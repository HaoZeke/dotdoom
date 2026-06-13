;;; rg-org-visual-test.el --- Tests for Org visual helpers -*- lexical-binding: t; -*-

(require 'cl-lib)
(require 'ert)
(require 'org)
(require 'rg-org-visual)

(ert-deftest rg-org-visual-buffer-accepts-small-local-org-buffer ()
  (with-temp-buffer
    (org-mode)
    (let ((default-directory "/tmp/")
          (rg/org-visual-max-buffer-size 10))
      (insert "* ok\n")
      (should (rg/org-visual-buffer-p)))))

(ert-deftest rg-org-visual-buffer-skips-large-org-buffer ()
  (with-temp-buffer
    (org-mode)
    (let ((default-directory "/tmp/")
          (rg/org-visual-max-buffer-size 3))
      (insert "* too large\n")
      (should-not (rg/org-visual-buffer-p)))))

(ert-deftest rg-org-visual-buffer-skips-remote-org-buffer ()
  (with-temp-buffer
    (org-mode)
    (let ((default-directory "/ssh:test.example:/tmp/")
          (rg/org-visual-max-buffer-size 100))
      (insert "* remote\n")
      (should-not (rg/org-visual-buffer-p)))))

(ert-deftest rg-org-visuals-toggle-enables-available-visual-modes ()
  (with-temp-buffer
    (org-mode)
    (setq-local org-modern-mode nil)
    (setq-local org-appear-mode nil)
    (let (calls)
      (cl-letf (((symbol-function 'org-modern-mode)
                 (lambda (arg)
                   (push (list 'org-modern-mode arg) calls)
                   (setq org-modern-mode (> arg 0))))
                ((symbol-function 'org-appear-mode)
                 (lambda (arg)
                   (push (list 'org-appear-mode arg) calls)
                   (setq org-appear-mode (> arg 0)))))
        (rg/org-visuals-toggle)
        (should (member '(org-modern-mode 1) calls))
        (should (member '(org-appear-mode 1) calls))
        (should org-modern-mode)
        (should org-appear-mode)))))

(ert-deftest rg-org-visuals-toggle-disables-active-visual-modes ()
  (with-temp-buffer
    (org-mode)
    (setq-local org-modern-mode t)
    (setq-local org-appear-mode t)
    (let (calls)
      (cl-letf (((symbol-function 'org-modern-mode)
                 (lambda (arg)
                   (push (list 'org-modern-mode arg) calls)
                   (setq org-modern-mode (> arg 0))))
                ((symbol-function 'org-appear-mode)
                 (lambda (arg)
                   (push (list 'org-appear-mode arg) calls)
                   (setq org-appear-mode (> arg 0)))))
        (rg/org-visuals-toggle)
        (should (member '(org-modern-mode -1) calls))
        (should (member '(org-appear-mode -1) calls))
        (should-not org-modern-mode)
        (should-not org-appear-mode)))))

(provide 'rg-org-visual-test)
;;; rg-org-visual-test.el ends here
