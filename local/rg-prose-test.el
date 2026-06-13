;;; rg-prose-test.el --- Tests for local prose helpers -*- lexical-binding: t; -*-

(require 'ert)
(require 'rg-prose)

(ert-deftest rg-prose-profile-duration-defaults ()
  (let ((rg/profile-org-editing-seconds 17))
    (should (equal (rg/prose-profile-duration nil) 17))))

(ert-deftest rg-prose-profile-duration-uses-prefix ()
  (should (equal (rg/prose-profile-duration 9) 9)))

(ert-deftest rg-prose-flycheck-on-save-sets-local-policy ()
  (with-temp-buffer
    (rg/prose-flycheck-on-save)
    (should
     (equal flycheck-check-syntax-automatically '(save)))))

(provide 'rg-prose-test)
;;; rg-prose-test.el ends here
