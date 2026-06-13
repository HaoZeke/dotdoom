;;; rg-snapper-test.el --- Tests for Snapper integration -*- lexical-binding: t; -*-

(require 'ert)
(require 'rg-snapper)

(ert-deftest rg-snapper-format-for-file ()
  (should (equal (rg/snapper-format-for-file "/tmp/example.org") "org"))
  (should (equal (rg/snapper-format-for-file "/tmp/example.tex") "latex"))
  (should (equal (rg/snapper-format-for-file "/tmp/example.md") "markdown"))
  (should (equal (rg/snapper-format-for-file "/tmp/example.rst") "rst"))
  (should (equal (rg/snapper-format-for-file "/tmp/example.txt") "plaintext")))

(ert-deftest rg-snapper-format-for-mode ()
  (with-temp-buffer
    (org-mode)
    (should (equal (rg/snapper-format-for-buffer) "org"))))

(ert-deftest rg-snapper-region-args ()
  (should
   (equal (rg/snapper-region-args "/tmp/example.org")
          '("--stdin-filepath" "/tmp/example.org" "--format" "org"))))

(ert-deftest rg-snapper-file-args ()
  (should
   (equal (rg/snapper-file-args "/tmp/example.org" :check t :diff t)
          '("--format" "org" "--check" "--diff" "/tmp/example.org"))))

(ert-deftest rg-snapper-git-diff-args ()
  (should
   (equal (rg/snapper-git-diff-args "HEAD~1" '("/tmp/example.org"))
          '("git-diff" "--no-color" "HEAD~1" "/tmp/example.org"))))

(provide 'rg-snapper-test)
;;; rg-snapper-test.el ends here
