;; -*- lexical-binding: t; -*-
;; Based in large part on https://emacs.stackexchange.com/a/16658

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
                            (replace-regexp-in-string "^ Git[:|-]" "  " vc-mode))))

      (setq vc-mode gitlogo))))

(advice-add 'vc-mode-line :after #'scion/format-git-string-advice)

(setopt mode-line-position-column-line-format '("%l:%c"))

(defun scion/buffer-name-with-project ()
  "Display buffer name as Project|file."
  (cond
   (buffer-file-name
    (let* ((project-root (or (condition-case nil
                                 (let ((pr (project-current)))
                                   (when pr (car (project-roots pr))))
                               (error nil))
                             default-directory))
           (project-name (when project-root
                           (file-name-nondirectory
                            (directory-file-name project-root))))
           (file-name (file-name-nondirectory buffer-file-name)))
      (if project-name
          (concat project-name " | " (propertize file-name 'face '(bold mode-line-buffer-id)))
        (propertize file-name 'face '(bold mode-line-buffer-id)))))
   (t
    (propertize (buffer-name) 'face '(bold mode-line-buffer-id)))))

(defun mode-line-fill-right (face reserve)
  "Return empty space using FACE and leaving RESERVE space on the right."
  (unless reserve
    (setq reserve 20))
  (when (and (display-graphic-p) (eq 'right (get-scroll-bar-mode)))
    (setq reserve (- reserve 3)))
  (propertize " "
              'display `((space :align-to (- (+ right right-fringe right-margin) ,reserve)))
              'face face))

(defun mode-line-fill-center (face reserve)
  "Return empty space using FACE to the center of remaining space leaving RESERVE space on the right."
  (unless reserve
    (setq reserve 20))
  (when (and (display-graphic-p) (eq 'right (get-scroll-bar-mode)))
    (setq reserve (- reserve 3)))
  (propertize " "
              'display `((space :align-to (- (+ center (.5 . right-margin)) ,reserve
                                             (.46 . left-margin))))
              'face face))

(defun reserve-left/middle ()
  (/ (length (format-mode-line mode-line-align-middle)) 2))

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
           (concat "       " (format-mode-line mode-line-position) "   " (propertize (format "(%d:%d)" (count-lines (point-min) (point-max)) fill-column) 'face 'shadow) "  ")))

        (:eval (when (and which-function-mode which-func-format (mode-line-window-selected-p))
                 (concat "     " (format-mode-line which-func-format) "     ")))

        ))

(setq mode-line-align-middle
      '(""
        (project-mode-line project-mode-line-format)
        (:eval (with-current-buffer (current-buffer)
                 (concat (propertize
                          (nerd-icons-icon-for-mode
                           (buffer-local-value 'major-mode (current-buffer)))
                          'display '(raise 0.1))
                         " "
                         (scion/buffer-name-with-project)))
               )
        " "
        ))

(setq scion/eglot-mode-line-format
      '((""
         "󱉟 "
         eglot-mode-line-menu
         " "
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
        (:eval (when (bound-and-true-p flymake-mode)
                 (concat (format-mode-line flymake-mode-line-format) "   ")))
        (:eval (when (bound-and-true-p minions-mode) minions-mode-line-modes))
        ))

(setq-default mode-line-format
              (list
               mode-line-align-left
               '(:eval (mode-line-fill-center (if (mode-line-window-selected-p) 'mode-line-active 'mode-line-inactive)
                                              (reserve-left/middle)))
               mode-line-align-middle
               'mode-line-format-right-align
               mode-line-align-right "    "
               ))
