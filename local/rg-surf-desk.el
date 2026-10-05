;;; rg-surf-desk.el --- Loader for the private desk helper -*- lexical-binding: t; -*-

(defconst rg-surf-desk-private-file
  (or (and load-file-name
           (let ((beside (expand-file-name "private/rg-surf-desk.el"
                                           (file-name-directory load-file-name))))
             (and (file-readable-p beside) beside)))
      (expand-file-name "local/private/rg-surf-desk.el"
                        (if (boundp 'doom-private-dir)
                            doom-private-dir
                          user-emacs-directory)))
  "Private desk implementation.")

(defun rg-surf-desk-private-status ()
  "Report whether the private desk helper is available."
  (interactive)
  (if (file-readable-p rg-surf-desk-private-file)
      (message "Private desk helper is available")
    (user-error "Run nimvault unseal in the Doom config repository")))

(if (file-readable-p rg-surf-desk-private-file)
    (load rg-surf-desk-private-file nil 'nomessage)
  (defun rg-surf-desk-sync-sent (&rest _)
    "Leave the desk helper idle while the vault is sealed."
    nil))

(provide 'rg-surf-desk)
;;; rg-surf-desk.el ends here
