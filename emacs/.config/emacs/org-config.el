;;; -*- lexical-binding: t -*-

;;; Org mode configuration. Based on
;;; https://zzamboni.org/post/beautifying-org-mode-in-emacs/
;;; https://www.howardism.org/Technical/Emacs/orgmode-wordprocessor.html
;;; https://lucidmanager.org/productivity/ricing-org-mode/
;;; https://youtu.be/L0EJeN1fCYw
;;; https://github.com/minad/org-modern

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
   '((sequence "TODO(t)" "WAIT(w!)" "|" "CANCELED(c!)" "DONE(d!)")))
  (org-hierarchical-todo-statistics nil)
  (org-ellipsis "…")

  :config
  (defun org-summary-todo (n-done n-not-done)
    "Switch entry to DONE when all subentries are done, to TODO otherwise."
    (let (org-log-done org-todo-log-states)   ; turn off logging
      (org-todo (if (= n-not-done 0) "DONE" "TODO"))))
  (add-hook 'org-after-todo-statistics-hook #'org-summary-todo))

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
                              (setq-local cursor-type t))))
