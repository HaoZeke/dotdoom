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

(ert-deftest rg-trawl-ridley-library-defaults-to-personal-redb ()
  (should (file-equal-p
           rg/trawl-ridley-library
           (expand-file-name "~/.local/share/Ridley/libraries/personal.redb")))
  (should (file-exists-p rg/trawl-ridley-library)))

(ert-deftest rg-trawl-ridley-json-files-omit-fixtures ()
  (dolist (f (rg/trawl-ridley-json-files))
    (should-not (string-match-p "sample-library" f))
    (should-not (string-match-p "seed\\.json\\'" f))))

(ert-deftest rg-trawl-ridley-json-includes-readable-json ()
  (let* ((tmp (make-temp-file "rg-trawl-live" nil ".json"))
         (rg/trawl-ridley-library tmp))
    (unwind-protect
        (should (equal (rg/trawl-ridley-json-files) (list tmp)))
      (delete-file tmp))))

(provide 'rg-trawl-test)
;;; rg-trawl-test.el ends here
