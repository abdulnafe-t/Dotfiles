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
  :hook
  (org-mode-hook . (lambda () (org-bullets-mode 1))))

(use-package org-appear
  :hook
  (org-mode-hook . org-appear-mode))

(use-package olivetti
  :hook
  (org-mode-hook . olivetti-mode)
  :config
  (setopt olivetti-body-width 72))

(custom-theme-set-faces
 'user
 '(variable-pitch ((t (:family "GeistNerdFontPropo"))))
 '(fixed-pitch ((t ( :family "GeistMonoNerdFontMono"))))
 '(monospace ((t (:family "GeistMonoNerdFontMono"))))
 '(org-level-1 ((t (:inherit outline-1 :height 1.7))))
 '(org-level-2 ((t (:inherit outline-2 :height 1.6))))
 '(org-level-3 ((t (:inherit outline-3 :height 1.5))))
 '(org-level-4 ((t (:inherit outline-4 :height 1.4))))
 '(org-level-5 ((t (:inherit outline-5 :height 1.3))))
 '(org-block ((t (:inherit fixed-pitch))))
 '(org-code ((t (:inherit (shadow fixed-pitch)))))
 '(org-document-info ((t (:foreground "dark orange"))))
 '(org-document-info-keyword ((t (:inherit (shadow fixed-pitch)))))
 '(org-indent ((t (:inherit (org-hide fixed-pitch)))))
 '(org-link ((t (:foreground "royal blue" :underline t))))
 '(org-meta-line ((t (:inherit (font-lock-comment-face fixed-pitch)))))
 '(org-property-value ((t (:inherit fixed-pitch))) t)
 '(org-special-keyword ((t (:inherit (font-lock-comment-face fixed-pitch)))))
 '(org-table ((t (:inherit fixed-pitch :foreground "#83a598"))))
 '(org-tag ((t (:inherit (shadow fixed-pitch) :weight bold :height 0.8))))
 '(org-verbatim ((t (:inherit (shadow fixed-pitch))))))

(add-hook 'org-mode-hook 'variable-pitch-mode)
