;;; autoExport.el --- For async exports -*- lexical-binding: t; -*-

(require 'package)
(setq package-enable-at-startup nil)
(package-initialize)

(defvar rg/async-emacs-dir
  (file-name-as-directory (expand-file-name "~/.config/emacs/"))
  "Emacs configuration directory for async Org export workers.")

(defvar rg/async-straight-dir
  (expand-file-name ".local/straight/" rg/async-emacs-dir)
  "Straight package root for async Org export workers.")

(defvar rg/async-straight-repos-dir
  (expand-file-name "repos/" rg/async-straight-dir)
  "Straight repository root for async Org export workers.")

(defvar rg/async-straight-build-dir
  (file-name-as-directory
   (or (car (file-expand-wildcards
             (expand-file-name
              (format "build-%d.%d" emacs-major-version emacs-minor-version)
              rg/async-straight-dir)))
       (car (last (sort (file-expand-wildcards
                         (expand-file-name "build-*" rg/async-straight-dir))
                        #'string<)))
       (expand-file-name "build/" rg/async-straight-dir)))
  "Straight build directory for async Org export workers.")

(defun rg/async-add-load-path (path)
  "Add PATH to `load-path' when it exists."
  (when (file-directory-p path)
    (add-to-list 'load-path (file-name-as-directory path))))

(defun rg/async-add-straight-package (package &optional repo)
  "Add Straight PACKAGE and optional REPO directories to `load-path'."
  (rg/async-add-load-path (expand-file-name package rg/async-straight-build-dir))
  (rg/async-add-load-path
   (expand-file-name (or repo package) rg/async-straight-repos-dir)))

(rg/async-add-straight-package "org" "org-mode")
(require 'org)
(require 'ox)
(require 'ox-koma-letter)
(require 'ox-beamer)

;; Org-Ref Stuff
(dolist (package '("org-ref" "dash" "s" "f" "hydra" "avy" "request"
                   "queue" "aio" "citeproc" "parsebib"
                   "biblio" "async" "htmlize" "pdf-tools"
                   "bibtex-completion"))
  (rg/async-add-straight-package package))
(rg/async-add-straight-package "dash" "dash.el")
(rg/async-add-straight-package "s" "s.el")
(rg/async-add-straight-package "f" "f.el")
(rg/async-add-straight-package "biblio" "biblio.el")
(rg/async-add-straight-package "request" "emacs-request")
(rg/async-add-straight-package "aio" "emacs-aio")
(rg/async-add-straight-package "htmlize" "emacs-htmlize")
(rg/async-add-straight-package "bibtex-completion" "helm-bibtex")
(require 'org-ref)

(load (expand-file-name
       "rg-compat.el"
       (file-name-directory (or load-file-name buffer-file-name)))
      nil t)

;; Path addtion
(let ((texlive-path
       (cond
        ((eq system-type 'gnu/linux)
         (concat (getenv "HOME") "/.local/share/texlive-20230827/bin/x86_64-linux"))
        ((eq system-type 'darwin)
         (concat (getenv "HOME") "/usr/local/texlive/2021/bin/universal-darwin")))))
  (when texlive-path
    (add-to-list 'exec-path texlive-path)
    (setenv "PATH" (concat (getenv "PATH") ":" texlive-path))
    ))

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
  ;; Compiler -- tectonic handles bibtex, package downloads, and multiple passes
  (setq org-latex-pdf-process (list "tectonic -X compile --synctex --keep-logs %f"))
  ;; engrave-faces replaces minted for code highlighting
  (setq org-latex-src-block-backend 'engraved)
  (setq org-latex-engraved-theme t) ;; use current Emacs theme
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
