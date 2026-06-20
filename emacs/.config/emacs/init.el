;;; -*- lexical-binding: t -*-

;;; Server/Client architecture
(use-package server)
(unless (server-running-p)
  (server-start))

;;; Emacs source code
(setq find-function-C-source-directory "~/Etc/Programs/emacs-c-code")

;;; General Emacs settings
(setopt inhibit-splash-screen t
        initial-scratch-message nil
        visible-bell nil

        mode-line-percent-position nil
        project-mode-line t
        mode-line-position-column-line-format '("%6l:%2C")

        find-file-visit-truename t
        view-read-only t
        delete-by-moving-to-trash t
        save-interprogram-paste-before-kill t

        bookmark-save-flag 0

        confirm-kill-processes nil
        shell-command-prompt-show-cwd t
        use-short-answers t

        completions-group t
        completion-eager-update t

        set-mark-command-repeat-pop t
        exchange-point-and-mark-highlight-region nil

        enable-recursive-minibuffers t
        minibuffer-visible-completions t

        help-window-select t
        help-enable-completion-autoload nil

        dnd-indicate-insertion-point t
        mouse-drag-and-drop-region 'control
        mouse-drag-and-drop-region-cut-when-buffers-differ t

        quit-window-kill-buffer t

        package-autosuggest-mode t

        frame-inhibit-implied-resize t
        frame-resize-pixelwise t
        window-resize-pixelwise t)

(recentf-mode 1)
(savehist-mode 1)
(push 'command-history savehist-additional-variables)
(auto-save-visited-mode 1)

(context-menu-mode 1)
(xterm-mouse-mode 1) ; for TTY
(setopt xterm-extra-capabilities '(getSelection
                                   setSelection
                                   modifyOtherKeys))

(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)

(line-count-global-mode 1)
(column-number-mode 1)

(global-visual-line-mode 1)
(global-word-wrap-whitespace-mode 1)

