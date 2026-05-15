;;; line-count.el --- Show the total line count in the mode line -*- lexical-binding: t -*-

;; Copyright (C) 2026  Abdulnafé Toulaïmat

;; Author: Abdulnafé Toulaïmat <abdulnafe.toulaimat@gmail.com>
;; Keywords: lisp, convenience, mode-line

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

;; This is a small script that defines ‘line-count-mode’, a globalized minor mode
;; that shows total line and column count in the minibuffer.

;;; Code:

(defgroup line-count nil
  "Line counting minor mode."
  :group 'convenience
  :group 'mode-line
  :prefix "line-count-")

(defvar line-count-mode-line-indicator
  '(line-count-mode (:eval (format "    (%d:%d) "
                                   (count-lines (point-min) (point-max)) fill-column)))
  "Mode line construct used by `line-count-mode'.")

(put 'mode-line-total-lines-indicator 'risky-local-variable t)

;;;###autoload
(define-minor-mode line-count-mode
  "Minor mode that shows total line & column count in the mode line by
modifying `mode-line-position', which see."
  :lighter " lnct"
  :group 'line-count
  (if line-count-mode
      (add-to-list 'mode-line-position line-count-mode-line-indicator t)
    (setq mode-line-position
          (delq line-count-mode-line-indicator mode-line-position)))
  (force-mode-line-update))

;;;###autoload
(define-globalized-minor-mode line-count-global-mode
  line-count-mode line-count-mode
  :predicate '(not pdf-view-mode)
  :group 'line-count)

(provide 'line-count)

;;; line-count.el ends here




