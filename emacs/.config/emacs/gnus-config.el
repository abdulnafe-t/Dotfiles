;;; -*- lexical-binding: t -*-

(setopt user-mail-address "abdulnafe.toulaimat@gmail.com"
        user-full-name "Abdulnafé Toulaïmat")

(setopt gnus-select-method
        '(nnimap "gmail"
	         (nnimap-address "imap.gmail.com")
	         (nnimap-server-port "imaps")
	         (nnimap-stream tls)))

(setopt smtpmail-smtp-server "smtp.gmail.com"
        smtpmail-smtp-service 587
        gnus-ignored-newsgroups "^to\\.\\|^[0-9. ]+\\( \\|$\\)\\|^[\"]\"[#'()]")

(setopt gnus-secondary-select-methods '((nntp "news.gmane.io"
                                              (nntp-stream tls)
                                              (nntp-port 563))
                                        (nntp "news.eternal-september.org"
                                              (nntp-stream tls)
                                              (nntp-port 563)))
        )

(setopt gnus-parameters '((".*" (display . all)))
        gnus-posting-styles '((".*" (signature "A.T.")))
        )
