;;; autoExport.el --- For async exports -*- lexical-binding: t; -*-

(require 'package)
(setq package-enable-at-startup nil)
(package-initialize)

(require 'org)
(require 'ox)
(add-to-list 'load-path "~/.emacs.d/.local/straight/repos/org-mode/contrib/lisp/")
(require 'ox-koma-letter)
(require 'ox-beamer)

;; Org-Ref Stuff
(add-to-list 'load-path "~/.emacs.d/.local/straight/repos/org-ref/")
(add-to-list 'load-path "~/.emacs.d/.local/straight/repos/dash.el/")
(add-to-list 'load-path "~/.emacs.d/.local/straight/repos/helm.el/")
(add-to-list 'load-path "~/.emacs.d/.local/straight/repos/helm/")
(add-to-list 'load-path "~/.emacs.d/.local/straight/build/helm/")
(add-to-list 'load-path "~/.emacs.d/.local/straight/repos/helm-bibtex/")
(add-to-list 'load-path "~/.emacs.d/.local/straight/repos/ivy/")
(add-to-list 'load-path "~/.emacs.d/.local/straight/repos/hydra/")
(add-to-list 'load-path "~/.emacs.d/.local/straight/repos/key-chord/")
(add-to-list 'load-path "~/.emacs.d/.local/straight/repos/s.el/")
(add-to-list 'load-path "~/.emacs.d/.local/straight/repos/f.el/")
(add-to-list 'load-path "~/.emacs.d/.local/straight/repos/pdf-tools/")
(add-to-list 'load-path "~/.emacs.d/.local/straight/repos/emacs-htmlize/")
(add-to-list 'load-path "~/.emacs.d/.local/straight/repos/parsebib/")
(add-to-list 'load-path "~/.emacs.d/.local/straight/build/async/")
(add-to-list 'load-path "~/.emacs.d/.local/straight/repos/biblio.el/")
(require 'org-ref)

;; Path addtion
(cond ((featurep :system 'linux)
       (setenv "PATH" (concat (getenv "PATH") ":" (concat (getenv "HOME") "/.local/share/texlive-20230827/bin/x86_64-linux")))
       (setq exec-path (append exec-path (list (concat (getenv "HOME") "/.local/share/texlive-20230827/bin/x86_64-linux"))))
      )
      ((featurep :system 'macos)
       (setenv "PATH" (concat (getenv "PATH") ":" (concat (getenv "HOME") "/usr/local/texlive/2021/bin/universal-darwin")))
       (setq exec-path (append exec-path (list (concat (getenv "HOME") "/usr/local/texlive/2021/bin/universal-darwin"))))
      )
)

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
  (setq org-latex-pdf-process (list "latexmk -shell-escape -f -pdfxe %f"))
  ;; Configuration
  (add-to-list 'org-latex-packages-alist '("" "minted" "xcolor"))
  (setq org-latex-listings 'minted)
  (setq org-latex-minted-options
    '(("bgcolor" "white") ("breaklines" "true") ("linenos" "true") ("style" "tango")))
  (append-to-list
   'org-latex-classes
   '(("tufte-book"
      "\\documentclass[a4paper, sfsidenotes, openany, justified]{tufte-book}"
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
  (add-to-list 'org-latex-classes
               '("koma-report" "\\documentclass{scrreprt}"))
)
(provide 'autoExport)
;;; autoExport.el ends here
