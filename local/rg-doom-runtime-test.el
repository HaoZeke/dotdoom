;;; rg-doom-runtime-test.el --- Tests for Doom runtime helpers -*- lexical-binding: t; -*-

(require 'cl-lib)
(require 'ert)
(require 'rg-doom-runtime)

(ert-deftest rg-doom-runtime-add-existing-load-path-adds-directory ()
  (let ((dir (make-temp-file "rg-doom-runtime-" t))
        load-path)
    (unwind-protect
        (let ((registered (rg/add-existing-load-path dir)))
          (should (equal registered (file-name-as-directory dir)))
          (should (member (file-name-as-directory dir) load-path)))
      (delete-directory dir))))

(ert-deftest rg-doom-runtime-add-existing-load-path-ignores-missing-directory ()
  (let ((load-path nil))
    (should-not (rg/add-existing-load-path "/tmp/rg-doom-runtime-missing"))
    (should-not load-path)))

(ert-deftest rg-doom-runtime-julia-predicates-default-to-regular-repl ()
  (should (rg/julia-open-repl-command-predicate '+julia/open-repl nil))
  (should-not
   (rg/julia-open-snail-repl-command-predicate '+julia/open-snail-repl nil)))

(ert-deftest rg-doom-runtime-julia-predicates-respect-snail-flag ()
  (cl-letf (((symbol-function 'doom-module-get)
             (lambda (key prop)
               (and (equal key '(:lang . julia))
                    (eq prop :flags)
                    '(+snail))))
            ((symbol-function 'doom-module--has-flag-p)
             (lambda (flags wanted)
               (memq wanted flags))))
    (should-not (rg/julia-open-repl-command-predicate '+julia/open-repl nil))
    (should
     (rg/julia-open-snail-repl-command-predicate '+julia/open-snail-repl nil))))

(ert-deftest rg-doom-runtime-installs-julia-command-predicates ()
  (let ((old-repl (function-get '+julia/open-repl 'completion-predicate))
        (old-snail (function-get '+julia/open-snail-repl 'completion-predicate)))
    (unwind-protect
        (progn
          (rg/install-julia-command-predicates)
          (should (eq (function-get '+julia/open-repl 'completion-predicate)
                      #'rg/julia-open-repl-command-predicate))
          (should (eq (function-get '+julia/open-snail-repl 'completion-predicate)
                      #'rg/julia-open-snail-repl-command-predicate)))
      (function-put '+julia/open-repl 'completion-predicate old-repl)
      (function-put '+julia/open-snail-repl 'completion-predicate old-snail))))

(provide 'rg-doom-runtime-test)
;;; rg-doom-runtime-test.el ends here
