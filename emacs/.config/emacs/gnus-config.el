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
        gnus-parameters '((".*" (display . all)))
        gnus-posting-styles '((".*" (signature "A.T.")))
        gnus-asynchronous t
        gnus-article-sort-functions '(gnus-article-sort-by-number
                                      gnus-article-sort-by-date))

(setopt gnus-secondary-select-methods '((nntp "news.gmane.io"
                                              (nntp-stream tls)
                                              (nntp-port 563))
                                        (nntp "news.eternal-september.org"
                                              (nntp-stream tls)
                                              (nntp-port 563))))

(setopt gnus-home-directory        (no-littering-expand-var-file-name "gnus")
        gnus-directory             (concat gnus-home-directory "/News")
        gnus-cache-directory       (concat gnus-directory "/cache")
        message-directory          (concat gnus-home-directory "/Mail")
        nndraft-directory          (concat gnus-home-directory "/nndrafts")
        gnus-startup-file          (no-littering-expand-etc-file-name "gnus/.newsrc")
        gnus-init-file             (no-littering-expand-etc-file-name "gnus/init.el"))

(setq mailcap-user-mime-data '(((viewer . "xdg-open %s") (type . ".*"))))

(setopt gnus-logo-color-style 'storm
        gnus-treat-emojize-symbols nil
        gnus-summary-line-format "%U%R%z %(%-20&user-date;  %-23,23f %* %B%-60,60S%)\n"
        gnus-summary-thread-gathering-function 'gnus-gather-threads-by-subject
        gnus-summary-gather-subject-limit 'fuzzy
        gnus-use-cache t
        gnus-thread-hide-subtree nil
        gnus-summary-goto-unread 'never
        gnus-group-goto-unread nil)


;;; fancy summary

(setq gnus-summary-make-false-root 'dummy
      gnus-summary-dummy-line-format  "%50= ▲    %-60,60S\n"
      gnus-sum-thread-tree-false-root      "▲    "
      gnus-sum-thread-tree-single-indent   "○    "
      gnus-sum-thread-tree-root            "●    "
      gnus-sum-thread-tree-vertical        "│    "
      gnus-sum-thread-tree-leaf-with-other "├──╼ "
      gnus-sum-thread-tree-single-leaf     "╰──╼ "
      gnus-sum-thread-tree-indent          "   ")

(add-hook 'gnus-group-mode-hook #'gnus-topic-mode)
