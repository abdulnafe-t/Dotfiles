;; Ensure package.el uses the elpa directory under this user-emacs-directory
(setq package-user-dir (expand-file-name "elpa/" user-emacs-directory))

;; Redirect native-comp cache
(when (boundp 'native-comp-eln-load-path)
  (setq native-comp-eln-load-path (list (expand-file-name "eln-cache/" user-emacs-directory))))

(push '(fullscreen . maximized) default-frame-alist)

(push '(background-color . "black") default-frame-alist)

;;;; Melpa
(progn
  (require 'package)
  ;; add melpa repository.
  (add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
  (when (< emacs-major-version 27) (package-initialize)))

(setopt package-archive-priorities '(("gnu" . 10)
                                     ("melpa" . 5)))
(setq package-review-policy t
      package-review-diff-command '("git" "diff" "--no-index" "--color=never" "--diff-filter=d"))
