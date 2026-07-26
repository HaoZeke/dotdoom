;;; rg-trace-feedback.el --- Loader for private xait trace helpers -*- lexical-binding: t; -*-

(defconst rg/trace-feedback-private-implementation-file
  (expand-file-name "local/private/rg-trace-feedback.el"
                    (if (boundp 'doom-private-dir)
                        doom-private-dir
                      user-emacs-directory))
  "Nimvaulted xait trace-feedback implementation.")

(defconst rg/trace-feedback-answer-export-file
  (expand-file-name
   "~/Git/Github/Tools/single-turn-review/emacs/rg-st-export.el")
  "Turn-grouped Trace Analysis answer exporter.")

(defun rg/trace-feedback-private-status ()
  "Report whether the private trace-feedback implementation is available."
  (interactive)
  (if (file-readable-p rg/trace-feedback-private-implementation-file)
      (message "Private xait trace-feedback helper is available")
    (user-error "Run nimvault unseal in the Doom config repository")))

(if (file-readable-p rg/trace-feedback-private-implementation-file)
    (load rg/trace-feedback-private-implementation-file nil 'nomessage)
  (defun rg/trace-feedback-load-private-settings ()
    "Leave trace feedback disabled while the private vault is sealed."
    (message "xait trace feedback disabled; run nimvault unseal")))

(when (file-readable-p rg/trace-feedback-answer-export-file)
  (load rg/trace-feedback-answer-export-file nil 'nomessage))

(provide 'rg-trace-feedback)
;;; rg-trace-feedback.el ends here
