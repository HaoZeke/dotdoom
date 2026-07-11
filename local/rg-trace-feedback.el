;;; rg-trace-feedback.el --- Emacs interface for xait trace feedback -*- lexical-binding: t; -*-

(require 'cl-lib)
(require 'subr-x)

(defgroup rg-trace-feedback nil
  "Create and manage xait Trace Analysis V2 feedback packets."
  :group 'tools)

(defcustom rg/trace-feedback-vault-root nil
  "Trace Analysis V2 root containing the tasks directory."
  :type '(choice (const :tag "Unset" nil) directory)
  :group 'rg-trace-feedback)

(defcustom rg/trace-feedback-default-model nil
  "Model name passed to xait queue commands."
  :type '(choice (const :tag "Unset" nil) string)
  :group 'rg-trace-feedback)

(defcustom rg/trace-feedback-key-prefix nil
  "Doom leader prefix for trace feedback commands."
  :type '(choice (const :tag "Unset" nil) string)
  :group 'rg-trace-feedback)

(defcustom rg/trace-feedback-xait-executable "xait"
  "Executable used for xait commands."
  :type 'string
  :group 'rg-trace-feedback)

(defcustom rg/trace-feedback-private-settings-file
  (when (boundp 'doom-private-dir)
    (expand-file-name "local/private/rg-trace-feedback-settings.el"
                      doom-private-dir))
  "Nimvaulted file containing machine-specific trace settings."
  :type '(choice (const :tag "Unset" nil) file)
  :group 'rg-trace-feedback)

(defconst rg/trace-feedback--buckets
  '("tbd" "submitted" "noResult" "not_applicable"))

(defun rg/trace-feedback--require-root ()
  "Return the configured trace root or raise a user error."
  (unless (and rg/trace-feedback-vault-root
               (not (string-empty-p rg/trace-feedback-vault-root)))
    (user-error "Set rg/trace-feedback-vault-root in the private settings"))
  (file-name-as-directory
   (expand-file-name rg/trace-feedback-vault-root)))

(defun rg/trace-feedback--tasks-root ()
  "Return the configured tasks directory."
  (expand-file-name "tasks" (rg/trace-feedback--require-root)))

(defun rg/trace-feedback-packet-dir (&optional path)
  "Return the trace packet directory containing PATH.

PATH defaults to the current buffer file."
  (let* ((target (or path buffer-file-name
                     (user-error "Current buffer has no file")))
         (tasks (file-name-as-directory
                 (expand-file-name (rg/trace-feedback--tasks-root))))
         (dir (file-name-as-directory
               (if (file-directory-p target)
                   (expand-file-name target)
                 (file-name-directory (expand-file-name target)))))
         found)
    (unless (file-in-directory-p dir tasks)
      (user-error "Current file is outside the configured trace tasks"))
    (while (and dir (not found) (file-in-directory-p dir tasks))
      (let* ((parent (file-name-directory (directory-file-name dir)))
             (bucket (and parent
                          (file-name-nondirectory
                           (directory-file-name parent)))))
        (if (member bucket rg/trace-feedback--buckets)
            (setq found dir)
          (setq dir (and parent
                         (not (equal parent dir))
                         parent)))))
    (or found (user-error "Current file is not inside a trace packet"))))

(cl-defun rg/trace-feedback-template
    (&key session-id title model severity category horizon turn domain language)
  "Return a feedback.org template from the supplied form fields."
  (format
   (concat "#+TITLE: %s feedback :: %s\n"
           "#+FILETAGS: :xai:trace_analysis:v2:feedback:\n"
           "#+DATE: %s\n"
           "#+DESCRIPTION: Trace Analysis V2 feedback packet.\n"
           "#+STATUS: drafted\n\n"
           "* Session ID\n%s\n"
           "* Model\n%s\n"
           "* Severity\n%s\n"
           "* Category\n%s\n"
           "* Task Horizon\n%s\n"
           "* Turn\n%s\n"
           "* Domain\n%s\n"
           "* Language\n%s\n"
           "* Test Cases\n\n"
           "* Issue\n"
           ">>> What the model did:\n\n"
           ">>> Where you see it:\n\n"
           ">>> Why it did it:\n\n"
           ">>> What it should have done:\n\n"
           ">>> The pattern:\n\n"
           "* Status\ndrafted\n")
   model title (format-time-string "%Y-%m-%d") session-id model severity
   category horizon turn domain language))

(defun rg/trace-feedback--xait-command (&rest args)
  "Return the xait command list for ARGS."
  (cons (or (executable-find rg/trace-feedback-xait-executable)
            rg/trace-feedback-xait-executable)
        args))

(defun rg/trace-feedback--show-output (name output)
  "Display OUTPUT in a special buffer named NAME."
  (let ((buffer (get-buffer-create name)))
    (with-current-buffer buffer
      (let ((inhibit-read-only t))
        (erase-buffer)
        (insert output)
        (goto-char (point-min))
        (special-mode)))
    (display-buffer buffer)
    buffer))

(defun rg/trace-feedback--call-xait (&rest args)
  "Run xait with ARGS and return its output.

Signal a user error and display the output when xait exits nonzero."
  (with-temp-buffer
    (let* ((command (rg/trace-feedback--xait-command))
           (status (apply #'process-file (car command) nil t nil args))
           (output (buffer-string)))
      (unless (and (integerp status) (zerop status))
        (rg/trace-feedback--show-output "*xait trace error*" output)
        (user-error "xait exited with status %s" status))
      output)))

(defun rg/trace-feedback--start-backfill (session-id packet)
  "Start xait backfill for SESSION-ID and PACKET."
  (let* ((buffer (get-buffer-create
                  (format "*xait backfill %s*"
                          (file-name-nondirectory
                           (directory-file-name packet)))))
         (command (apply #'rg/trace-feedback--xait-command
                         (list "trace" "backfill" session-id packet))))
    (with-current-buffer buffer
      (let ((inhibit-read-only t))
        (erase-buffer)))
    (make-process
     :name (format "xait-backfill-%s" session-id)
     :buffer buffer
     :command command
     :noquery t
     :sentinel
     (lambda (process _event)
       (when (memq (process-status process) '(exit signal))
         (with-current-buffer (process-buffer process)
           (goto-char (point-max))
           (insert (format "\nProcess exited: %s\n"
                           (process-exit-status process)))
           (special-mode)))))
    (display-buffer buffer)))

(cl-defun rg/trace-feedback-create
    (&key session-id slug title model severity category horizon turn domain language)
  "Create a feedback packet and start its trace backfill."
  (let* ((packet (file-name-as-directory
                  (expand-file-name
                   slug (expand-file-name "tbd" (rg/trace-feedback--tasks-root)))))
         (feedback (expand-file-name "feedback.org" packet)))
    (when (file-exists-p packet)
      (user-error "Trace packet already exists: %s" packet))
    (make-directory packet t)
    (write-region
     (rg/trace-feedback-template
      :session-id session-id :title title :model model :severity severity
      :category category :horizon horizon :turn turn :domain domain
      :language language)
     nil feedback nil 'silent)
    (rg/trace-feedback--start-backfill session-id packet)
    packet))

(defun rg/trace-feedback--slugify (text)
  "Return a lowercase dash-separated slug for TEXT."
  (let ((slug (downcase (replace-regexp-in-string "[^[:alnum:]]+" "-" text))))
    (string-trim slug "-+" "-+")))

(defun rg/trace-feedback-new ()
  "Prompt for fields, create a feedback packet, and visit feedback.org."
  (interactive)
  (let* ((session-id (read-string "Session ID: "))
         (title (read-string "Short finding title: "))
         (default-slug
          (format "%s-stickynote-%s"
                  (format-time-string "%Y-%m-%d")
                  (rg/trace-feedback--slugify title)))
         (slug (read-string "Packet slug: " default-slug))
         (severity (completing-read "Severity: " '("Major" "Minor") nil t))
         (category (read-string "Categories: "))
         (horizon (completing-read "Task horizon: "
                                   '("Short" "Long" "Autonomous") nil t))
         (turn (read-number "Form turn: "))
         (domain (completing-read
                  "Domain: "
                  '("Firmware / embedded" "Devops / GitHub" "General-SWE"
                    "Exploratory / new" "ML / Data" "Web / Vibe") nil t))
         (language (read-string "Language: "))
         (model (concat "v9-" (or rg/trace-feedback-default-model
                                  (user-error "Set the default trace model"))))
         (packet (rg/trace-feedback-create
                  :session-id session-id :slug slug :title title :model model
                  :severity severity :category category :horizon horizon
                  :turn turn :domain domain :language language)))
    (find-file (expand-file-name "feedback.org" packet))))

(defun rg/trace-feedback-lint-export-packet (packet)
  "Lint and export PACKET, returning its feedback.txt path."
  (rg/trace-feedback--call-xait "trace" "lint" packet)
  (rg/trace-feedback--call-xait "trace" "export" packet)
  (expand-file-name "feedback.txt" packet))

(defun rg/trace-feedback-lint-export ()
  "Save, lint, export, visit, and copy the current feedback packet."
  (interactive)
  (when (buffer-modified-p)
    (save-buffer))
  (let* ((packet (rg/trace-feedback-packet-dir))
         (output (rg/trace-feedback-lint-export-packet packet)))
    (unless (file-exists-p output)
      (user-error "xait did not create %s" output))
    (find-file output)
    (kill-new (buffer-substring-no-properties (point-min) (point-max)))
    (message "Exported feedback copied to the kill ring")))

(defun rg/trace-feedback--moved-packet (packet bucket)
  "Return the destination for PACKET under BUCKET."
  (expand-file-name
   (file-name-nondirectory (directory-file-name packet))
   (expand-file-name bucket (rg/trace-feedback--tasks-root))))

(defun rg/trace-feedback-submit-packet (packet)
  "Stamp PACKET submitted and return its destination directory."
  (let ((slug (file-name-nondirectory (directory-file-name packet))))
    (rg/trace-feedback--call-xait "db" "trace" "submit" slug)
    (rg/trace-feedback--moved-packet packet "submitted")))

(defun rg/trace-feedback--visit-moved-file (old-file destination)
  "Visit OLD-FILE's basename under DESTINATION."
  (let ((new-file (expand-file-name (file-name-nondirectory old-file)
                                    destination)))
    (if (file-exists-p new-file)
        (find-file new-file)
      (find-file (expand-file-name "feedback.org" destination)))))

(defun rg/trace-feedback-submit ()
  "Stamp the current packet after its Slack form was submitted."
  (interactive)
  (unless (y-or-n-p "Slack form already submitted? ")
    (user-error "Submit the Slack form before stamping the packet"))
  (when (buffer-modified-p)
    (save-buffer))
  (let* ((old-file (or buffer-file-name
                       (user-error "Current buffer has no file")))
         (packet (rg/trace-feedback-packet-dir old-file))
         (destination (rg/trace-feedback-submit-packet packet)))
    (rg/trace-feedback--visit-moved-file old-file destination)))

(defun rg/trace-feedback--record-disposition (reason)
  "Record REASON in the current feedback.org buffer."
  (save-excursion
    (goto-char (point-min))
    (when (re-search-forward "^\\* Internal disposition\n" nil t)
      (let ((start (match-beginning 0)))
        (if (re-search-forward "^\\* " nil t)
            (delete-region start (match-beginning 0))
          (delete-region start (point-max)))))
    (goto-char (point-min))
    (unless (re-search-forward "^\\* Status\n" nil t)
      (user-error "feedback.org has no Status heading"))
    (goto-char (match-beginning 0))
    (insert "* Internal disposition\n" reason "\n"))
  (goto-char (point-min)))

(defun rg/trace-feedback-mark-packet-not-submitted (packet reason)
  "Record REASON and mark PACKET clean, returning its destination."
  (let* ((slug (file-name-nondirectory (directory-file-name packet)))
         (feedback (expand-file-name "feedback.org" packet)))
    (with-temp-buffer
      (insert-file-contents feedback)
      (rg/trace-feedback--record-disposition reason)
      (write-region (point-min) (point-max) feedback nil 'silent))
    (rg/trace-feedback--call-xait "db" "trace" "mark" slug "clean")
    (rg/trace-feedback--moved-packet packet "noResult")))

(defun rg/trace-feedback-mark-not-submitted (reason)
  "Mark the current packet trivial or not submitted with REASON."
  (interactive (list (read-string "Reason not submitted: ")))
  (when (string-empty-p (string-trim reason))
    (user-error "A disposition reason is required"))
  (when (buffer-modified-p)
    (save-buffer))
  (let* ((old-file (or buffer-file-name
                       (user-error "Current buffer has no file")))
         (packet (rg/trace-feedback-packet-dir old-file))
         (destination
          (rg/trace-feedback-mark-packet-not-submitted packet reason)))
    (rg/trace-feedback--visit-moved-file old-file destination)))

(defvar rg-trace-feedback-rank-mode-map
  (let ((map (make-sparse-keymap)))
    (set-keymap-parent map special-mode-map)
    (define-key map (kbd "g") #'rg/trace-feedback-rank)
    (define-key map (kbd "q") #'quit-window)
    (define-key map (kbd "/") #'rg/trace-feedback-rank-search)
    map)
  "Keymap for `rg-trace-feedback-rank-mode'.")

(define-derived-mode rg-trace-feedback-rank-mode special-mode "xait-rank"
  "Major mode for xait trace queue output.")

(defun rg/trace-feedback-rank-search ()
  "Search the rank buffer with Consult when available."
  (interactive)
  (if (fboundp 'consult-line)
      (call-interactively #'consult-line)
    (call-interactively #'isearch-forward)))

(defun rg/trace-feedback--queue-buffer (name args)
  "Show xait ARGS in a read-only buffer called NAME."
  (let ((output (apply #'rg/trace-feedback--call-xait args))
        (buffer (get-buffer-create name)))
    (with-current-buffer buffer
      (let ((inhibit-read-only t))
        (erase-buffer)
        (insert output)
        (goto-char (point-min))
        (rg-trace-feedback-rank-mode)))
    (display-buffer buffer)
    buffer))

(defun rg/trace-feedback-rank ()
  "Open the ranked trace feedback queue."
  (interactive)
  (rg/trace-feedback--queue-buffer
   "*xait trace rank*"
   (list "db" "trace" "rank" "--model"
         (or rg/trace-feedback-default-model
             (user-error "Set the default trace model"))
         "--spread")))

(defun rg/trace-feedback-status ()
  "Open the xait trace status output."
  (interactive)
  (rg/trace-feedback--queue-buffer
   "*xait trace status*" '("db" "trace" "status")))

(defun rg/trace-feedback--ensure-transient ()
  "Define the trace feedback Transient menu when available."
  (unless (featurep 'transient)
    (require 'transient nil t))
  (when (and (featurep 'transient)
             (not (fboundp 'rg/trace-feedback--transient)))
    (eval
     '(transient-define-prefix rg/trace-feedback--transient ()
        "xait Trace Analysis V2 feedback."
        [["Packet"
          ("n" "New" rg/trace-feedback-new)
          ("l" "Lint and export" rg/trace-feedback-lint-export)]
         ["Disposition"
          ("s" "Stamp submitted" rg/trace-feedback-submit)
          ("c" "Mark trivial / not submitted"
           rg/trace-feedback-mark-not-submitted)]
         ["Queue"
          ("r" "Ranked queue" rg/trace-feedback-rank)
          ("t" "Status" rg/trace-feedback-status)]]))))

(defun rg/trace-feedback-dispatch ()
  "Open the xait trace feedback command menu."
  (interactive)
  (rg/trace-feedback--ensure-transient)
  (if (fboundp 'rg/trace-feedback--transient)
      (call-interactively #'rg/trace-feedback--transient)
    (call-interactively
     (intern
      (completing-read
       "Trace command: "
       '("rg/trace-feedback-new" "rg/trace-feedback-lint-export"
         "rg/trace-feedback-submit" "rg/trace-feedback-mark-not-submitted"
         "rg/trace-feedback-rank" "rg/trace-feedback-status")
       nil t)))))

(defun rg/trace-feedback-install-keybindings ()
  "Install Doom leader bindings using the configured prefix."
  (unless rg/trace-feedback-key-prefix
    (user-error "Set rg/trace-feedback-key-prefix in the private settings"))
  (unless (fboundp 'map!)
    (user-error "Doom map! is unavailable"))
  (eval
   `(map! :leader
          :prefix (,rg/trace-feedback-key-prefix . "xait trace")
          "x" #'rg/trace-feedback-dispatch
          "n" #'rg/trace-feedback-new
          "l" #'rg/trace-feedback-lint-export
          "s" #'rg/trace-feedback-submit
          "c" #'rg/trace-feedback-mark-not-submitted
          "r" #'rg/trace-feedback-rank
          "t" #'rg/trace-feedback-status)))

(defun rg/trace-feedback-load-private-settings ()
  "Load the nimvaulted private settings file when present."
  (interactive)
  (when (and rg/trace-feedback-private-settings-file
             (file-readable-p rg/trace-feedback-private-settings-file))
    (load rg/trace-feedback-private-settings-file nil 'nomessage)))

(provide 'rg-trace-feedback)
;;; rg-trace-feedback.el ends here
