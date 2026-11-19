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

(ert-deftest rg-health-bibtex-check-repairs-raw-cache-only ()
  (let ((source "/tmp/rg-health-source.bib")
        (cache "/tmp/rg-health-cache.bib")
        (clean-cache "/tmp/rg-health-missing-clean-cache.bib"))
    (with-temp-file source (insert "@article{source}\n"))
    (with-temp-file cache (insert "@article{cache}\n"))
    (ignore-errors (delete-file clean-cache))
    (let ((zot_bib_source source)
          (zot_bib_cache cache)
          (zot_bib_clean_cache clean-cache))
      (cl-letf (((symbol-function 'rg/health-bibtex-parse-cache)
                 (lambda (_file) nil)))
        (let ((item (rg/health-bibtex-cache)))
          (should (eq (plist-get item :status) 'ok))
          (should (file-readable-p clean-cache))
          (should (string-match-p "clean cache readable"
                                  (plist-get item :detail))))))))

(ert-deftest rg-health-bibtex-check-prefers-clean-cache ()
  (let ((source "/tmp/rg-health-source.bib")
        (cache "/tmp/rg-health-cache.bib")
        (clean-cache "/tmp/rg-health-clean-cache.bib"))
    (with-temp-file source (insert "@article{source}\n"))
    (with-temp-file cache (insert "@article{cache}\n"))
    (with-temp-file clean-cache (insert "@article{clean}\n"))
    (let ((zot_bib_source source)
          (zot_bib_cache cache)
          (zot_bib_clean_cache clean-cache))
      (cl-letf (((symbol-function 'rg/health-bibtex-parse-cache)
                 (lambda (_file) nil)))
        (let ((item (rg/health-bibtex-cache)))
          (should (eq (plist-get item :status) 'ok))
          (should (string-match-p "clean cache readable"
                                  (plist-get item :detail))))))))

(ert-deftest rg-health-bibtex-check-warns-on-unparseable-clean-cache ()
  (let ((source "/tmp/rg-health-parse-source.bib")
        (cache "/tmp/rg-health-parse-cache.bib")
        (clean-cache "/tmp/rg-health-parse-clean-cache.bib"))
    (with-temp-file source (insert "@article{source}\n"))
    (with-temp-file cache (insert "@article{cache}\n"))
    (with-temp-file clean-cache (insert "@article{broken,\n  author = bad\\value\n}\n"))
    (let ((zot_bib_source source)
          (zot_bib_cache cache)
          (zot_bib_clean_cache clean-cache))
      (cl-letf (((symbol-function 'rg/health-bibtex-parse-cache)
                 (lambda (_file) "Invalid character `\\'")))
        (let ((item (rg/health-bibtex-cache)))
          (should (eq (plist-get item :status) 'warn))
          (should (string-match-p "parse failed"
                                  (plist-get item :detail))))))))

(ert-deftest rg-health-report-renders-items ()
  (let ((report (rg/health-render
                 (list (rg/health-item "One" t "ready")
                       (rg/health-item "Two" nil "missing")))))
    (should (string-match-p "OK[[:space:]]+One[[:space:]]+ready" report))
    (should (string-match-p "WARN[[:space:]]+Two[[:space:]]+missing" report))))

(ert-deftest rg-health-colemak-warns-when-unloaded ()
  (cl-letf (((symbol-function 'featurep)
             (lambda (feature) (not (eq feature 'evil-colemak-basics)))))
    (let ((item (rg/health-colemak)))
      (should (eq (plist-get item :status) 'warn))
      (should (string-match-p "not loaded" (plist-get item :detail))))))

(ert-deftest rg-health-colemak-ok-when-global-mode-on ()
  (cl-letf (((symbol-function 'featurep)
             (lambda (feature) (eq feature 'evil-colemak-basics)))
            ((symbol-function 'key-binding)
             (lambda (_key &rest _) 'evil-scroll-page-up)))
    (defvar global-evil-colemak-basics-mode)
    (let ((global-evil-colemak-basics-mode t))
      (let ((item (rg/health-colemak)))
        (should (eq (plist-get item :status) 'ok))
        (should (string-match-p "global-evil-colemak-basics-mode on"
                                (plist-get item :detail)))))))

(ert-deftest rg-health-bibtex-parse-cache-reports-missing-parsebib ()
  (cl-letf (((symbol-function 'require)
             (let ((orig (symbol-function 'require)))
               (lambda (feature &optional filename noerror)
                 (if (eq feature 'parsebib)
                     nil
                   (funcall orig feature filename noerror))))))
    (let ((detail (rg/health-bibtex-parse-cache "/tmp/unused.bib")))
      (should (stringp detail))
      (should (string-match-p "parsebib" detail)))))

(ert-deftest rg-health-bibtex-check-warns-when-parsebib-missing ()
  (let ((source "/tmp/rg-health-parsebib-source.bib")
        (cache "/tmp/rg-health-parsebib-cache.bib")
        (clean-cache "/tmp/rg-health-parsebib-clean-cache.bib"))
    (with-temp-file source (insert "@article{source}\n"))
    (with-temp-file cache (insert "@article{cache}\n"))
    (with-temp-file clean-cache (insert "@article{clean}\n"))
    (let ((zot_bib_source source)
          (zot_bib_cache cache)
          (zot_bib_clean_cache clean-cache))
      (cl-letf (((symbol-function 'rg/health-bibtex-parse-cache)
                 (lambda (_file) "parsebib is not available")))
        (let ((item (rg/health-bibtex-cache)))
          (should (eq (plist-get item :status) 'warn))
          (should (string-match-p "parsebib" (plist-get item :detail))))))))

(defconst rg-health-test-expected-modules
  '("module rg-bibtex"
    "module rg-cite-notes"
    "module rg-trawl"
    "module rg-doom-runtime"
    "module rg-org-capture"
    "module rg-trace-feedback"
    "module rg-compat"
    "module rg-prose"
    "module rg-snapper"
    "module rg-vale"
    "module rg-org-visual")
  "config.el load! helpers that rg/health-local-modules must gate.")

(ert-deftest rg-health-local-modules-covers-loaded-helpers ()
  (let ((names (mapcar (lambda (item) (plist-get item :name))
                       (rg/health-local-modules))))
    (should (equal names rg-health-test-expected-modules))))

(ert-deftest rg-health-items-include-desk-executables-and-modules ()
  (cl-letf (((symbol-function 'rg/health-bibtex-cache)
             (lambda () (rg/health-item "BibTeX cache" t "mocked"))))
    (let ((names (mapcar (lambda (item) (plist-get item :name))
                         (rg/doom-health-items))))
      (dolist (name (append '("Vale" "Snapper" "Trawl")
                            rg-health-test-expected-modules))
        (should (member name names))))))

(ert-deftest rg-health-colemak-warns-when-E-is-lookup ()
  (cl-letf (((symbol-function 'featurep)
             (lambda (feature) (eq feature 'evil-colemak-basics)))
            ((symbol-function 'key-binding)
             (lambda (_key &rest _) 'evil-lookup)))
    (defvar global-evil-colemak-basics-mode)
    (let ((global-evil-colemak-basics-mode t))
      (let ((item (rg/health-colemak)))
        (should (eq (plist-get item :status) 'warn))
        (should (string-match-p "evil-lookup" (plist-get item :detail)))))))

(provide 'rg-health-test)
;;; rg-health-test.el ends here
