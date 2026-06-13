;;; rg-compat.el --- Local compatibility shims -*- lexical-binding: t; -*-

(require 'cl-lib)

(defvar-local rg/parsebib-normalized-buffer nil
  "Non-nil when the current buffer has normalized escaped BibTeX braces.")

(defun rg/parsebib-normalize-escaped-braces ()
  "Normalize Zotero escaped braces in the current BibTeX buffer."
  (goto-char (point-min))
  (while (re-search-forward "\\\\\\([{}]\\)" nil t)
    (replace-match
     (if (string= (match-string 1) "{")
         "{\\\\textbraceleft}"
       "{\\\\textbraceright}")
     t t)))

(defun rg/parsebib-normalize-current-buffer-once ()
  "Normalize escaped BibTeX braces in the current buffer once."
  (unless rg/parsebib-normalized-buffer
    (save-excursion
      (rg/parsebib-normalize-escaped-braces))
    (setq rg/parsebib-normalized-buffer t)))

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
      (rg/parsebib-normalize-current-buffer-once)
      (apply orig-fn args))))

(with-eval-after-load 'parsebib
  (unless (advice-member-p #'rg/parsebib-parse-bib-buffer-normalized
                           'parsebib-parse-bib-buffer)
    (advice-add 'parsebib-parse-bib-buffer
                :around #'rg/parsebib-parse-bib-buffer-normalized)))

(defun rg/bibtex-completion-with-normalized-buffer (orig-fn &rest args)
  "Call ORIG-FN after normalizing the current BibTeX buffer."
  (rg/parsebib-normalize-current-buffer-once)
  (apply orig-fn args))

(with-eval-after-load 'bibtex-completion
  (dolist (fn '(bibtex-completion-parse-bibliography
                bibtex-completion-parse-strings))
    (unless (advice-member-p #'rg/bibtex-completion-with-normalized-buffer fn)
      (advice-add fn :around #'rg/bibtex-completion-with-normalized-buffer))))

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
