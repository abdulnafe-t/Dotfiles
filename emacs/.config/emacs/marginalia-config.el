;;; -*- lexical-binding: t -*-

(defun a-t/marginalia-annotate-function (cand)
  "Annotate function CAND with its documentation string. Display
documentation string before other info."
  (when-let* ((sym (intern-soft cand)))
    (marginalia--fields
     (:left (marginalia-annotate-binding cand))
     ((marginalia--function-doc sym)
      :truncate 1.0 :face 'marginalia-documentation)
     ((marginalia--function-args sym) :face 'marginalia-value
      :truncate 0.5)
     ((marginalia--symbol-class sym) :face 'marginalia-type))))

(defun a-t/marginalia-annotate-variable (cand)
  "Annotate variable CAND with its documentation string. Display
documentation string before other info."
  (when-let* ((sym (intern-soft cand)))
    (marginalia--fields
     ((or (documentation-property sym 'variable-documentation)
          (marginalia--definition-prefix sym))
      :truncate 1.0 :face 'marginalia-documentation)
     ((marginalia--variable-value sym) :truncate 0.5)
     ((marginalia--symbol-class sym) :face 'marginalia-type))))

(defun a-t/marginalia-annotate-package (cand)
  "Annotate package CAND with its description summary. Display
documentation string before other info."
  (when-let* ((pkg-alist (bound-and-true-p package-alist))
              ;; See ‘package-get-version’.
              (name (replace-regexp-in-string
                     "-[0-9]\\(?:[0-9.]\\|pre\\|beta\\|alpha\\|snapshot\\)+\\'" "" cand))
              (pkg (intern-soft name))
              (desc (or (unless (equal name cand)
                          (cl-loop with version = (substring cand (1+ (length name)))
                                   for d in (alist-get pkg pkg-alist)
                                   if (equal (package-version-join
                                              (package-desc-version d))
                                             version)
                                   return d))
                        ;; taken from ‘describe-package-1’
                        (car (alist-get pkg pkg-alist))
                        (if-let* ((built-in (assq pkg package--builtins)))
                            (package--from-builtin built-in)
                          (car (alist-get pkg package-archive-contents))))))
    (marginalia--fields
     ((package-desc-summary desc) :truncate 1.0 :face 'marginalia-documentation)
     ((cond
       ((package-desc-archive desc)
        (propertize (package-desc-archive desc) 'face 'marginalia-archive))
       (t (propertize
           (or (package-desc-status desc) "orphan")
           'face 'marginalia-installed)))
      :truncate 12)
     ((package-version-join
       (package-desc-version desc))
      :truncate 16 :face 'marginalia-version))))

(defun a-t/marginalia-annotate-symbol (cand)
  "Annotate symbol CAND with its documentation string. Display
documentation string before other info."
  (when-let* ((sym (intern-soft cand)))
    (marginalia--fields
     (:left (marginalia-annotate-binding cand))
     ((if (fboundp sym)
          (marginalia--function-doc sym)
        (or (cl-loop
             for doc in '(variable-documentation
                          face-documentation
                          group-documentation)
             thereis (ignore-errors (documentation-property sym doc)))
            (marginalia--definition-prefix sym)))
      :truncate 1.0 :face 'marginalia-documentation)
     ((marginalia--symbol-class sym) :face 'marginalia-type)
     ((marginalia--abbreviate-file-name (or (symbol-file sym) ""))
      :truncate -0.5 :face 'marginalia-file-name))))

(defun a-t/marginalia-annotate-imenu (cand)
  "Annotate imenu CAND with its documentation string. Display documentation
string before other info."
  (when (derived-mode-p 'emacs-lisp-mode)
    ;; Strip until the last whitespace in order to support flat imenu
    (a-t/marginalia-annotate-symbol (replace-regexp-in-string "\\`.* " "" cand))))

(dolist (type '(function variable package symbol imenu))
  (add-to-list 'marginalia-annotators
               (list type (intern (concat "a-t/marginalia-annotate-" (symbol-name type)))
                     'builtin 'none)))
