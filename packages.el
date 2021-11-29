;; [[file:packages.org::*MacOS][MacOS:1]]
(cond (IS-MAC (package! exec-path-from-shell)
              ))
;; MacOS:1 ends here

;; [[file:packages.org::*Dired Icons][Dired Icons:1]]
(package! all-the-icons-dired)
;; Dired Icons:1 ends here

;; [[file:packages.org::*Wakatime][Wakatime:1]]
(package! wakatime-mode)
;; Wakatime:1 ends here

;; [[file:packages.org::*Evil Colemak][Evil Colemak:1]]
(package! evil-colemak-basics)
(package! evil-better-visual-line)
;; Evil Colemak:1 ends here

;; [[file:packages.org::*Firestarter][Firestarter:1]]
(package! firestarter)
;; Firestarter:1 ends here

;; [[file:packages.org::*Org Download][Org Download:1]]
(package! org-download
  :recipe (:host github
            :repo "abo-abo/org-download"))
;; Org Download:1 ends here

;; [[file:packages.org::*LATER Org Drill][LATER Org Drill:1]]
(package! org-drill
  :recipe (:host github
            :repo "hakanserce/org-drill"))
;; LATER Org Drill:1 ends here

;; [[file:packages.org::*Org Protocol Updates][Org Protocol Updates:1]]
(package! org-protocol-capture-html
  :recipe (:host github
           :repo "alphapapa/org-protocol-capture-html"))
;; Org Protocol Updates:1 ends here

;; [[file:packages.org::*Org Noter][Org Noter:1]]
(package! org-noter)
;; Org Noter:1 ends here

;; [[file:packages.org::*Org Ref][Org Ref:1]]
(package! org-ref)
;; Org Ref:1 ends here

;; [[file:packages.org::*Org Mind Map][Org Mind Map:1]]
(package! org-mind-map
  :recipe (:host github
            :repo "theodorewiles/org-mind-map"))
;; Org Mind Map:1 ends here

;; [[file:packages.org::*Org Rifle][Org Rifle:1]]
(package! helm-org-rifle)
;; Org Rifle:1 ends here

;; [[file:packages.org::*Org Async][Org Async:1]]
(package! org-babel-eval-in-repl)
;; Org Async:1 ends here

;; [[file:packages.org::*Anki Mode][Anki Mode:1]]
(package! anki-editor)
;; Anki Mode:1 ends here

;; [[file:packages.org::*Org Re-Reveal Extensions][Org Re-Reveal Extensions:1]]
(package! org-re-reveal-ref)
;; Org Re-Reveal Extensions:1 ends here

;; [[file:packages.org::*Org Roam Bibtex][Org Roam Bibtex:1]]
(package! org-roam-bibtex)
;; Org Roam Bibtex:1 ends here

;; [[file:packages.org::*Org GCal][Org GCal:1]]
(package! org-gcal)
;; Org GCal:1 ends here

;; [[file:packages.org::*Citeproc Org][Citeproc Org:1]]
(package! citeproc-org :pin "0fb4c96f48b3055a59a397af24d3f1a82cf77b66")
;; Citeproc Org:1 ends here

;; [[file:packages.org::*Dockerfile Mode][Dockerfile Mode:1]]
(package! dockerfile-mode)
;; Dockerfile Mode:1 ends here

;; [[file:packages.org::*Zotero][Zotero:1]]
(package! zotxt)
;; Zotero:1 ends here

;; [[file:packages.org::*Sphinx and RsT][Sphinx and RsT:1]]
(package! ox-rst
  :recipe (:host github
           :repo "msnoigrs/ox-rst"))
(package! sphinx-mode
  :recipe (:host github
           :repo "Fuco1/sphinx-mode"
           :files ("*.el")))
;; Sphinx and RsT:1 ends here

;; [[file:packages.org::*CPP Additions][CPP Additions:1]]
(package! highlight-doxygen)
;; CPP Additions:1 ends here

;; [[file:packages.org::*Meson Mode][Meson Mode:1]]
(package! meson-mode)
;; Meson Mode:1 ends here

;; [[file:packages.org::*Tup Mode][Tup Mode:1]]
(package! tup-mode
:recipe (:host github
           :repo "ejmr/tup-mode"))
;; Tup Mode:1 ends here

;; [[file:packages.org::*SaltStack Mode][SaltStack Mode:1]]
(package! salt-mode
:recipe (:host github
         :repo "glynnforrest/salt-mode"))
;; SaltStack Mode:1 ends here

;; [[file:packages.org::*PKGBUILD Mode][PKGBUILD Mode:1]]
(package! pkgbuild-mode
  :recipe (:host github
            :repo "juergenhoetzel/pkgbuild-mode"))
;; PKGBUILD Mode:1 ends here

;; [[file:packages.org::*LAMMPS Mode][LAMMPS Mode:1]]
(package! lammps-mode
  :recipe (:host github
                    :repo "HaoZeke/lammps-mode"))
;; LAMMPS Mode:1 ends here

;; [[file:packages.org::*Pug Mode][Pug Mode:1]]
(package! pug-mode)
;; Pug Mode:1 ends here

;; [[file:packages.org::*Nix Mode][Nix Mode:1]]
(package! nix-mode)
;; Nix Mode:1 ends here

;; [[file:packages.org::*VIM mode][VIM mode:1]]
(package! vimrc-mode)
;; VIM mode:1 ends here

;; [[file:packages.org::*JVM Languages][JVM Languages:1]]
; Kotlin > Java
(package! kotlin-mode)
; Groovy -> Testing
(package! groovy-mode)
;; JVM Languages:1 ends here

;; [[file:packages.org::*Systemd Mode][Systemd Mode:1]]
(package! systemd)
;; Systemd Mode:1 ends here

;; [[file:packages.org::*Wolfram Mode][Wolfram Mode:1]]
(package! wolfram-mode)
;; Wolfram Mode:1 ends here

;; [[file:packages.org::*Polymode][Polymode:1]]
(package! poly-R)
(package! poly-org)
;; Polymode:1 ends here

;; [[file:packages.org::*MELPA Helper][MELPA Helper:1]]
(package! package-lint)
(package! flycheck-package)
;; MELPA Helper:1 ends here

;; [[file:packages.org::*Doom][Doom:1]]
(package! emacs-snippets
  :recipe (:host github
           :repo "hlissner/emacs-snippets"
           :files ("*")))
;; Doom:1 ends here

;; [[file:packages.org::*Standard][Standard:1]]
(package! yasnippet-snippets
  :recipe (:host github
           :repo "AndreaCrotti/yasnippet-snippets"
           :files ("*")))
;; Standard:1 ends here

;; [[file:packages.org::*Math support][Math support:1]]
(package! cdlatex)
;; Math support:1 ends here

;; [[file:packages.org::*Math support][Math support:2]]
(package! math-symbol-lists)
;; Math support:2 ends here

;; [[file:packages.org::*Math support][Math support:3]]
(package! calctex :recipe (:host github :repo "johnbcoughlin/calctex"
                           :files ("*.el" "calctex/*.el" "calctex-contrib/*.el" "org-calctex/*.el" "vendor"))
  :pin "784cf911bc96aac0f47d529e8cee96ebd7cc31c9")
;; Math support:3 ends here
