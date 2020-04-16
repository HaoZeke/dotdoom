;; [[file:~/.config/doom/packages.org::*About this file][About this file:1]]
;; -*- no-byte-compile: t; -*-
;;; ~/.config/doom/packages.el
;; About this file:1 ends here

;; [[file:~/.config/doom/packages.org::*Dired Icons][Dired Icons:1]]
(package! all-the-icons-dired)
;; Dired Icons:1 ends here

;; [[file:~/.config/doom/packages.org::*Wakatime][Wakatime:1]]
(package! wakatime-mode)
;; Wakatime:1 ends here

;; [[file:~/.config/doom/packages.org::*Git Annex][Git Annex:1]]
(package! magit-annex)
(package! git-annex)
;; Git Annex:1 ends here

;; [[file:~/.config/doom/packages.org::*LATER Key Chords and Keybindings][LATER Key Chords and Keybindings:1]]
(package! general)
;; LATER Key Chords and Keybindings:1 ends here

;; [[file:~/.config/doom/packages.org::*Org Download][Org Download:1]]
(package! org-download)
;; Org Download:1 ends here

;; [[file:~/.config/doom/packages.org::*Org Noter][Org Noter:1]]
(package! org-noter)
;; Org Noter:1 ends here

;; [[file:~/.config/doom/packages.org::*Org Ref][Org Ref:1]]
(package! org-ref)
;; Org Ref:1 ends here

;; [[file:~/.config/doom/packages.org::*Org Mind Map][Org Mind Map:1]]
(package! org-mind-map
  :recipe (:host github
            :repo "theodorewiles/org-mind-map"))
;; Org Mind Map:1 ends here

;; [[file:~/.config/doom/packages.org::*Org Rifle][Org Rifle:1]]
(package! helm-org-rifle)
;; Org Rifle:1 ends here

;; [[file:~/.config/doom/packages.org::*Org Gcal][Org Gcal:1]]
(package! org-gcal)
;; Org Gcal:1 ends here

;; [[file:~/.config/doom/packages.org::*Anki Mode][Anki Mode:1]]
(package! anki-editor)
;; Anki Mode:1 ends here

;; [[file:~/.config/doom/packages.org::*Dockerfile Mode][Dockerfile Mode:1]]
(package! dockerfile-mode)
;; Dockerfile Mode:1 ends here

;; [[file:~/.config/doom/packages.org::*Zotero][Zotero:1]]
(package! zotxt)
;; Zotero:1 ends here

;; [[file:~/.config/doom/packages.org::*Tup Mode][Tup Mode:1]]
(package! tup-mode
:recipe (:host github
           :repo "ejmr/tup-mode"))
;; Tup Mode:1 ends here

;; [[file:~/.config/doom/packages.org::*SaltStack Mode][SaltStack Mode:1]]
(package! salt-mode
:recipe (:host github
         :repo "glynnforrest/salt-mode"))
;; SaltStack Mode:1 ends here

;; [[file:~/.config/doom/packages.org::*PKGBUILD Mode][PKGBUILD Mode:1]]
(package! pkgbuild-mode
  :recipe (:host github
            :repo "juergenhoetzel/pkgbuild-mode"))
;; PKGBUILD Mode:1 ends here

;; [[file:~/.config/doom/packages.org::*LAMMPS Mode][LAMMPS Mode:1]]
(package! lammps-mode
  :recipe (:host github
                    :repo "HaoZeke/lammps-mode"))
;; LAMMPS Mode:1 ends here

;; [[file:~/.config/doom/packages.org::*Pug Mode][Pug Mode:1]]
(package! pug-mode)
;; Pug Mode:1 ends here

;; [[file:~/.config/doom/packages.org::*Nix Mode][Nix Mode:1]]
(package! nix-mode)
;; Nix Mode:1 ends here

;; [[file:~/.config/doom/packages.org::*JVM Languages][JVM Languages:1]]
; Kotlin > Java
(package! kotlin-mode)
; Groovy -> Testing
(package! groovy-mode)
;; JVM Languages:1 ends here

;; [[file:~/.config/doom/packages.org::*Systemd Mode][Systemd Mode:1]]
(package! systemd)
;; Systemd Mode:1 ends here

;; [[file:~/.config/doom/packages.org::*Polymode][Polymode:1]]
(package! poly-R)
;; Polymode:1 ends here

;; [[file:~/.config/doom/packages.org::*MELPA Helper][MELPA Helper:1]]
(package! package-lint)
(package! flycheck-package)
;; MELPA Helper:1 ends here

;; [[file:~/.config/doom/packages.org::*Doom][Doom:1]]
(package! emacs-snippets
  :recipe (:host github
           :repo "hlissner/emacs-snippets"
           :files ("*")))
;; Doom:1 ends here

;; [[file:~/.config/doom/packages.org::*Standard][Standard:1]]
(package! yasnippet-snippets
  :recipe (:host github
           :repo "AndreaCrotti/yasnippet-snippets"
           :files ("*")))
;; Standard:1 ends here

;; [[file:~/.config/doom/packages.org::*Math support][Math support:1]]
(package! cdlatex)
;; Math support:1 ends here
