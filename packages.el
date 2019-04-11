;; [[file:~/Git/Github/Dotfiles/dotfiles/emacs/.config/doom/packages.org::*About%20this%20file][About this file:1]]
;; -*- no-byte-compile: t; -*-
;;; ~/.config/doom/packages.el
;; About this file:1 ends here

;; [[file:~/Git/Github/Dotfiles/dotfiles/emacs/.config/doom/packages.org::*Dired%20Icons][Dired Icons:1]]
(package! all-the-icons-dired)
;; Dired Icons:1 ends here

;; [[file:~/Git/Github/Dotfiles/dotfiles/emacs/.config/doom/packages.org::*Git%20Annex][Git Annex:1]]
(package! magit-annex)
(package! git-annex)
;; Git Annex:1 ends here

;; [[file:~/Git/Github/Dotfiles/dotfiles/emacs/.config/doom/packages.org::*Key%20Chords%20and%20Keybindings][Key Chords and Keybindings:1]]
(package! general)
;; Key Chords and Keybindings:1 ends here

;; [[file:~/Git/Github/Dotfiles/dotfiles/emacs/.config/doom/packages.org::*Org%20Download][Org Download:1]]
(package! org-download)
;; Org Download:1 ends here

;; [[file:~/Git/Github/Dotfiles/dotfiles/emacs/.config/doom/packages.org::*Org%20Noter][Org Noter:1]]
(package! org-noter)
;; Org Noter:1 ends here

;; [[file:~/Git/Github/Dotfiles/dotfiles/emacs/.config/doom/packages.org::*Org%20Ref][Org Ref:1]]
(package! org-ref)
;; Org Ref:1 ends here

;; [[file:~/Git/Github/Dotfiles/dotfiles/emacs/.config/doom/packages.org::*Org%20Mind%20Map][Org Mind Map:1]]
(package! org-mind-map
  :recipe (:fetcher github
            :repo "theodorewiles/org-mind-map"))
;; Org Mind Map:1 ends here

;; [[file:~/Git/Github/Dotfiles/dotfiles/emacs/.config/doom/packages.org::*Org%20Rifle][Org Rifle:1]]
(package! helm-org-rifle)
;; Org Rifle:1 ends here

;; [[file:~/Git/Github/Dotfiles/dotfiles/emacs/.config/doom/packages.org::*Anki%20Mode][Anki Mode:1]]
(package! anki-editor)
;; Anki Mode:1 ends here

;; [[file:~/Git/Github/Dotfiles/dotfiles/emacs/.config/doom/packages.org::*Dockerfile%20Mode][Dockerfile Mode:1]]
(package! dockerfile-mode)
;; Dockerfile Mode:1 ends here

;; [[file:~/Git/Github/Dotfiles/dotfiles/emacs/.config/doom/packages.org::*Zotero][Zotero:1]]
(package! zotxt)
;; Zotero:1 ends here

;; [[file:~/Git/Github/Dotfiles/dotfiles/emacs/.config/doom/packages.org::*Tup%20Mode][Tup Mode:1]]
(package! tup-mode
:recipe (:fetcher github
           :repo "ejmr/tup-mode"))
;; Tup Mode:1 ends here

;; [[file:~/Git/Github/Dotfiles/dotfiles/emacs/.config/doom/packages.org::*SaltStack%20Mode][SaltStack Mode:1]]
(package! salt-mode
:recipe (:fetcher github
         :repo "glynnforrest/salt-mode"))
;; SaltStack Mode:1 ends here

;; [[file:~/Git/Github/Dotfiles/dotfiles/emacs/.config/doom/packages.org::*PKGBUILD%20Mode][PKGBUILD Mode:1]]
(package! pkgbuild-mode
  :recipe (:fetcher github
            :repo "juergenhoetzel/pkgbuild-mode"))
;; PKGBUILD Mode:1 ends here

;; [[file:~/Git/Github/Dotfiles/dotfiles/emacs/.config/doom/packages.org::*LAMMPS%20Mode][LAMMPS Mode:1]]
(package! lammps-mode
  :recipe (:fetcher github
                    :repo "HaoZeke/lammps-mode"))
;; LAMMPS Mode:1 ends here

;; [[file:~/Git/Github/Dotfiles/dotfiles/emacs/.config/doom/packages.org::*Pug%20Mode][Pug Mode:1]]
(package! pug-mode)
;; Pug Mode:1 ends here

;; [[file:~/Git/Github/Dotfiles/dotfiles/emacs/.config/doom/packages.org::*Nix%20Mode][Nix Mode:1]]
(package! nix-mode)
;; Nix Mode:1 ends here

;; [[file:~/Git/Github/Dotfiles/dotfiles/emacs/.config/doom/packages.org::*JVM%20Languages][JVM Languages:1]]
; Kotlin > Java
(package! kotlin-mode)
; Groovy -> Testing
(package! groovy-mode)
;; JVM Languages:1 ends here

;; [[file:~/Git/Github/Dotfiles/dotfiles/emacs/.config/doom/packages.org::*MELPA%20Helper][MELPA Helper:1]]
(package! package-lint)
(package! flycheck-package)
;; MELPA Helper:1 ends here

;; [[file:~/Git/Github/Dotfiles/dotfiles/emacs/.config/doom/packages.org::*Doom][Doom:1]]
(package! emacs-snippets
  :recipe (:fetcher github
           :repo "hlissner/emacs-snippets"
           :files ("*")))
;; Doom:1 ends here

;; [[file:~/Git/Github/Dotfiles/dotfiles/emacs/.config/doom/packages.org::*Standard][Standard:1]]
(package! yasnippet-snippets
  :recipe (:fetcher github
           :repo "AndreaCrotti/yasnippet-snippets"
           :files ("*")))
;; Standard:1 ends here

;; [[file:~/Git/Github/Dotfiles/dotfiles/emacs/.config/doom/packages.org::*Math%20support][Math support:1]]
(package! cdlatex)
;; Math support:1 ends here
