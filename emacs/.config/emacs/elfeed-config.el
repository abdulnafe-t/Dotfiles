;; -*- lexical-binding: t; -*-

(use-package elfeed
  :ensure t
  :bind
  ("C-c y" . elfeed)
  :hook
  (elfeed-show-mode-hook . (lambda ()
			     (setq-local cursor-type 'bar)
			     (text-scale-set 2)))

  (elfeed-search-mode-hook . (lambda()
                               (setq bidi-paragraph-direction 'left-to-right)))
  :config

  (setq-default elfeed-search-filter "@2months")

  (setopt elfeed-feeds
          '(("https://karthinks.com/index.xml" emacs software)
	    ("https://xkcd.com/rss.xml" xkcd humor general comics)
	    ("https://archlinux.org/feeds/news" arch linux software)
            ("https://emacshorrors.com/feed.atom" emacs software humor)
	    ("https://blog.ar-ms.me/atom.xml" abdul-rahman-sibahi arabic software typography general)
	    ("https://www.youtube.com/feeds/videos.xml?channel_id=UCGudGqToOw9hWGR88W9Jutg" youtube howtown)
	    ("https://www.youtube.com/feeds/videos.xml?channel_id=UCYO_jab_esuFRV4b17AJtAw" youtube 3blue1brown math)
	    ("https://www.youtube.com/feeds/videos.xml?channel_id=UCkcnYVAVZQOB-nXHechtXDg" youtube benjamin finance)
	    ("https://www.youtube.com/feeds/videos.xml?channel_id=UCSdma21fnJzgmPodhC9SJ3g" youtube nakey-jakey gaming)
	    ("https://www.youtube.com/feeds/videos.xml?channel_id=UCD6VugMZKRhSyzWEWA9W2fg" youtube ssethtzeentach gaming)
	    ("https://www.youtube.com/feeds/videos.xml?channel_id=UC8e0Sg8TmRRFJytjEGhmVTg" youtube rhystic-studies mtg art)
	    ("https://www.youtube.com/feeds/videos.xml?channel_id=UChzRJQ-MbpcIxFT5YLW1R9w" youtube juniper-dev gamedev gaming)
	    ("https://www.youtube.com/feeds/videos.xml?channel_id=UCX7lrgEOku1Ii5smnxDS5uQ" youtube soju-with-sarah podcast life)
	    ("https://www.youtube.com/feeds/videos.xml?channel_id=UCX60pqsaaAPFh2sUZEaNKJA" youtube HGModernism life tech art general)
	    ("https://www.youtube.com/feeds/videos.xml?channel_id=UCwHwDuNd9lCdA7chyyquDXw" youtube bread-on-penguins arch linux life general))))

(use-package elfeed-tube
  :after elfeed
  :ensure t
  :demand t
  :config
  (elfeed-tube-setup)
  (setopt elfeed-tube-thumbnail-size 'medium)
  (defun scion/open-youtube-with-freetube (url &optional _new-window)
    (start-process "open-youtube" nil "freetube" url))
  (setopt browse-url-handlers
          '(("https?://\\(www\\.\\)?\\(youtube\\.com\\)/" . scion/open-youtube-with-freetube)
            ("." . browse-url-default-browser)))

  :bind (:map elfeed-show-mode-map
              ("F" . elfeed-tube-fetch)
	      ("<mouse-8>" . elfeed-kill-buffer)
              ([remap save-buffer] . elfeed-tube-save)
              :map elfeed-search-mode-map
              ("F" . elfeed-tube-fetch)
              ([remap save-buffer] . elfeed-tube-save)))
