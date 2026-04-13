;; -*- lexical-binding: t; -*-
;; Was originally based on https://emacs.stackexchange.com/a/16658

(column-number-mode t)
(setopt mode-line-percent-position nil
        column-number-indicator-zero-based nil)

(defun scion/format-git-string-advice (file &optional backend)
  "Strip VC mode prefix and apply face based on file state."
  (when (and (buffer-file-name)
             (vc-backend (buffer-file-name)))
    (let* ((state (vc-state (buffer-file-name)))
           (face (pcase state
                   ((or 'up-to-date 'nil) 'vc-state-base)
                   ('edited 'vc-edited-state)
                   ('needs-merge 'vc-edited-state)
                   ('needs-update 'vc-edited-state)
                   ('added 'vc-edited-state)
                   ('removed 'vc-edited-state)
                   ('conflict 'vc-edited-state)
                   ('locked 'vc-locked-state)
                   (_ 'vc-state-base)))
           (gitlogo (concat (propertize "  " 'display '(raise 0.1)
                                        'face face)
                            (replace-regexp-in-string "^ Git[:|-]" " " vc-mode))))

      (setq vc-mode gitlogo))))

(advice-add 'vc-mode-line :after #'scion/format-git-string-advice)

(setopt mode-line-position-column-line-format '("%l:%c"))

(defun scion/copy-project-directory ()
  "Copy project directory to kill-ring."
  (interactive)
  (kill-new default-directory))

(defun scion/buffer-name-with-project ()
  "Display buffer name as Project|file."
  (let* ((proj-keymap (let ((map (make-sparse-keymap)))
                        (define-key map [mode-line mouse-1] 'dired-jump)
                        (define-key map [mode-line mouse-3] 'scion/copy-project-directory)
                        map))
         (bufname (format-mode-line (propertized-buffer-identification "%b"))
                  ))
    (if buffer-file-name
        (let* ((project-root (or (condition-case nil
                                     (let ((pr (project-current)))
                                       (when pr (car (project-roots pr))))
                                   (error "Error in mode-line-config scion/buffer-name-with-project at project-root"))
                                 default-directory))
               (project-name (when project-root
                               (propertize
                                (file-name-nondirectory
                                 (directory-file-name project-root))
                                'help-echo
                                (concat "Project name\n"
                                        "CWD: "
                                        default-directory
                                        "\nmouse-1: Dired here\nmouse-3: Copy CWD"
                                        )
                                'mouse-face 'mode-line-highlight
                                'local-map proj-keymap
                                ))))
          (if project-name
              (concat project-name " | " bufname)
            bufname))
      bufname)))

(defun mode--line-format-center ()
  "Center all following mode-line constructs, up to and excluding
mode-line-format-right-align.

When the symbol `mode-line-format-center' appears in `mode-line-format',
return a string of one space, with a display property to make it appear
long enough to align anything after that symbol - up to and excluding
`mode-line-format-right-align' - to the the center of the rendered mode
line.

It is important that the symbol `mode-line-format-center' be included in
`mode-line-format' (and not another similar construct such
as `(:eval (mode-line-format-right-align)').  This is because the symbol
`mode-line-format-center' is processed by `format-mode-line' as a
variable."
  (let* ((rest-beg (cdr (memq 'mode-line-format-center mode-line-format)))
         (rest-end (memq 'mode-line-format-right-align rest-beg))
         (center-constructs (butlast rest-beg (length rest-end)))
         (center-constructs-str (format-mode-line center-constructs))
         (center-constructs-width (progn
                                    (add-face-text-property
                                     0 (length center-constructs-str)
                                     'mode-line t center-constructs-str)
                                    (string-pixel-width center-constructs-str))))

    (propertize " " 'display
                (if (and (display-graphic-p)
                         (not (eq mode-line-right-align-edge 'window)))
	            `(space :align-to (,(/
                                         (-
                                          ,mode-line-right-align-edge
                                          center-constructs-width)
                                         2)))
                  `(space :align-to (,(/
                                       (- (window-pixel-width)
                                          (window-scroll-bar-width)
                                          (window-right-divider-width)
                                           (* (+ (or (car (window-margins)) 0)
                                                 (or (cdr (window-margins)) 0))
                                              (frame-char-width))
                                           (car (window-fringes))
                                          (pcase mode-line-right-align-edge
                                            ('right-margin
                                             (or (cdr (window-margins)) 0))
                                            ('right-fringe
                                             (or (cadr (window-fringes)) 0))
                                            (_ 0))
                                          center-constructs-width)
                                       2)))
                  ))))

(defvar mode-line-format-center '(:eval (mode--line-format-center))
  "Mode line construct to center all following constructs up to and
excluding `mode-line-format-right-align' and anything following it.")

(put 'mode-line-format-center 'risky-local-variable t)

(setq mode-line-align-left
      '(""
        "%e"
        " "
        mode-line-front-space
        (:propertize ("" mode-line-mule-info mode-line-client
                      mode-line-modified mode-line-remote
                      mode-line-window-dedicated)
                     display (min-width (6.0)))

        mode-line-frame-identification
        (:eval
         (when (mode-line-window-selected-p)
           (concat "       " (format-mode-line mode-line-position) "   "
                   (propertize
                    (format "(%d:%d)"
                            (count-lines (point-min) (point-max)) fill-column)
                    'face 'shadow)
                   "  ")))

        (:eval (when (and which-function-mode
                          (mode-line-window-selected-p))
                 (concat "     " (format-mode-line which-func-format) "     ")))

        ))

(setq mode-line-align-middle
      '(""
        (project-mode-line project-mode-line-format)
        (:eval (with-current-buffer (current-buffer)
                 (concat (when (featurep 'nerd-icons)
                           (propertize
                            (nerd-icons-icon-for-mode
                             (buffer-local-value 'major-mode (current-buffer)))
                            'display '(raise 0.1)))
                         " "
                         (scion/buffer-name-with-project)))
               )
        " "
        ))

(setq scion/eglot-mode-line-format
      '((""
         "󱉟 "
         eglot-mode-line-menu
         eglot-mode-line-error
         eglot-mode-line-pending-requests
         eglot-mode-line-progress
         eglot-mode-line-action-suggestion)))

(setq scion/mode-line-eglot
      '(:eval
         (cl-loop for e in scion/eglot-mode-line-format for render = (format-mode-line e) unless
                  (eq render #1="") collect (cons render (eq e 'eglot-mode-line-menu)) into
                  rendered finally
                  (return
                   (cl-loop for (rspec . rest) on rendered for (r . titlep) = rspec concat r
                            when rest concat (if titlep ":" "/"))))))

(setq mode-line-align-right
      '(""
        (:eval (when (bound-and-true-p eglot--managed-mode) scion/mode-line-eglot))
        vc-mode
        "  "
        mode-line-modes))

(setq-default mode-line-format
              (list
               mode-line-align-left
               'mode-line-format-center
               mode-line-align-middle
               'mode-line-format-right-align
               mode-line-align-right "  "
               ))
