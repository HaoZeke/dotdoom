;;; rg-prose.el --- Local prose editing helpers -*- lexical-binding: t; -*-

(defgroup rg-prose nil
  "Local prose editing helpers."
  :group 'tools)

(defcustom rg/profile-org-editing-seconds 25
  "Seconds to collect CPU profiler samples for Org editing."
  :type 'integer)

(defun rg/prose-profile-duration (seconds)
  "Return profiling duration from prefix argument SECONDS."
  (if seconds
      (prefix-numeric-value seconds)
    rg/profile-org-editing-seconds))

(defun rg/profile-org-editing (&optional seconds)
  "Profile Org editing CPU use for SECONDS."
  (interactive "P")
  (let ((duration (rg/prose-profile-duration seconds)))
    (profiler-start 'cpu)
    (run-at-time
     duration nil
     (lambda ()
       (profiler-stop)
       (profiler-report)))
    (message "Profiling Org editing for %s seconds" duration)))

(defun rg/prose-eglot-ensure ()
  "Start Eglot for the current prose buffer."
  (interactive)
  (eglot-ensure))

(defun rg/prose-flycheck-on-save ()
  "Run Flycheck in prose buffers on save."
  (setq-local flycheck-check-syntax-automatically '(save)))

(provide 'rg-prose)
;;; rg-prose.el ends here
