;;; -*- lexical-binding: t -*-

;; From
;; https://www.reddit.com/r/emacs/comments/yzb77m/an_easy_trick_i_found_to_improve_emacs_startup/
(setq gc-cons-threshold most-positive-fixnum
      gc-cons-percentage 0.6)
(defvar config:file-name-handler-alist-cache file-name-handler-alist)
(setq file-name-handler-alist nil)
(defun config:restore-post-init-settings ()
  (setq gc-cons-threshold 800000
        gc-cons-percentage 0.1)
  (setq file-name-handler-alist config:file-name-handler-alist-cache))
(add-hook 'emacs-startup-hook #'config:restore-post-init-settings)

(defun config:defer-gc ()
  (setq gc-cons-threshold most-positive-fixnum))
(defun config:-do-restore-gc ()
  (setq gc-cons-threshold 800000))
(defun config:restore-gc ()
  (run-at-time 1 nil #'config:-do-restore-gc))

(add-hook 'minibuffer-setup #'config:defer-gc)
(add-hook 'minibuffer-exit #'config:restore-gc)

(setq auto-mode-case-fold nil
      process-adaptive-read-buffering t
      inhibit-compacting-font-caches t
      inhibit-startup-message t)

;; Ensure package.el uses the elpa directory under this user-emacs-directory
(setq package-user-dir (expand-file-name "elpa/" user-emacs-directory))

;; Redirect native-comp cache
(when (boundp 'native-comp-eln-load-path)
  (setq native-comp-eln-load-path (list (expand-file-name "eln-cache/" user-emacs-directory))))

(push '(fullscreen . maximized) default-frame-alist)

(push '(background-color . "black") default-frame-alist)

;;;; ‘Melpa’
(progn
  (require 'package)
  (add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
  (when (< emacs-major-version 27) (package-initialize)))

(setopt package-archive-priorities '(("gnu" . 10)
                                     ("melpa" . 5)))
(setq package-review-policy t
      package-review-diff-command '("git" "diff" "--no-index" "--diff-filter=d"))

(eval-when-compile
  (require 'use-package))
(require 'bind-key)
