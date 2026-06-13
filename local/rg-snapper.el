;;; rg-snapper.el --- Snapper prose formatting commands -*- lexical-binding: t; -*-

(require 'cl-lib)
(require 'compile)
(require 'subr-x)

(defgroup rg-snapper nil
  "Local commands for the Snapper semantic line-break formatter."
  :group 'tools)

(defcustom rg/snapper-executable "snapper"
  "Executable used for Snapper commands."
  :type 'string)

(defcustom rg/snapper-extension-format-alist
  '(("org" . "org")
    ("tex" . "latex")
    ("ltx" . "latex")
    ("latex" . "latex")
    ("md" . "markdown")
    ("markdown" . "markdown")
    ("rst" . "rst")
    ("txt" . "plaintext")
    ("text" . "plaintext"))
  "Mapping from file extensions to Snapper format names."
  :type '(alist :key-type string :value-type string))

(defcustom rg/snapper-mode-format-alist
  '((org-mode . "org")
    (latex-mode . "latex")
    (LaTeX-mode . "latex")
    (markdown-mode . "markdown")
    (gfm-mode . "markdown")
    (rst-mode . "rst")
    (text-mode . "plaintext"))
  "Mapping from major modes to Snapper format names."
  :type '(alist :key-type symbol :value-type string))

(defun rg/snapper--program ()
  "Return the Snapper executable path or signal a user error."
  (or (executable-find rg/snapper-executable)
      (user-error "Cannot find `%s' in PATH" rg/snapper-executable)))

(defun rg/snapper-format-for-file (file)
  "Return the Snapper format for FILE."
  (cdr (assoc-string
        (or (file-name-extension file) "")
        rg/snapper-extension-format-alist
        t)))

(defun rg/snapper-format-for-buffer ()
  "Return the Snapper format for the current buffer."
  (or (and buffer-file-name
           (rg/snapper-format-for-file buffer-file-name))
      (cdr (assq major-mode rg/snapper-mode-format-alist))))

(defun rg/snapper--format-args (format)
  "Return Snapper FORMAT arguments."
  (unless format
    (user-error "Cannot infer Snapper format for this buffer"))
  (list "--format" format))

(defun rg/snapper-region-args (&optional file)
  "Return Snapper arguments for formatting region text from FILE."
  (let ((format (or (and file (rg/snapper-format-for-file file))
                    (rg/snapper-format-for-buffer))))
    (append (when file
              (list "--stdin-filepath" file))
            (rg/snapper--format-args format))))

(defun rg/snapper-file-args (file &rest options)
  "Return Snapper arguments for FILE using OPTIONS.

OPTIONS accepts :check, :diff, and :in-place."
  (append (rg/snapper--format-args (rg/snapper-format-for-file file))
          (when (plist-get options :check)
            (list "--check"))
          (when (plist-get options :diff)
            (list "--diff"))
          (when (plist-get options :in-place)
            (list "--in-place"))
          (list file)))

(defun rg/snapper-git-diff-args (ref files)
  "Return Snapper git-diff arguments for REF and FILES."
  (append (list "git-diff" "--no-color" ref) files))

(defun rg/snapper--shell-command (args)
  "Return a shell command for Snapper ARGS."
  (mapconcat #'shell-quote-argument
             (cons (rg/snapper--program) args)
             " "))

(defun rg/snapper--saved-file ()
  "Return the current file path after saving it."
  (unless buffer-file-name
    (user-error "This buffer is not visiting a file"))
  (when (buffer-modified-p)
    (save-buffer))
  buffer-file-name)

(defun rg/snapper-format-region (beg end)
  "Format region from BEG to END with Snapper."
  (interactive "r")
  (let* ((file (or buffer-file-name (buffer-name)))
         (args (rg/snapper-region-args file))
         (exit (apply #'call-process-region
                      beg end (rg/snapper--program) t t nil args)))
    (unless (and (integerp exit) (zerop exit))
      (user-error "Snapper failed with exit status %S" exit))))

(defun rg/snapper-format-buffer ()
  "Format the current buffer with Snapper."
  (interactive)
  (rg/snapper-format-region (point-min) (point-max)))

(defun rg/snapper-check-buffer ()
  "Run Snapper check and diff for the current file."
  (interactive)
  (let ((default-directory (or (and buffer-file-name
                                    (file-name-directory buffer-file-name))
                               default-directory)))
    (compilation-start
     (rg/snapper--shell-command
      (rg/snapper-file-args (rg/snapper--saved-file) :check t :diff t))
     nil
     (lambda (_) "*snapper-check*"))))

(defun rg/snapper-git-diff (ref)
  "Run Snapper sentence-level git diff against REF."
  (interactive (list (read-string "Git ref: " "HEAD")))
  (compilation-start
   (rg/snapper--shell-command (rg/snapper-git-diff-args ref nil))
   nil
   (lambda (_) "*snapper-git-diff*")))

(defun rg/snapper-watch (patterns)
  "Watch PATTERNS with Snapper."
  (interactive
   (list (split-string-and-unquote
          (read-string "Snapper watch patterns: "
                       (or (and buffer-file-name
                                (shell-quote-argument buffer-file-name))
                           "*.org *.md *.tex *.rst")))))
  (let ((cmd (rg/snapper--shell-command (cons "watch" patterns))))
    (if (fboundp 'rg/vterm-named)
        (rg/vterm-named "snapper-watch" cmd)
      (compilation-start cmd nil (lambda (_) "*snapper-watch*")))))

(with-eval-after-load 'transient
  (transient-define-prefix rg/snapper-menu ()
    "Snapper commands."
    [["Format"
      ("f" "buffer" rg/snapper-format-buffer)
      ("r" "region" rg/snapper-format-region)
      ("c" "check" rg/snapper-check-buffer)]
     ["Diff"
      ("d" "git diff" rg/snapper-git-diff)]
     ["Watch"
      ("w" "watch" rg/snapper-watch)]]))

(provide 'rg-snapper)
;;; rg-snapper.el ends here
