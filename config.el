;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!

;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
(setq user-full-name "Tom Passarelli"
      user-mail-address "tom.passarelli@protonmail.com")
;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-unicode-font' -- for unicode glyphs
(setq
  doom-font (font-spec :family "Fira Code" :size 18)
  doom-big-font (font-spec :family "Fira Code" :size 22)
  doom-variable-pitch-font (font-spec :family "Fira Sans" :size 18))

;;(setq doom-font (font-spec :family "Fira Code" :size 12 :weight 'semi-light)
;;      doom-variable-pitch-font (font-spec :family "Fira Sans" :size 13))
;; `load-theme' function. This is the default:
;(setq doom-theme 'doom-one)
;(setq doom-theme 'doom-solarized-light)
(setq doom-theme 'doom-solarized-dark)
;(setq doom-theme 'doom-one-light)
;(setq doom-theme 'doom-laserwave)
;(setq doom-theme 'doom-outrun-electric)
;(setq doom-theme 'doom-dracula)
;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)
(custom-set-faces
 '(cursor ((t (:background "#839496" :foreground "#839496")))))


;;; ---- _general -----
;;
;;_time
(display-time-mode 1)
(setq display-time-format "%I:%M %p")

;; _tramp
;; (add-to-list prepends, so code order should be
;; least specific - most specifi)
;; basically if not sea -> use sea for all tramp ssh connections
;; FIXME I'll have to make this smarter eventually, because im proxying ALL remotes
(after! tramp
  (add-to-list 'tramp-default-proxies-alist
               '("\\`.*\\'" nil "/ssh:sea:"))

  (add-to-list 'tramp-default-proxies-alist
               '("sea" nil nil)))
;; _dired

;; _projectile
(setq projectile-project-search-path: '("~/code/"))

;; _lsp
;; (use-package! eglot
;;   :ensure t
;;   :config
;;   (add-to-list 'eglot-server-programs '(python-mode . ("pylsp")))
;;   (setq-default eglot-workspace-configuration
;;                 '((:pylsp . (:plugins (:pycodestyle (:enabled nil)
;;                                        :mccabe (:enabled nil)
;;                                        :flake8 (:enabled nil)
;;                                        :pyflakes (:enabled nil))))))
;;   :hook
;;   ((python-mode . eglot-ensure)))

