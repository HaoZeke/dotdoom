;;; autoExport.el --- For async exports -*- lexical-binding: t; -*-

(require 'package)
(setq package-enable-at-startup nil)
(package-initialize)

(require 'org)
(require 'ox)
(require 'cl)

;; Feature parity with doom
(with-eval-after-load 'ox-latex
  ;; Compiler
  (setq org-latex-pdf-process (list "latexmk -shell-escape -bibtex -f -pdfxe %f"))
  ;; Configuration
  (add-to-list 'org-latex-packages-alist '("" "minted" "xcolor"))
  (setq org-latex-listings 'minted)
  (setq org-latex-minted-options
    '(("bgcolor" "black") ("linenos" "true") ("style" "native")))
  (append-to-list
   'org-latex-classes
   '(("tufte-book"
      "\\documentclass[a4paper, sfsidenotes, openany, justified]{tufte-book}
      \\input{/home/haozeke/Git/tufte-book.tex}"
      ("\\part{%s}" . "\\part*{%s}")
      ("\\chapter{%s}" . "\\chapter*{%s}")
      ("\\section{%s}" . "\\section*{%s}")
      ("utf8" . "utf8x")
      ("\\subsection{%s}" . "\\subsection*{%s}"))))
  (add-to-list 'org-latex-classes
               '("koma-article" "\\documentclass{scrartcl}"
                 ("\\section{%s}" . "\\section*{%s}")
                 ("\\subsection{%s}" . "\\subsection*{%s}")
                 ("\\subsubsection{%s}" . "\\subsubsection*{%s}")
                 ("\\paragraph{%s}" . "\\paragraph*{%s}")
                 ("\\subparagraph{%s}" . "\\subparagraph*{%s}")))
)
(provide 'autoExport)
;;; autoExport.el ends here
