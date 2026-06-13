;;; rg-bibtex.el --- Local bibliography helpers -*- lexical-binding: t; -*-

(require 'seq)
(require 'subr-x)

(defvar bibtex-completion-bibliography)
(defvar citar-bibliography)
(defvar org-cite-global-bibliography)
(defvar org-cite-basic-mouse-over-key-face)

(declare-function org-cite-boundaries "oc")
(declare-function org-cite-get-references "oc")
(declare-function org-cite-key-boundaries "oc")

(defgroup rg-bibtex nil
  "Local bibliography and notes path helpers."
  :group 'tools)

(defcustom rg/bibtex-default-notes-directory (expand-file-name "~/org/")
  "Default Org notes directory used when no private value is configured."
  :type 'directory)

(defcustom rg/bibtex-default-source-file (expand-file-name "~/Documents/zotLib.bib")
  "Default BibTeX file used when no private value is configured."
  :type 'file)

(defcustom rg/zot-bib-auto-refresh-idle-delay 30
  "Idle seconds before checking whether the BibTeX cache is stale."
  :type 'number)

(defconst rg/bibtex-library-file
  (or load-file-name
      buffer-file-name
      (locate-library "rg-bibtex"))
  "Path to this helper file for child Emacs cache refreshes.")

(defvar org_notes nil
  "Org notes directory used by this Doom config.")

(defvar zot_bib_source nil
  "Source BibTeX file used to refresh the local cache.")

(defvar zot_bib_cache nil
  "Local cached BibTeX file.")

(defvar zot_bib_clean_cache nil
  "Sanitized local BibTeX cache used by parsebib-backed tools.")

(defvar zot_bib nil
  "Active BibTeX file used by completion and citation commands.")

(defvar rg/zot-bib-refresh-cache-async-running nil
  "Current async BibTeX refresh process, or nil when no refresh is active.")

(defvar rg/zot-bib-auto-refresh-timer nil
  "Idle timer used to refresh stale BibTeX caches.")

(defun rg/bibtex--env (name)
  "Return non-empty environment variable NAME."
  (when-let ((value (getenv name)))
    (unless (string-empty-p value)
      value)))

(defun rg/bibtex--bound-value (symbol)
  "Return SYMBOL's value when it is bound to a string."
  (when (and (boundp symbol) (stringp (symbol-value symbol)))
    (symbol-value symbol)))

(defun rg/bibtex--directory (path)
  "Return PATH as an expanded directory name."
  (file-name-as-directory (expand-file-name path)))

(defun rg/bibtex-default-cache-file ()
  "Return the default local BibTeX cache file."
  (expand-file-name "doom/zotLib.bib"
                    (or (rg/bibtex--env "XDG_CACHE_HOME")
                        (expand-file-name "~/.cache"))))

(defun rg/bibtex-default-clean-cache-file ()
  "Return the default sanitized local BibTeX cache file."
  (expand-file-name "doom/zotLib.clean.bib"
                    (or (rg/bibtex--env "XDG_CACHE_HOME")
                        (expand-file-name "~/.cache"))))

(defun rg/bibtex--first-readable (&rest files)
  "Return the first readable file in FILES."
  (seq-find (lambda (file)
              (and (stringp file) (file-readable-p file)))
            files))

(defun rg/bibtex--file-mtime (file)
  "Return FILE modification time when FILE is readable."
  (when (and (stringp file) (file-readable-p file))
    (file-attribute-modification-time (file-attributes file))))

(defun rg/bibtex-file-newer-p (file other-file)
  "Return non-nil when FILE is newer than OTHER-FILE."
  (when-let ((file-time (rg/bibtex--file-mtime file)))
    (let ((other-time (rg/bibtex--file-mtime other-file)))
      (or (null other-time)
          (time-less-p other-time file-time)))))

(defun rg/bibtex-configure-paths ()
  "Configure notes and bibliography paths from private values or environment."
  (setq org_notes
        (rg/bibtex--directory
         (or (rg/bibtex--env "RG_ORG_NOTES_DIR")
             (rg/bibtex--bound-value 'org_notes)
             rg/bibtex-default-notes-directory))
        zot_bib_source
        (expand-file-name
         (or (rg/bibtex--env "RG_ZOT_BIB")
             (rg/bibtex--bound-value 'zot_bib_source)
             rg/bibtex-default-source-file))
        zot_bib_cache
        (expand-file-name
         (or (rg/bibtex--env "RG_ZOT_BIB_CACHE")
             (rg/bibtex--bound-value 'zot_bib_cache)
             (rg/bibtex-default-cache-file)))
        zot_bib_clean_cache
        (expand-file-name
         (or (rg/bibtex--env "RG_ZOT_BIB_CLEAN_CACHE")
             (rg/bibtex--bound-value 'zot_bib_clean_cache)
             (rg/bibtex-default-clean-cache-file))))
  (rg/bibtex-ensure-clean-cache)
  (setq zot_bib
        (or (rg/bibtex--first-readable zot_bib_clean_cache
                                        zot_bib_cache
                                        zot_bib_source)
            zot_bib_source)
        org-directory org_notes
        deft-directory org_notes
        org-roam-directory org_notes)
  (rg/bibtex-apply-active-bibliography)
  zot_bib)

(defun rg/bibtex-ensure-clean-cache ()
  "Create the sanitized BibTeX cache when it is missing."
  (when-let ((input-file (and (not (file-readable-p zot_bib_clean_cache))
                              (rg/bibtex--first-readable zot_bib_cache
                                                          zot_bib_source))))
    (rg/zot-bib-build-clean-cache input-file zot_bib_clean_cache)))

(defun rg/bibtex-apply-active-bibliography ()
  "Point citation consumers at the active BibTeX file."
  (let ((bibliography (list zot_bib)))
    (when (boundp 'org-cite-global-bibliography)
      (setq org-cite-global-bibliography bibliography))
    (when (boundp 'citar-bibliography)
      (setq citar-bibliography bibliography))
    (when (boundp 'bibtex-completion-bibliography)
      (setq bibtex-completion-bibliography bibliography))
    bibliography))

(defun rg/citar-org-fast-activate (citation)
  "Apply cheap text properties for Org citation CITATION."
  (pcase-let ((`(,beg . ,end) (org-cite-boundaries citation)))
    (put-text-property beg end 'font-lock-multiline t)
    (add-face-text-property beg end 'org-cite)
    (dolist (reference (org-cite-get-references citation))
      (pcase-let ((`(,key-beg . ,key-end)
                   (org-cite-key-boundaries reference)))
        (when (boundp 'org-cite-basic-mouse-over-key-face)
          (put-text-property key-beg
                             key-end
                             'mouse-face
                             org-cite-basic-mouse-over-key-face))
        (add-face-text-property key-beg key-end 'org-cite-key)))))

(defun rg/zot-bib-use-cache ()
  "Use the best local BibTeX cache when it is readable."
  (setq zot_bib (or (rg/bibtex--first-readable zot_bib_clean_cache
                                                zot_bib_cache
                                                zot_bib_source)
                    zot_bib_source))
  (rg/bibtex-apply-active-bibliography)
  zot_bib)

(defun rg/zot-bib-cache-stale-p ()
  "Return non-nil when the sanitized BibTeX cache needs a refresh."
  (rg/bibtex-configure-paths)
  (and (file-readable-p zot_bib_source)
       (or (not (file-readable-p zot_bib_clean_cache))
           (rg/bibtex-file-newer-p zot_bib_source zot_bib_clean_cache))))

(defun rg/bibtex-sanitize-buffer ()
  "Normalize BibTeX escapes that parsebib rejects in Zotero exports."
  (save-excursion
    (goto-char (point-min))
    (while (re-search-forward "\\\\[{}]" nil t)
      (replace-match "" t t))))

(defun rg/zot-bib-build-clean-cache (&optional input output)
  "Build sanitized BibTeX cache from INPUT at OUTPUT."
  (interactive)
  (unless (and input output)
    (rg/bibtex-configure-paths))
  (let ((input-file (or input
                        (rg/bibtex--first-readable zot_bib_cache
                                                    zot_bib_source)))
        (output-file (or output zot_bib_clean_cache)))
    (unless (file-readable-p input-file)
      (user-error "Cannot read %s" input-file))
    (make-directory (file-name-directory output-file) t)
    (with-temp-buffer
      (insert-file-contents input-file)
      (rg/bibtex-sanitize-buffer)
      (write-region (point-min) (point-max) output-file nil 'silent))
    output-file))

(defun rg/zot-bib-refresh-cache ()
  "Refresh the local BibTeX caches from `zot_bib_source'."
  (interactive)
  (rg/bibtex-configure-paths)
  (unless (file-readable-p zot_bib_source)
    (user-error "Cannot read %s" zot_bib_source))
  (make-directory (file-name-directory zot_bib_cache) t)
  (copy-file zot_bib_source zot_bib_cache t)
  (rg/zot-bib-build-clean-cache zot_bib_cache zot_bib_clean_cache)
  (rg/zot-bib-use-cache)
  (when (featurep 'bibtex-completion)
    (bibtex-completion-clear-cache (list zot_bib))
    (bibtex-completion-clear-string-cache (list zot_bib)))
  (message "BibTeX cache refreshed: %s" zot_bib)
  zot_bib)

(defun rg/bibtex-clear-completion-caches ()
  "Clear loaded BibTeX completion caches."
  (when (featurep 'bibtex-completion)
    (bibtex-completion-clear-cache (list zot_bib))
    (bibtex-completion-clear-string-cache (list zot_bib))))

(defun rg/bibtex--async-start (start-func finish-func)
  "Run START-FUNC asynchronously and call FINISH-FUNC with the result."
  (require 'async)
  (async-start start-func finish-func))

(defun rg/zot-bib-refresh-cache-async-finish (result)
  "Handle async BibTeX refresh RESULT."
  (setq rg/zot-bib-refresh-cache-async-running nil)
  (if (plist-get result :ok)
      (progn
        (rg/zot-bib-use-cache)
        (rg/bibtex-clear-completion-caches)
        (message "BibTeX cache refreshed asynchronously: %s"
                 (plist-get result :path)))
    (message "BibTeX async refresh failed: %s"
             (plist-get result :error))))

(defun rg/zot-bib-refresh-cache-async (&optional force)
  "Refresh stale BibTeX caches in a child Emacs process.
With FORCE, refresh even when the sanitized cache is current."
  (interactive "P")
  (rg/bibtex-configure-paths)
  (cond
   ((and rg/zot-bib-refresh-cache-async-running (not force))
    (message "BibTeX async refresh already running")
    nil)
   ((and (not force) (not (rg/zot-bib-cache-stale-p)))
    (rg/zot-bib-use-cache)
    (message "BibTeX clean cache is current: %s" zot_bib)
    nil)
   (t
    (let* ((helper-file rg/bibtex-library-file)
           (notes-dir org_notes)
           (source-file zot_bib_source)
           (raw-cache zot_bib_cache)
           (clean-cache zot_bib_clean_cache)
           (process
            (rg/bibtex--async-start
             `(lambda ()
                (condition-case err
                    (progn
                      (load ,helper-file nil t)
                      (setq org_notes ,notes-dir
                            zot_bib_source ,source-file
                            zot_bib_cache ,raw-cache
                            zot_bib_clean_cache ,clean-cache)
                      (rg/zot-bib-refresh-cache)
                      (list :ok t :path zot_bib))
                  (error
                   (list :ok nil :error (error-message-string err)))))
             #'rg/zot-bib-refresh-cache-async-finish)))
      (setq rg/zot-bib-refresh-cache-async-running process)
      process))))

(defun rg/zot-bib-refresh-cache-on-idle ()
  "Refresh stale BibTeX caches from an idle timer."
  (when (rg/zot-bib-cache-stale-p)
    (rg/zot-bib-refresh-cache-async)))

(defun rg/zot-bib-enable-auto-refresh ()
  "Enable idle BibTeX cache refresh checks."
  (interactive)
  (when (timerp rg/zot-bib-auto-refresh-timer)
    (cancel-timer rg/zot-bib-auto-refresh-timer))
  (setq rg/zot-bib-auto-refresh-timer
        (run-with-idle-timer rg/zot-bib-auto-refresh-idle-delay
                             t
                             #'rg/zot-bib-refresh-cache-on-idle)))

(defun rg/bibtex-completion-warm-cache ()
  "Load BibTeX completion candidates explicitly."
  (interactive)
  (require 'bibtex-completion)
  (rg/zot-bib-use-cache)
  (message "BibTeX candidates loaded: %d"
           (length (bibtex-completion-candidates))))

(provide 'rg-bibtex)
;;; rg-bibtex.el ends here
