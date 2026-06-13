;;; rg-org-visual.el --- Local Org visual helpers -*- lexical-binding: t; -*-

(defvar rg/org-visual-max-buffer-size (* 1024 1024)
  "Maximum Org buffer size for automatic visual prettification.")

(defun rg/org-visual-buffer-p ()
  "Return non-nil when the current Org buffer should use visual prettification."
  (and (derived-mode-p 'org-mode)
       (not (file-remote-p default-directory))
       (<= (buffer-size) rg/org-visual-max-buffer-size)))

(defun rg/org-modern-mode-maybe ()
  "Enable `org-modern-mode' when the current Org buffer is cheap to prettify."
  (when (rg/org-visual-buffer-p)
    (org-modern-mode 1)))

(defun rg/org-appear-mode-maybe ()
  "Enable `org-appear-mode' when Org visual prettification is cheap."
  (when (rg/org-visual-buffer-p)
    (org-appear-mode 1)))

(defun rg/org-visuals-toggle ()
  "Toggle Org visual prettification in the current buffer."
  (interactive)
  (unless (derived-mode-p 'org-mode)
    (user-error "Org visuals are only available in org-mode buffers"))
  (if (or (bound-and-true-p org-modern-mode)
          (bound-and-true-p org-appear-mode))
      (progn
        (when (bound-and-true-p org-modern-mode)
          (org-modern-mode -1))
        (when (bound-and-true-p org-appear-mode)
          (org-appear-mode -1)))
    (when (fboundp 'org-modern-mode)
      (org-modern-mode 1))
    (when (fboundp 'org-appear-mode)
      (org-appear-mode 1))))

(provide 'rg-org-visual)
;;; rg-org-visual.el ends here
