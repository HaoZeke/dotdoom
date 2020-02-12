;;; init.el -*- lexical-binding: t; -*-
;; This file controls what Doom modules are enabled and what order they load in.
;; Remember to run 'doom sync' after modifying it!

;; NOTE Press 'SPC h d h' (or 'C-h d h' for non-vim users) to access Doom's
;;      documentation. There you'll find information about all of Doom's modules
;;      and what flags they support.

;; NOTE Move your cursor over a module's name (or its flags) and press 'K' (or
;;      'C-c g k' for non-vim users) to view its documentation. This works on
;;      flags as well (those symbols that start with a plus).
;;
;;      Alternatively, press 'gd' (or 'C-c g d') on a module to browse its
;;      directory (for easy access to its source code).

;; Copy me to ~/.doom.d/init.el or ~/.config/doom/init.el, then edit me!

(doom! :input
       ;;chinese
       ;;japanese

       :completion
       (company          ; the ultimate code completion backend
        +childframe)      ; a better UI for company (Emacs 26+)
      ;; (helm             ; the *other* search engine for love and life
      ;;   +childframe      ; a better UI for helm (Emacs 26+)
      ;;   +fuzzy)          ; enable fuzzy search backend for helm
      ;; ido               ; the other *other* search engine...
       (ivy              ; a search engine for love and life
        +childframe      ; a better UI for ivy (Emacs 26+)
        +prescient       ; better? filtering and sorting?
        +icons           ; enables file icons
        +fuzzy)          ; enable fuzzy search backend for ivy

      :ui
      deft              ; notational velocity for Emacs
      doom              ; what makes DOOM look the way it does
      doom-dashboard    ; a nifty splash screen for Emacs
      doom-quit         ; DOOM quit-message prompts when you quit Emacs
      fill-column       ; a `fill-column' indicator
      hl-todo           ; highlight TODO/FIXME/NOTE tags
      ;; hydra
      ;; indent-guides  ; highlighted indent columns
      modeline          ; snazzy, Atom-inspired modeline, plus API
      nav-flash         ; blink the current line after jumping
      ;; neotree        ; a project drawer, like NERDTree for vim
      ophints           ; highlight the region an operation acts on
      (popup            ; tame sudden yet inevitable temporary windows
        +all            ; catch all popups that start with an asterix
        +defaults)      ; default popup rules
      pretty-code       ; replace bits of code with prettymbols
      ;; tabs           ; a tab bar for Emacs
      treemacs          ; a project drawer, like neotree but cooler
      unicode           ; extended unicode support for various languages
      vc-gutter         ; vcs diff in the fringe
      vi-tilde-fringe   ; fringe tildes to mark beyond EOB
      window-select     ; visually switch windows
      workspaces        ; tab emulation, persistence & separate workspaces
      ;; zen              ; distraction-free coding or writing

      :editor
      (evil +everywhere) ; come to the dark side, we have cookies
      file-templates     ; auto-snippets for empty files
      fold               ; (nigh) universal code folding
      (format +onsave)   ; Automated prettiness
      ;; god             ; run Emacs commands without modifier keys
      ;; lispy           ; vim for lisp, for people who dont like vim
      multiple-cursors   ; editing in many places at once
      ;; objed           ; text object editing for the innocent
      ;; parinfer        ; turn lisp into python, sort of
      rotate-text        ; cycle region at point between text candidates
      snippets           ; my elves. They type so I don't have to
      word-wrap       ; soft wrapping with language aware indent


       :emacs
       (dired            ; making dired pretty [functional]
        +ranger           ; bringing the goodness of ranger to dired
        +icons)            ; colorful icons for dired-mode
       electric          ; smarter, keyword-based electric-indent
       ibuffer           ; interactive buffer management
       vc                ; version-control and Emacs, sitting in a tree

       :term
       ;; eshell            ; a consistent, cross-platform shell (WIP)
       ;; shell           ; a terminal REPL for Emacs
       term              ; terminals in Emacs
       ;; vterm             ; another terminal in Emacs
      
       :checkers
       (syntax             ; tasing you for every semicolon you forget
        +childframe)       ; use childframes for error popups (Emacs 26+ only)
       spell             ; tasing you for misspelling mispelling
       ;;grammar           ; tasing grammar mistake every you make

       :tools
       ;; ansible
       ;; debugger          ; FIXME stepping through code, to help you add bugs
       ;; direnv
       ;; docker
       editorconfig      ; let someone else argue about tabs vs spaces
       ;; ein            ; tame Jupyter notebooks with emacs
       (eval +overlay)   ; run code, run (also, repls)
       gist              ; interacting with github gists
       (lookup           ; helps you navigate your code and documentation
        +docsets)        ; ...on in Dash docsets locally
       lsp
       ;; macos            ; MacOS-specific commands
       ;; make             ; run make tasks from Emacs
       magit             ; a git porcelain for Emacs
       ;; pass           ;password manager for nerds
       pdf               ; pdf enhancements
       ;; prodigy          ; FIXME managing external services & code builders
       ;; rgb              ; creating color strings
       ;; terraform         ; infrastructure as code
       tmux              ; an API for interacting with tmux
       ;; upload           ; map local to remote projects via ssh/ftp

       :lang
       ;; agda              ; types of types of types of types...
       ;; assembly          ; assembly for fun or debugging
       (cc +lsp)                   ; C/C++/Obj-C madness
       ;; clojure           ; java with a lisp
       ;; common-lisp       ; if you've seen one lisp, you've seen them all
       ;; coq               ; proofs-as-programs
       ;; crystal           ; ruby at the speed of c
       ;; csharp            ; unity, .NET, and mono shenanigans
       data                 ; config/data formats
       ;; elixir            ; erlang done right
       ;; elm               ; care for a cup of TEA?
       emacs-lisp           ; drown in parentheses
       ;; erlang            ; an elegant language for a more civilized age
       ess                  ; emacs speaks statistics
       ;;faust              ; dsp, but you get to keep your soul
       ;;fsharp             ; ML stands for Microsoft's Language
       ;; go                   ; the hipster dialect
       (haskell +dante)   ; a language that's lazier than I am
       ;; hy                 ; readability of scheme w/ speed of python
       ;; idris
       ;; (java +meghanada)  ; the poster child for carpal tunnel syndrome
       javascript          ; all(hope(abandon(ye(who(enter(here))))))
       ;; julia            ; a better, faster MATLAB
       ;; kotlin           ; a better, slicker Java(Script)
       (latex              ; writing papers in Emacs has never been so fun
        +latexmk)          ; No other option TBH
       ;; lean
       ;; factor
       ;; ledger             ; an accounting system in Emacs
       lua               ; one-based indices? one-based indices
       markdown         ; writing docs for people to ignore
       ;; nim               ; python + lisp at the speed of c
       nix                ; I hereby declare "nix geht mehr!"
       ;; ocaml             ; an objective camel
       (org              ; organize your plain life in plain text
        ;; +brain           ; for org-brain support
        +dragndrop       ; file drag & drop support
        +gnuplot         ; render gnuplot
        +hugo            ; use Emacs for hugo blogging
        ;; +journal      ; journaling in org
        ;; +jupyter         ; enable jupyter integration
        +pandoc          ; pandoc integration into org's exporter
       ;;+pomodoro       ; be fruitful with the tomato technique
        +present)        ; using Emacs for presentations
       ;; perl            ; write code no one else can comprehend
       ;; php             ; perl's insecure younger brother
       ;; plantuml        ; diagrams for confusing people more
       ;; purescript      ; javascript, but functional
       python            ; beautiful is better than ugly
       ;; qt              ; the 'cutest' gui framework ever
       ;; racket          ; a DSL for DSLs
       ;; rest            ; Emacs as a REST client
       ;; rst             ; ReST in peace
       ruby               ; 1.step do {|i| p "Ruby is #{i.even? ? 'love' : 'life'}"}
       rust            ; Fe2O3.unwrap().unwrap().unwrap().unwrap()
       ;; scala           ; java, but good
       ;;scheme            ; a fully conniving family of lisps
       sh                ; she sells (ba|z)sh shells on the C xor
       ;; solidity          ; do you need a blockchain? No.
       ;; swift             ; who asked for emoji variables?
       ;; terra           ; Earth and Moon in alignment for performance.
       web                ; the tubes

       :email
       ;;(mu4e +gmail)
       ;;notmuch
       ;;(wanderlust +gmail)

       ;; Applications are complex and opinionated modules that transform Emacs
       ;; toward a specific purpose. They may have additional dependencies and
       ;; should be loaded late.

       :app
       ;;calendar
       ;;irc               ; how neckbeards socialize
       ;;(rss +org)        ; emacs as an RSS reader
       ;;twitter           ; twitter client https://twitter.com/vnought
       ;;write             ; emacs for writers (fiction, notes, papers, etc.)
      
       :config
       ;; For literate config users. This will tangle+compile a config.org
       ;; literate config in your `doom-private-dir' whenever it changes.
       literate

       ;; The default module set reasonable defaults for Emacs. It also provides
       ;; a Spacemacs-inspired keybinding scheme, a custom yasnippet library,
       ;; and additional ex commands for evil-mode. Use it as a reference for
       ;; your own modules.
       (default +bindings +smartparens))
