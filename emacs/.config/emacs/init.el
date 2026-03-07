;;; -*- lexical-binding: t -*-

;;; Server/Client architecture

(use-package server)
(unless (server-running-p)
  (server-start))

;;; General emacs settings
(setopt inhibit-splash-screen t
        visible-bell nil
        initial-scratch-message nil)

(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)

(global-visual-line-mode 1)
(global-word-wrap-whitespace-mode 1)

(add-hook 'prog-mode-hook #'completion-preview-mode)
(add-hook 'text-mode-hook #'completion-preview-mode)
(with-eval-after-load 'completion-preview
  (push 'org-self-insert-command completion-preview-commands)
  (setopt completion-preview-minimum-symbol-length 2)
  (keymap-set completion-preview-active-mode-map
              "M-n" #'completion-preview-next-candidate)
  (keymap-set completion-preview-active-mode-map
              "M-<down>" #'completion-preview-next-candidate)
  (keymap-set completion-preview-active-mode-map
              "M-p" #'completion-preview-prev-candidate)
  (keymap-set completion-preview-active-mode-map
              "M-<up>" #'completion-preview-prev-candidate))

(global-set-key (kbd "C-+") 'text-scale-increase)
(global-set-key (kbd "C--") 'text-scale-decrease)
(global-set-key (kbd "<C-wheel-down>") 'text-scale-decrease)
(global-set-key (kbd "<C-wheel-up>") 'text-scale-increase)

(electric-pair-mode 1)
(delete-selection-mode 1)
(setopt fill-column 90)

;; Replace tabs with spaces
(add-hook 'prog-mode-hook
          (lambda ()
            (unless (derived-mode-p 'makefile-gmake-mode)
              (indent-tabs-mode -1))))

(global-auto-revert-mode 1)

(column-number-mode 1)
(setopt column-number-indicator-zero-based nil)
(setopt mode-line-percent-position nil)

;; Spellchecking
(add-hook 'text-mode-hook #'flyspell-mode)
; In prog-mode, only check spelling in strings & comments
(add-hook 'prog-mode-hook #'flyspell-prog-mode)

;; From https://stackoverflow.com/questions/3631220/fix-to-get-smooth-scrolling-in-emacs
(setopt scroll-margin 1
        scroll-step 1
        scroll-conservatively 101
        scroll-preserve-screen-position 1)
;; scroll one line at a time (less "jumpy" than defaults)
(setopt mouse-wheel-scroll-amount '(1 ((shift) . 1)) ; one line at a time
        mouse-wheel-progressive-speed nil)           ; don't accelerate scrolling
(setq-default smooth-scroll-margin 0)

;; Display a counter in I-search, showing total number of matches, as well as the current
;; position in them. Taken from Protesilaos Stavrou
(setopt isearch-lazy-count t
        lazy-count-prefix-format "(%s/%s) "
        lazy-count-suffix-format nil
        search-whitespace-regexp ".*?")

(setopt confirm-kill-processes nil
        use-short-answers t
        view-read-only t)

;; Augment default C-g behavior
(defun prot/keyboard-quit-dwim ()
  "Do-What-I-Mean behaviour for a general `keyboard-quit'.

The generic `keyboard-quit' does not do the expected thing when the
minibuffer is open.  Whereas we want it to close the minibuffer, even
without explicitly focusing it.

The DWIM behaviour of this command is as follows:

- When the region is active, disable it.  When a minibuffer is open, but
- not focused, close the minibuffer.  When the Completions buffer is
- selected, close it.  In every other case use the regular
- `keyboard-quit'."
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
(keymap-global-set "C-z" 'undo)

(keymap-global-set "M-?" 'xref-find-definitions)
(keymap-global-set "M-." 'xref-find-references)

;; Enable certain "advanced" functions
(put 'downcase-region 'disabled nil)
(put 'upcase-region 'disabled nil)
(put 'scroll-left 'disabled nil)
(put 'scroll-right 'disabled nil)


(setopt use-package-hook-name-suffix nil)

;;; Theme & style

(setq-default cursor-type 'box)

(add-hook 'text-mode-hook
          (lambda ()
            (setq-local cursor-type 'bar)))

;; Customize modeline
(load "~/.config/emacs/mode-line-config.el")

(use-package ef-themes
  :init
  (ef-themes-take-over-modus-themes-mode 1)
  :config
  (setopt modus-themes-mixed-fonts t)
  (setopt modus-themes-bold-constructs t
          modus-themes-italic-constructs t
          modus-themes-prompts '(ultrabold))

  (setopt modus-themes-common-palette-overrides
          '((cursor fg-main)
            (string red-faint)
            (comment fg-dim)
            (bg-hover fg-active)
            (fg-prompt cyan)
            (fg-mode-line-active fg-main)
            (bg-mode-line-active "#2f2c39")
            (bg-mode-line-inactive "#17161c")
            ))
  (modus-themes-load-theme 'ef-dark))

;; [WIP] Make background transparent, unless in fullscreen
(push '(alpha-background . 100) default-frame-alist)

;; (defun scion/change-alpha-background-on-fullscreen (frame)
;;   (let ((fullscreen  (frame-parameter frame 'fullscreen)))
;;     (when (memq fullscreen '(fullscreen fullboth))
;;       (set-background-color 'white))))

;; Pulsar: flash current line on certain window changes
(use-package pulsar
  :config
  (setopt pulsar-face 'pulsar-magenta
          pulsar-region-face 'pulsar-magenta
          pulsar-region-change-face 'pulsar-magenta
          pulsar-highlight-face 'pulsar-magenta))
(pulsar-global-mode 1)

(defface custom-hl-line-face
  '((t (:box nil
        :inherit 'default)))
  "Face for hl-line, as well as minibuffer augmentations (vertico et al.).")

(set-face-background 'custom-hl-line-face (face-background 'mode-line))

(use-package hl-line
  :custom-face
  (hl-line ((t (:background unspecified :inherit 'custom-hl-line-face))))
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
   tabulated-list-mode-hook))

(add-hook 'hl-line-mode-hook
          (lambda ()
            (setq-local cursor-type nil
                        column-number-mode (not hl-line-mode))
            (pulsar-mode -1)
            (visual-line-mode -1)))

;;; Org mode
(load "~/.config/emacs/org-config")

;;; Programming

(setopt compilation-scroll-output t
        treesit-font-lock-level 4)

(use-package autoinsert
  ; Builtin, used to automatically insert header guards & includes in C++ files
  :init
  (auto-insert-mode t)
  :config
  (setopt auto-insert-query nil))

(use-package flymake
  ;; Builtin, used for syntax checking. Disable its
  ;; modeline lighter "Flymake", but keep the error
  ;; counters
  :config
  (setopt flymake-mode-line-lighter ""))

;; Trim extraneous whitespaces in code files
(use-package ws-butler
  :hook (prog-mode-hook . ws-butler-mode))

;; Use treesitter for bash, C, & C++ in order to ensure accurate syntax highlighting
(setopt major-mode-remap-alist
        '((sh-mode . bash-ts-mode)
          (c-mode . c-ts-mode)
          (c++-mode . c++-ts-mode)
          (c-or-c++-mode . c-or-c++-ts-mode)))

(setq treesit-language-source-alist
      '((c "https://github.com/tree-sitter/tree-sitter-c")
        (cpp "https://github.com/tree-sitter/tree-sitter-cpp")))

;; ede: emacs development environment
(add-hook 'prog-mode-hook #'global-ede-mode)

;; Required to get proper auto-completion (e.g. for () after function names) with eglot &
;; clangd
(use-package yasnippet
  :config
  (yas-global-mode 1))

(use-package eglot
  :custom-face
  (eglot-mode-line ((t (:weight regular :foreground ,(face-foreground 'default)))))
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
  (add-to-list 'auto-mode-alist '("\\.h$" . c++-mode))
  (setopt eglot-autoshutdown t
          eglot-extend-to-xref t
          eglot-code-action-indications '(margin)
          eglot-events-buffer-config '(:size 0))
  )

;; Use quickrun, which enables programming language interpretation on the fly.
;; quickrun-shell is useful for programs requiring user input (via std::cin for example),
;; as such programs fail if run with quickrun.  This also covers C++, and other "C-like
;; languages" according to treesitter.el documentation.
(with-eval-after-load "c-ts-mode"
  (keymap-set c-ts-base-mode-map "C-c C-r C-r" #'quickrun)
  (keymap-set c-ts-base-mode-map "C-c C-r C-s" #'quickrun-shell)
  (keymap-set c-ts-base-mode-map "RET" #'electric-indent-just-newline))

(add-hook 'c++-ts-mode-hook
          (lambda ()
            (setopt c-ts-mode-indent-offset 6)
            (setopt indent-tabs-mode nil)))

(with-eval-after-load 'eglot
  (add-to-list 'eglot-ignored-server-capabilities :documentOnTypeFormattingProvider)
  (add-to-list 'eglot-ignored-server-capabilities :documentHighlightProvider)
  (add-hook 'eglot-managed-mode-hook (lambda()
                                       (eglot-semantic-tokens-mode -1))))

(use-package json-mode)
(add-to-list 'auto-mode-alist '("\\.jsonc\\'" . json-mode))

(use-package markdown-mode
  :custom-face

  )

;; Enable auctex to support common latex packages
(use-package auctex
  :hook tex-mode-hook
  :config
  (setopt tex-auto-save t
          tex-parse-self t
          tex-master nil))

;; Use pdf-tools as an emacs-native pdf viewer
(use-package pdf-tools
  :mode ("\\.pdf\\'" . pdf-view-mode)
  :hook (pdf-view-mode-hook . pdf-misc-minor-mode)
  :config
  (setopt pdf-info-epdfinfo-program "/usr/local/bin/epdfinfo"))

(setopt TeX-view-program-selection '((output-pdf "PDF Tools"))
        TeX-source-correlate-start-server t)

(setopt pdf-misc-print-program-executable "lp")

(add-hook 'TeX-after-compilation-finished-functions
          #'TeX-revert-document-buffer)

;;; Other QOL packages & extensions

;;;; Melpa
(progn
  (require 'package)
  ;; add melpa repository.
  (add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
  (when (< emacs-major-version 27) (package-initialize)))

;;;; Dired
;; Enable long listing in dired, sort directories before other files,
;; use human-readable file sizes (kb, gb, etc), and don't show hidden files.
(setq-default dired-listing-switches "-alh --group-directories-first")

(use-package dired
  :demand t
  :init
  (require 'dired-x)
  :bind
  (:map dired-mode-map
        ("M-o" . dired-omit-mode))
  :hook
  (dired-mode-hook . dired-omit-mode)
  (dired-mode-hook . (lambda()
                       (set-face-attribute 'dired-directory nil
                                           :foreground (face-foreground 'font-lock-keyword-face))))
  :config
  (setopt dired-auto-revert-buffer t)
  (setopt dired-omit-files
          (concat (default-value 'dired-omit-files) "\\|^\\..+$"))
  )

;; Enable mouse navigation between visited help-mode topics
(add-hook 'help-mode-hook
          (lambda ()
            (keymap-set help-mode-map
                        "<mouse-9>" #'help-go-forward)
            (keymap-set help-mode-map
                        "<mouse-8>" #'help-go-back)))

;;;; Extensions: multiple-cursor
(use-package multiple-cursors
  :bind
  (("C-$ l" . mc/edit-lines)
   ("C-$ a" . mc/mark-all-like-this)
   ("C-$ <down>" . mc/mark-more-like-this-extended)
   ("C-$ <up>" . mc/mark-more-like-this-extended)
   ;; There are more MC keybindings in the hydras hydra-mc-*
   ))

;;;; Extensions: VEMCO Stack
(use-package vertico
  :custom-face
  (vertico-group-title ((t (:inherit bold-italic))))
  :custom
  (vertico-scroll-margin 1)
  (vertico-count 10)
  (vertico-cycle t)
  (vertico-resize nil)
  :init
  (vertico-mode)
  (vertico-mouse-mode)
  :config
  (set-face-attribute 'vertico-current nil :inherit 'custom-hl-line-face))

(use-package embark
  :bind
  (("C-ù" . embark-act)         ;; pick some comfortable binding
   ("M-ù" . embark-dwim)        ;; good alternative: M-.
   ("C-h B" . embark-bindings)) ;; alternative for `describe-bindings'

  :init

  ;; Optionally replace the key help with a completing-read interface
  (setq prefix-help-command #'embark-prefix-help-command)

  ;; Show the Embark target at point via Eldoc. You may adjust the
  ;; Eldoc strategy, if you want to see the documentation from
  ;; multiple providers. Beware that using this can be a little
  ;; jarring since the message shown in the minibuffer can be more
  ;; than one line, causing the modeline to move up and down:

  ;; (add-hook 'eldoc-documentation-functions #'embark-eldoc-first-target)
  ;; (setq eldoc-documentation-strategy #'eldoc-documentation-compose-eagerly)

  ;; Add Embark to the mouse context menu. Also enable `context-menu-mode'.
  ;; (context-menu-mode 1)
  ;; (add-hook 'context-menu-functions #'embark-context-menu 100)

  :config

  ;; Hide the mode line of the Embark live/completions buffers
  (add-to-list 'display-buffer-alist
               '("\\`\\*Embark Collect \\(Live\\|Completions\\)\\*"
                 nil
                 (window-parameters (mode-line-format . none)))))

;; Consult users will also want the embark-consult package.
(use-package embark-consult) ; only need to install it, embark loads it after consult if found

(use-package marginalia
  :custom
  (marginalia-align 'left)
  :init
  (marginalia-mode)

  :config
  ;; Reorder marginalia annotations to place docstrings first.  This
  ;; is done by modifying the marginalia.el annotation functions.
  (load "~/.config/emacs/marginalia-config.el")
  )

(use-package consult
  :bind (;; C-c bindings in `mode-specific-map'
         ("C-c k" . consult-kmacro)
         ("C-c m" . consult-man)
         ("C-c i" . consult-info)
         ([remap Info-search] . consult-info)
         ;; Custom bindings
         ("C-M-:" . consult-fd)
         ("C-:" . scion/consult-fd-home)
         ;; C-x bindings in `ctl-x-map'
         ("C-x b" . consult-buffer)
         ("C-x 4 b" . consult-buffer-other-window)
         ("C-x 5 b" . consult-buffer-other-frame)
         ("C-x p b" . consult-project-buffer)
         ;; Other custom bindings
         ("M-y" . consult-yank-pop)
         ;; M-g bindings in `goto-map'
         ("M-g f" . consult-flymake)
         ("M-g e" . consult-compile-error)
         ("M-g r" . consult-grep-match)
         ("M-g g" . consult-goto-line)
         ("M-g M-g" . consult-goto-line)
         ("M-g o" . consult-outline)
         ("M-g m" . consult-mark)
         ("M-g k" . consult-global-mark)
         ("M-g i" . consult-imenu)
         ("M-g I" . consult-imenu-multi)
         ;; M-s bindings in `search-map'
         ("M-s r" . consult-ripgrep)
         ("M-s l" . consult-line)
         ("M-s L" . consult-line-multi)
         ;; Isearch integration
         :map isearch-mode-map
         ("M-e" . consult-isearch-history)
         ("M-s e" . consult-isearch-history)
         ("M-s l" . consult-line)
         ("M-s L" . consult-line-multi)
	 )

  :init

  ;; Use Consult to select xref locations with preview
  (setopt xref-show-xrefs-function #'consult-xref
          xref-show-definitions-function #'consult-xref)

  (setopt consult-fd-args
          `(,(if (executable-find "fdfind" 'remote) "fdfind" "fd")
            "--color=never" "--hidden" "--follow" "--type file")
          consult-ripgrep-args
          '("rg --null --line-buffered --color=never --max-columns=1000 --path-separator / --smart-case --no-heading --with-filename --line-number --hidden"))

  ;; This wrapper is defined under :init because it is bound to C-: under :bind
  ;; Emacs must know about it in advance before consult is loaded
  (defun scion/consult-fd-home()
    "Call consult-fd at ~"
    (interactive)
    (consult-fd (getenv "HOME")))

  :config
  (setopt consult-async-min-input 2)
  (setq completion-in-region-function #'consult-completion-in-region)

  (setq consult-async-split-styles-alist
        (append
         (list
          (cons 'perl-dollar
                (list :initial ?$ :function #'consult--split-perl)))
         consult-async-split-styles-alist))
  (setq consult-async-split-style 'perl-dollar)

  (consult-customize
   consult-theme consult-ripgrep consult-git-grep consult-grep consult-man
   consult-bookmark consult-recent-file consult-xref consult-source-bookmark
   consult-source-file-register consult-source-recent-file
   consult-source-project-recent-file
   :preview-key '("M-*" :debounce 0.6 any)

   ;; Enable file previewing in consult-fd wrapper, and sort its output
   scion/consult-fd-home :state (consult--file-preview) :sort t :preview-key '("M-*" :debounce 0.6 any)
  ))

(defun consult-find-file-with-preview (prompt &optional dir default mustmatch initial pred)
  "Enable consult previewing in find-file, dired, etc."
  (interactive)
  (let ((default-directory (or dir default-directory))
        (minibuffer-completing-file-name t))
    (consult--read #'read-file-name-internal
                   :state (consult--file-preview)
                   :prompt prompt
                   :initial (abbreviate-file-name default-directory)
                   :require-match mustmatch
                   :predicate pred)))
(setq read-file-name-function #'consult-find-file-with-preview)

(use-package orderless
  :config

  (orderless-define-completion-style orderless+flex
    (orderless-matching-styles '(orderless-flex)))

  (setq completion-category-defaults nil)
  (setopt completion-styles '(orderless partial-completion substring basic)
          orderless-matching-styles '(orderless-initialism orderless-regexp orderless-literal)
          completion-category-overrides '((file (styles orderless+flex))
                                          (buffer (styles orderless+flex)))))

(defun consult--orderless-flex-regexp-compiler (input type ignore-case)
  "Compile INPUT into Consult regexps and a highlight function. Uses
orderless-flex for file completion."
  (let* ((styles (if minibuffer-completing-file-name
                     '(orderless-flex)
                   orderless-matching-styles))
         (compiled (orderless-compile input styles)))
    (setq input (cdr compiled))
    (cons
     (mapcar (lambda (r) (consult--convert-regexp r type)) input)
     (lambda (str)
       (let* ((fname (file-name-nondirectory str))
              (start (max 0 (- (length str) (length fname))))
              (hl (orderless--highlight input t (copy-sequence fname))))
         (let ((pos 0))
           (while (< pos (length hl))
             (let* ((next (or (next-property-change pos hl) (length hl)))
                    (face (get-text-property pos 'face hl)))
               (when face
                 (add-text-properties (+ start pos) (+ start next) `(face ,face) str))
               (setq pos next)))
           str))))))

(defun consult-fd--with-orderless (&rest args)
  "Enable orderless style matching for consult-fd & consult-find."
  (minibuffer-with-setup-hook
      (lambda ()
        (setq-local consult--regexp-compiler #'consult--orderless-flex-regexp-compiler
                    minibuffer-completing-file-name t))
    (apply args)))

(advice-add #'consult-fd :around #'consult-fd--with-orderless)
(advice-add #'consult-find :around #'consult-fd--with-orderless)

;;;; Extensions: nerd-icons
(use-package nerd-icons
  :demand t)

(use-package nerd-icons-dired
  :hook
  (dired-mode-hook . nerd-icons-dired-mode))

(use-package nerd-icons-completion
  :demand t
  :init
  (nerd-icons-completion-mode)
  :config
  (set-face-attribute 'nerd-icons-completion-dir-face nil
                      :foreground (face-foreground 'font-lock-keyword-face)))

(defun scion/set-custom-faces ()
  (set-face-attribute 'nerd-icons-completion-dir-face nil
                       :foreground (face-foreground 'font-lock-keyword-face))
  (set-face-attribute 'mode-line nil :inherit 'variable-pitch :box 'nil)
  (set-face-attribute 'mode-line-active nil :inherit 'variable-pitch :box 'nil)
  (set-face-attribute 'mode-line-inactive nil :inherit 'variable-pitch :box 'nil)

  (set-face-attribute 'vc-state-base nil :inherit 'variable-pitch)
  (set-face-attribute 'vc-edited-state nil :inherit 'variable-pitch :slant 'italic)
  (set-face-attribute 'vc-locked-state nil :inherit 'variable-pitch)

  (set-face-attribute 'consult-highlight-match nil :background 'nil :foreground "#8a2be2" :weight 'bold)

  (add-hook 'eglot-managed-mode-hook (lambda ()
				       (set-face-attribute 'markdown-header-face-3 nil :foreground (face-foreground 'font-lock-keyword-face))
				       (set-face-attribute 'markdown-inline-code-face nil :foreground (face-foreground 'font-lock-variable-name-face) :weight 'regular)))
  )

(if (daemonp)
    (add-hook 'after-make-frame-functions
	      (defun my/icon-init-daemon (frame)
		(with-selected-frame frame
		  (scion/set-custom-faces))
		(remove-hook 'after-make-frame-functions
			     #'my/icon-init-daemon)
		(fmakunbound 'my/icon-init-daemon)))
  (scion/set-default-faces))

;;;; Extensions: hydra
(use-package hydra
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
    ("b" consult-buffer "Switch buffer" :color blue :column "Buffer")
    ("d" dired "Dired" :color blue :column "Buffer")
    ("0" delete-window "Delete current window" :color blue :column "Windows")
    ("1" delete-other-windows "Delete other windows" :color blue :column "Windows")
    ("2" split-window-below "Split window below" :column "Windows")
    ("3" split-window-right "Split window to the right" :column "Windows")
    ("q" nil "Quit" :column "Quit")
    ("RET" nil "Quit" :column "Quit"))

  (with-eval-after-load 'eglot
    (defhydra hdyra-eglot-and-ede (eglot-mode-map "C-c .")
      "Eglot & EDE actions."
      ("t" ede-new-target "New target" :column "Setup" :color blue)
      ("a" ede-add-file "Add to target" :column "Setup")
      ("RET" eglot-format-buffer "Format buffer" :column "Build")
      ("C" ede-compile-project "Compile project" :column "Build")
      ("c" ede-compile-target "Compile project" :column "Build")
      ("r" ede-run-target "Run target" :column "Build" :color blue)
      ("d" ede-remove-file "Remove from target" :column "Clean up")
      ("e" ede-edit-file-target "Edit Project.ede" :column "Clean up")
      ("q" nil "Quit" :color blue :column "Other")
      ("1" flymake-show-buffer-diagnostics "Diagnostics window" :color blue :column "Clean up")))
  )

;;;; Extensions: Vundo
(use-package vundo
  :hook
  (prog-mode-hook . vundo-popup-mode)
  (text-mode-hook . vundo-popup-mode)
  :config
  (setopt vundo-glyph-alist vundo-unicode-symbols
          vundo-popup-time 4.0))

;;;; Extensions: Magit
(use-package magit
  :init
  (setopt vc-follow-symlinks t))

;;;; Extensions: expand-region
(use-package expand-region)
(keymap-global-set "C-=" 'er/expand-region)

;;;; Extensions: no-littering
(use-package no-littering)

;;;; Extensions: elfeed
(load "~/.config/emacs/elfeed-config")

;;;; Extensions: agent-shell
(use-package agent-shell)

;;;; Extensions: page-break-line
(use-package page-break-lines
  :config
  (global-page-break-lines-mode))

;;;; Extensions: highlight-doxygen
(use-package highlight-doxygen
  :custom-face
  (highlight-doxygen-comment ((t (:background unspecified))))
  :config
  (highlight-doxygen-global-mode 1))

;;;; Extensions: eldoc-box
(use-package eldoc-box
  :custom-face
  (eldoc-box-border ((t (:background "#ffffff" :weight bold))))
  (eldoc-box-body ((t (:background "#0d0e1c"))))

  :bind
  (:map global-map  ("C-*" . eldoc-box-toggle)
        ("M-<up>" . eldoc-box-scroll-down)
        ("M-<down>" . eldoc-box-scroll-up))

  :config

  (defun eldoc-box-toggle ()
    "Toggle eldoc-box visibility."
    (interactive)
    (if (eldoc-box--frame-visible-p)
        (eldoc-box-quit-frame)
      (eldoc-box-help-at-point)))

  :custom
  (eldoc-box-clear-with-C-g t)
  (eldoc-box-max-pixel-width 750)
  (eldoc-box-max-pixel-height 350)
  (eldoc-documentation-strategy 'eldoc-documentation-compose-eagerly)
  )

;;; Extensions: minions mode
(use-package minions
  :init
  (minions-mode t)
  :config
  (setopt minions-mode-line-delimiters nil
          minions-mode-line-lighter "  ")
  )

;;; Automated

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   '("fff0dc54ff5a194ba6593d1cce0fbb4fe8cf9da59fcef47f9e06dec6ef11b1fa" default))
 '(ede-project-directories
   '("/home/scion/Projects/learn_cpp/chapter_27_x" "/home/scion/Projects/learn_cpp/demo"
     "/home/scion/Projects/Notepad--"))
 '(package-selected-packages
   '(agent-shell auctex consult ef-themes eglot eldoc-box elfeed elfeed-tube embark
                 embark-consult expand-region fireplace fzf highlight-doxygen hydra
                 json-mode lin magit marginalia markdown-mode minions multiple-cursors
                 nerd-icons-completion nerd-icons-dired no-littering olivetti opam
                 orderless org-appear org-bullets org-modern page-break-lines pdf-tools
                 pulsar quickrun smart-mode-line tuareg vertico vundo ws-butler yasnippet)))

;; ## added by opam user-setup for emacs / base ## 56ab50dc8996d2bb95e7856a6eddb17b ## you can edit, but keep this line
;;(require 'opam-user-setup "~/.config/emacs/opam-user-setup.el")
;; ## end of opam user-setup addition for emacs / base ## keep this line

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:font "GeistMonoNerdFontMono-15"))))
 '(fixed-pitch ((t (:family "GeistMonoNerdFontMono"))))
 '(monospace ((t (:family "GeistMonoNerdFontMono"))))
 '(org-block ((t (:inherit fixed-pitch))))
 '(org-code ((t (:inherit (shadow fixed-pitch)))))
 '(org-document-info ((t (:foreground "dark orange"))))
 '(org-document-info-keyword ((t (:inherit (shadow fixed-pitch)))))
 '(org-indent ((t (:inherit (org-hide fixed-pitch)))))
 '(org-level-1 ((t (:inherit outline-1 :height 1.7))))
 '(org-level-2 ((t (:inherit outline-2 :height 1.6))))
 '(org-level-3 ((t (:inherit outline-3 :height 1.5))))
 '(org-level-4 ((t (:inherit outline-4 :height 1.4))))
 '(org-level-5 ((t (:inherit outline-5 :height 1.3))))
 '(org-link ((t (:foreground "royal blue" :underline t))))
 '(org-meta-line ((t (:inherit (font-lock-comment-face fixed-pitch)))))
 '(org-property-value ((t (:inherit fixed-pitch))))
 '(org-special-keyword ((t (:inherit (font-lock-comment-face fixed-pitch)))))
 '(org-table ((t (:inherit fixed-pitch :foreground "#83a598"))))
 '(org-tag ((t (:inherit (shadow fixed-pitch) :weight bold :height 0.8))))
 '(org-verbatim ((t (:inherit (shadow fixed-pitch)))))
 '(variable-pitch ((t (:family "GeistNerdFontPropo")))))
