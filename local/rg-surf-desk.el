;;; rg-surf-desk.el --- Keep the SENT property with the todo state -*- lexical-binding: t; -*-

;; :POST: is a Babel header argument. Org warns on it and tells you to use
;; :header-args:. The desk property is SENT for that reason.
;; SPC m t, then d, runs `org-todo' into DONE(d). That logs CLOSED and does
;; not touch a property. This hook does, when SENT is already on the entry.

(defun rg-surf-desk-sent-value (state)
  "Return yes when STATE is the string DONE."
  (if (equal state "DONE") "yes" "no"))

(defun rg-surf-desk-sync-sent (&rest _)
  "Set SENT from `org-state' when the entry already has that property."
  (when (and (derived-mode-p 'org-mode)
             (org-entry-get nil "SENT"))
    (org-set-property "SENT" (rg-surf-desk-sent-value org-state))))

(add-hook 'org-after-todo-state-change-hook #'rg-surf-desk-sync-sent)

(defun rg-surf-desk-lint-script (file)
  "Return desk-lint.py for the repository that contains FILE."
  (let ((root (locate-dominating-file
               file
               (lambda (dir)
                 (file-exists-p (expand-file-name "Software/SURF/advisor/desk-lint.py" dir))))))
    (when root
      (expand-file-name "Software/SURF/advisor/desk-lint.py" root))))

(defun rg-surf-desk-entry-src ()
  "Return the text of the source block in the Org entry at point."
  (save-excursion
    (org-back-to-heading t)
    (let ((end (save-excursion (org-end-of-subtree t t))))
      (when (re-search-forward "^#\\+begin_src\\b.*\n" end t)
        (let ((start (point)))
          (when (re-search-forward "^#\\+end_src" end t)
            (buffer-substring-no-properties start (match-beginning 0))))))))

(defun rg-surf-desk-copy-src ()
  "Copy the reply block of the Org entry at point."
  (interactive)
  (let ((text (rg-surf-desk-entry-src)))
    (unless (and text (not (string-empty-p (string-trim text))))
      (user-error "No reply block in this heading"))
    (kill-new (string-trim text))
    (message "Copied the reply block")))

(defun rg-surf-desk-lint ()
  "Lint the desk ticket directory of the current file."
  (interactive)
  (let* ((file (or (buffer-file-name) (user-error "This buffer has no file")))
         (script (or (rg-surf-desk-lint-script file)
                     (user-error "desk-lint.py is not in this repository")))
         (dir (locate-dominating-file file "overview.org"))
         (target (or dir file)))
    (compile (format "%s %s"
                     (shell-quote-argument script)
                     (shell-quote-argument target)))))

(when (fboundp 'after!)
  (after! org
    (map! :map org-mode-map
          :localleader
          (:prefix ("j" . "desk")
           :desc "Copy the reply block" "c" #'rg-surf-desk-copy-src
           :desc "Lint this ticket" "l" #'rg-surf-desk-lint))))

(provide 'rg-surf-desk)
;;; rg-surf-desk.el ends here
