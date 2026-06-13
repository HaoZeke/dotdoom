;;; rg-bibtex-test.el --- Tests for local BibTeX helpers -*- lexical-binding: t; -*-

(require 'ert)
(require 'rg-bibtex)

(ert-deftest rg-bibtex-cache-path-defaults-to-xdg-cache ()
  (let ((process-environment '("XDG_CACHE_HOME=/tmp/rg-cache")))
    (should
     (equal (rg/bibtex-default-cache-file)
            "/tmp/rg-cache/doom/zotLib.bib"))))

(ert-deftest rg-bibtex-clean-cache-path-defaults-to-xdg-cache ()
  (let ((process-environment '("XDG_CACHE_HOME=/tmp/rg-cache")))
    (should
     (equal (rg/bibtex-default-clean-cache-file)
            "/tmp/rg-cache/doom/zotLib.clean.bib"))))

(ert-deftest rg-bibtex-cache-selection-prefers-readable-cache ()
  (let ((source "/tmp/rg-bibtex-source.bib")
        (cache "/tmp/rg-bibtex-cache.bib"))
    (with-temp-file source (insert "@article{source}\n"))
    (with-temp-file cache (insert "@article{cache}\n"))
    (let ((zot_bib_source source)
          (zot_bib_cache cache))
      (should (equal (rg/zot-bib-use-cache) cache)))))

(ert-deftest rg-bibtex-cache-selection-prefers-readable-clean-cache ()
  (let ((source "/tmp/rg-bibtex-source.bib")
        (cache "/tmp/rg-bibtex-cache.bib")
        (clean-cache "/tmp/rg-bibtex-clean-cache.bib"))
    (with-temp-file source (insert "@article{source}\n"))
    (with-temp-file cache (insert "@article{cache}\n"))
    (with-temp-file clean-cache (insert "@article{clean}\n"))
    (let ((zot_bib_source source)
          (zot_bib_cache cache)
          (zot_bib_clean_cache clean-cache))
      (should (equal (rg/zot-bib-use-cache) clean-cache)))))

(ert-deftest rg-bibtex-cache-selection-falls-back-to-source ()
  (let ((source "/tmp/rg-bibtex-source.bib")
        (cache "/tmp/rg-bibtex-missing.bib"))
    (with-temp-file source (insert "@article{source}\n"))
    (let ((zot_bib_source source)
          (zot_bib_cache cache))
      (should (equal (rg/zot-bib-use-cache) source)))))

(ert-deftest rg-bibtex-configure-paths-uses-environment ()
  (let ((process-environment
         '("RG_ORG_NOTES_DIR=/tmp/rg-notes"
           "RG_ZOT_BIB=/tmp/rg-zot.bib"
           "RG_ZOT_BIB_CACHE=/tmp/rg-zot-cache.bib"
           "RG_ZOT_BIB_CLEAN_CACHE=/tmp/rg-zot-clean-cache.bib")))
    (makunbound 'org_notes)
    (makunbound 'zot_bib_source)
    (makunbound 'zot_bib_cache)
    (makunbound 'zot_bib_clean_cache)
    (rg/bibtex-configure-paths)
    (should (equal org_notes "/tmp/rg-notes/"))
    (should (equal zot_bib_source "/tmp/rg-zot.bib"))
    (should (equal zot_bib_cache "/tmp/rg-zot-cache.bib"))
    (should (equal zot_bib_clean_cache "/tmp/rg-zot-clean-cache.bib"))))

(ert-deftest rg-bibtex-sanitize-removes-escaped-braces ()
  (with-temp-buffer
    (insert "@unpublished{sample,\n")
    (insert "  author = {Mahmoud\\}, Chiheb \\{Ben and Cs\\'anyi, G\\'abor}\n")
    (insert "}\n")
    (rg/bibtex-sanitize-buffer)
    (should
     (string-match-p
      "author = {Mahmoud, Chiheb Ben and Cs\\\\'anyi, G\\\\'abor}"
      (buffer-string)))))

(ert-deftest rg-bibtex-refresh-cache-writes-clean-cache ()
  (let ((source "/tmp/rg-bibtex-source-refresh.bib")
        (cache "/tmp/rg-bibtex-cache-refresh.bib")
        (clean-cache "/tmp/rg-bibtex-clean-cache-refresh.bib"))
    (with-temp-file source
      (insert "@unpublished{sample,\n")
      (insert "  author = {Mahmoud\\}, Chiheb \\{Ben and Anelli, Andrea}\n")
      (insert "}\n"))
    (ignore-errors (delete-file cache))
    (ignore-errors (delete-file clean-cache))
    (let ((zot_bib_source source)
          (zot_bib_cache cache)
          (zot_bib_clean_cache clean-cache))
      (should (equal (rg/zot-bib-refresh-cache) clean-cache))
      (should (file-readable-p cache))
      (should (file-readable-p clean-cache))
      (with-temp-buffer
        (insert-file-contents clean-cache)
        (should
         (string-match-p
          "author = {Mahmoud, Chiheb Ben and Anelli, Andrea}"
          (buffer-string)))))))

(provide 'rg-bibtex-test)
;;; rg-bibtex-test.el ends here
