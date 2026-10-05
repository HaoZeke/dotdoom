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

(provide 'rg-surf-desk)
;;; rg-surf-desk.el ends here
