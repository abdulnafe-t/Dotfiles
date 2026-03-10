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

(setopt ispell-dictionary "en_US"
	ispell-program-name "hunspell"
	ispell-extra-args '("-a" "-i" "utf-8"))

(use-package org-bullets
  :ensure t
  :hook
  (org-mode-hook . (lambda () (org-bullets-mode 1))))

(use-package org-appear
  :ensure t
  :hook
  (org-mode-hook . org-appear-mode))

(use-package olivetti
  :ensure t
  :hook
  (org-mode-hook . olivetti-mode)
  :config
  (setopt olivetti-body-width 72))

(add-hook 'org-mode-hook 'variable-pitch-mode)
