;;; rg-tangle-test.el --- Tests for local tangle helper -*- lexical-binding: t; -*-

(require 'ert)
(require 'rg-tangle)

(defun rg-tangle-test--root ()
  "Return the repository root for these tests."
  (rg/tangle--repo-root))

(ert-deftest rg-tangle-private-dir-is-rooted ()
  (let ((root "/tmp/dotdoom-test"))
    (rg/tangle-setup root)
    (should (equal doom-private-dir "/tmp/dotdoom-test/"))))

(ert-deftest rg-tangle-coderef-allows-nil-format ()
  (rg/tangle-setup default-directory)
  (should (stringp (org-src-coderef-regexp nil))))

(ert-deftest rg-tangle-files-are-canonical ()
  (let ((root "/tmp/dotdoom-test"))
    (should
     (equal (rg/tangle-files root)
            '("/tmp/dotdoom-test/config.org"
              "/tmp/dotdoom-test/packages.org")))))

(ert-deftest rg-tangle-packages-org-tangles ()
  (let ((root (rg-tangle-test--root)))
    (rg/tangle-setup root)
    (should
     (member (expand-file-name "packages.el" root)
             (org-babel-tangle-file (expand-file-name "packages.org" root))))))

(ert-deftest rg-tangle-packages-links-stay-relative ()
  (let ((root (rg-tangle-test--root)))
    (rg/tangle-setup root)
    (org-babel-tangle-file (expand-file-name "packages.org" root))
    (with-temp-buffer
      (insert-file-contents (expand-file-name "packages.el" root))
      (should (re-search-forward "\\[\\[file:packages.org::" nil t))
      (should-not
       (re-search-forward (regexp-quote (expand-file-name "packages.org" root))
                          nil t)))))

(provide 'rg-tangle-test)
;;; rg-tangle-test.el ends here
