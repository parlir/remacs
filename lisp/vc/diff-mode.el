;; Copyright (C) 1998-2012 Free Software Foundation, Inc.
;; Some efforts were spent to have it somewhat compatible with XEmacs's
(eval-when-compile (require 'cl-lib))
  '(("n" . diff-hunk-next)
    ("}" . diff-file-next)	; From compilation-minor-mode.
    ("o" . diff-goto-source)	; other-window
    ("R" . diff-reverse-direction)
    ("/" . diff-undo)
    ([remap undo] . diff-undo))
               (dolist (key '("A" "r" "R" "g" "q" "W" "z"))
    ["Remove trailing whitespace" diff-remove-trailing-whitespace
     :help "Remove trailing whitespace problems introduced by the diff"]
  "Toggle automatic diff hunk highlighting (Diff Auto Refine mode).
With a prefix argument ARG, enable Diff Auto Refine mode if ARG
is positive, and disable it otherwise.  If called from Lisp,
enable the mode if ARG is omitted or nil.

Diff Auto Refine mode is a buffer-local minor mode used with
`diff-mode'.  When enabled, Emacs automatically highlights
changes in detail as the user visits hunks.  When transitioning
from disabled to enabled, it tries to refine the current hunk, as
well."
    (condition-case-unless-debug nil (diff-refine-hunk) (error nil))))
    (((class color))
    (((class color))
  '((default
     :inherit diff-changed)
    (((class color) (min-colors 88) (background light))
     :background "#ffdddd")
    (((class color) (min-colors 88) (background dark))
     :background "#553333")
    (((class color))
     :foreground "red"))
  '((default
     :inherit diff-changed)
    (((class color) (min-colors 88) (background light))
     :background "#ddffdd")
    (((class color) (min-colors 88) (background dark))
     :background "#335533")
    (((class color))
     :foreground "green"))
    (((class color))
     :foreground "yellow"))
(defvar diff-use-changed-face (and (face-differs-from-default-p diff-changed-face)
				   (not (face-equal diff-changed-face diff-added-face))
				   (not (face-equal diff-changed-face diff-removed-face)))
  "If non-nil, use the face `diff-changed' for changed lines in context diffs.
Otherwise, use the face `diff-removed' for removed lines,
and the face `diff-added' for added lines.")

     (1 (if diff-use-changed-face
	    diff-indicator-changed-face
	  ;; Otherwise, search for `diff-context-mid-hunk-header-re' and
	  ;; if the line of context diff is above, use `diff-removed-face';
	  ;; if below, use `diff-added-face'.
	  (save-match-data
	    (let ((limit (save-excursion (diff-beginning-of-hunk))))
	      (if (save-excursion (re-search-backward diff-context-mid-hunk-header-re limit t))
		  diff-indicator-added-face
		diff-indicator-removed-face)))))
     (2 (if diff-use-changed-face
	    diff-changed-face
	  ;; Otherwise, use the same method as above.
	  (save-match-data
	    (let ((limit (save-excursion (diff-beginning-of-hunk))))
	      (if (save-excursion (re-search-backward diff-context-mid-hunk-header-re limit t))
		  diff-added-face
		diff-removed-face))))))
    ("^\\(?:Index\\|revno\\): \\(.+\\).*\n"
  "Advance to the end of the current hunk, and return its position."
                      (pcase style
                        (`unified
                         (concat (if diff-valid-unified-empty-line
                                     "^[^-+# \\\n]\\|" "^[^-+# \\]\\|")
                                 ;; A `unified' header is ambiguous.
                                 diff-file-header-re))
                        (`context "^[^-+#! \\]")
                        (`normal "^[^<>#\\]")
                        (_ "^[^-+#!<> \\]"))
  "Move back to the previous hunk beginning, and return its position.
If point is in a file header rather than a hunk, advance to the
next hunk if TRY-HARDER is non-nil; otherwise signal an error."
  (if (looking-at diff-hunk-header-re)
      (point)
       (unless try-harder
	 (error "Can't find the beginning of the hunk"))
       (diff-beginning-of-file-and-junk)
       (diff-hunk-next)
       (point)))))
     (condition-case-unless-debug nil (diff-refine-hunk) (error nil))))
 diff-file diff-file-header-re "file" diff-end-of-file)

(defun diff-bounds-of-hunk ()
  "Return the bounds of the diff hunk at point.
The return value is a list (BEG END), which are the hunk's start
and end positions.  Signal an error if no hunk is found.  If
point is in a file header, return the bounds of the next hunk."
  (save-excursion
    (let ((pos (point))
	  (beg (diff-beginning-of-hunk t))
	  (end (diff-end-of-hunk)))
      (cond ((>= end pos)
	     (list beg end))
	    ;; If this hunk ends above POS, consider the next hunk.
	    ((re-search-forward diff-hunk-header-re nil t)
	     (list (match-beginning 0) (diff-end-of-hunk)))
	    (t (error "No hunk found"))))))

(defun diff-bounds-of-file ()
  "Return the bounds of the file segment at point.
The return value is a list (BEG END), which are the segment's
start and end positions."
  (save-excursion
    (let ((pos (point))
	  (beg (progn (diff-beginning-of-file-and-junk)
		      (point))))
      (diff-end-of-file)
      ;; bzr puts a newline after the last hunk.
      (while (looking-at "^\n")
	(forward-char 1))
      (if (> pos (point))
	  (error "Not inside a file diff"))
      (list beg (point)))))
  (apply 'narrow-to-region
	 (if arg (diff-bounds-of-file) (diff-bounds-of-hunk)))
  (set (make-local-variable 'diff-narrowed-to) (if arg 'file 'hunk)))
  "Kill the hunk at point."
  (let* ((hunk-bounds (diff-bounds-of-hunk))
	 (file-bounds (ignore-errors (diff-bounds-of-file)))
	 ;; If the current hunk is the only one for its file, kill the
	 ;; file header too.
	 (bounds (if (and file-bounds
			  (progn (goto-char (car file-bounds))
				 (= (progn (diff-hunk-next) (point))
				    (car hunk-bounds)))
			  (progn (goto-char (cadr hunk-bounds))
				 ;; bzr puts a newline after the last hunk.
				 (while (looking-at "^\n")
				   (forward-char 1))
				 (= (point) (cadr file-bounds))))
		     file-bounds
		   hunk-bounds))
    (apply 'kill-region bounds)
    (goto-char (car bounds))))
  "diff \\|index \\|\\(?:deleted file\\|new\\(?: file\\)?\\|old\\) mode\\|=== modified file")
  (let ((inhibit-read-only t))
    (apply 'kill-region (diff-bounds-of-file))))
      (while (re-search-forward re end t) (cl-incf n))
	(start (diff-beginning-of-hunk)))
       (cl-dolist (rf diff-remembered-files-alist)
	   (if (and newfile (file-exists-p newfile)) (cl-return newfile))))
       (cl-do* ((files fs (delq nil (mapcar 'diff-filename-drop-dir files)))
                (file nil nil))
		(setq file (cl-do* ((files files (cdr files))
                                    (file (car files) (car files)))
         (let ((file (expand-file-name (or (car fs) ""))))
	   (setq file
		 (read-file-name (format "Use file %s: " file)
				 (file-name-directory file) file t
				 (file-name-nondirectory file)))
			(pcase (char-after)
                                  (progn (forward-char 1)
                                         (insert " "))
                                (delete-char 1)
                                (insert "! "))
                              (backward-char 2))
                                                     (= (char-after) ?+))
                                 (delete-region (point) last-pt)
                                 (setq modif t)))
                          (?\n (insert "  ") (setq modif nil)
                               (backward-char 2))
			  (_ (setq modif nil))))))
		      (if (save-excursion (re-search-forward "^\\+.*\n-"
                                                             nil t))
			(pcase (char-after)
                                  (progn (forward-char 1)
                                         (insert " "))
                                (delete-char 1)
                                (insert "! "))
                              (backward-char 2))
                                                     (not (eobp)))
                                 (setq delete t) (setq modif t)))
			  (_ (setq modif nil)))
                    (pcase (char-after)
                      (?\s              ;merge with the other half of the chunk
                         (pcase (char-after pt2)
                           ((or ?! ?+)
                                    (prog1
                                        (buffer-substring (+ pt2 2) endline2)
                           (_ (setq reversible nil)
                      (_ (setq reversible nil) (forward-line 1))))
	      (while (pcase (setq c (char-after))
                           (delete-char 1) (insert "+") t)
                           (delete-char 1) (insert "-") t)
		       ((or ?\\ ?#) t)
		       (_ (when (and first last (< first last))
	      (pcase (char-after)
		(?\s (cl-incf space))
		(?+ (cl-incf plus))
		(?- (cl-incf minus))
		(?! (cl-incf bang))
		((or ?\\ ?#) nil)
		(_  (setq space 0 plus 0 minus 0 bang 0)))
  (diff-setup-whitespace)
  "Toggle Diff minor mode.
With a prefix argument ARG, enable Diff minor mode if ARG is
positive, and disable it otherwise.  If called from Lisp, enable
the mode if ARG is omitted or nil.

(defun diff-setup-whitespace ()
  "Set up Whitespace mode variables for the current Diff mode buffer.
This sets `whitespace-style' and `whitespace-trailing-regexp' so
that Whitespace mode shows trailing whitespace problems on the
modified lines of the diff."
  (set (make-local-variable 'whitespace-style) '(face trailing))
  (let ((style (save-excursion
		 (goto-char (point-min))
		 (when (re-search-forward diff-hunk-header-re nil t)
		   (goto-char (match-beginning 0))
		   (diff-hunk-style)))))
    (set (make-local-variable 'whitespace-trailing-regexp)
	 (if (eq style 'context)
	     "^[-\+!] .*?\\([\t ]+\\)$"
	   "^[-\+!<>].*?\\([\t ]+\\)$"))))

          (cl-decf count) t)
                (pcase (char-after)
                  (?\s (cl-decf before) (cl-decf after) t)
                     (cl-decf before) t))
                  (?+ (cl-decf after) t)
                  (_
                     (cl-decf before) (cl-decf after) t)
	   (char-offset (- (point) (diff-beginning-of-hunk t)))
  (pcase-let ((`(,buf ,line-offset ,pos ,old ,new ,switched)
               ;; Sometimes we'd like to have the following behavior: if
               ;; REVERSE go to the new file, otherwise go to the old.
               ;; But that means that by default we use the old file, which is
               ;; the opposite of the default for diff-goto-source, and is thus
               ;; confusing.  Also when you don't know about it it's
               ;; pretty surprising.
               ;; TODO: make it possible to ask explicitly for this behavior.
               ;;
               ;; This is duplicated in diff-test-hunk.
               (diff-find-source-location nil reverse)))
  (pcase-let ((`(,buf ,line-offset ,pos ,src ,_dst ,switched)
               (diff-find-source-location nil reverse)))
    (pcase-let ((`(,buf ,line-offset ,pos ,src ,_dst ,switched)
                 (diff-find-source-location other-file rev)))
    (pcase-let ((`(,buf ,_line-offset ,pos ,src ,dst ,switched)
                 (ignore-errors         ;Signals errors in place of prompting.
                   ;; Use `noprompt' since this is used in which-func-mode
                   ;; and such.
                   (diff-find-source-location nil nil 'noprompt))))
  (let* ((char-offset (- (point) (diff-beginning-of-hunk t)))
	 (opts (pcase (char-after) (?@ "-bu") (?* "-bc") (_ "-b")))
	      (pcase status
		(0 nil)                 ;Nothing to reformat.
                   ;; Remove the file-header.
                   (when (re-search-forward diff-hunk-header-re nil t)
                     (delete-region (point-min) (match-beginning 0))))
		(_ (goto-char (point-max))
     :background "#ffff55")
     :background "#aaaa22")
    (t :inverse-video t))
(defface diff-refine-removed
  '((default
     :inherit diff-refine-change)
    (((class color) (min-colors 88) (background light))
     :background "#ffaaaa")
    (((class color) (min-colors 88) (background dark))
     :background "#aa2222"))
  "Face used for removed characters shown by `diff-refine-hunk'."
  :group 'diff-mode
  :version "24.3")

(defface diff-refine-added
  '((default
     :inherit diff-refine-change)
    (((class color) (min-colors 88) (background light))
     :background "#aaffaa")
    (((class color) (min-colors 88) (background dark))
     :background "#22aa22"))
  "Face used for added characters shown by `diff-refine-hunk'."
  :group 'diff-mode
  :version "24.3")

                  (beg1 end1 beg2 end2 props-c &optional preproc props-r props-a))
    (diff-beginning-of-hunk t)
           (props-c '((diff-mode . fine) (face diff-refine-change)))
           (props-r '((diff-mode . fine) (face diff-refine-removed)))
           (props-a '((diff-mode . fine) (face diff-refine-added)))
      (pcase style
        (`unified
                                nil 'diff-refine-preproc props-r props-a)))
        (`context
                                  (if diff-use-changed-face props-c)
                                  'diff-refine-preproc
                                  (unless diff-use-changed-face props-r)
                                  (unless diff-use-changed-face props-a)))))
        (_ ;; Normal diffs.
                                  nil 'diff-refine-preproc props-r props-a))))))))
(defun diff-undo (&optional arg)
  "Perform `undo', ignoring the buffer's read-only status."
  (interactive "P")
  (let ((inhibit-read-only t))
    (undo arg)))
(defun diff-remove-trailing-whitespace ()
  "When on a buffer that contains a diff, inspects the
differences and removes trailing whitespace (spaces, tabs) from
the lines modified or introduced by this diff. Shows a message
with the name of the altered buffers, which are unsaved.  If a
file referenced on the diff has no buffer and needs to be fixed,
a buffer visiting that file is created."
  (interactive)
  ;; We assume that the diff header has no trailing whitespace.
  (let ((modified-buffers nil))
    (save-excursion
      (goto-char (point-min))
      (while (re-search-forward "^[+!>].*[ \t]+$" (point-max) t)
        (pcase-let ((`(,buf ,line-offset ,pos ,src ,_dst ,_switched)
                     (diff-find-source-location t t)))
          (when line-offset
            (with-current-buffer buf
              (save-excursion
                (goto-char (+ (car pos) (cdr src)))
                (beginning-of-line)
                (when (re-search-forward "\\([ \t]+\\)$" (line-end-position) t)
                  (unless (memq buf modified-buffers)
                    (push buf modified-buffers))
                  (replace-match ""))))))))
    (if modified-buffers
        (message "Deleted new trailing whitespace from: %s"
                 (mapconcat (lambda (buf) (concat "`" (buffer-name buf) "'"))
                            modified-buffers " "))
      (message "No trailing whitespace fixes needed."))))
