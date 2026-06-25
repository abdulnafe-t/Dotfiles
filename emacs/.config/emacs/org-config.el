;;; -*- lexical-binding: t -*-

;;; Org mode configuration. Based on
;;; https://zzamboni.org/post/beautifying-org-mode-in-emacs/
;;; https://www.howardism.org/Technical/Emacs/orgmode-wordprocessor.html
;;; https://lucidmanager.org/productivity/ricing-org-mode/
;;; https://youtu.be/L0EJeN1fCYw

(use-package org
  :bind
  ("C-c a" . org-agenda)
  :custom
  (org-M-RET-may-split-line '((default . nil)))
  (org-src-fontify-natively t)
  (org-src-tab-acts-natively t)
  (org-src-preserve-indentation t)
  (org-insert-heading-respect-content t)
  (org-log-into-drawer t)
  (org-log-done 'time)
  (org-directory "~/Documents/org")
  (org-agenda-files (list org-directory))
  (org-hide-emphasis-markers t)
  (org-startup-indented t)
  (org-pretty-entities t)
  (org-use-sub-superscripts '{})
  (org-startup-with-inline-images t)
  (org-image-actual-width '(300))
  (org-todo-keywords
   '((sequence "TODO(t)" "WAIT(w!)" "|" "CANCELED(c!)" "DONE(d!)"))))

(use-package org-superstar
  :ensure t
  :after org
  :hook
  (org-mode-hook . org-superstar-mode)
  :custom
  (org-superstar-cycle-headline-bullets t)
  (org-superstar-leading-bullet ?\s)
  (org-indent-mode-turns-on-hiding-stars nil))

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
