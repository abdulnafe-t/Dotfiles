;;; -*- lexical-binding: t -*-

(defface a-t-hl-line-face
  `((((background dark)) :box nil :inherit default :weight normal :background "#2f2c39")
    (t (:box nil :inherit default :weight normal :background "#d2d1d7")))
  "Face for hl-line, as well as the minibuffer (vertico et al.).")

(defface a-t-font-lock-auto '((t (:inherit font-lock-type-face :slant italic :weight normal)))
  "Custom face for the C++ ‘auto’ keyword.")

(defface a-t-font-lock-this-ptr '((t (:foreground "#0060ab" :slant normal :weight bold)))
  "Custom face for the C++ ‘this’ pointer.")

(modus-themes-with-colors
  (defface a-t-author `((t (:foreground ,accent-1)))
    "Face for author of an article in the gnus summary buffer.")

  (defface a-t-date `((t (:foreground ,date-common)))
    "Face for the date in the gnus summary buffer.")

  (defface a-t-dummy `((t (:foreground ,fg-alt :slant italic)))
    "Face for dummy articles in the gnus summary buffer.")

  (defface a-t-dir-face `((t (:foreground ,cursor)))
    "Face for directories."))

(setq gnus-face-1 'a-t-date
      gnus-face-2 'a-t-author
      gnus-face-3 'a-t-dummy)

(add-hook 'c++-ts-mode-hook
          (lambda()
            (setq treesit-font-lock-settings
                  (append treesit-font-lock-settings
                          (treesit-font-lock-rules
                           :language 'cpp
                           :feature 'keyword
                           :override t
                           '((auto) @a-t-font-lock-auto
                             (this) @a-t-font-lock-this-ptr))))

            (setq-local treesit-font-lock-feature-list
                        (cl-loop for level in treesit-font-lock-feature-list
                                 collect (remove 'function-call level)))
            (push 'function (nth 2 treesit-font-lock-feature-list))

            (treesit-font-lock-recompute-features)))

(defun a-t/set-custom-faces ()

  (set-face-attribute 'default nil :height 120 :family "GeistMono Nerd Font Mono")

  (when (display-graphic-p)
    (set-face-attribute 'variable-pitch nil :height 120 :family "Geist Nerd Font Propo"))

  (unless (display-graphic-p)
    (set-face-attribute 'default nil :background "unspecified-bg"))

  (modus-themes-with-colors
    (set-face-attribute 'highlight nil
                        :foreground (if (eq (frame-parameter nil 'background-mode) 'dark)
                                        bg-main
                                      fg-main)
                        :background (if (eq (frame-parameter nil 'background-mode) 'dark)
                                        fg-main
                                      bg-active))

    (set-face-attribute 'a-t-dir-face nil :foreground cursor)

    (set-face-attribute 'mode-line nil :box 'nil :underline 'nil :family "GeistMono Nerd Font Propo")
    (set-face-attribute 'mode-line-active nil :box nil :underline 'nil :family "GeistMono Nerd Font Propo")
    (set-face-attribute 'mode-line-inactive nil :box 'nil :underline 'nil :family "GeistMono Nerd Font Propo")

    (set-face-attribute 'vc-state-base nil :inherit 'variable-pitch :slant 'normal)
    (set-face-attribute 'vc-edited-state nil :inherit 'variable-pitch :slant 'italic)
    (set-face-attribute 'vc-locked-state nil :inherit 'variable-pitch :slant 'normal)

    (set-face-attribute 'font-lock-variable-use-face nil :foreground fg-main)
    (set-face-attribute 'font-lock-property-name-face nil :foreground fg-alt))

  (with-eval-after-load 'page-break-lines
    (set-fontset-font "fontset-default"
                      (cons page-break-lines-char page-break-lines-char)
                      (face-attribute 'default :family)))

  (with-eval-after-load 'hl-line
    (set-face-attribute 'hl-line nil :background (face-background 'a-t-hl-line-face)))

  (with-eval-after-load 'vertico
    (set-face-attribute 'vertico-current nil :background (face-background 'a-t-hl-line-face) :weight 'normal))

  (with-eval-after-load 'consult
    (modus-themes-with-colors
      (set-face-attribute 'consult-highlight-match nil :background bg-cyan-subtle :weight 'bold)
      (set-face-attribute 'match nil :background bg-cyan-subtle :weight 'bold)
      (set-face-attribute 'consult-file nil :foreground (face-foreground 'shadow))))

  (with-eval-after-load 'eglot
    (modus-themes-with-colors
      (set-face-attribute 'eglot-mode-line           nil :weight 'regular :foreground fg-main)
      (set-face-attribute 'eglot-semantic-macro      nil :weight 'bold :foreground fg-alt)
      (set-face-attribute 'eglot-semantic-parameter  nil :inherit 'font-lock-variable-name-face)
      (set-face-attribute 'eglot-semantic-static     nil :slant 'italic :weight 'normal :foreground 'unspecified :inherit 'nil)))

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
    (set-face-attribute 'org-table                 nil :inherit 'fixed-pitch :foreground (if (eq (frame-parameter nil 'background-mode) 'light)
                                                                                             "#3c534a"
                                                                                           "#83a598"))
    (set-face-attribute 'org-tag                   nil :inherit '(shadow fixed-pitch) :weight 'bold :height 0.8)
    (set-face-attribute 'org-verbatim              nil :inherit '(shadow fixed-pitch)))

  (with-eval-after-load 'olivetti
    (set-face-attribute 'olivetti-fringe nil :background "gray50"))

  (with-eval-after-load 'flymake
    (set-face-attribute 'flymake-note nil :underline '(:style wave :color "#0faa26"))
    (set-face-attribute 'flymake-warning nil :underline '(:style wave :color "#bf9032")))

  (with-eval-after-load 'gnus-art
    (set-face-attribute 'gnus-header-from nil :foreground (face-foreground 'a-t-author))
    (set-face-attribute 'gnus-header-subject nil :foreground (face-foreground 'font-lock-keyword-face)))

  (with-eval-after-load 'dired
    (set-face-attribute 'dired-header nil :foreground (face-foreground 'font-lock-builtin-face))
    (set-face-attribute 'dired-directory nil :foreground (face-foreground 'a-t-dir-face)))

  (with-eval-after-load 'diredfl
    (modus-themes-with-colors
      (set-face-attribute 'diredfl-dir-name nil :foreground (face-foreground 'a-t-dir-face))
      (set-face-attribute 'diredfl-dir-heading nil :foreground (face-foreground 'font-lock-builtin-face))
      (set-face-attribute 'diredfl-file-suffix nil :foreground fg-main)
      (set-face-attribute 'diredfl-compressed-file-suffix nil :foreground (face-foreground 'diredfl-compressed-file-name))))

  (with-eval-after-load 'nerd-icons-completion
    (set-face-attribute 'nerd-icons-completion-dir-face nil :foreground (face-foreground 'a-t-dir-face))))

(if (daemonp)
    (add-hook 'after-make-frame-functions
              (defun a-t/faces-init-daemon (frame)
                (with-selected-frame frame
                  (a-t/set-custom-faces))
                (remove-hook 'after-make-frame-functions
                             #'a-t/faces-init-daemon)
                (fmakunbound 'a-t/faces-init-daemon)))
  (a-t/set-custom-faces))
