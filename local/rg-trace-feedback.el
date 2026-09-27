;;; rg-trace-feedback.el --- Loader for private xait trace helpers -*- lexical-binding: t; -*-

(defconst rg/trace-feedback-private-implementation-file
  (expand-file-name "local/private/rg-trace-feedback.el"
                    (if (boundp 'doom-private-dir)
                        doom-private-dir
                      user-emacs-directory))
  "Private trace-feedback implementation.")

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

(when (fboundp 'rg/trace-feedback-submit)
  (unless (fboundp 'rg/trace-feedback-submit-trace)
    (defalias 'rg/trace-feedback-submit-trace
      (symbol-function 'rg/trace-feedback-submit)))
  (defun rg/review-submit ()
    "Stamp a submitted CQA packet or Trace Analysis feedback packet."
    (interactive)
    (if (and (fboundp 'rg/cqa--task-dir)
             (ignore-errors (rg/cqa--task-dir)))
        (call-interactively #'rg/cqa-stamp-submission)
      (call-interactively #'rg/trace-feedback-submit-trace)))
  (defalias 'rg/trace-feedback-submit #'rg/review-submit))

(provide 'rg-trace-feedback)
;;; rg-trace-feedback.el ends here
