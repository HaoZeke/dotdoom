;;; autoExport.el --- For async exports -*- lexical-binding: t; -*-

(require 'package)
(setq package-enable-at-startup nil)
(package-initialize)

(require 'org)
(require 'ox)
(require 'cl)
(setq org-export-async-debug nil)

; For KOMAscript stuff
(with-eval-after-load "ox-latex"
  (add-to-list 'org-latex-classes
               '("koma-article" "\\documentclass{scrartcl}"
                 ("\\section{%s}" . "\\section*{%s}")
                 ("\\subsection{%s}" . "\\subsection*{%s}")
                 ("\\subsubsection{%s}" . "\\subsubsection*{%s}")
                 ("\\paragraph{%s}" . "\\paragraph*{%s}")
                 ("\\subparagraph{%s}" . "\\subparagraph*{%s}")))
  (add-to-list 'org-latex-packages-alist '("" "minted"))
  (setq org-latex-listings 'minted)
  )

(setq org-latex-pdf-process (list "latexmk -shell-escape -bibtex -f -pdfxe %f"))
(provide 'autoExport)
;;; autoExport.el ends here
