;;; rg-vale-test.el --- Tests for Vale integration -*- lexical-binding: t; -*-

(require 'ert)
(require 'rg-vale)

(ert-deftest rg-vale-command-args ()
  (let ((rg/vale-config-file "/tmp/.vale.ini"))
    (should
     (equal (rg/vale-command-args '("/tmp/a.org" "/tmp/b.md"))
            '("--config" "/tmp/.vale.ini"
              "--output" "line"
              "--no-wrap"
              "/tmp/a.org" "/tmp/b.md")))))

(ert-deftest rg-vale-command-args-with-glob ()
  (let ((rg/vale-config-file "/tmp/.vale.ini"))
    (should
     (equal (rg/vale-command-args '("/tmp/docs") :glob "*.{org,md,rst,tex}")
            '("--config" "/tmp/.vale.ini"
              "--output" "line"
              "--no-wrap"
              "--glob" "*.{org,md,rst,tex}"
              "/tmp/docs")))))

(ert-deftest rg-vale-sync-args ()
  (let ((rg/vale-config-file "/tmp/.vale.ini"))
    (should
     (equal (rg/vale-sync-args)
            '("--config" "/tmp/.vale.ini" "sync")))))

(provide 'rg-vale-test)
;;; rg-vale-test.el ends here
