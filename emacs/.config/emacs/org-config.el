;;; -*- lexical-binding: t -*-

;;; Org mode configuration. Based on
;;; https://zzamboni.org/post/beautifying-org-mode-in-emacs/
;;; https://www.howardism.org/Technical/Emacs/orgmode-wordprocessor.html
;;; https://lucidmanager.org/productivity/ricing-org-mode/

(setopt org-hide-emphasis-markers t
        org-startup-indented t
        org-pretty-entities t
        org-use-sub-superscripts '{}
        org-startup-with-inline-images t
        org-image-actual-width '(300))

(use-package org-bullets
  :ensure t
  :after org
  :hook
  (org-mode-hook . org-bullets-mode))

(use-package org-appear
  :ensure t
  :after org
  :hook
  (org-mode-hook . org-appear-mode))

(use-package olivetti
  :ensure t
  :hook
  (olivetti-mode-on-hook . (lambda ()
                             (setq-local cursor-type 'bar)))

  (olivetti-mode-off-hook . (lambda ()
                              (setq-local cursor-type t)))

  :config
  (setopt olivetti-style nil
          olivetti-body-width 72))
