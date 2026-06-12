;;; mode-line-config.el --- A minimalist mode line with centered buffer id  -*- lexical-binding: t; -*-

;; Copyright (C) 2026  Abdulnafé Toulaïmat

;; Author: Abdulnafé Toulaïmat <abdulnafe.toulaimat@gmail.com>
;; Keywords: lisp, mode-line

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

;; This is a short script defining a custom mode line that tries to stay as close to the
;; default mode line as possible. It diverges from the default by defining a construct for
;; centering content, ‘mode-line-format-center’, which see. By default, the centered
;; content is made up of a major-mode-appropriate icon provided by ‘nerd-icons’, the
;; current project’s name (‘project-mode-line-format’), and the current buffer’s
;; identification (‘mode-line-buffer-identification’). Eglot, VC, and major/minor mode
;; lighters are right aligned. Was originally based on
;; https://emacs.stackexchange.com/a/16658

;;; Code:

;; (declare-function line-count-global-mode "line-count.el")

(defgroup a-t/mode-line nil
  "Custom mode line with centered content."
  :group 'mode-line)

(defun a-t/vc-mode-line-advice (file &optional backend)
  "Replace the prefix of the VC mode line lighter with an icon. Apply a
face based on VC file state.

FILE is the file being checked for version control.

BACKEND is the backend to check for version control. Defaults to git."
  (when (and file
             (vc-registered file))
    (let* ((state (vc-state file))
           (backend (or (symbol-name backend) "Git"))
           (face (cond ((eq state 'up-to-date) 'vc-up-to-date-state)
                       ((stringp state) 'vc-locked-state)
                       ((eq state 'added) 'vc-locally-added-state)
                       ((eq state 'conflict) 'vc-conflict-state)
                       ((eq state 'removed) 'vc-removed-state)
                       ((eq state 'missing) 'vc-missing-state)
                       ((eq state 'ignored) 'vc-ignored-state)
                       (t 'vc-edited-state)))
           (lighter-with-logo (propertize
                               (replace-regexp-in-string
                                (concat "^ " backend "[-:!?@]") " " vc-mode)
                               'face face)))
      (setq vc-mode lighter-with-logo))))

(advice-add 'vc-mode-line :after #'a-t/vc-mode-line-advice)

(defun a-t/copy-project-directory ()
  "Copy project directory to kill-ring."
  (interactive)
  (kill-new default-directory))

(defun mode-line--format-center () ; TODO: rewrite this in C?
  "Center all following mode-line constructs, up to and excluding
‘mode-line-format-right-align’.

When the symbol ‘mode-line-format-center’ appears in ‘mode-line-format’,
return a string of one space, with a display property to make it appear
long enough to align anything after that symbol - up to and excluding
‘mode-line-format-right-align’ - to the the center of the rendered mode
line.

It is important that the symbol ‘mode-line-format-center’ be included in
‘mode-line-format’ (and not another similar construct such
as \\=`(:eval (mode-line-format-center))\\='.  This is because the symbol
‘mode-line-format-center’ is processed by ‘format-mode-line’ as a
variable."
  (let* ((rest-beg (cdr (memq 'mode-line-format-center mode-line-format)))
         (rest-end (memq 'mode-line-format-right-align rest-beg))
         (center-constructs (butlast rest-beg (length rest-end)))
         (center-constructs-str (format-mode-line center-constructs))
         (center-constructs-width (progn
                                    (add-face-text-property
                                     0 (length center-constructs-str)
                                     'mode-line t center-constructs-str)
                                    (string-pixel-width center-constructs-str))))

    (propertize " " 'display
                (if (and (display-graphic-p)
                         (not (eq mode-line-right-align-edge 'window)))
	            `(space :align-to (,(/
                                         (-
                                          mode-line-right-align-edge
                                          center-constructs-width)
                                         2)))
                  `(space :align-to (,(/
                                       (- (window-pixel-width)
                                          (window-scroll-bar-width)
                                          (window-right-divider-width)
                                          (* (+ (or (car (window-margins)) 0)
                                                (or (cdr (window-margins)) 0))
                                             (frame-char-width))
                                          (car (window-fringes))
                                          (pcase mode-line-right-align-edge
                                            ('right-margin
                                             (or (cdr (window-margins)) 0))
                                            ('right-fringe
                                             (or (cadr (window-fringes)) 0))
                                            (_ 0))
                                          center-constructs-width)
                                       2)))))))

;;(seq-take rest-beg (seq-position rest-beg 'mode-line-format-right-align))

(defvar mode-line-format-center '(:eval (mode-line--format-center))
  "Mode line construct to center all following constructs up to and
excluding ‘mode-line-format-right-align’ and anything following it.

If ‘mode-line-format-right-align’ does not appear in ‘mode-line-format’,
all constructs following this one are centered.")

(put 'mode-line-format-center 'risky-local-variable t)

(defcustom mode-line-raw-buf-id-mode-list '(agent-shell-mode gnus-mode eww-mode term-mode elfeed-search-mode elfeed-show-mode)
  "List of major modes in which the buffer id should show neither an icon
nor a project name."

  :type '(repeat (symbol :tag "Major mode"))
  :group 'a-t/mode-line)

(defcustom mode-line-align-left
  '("%e"
    " "
    (:propertize
     ("" mode-line-mule-info mode-line-client mode-line-modified mode-line-remote
      mode-line-window-dedicated)
     display (min-width (6.0)))
    mode-line-frame-identification
    "  "
    (:eval
     (when (mode-line-window-selected-p)
       (format-mode-line mode-line-position)))
    "    ")
  "Mode line construct containing all entries that should be left-aligned."
  :type '(repeat (choice (string :tag "Literal text to display in the mode line")
                         (sexp :tag "Sexp to pass on to ‘format-mode-line’, which see. For example, this can
be a list whose car is one of the keywords :propertize or :eval")))
  :group 'a-t/mode-line)

(defcustom mode-line-align-middle
  '((:eval (when (and (featurep 'nerd-icons)
                      (not (and (display-graphic-p)
                                (derived-mode-p 'gnus-mode)))) ; TODO: make this into a
                                                               ; minor mode
             (concat
              (nerd-icons-icon-for-mode major-mode)
              (unless (and (project-current)
                           project-mode-line
                           (not (derived-mode-p mode-line-raw-buf-id-mode-list)))
                " "))))

    (project-mode-line
     (:eval (when-let ((fmt (and (not (derived-mode-p mode-line-raw-buf-id-mode-list))
                                 (project-mode-line-format))))
              (concat fmt "::"))))

    (:eval (format-mode-line mode-line-buffer-identification)))
  "Mode line construct containing all entries that should be centered. By
default, this is a major-mode-appropriate icon,
‘project-mode-line-format’, and ‘mode-line-buffer-identification’ (which
see)."
  :type '(repeat (choice (string :tag "Literal text to display in the mode line")
                         (sexp :tag "Sexp to pass on to ‘format-mode-line’, which see. For example, this can
be a list whose car is one of the keywords :propertize or :eval")))
  :group 'a-t/mode-line)

(defcustom mode-line-align-right
  '(""
    mode-line-misc-info
    " "
    vc-mode
    "  "
    mode-line-modes)
  "Mode line construct containing all entries that should be right-aligned."
  :type '(repeat (choice (string :tag "Literal text to display in the mode line")
                         (sexp :tag "Sexp to pass on to ‘format-mode-line’, which see. For example, this can
be a list whose car is one of the keywords :propertize or :eval")))
  :group 'a-t/mode-line)

(setq-default mode-line-format
              (list
               mode-line-align-left
               'mode-line-format-center
               mode-line-align-middle
               'mode-line-format-right-align
               mode-line-align-right))

(provide 'mode-line-config)
;;; mode-line-config.el ends here
