;;; rg-surf-desk-test.el --- Tests for the SENT property -*- lexical-binding: t; -*-

(require 'ert)
(require 'rg-surf-desk)
(require 'org)

(ert-deftest rg-surf-desk-sent-value-follows-done ()
  (should (equal (rg-surf-desk-sent-value "DONE") "yes"))
  (should (equal (rg-surf-desk-sent-value "TODO") "no"))
  (should (equal (rg-surf-desk-sent-value nil) "no")))

(ert-deftest rg-surf-desk-sync-sent-flips-on-done ()
  (with-temp-buffer
    (org-mode)
    (insert "* Reply\n:PROPERTIES:\n:SENT: no\n:END:\nbody\n")
    (goto-char (point-min))
    (org-todo "DONE")
    (should (equal (org-entry-get nil "SENT") "yes"))
    (org-todo "TODO")
    (should (equal (org-entry-get nil "SENT") "no"))))

(provide 'rg-surf-desk-test)
;;; rg-surf-desk-test.el ends here
