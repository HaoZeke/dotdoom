;;; rg-org-capture-test.el --- Tests for local Org capture templates -*- lexical-binding: t; -*-

(require 'ert)
(require 'rg-org-capture)

(ert-deftest rg-org-capture-transform-square-brackets ()
  (should (equal (rg/org-capture-transform-square-brackets "[paper] title")
                 "(paper) title")))

(ert-deftest rg-org-capture-templates-have-expected-keys ()
  (should (equal (mapcar #'car (rg/org-capture-templates))
                 '("P" "L" "a"))))

(ert-deftest rg-org-capture-install-is-idempotent ()
  (let ((org-capture-templates nil))
    (rg/org-capture-install)
    (rg/org-capture-install)
    (should (equal (mapcar #'car org-capture-templates)
                   '("P" "L" "a")))))

(ert-deftest rg-org-capture-html-install-replaces-existing-key ()
  (let ((org-capture-templates '(("w" "old"))))
    (rg/org-capture-install-html)
    (should (= (length org-capture-templates) 1))
    (should (equal (cadar org-capture-templates) "Web site"))))

(provide 'rg-org-capture-test)
;;; rg-org-capture-test.el ends here
