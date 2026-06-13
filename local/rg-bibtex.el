;;; rg-bibtex.el --- Local bibliography helpers -*- lexical-binding: t; -*-

(require 'subr-x)

(defgroup rg-bibtex nil
  "Local bibliography and notes path helpers."
  :group 'tools)

(defcustom rg/bibtex-default-notes-directory (expand-file-name "~/org/")
  "Default Org notes directory used when no private value is configured."
  :type 'directory)

(defcustom rg/bibtex-default-source-file (expand-file-name "~/Documents/zotLib.bib")
  "Default BibTeX file used when no private value is configured."
  :type 'file)

(defvar org_notes nil
  "Org notes directory used by this Doom config.")

(defvar zot_bib_source nil
  "Source BibTeX file used to refresh the local cache.")

(defvar zot_bib_cache nil
  "Local cached BibTeX file.")

(defvar zot_bib nil
  "Active BibTeX file used by completion and citation commands.")

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
        zot_bib
        (if (file-readable-p zot_bib_cache) zot_bib_cache zot_bib_source)
        org-directory org_notes
        deft-directory org_notes
        org-roam-directory org_notes)
  (when (boundp 'bibtex-completion-bibliography)
    (setq bibtex-completion-bibliography (list zot_bib)))
  zot_bib)

(defun rg/zot-bib-use-cache ()
  "Use the local BibTeX cache when it is readable."
  (setq zot_bib (if (file-readable-p zot_bib_cache)
                    zot_bib_cache
                  zot_bib_source))
  (when (boundp 'bibtex-completion-bibliography)
    (setq bibtex-completion-bibliography (list zot_bib)))
  zot_bib)

(defun rg/zot-bib-refresh-cache ()
  "Refresh the local BibTeX cache from `zot_bib_source'."
  (interactive)
  (rg/bibtex-configure-paths)
  (unless (file-readable-p zot_bib_source)
    (user-error "Cannot read %s" zot_bib_source))
  (make-directory (file-name-directory zot_bib_cache) t)
  (copy-file zot_bib_source zot_bib_cache t)
  (rg/zot-bib-use-cache)
  (when (featurep 'bibtex-completion)
    (bibtex-completion-clear-cache (list zot_bib))
    (bibtex-completion-clear-string-cache (list zot_bib)))
  (message "BibTeX cache refreshed: %s" zot_bib_cache))

(defun rg/bibtex-completion-warm-cache ()
  "Load BibTeX completion candidates explicitly."
  (interactive)
  (require 'bibtex-completion)
  (rg/zot-bib-use-cache)
  (message "BibTeX candidates loaded: %d"
           (length (bibtex-completion-candidates))))

(provide 'rg-bibtex)
;;; rg-bibtex.el ends here
