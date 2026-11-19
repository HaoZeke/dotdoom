;;; rg-trace-feedback-test.el --- Public loader tests -*- lexical-binding: t; -*-

(require 'ert)
(require 'rg-trace-feedback)

(ert-deftest rg-trace-feedback-loader-resolves-sibling-private-file ()
  (let* ((library (or (locate-library "rg-trace-feedback")
                      (ert-fail "rg-trace-feedback is not on load-path")))
         (sibling (expand-file-name
                   "private/rg-trace-feedback.el"
                   (file-name-directory library))))
    (should (equal (expand-file-name rg/trace-feedback-private-implementation-file)
                   (expand-file-name sibling)))
    (when (file-readable-p sibling)
      (should (fboundp 'rg/trace-feedback-create)))))

(provide 'rg-trace-feedback-test)
;;; rg-trace-feedback-test.el ends here
