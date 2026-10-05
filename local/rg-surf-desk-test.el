;;; rg-surf-desk-test.el --- Load the private desk tests when unsealed -*- lexical-binding: t; -*-

(require 'ert)
(require 'rg-surf-desk)

(let* ((dir (file-name-directory (or load-file-name (buffer-file-name))))
       (tests (expand-file-name "private/rg-surf-desk-test.el" dir)))
  (if (and (fboundp 'rg-surf-desk-copy-src) (file-readable-p tests))
      (load tests nil 'nomessage)
    (ert-deftest rg-surf-desk-stays-quiet-while-sealed ()
      (should-not (fboundp 'rg-surf-desk-copy-src)))))

(provide 'rg-surf-desk-test)
;;; rg-surf-desk-test.el ends here
