;;; rg-trawl.el --- Emacs desk for trawl find/land/noter -*- lexical-binding: t; -*-

(require 'cl-lib)
(require 'subr-x)
(require 'rg-cite-notes)

(defgroup rg-trawl nil
  "Couple org-noter to trawl, Zotero, and Ridley."
  :group 'tools)

(defcustom rg/trawl-command "trawl"
  "trawl executable on PATH."
  :type 'string)

(defcustom rg/trawl-ridley-library
  (expand-file-name "~/.local/share/Ridley/libraries/personal.redb")
  "Live Ridley store used for org-noter item lookup."
  :type 'file)

(defun rg/trawl--run (&rest args)
  "Run trawl with ARGS. Return (exit-code . stdout)."
  (with-temp-buffer
    (cons (apply #'call-process rg/trawl-command nil t nil args)
          (buffer-string))))

(defun rg/trawl--ok (result)
  "Return stdout from RESULT when exit code is zero."
  (when (zerop (car result))
    (cdr result)))

(defun rg/trawl-parse-find-line (line)
  "Parse one `trawl find` LINE into (doi . title) or nil."
  (when (string-match "doi:\\(\\S-+\\)\\s-*$" line)
    (let ((doi (match-string 1 line))
          (title (if (string-match "^[0-9]+\\. \\(.+\\) (.*) .* doi:" line)
                     (string-trim (match-string 1 line))
                   line)))
      (cons doi title))))

(defun rg/trawl-find (query)
  "Run `trawl find QUERY' and return parsed hits."
  (interactive "sFind: ")
  (let* ((out (rg/trawl--ok (apply #'rg/trawl--run
                                   (append '("find") (split-string query)))))
         (hits (and out
                    (cl-remove-if
                     #'null
                     (mapcar #'rg/trawl-parse-find-line
                             (split-string out "\n" t))))))
    (when (called-interactively-p 'interactive)
      (if (null hits)
          (user-error "trawl find: no hits")
        (let* ((choice (completing-read
                        "Hit: "
                        (mapcar (lambda (h) (format "%s  %s" (car h) (cdr h)))
                                hits)
                        nil t))
               (doi (car (split-string choice))))
          (kill-new doi)
          (message "DOI %s (yank, then rg/trawl-land)" doi))))
    hits))

(defun rg/trawl-land (doi)
  "Land one DOI through trawl."
  (interactive "sDOI: ")
  (let ((res (rg/trawl--run "land" doi)))
    (unless (zerop (car res))
      (user-error "trawl land: %s" (string-trim (cdr res))))
    (when (fboundp 'rg/zot-bib-refresh-cache-async)
      (rg/zot-bib-refresh-cache-async))
    (message "%s" (string-trim (cdr res)))
    (cdr res)))

(defun rg/trawl-today ()
  "Show `trawl today' in a buffer."
  (interactive)
  (let ((res (rg/trawl--run "today")))
    (with-current-buffer (get-buffer-create "*trawl-today*")
      (let ((inhibit-read-only t))
        (erase-buffer)
        (insert (cdr res))
        (special-mode)
        (goto-char (point-min))
        (pop-to-buffer (current-buffer))))))

(defun rg/trawl-log (kind &optional doi title)
  "Append a ledger line via `trawl log'."
  (let ((args (list "log" kind)))
    (when doi
      (setq args (append args (list "--doi" doi))))
    (when title
      (setq args (append args (list "--title" title))))
    (apply #'rg/trawl--run args)))

(defun rg/trawl--doi-at-point ()
  "DOI from org property or cite at point."
  (or (and (fboundp 'org-entry-get) (org-entry-get (point) "DOI" t))
      (and (fboundp 'org-entry-get) (org-entry-get (point) "TRAWL_DOI" t))))

(defun rg/trawl-noter-log-insert ()
  "Record an org-noter insert on the trawl ledger."
  (when (and (fboundp 'org-entry-get) (derived-mode-p 'org-mode))
    (rg/trawl-log "noter"
                  (rg/trawl--doi-at-point)
                  (org-entry-get (point) "ITEM"))))

(defun rg/trawl-install-noter-hook ()
  "Hook org-noter inserts into the trawl ledger."
  (when (boundp 'org-noter-insert-heading-hook)
    (add-hook 'org-noter-insert-heading-hook #'rg/trawl-noter-log-insert))
  (advice-add 'org-noter-insert-note :after
              (lambda (&rest _) (rg/trawl-noter-log-insert))))

(defun rg/trawl-ridley-json-files ()
  "Ridley item JSON files from the live store. Never sample or seed fixtures."
  (let* ((live rg/trawl-ridley-library)
         (json (cond
                ((and live (file-directory-p live))
                 (expand-file-name "library.json" live))
                ((and live (string-match-p "\\.json\\'" live))
                 live)
                (t nil))))
    (and json (file-readable-p json) (list json))))

(defun rg/trawl-configure ()
  "Apply org-noter and Ridley paths for the trawl desk."
  (setq org-noter-default-notes-file-names '("bibnotes.org")
        org-noter-auto-save-last-location t)
  (when (boundp 'org_notes)
    (setq org-noter-notes-search-path (list org_notes)))
  (rg/trawl-install-noter-hook)
  (when (boundp 'ookcite-ridley-item-json-files)
    (setq ookcite-ridley-item-json-files (rg/trawl-ridley-json-files))))

(with-eval-after-load 'org-noter
  (rg/trawl-configure))

(provide 'rg-trawl)
;;; rg-trawl.el ends here
