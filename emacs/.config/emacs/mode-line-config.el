;; -*- lexical-binding: t; -*-
;; Based in large part on https://emacs.stackexchange.com/a/16658

(defadvice vc-mode-line (after strip-backend () activate)
  (when (stringp vc-mode)
    (let ((gitlogo (replace-regexp-in-string "^ Git." " " vc-mode)))
      (setq vc-mode gitlogo))))

(setopt mode-line-position-column-line-format '("%l:%c"))


;; ((eglot--managed-mode (" [" eglot--mode-line-format "] "))
;;  (which-function-mode
;;   (which-func-mode (which-func--use-mode-line (#1="" which-func-format " "))))
;;  (global-mode-string (#1# global-mode-string)))

(defun mode-line-fill-right (face reserve)
  "Return empty space using FACE and leaving RESERVE space on the right."
  (unless reserve
    (setq reserve 15))
  (when (and window-system (eq 'right (get-scroll-bar-mode)))
    (setq reserve (- reserve 3)))
  (propertize " "
              'display `((space :align-to (- (+ right right-fringe right-margin) ,reserve)))
              'face face))


(defun mode-line-fill-center (face reserve)
  "Return empty space using FACE to the center of remaining space leaving RESERVE space on the right."
  (unless reserve
    (setq reserve 20))
  (when (and window-system (eq 'right (get-scroll-bar-mode)))
    (setq reserve (- reserve 3)))
  (propertize " "
              'display `((space :align-to (- (+ center (.5 . right-margin)) ,reserve
                                             (.47 . left-margin))))
              'face face))

(defun scion-buffer-name-with-project ()
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
          (concat project-name "|" (propertize file-name 'face '(bold mode-line-buffer-id)))
        (propertize file-name 'face '(bold mode-line-buffer-id)))))
   (t
    (propertize (buffer-name) 'face '(bold mode-line-buffer-id)))))

(defconst RIGHT_PADDING 0)

(defun reserve-left/middle ()
  (/ (length (format-mode-line mode-line-align-middle)) 2))

(defun reserve-middle/right ()
  (+ RIGHT_PADDING (length (format-mode-line mode-line-align-right))))

(setq mode-line-align-left
      '(""
        "%e"
        mode-line-front-space
        (:propertize ("" mode-line-mule-info mode-line-client
                      mode-line-modified mode-line-remote
                      mode-line-window-dedicated)
                     display (min-width (6.0)))

        mode-line-frame-identification
        (:eval
         (when (mode-line-window-selected-p)
           (concat "    " (format-mode-line mode-line-position) (propertize (format "(%d:%d)" (count-lines (point-min) (point-max)) fill-column) 'face 'shadow) "  ")))))

(setq mode-line-align-middle
      '(""
        (project-mode-line project-mode-line-format)
        (:eval (concat (format-mode-line vc-mode vc-mode) "   "))
        (:eval (scion-buffer-name-with-project))
        ))

(setq mode-line-align-right
      '(""
        flymake-mode-line-format
        mode-line-misc-info
        (:eval (when (mode-line-window-selected-p) mode-name))
        ))

(setq-default mode-line-format
              (list

               mode-line-align-left

               '(:eval (mode-line-fill-center 'mode-line
                                              (reserve-left/middle)))

               mode-line-align-middle
               '(:eval
                 (mode-line-fill-right 'mode-line
                                       (reserve-middle/right)))
               mode-line-align-right
               ))
