;;; rg-health.el --- Local Doom health checks -*- lexical-binding: t; -*-

(require 'subr-x)
(require 'rg-bibtex nil t)
(require 'rg-snapper nil t)
(require 'rg-vale nil t)

(defun rg/health-item (name ok detail)
  "Return a health item named NAME with OK state and DETAIL."
  (list :name name
        :status (if ok 'ok 'warn)
        :detail detail))

(defun rg/health-executable (name executable)
  "Return a health item for EXECUTABLE named NAME."
  (if-let ((program (executable-find executable)))
      (rg/health-item name t (format "found %s" program))
    (rg/health-item name nil (format "missing %s" executable))))

(defun rg/health-readable-file (name file)
  "Return a health item for readable FILE named NAME."
  (if (and (stringp file) (file-readable-p file))
      (rg/health-item name t (format "readable %s" file))
    (rg/health-item name nil (format "not readable %s" file))))

(defun rg/health-bibtex-cache ()
  "Return a health item for the active BibTeX cache."
  (when (fboundp 'rg/bibtex-configure-paths)
    (rg/bibtex-configure-paths))
  (cond
   ((and (boundp 'zot_bib_cache) (file-readable-p zot_bib_cache))
    (rg/health-item "BibTeX cache" t (format "cache readable %s" zot_bib_cache)))
   ((and (boundp 'zot_bib_source) (file-readable-p zot_bib_source))
    (rg/health-item "BibTeX cache" nil (format "using source %s" zot_bib_source)))
   (t
    (rg/health-item "BibTeX cache" nil "no readable bibliography"))))

(defun rg/health-literate-after-save ()
  "Return a health item for Doom's literate after-save hook."
  (rg/health-item
   "Literate after-save"
   (not (memq '+literate-recompile-maybe-h after-save-hook))
   (if (memq '+literate-recompile-maybe-h after-save-hook)
       "automatic retangle hook present"
     "automatic retangle hook absent")))

(defun rg/health-org-lint ()
  "Return a health item for org-lint Flycheck status."
  (if (boundp 'flycheck-disabled-checkers)
      (rg/health-item
       "org-lint"
       (memq 'org-lint flycheck-disabled-checkers)
       (if (memq 'org-lint flycheck-disabled-checkers)
           "disabled in flycheck"
         "enabled in flycheck"))
    (rg/health-item "org-lint" t "flycheck not loaded")))

(defun rg/health-local-modules ()
  "Return health items for local helper modules."
  (mapcar
   (lambda (feature)
     (rg/health-item
      (format "module %s" feature)
      (featurep feature)
      (if (featurep feature) "loaded" "not loaded")))
   '(rg-bibtex rg-prose rg-snapper rg-vale)))

(defun rg/doom-health-items ()
  "Return local Doom health-check items."
  (append
   (list
    (rg/health-executable "Vale" (or (and (boundp 'rg/vale-executable)
                                          rg/vale-executable)
                                     "vale"))
    (rg/health-executable "Snapper" (or (and (boundp 'rg/snapper-executable)
                                             rg/snapper-executable)
                                        "snapper"))
    (rg/health-bibtex-cache)
    (rg/health-literate-after-save)
    (rg/health-org-lint))
   (rg/health-local-modules)))

(defun rg/health-render (items)
  "Render health ITEMS as a plain-text report."
  (concat
   "Status  Check                  Detail\n"
   "------  ---------------------  ------\n"
   (mapconcat
    (lambda (item)
      (format "%-6s  %-21s  %s"
              (upcase (symbol-name (plist-get item :status)))
              (plist-get item :name)
              (plist-get item :detail)))
    items
    "\n")
   "\n"))

(defun rg/doom-health-check ()
  "Display local Doom health checks."
  (interactive)
  (let ((buffer (get-buffer-create "*doom-health*")))
    (with-current-buffer buffer
      (let ((inhibit-read-only t))
        (erase-buffer)
        (insert (rg/health-render (rg/doom-health-items)))
        (goto-char (point-min))
        (special-mode)))
    (pop-to-buffer buffer)))

(provide 'rg-health)
;;; rg-health.el ends here
