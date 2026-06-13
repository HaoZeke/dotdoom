;;; rg-cite-notes-test.el --- Tests for citation note templates -*- lexical-binding: t; -*-

(require 'ert)
(require 'rg-cite-notes)

(defvar ookcite-ridley-org-noter-properties)

(ert-deftest rg-cite-notes-org-ref-template-has-org-noter-properties ()
  (let ((template (rg/cite-notes-org-ref-title-format)))
    (should (string-search ":Custom_ID: %k" template))
    (should (string-search ":ROAM_KEY: cite:%k" template))
    (should (string-search ":NOTER_DOCUMENT: %F" template))
    (should (string-search ":DOI: %D" template))))

(ert-deftest rg-cite-notes-bibtex-template-processes-file-field ()
  (let ((template (rg/cite-notes-bibtex-completion-template)))
    (should (string-search ":Custom_ID: ${=key=}" template))
    (should (string-search ":ROAM_KEY: cite:${=key=}" template))
    (should (string-search
             ":NOTER_DOCUMENT: %(orb-process-file-field \"${=key=}\")"
             template))))

(ert-deftest rg-cite-notes-orb-head-processes-file-field ()
  (let ((head (rg/cite-notes-orb-head)))
    (should (string-search "#+ROAM_KEY: ${ref}" head))
    (should (string-search ":Custom_ID: ${=key=}" head))
    (should (string-search
             ":NOTER_DOCUMENT: %(orb-process-file-field \"${=key=}\")"
             head))))

(ert-deftest rg-cite-notes-authors-string-preserves-bibtex-string ()
  (let ((item '((author . "Turing, Alan and Lovelace, Ada"))))
    (should (equal (rg/cite-notes-authors-string item)
                   "Turing, Alan and Lovelace, Ada"))))

(ert-deftest rg-cite-notes-ookcite-note-uses-canonical-properties ()
  (let* ((ookcite-ridley-org-noter-properties
          '(("NOTER_NOTES_BEHAVIOR" . "(start scroll)")
            ("NOTER_NOTES_LOCATION" . "horizontal-split")))
         (item '((item_id . "01ABC")
                 (title . "Readable Paper")
                 (author . "Turing, Alan and Lovelace, Ada")
                 (year . "1950")
                 (doi . "10.5555/turing")
                 (journal . "Journal of Tests")
                 (url . "https://example.test/paper")))
         (note (rg/cite-notes-ookcite-note-text
                item "/tmp/readable.pdf" "turing1950")))
    (should (string-search "* TODO Readable Paper :reading:ridley:" note))
    (should (string-search ":Custom_ID: turing1950" note))
    (should (string-search ":ROAM_KEY: cite:turing1950" note))
    (should (string-search ":NOTER_DOCUMENT: /tmp/readable.pdf" note))
    (should (string-search ":NOTER_NOTES_LOCATION: horizontal-split" note))
    (should (string-search ":RIDLEY_ITEM_ID: 01ABC" note))
    (should (string-search ":AUTHOR: Turing, Alan and Lovelace, Ada" note))
    (should (string-search "cite:@turing1950" note))))

(provide 'rg-cite-notes-test)
;;; rg-cite-notes-test.el ends here
