;;; rg-trawl-test.el --- Tests for the trawl Emacs desk -*- lexical-binding: t; -*-

(require 'ert)
(require 'rg-trawl)

(ert-deftest rg-trawl-parse-find-line-extracts-doi-and-title ()
  (let ((hit (rg/trawl-parse-find-line
              "1. Localized Atomic and Molecular Orbitals (1963) RMP  doi:10.1103/revmodphys.35.457")))
    (should (equal (car hit) "10.1103/revmodphys.35.457"))
    (should (string-search "Localized Atomic" (cdr hit)))))

(ert-deftest rg-trawl-parse-find-line-rejects-noise ()
  (should (null (rg/trawl-parse-find-line "cap 8 — not a harvest"))))

(ert-deftest rg-trawl-ridley-json-prefers-live-when-present ()
  (let ((rg/trawl-ridley-library
         (expand-file-name "~/.local/share/Ridley/sample-library/library.json")))
    (should (string-suffix-p "library.json"
                             (or (car (rg/trawl-ridley-json-files)) "")))))

(provide 'rg-trawl-test)
;;; rg-trawl-test.el ends here
