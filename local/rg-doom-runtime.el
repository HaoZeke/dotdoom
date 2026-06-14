;;; rg-doom-runtime.el --- Runtime glue for Doom integrations -*- lexical-binding: t; -*-

(defgroup rg-doom-runtime nil
  "Runtime helpers for local Doom integrations."
  :group 'doom)

(defcustom rg/ookcite-source-dir
  (expand-file-name "~/Git/Github/Tools/ookcite.el")
  "Source directory for the local OokCite package."
  :type 'directory
  :group 'rg-doom-runtime)

(defun rg/add-existing-load-path (path)
  "Add PATH to `load-path' when it names an existing directory."
  (when (file-directory-p path)
    (let ((dir (file-name-as-directory path)))
      (add-to-list 'load-path dir)
      dir)))

(defun rg/register-ookcite-source ()
  "Expose the local OokCite source directory to `load-path'."
  (rg/add-existing-load-path rg/ookcite-source-dir))

(defun rg/doom-module-has-flag-p (group module flag)
  "Return non-nil when Doom GROUP MODULE has FLAG enabled."
  (and (fboundp 'doom-module-get)
       (fboundp 'doom-module--has-flag-p)
       (when-let* ((flags (doom-module-get (cons group module) :flags)))
         (doom-module--has-flag-p flags flag))))

(defun rg/julia-snail-enabled-p ()
  "Return non-nil when Doom's Julia snail flag is enabled."
  (rg/doom-module-has-flag-p :lang 'julia '+snail))

(defun rg/julia-open-repl-command-predicate (_sym _buf)
  "Return non-nil when the regular Julia REPL command should be listed."
  (not (rg/julia-snail-enabled-p)))

(defun rg/julia-open-snail-repl-command-predicate (_sym _buf)
  "Return non-nil when the Julia Snail REPL command should be listed."
  (rg/julia-snail-enabled-p))

(defun rg/install-julia-command-predicates ()
  "Install Julia command completion predicates with explicit module lookup."
  (function-put '+julia/open-repl
                'completion-predicate
                #'rg/julia-open-repl-command-predicate)
  (function-put '+julia/open-snail-repl
                'completion-predicate
                #'rg/julia-open-snail-repl-command-predicate))

(provide 'rg-doom-runtime)
;;; rg-doom-runtime.el ends here
