;;; autoExport.el --- For async exports -*- lexical-binding: t; -*-

(require 'package)
(setq package-enable-at-startup nil)
(package-initialize)

(require 'org)
(require 'ox)
(add-to-list 'load-path "~/.emacs.d/.local/straight/repos/org-mode/contrib/lisp/")
(require 'ox-koma-letter)
(require 'cl)

;; Functions
;; this function is used to append multiple elements to the list 'ox-latex
(defun append-to-list (list-var elements)
  "Append ELEMENTS to the end of LIST-VAR. The return value is the new value of LIST-VAR."
  (unless (consp elements) (error "ELEMENTS must be a list"))
  (let ((list (symbol-value list-var)))
    (if list
        (setcdr (last list) elements)
      (set list-var elements)))
(symbol-value list-var))
;; Feature parity with doom
(eval-after-load 'ox '(require 'ox-koma-letter))
(with-eval-after-load 'ox-latex
  ;; Compiler
  (setq org-latex-pdf-process (list "latexmk -shell-escape -bibtex -f -pdfxe %f"))
  ;; Configuration
  (add-to-list 'org-latex-packages-alist '("" "minted" "xcolor"))
  (setq org-latex-listings 'minted)
  (setq org-latex-minted-options
    '(("bgcolor" "lightgray") ("linenos" "true") ("style" "tango")))
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
