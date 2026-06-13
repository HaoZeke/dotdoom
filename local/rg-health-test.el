;;; rg-health-test.el --- Tests for local Doom health checks -*- lexical-binding: t; -*-

(require 'cl-lib)
(require 'ert)
(require 'rg-health)

(ert-deftest rg-health-item-status ()
  (should (eq (plist-get (rg/health-item "test" t "ok") :status) 'ok))
  (should (eq (plist-get (rg/health-item "test" nil "bad") :status) 'warn)))

(ert-deftest rg-health-executable-check ()
  (cl-letf (((symbol-function 'executable-find)
             (lambda (program)
               (and (equal program "vale") "/usr/bin/vale"))))
    (let ((item (rg/health-executable "Vale" "vale")))
      (should (eq (plist-get item :status) 'ok))
      (should (string-match-p "/usr/bin/vale" (plist-get item :detail))))))

(ert-deftest rg-health-bibtex-check-prefers-cache ()
  (let ((source "/tmp/rg-health-source.bib")
        (cache "/tmp/rg-health-cache.bib"))
    (with-temp-file source (insert "@article{source}\n"))
    (with-temp-file cache (insert "@article{cache}\n"))
    (let ((zot_bib_source source)
          (zot_bib_cache cache))
      (let ((item (rg/health-bibtex-cache)))
        (should (eq (plist-get item :status) 'ok))
        (should (string-match-p "cache readable" (plist-get item :detail)))))))

(ert-deftest rg-health-report-renders-items ()
  (let ((report (rg/health-render
                 (list (rg/health-item "One" t "ready")
                       (rg/health-item "Two" nil "missing")))))
    (should (string-match-p "OK[[:space:]]+One[[:space:]]+ready" report))
    (should (string-match-p "WARN[[:space:]]+Two[[:space:]]+missing" report))))

(provide 'rg-health-test)
;;; rg-health-test.el ends here
