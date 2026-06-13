;;; rg-compat.el --- Local compatibility shims -*- lexical-binding: t; -*-

(require 'cl-lib)

(defun rg/parsebib-normalize-escaped-braces ()
  "Normalize Zotero escaped braces in the current BibTeX buffer."
  (goto-char (point-min))
  (while (re-search-forward "\\\\\\([{}]\\)" nil t)
    (replace-match
     (if (string= (match-string 1) "{")
         "{\\\\textbraceleft}"
       "{\\\\textbraceright}")
     t t)))

(defun rg/parsebib-parse-bib-buffer-normalized (orig-fn &rest args)
  "Call ORIG-FN on a normalized copy of the current BibTeX buffer."
  (let ((contents (buffer-substring-no-properties (point-min) (point-max)))
        (dialect (and (boundp 'bibtex-dialect) bibtex-dialect))
        (directory default-directory))
    (with-temp-buffer
      (setq default-directory directory)
      (when dialect
        (setq-local bibtex-dialect dialect))
      (insert contents)
      (rg/parsebib-normalize-escaped-braces)
      (apply orig-fn args))))

(with-eval-after-load 'parsebib
  (unless (advice-member-p #'rg/parsebib-parse-bib-buffer-normalized
                           'parsebib-parse-bib-buffer)
    (advice-add 'parsebib-parse-bib-buffer
                :around #'rg/parsebib-parse-bib-buffer-normalized)))

(defun rg/flycheck-org-lint-line-number (line)
  "Return a numeric line for LINE from Org lint report data."
  (cond
   ((numberp line) line)
   ((markerp line) (line-number-at-pos line))
   ((and (stringp line)
         (markerp (get-text-property 0 'org-lint-marker line)))
    (line-number-at-pos (get-text-property 0 'org-lint-marker line)))
   ((stringp line)
    (max 1 (string-to-number line)))
   (t 1)))

(defun rg/flycheck-org-lint-start (checker callback)
  "Run Org lint for Flycheck CHECKER and report through CALLBACK."
  (condition-case err
      (let ((errors
             (delq nil
                   (mapcar
                    (lambda (report)
                      (pcase report
                        (`(,_id [,line ,_trust ,description ,_checker])
                         (flycheck-error-new-at
                          (rg/flycheck-org-lint-line-number line)
                          nil 'info description
                          :checker checker))
                        (_
                         (flycheck-error-new-at
                          1 nil 'warning
                          (format "Unexpected org-lint format: %S" report)
                          :checker checker))))
                    (org-lint)))))
        (funcall callback 'finished errors))
    (error
     (funcall callback 'errored (error-message-string err)))))

(with-eval-after-load 'flycheck
  (put 'org-lint 'flycheck-start #'rg/flycheck-org-lint-start))

(provide 'rg-compat)
;;; rg-compat.el ends here