;; (defun my/set-python-language-server (python-version)
;;   "Set the Eglot Python language server for the given PYTHON-VERSION."
;;   (interactive "sEnter Python version (e.g., 2.7.18 or 3.x): ")
;;   (after! eglot
;;     (add-hook 'python-mode-hook
;;               (lambda ()
;;                 (setq-local eglot-server-programs
;;                             (cons `(python-mode ,(concat (getenv "PYENV_ROOT") "/versions/" python-version "/bin/python" " -m" "pyls"))
;;                                   eglot-server-programs))))))

;; _debugger
(after! dap-mode
  (setq dap-python-debugger 'debugpy))

;; _python
(after! python
  (setq python-indent-offset 2)
  (setq blacken-line-length 100))

;; _javascript
(after! javascript
 (setq js-indent-level 2
       js2-basic-offset 2))

;; (use-package! lsp-ui
;;   :defer t
;;   :config
;;   (setq lsp-ui-sideline-enable nil
;;         lsp-ui-doc-delay 999
;;         lsp-ui-doc-use-webkit t
;;         lsp-ui-doc-position "at-point"
;;         lsp-eldoc-enable-hover nil
;;         lsp-signature-render-documentation nil
;;         lsp-signature-auto-activate nil
;;         lsp-ui-doc-show-with-cursor nil)
;;   :hook (lsp-mode . lsp-ui-mode)
;;   :bind (:map lsp-ui-mode-map
;;               ("C-c i" . lsp-ui-imenu)))

;;; ---- _org -----
(setq org-directory "~/org/")
(setq org-roam-directory "~/org/roam/")

;; doom uses 'm' as the default local leader, so the below is 'SPCmca'
(map! :map org-mode-map
      :localleader
      :desc "Add clock entry" "c a" #'org-clock-add)

;; solves the mysterious lack of native support to simply add clocktime to a ticket
;; while the mystery persists, we now have support to do so!
(defun org-clock-add ()
  (interactive)
  (let ((time (org-read-date nil 'to-time nil "Clock start time:"))
        (duration (string-to-number (read-string "Duration (in minutes):"))))
    (org-clock-add-logbook-entry time duration)))

(defun org-clock-add-logbook-entry (start duration)
  (org-back-to-heading t)
  (let ((entry (format "CLOCK: [%s]--[%s] =>  %s"
                       (format-time-string (org-time-stamp-format t t) start)
                       (format-time-string (org-time-stamp-format t t) (time-add start (seconds-to-time (* duration 60))))
                       (org-duration-from-minutes duration))))
    (if (org-log-into-drawer)
        (progn
          (org-log-beginning)
          (insert entry "\n"))
      (org-end-of-meta-data)
      (insert entry))))

;; --
;; the below fixes the bug - new org roam files are not added
;; automatically to agenda. Idk if this is a bug or just unimplemented feature
;; my solution uses a event monitor program and callback
;; _agenda
(after! org-roam
(defun my/update-org-agenda-files ()
  "Update the org-agenda-files list with Org files from the org-roam-directory."
  (interactive)
  (setq org-agenda-files (directory-files-recursively org-roam-directory "\.org$"))
  (message "org-agenda-files updated!"))

(defvar my/org-roam-directory-watcher nil
  "Variable to store the file system watcher for the Org-roam directory.")

(defun my/org-roam-directory-change-callback (event)
  "Callback function to handle changes in the Org-roam directory.
EVENT is the file system event that triggers the callback."
  (when (eq (nth 1 event) 'created) ; Check if the event is file creation
    (my/update-org-agenda-files)))

(defun my/setup-org-roam-directory-watcher ()
  "Set up a file system watcher for the Org-roam directory."
  (when (boundp 'my/org-roam-directory-watcher) ; If a watcher is already set up, remove it
    (file-notify-rm-watch my/org-roam-directory-watcher))
  (setq my/org-roam-directory-watcher
        (file-notify-add-watch org-roam-directory
                               '(change attribute-change)
                               #'my/org-roam-directory-change-callback)))

;; Set up the file system watcher when Emacs starts
(my/setup-org-roam-directory-watcher))
;; --

(after! org
  (use-package! org-inlinetask)
  (use-package! literate-calc-mode)
  (setq org-use-tag-inheritance nil)
  (setq org-agenda-use-tag-inheritance nil)
  (setq org-agenda-files (directory-files-recursively org-roam-directory "\.org$"))
  (setq org-hide-leading-stars nil)
  (setq org-superstar-leading-bullet ?\s)
  (setq org-superstar-headline-bullets-list '("•"))
  ; make org look more like 'markdown'
  (setq org-hide-emphasis-markers t)
  ; org zen mode
  (setq +zen-text-scale 0)
  (add-hook 'org-mode-hook (lambda () (writeroom-mode +1)))
  (add-hook 'org-mode-hook (lambda () (setq display-line-numbers-type nil))))

;; -- org extensions -- _oext
;; _wild _owc _org_wild
(use-package! org-wild-notifier
  :after org
  :config
  (setq org-wild-notifier-keyword-whitelist '()
    org-wild-notifier--alert-severity "high"
    org-wild-notifier-notification-title "<< ORG REMINDER >>"
    org-wild-notifier-alert-time '(1 2 5 10)
    alert-default-style 'libnotify
    alert-libnotify-additional-args '("-h" "string:desktop-entry:emacs"))
    (org-wild-notifier-mode))


;; _roam save hook
(add-hook! 'after-save-hook
  (defun org-rename-to-new-title ()
    (when-let*
        ((old-file (buffer-file-name))
         (is-roam-file (org-roam-file-p old-file))
         (file-node (save-excursion
                      (goto-char 1)
                      (org-roam-node-at-point)))
         (file-name  (file-name-base (org-roam-node-file file-node)))
         (file-time  (or (and (string-match "\\`\\([0-9]\\{14\\}\\)-" file-name)
                              (concat (match-string 1 file-name) "-"))
                         ""))
         (slug (org-roam-node-slug file-node))
         (new-file (expand-file-name (concat file-time slug ".org")))
         (different-name? (not (string-equal old-file new-file))))

      (rename-buffer new-file)
      (rename-file old-file new-file)
      (set-visited-file-name new-file)
      (set-buffer-modified-p nil))))

