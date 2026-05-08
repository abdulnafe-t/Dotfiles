;;; -*- lexical-binding: t -*-

(defface scion-font-lock-auto '((t (:inherit font-lock-type-face :slant italic :weight normal)))
  "Custom face for the C++ ‘auto’ keyword.")

(defface scion-font-lock-this-ptr '((t (:foreground "#00609b" :slant normal :weight bold)))
  "Custom face for the C++ ‘this’ pointer.")

(defface scion-date '((t (:foreground "#00a692")))
  "Face for the date in the gnus summary buffer.")

(defface scion-author `((t (:foreground "#e580ea")))
  "Face for author of an article in the gnus summary buffer.")

(defface scion-dummy '((t (:foreground "#80baea" :slant italic)))
  "Face for dummy articles in the gnus summary buffer.")

(defface scion-subject '((t (:weight normal)))
  "Face for subject of an article in the gnus summary buffer.")

(setq gnus-face-1 'scion-date
      gnus-face-2 'scion-author
      gnus-face-3 'scion-dummy
      gnus-face-4 'scion-subject)

(add-hook 'c++-ts-mode-hook
          (lambda()
            (setq treesit-font-lock-settings
                  (append treesit-font-lock-settings
                          (treesit-font-lock-rules
                           :language 'cpp
                           :feature 'keyword
                           :override t
                           '((auto) @scion-font-lock-auto
                             (this) @scion-font-lock-this-ptr))))

            (setq-local treesit-font-lock-feature-list
                        (cl-loop for level in treesit-font-lock-feature-list
                                 collect (remove 'function-call level)))
            (push 'function (nth 2 treesit-font-lock-feature-list))

            (treesit-font-lock-recompute-features)))

(setq use-default-font-for-symbols nil)

;; Variable-pitch fontset: GeistNerdFontPropo + Amiri for Arabic
(create-fontset-from-fontset-spec
 (font-xlfd-name
  (font-spec :size 20 :registry "fontset-arabicvar")))

(defun scion/set-custom-faces ()
  (with-eval-after-load 'nerd-icons-completion
    (set-face-attribute 'nerd-icons-completion-dir-face nil
			:foreground (face-foreground 'font-lock-keyword-face)))

  (set-fontset-font "fontset-arabicvar" 'latin "GeistNerdFontPropo")
  (set-fontset-font "fontset-arabicvar" 'arabic (font-spec :family "Amiri") nil 'append)

  (set-fontset-font "fontset-default" 'arabic "Kawkab Mono" nil 'prepend)

  (set-face-attribute 'default        nil :height 150)
  (set-face-attribute 'variable-pitch nil :fontset "fontset-arabicvar" :font 'unspecified :family 'unspecified)

  (unless (display-graphic-p)
    (set-face-attribute 'default nil :background "unspecified-bg"))

  (set-face-attribute 'mode-line nil :box 'nil :underline 'nil)
  (set-face-attribute 'mode-line-active nil :box nil :underline 'nil)
  (set-face-attribute 'mode-line-inactive nil :box 'nil :underline 'nil)

  (set-face-attribute 'vc-state-base nil :inherit 'variable-pitch :slant 'normal)
  (set-face-attribute 'vc-edited-state nil :inherit 'variable-pitch :slant 'italic)
  (set-face-attribute 'vc-locked-state nil :inherit 'variable-pitch :slant 'normal)

  (set-face-attribute 'font-lock-variable-use-face nil :foreground (face-foreground 'default))
  (set-face-attribute 'font-lock-property-name-face nil :foreground "#8aa0df")
  (set-face-attribute 'font-lock-property-name-face nil :foreground "#8aa0df")

  (set-face-attribute 'hl-line nil :background (face-background 'custom-hl-line-face))

  (with-eval-after-load 'consult
    (set-face-attribute 'consult-highlight-match nil :background "#561d32" :weight 'bold)
    (set-face-attribute 'match nil :background "#561d32" :weight 'bold)
    (set-face-attribute 'consult-file nil :foreground (face-foreground 'shadow)))

  (with-eval-after-load 'eglot
    (set-face-attribute 'eglot-mode-line           nil :weight 'regular :foreground (face-foreground 'default))
    (set-face-attribute 'eglot-semantic-macro      nil :weight 'bold :foreground "#89afef")
    (set-face-attribute 'eglot-semantic-property   nil :weight 'normal :slant 'normal :foreground "#8aa0df")
    (set-face-attribute 'eglot-semantic-parameter  nil :inherit 'font-lock-variable-name-face)
    (set-face-attribute 'eglot-semantic-enumMember nil :foreground (face-foreground 'default))
    (set-face-attribute 'eglot-semantic-static     nil :slant 'italic :weight 'normal :foreground 'unspecified :inherit 'nil))

  (with-eval-after-load 'org
    (set-face-attribute 'org-block                 nil :inherit 'fixed-pitch)
    (set-face-attribute 'org-code                  nil :inherit '(shadow fixed-pitch))
    (set-face-attribute 'org-document-info         nil :foreground "dark orange")
    (set-face-attribute 'org-document-info-keyword nil :inherit '(shadow fixed-pitch))
    (set-face-attribute 'org-level-1               nil :inherit 'outline-1 :height 1.7)
    (set-face-attribute 'org-level-2               nil :inherit 'outline-2 :height 1.6)
    (set-face-attribute 'org-level-3               nil :inherit 'outline-3 :height 1.5)
    (set-face-attribute 'org-level-4               nil :inherit 'outline-4 :height 1.4)
    (set-face-attribute 'org-level-5               nil :inherit 'outline-5 :height 1.3)
    (set-face-attribute 'org-link                  nil :foreground "royal blue" :underline t)
    (set-face-attribute 'org-meta-line             nil :inherit '(font-lock-comment-face fixed-pitch))
    (set-face-attribute 'org-property-value        nil :inherit 'fixed-pitch)
    (set-face-attribute 'org-special-keyword       nil :inherit '(font-lock-comment-face fixed-pitch))
    (set-face-attribute 'org-table                 nil :inherit 'fixed-pitch :foreground "#83a598")
    (set-face-attribute 'org-tag                   nil :inherit '(shadow fixed-pitch) :weight 'bold :height 0.8)
    (set-face-attribute 'org-verbatim              nil :inherit '(shadow fixed-pitch)))

  (with-eval-after-load 'olivetti
    (set-face-attribute 'olivetti-fringe nil :background "gray50"))

  (with-eval-after-load 'flymake
    (set-face-attribute 'flymake-note nil :underline '(:style wave :color "#0faa26")))

  (with-eval-after-load 'gnus-art
    (set-face-attribute 'gnus-header-from nil :foreground (face-foreground 'scion-author))
    (set-face-attribute 'gnus-header-subject nil :foreground (face-foreground 'font-lock-keyword-face)))

  (with-eval-after-load 'elfeed
    (set-face-attribute 'elfeed-search-date-face nil :foreground (face-foreground 'scion-date))
    (set-face-attribute 'elfeed-log-date-face  nil :foreground (face-foreground 'scion-date))
    (set-face-attribute 'elfeed-search-last-update-face nil :foreground (face-foreground 'scion-date))

    (set-face-attribute 'elfeed-search-feed-face nil :foreground (face-foreground 'scion-author))))

(if (daemonp)
    (add-hook 'after-make-frame-functions
	      (defun scion/faces-init-daemon (frame)
		(with-selected-frame frame
		  (scion/set-custom-faces))
		(remove-hook 'after-make-frame-functions
			     #'scion/faces-init-daemon)
		(fmakunbound 'scion/faces-init-daemon)))
  (scion/set-custom-faces))
