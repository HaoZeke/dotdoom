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
          '("--stdin-filepath" "/tmp/example.org" "--native" "--format" "org"))))

(ert-deftest rg-snapper-file-args ()
  (should
   (equal (rg/snapper-file-args "/tmp/example.org" :check t :diff t)
          '("--native" "--format" "org" "--check" "--diff" "/tmp/example.org"))))

(ert-deftest rg-snapper-git-diff-args ()
  (should
   (equal (rg/snapper-git-diff-args "HEAD~1" '("/tmp/example.org"))
          '("git-diff" "--no-color" "HEAD~1" "/tmp/example.org"))))

(ert-deftest rg-snapper-failed-process-keeps-the-region ()
  (with-temp-buffer
    (setq buffer-file-name "/tmp/snapper-failure.org")
    (insert "Prefix.\nDo not lose this region.\nSuffix.\n")
    (let ((before (buffer-string)))
      (cl-letf (((symbol-function 'rg/snapper--program) (lambda () "/usr/bin/false")))
        (should-error (rg/snapper-format-region 9 33) :type 'user-error))
      (should (equal (buffer-string) before)))))

(ert-deftest rg-snapper-failure-reports-stderr-without-inserting-it ()
  (with-temp-buffer
    (setq buffer-file-name "/tmp/snapper-failure.org")
    (insert "Keep the original text.\n")
    (let ((before (buffer-string)))
      (cl-letf (((symbol-function 'rg/snapper--program) (lambda () "/bin/sh"))
                ((symbol-function 'rg/snapper-region-args)
                 (lambda (&optional _) '("-c" "printf 'formatter refused' >&2; exit 1"))))
        (let ((error-data (should-error (rg/snapper-format-buffer) :type 'user-error)))
          (should (string-match-p "formatter refused" (error-message-string error-data)))))
      (should (equal (buffer-string) before)))))

(ert-deftest rg-snapper-native-keeps-protected-text-and-comments ()
  (with-temp-buffer
    (setq buffer-file-name "/tmp/snapper-protected.org")
    (insert "First sentence. Second sentence.\n\n# snapper:off\nKeep  two spaces. Same line.\n# snapper:on\n\nLast sentence. Final sentence.\n")
    (rg/snapper-format-buffer)
    (should (string-match-p (regexp-quote "First sentence.\nSecond sentence.") (buffer-string)))
    (should (string-match-p (regexp-quote "# snapper:off\nKeep  two spaces. Same line.\n# snapper:on") (buffer-string)))
    (should (string-match-p (regexp-quote "Last sentence.\nFinal sentence.") (buffer-string)))
    (let ((once (buffer-string)))
      (rg/snapper-format-buffer)
      (should (equal (buffer-string) once)))))

(ert-deftest rg-snapper-success-changes-only-selected-text ()
  (with-temp-buffer
    (setq buffer-file-name "/tmp/snapper-region.org")
    (insert "Prefix.\nFirst sentence. Second sentence.\nSuffix.\n")
    (let ((start (progn (goto-char (point-min)) (forward-line 1) (point)))
          (end (progn (forward-line 1) (point))))
      (rg/snapper-format-region start end))
    (should (equal (buffer-string) "Prefix.\nFirst sentence.\nSecond sentence.\nSuffix.\n"))))

(provide 'rg-snapper-test)
;;; rg-snapper-test.el ends here
