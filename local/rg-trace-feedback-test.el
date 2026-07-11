;;; rg-trace-feedback-test.el --- Tests for xait trace feedback helpers -*- lexical-binding: t; -*-

(require 'cl-lib)
(require 'ert)
(require 'rg-trace-feedback)

(defmacro rg-trace-feedback-test--with-root (&rest body)
  "Run BODY with an isolated trace-analysis root."
  (declare (indent 0) (debug t))
  `(let* ((root (make-temp-file "rg-trace-feedback-" t))
          (rg/trace-feedback-vault-root root)
          (rg/trace-feedback-default-model "stickynote"))
     (unwind-protect
         (progn
           (make-directory (expand-file-name "tasks/tbd" root) t)
           (make-directory (expand-file-name "tasks/submitted" root) t)
           (make-directory (expand-file-name "tasks/noResult" root) t)
           ,@body)
       (delete-directory root t))))

(ert-deftest rg-trace-feedback-packet-dir-finds-current-packet ()
  (rg-trace-feedback-test--with-root
    (let* ((packet (expand-file-name "tasks/tbd/example" root))
           (nested (expand-file-name "signals/event.json" packet)))
      (make-directory (file-name-directory nested) t)
      (write-region "{}" nil nested nil 'silent)
      (should (equal (file-name-as-directory packet)
                     (rg/trace-feedback-packet-dir nested))))))

(ert-deftest rg-trace-feedback-packet-dir-rejects-files-outside-root ()
  (rg-trace-feedback-test--with-root
    (let ((outside (make-temp-file "rg-trace-feedback-outside-")))
      (unwind-protect
          (should-error (rg/trace-feedback-packet-dir outside)
                        :type 'user-error)
        (delete-file outside)))))

(ert-deftest rg-trace-feedback-template-contains-form-fields ()
  (let ((text (rg/trace-feedback-template
               :session-id "019f-test"
               :title "Parallel poll loop"
               :model "v9-stickynote"
               :severity "Major"
               :category "Tool Call Inefficiencies"
               :horizon "Long"
               :turn 7
               :domain "Devops / GitHub"
               :language "Shell")))
    (dolist (fragment '("#+TITLE: v9-stickynote feedback :: Parallel poll loop"
                        "* Session ID\n019f-test"
                        "* Turn\n7"
                        "* Issue\n>>> What the model did:"
                        "* Status\ndrafted"))
      (should (string-match-p (regexp-quote fragment) text)))))

(ert-deftest rg-trace-feedback-create-writes-packet-and-starts-backfill ()
  (rg-trace-feedback-test--with-root
    (let (started)
      (cl-letf (((symbol-function 'rg/trace-feedback--start-backfill)
                 (lambda (session-id packet)
                   (setq started (list session-id packet)))))
        (let* ((packet (rg/trace-feedback-create
                        :session-id "019f-test"
                        :slug "2026-07-11-stickynote-test"
                        :title "Test finding"
                        :model "v9-stickynote"
                        :severity "Major"
                        :category "Hallucination"
                        :horizon "Long"
                        :turn 3
                        :domain "General-SWE"
                        :language "Rust"))
               (feedback (expand-file-name "feedback.org" packet)))
          (should (file-exists-p feedback))
          (should (equal started (list "019f-test" packet))))))))

(ert-deftest rg-trace-feedback-create-refuses-existing-packet ()
  (rg-trace-feedback-test--with-root
    (let ((packet (expand-file-name "tasks/tbd/existing" root)))
      (make-directory packet t)
      (should-error
       (rg/trace-feedback-create
        :session-id "019f-test" :slug "existing" :title "Existing"
        :model "v9-stickynote" :severity "Major" :category "Other"
        :horizon "Long" :turn 1 :domain "General-SWE" :language "Shell")
       :type 'user-error))))

(ert-deftest rg-trace-feedback-record-disposition-replaces-existing-section ()
  (with-temp-buffer
    (insert "* Issue\nBody\n* Internal disposition\nOld\n* Status\ndrafted\n")
    (rg/trace-feedback--record-disposition "Too small to submit")
    (rg/trace-feedback--record-disposition "Duplicate of stronger report")
    (should (= 1 (how-many "^\\* Internal disposition$" (point-min) (point-max))))
    (should (search-forward "Duplicate of stronger report" nil t))
    (should-not (search-forward "Old" nil t))))

(ert-deftest rg-trace-feedback-lint-export-runs-lint-before-export ()
  (rg-trace-feedback-test--with-root
    (let* ((packet (expand-file-name "tasks/tbd/example" root))
           calls)
      (make-directory packet t)
      (write-region "text" nil (expand-file-name "feedback.txt" packet) nil 'silent)
      (cl-letf (((symbol-function 'rg/trace-feedback--call-xait)
                 (lambda (&rest args)
                   (push args calls)
                   "ok")))
        (rg/trace-feedback-lint-export-packet packet)
        (should (equal (nreverse calls)
                       (list (list "trace" "lint" packet)
                             (list "trace" "export" packet))))))))

(ert-deftest rg-trace-feedback-submit-does-not-run-lint ()
  (rg-trace-feedback-test--with-root
    (let* ((packet (expand-file-name "tasks/tbd/example" root))
           calls)
      (make-directory packet t)
      (cl-letf (((symbol-function 'rg/trace-feedback--call-xait)
                 (lambda (&rest args)
                   (push args calls)
                   "submitted")))
        (should (equal (rg/trace-feedback-submit-packet packet)
                       (expand-file-name "tasks/submitted/example" root)))
        (should (equal calls '(("db" "trace" "submit" "example"))))))))

(ert-deftest rg-trace-feedback-mark-clean-records-reason-and-calls-xait ()
  (rg-trace-feedback-test--with-root
    (let* ((packet (expand-file-name "tasks/tbd/example" root))
           (feedback (expand-file-name "feedback.org" packet))
           calls)
      (make-directory packet t)
      (write-region "* Issue\nBody\n* Status\ndrafted\n" nil feedback nil 'silent)
      (cl-letf (((symbol-function 'rg/trace-feedback--call-xait)
                 (lambda (&rest args)
                   (push args calls)
                   "clean")))
        (should (equal
                 (rg/trace-feedback-mark-packet-not-submitted
                  packet "Duplicate of stronger report")
                 (expand-file-name "tasks/noResult/example" root)))
        (should (equal calls '(("db" "trace" "mark" "example" "clean"))))
        (should (string-match-p
                 "\\* Internal disposition\nDuplicate of stronger report"
                 (with-temp-buffer
                   (insert-file-contents feedback)
                   (buffer-string))))))))

(ert-deftest rg-trace-feedback-rank-opens-read-only-result-buffer ()
  (rg-trace-feedback-test--with-root
    (cl-letf (((symbol-function 'rg/trace-feedback--call-xait)
               (lambda (&rest args)
                 (should (equal args '("db" "trace" "rank"
                                       "--model" "stickynote" "--spread")))
                 "173 major example\n")))
      (let ((buffer (rg/trace-feedback-rank)))
        (unwind-protect
            (with-current-buffer buffer
              (should (derived-mode-p 'rg-trace-feedback-rank-mode))
              (should buffer-read-only)
              (should (string-match-p "173 major example" (buffer-string))))
          (kill-buffer buffer))))))

(ert-deftest rg-trace-feedback-monitor-filters-the-ranked-queue ()
  (rg-trace-feedback-test--with-root
    (cl-letf (((symbol-function 'rg/trace-feedback--call-xait)
               (lambda (&rest args)
                 (should
                  (equal args
                         '("db" "trace" "rank" "--model" "stickynote"
                           "--spread" "--category"
                           "Monitor / Subagent Task / Background Task Issues")))
                 "monitor result\n")))
      (let ((buffer (rg/trace-feedback-monitor)))
        (unwind-protect
            (with-current-buffer buffer
              (should (equal rg/trace-feedback--queue-args
                             '("db" "trace" "rank" "--model" "stickynote"
                               "--spread" "--category"
                               "Monitor / Subagent Task / Background Task Issues"))))
          (kill-buffer buffer))))))

(ert-deftest rg-trace-feedback-refresh-preserves-the-active-filter ()
  (let ((calls nil)
        (args '("db" "trace" "rank" "--category" "monitor")))
    (cl-letf (((symbol-function 'rg/trace-feedback--call-xait)
               (lambda (&rest actual)
                 (push actual calls)
                 "filtered result\n")))
      (let ((buffer (rg/trace-feedback--queue-buffer "*xait filtered test*" args)))
        (unwind-protect
            (with-current-buffer buffer
              (rg/trace-feedback-refresh)
              (should (equal (nreverse calls) (list args args))))
          (kill-buffer buffer))))))

(provide 'rg-trace-feedback-test)
;;; rg-trace-feedback-test.el ends here
