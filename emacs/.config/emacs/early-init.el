;; Ensure package.el uses the elpa directory under this user-emacs-directory
(setq package-user-dir (expand-file-name "elpa/" user-emacs-directory))

;; Redirect native-comp cache
(when (boundp 'native-comp-eln-load-path)
  (setq native-comp-eln-load-path (list (expand-file-name "eln-cache/" user-emacs-directory))))

(push '(fullscreen . maximized) default-frame-alist)