;; _reference
;; customize og
;; (after! org
;;   (set-face-attribute 'org-link nil
;;                       :weight 'normal
;;                       :background nil)
;;   (set-face-attribute 'org-code nil
;;                       :foreground "#d43984"
;;                       :background nil
;;                       :weight 'semi-bold
;;                       :overline nil)
;;   (set-face-attribute 'org-date nil
;;                       :foreground "#5B6268"
;;                       :background nil)
;;   (set-face-attribute 'org-level-1 nil
;;                       :foreground "#003641"
;;                       :background nil
;;                       :height 1.2
;;                       :weight 'normal)
;;   (set-face-attribute 'org-level-2 nil
;;                       :foreground "#003641"
;;                       :background nil
;;                       :height 1.0
;;                       :weight 'normal)
;;   (set-face-attribute 'org-level-3 nil
;;                       :foreground "#003641"
;;                       :background nil
;;                       :height 1.0
;;                       :weight 'normal)
;;   (set-face-attribute 'org-level-4 nil
;;                       :foreground "#003641"
;;                       :background nil
;;                       :height 1.0
;;                       :weight 'normal)
;;   (set-face-attribute 'org-level-5 nil
;;                       :weight 'normal)
;;   (set-face-attribute 'org-level-6 nil
;;                       :weight 'normal)
;;   (set-face-attribute 'org-document-title nil
;;                       :foreground "#003641"
;;                       :background nil
;;                       :height 1.75
;;                       :weight 'bold))
;;
;;
;;
;;
;;
;; ;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; (setq user-full-name "Tom Passarelli"
;;       user-mail-address "tom.passarelli@protonmail.com")

;; ; -------- Font and Spacing --------

;; ;; Doom exposes five (optional) variables for controlling fonts in Doom:
;; ;;
;; ;; - `doom-font' -- the primary font to use
;; ;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; ;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;; ;;   presentations or streaming.
;; ;; - `doom-unicode-font' -- for unicode glyphs
;; ;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;; ;;
;; ;; See 'C-h v doom-font' for documentation and more examples of what they
;; ;; accept. For example:
;; ;;
;; ;;(setq doom-font (font-spec :family "Fira Code" :size 12 :weight 'semi-light)
;; ;;      doom-variable-pitch-font (font-spec :family "Fira Sans" :size 13))
;; ;;
;; ;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; ;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; ;; refresh your font settings. If Emacs still can't find your font, it likely
;; ;; wasn't installed correctly. Font issues are rarely Doom issues!

;; ;; There are two ways to load a theme. Both assume the theme is installed and
;; ;; available. You can either set `doom-theme' or manually load a theme with the
;; ;; `load-theme' function. This is the default:

;; (setq
;;   doom-font (font-spec :family "Hack" :size 18)
;;   doom-big-font (font-spec :family "Hack" :size 22)
;;   doom-variable-pitch-font (font-spec :family "Hack" :size 16))

;; (setq doom-theme 'doom-solarized-light)

;; ;; This determines the style of line numbers in effect. If set to `nil', line
;; ;; numbers are disabled. For relative line numbers, set this to `relative'.
;; (setq display-line-numbers-type t)

;; ;;; -- DEVELOPMENT CONFIG GLOBAL --
;; (setq projectile-project-search-path '("~/code/"))

;; ;;(after! yasnippet
;; ;;  (push (expand-file-name "snippets/" doom-private-dir) yas-snippet-dirs))

;; ;; Treemacs
;; (map! :after treemacs
;;       :map treemacs-mode-map
;;       "S-RET" #'treemacs-visit-node-ace)

;; ;; ---------- LSP --------------

;; ;; UI
;; ;(after! lsp-ui
;; ; (setq lsp-ui-doc-mode t
;; ;       lsp-ui-doc-enable t
;; ;       lsp-ui-doc-max-width 180
;; ;       lsp-ui-doc-max-height 60
;; ;       lsp-ui-sideline-show-symbol t
;; ;        lsp-ui-doc-use-childframe t))


;; ;; ------- Javascript -------

;; (setq js-indent-level 2
;;       js2-basic-offset 2)

;; ;;; ------- Angular --------------

;; ;;; angular-language-server
;; ;; (after! lsp-mode
;; ;;   (setq lsp-clients-angular-language-server-command
;; ;;   '("node"
;; ;;     "/usr/local/lib/node_modules/@angular/language-server"
;; ;;     "--ngProbeLocations"
;; ;;     "/usr/local/lib/node_modules"
;; ;;     "--tsProbeLocations"
;; ;;     "/usr/local/lib/node_modules"
;; ;;     "--stdio")))

;; ;;-------- ORG MODE -------------

;; (add-to-list 'doom-large-file-excluded-modes 'org-mode)
;; ;; (add-to-list 'exec-path "~/sqlite/sqlite3")
;; (use-package org
;;   :init
;;   (setq org-directory "~/Nextcloud/org")
;;   (setq org-roam-directory "~/Nextcloud/org/notes"))
;; (after! org
;;   (setq visual-fill-column-mode t
;;         visual-line-mode t)
;;   (map! :map org-mode-map
;;         :n "M-j" #'org-metadown
;;         :n "M-k" #'org-metaup)
;;   (custom-set-faces
;;   '(org-level-1 ((t (:inherit outline-1 :height 1.4))))
;;   '(org-level-2 ((t (:inherit outline-2 :height 1.3))))
;;   '(org-level-3 ((t (:inherit outline-3 :height 1.2))))
;;   '(org-level-4 ((t (:inherit outline-4 :height 1.1))))
;;   '(org-level-5 ((t (:inherit outline-5 :height 1.0))))
;;   )
;;   (setq org-log-done '(time)
;;         org-hide-emphasis-markers '(t)
;;         org-use-tag-inheritance '(nil)
;;         ;;org-bullets-bullet-list '("⁖")
;;         org-todo-keywords '((sequence "TODO(t)" "NEXT(n)" "INPROGRESS(i)" "WAITING(w)" "HOLD(h)"  "|" "DONE(d)" "PASS(p)" "SOMEDAY-MAYBE(s)")
;;                             (sequence "[ ](T)" "[N](N)" "[-](I)" "[~](W)" "[H](H)"  "|" "[X](D)" "[P](P)" "[S]S"))
;;         org-todo-keyword-faces
;;         '(("TODO"       :foreground "#7c7c78" :weight normal :underline t)
;;           ("WAITING"    :foreground "#9f7efe" :weight normal :underline t)
;;           ("INPROGRESS" :foreground "#0098dd" :weight normal :underline t)
;;           ("HOLD"       :foreground "#80808A" :weight normal :underline t)
;;           ("DONE"       :foreground "#50a14f" :weight normal :underline t)
;;           ("MISS"       :foreground "#ff6480" :weight normal :underline t)
;;           ("[-]"  . +org-todo-active)
;;           ("INPROGRESS" . +org-todo-active)
;;           ("[?]"  . +org-todo-onhold)
;;           ("UNDECIDED"  . +org-todo-onhold)
;;           ("WAITING" . +org-todo-onhold))
;;           org-priority-faces '((?A :foreground "#e45649")
;;                                (?B :foreground "#da8548")
;;                                (?C :foreground "#0098dd")))

;; ;; https://old.reddit.com/r/emacs/comments/hnf3cw/my_orgmode_agenda_much_better_now_with_category/
;;  (use-package! org-super-agenda
;;   :after org-agenda
;;   :init
;;   (setq org-agenda-files (list org-roam-directory)
;;         ;;(see above for replacement) org-agenda-files (directory-files-recursively "~/org/" "\\.org$")
;;         org-agenda-include-deadlines t
;;         org-agenda-block-separator nil
;;         org-agenda-compact-blocks t
;;         ;;org-agenda-skip-scheduled-if-done t
;;         org-agenda-todo-ignore-scheduled 'future
;;         org-agenda-tags-todo-honor-ignore-options t
;;         org-agenda-start-day "1d"
;;         org-agenda-span '7
;;         org-agenda-start-on-weekday 1
;;         org-super-agenda-groups '((:name "Today"  ; Optionally specify section name
;;                                          :time-grid t  ; Items that appear on the time grid
;;                                          :scheduled today ; Items that have this TODO keyword
;;                                   )
;;                                   (:name "Important"
;;                                          ;; Single arguments given alone
;;                                          :tag "bills"
;;                                          :priority "A")
;;                                   (:name "TODO AND scheduled in the past"
;;                                          :todo t
;;                                          :scheduled past
;;                                   )
;;                                   ;; (:name "Not Done"
;;                                   ;;        :todo t
;;                                   ;;        :scheduled past
;;                                   ;; )
;;                                   ;; (:name "Week"
;;                                   ;;        :todo t
;;                                   ;;        :scheduled past
;;                                   ;; )
;;                                   ;; Set order of multiple groups at once
;;                                   (:order-multi (2 (:name "Shopping in town" ;; Boolean AND group matches items that match all subgroups
;;                                                           :and (:tag "shopping" :tag "@town"))
;;                                                    (:name "Food-related" ;; Multiple args given in list with implicit OR
;;                                                           :tag ("food" "dinner"))
;;                                                    (:name "Personal"
;;                                                           :habit t
;;                                                           :tag "personal")
;;                                                    (:name "Space-related (non-moon-or-planet-related)"
;;                                                           ;; Regexps match case-insensitively on the entire entry
;;                                                           :and (:regexp ("space" "NASA")
;;                                                                         ;; Boolean NOT also has implicit OR between selectors
;;                                                                         :not (:regexp "moon" :tag "planet")))))
;;                                   ;; Groups supply their own section names when none are given
;;                                   (:todo "WAITING" :order 8)  ; Set order of this section
;;                                   (:todo ("SOMEDAY" "TO-READ" "CHECK" "TO-WATCH" "WATCHING")
;;                                          ;; Show this group at the end of the agenda (since it has the
;;                                          ;; highest number). If you specified this group last, items
;;                                          ;; with these todo keywords that e.g. have priority A would be
;;                                          ;; displayed in that group instead, because items are grouped
;;                                          ;; out in the order the groups are listed.
;;                                          :order 9)
;;                                   (:priority<= "B"
;;                                                ;; Show this section after "Today" and "Important", because
;;                                                ;; their order is unspecified, defaulting to 0. Sections
;;                                                ;; are displayed lowest-number-first.
;;                                                :order 1)
;;                                   ;; After the last group, the agenda will display items that didn't
;;                                   ;; match any of these groups, with the default order position of 99
;;                                   ))
;;                                   (org-agenda nil "a"))
;;         :config
;;         (org-super-agenda-mode))

;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `after!' block, otherwise Doom's defaults may override your settings. E.g.
;;
;;   (after! PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look up their documentation).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;; Alternatively, use `C-h o' to look up a symbol (functions, variables, faces,
;; etc).
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.
