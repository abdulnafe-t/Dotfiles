;;; hippie-capf.el --- completion-at-point-functions based on hippie-expand  -*- lexical-binding: t; -*-

;; Copyright (C) 2026  Abdulnafé Toulaïmat

;; Author: Abdulnafé Toulaïmat <abdulnafe.toulaimat@gmail.com>
;; Keywords: abbrev,convenience

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;;

;;; Code:

(require 'hippie-exp)

(defgroup a-t/hippie-capf nil
  "Complete the word at point using `hippie-expand'."
  :group 'hippie-expand)

(defcustom a-t/hippie-capf-try-functions
  '(try-expand-all-abbrevs
    try-expand-dabbrev
    try-expand-dabbrev-visible
    try-expand-dabbrev-from-kill
    try-expand-dabbrev-all-buffers
    try-complete-lisp-symbol-partially
    try-complete-lisp-symbol)
  "Try-functions whose candidates `a-t/hippie-capf' offers."

  :type '(repeat function))

(defcustom a-t/hippie-capf-min-length 2
  "Minimum ABBREV length before candidates are collected."
  :type 'integer)

(defcustom a-t/file-capf-try-functions
  '(try-complete-file-name-partially
    try-complete-file-name)
  "Try-functions whose candidates `a-t/file-capf' offers."
  :type '(repeat function))

(defun a-t/hippie-capf--collect (abbrev end try-list)
  "Collect all expansions of ABBREV ending at END.
Each try-function in TRY-LIST is called in turn, and the substituted region
is harvested after every successful call. The buffer is left unchanged.

Modification hooks and undo are suspended during collection."
  (save-excursion
    (goto-char end)
    (let ((he-tried-table (list abbrev))
          (inhibit-modification-hooks t)
          (buffer-undo-list t)
          (results))
      (unwind-protect
          (dolist (try try-list)
            (let ((old nil))
              (while (funcall try old)
                (push (buffer-substring-no-properties he-string-beg
                                                      he-string-end)
                      results)
                (setq old t))))
        (when (eq (marker-buffer he-string-beg) (current-buffer))
          (he-reset-string)))
      (nreverse results))))

;;;###autoload
(defun a-t/hippie-capf ()
  "Hippie-expand completion function for `completion-at-point-functions'."
  (let* ((beg (he-dabbrev-beg))
	 (end (point))
	 (abbrev (buffer-substring-no-properties beg end)))
    (when (>= (length abbrev) a-t/hippie-capf-min-length)
      (let ((collection 'uninitialized))
        (list beg end
              (lambda (s p a)
                (if (eq a 'metadata)
                    '(metadata (cycle-sort-function . identity)
                               (category . hippie))
		  (when (eq collection 'uninitialized)
		    (setq collection (a-t/hippie-capf--collect
                                      abbrev end a-t/hippie-capf-try-functions)))
                  (complete-with-action a collection s p))))))))

;;;###autoload
(defun a-t/file-capf ()
  "Hippie-expand file-name completion for `completion-at-point-functions'."
  (let* ((beg (he-file-name-beg))
	 (end (point))
	 (abbrev (buffer-substring-no-properties beg end)))
    (when (and (>= (length abbrev) a-t/hippie-capf-min-length)
	       (file-name-directory abbrev))
      (let ((collection 'uninitialized))
        (list beg end
              (lambda (s p a)
                (if (eq a 'metadata)
                    '(metadata (cycle-sort-function . identity)
                               (category . file))
		  (when (eq collection 'uninitialized)
		    (setq collection (a-t/hippie-capf--collect
                                      abbrev end a-t/file-capf-try-functions)))
                  (complete-with-action a collection s p))))))))

(provide 'hippie-capf)
;;; hippie-capf ends here
