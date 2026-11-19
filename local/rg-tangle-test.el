;;; rg-tangle-test.el --- Tests for local tangle helper -*- lexical-binding: t; -*-

(require 'ert)
(require 'rg-tangle)

(defun rg-tangle-test--root ()
  "Return the repository root for these tests."
  (rg/tangle--repo-root))

(defun rg-tangle-test--with-temp-root (fn)
  "Call FN with a temp copy of packages.org as the tangle root."
  (let* ((src (rg-tangle-test--root))
         (tmpdir (file-name-as-directory (make-temp-file "rg-tangle-" t))))
    (unwind-protect
        (progn
          (copy-file (expand-file-name "packages.org" src)
                     (expand-file-name "packages.org" tmpdir))
          (rg/tangle-setup tmpdir)
          (funcall fn tmpdir))
      (delete-directory tmpdir t))))

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
  (rg-tangle-test--with-temp-root
   (lambda (root)
     (should
      (member (expand-file-name "packages.el" root)
              (org-babel-tangle-file (expand-file-name "packages.org" root)))))))

(ert-deftest rg-tangle-packages-links-stay-relative ()
  (rg-tangle-test--with-temp-root
   (lambda (root)
     (org-babel-tangle-file (expand-file-name "packages.org" root))
     (with-temp-buffer
       (insert-file-contents (expand-file-name "packages.el" root))
       (should (re-search-forward "\\[\\[file:packages.org::" nil t))
       (should-not
        (re-search-forward (regexp-quote (expand-file-name "packages.org" root))
                           nil t))))))

(provide 'rg-tangle-test)
;;; rg-tangle-test.el ends here
