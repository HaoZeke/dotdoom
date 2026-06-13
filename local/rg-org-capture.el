;;; rg-org-capture.el --- Local Org capture templates -*- lexical-binding: t; -*-

(require 'cl-lib)

(defvar org-capture-templates nil)
(defvar +org-capture-notes-file)

(defgroup rg-org-capture nil
  "Local Org capture template helpers."
  :group 'org)

(defun rg/org-capture-transform-square-brackets (string-to-transform)
  "Transform square brackets in STRING-TO-TRANSFORM into round brackets."
  (concat
   (mapcar (lambda (char)
             (cond
              ((equal char ?\[) ?\()
              ((equal char ?\]) ?\))
              (t char)))
           string-to-transform)))

(defun rg/org-capture-templates ()
  "Return local Org capture templates."
  '(("P" "Protocol" entry
     (file+headline +org-capture-notes-file "Inbox")
     "* %^{Title}\nSource: %u, %c\n #+BEGIN_QUOTE\n%i\n#+END_QUOTE\n\n\n%?"
     :prepend t
     :kill-buffer t)
    ("L" "Protocol Link" entry
     (file+headline +org-capture-notes-file "Inbox")
     "* %? [[%:link][%(rg/org-capture-transform-square-brackets \"%:description\")]]\n"
     :prepend t
     :kill-buffer t)
    ("a" "Article" entry
     (file+headline +org-capture-notes-file "Article")
     "* %^{Title} %(org-set-tags)  :article: \n:PROPERTIES:\n:Created: %U\n:Linked: %a\n:END:\n%i\nBrief description:\n%?"
     :prepend t
     :empty-lines 1
     :created t)))

(defun rg/org-capture-html-template ()
  "Return the HTML org-protocol capture template."
  '("w" "Web site" entry
    (file+headline +org-capture-notes-file "Website")
    "* %a :website:\n\n%U %?\n\n%:initial"))

(defun rg/org-capture--add-template (template)
  "Add TEMPLATE to `org-capture-templates' by key."
  (let ((key (car template)))
    (setq org-capture-templates
          (cons template
                (cl-remove-if
                 (lambda (existing)
                   (equal (car existing) key))
                 org-capture-templates)))))

(defun rg/org-capture-install ()
  "Install local Org capture templates."
  (dolist (template (reverse (rg/org-capture-templates)))
    (rg/org-capture--add-template template))
  org-capture-templates)

(defun rg/org-capture-install-html ()
  "Install the HTML org-protocol capture template."
  (rg/org-capture--add-template (rg/org-capture-html-template))
  org-capture-templates)

(provide 'rg-org-capture)
;;; rg-org-capture.el ends here
