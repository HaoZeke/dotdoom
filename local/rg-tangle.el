;;; rg-tangle.el --- Reproducible tangling for this Doom config -*- lexical-binding: t; -*-

(require 'cl-lib)

(defvar doom-private-dir)
(defvar org-coderef-label-format)

(declare-function org-babel-tangle-file "ob-tangle")

(defvar rg/tangle--coderef-advice-installed nil
  "Non-nil when the Org coderef compatibility advice is installed.")

(defun rg/tangle--repo-root ()
  "Return the repository root for this file."
  (let ((file (expand-file-name
               (or load-file-name buffer-file-name "local/rg-tangle.el"))))
    (file-name-directory
     (directory-file-name
      (file-name-directory file)))))

(defun rg/tangle--straight-build-dir ()
  "Return the Straight build directory matching the current Emacs."
  (let* ((straight-root (expand-file-name "~/.config/emacs/.local/straight/"))
         (exact (expand-file-name
                 (format "build-%d.%d" emacs-major-version emacs-minor-version)
                 straight-root)))
    (file-name-as-directory
     (or (car (file-expand-wildcards exact))
         (car (last (sort (file-expand-wildcards
                           (expand-file-name "build-*" straight-root))
                          #'string<)))
         exact))))

(defun rg/tangle--load-org ()
  "Load Org from the active Doom package tree when available."
  (let ((org-dir (expand-file-name "org" (rg/tangle--straight-build-dir))))
    (when (file-directory-p org-dir)
      (add-to-list 'load-path org-dir)))
  (require 'org))

(defun rg/tangle--org-src-coderef-regexp (orig-fn fmt &optional label)
  "Call ORIG-FN with a default coderef FMT when FMT is nil."
  (funcall orig-fn (or fmt org-coderef-label-format "(ref:%s)") label))

(defun rg/tangle-setup (&optional root)
  "Prepare batch Emacs to tangle this Doom config from ROOT."
  (rg/tangle--load-org)
  (setq doom-private-dir
        (file-name-as-directory (expand-file-name (or root (rg/tangle--repo-root)))))
  (unless rg/tangle--coderef-advice-installed
    (advice-add 'org-src-coderef-regexp
                :around #'rg/tangle--org-src-coderef-regexp)
    (setq rg/tangle--coderef-advice-installed t))
  doom-private-dir)

(defun rg/tangle-files (&optional root)
  "Return canonical literate config files under ROOT."
  (let ((base (file-name-as-directory (expand-file-name (or root (rg/tangle--repo-root))))))
    (list (expand-file-name "config.org" base)
          (expand-file-name "packages.org" base))))

(defun rg/tangle-repo (&optional root)
  "Tangle this Doom config from ROOT."
  (interactive)
  (let ((base (rg/tangle-setup root)))
    (dolist (file (rg/tangle-files base))
      (unless (file-readable-p file)
        (user-error "Cannot read %s" file))
      (org-babel-tangle-file file))))

(provide 'rg-tangle)
;;; rg-tangle.el ends here
