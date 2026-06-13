;;; rg-cite-notes.el --- Citation reading note templates -*- lexical-binding: t; -*-

(require 'cl-lib)
(require 'subr-x)

(defgroup rg-cite-notes nil
  "Local citation reading-note template helpers."
  :group 'tools)

(defcustom rg/cite-notes-heading-todo "TODO"
  "Todo keyword used for citation reading-note headings."
  :type 'string)

(defcustom rg/cite-notes-heading-tags '("reading" "ridley")
  "Tags added to OokCite/Ridley reading-note headings."
  :type '(repeat string))

(defun rg/cite-notes--get (item key)
  "Return KEY from ITEM using symbol or string alist keys."
  (or (alist-get key item nil nil #'equal)
      (alist-get (symbol-name key) item nil nil #'equal)))

(defun rg/cite-notes--field (item key)
  "Return KEY from flat ITEM or its fields object."
  (or (rg/cite-notes--get item key)
      (when-let ((fields (rg/cite-notes--get item 'fields)))
        (rg/cite-notes--get fields key))))

(defun rg/cite-notes--nonempty-string-p (value)
  "Return non-nil when VALUE is a non-empty string."
  (and (stringp value) (not (string-empty-p value))))

(defun rg/cite-notes--creator-name (creator)
  "Return a readable author name for CREATOR."
  (if (stringp creator)
      creator
    (string-join
     (cl-remove-if-not
      #'rg/cite-notes--nonempty-string-p
      (list (or (rg/cite-notes--get creator 'firstName)
                (rg/cite-notes--get creator 'first)
                (rg/cite-notes--get creator 'given))
            (or (rg/cite-notes--get creator 'lastName)
                (rg/cite-notes--get creator 'last)
                (rg/cite-notes--get creator 'family)
                (rg/cite-notes--get creator 'name))))
     " ")))

(defun rg/cite-notes-authors-string (item)
  "Return a readable author string for ITEM."
  (let ((authors (or (rg/cite-notes--get item 'creators)
                     (rg/cite-notes--get item 'authors)
                     (rg/cite-notes--get item 'author))))
    (cond
     ((stringp authors) authors)
     ((listp authors) (mapconcat #'rg/cite-notes--creator-name authors ", "))
     (t nil))))

(defun rg/cite-notes--date-year (date)
  "Return a year string from DATE."
  (cond
   ((stringp date)
    (when (string-match "\\([0-9][0-9][0-9][0-9]\\)" date)
      (match-string 1 date)))
   ((listp date)
    (or (rg/cite-notes--get date 'year)
        (when-let ((parts (rg/cite-notes--get date 'date-parts)))
          (format "%s" (caar parts)))))
   (t nil)))

(defun rg/cite-notes-title (item)
  "Return citation title from ITEM."
  (or (rg/cite-notes--field item 'title)
      (rg/cite-notes--field item 'name)))

(defun rg/cite-notes-year (item)
  "Return citation year from ITEM."
  (or (rg/cite-notes--field item 'year)
      (rg/cite-notes--date-year (rg/cite-notes--field item 'date)
                                )))

(defun rg/cite-notes-doi (item)
  "Return DOI from ITEM."
  (or (rg/cite-notes--field item 'DOI)
      (rg/cite-notes--field item 'doi)))

(defun rg/cite-notes-journal (item)
  "Return journal/container title from ITEM."
  (or (rg/cite-notes--field item 'publicationTitle)
      (rg/cite-notes--field item 'journal)
      (rg/cite-notes--field item 'journaltitle)
      (rg/cite-notes--field item 'container-title)))

(defun rg/cite-notes-url (item)
  "Return URL from ITEM."
  (rg/cite-notes--field item 'url))

(defun rg/cite-notes-ridley-id (item)
  "Return Ridley item id from ITEM."
  (or (rg/cite-notes--get item 'item_id)
      (rg/cite-notes--get item 'itemId)
      (rg/cite-notes--get item 'id)))

(defun rg/cite-notes--ascii-slug (value)
  "Return an ASCII slug for VALUE."
  (let ((slug (downcase
               (replace-regexp-in-string
                "[^[:alnum:]]+" "-"
                (or value "")))))
    (string-trim slug "-" "-")))

(defun rg/cite-notes-citation-key (item &optional key)
  "Return citation KEY for ITEM."
  (or key
      (rg/cite-notes--field item 'citationKey)
      (rg/cite-notes--field item 'citation_key)
      (rg/cite-notes--field item 'citekey)
      (rg/cite-notes--field item '=key=)
      (when (fboundp 'ookcite-entry-citation-key)
        (funcall 'ookcite-entry-citation-key item))
      (let* ((author (car (split-string (or (rg/cite-notes-authors-string item)
                                            "")
                                         "[, ]+" t)))
             (year (rg/cite-notes-year item))
             (base (string-join
                    (cl-remove-if-not
                     #'rg/cite-notes--nonempty-string-p
                     (list author year))
                    "")))
        (unless (string-empty-p base)
          (rg/cite-notes--ascii-slug base)))))

(defun rg/cite-notes--property-lines (properties)
  "Return Org property lines from PROPERTIES."
  (mapconcat
   (pcase-lambda (`(,property . ,value))
     (format ":%s: %s" property value))
   (cl-remove-if-not
    (pcase-lambda (`(,property . ,value))
      (and (rg/cite-notes--nonempty-string-p property)
           (rg/cite-notes--nonempty-string-p value)))
    properties)
   "\n"))

(defun rg/cite-notes--drawer (properties)
  "Return an Org property drawer from PROPERTIES."
  (let ((lines (rg/cite-notes--property-lines properties)))
    (concat ":PROPERTIES:\n"
            (unless (string-empty-p lines)
              (concat lines "\n"))
            ":END:\n\n")))

(defun rg/cite-notes--ookcite-org-noter-properties ()
  "Return org-noter properties configured by OokCite."
  (when (boundp 'ookcite-ridley-org-noter-properties)
    (symbol-value 'ookcite-ridley-org-noter-properties)))

(defun rg/cite-notes-org-ref-title-format ()
  "Return canonical `org-ref-note-title-format'."
  (concat
   "* TODO %y - %t\n"
   ":PROPERTIES:\n"
   ":Custom_ID: %k\n"
   ":ROAM_KEY: cite:%k\n"
   ":NOTER_DOCUMENT: %F\n"
   ":AUTHOR: %9a\n"
   ":JOURNAL: %j\n"
   ":YEAR: %y\n"
   ":VOLUME: %v\n"
   ":PAGES: %p\n"
   ":DOI: %D\n"
   ":URL: %U\n"
   ":END:\n\n"))

(defun rg/cite-notes-bibtex-completion-template ()
  "Return canonical `bibtex-completion' reading-note template."
  (concat
   "#+TITLE: ${title}\n"
   "#+ROAM_KEY: cite:${=key=}\n"
   "#+ROAM_TAGS: ${keywords}\n"
   "* TODO Notes\n"
   ":PROPERTIES:\n"
   ":Custom_ID: ${=key=}\n"
   ":ROAM_KEY: cite:${=key=}\n"
   ":NOTER_DOCUMENT: %(orb-process-file-field \"${=key=}\")\n"
   ":AUTHOR: ${author-abbrev}\n"
   ":JOURNAL: ${journaltitle}\n"
   ":DATE: ${date}\n"
   ":YEAR: ${year}\n"
   ":DOI: ${doi}\n"
   ":URL: ${url}\n"
   ":END:\n\n"))

(defun rg/cite-notes-orb-head ()
  "Return canonical ORB capture head for reading notes."
  (concat
   "#+TITLE: ${=key=}: ${title}\n"
   "#+ROAM_KEY: ${ref}\n"
   "#+ROAM_TAGS:\n\n"
   "- keywords :: ${keywords}\n\n"
   "* ${title}\n"
   ":PROPERTIES:\n"
   ":Custom_ID: ${=key=}\n"
   ":ROAM_KEY: ${ref}\n"
   ":URL: ${url}\n"
   ":AUTHOR: ${author-or-editor}\n"
   ":NOTER_DOCUMENT: %(orb-process-file-field \"${=key=}\")\n"
   ":NOTER_PAGE:\n"
   ":END:\n\n"))

(defun rg/cite-notes-ookcite-note-text (item pdf-file &optional key)
  "Return canonical OokCite/Ridley note text for ITEM and PDF-FILE.

KEY overrides the generated citation key."
  (let* ((cite-key (rg/cite-notes-citation-key item key))
         (title (or (rg/cite-notes-title item) cite-key "Untitled"))
         (tags (and rg/cite-notes-heading-tags
                    (concat " :" (string-join rg/cite-notes-heading-tags ":")
                            ":")))
         (properties
          (append
           `(("Custom_ID" . ,cite-key)
             ("ROAM_KEY" . ,(format "cite:%s" cite-key))
             ("NOTER_DOCUMENT" . ,pdf-file))
           (rg/cite-notes--ookcite-org-noter-properties)
           `(("RIDLEY_ITEM_ID" . ,(rg/cite-notes-ridley-id item))
             ("DOI" . ,(rg/cite-notes-doi item))
             ("URL" . ,(rg/cite-notes-url item))
             ("AUTHOR" . ,(rg/cite-notes-authors-string item))
             ("JOURNAL" . ,(rg/cite-notes-journal item))
             ("YEAR" . ,(rg/cite-notes-year item))))))
    (concat "* " rg/cite-notes-heading-todo " " title tags "\n"
            (rg/cite-notes--drawer properties)
            (format "[[%s][PDF]]\n\n" pdf-file)
            (format "cite:@%s\n\n" cite-key))))

(provide 'rg-cite-notes)
;;; rg-cite-notes.el ends here
