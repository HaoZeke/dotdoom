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

(ert-deftest rg-surf-desk-lint-script-finds-the-repo-copy ()
  (let* ((root (make-temp-file "desk-lint" t))
         (script (expand-file-name "Software/SURF/advisor/desk-lint.py" root))
         (note (expand-file-name "Software/SURF/support_desk/sd/example/overview.org" root)))
    (make-directory (file-name-directory script) t)
    (make-directory (file-name-directory note) t)
    (write-region "" nil script)
    (write-region "" nil note)
    (unwind-protect
        (should (equal (rg-surf-desk-lint-script note) script))
      (delete-directory root t))))

(ert-deftest rg-surf-desk-copy-src-takes-the-block ()
  (with-temp-buffer
    (org-mode)
    (insert "* Public\n:PROPERTIES:\n:SENT: no\n:END:\n#+begin_src text\nHi.\n\n10 SBU.\n#+end_src\n")
    (goto-char (point-min))
    (let ((text (rg-surf-desk-entry-src)))
      (should (string-match-p "10 SBU" text)))))

(provide 'rg-surf-desk-test)
;;; rg-surf-desk-test.el ends here
