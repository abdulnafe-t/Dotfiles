;;; -*- lexical-binding: t -*-

(setopt user-mail-address "abdulnafe.toulaimat@gmail.com"
        user-full-name "Abdulnafé Toulaïmat")

(setopt gnus-select-method
        '(nnimap "gmail"
	         (nnimap-address "imap.gmail.com")
	         (nnimap-server-port "imaps")
	         (nnimap-stream tls))
        smtpmail-smtp-server "smtp.gmail.com"
        smtpmail-smtp-service 587
        gnus-ignored-newsgroups "^to\\.\\|^[0-9. ]+\\( \\|$\\)\\|^[\"]\"[#'()]")

(setopt mail-user-agent 'gnus-user-agent
        gnus-posting-styles '((".*" (signature "A.T.")))
        gnus-asynchronous t
        gnus-article-sort-functions '(gnus-article-sort-by-most-recent-number
                                      gnus-article-sort-by-most-recent-date)
        gnus-thread-sort-functions '(gnus-thread-sort-by-most-recent-number
                                     gnus-thread-sort-by-most-recent-date))

(setopt gnus-secondary-select-methods '((nntp "news.gmane.io"
                                              (nntp-stream tls)
                                              (nntp-port 563))
                                        (nntp "news.eternal-september.org"
                                              (nntp-stream tls)
                                              (nntp-port 563))))

;;; no-littering
(setopt gnus-home-directory         (no-littering-expand-var-file-name "gnus")
        gnus-directory              (concat gnus-home-directory "/News")
        gnus-article-save-directory gnus-directory
        gnus-kill-files-directory   gnus-directory
        gnus-cache-directory        (concat gnus-directory "/cache")
        message-directory           (concat gnus-home-directory "/Mail")
        nndraft-directory           (concat gnus-home-directory "/nndrafts")
        gnus-startup-file           (no-littering-expand-etc-file-name "gnus/.newsrc") ; FIXME: should be in var instead?
        gnus-init-file              (no-littering-expand-etc-file-name "gnus/init.el"))

(setq mailcap-user-mime-data '(((viewer . "xdg-open %s") (type . ".*"))))

;;; Optimization

(setopt gnus-use-cache t
        gnus-check-new-newsgroups nil
        gnus-read-active-file nil)

;;; Saving
(setopt gnus-prompt-before-saving t)

;;; Style
(setopt gnus-logo-color-style 'storm
        gnus-treat-emojize-symbols nil
        gnus-treat-display-smileys nil
        gnus-treat-buttonize t
        gnus-treat-buttonize-head 'head

        gnus-thread-hide-subtree t
        gnus-group-goto-unread nil

        gnus-auto-center-summary nil
        gnus-auto-center-group nil )

(add-hook 'gnus-group-mode-hook #'gnus-topic-mode)

(add-hook 'gnus-summary-mode-hook
          (lambda ()
            (setq truncate-lines t
                  truncate-partial-width-windows t)
            (visual-line-mode -1)))

(add-hook 'gnus-article-mode-hook
          (lambda ()
            (setq truncate-lines nil)
            (visual-line-mode 1)))

;;; fancy summary
;; Based on https://github.com/cofi/dotfiles/blob/master/gnus.el

(defun gnus-user-format-function-R (header)
  "Add trailing spaces for thread roots to align to column 97."
  (if (or (zerop gnus-tmp-level)
          (not (gnus-subject-equal gnus-tmp-prev-subject (aref header 1))))
      (make-string (max 0 (- 97 (current-column))) ? )
    ""))

(setopt gnus-summary-to-prefix "To: "
        gnus-summary-line-format "%U%R%z %(%1{%-16,16&user-date;%} %* %B%4{%0,70s%} %uR%2{%0,50f%}%)\n"
        gnus-summary-thread-gathering-function 'gnus-gather-threads-by-subject
        gnus-summary-gather-subject-limit 'fuzzy
        gnus-summary-goto-unread 'never
        gnus-summary-make-false-root 'dummy
        gnus-summary-dummy-line-format  "    %3{[Dummy] %20= %* ▲ %0,70S%}\n"
        gnus-sum-thread-tree-false-root      "▲ "
        gnus-sum-thread-tree-single-indent   "○ "
        gnus-sum-thread-tree-root            "● "
        gnus-sum-thread-tree-vertical        "│"
        gnus-sum-thread-tree-leaf-with-other "├─╼"
        gnus-sum-thread-tree-single-leaf     "╰─╼"
        gnus-sum-thread-tree-indent          "  ")

(gnus-add-configuration
 '(article (horizontal 1.0 (summary .45 point) (article 1.0))))

;; Format specification for the summary mode line.
(setopt gnus-summary-mode-line-format "Gnus: %V: %p"
        gnus-group-mode-line-format "Gnus: %%b")
