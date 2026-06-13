;;; rg-vale.el --- Vale prose lint commands -*- lexical-binding: t; -*-

(require 'compile)
(require 'subr-x)

(defgroup rg-vale nil
  "Local commands for Vale prose linting."
  :group 'tools)

(defcustom rg/vale-executable "vale"
  "Executable used for Vale commands."
  :type 'string)

(defcustom rg/vale-config-file (expand-file-name "~/.config/vale/.vale.ini")
  "Vale configuration file."
  :type 'file)

(defcustom rg/vale-document-glob "*.{org,md,markdown,rst,tex,txt}"
  "Glob used when running Vale over a directory."
  :type 'string)

(defun rg/vale--program ()
  "Return the Vale executable path or signal a user error."
  (or (executable-find rg/vale-executable)
      (user-error "Cannot find `%s' in PATH" rg/vale-executable)))

(defun rg/vale-command-args (paths &rest options)
  "Return Vale arguments for PATHS using OPTIONS.

OPTIONS accepts :glob."
  (append (list "--config" rg/vale-config-file
                "--output" "line"
                "--no-wrap")
          (when-let ((glob (plist-get options :glob)))
            (list "--glob" glob))
          paths))

(defun rg/vale-sync-args ()
  "Return Vale sync arguments."
  (list "--config" rg/vale-config-file "sync"))

(defun rg/vale--shell-command (args)
  "Return a shell command for Vale ARGS."
  (mapconcat #'shell-quote-argument
             (cons (rg/vale--program) args)
             " "))

(defun rg/vale--saved-file ()
  "Return the current file path after saving it."
  (unless buffer-file-name
    (user-error "This buffer is not visiting a file"))
  (when (buffer-modified-p)
    (save-buffer))
  buffer-file-name)

(defun rg/vale-run (paths &optional glob)
  "Run Vale over PATHS, optionally restricted by GLOB."
  (interactive
   (list
    (split-string-and-unquote
     (read-string "Vale paths: "
                  (or (and buffer-file-name
                           (shell-quote-argument buffer-file-name))
                      default-directory)))
    nil))
  (compilation-start
   (rg/vale--shell-command
    (apply #'rg/vale-command-args
           paths
           (when glob
             (list :glob glob))))
   nil
   (lambda (_) "*vale-rgoswami*")))

(defun rg/vale-buffer ()
  "Run Vale over the current file."
  (interactive)
  (rg/vale-run (list (rg/vale--saved-file))))

(defun rg/vale-directory (directory)
  "Run Vale over DIRECTORY with `rg/vale-document-glob'."
  (interactive "DRun Vale in directory: ")
  (rg/vale-run (list (directory-file-name directory)) rg/vale-document-glob))

(defun rg/vale-project ()
  "Run Vale over the current project."
  (interactive)
  (let ((root (or (and (fboundp 'projectile-project-root)
                       (ignore-errors (projectile-project-root)))
                  (when-let ((project (project-current)))
                    (project-root project))
                  default-directory)))
    (rg/vale-directory root)))

(defun rg/vale-sync ()
  "Run Vale sync using `rg/vale-config-file'."
  (interactive)
  (compilation-start
   (rg/vale--shell-command (rg/vale-sync-args))
   nil
   (lambda (_) "*vale-sync*")))

(provide 'rg-vale)
;;; rg-vale.el ends here