(use-package completion-preview

  :bind
  (:map completion-preview-active-mode-map
        ("M-n" . completion-preview-next-candidate)
        ("M-<down>" . completion-preview-next-candidate)
        ("M-p" . completion-preview-prev-candidate)
        ("M-<up>" . completion-preview-prev-candidate)
        ("<tab>" . completion-preview-insert)
        ("M-<tab>" . completion-preview-complete))

  :hook
  ((prog-mode-hook text-mode-hook))

  :config
  (push 'org-self-insert-command completion-preview-commands)

  :custom
  (completion-preview-minimum-symbol-length 2))

(global-set-key (kbd "C-+") 'text-scale-increase)
(global-set-key (kbd "C--") 'text-scale-decrease)
(global-set-key (kbd "<C-wheel-down>") 'text-scale-decrease)
(global-set-key (kbd "<C-wheel-up>") 'text-scale-increase)

(electric-pair-mode 1)
(electric-quote-mode 1)
(delete-selection-mode 1)
(setq-default blink-matching-paren-highlight-offscreen t
              show-paren-context-when-offscreen t)

(setq-default fill-column 90
              sentence-end-double-space nil)

;; Replace tabs with spaces
(defun a-t/disable-tabs ()
  "Use spaces and not tabs for indentation, unless in ‘makefile-gmake-mode’"
  (unless (derived-mode-p 'makefile-gmake-mode)
    (indent-tabs-mode -1)))

(add-hook 'prog-mode-hook #'a-t/disable-tabs)

(global-auto-revert-mode 1)
(global-so-long-mode 1)

;; From https://stackoverflow.com/questions/3631220/fix-to-get-smooth-scrolling-in-emacs
(setopt scroll-margin 1
        scroll-step 1
        scroll-conservatively 101
        scroll-preserve-screen-position 1
        mouse-wheel-scroll-amount '(1 ((shift) . 1))
        mouse-wheel-progressive-speed nil)

;; From https://karthinks.com/software/even-more-batteries-included-with-emacs/
;; Get DWIM behavior from ‘scroll-other-window’
(setq other-window-scroll-default
      (lambda ()
        (or (get-mru-window nil nil 'not-this-one-dummy)
            (next-window)               ;fall back to next window
            (next-window nil nil 'visible))))

;; Display a counter in I-search, showing total number of matches, as well as the current
;; position in them. Taken from Protesilaos Stavrou
(setopt isearch-lazy-count t
        lazy-count-prefix-format "(%s/%s) "
        lazy-count-suffix-format nil
        search-whitespace-regexp ".*?")

;; Augment default C-g behavior
(defun prot/keyboard-quit-dwim ()
  (interactive)
  (cond
   ((region-active-p)
    (keyboard-quit))
   ((derived-mode-p 'completion-list-mode)
    (delete-completion-window))
   ((> (minibuffer-depth) 0)
    (abort-recursive-edit))
   (t
    (keyboard-quit))))

(keymap-global-set "C-g" 'prot/keyboard-quit-dwim)

;; Unbind suspend-frame to prevent weird behavior on hyprland, and to
;; prevent finger slippage while undoing.
(keymap-unset global-map "C-x C-z")

(repeat-mode 1)
(keymap-global-set "C-z" 'undo)
(define-key undo-repeat-map (kbd "z") #'undo)

(setopt use-package-hook-name-suffix nil)

;;; Security

(setq trusted-content '("~/Projects/"))

(setq-default auth-sources '("secrets:App Passwords" "~/.authinfo.gpg"))

;; Make local sudo always prompt for a password, as opposed to looking it up in
;; ‘auth-sources’. From
;; https://emacs.stackexchange.com/questions/64062/how-to-avoid-using-auth-sources-when-editing-with-sudo
(setopt tramp-completion-use-auth-sources nil)

(connection-local-set-profile-variables
 'remote-without-auth-sources
 '((auth-sources . nil)))

(connection-local-set-profiles
 '(:application tramp :protocol "sudo"
                :machine "plato" :user "root")
 'remote-without-auth-sources)

;;; Theme & style

(setq-default cursor-type 'box
              cursor-in-non-selected-windows nil)

(setopt elisp-fontify-semantically t
        elisp-add-help-echo nil
        font-lock-maximum-decoration 3
        treesit-font-lock-level 3)

;; (add-to-list 'default-frame-alist '(alpha-background . 0.8))

;;;; Style: fringe indicators & window dividers
(setq-default window-divider-default-right-width 3)
(window-divider-mode 1)

(setopt fringe-indicator-alist
        (assq-delete-all 'truncation
                         (assq-delete-all 'continuation
                                          fringe-indicator-alist)))

(defun a-t/modernize-tty ()
  "Replace window borders and special glyphs with more modern looking alternatives."
  (unless (display-graphic-p)
    (let ((display-table (or buffer-display-table
                             standard-display-table)))
      (set-display-table-slot display-table 'vertical-border ?┃) ; Replace pipe with box
                                                                 ; segment
      (set-display-table-slot display-table 'truncation ? )))) ; Replace $ with space

(add-hook 'window-configuration-change-hook #'a-t/modernize-tty)

;;;; Style: mode line
(require 'mode-line-config)

(load "~/.config/emacs/season-colors.el")

;;;; Style: theme
(use-package ef-themes
  :ensure t
  :demand t
  :init
  (ef-themes-take-over-modus-themes-mode)

  :bind
  (("<f5>" . a-t/toggle-dark-modus-theme)
   ("C-<f5>" . modus-themes-select))

  :custom
  (modus-themes-mixed-fonts t)
  (modus-themes-bold-constructs t)
  (modus-themes-italic-constructs t)
  (modus-themes-prompts '(ultrabold))

  (ef-dark-palette-overrides
   `((string red-faint)
     (comment fg-dim)
     (bg-hover nil)
     (bg-mode-line-active ,season-dim)
     (cursor ,season-bright)))

  (ef-night-palette-overrides
   `((bg-main "#000000")
     (string red-faint)
     (comment fg-dim)
     (bg-hover nil)
     (cursor ,season-bright)))

  (ef-melissa-dark-palette-overrides
   `((bg-main "#000000")
     (string red-faint)
     (comment fg-dim)
     (bg-hover nil)
     (cursor ,season-bright)))

  (ef-melissa-light-palette-overrides
   `((bg-main "#ffffff")
     (bg-hover nil)
     (cursor ,season-dim)))

  :config

  (defun a-t/toggle-dark-modus-theme ()
    (interactive)
    (modus-themes-load-theme (if (eq (modus-themes-get-current-theme) season-dark-theme)
                                 season-light-theme
                               season-dark-theme))
    (a-t/set-custom-faces))

  (modus-themes-load-theme season-dark-theme))

;;;; Style: ‘pulsar’
(use-package pulsar
  :ensure t
  :config
  (setopt pulsar-face 'cursor
          pulsar-region-face 'cursor
          pulsar-region-change-face 'cursor
          pulsar-highlight-face 'cursor
          pulsar-tty-color "snow3")
  (push 'kill-visual-line pulsar-pulse-functions)
  :init
  (pulsar-global-mode))

;;;; Style: ‘shr’
(use-package shr
  :custom
  (shr-use-colors nil)
  (shr-use-fonts nil))

(use-package hl-line
  :demand t
  :hook
  (dired-mode-hook
   elfeed-search-mode-hook
   git-rebase-mode-hook
   grep-mode-hook
   ibuffer-mode-hook
   log-view-mode-hook
   magit-log-mode-hook
   occur-mode-hook
   org-agenda-mode-hook
   pdf-outline-buffer-mode-hook
   proced-mode-hook
   gnus-server-mode-hook
   gnus-browse-mode-hook
   gnus-summary-mode-hook
   gnus-group-mode-hook
   tabulated-list-mode-hook))

(defun a-t/disable-visual-line-mode ()
  "Disable ‘visual-line-mode’ and associated modes."
  (unless (derived-mode-p 'hexl-mode)
    (visual-line-mode -1)
    (toggle-truncate-lines 1)
    (setq-local cursor-type nil
                column-number-mode (not hl-line-mode)
                line-move-visual nil)))

(add-hook 'hl-line-mode-hook #'a-t/disable-visual-line-mode)

(advice-add #'grep-change-to-grep-edit-mode
            :after (lambda()
                     (when hl-line-mode
                       (hl-line-mode -1)
                       (setq-local cursor-type 'box))))

(advice-add #'grep-edit-save-changes
            :after (lambda ()
                     (hl-line-mode 1)))

(advice-add #'occur-edit-mode
            :after (lambda()
                     (when hl-line-mode
                       (hl-line-mode -1)
                       (setq-local cursor-type 'box))))

(advice-add #'occur-cease-edit
            :after (lambda ()
                     (hl-line-mode 1)))

;;; ‘Org’
(load "~/.config/emacs/org-config")

;;; Programming

(use-package autoinsert
  ; Builtin, used to automatically insert header guards & #include macros when a header
  ; file has the same name as the current (new) C++ file
  :init
  (auto-insert-mode)
  :custom
  (auto-insert-query nil)
  (auto-insert nil))

(use-package flymake
  ;; Builtin, used for syntax checking. Disable its
  ;; modeling lighter, but keep the error
  ;; counters
  :custom
  (flymake-mode-line-lighter "")
  :config
  (add-hook 'bash-ts-mode-hook #'flymake-mode))

;; Trim extraneous whitespaces in code files
(use-package ws-butler
  :ensure t
  :init
  (ws-butler-global-mode))

;; Extensions: ‘yasnippet’.
;;
;;Required to get proper auto-completion (e.g. for () after function names) with eglot &
;; clangd
(use-package yasnippet
  :ensure t
  :config
  (yas-global-mode))

(use-package eglot
  :bind
  (:map eglot-mode-map
        ("M-q" . eglot-format))
  :hook ((c-ts-mode-hook c++-ts-mode-hook) . eglot-ensure)
  :config
  (add-to-list 'eglot-server-programs
               '((c-ts-mode c++-ts-mode) . ("clangd"
                                            "--clang-tidy"
                                            "--enable-config"
                                            "--log=verbose"
                                            "--pretty"
                                            "--completion-style=detailed")))
  (add-to-list 'eglot-ignored-server-capabilities :inlayHintProvider)
  (add-to-list 'eglot-ignored-server-capabilities :documentHighlightProvider)
  (add-to-list 'eglot-ignored-server-capabilities :documentOnTypeFormattingProvider)

  :custom
  (eglot-autoshutdown t)
  (eglot-extend-to-xref t)
  (eglot-sync-connect nil)
  (eglot-code-action-indications '(margin))
  (eglot-semantic-token-types '("macro" "property" "parameter" "enumMember"))
  (eglot-semantic-token-modifiers '("static"))
  (eglot-mode-line-format
   '(("󱉟 "
      eglot-mode-line-menu
      eglot-mode-line-error
      eglot-mode-line-pending-requests
      eglot-mode-line-progress
      eglot-mode-line-action-suggestion))))

(with-eval-after-load 'eglot
  (when-let* ((entry (assq 'eglot--managed-mode mode-line-misc-info))
              (fmt (cadr entry)))
    (setcar fmt " ") ; Remove "["
    (setcar (last fmt) " "))) ; Remove "]"

;;;; Extensions: ‘treesitter’
(use-package treesit
  :custom
  (treesit-enabled-modes t))

(defun a-t/c++-config ()
  "Set custom C++ options."
  (setopt c-ts-mode-indent-offset 6
          indent-tabs-mode nil)
  (setq-local compile-command "cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON -S ./src -B ./build && cmake --build ./build")
  (keymap-set c-ts-base-mode-map "RET" #'electric-indent-just-newline)
  (keymap-set c-ts-base-mode-map "C-c C-c" #'compile)
  (keymap-set c-ts-base-mode-map "C-c c" #'compile))

(add-hook 'c++-ts-mode-hook #'a-t/c++-config)

(defun a-t/eglot-config ()
  "Set custom eglot options."
  (setq-local eldoc-documentation-strategy 'eldoc-documentation-compose-eagerly))

(add-hook 'eglot-managed-mode-hook #'a-t/eglot-config)

(add-to-list 'auto-mode-alist '("\\.clang\\(-\\(format\\|tidy\\)\\|d\\)" . conf-mode))

(add-hook 'compilation-filter-hook 'ansi-color-compilation-filter)
(add-hook 'shell-mode-hook 'ansi-color-for-comint-mode-on)

;;;; Extensions: ‘GDB’
(use-package gdb-mi
  :ensure t
  :config

  (defun a-t/gdb--configure-source-buffer ()
    "Configure source buffers during GDB debugging session."
    (when (and (derived-mode-p 'prog-mode)
               (eq gud-minor-mode 'gdbmi))
      (setq-local line-number-mode nil
                  column-number-mode nil
                  mode-line-format-center nil)
      (display-line-numbers-mode 1)
      (line-count-mode -1)
      (visual-line-mode -1)))

  (defun a-t/gdb--configure-special-buffer ()
    "Strip mode-line noise in GDB special buffers."
    (setq-local line-number-mode nil
                column-number-mode nil
                mode-line-format-center nil)
    (line-count-mode -1)
    (visual-line-mode -1))

  (defun a-t/gdb--cleanup-source-buffer ()
    "Restore source buffers after GDB exits."
    (when (and (derived-mode-p 'prog-mode)
               (eq gud-minor-mode 'gdbmi))
      (setq-local mode-line-format-center (default-value 'mode-line-format-center)
                  column-number-mode 1
                  line-number-mode 1)
      (display-line-numbers-mode -1)
      (line-count-mode 1)))

  (add-hook 'gdb-find-file-hook #'a-t/gdb--configure-source-buffer)
  (advice-add #'gdb-init-buffer :after #'a-t/gdb--configure-source-buffer)
  (advice-add #'gdb-reset :before
              (lambda ()
                (dolist (buffer (buffer-list))
                  (with-current-buffer buffer
                    (a-t/gdb--cleanup-source-buffer)))))

  (advice-add #'gdb :before
              (lambda (_command-line)
                (dolist (hook '(gud-mode-hook
                                gdb-script-mode-hook
                                gdb-locals-mode-hook
                                gdb-threads-mode-hook
                                gdb-registers-mode-hook
                                gdb-breakpoints-mode-hook
                                gdb-inferior-io-mode-hook
                                gdb-frames-mode-hook))
                  (add-hook hook #'a-t/gdb--configure-special-buffer))))

  (advice-add #'gdb :after (lambda (_command-line)
                             (gdb-many-windows 1)))

  :custom
  (gdb-debuginfod-enable-setting nil)
  (gdb-show-main t)
  (gud-highlight-current-line t)
  (gdb-stack-buffer-addresses t)
  (gdb-restore-window-configuration-after-quit t))

;;;; Extensions: ‘json-’ and ‘markdown-mode’
(use-package json-mode
  :ensure t
  :config
  (add-to-list 'auto-mode-alist '("\\.jsonc\\'" . json-mode)))

(use-package markdown-mode
  :ensure t)

;;;; Extensions: ‘AUCTeX’
(use-package auctex
  :ensure t
  :hook (LaTeX-mode-hook . TeX-source-correlate-mode)
  :config
  (setopt TeX-auto-save t
          TeX-parse-self t
          TeX-master nil
          TeX-view-program-selection '((output-pdf "PDF Tools"))
          TeX-source-correlate-start-server t
          TeX-engine 'luatex))

(add-hook 'TeX-after-compilation-finished-functions
          #'TeX-revert-document-buffer)

;; Use pdf-tools as an emacs-native PDF viewer
(use-package pdf-tools
  :ensure t
  :init
  (pdf-tools-install)
  :hook
  (pdf-view-mode-hook . (lambda ()
                          (setq pdf-tools-enabled-modes
                                (delq #'pdf-misc-size-indication-minor-mode
                                      pdf-tools-enabled-modes))))
  (pdf-view-mode-hook . pdf-tools-enable-minor-modes)
  :custom
  (pdf-info-epdfinfo-program "/usr/local/bin/epdfinfo")
  (pdf-misc-print-program-executable "lp"))

(use-package pdffontetc
  :ensure t)

;;;; Extensions: ‘tuareg’
(use-package tuareg
  :ensure t)

;;; Other QOL packages & extensions

;;;; ‘Dired’
;; Enable long listing in dired, sort directories before other files, use human-readable
;; file sizes (KB, GB, etc), and don't show hidden files (including . and ..).
(setq-default dired-listing-switches "-Agho --group-directories-first"
              dired-switches-in-mode-line nil)

(use-package dired
  :demand t
  :init
  (require 'dired-x)

  :bind
  (:map dired-mode-map
        ("M-o" . dired-omit-mode))
  :hook
  (dired-mode-hook . dired-omit-mode)
  (dired-mode-hook . turn-on-gnus-dired-mode)

  :custom
  (dired-dwim-target t)
  (dired-omit-verbose nil)
  (dired-mouse-drag-files 'move)
  (dired-auto-revert-buffer t)
  (dired-dwim-target t)
  (image-dired-external-viewer "xdg-open")
  (dired-movement-style 'cycle-files)
  (dired-kill-when-opening-new-dired-buffer t)
  (dired-omit-files (rx (or (seq bol (? ".") "#")         ;; emacs autosave files
                            (seq bol "." (not (any "."))) ;; dot-files
                            (seq "~" eol)                 ;; backup-files
                            )))
  :config
  (advice-add #'wdired-change-to-wdired-mode
              :after (lambda()
                       (when hl-line-mode
                         (hl-line-mode -1)
                         (setq-local cursor-type 'box))))

  (advice-add #'wdired-change-to-dired-mode
              :after (lambda ()
                       (hl-line-mode 1))))

(use-package dired-preview
  :ensure t
  :after dired
  :init
  (dired-preview-global-mode)
  :custom
  (dired-preview-delay 0.1)
  (dired-preview-buffer-name-indicator "Preview:")
  (dired-preview-max-size (* 5 (expt 2 20)))

  :bind

  (:repeat-map dired-preview-repeat-map
               ("C-u" . dired-preview-page-up)
               ("C-d" . dired-preview-page-down)
               ("C-x" . dired-preview-hexl-toggle)
               :exit
               ("C-f" . dired-preview-find-file)
               ("C-o" . dired-preview-open-dwim))

  :config
  (setopt dired-preview-ignored-extensions-regexp nil))

(use-package diredfl
  :ensure t
  :after dired
  :init
  (diredfl-global-mode)
  :custom
  (diredfl-ignore-compressed-flag nil))

;;;; Extensions: ‘jinx’
(use-package jinx
  :ensure t
  :demand t
  :hook (emacs-startup-hook . global-jinx-mode)
  :bind (("M-$" . jinx-correct)
         ("C-M-$" . jinx-next))
  :config
  (setopt jinx-languages "en_US"
          jinx-camel-modes t)

  (dolist (r `( ,(rx ; Don't spellcheck hex colors: #RGB, #RRGGBB, and #RRGGBBAA
                  (seq
                   (group (or
                           (= 3 xdigit)
                           (= 6 xdigit)
                           (= 8 xdigit)))
                   eow))

                ,(rx ; Don't spellcheck file names/extensions
                  (seq
                   bow
                   (zero-or-more alnum)
                   "."
                   (one-or-more alnum)
                   eow))))
    (push r (cdr (assoc t jinx-exclude-regexps))))

  (defun a-t/jinx-skip-path-p (start)
    "Skip if the preceding text forms an absolute path.
     Meant to be used in jinx--predicates to skip file paths."
    (save-excursion
      (goto-char start)
      (let ((beginning-of-path (line-beginning-position)))
        (goto-char start)
        (skip-chars-backward "~/A-Za-z0-9_.-")
        (when (and (> (point) beginning-of-path)
                   (file-name-absolute-p (buffer-substring-no-properties
                                          (point) start)))
          (re-search-forward "[^/]*" (line-end-position) t)
          (point)))))

  (push #'a-t/jinx-skip-path-p jinx--predicates)

  (defun a-t/jinx-skip-package-p (word-start)
    "Skip if the word at point is an installed package name.
   Handles hyphenated package names in emacs-lisp-mode.
   Meant to be used in jinx--predicates."
    (save-excursion
      (goto-char word-start)
      (let ((start-pos (point)))
        (skip-chars-forward "a-zA-Z0-9-")
        (let* ((potential-name (downcase (buffer-substring-no-properties start-pos (point))))
               (pkg (intern-soft potential-name)))
          (when (and pkg (assq pkg package-alist))
            (point))))))

  (push #'a-t/jinx-skip-package-p jinx--predicates))

;;;; Enable certain "advanced" functions
(put 'downcase-region 'disabled nil)
(put 'upcase-region 'disabled nil)
(put 'scroll-left 'disabled nil)
(put 'scroll-right 'disabled nil)
(put 'dired-find-alternate-file 'disabled nil)

;; Enable mouse navigation between visited help-mode topics
(with-eval-after-load 'help-mode
  (keymap-set help-mode-map "<mouse-9>" #'help-go-forward)
  (keymap-set help-mode-map "<mouse-8>" #'help-go-back))

;; Bind "C-h M-k" to ‘find-function-on-key’, which is like "C-h k <key> s"
(keymap-set help-map "C-k" #'find-function-on-key)

;;;; Extensions: ‘multiple-cursors’
(use-package multiple-cursors
  :ensure t
  :demand t
  :bind
  (("C-$ l" . mc/edit-lines)
   ("C-$ a" . mc/mark-all-like-this)
   ("C-$ <down>" . mc/mark-more-like-this-extended)
   ("C-$ <up>" . mc/mark-more-like-this-extended)
   ;; There are more MC keybindings in the hydras ‘hydra-mc-*’
   ))

;;;; Extensions: ‘VEMCO’ Stack
(use-package vertico
  :ensure t

  :custom-face
  (vertico-group-title ((t (:inherit bold-italic))))

  :custom
  (vertico-scroll-margin 1)
  (vertico-count 10)
  (vertico-cycle t)
  (vertico-resize nil)

  (read-extended-command-predicate #'command-completion-default-include-p)
  (minibuffer-prompt-properties
   '(read-only t cursor-intangible t face minibuffer-prompt))

  :init
  (vertico-mode)
  (vertico-multiform-mode)
  (vertico-mouse-mode)

  :config

  (setopt vertico-multiform-commands
          '((consult-flymake buffer indexed)
            (embark-bindings buffer)))

  (setopt vertico-multiform-categories
          '((consult-grep buffer)
            (consult-location buffer)
            (imenu buffer))))

(use-package vertico-flat
  :after vertico
  :config
  (keymap-set vertico-flat-map "<remap> <left-char>" nil)
  (keymap-set vertico-flat-map "<remap> <right-char>" nil))

(use-package embark
  :ensure t
  :demand t
  :bind
  (("C-c e" . embark-act)
   ("C-h B" . embark-bindings))
  :init
  (setopt prefix-help-command #'embark-prefix-help-command)
  :config
  ;; Hide the mode line of the Embark live/completions buffers
  (add-to-list 'display-buffer-alist
               '("\\`\\*Embark Collect \\(Live\\|Completions\\)\\*"
                 nil
                 (window-parameters (mode-line-format . none)))))

(use-package embark-consult
  :ensure t)

(use-package marginalia
  :ensure t
  :custom
  (marginalia-align 'left)
  :init
  (marginalia-mode)

  :config
  ;; Reorder marginalia annotations to place doc strings first.  This is done by modifying
  ;; the marginalia.el annotation functions.
  (load "~/.config/emacs/marginalia-config.el"))

(use-package consult
  :ensure t
  :demand t
  :bind (;; C-c bindings in ‘mode-specific-map’
         ("C-c k" . consult-kmacro)
         ([remap Info-search] . consult-info)
         ;; Other custom bindings
         ("M-y" . consult-yank-pop)
         ;; M-g bindings in ‘goto-map’
         ("M-g f" . consult-flymake)
         ("M-g r" . consult-grep-match)
         ("M-g g" . consult-goto-line)
         ("M-g M-g" . consult-goto-line)
         ("M-g o" . consult-outline)
         ("M-g m" . consult-mark)
         ("M-g k" . consult-global-mark)
         ("M-g i" . consult-imenu)
         ("M-g I" . consult-imenu-multi)
         ;; M-s bindings in ‘search-map’
         ("M-s d" . a-t/consult-fd-home)
         ("M-s D" . consult-fd)
         ("M-s r" . consult-ripgrep)
         ("M-s l" . consult-line)
         ("M-s c" . consult-locate)
         ("M-s L" . consult-line-multi)
         :map isearch-mode-map
         ("M-e" . consult-isearch-history)
         ("M-s l" . consult-line)
         ("M-s L" . consult-line-multi))

  :init
  (setopt xref-show-xrefs-function #'consult-xref
          xref-show-definitions-function #'consult-xref)

  (defun a-t/consult-fd-home ()
    (interactive)
    (consult-fd (getenv "HOME")))

  (setopt consult-fd-args
          '("fd --color=never --hidden --follow --type file")

          consult-ripgrep-args
          '("rg --null --line-buffered --color=never --max-columns=1000 --path-separator /"
            "--smart-case --no-heading --with-filename --line-number --hidden")

          consult-find-args
          '("find -L . -type f")

          consult-grep-args
          '("grep" (consult--grep-exclude-args)
            "--null --line-buffered --color=never --ignore-case"
            "--with-filename --line-number -I -r"))

  :config
  (setopt consult-async-min-input 2)

  (when-let* ((entry (assoc 'perl consult-async-split-styles-alist)))
    (setf (cadr (memq :initial entry)) ?$))

  (defun consult-find-file-with-preview (prompt &optional dir default mustmatch initial pred)
    (interactive)
    (let ((default-directory (or dir default-directory))
          (minibuffer-completing-file-name t))
      (substitute-in-file-name
       (consult--read #'read-file-name-internal
                      :state (consult--file-preview)
                      :prompt prompt
                      :initial (abbreviate-file-name default-directory)
                      :require-match mustmatch
                      :predicate pred
                      :sort t
                      :preview-key '("M-*"
                                     :debounce 0.4 any)))))

  (setopt read-file-name-function #'consult-find-file-with-preview)

  (consult-customize
   consult-theme consult-git-grep consult-grep consult-man
   consult-bookmark consult-recent-file consult-source-bookmark
   consult-source-file-register consult-source-recent-file
   consult-source-project-recent-file
   consult-ripgrep
   :preview-key "M-*"

   consult-buffer consult-xref :preview-key 'any

   a-t/consult-fd-home consult-fd consult-find consult-locate
   :state (consult--file-preview)
   :sort t
   :preview-key '("M-*" :debounce 0.4 any)))

(use-package orderless
  :ensure t
  :config

  (orderless-define-completion-style orderless+initialism
    (orderless-matching-styles '(orderless-initialism orderless-literal orderless-regexp)))

  (orderless-define-completion-style orderless+flex
    (orderless-matching-styles '(orderless-flex orderless-literal orderless-regexp)))

  (setopt completion-styles '(orderless basic partial-completion emacs22)
          completion-category-defaults nil
          completion-category-overrides  '((file (styles orderless+flex))
                                           (buffer (styles orderless+flex))
                                           (command  (styles orderless+initialism))
                                           (bookmark (styles orderless+flex))
                                           ;; For consult-buffer:
                                           (multi-category (styles orderless+flex)))))

(defun consult--orderless-flex-regexp-compiler (input type ignore-case)
  (let* ((compiled (orderless-compile input '(orderless-flex)))
         (input (cdr compiled)))
    (cons
     (mapcar (lambda (r) (consult--convert-regexp r type)) input)
     (lambda (str)
       (let* ((fname (file-name-nondirectory str))
              (start (max 0 (- (length str) (length fname))))
              (hl (orderless--highlight input t (copy-sequence fname))))
        (let ((pos 0))
          (while (< pos (length hl))
            (let ((next (or (next-property-change pos hl) (length hl)))
                  (face (get-text-property pos 'face hl)))
              (when face
                (add-text-properties (+ start pos) (+ start next) `(face ,face) str))
              (setq pos next)))
          str))))))

(defun consult--find-file-with-orderless (&rest args)
  (let ((consult--regexp-compiler #'consult--orderless-flex-regexp-compiler))
    (apply args)))

(advice-add #'consult-fd :around #'consult--find-file-with-orderless)
(advice-add #'consult-find :around #'consult--find-file-with-orderless)

(defun consult--orderless-regexp-compiler (input type &rest _config)
  (setq input (cdr (orderless-compile input)))
  (cons
   (mapcar (lambda (r) (consult--convert-regexp r type)) input)
   (lambda (str) (orderless--highlight input t str))))

(defun consult--grep-with-orderless (&rest args)
  (let ((consult--regexp-compiler #'consult--orderless-regexp-compiler))
    (apply args)))

(advice-add #'consult-ripgrep :around #'consult--grep-with-orderless)
(advice-add #'consult-grep :around #'consult--grep-with-orderless)

;;;; Extensions: ‘nerd-icons’
(use-package nerd-icons
  :ensure t
  :demand t

  :config
  (dolist (entry '(("^Videos$"    nerd-icons-mdicon "nf-md-folder_play")
                   ("^Projects$"  nerd-icons-mdicon "nf-md-folder_open")
                   ("^Public$"    nerd-icons-mdicon "nf-md-earth")
                   ("^Templates$" nerd-icons-mdicon "nf-md-folder_file")
                   ("^Games$"     nerd-icons-mdicon "nf-md-gamepad_variant")
                   ("^Projects$" nerd-icons-octicon "nf-oct-project_roadmap")
                   ("^Etc$"       nerd-icons-mdicon "nf-md-dice_multiple")))
    (add-to-list 'nerd-icons-dir-icon-alist entry)))

(use-package nerd-icons-dired
  :ensure t
  :after (nerd-icons dired)
  :hook
  (dired-mode-hook . nerd-icons-dired-mode))

(use-package nerd-icons-completion
  :ensure t
  :demand t
  :init
  (nerd-icons-completion-mode))

(use-package nerd-icons-grep
  :ensure t
  :after (nerd-icons grep)
  :init
  (nerd-icons-grep-mode))

;;;; Extensions: ‘avy’
(use-package avy
  :ensure t
  :demand t
  :bind
  (("C-;" . avy-goto-char-timer)
   (:map isearch-mode-map ("C-;" . avy-isearch)))

  :config
  (setopt avy-keys '(?q ?s ?d ?f ?g ?h ?j ?k ?l ?m) ; AZERTY
          avy-background t
          avy-all-windows 'all-frames
          avy-timeout-seconds 0.3
          avy-orders-alist '((avy-goto-char-timer . avy-order-closest)
                             (avy-isearch . avy-order-closest))
          avy-single-candidate-jump nil)

  (defun avy-action-kill-whole-line (pt)
    (save-excursion
      (goto-char pt)
      (kill-whole-line))
    (select-window
     (cdr
      (ring-ref avy-ring 0)))
    t)

  (defun avy-action-copy-whole-line (pt)
    (save-excursion
      (goto-char pt)
      (cl-destructuring-bind (start . end)
          (bounds-of-thing-at-point 'line)
        (copy-region-as-kill start end)))
    (select-window
     (cdr
      (ring-ref avy-ring 0)))
    t)

  (defun avy-action-yank-whole-line (pt)
    (avy-action-copy-whole-line pt)
    (save-excursion (yank))
    t)

  (defun avy-action-teleport-whole-line (pt)
    (avy-action-kill-whole-line pt)
    (save-excursion (yank)) t)

  (defun avy-action-mark-to-char (pt)
    (activate-mark)
    (goto-char pt))

  (defun avy-action-embark (pt)
    (unwind-protect
        (save-excursion
          (goto-char pt)
          (embark-act))
      (select-window
       (cdr (ring-ref avy-ring 0))))
    t)

  (defun avy-action-xref-definitions (pt)
    (unwind-protect
        (save-excursion
          (goto-char pt)
          (xref-find-definitions (thing-at-point 'symbol)))
      (select-window
       (cdr (ring-ref avy-ring 0))))
    t)

  (defun avy-action-xref-references (pt)
    (unwind-protect
        (save-excursion
          (goto-char pt)
          (xref-find-references (thing-at-point 'symbol)))
      (select-window
       (cdr (ring-ref avy-ring 0))))
    t)

  (defun avy-show-dispatch-help ()
    "Display available avy actions in a grid, and fontify the keys."
    (let* ((len (length "avy-action-"))
           (fw (frame-width))
           (raw-strings (mapcar
                         (lambda (x)
                           (let* ((key (car x))
                                  (key-str (if (eq key ? ) "SPC" (char-to-string key))))
                             (format "%3s:%-20s"
                                     (propertize key-str 'face 'font-lock-builtin-face)
                                     (substring (symbol-name (cdr x)) len))))
                         avy-dispatch-alist))
           (max-len (1+ (apply #'max (mapcar #'length raw-strings))))
           (strings-len (length raw-strings))
           (per-row (floor fw max-len))
           display-strings)
      (cl-loop for string in raw-strings
               for N from 1 to strings-len do
               (push (concat string " ") display-strings)
               (when (= (mod N per-row) 0) (push "\n" display-strings)))
      (message "%s" (apply #'concat (nreverse display-strings)))))

  (when-let* ((entry (assoc ?n avy-dispatch-alist)))
    (setcar entry ?c))
  (setf (alist-get ?y avy-dispatch-alist) 'avy-action-yank
        (alist-get ?Y avy-dispatch-alist) 'avy-action-yank-whole-line
        (alist-get ?w avy-dispatch-alist) 'avy-action-copy-whole-line
        (alist-get ?W avy-dispatch-alist) 'avy-action-kill-whole-line
        (alist-get ?T avy-dispatch-alist) 'avy-action-teleport-whole-line
        (alist-get ?  avy-dispatch-alist) 'avy-action-mark-to-char
        (alist-get ?! avy-dispatch-alist) 'avy-action-embark
        (alist-get ?. avy-dispatch-alist) 'avy-action-xref-definitions
        (alist-get ?: avy-dispatch-alist) 'avy-action-xref-references))

;;;; Extensions: ‘zygospore’
(use-package zygospore
  :ensure t)

;;;; Extensions: ‘hydra’
(use-package hydra
  :ensure t
  :config
  (defhydra hydra-mc-word (global-map "C-$ w")
    "Multiple-cursors word"
    (">" mc/mark-next-like-this-word "next word")
    ("<" mc/mark-previous-like-this-word "previous word")
    ("q" nil "Quit"))

  (defhydra hydra-mc-symbol (global-map "C-$ s")
    "Multiple-cursors symbol"
    (">" mc/mark-next-like-this-symbol "next symbol")
    ("<" mc/mark-previous-like-this-symbol "previous symbol")
    ("q" nil "Quit"))

  (defhydra hydra-buffers-and-windows (global-map "C-x")
    "Manage windows and buffers."
    ("<left>" windmove-left "Move to left window" :column "Movement")
    ("<right>" windmove-right "Move to right window" :column "Movement")
    ("<up>" windmove-up "Move to window above" :column "Movement")
    ("<down>" windmove-down "Move to window below" :column "Movement")
    ("k" kill-current-buffer "Kill current buffer" :column "Buffer")
    ("C-f" find-file "Find file" :color blue :column "Buffer")
    ("C-s" save-buffer "Save" :color blue :column "Buffer")
    ("b" consult-buffer "Switch to buffer" :color blue :column "Buffer")
    ("d" dired "Dired" :color blue :column "Buffer")
    ("C-d" dired "Dired" :color blue :column "Buffer")
    ("0" delete-window "Delete current window" :color blue :column "Windows")
    ("1" zygospore-toggle-delete-other-windows "Toggle other windows" :column "Windows")
    ("2" split-window-below "Split window below" :column "Windows")
    ("3" split-window-right "Split window to the right" :column "Windows")
    ("q" nil "Quit" :column "Quit")
    ("RET" nil "Quit" :column "Quit")))

;;;; Extensions: ‘vundo’
(use-package vundo
  :ensure t
  :config
  (setopt vundo-glyph-alist vundo-unicode-symbols
          vundo-popup-time 4.0))

;;;; Extensions: ‘magit’
(use-package magit
  :ensure t
  :init
  (setopt vc-follow-symlinks t))

(use-package forge
  :ensure t
  :after magit)

;;;; Extensions: ‘expand-region’
(use-package expand-region
  :ensure t
  :bind
  (("C-c m" . er/expand-region)
   ("C-c s" . er/mark-symbol)))

;;;; Extensions: ‘no-littering’
(use-package no-littering
  :ensure t)

;;; ‘Gnus’
(load "~/.config/emacs/gnus-config.el")

;;;; Extensions: ‘elfeed’
(load "~/.config/emacs/elfeed-config")

;;;; Extensions: ‘agent-shell’
(use-package agent-shell
  :ensure t
  :bind
  (:map agent-shell-mode-map (("C-c C-c" . nil)
                              ("C-c C-k" . agent-shell-interrupt)))
  :custom
  (agent-shell-opencode-default-model-id "opencode/big-pickle")
  (agent-shell-thought-process-expand-by-default t))

;;;; Extensions: ‘page-break-line’
(use-package page-break-lines
  :ensure t
  :init
  (global-page-break-lines-mode)
  :config
  (add-to-list 'page-break-lines-modes 'c-mode))

;;;; Extensions: ‘highlight-doxygen’
(use-package highlight-doxygen
  :ensure t
  :custom-face
  (highlight-doxygen-comment ((t (:background unspecified))))
  :config
  (highlight-doxygen-global-mode))

;;;; Extensions: ‘eldoc-box’
(use-package eldoc-box
  :ensure t
  :custom-face
  (eldoc-box-border ((t (:background "#ffffff" :weight bold))))
  (eldoc-box-body ((t (:background "#0d0e1c"))))
  :bind
  (:map global-map
        ("C-*" . eldoc-box-help-at-point))
  :config
  :custom
  (eldoc-box-clear-with-C-g t)
  (eldoc-box-max-pixel-width 750)
  (eldoc-box-max-pixel-height 350)
  (eldoc-documentation-strategy 'eldoc-documentation-compose-eagerly)
  (eldoc-idle-delay 1))

;;;; Extensions: ‘minions’
(use-package minions
  :ensure t
  :init
  (minions-mode t)
  :config
  (setopt mode-line-modes-delimiters nil
          minions-mode-line-lighter " "
          minions-prominent-modes '(flymake-mode)))

;;;; Extensions: ‘xr’
(use-package xr
  :ensure t)

;;;; Extensions: ‘auto-capitalize’ (from user-lisp)
(use-package auto-capitalize
  :init
  (auto-capitalize-global-mode)

  :config
  (modify-syntax-entry ?' ".   " text-mode-syntax-table)
  (modify-syntax-entry ?’ ".   " text-mode-syntax-table))

;;;; Extensions: ‘auto-read-only’ (from user-lisp)
(use-package auto-read-only
  :init
  (auto-read-only-mode 1)
  :config
  (add-to-list 'auto-read-only-file-regexps
               (rx (literal (expand-file-name find-function-C-source-directory)))))

;;;; Extensions: ‘beginend’
(use-package beginend
  :ensure t
  :init
  (beginend-global-mode))

;;;; Extensions: ‘lorem-ipsum’
(use-package lorem-ipsum
  :ensure t)

;;;; Extensions: ‘move-text’
(use-package move-text
  :ensure t
  :config
  (move-text-default-bindings))

;;;; Extensions: ‘whole-line-or-region’
(use-package whole-line-or-region
  :ensure t

  :init
  (whole-line-or-region-global-mode)

  :config
  (push 'whole-line-or-region-kill-region pulsar-pulse-functions)
  (push 'whole-line-or-region-kill-region pulsar-pulse-region-functions)
  (push 'whole-line-or-region-kill-ring-save pulsar-pulse-region-functions)

  ;; Based on
  ;; https://github.com/purcell/whole-line-or-region/issues/16#issuecomment-870494559
  (defun a-t/comment-whole-line-or-region (prefix)
    "Wrapper around ‘whole-line-or-region-comment-dwim-2’.

The original function does nothing on empty lines. This fixes that by
calling ‘comment-dwim’ in that case."

    (interactive "*P")
    (if (a-t/current-line-empty-p)
        (call-interactively 'comment-dwim)
      (call-interactively 'whole-line-or-region-comment-dwim-2)))

  (defun a-t/current-line-empty-p ()
    "Check whether the current line is empty."
    (save-excursion
      (beginning-of-line)
      (looking-at-p "[[:blank:]]*$")))

  :bind
  ("M-;" . a-t/comment-whole-line-or-region))

;;;; Extensions: ‘wiki-summary’
(use-package wiki-summary
  :ensure t)

;;;; Extensions: ‘show-font’
(use-package show-font
  :ensure t
  :config
  (add-to-list 'show-font-arabic-families "Kawkab Mono")
  (add-to-list 'show-font-arabic-families "Amiri")
  (add-to-list 'show-font-arabic-families "Amiri Quran")
  (add-to-list 'show-font-arabic-families "Amiri Quran Colored")

  (add-to-list 'show-font-japanese-families "IPAexGothic")
  (add-to-list 'show-font-japanese-families "IPAexMincho")
  (add-to-list 'show-font-japanese-families "HanaMinA")
  (add-to-list 'show-font-japanese-families "HanaMinB")

  (add-to-list 'show-font-korean-families "KoPubBatang")
  (add-to-list 'show-font-korean-families "KoPubDotum")

  (add-to-list 'show-font-chinese-families "LXGW Neo XiHei")
  (add-to-list 'show-font-chinese-families "AR PL UMing CN")
  (add-to-list 'show-font-chinese-families "AR PL UMing HK")
  (add-to-list 'show-font-chinese-families "AR PL UMing TW")
  (add-to-list 'show-font-chinese-families "AR PL UMing TW MBE"))

;;; Misc: ‘fortune’
(use-package fortune
  :custom
  (fortune-dir "~/Etc/fortunes/")
  :config
  (advice-add 'fortune :after (lambda (&optional _file)
                                (view-mode))))

;;;; Misc: ‘grep’
(use-package grep
  :custom
  (grep-use-headings t))

;;; Custom faces

(load "~/.config/emacs/faces-config.el")

;;; Automated

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   '(agent-shell auctex avy beginend dired-preview diredfl ef-themes eldoc-box elfeed-tube
                 embark-consult expand-region forge highlight-doxygen hydra jinx json-mode
                 lorem-ipsum marginalia minions modus-themes move-text multiple-cursors
                 nerd-icons nerd-icons-completion nerd-icons-dired nerd-icons-grep
                 no-littering olivetti orderless org-appear org-bullets
                 package-lint-flymake page-break-lines pdf-tools pdffontetc pulsar
                 show-font tuareg vertico vundo whole-line-or-region wiki-summary
                 ws-butler xr yasnippet zygospore))
 '(send-mail-function 'smtpmail-send-it))

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
;; Local Variables:
;; jinx-local-words: "init lp"
;; End:
