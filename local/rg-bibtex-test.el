;;; rg-bibtex-test.el --- Tests for local BibTeX helpers -*- lexical-binding: t; -*-

(require 'ert)
(require 'rg-bibtex)

(ert-deftest rg-bibtex-cache-path-defaults-to-xdg-cache ()
  (let ((process-environment '("XDG_CACHE_HOME=/tmp/rg-cache")))
    (should
     (equal (rg/bibtex-default-cache-file)
            "/tmp/rg-cache/doom/zotLib.bib"))))

(ert-deftest rg-bibtex-cache-selection-prefers-readable-cache ()
  (let ((source "/tmp/rg-bibtex-source.bib")
        (cache "/tmp/rg-bibtex-cache.bib"))
    (with-temp-file source (insert "@article{source}\n"))
    (with-temp-file cache (insert "@article{cache}\n"))
    (let ((zot_bib_source source)
          (zot_bib_cache cache))
      (should (equal (rg/zot-bib-use-cache) cache)))))

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
           "RG_ZOT_BIB_CACHE=/tmp/rg-zot-cache.bib")))
    (makunbound 'org_notes)
    (makunbound 'zot_bib_source)
    (makunbound 'zot_bib_cache)
    (rg/bibtex-configure-paths)
    (should (equal org_notes "/tmp/rg-notes/"))
    (should (equal zot_bib_source "/tmp/rg-zot.bib"))
    (should (equal zot_bib_cache "/tmp/rg-zot-cache.bib"))))

(provide 'rg-bibtex-test)
;;; rg-bibtex-test.el ends here
