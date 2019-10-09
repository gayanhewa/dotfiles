;;; -*- lexical-binding: t -*-
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Base settings ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(setq package-check-signature nil)
(package-initialize)
(setq package-archives '(("gnu" . "http://elpa.gnu.org/packages/")
                         ("melpa" . "http://melpa.org/packages/")))

(when (not package-archive-contents)
  (package-refresh-contents))

(unless (package-installed-p 'use-package)
  (package-install 'use-package))
(require 'use-package)
(setq use-package-always-ensure t)

(use-package auto-compile
  :config
  (require 'auto-compile)
  (auto-compile-on-load-mode)
  (auto-compile-on-save-mode))

(defconst private-dir  (expand-file-name "private" user-emacs-directory))
(defconst temp-dir (format "%s/cache" private-dir)
  "Hostname-based elisp temp directories")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; base

(when (version<= "26.0.50" emacs-version )
  (global-display-line-numbers-mode))

(setq
 default-directory "~/Workspace"
 exec-path (append exec-path '("/Users/gayan/.rvm/gems/ruby-2.6.3/bin"))
 inhibit-startup-message t         ; Don't show the startup message...
 inhibit-startup-screen t          ; ... or screen
 cursor-in-non-selected-windows t  ; Hide the cursor in inactive windows
 echo-keystrokes 0.1               ; Show keystrokes right away, don't show the message in the scratch buffer
 initial-scratch-message nil       ; Empty scratch buffer
 initial-major-mode 'org-mode      ; Org mode by default
 sentence-end-double-space nil     ; Sentences should end in one space, come on!
 confirm-kill-emacs 'y-or-n-p      ; y and n instead of yes and no when quitting
 help-window-select t              ; Select help window so it's easy to quit it with 'q'
 large-file-warning-threshold 100000000 ; Warn only when opening files bigger than 100MB
 delete-by-moving-to-trash t ; move files to trash instead of removing
 global-auto-revert-mode t ; revert external updated buffers automatically
 delete-selection-mode 1 ; delete selected text when typing
 require-final-newline t ; adding a new line eof
 bookmark-save-flag t ; save bookmarks
 bookmark-default-file (concat temp-dir "/bookmarks") ; set the bookmarks save path
 dashboard-startup-banner nil

 history-length 1000
 backup-inhibited nil
 make-backup-files t
 auto-save-default t
 auto-save-list-file-name (concat temp-dir "/autosave")
 make-backup-files t
 create-lockfiles nil
 backup-directory-alist `((".*" . ,(concat temp-dir "/backup/")))
 auto-save-file-name-transforms `((".*" ,(concat temp-dir "/auto-save-list/") t))
 show-paren-mode t
 global-visual-line-mode t
 global-hl-line-mode t
 line-spacing 2
 default-text-properties '(line-spacing 0.25 line-height 1.25)

 ispell-program-name "aspell"

 inhibit-compacting-font-caches t
 find-file-visit-truename t

 custom-file "~/.custom.el"
 )

(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
;; set alias to y-or-n
(fset 'yes-or-no-p 'y-or-n-p)

(unless (file-exists-p (concat temp-dir "/auto-save-list"))
		       (make-directory (concat temp-dir "/auto-save-list") :parents))

(global-unset-key (kbd "s-p"))     ; Don't print

(add-hook 'before-save-hook 'delete-trailing-whitespace) ;; delete trailing whitespace on save

;; package to separate Emacs killring and system clipboard
;; https://github.com/rolandwalker/simpleclip
(use-package simpleclip
  :config
  (simpleclip-mode 1))

(use-package dashboard
  :config
  (dashboard-setup-startup-hook))

(use-package ediff
  :config
  (setq ediff-window-setup-function 'ediff-setup-windows-plain)
  (setq-default ediff-highlight-all-diffs 'nil)
  (setq ediff-diff-options "-w"))

(use-package exec-path-from-shell
  :config
  ;; Add GOPATH to shell
  (when (memq window-system '(mac ns))
    (exec-path-from-shell-copy-env "GOPATH")
    (exec-path-from-shell-copy-env "PYTHONPATH")
    ; (exec-path-from-shell-initialize)
    ))

(setq exec-path-from-shell-check-startup-files nil)

;; Expand-region allows to gradually expand selection inside words, sentences, expressions, etc.
(use-package expand-region
  :config
  (global-set-key (kbd "s-'") 'er/expand-region)         ;; Cmd+' (apostrophe) to expand
  (global-set-key (kbd "s-\"") 'er/contract-region))     ;; Cmd+" (same, but with shift) to contract

;; Move-text lines around with meta-up/down.
(use-package move-text
  :config
  (move-text-default-bindings))

;; i don't know what this does yet
(use-package page-break-lines)

;; TODO - test this one out
;; https://github.com/mhayashi1120/Emacs-wgrep
(use-package wgrep)

;; Use Projectile for project management.
(use-package projectile
  :config
  (setq projectile-completion-system 'helm)
  (define-key projectile-mode-map (kbd "C-s-p") 'projectile-command-map) ;; Ctrl+Cmd+p show projectile menu
  (define-key projectile-mode-map (kbd "C-c P") 'projectile-command-map)
  (projectile-mode +1))

(use-package smex)  ;; show recent commands when invoking Alt-x (or Cmd+Shift+p)
(use-package flx)   ;; enable fuzzy matching

;; Magit
(use-package magit
  :config
  (global-set-key (kbd "s-g") 'magit-status))   ;; Cmd+g for git status

;; Show changes in the gutter
(use-package git-gutter
  :diminish
  :config
  (global-git-gutter-mode 't)
  (set-face-background 'git-gutter:modified 'nil)   ;; background color
  (set-face-foreground 'git-gutter:added "green4")
  (set-face-foreground 'git-gutter:deleted "red"))

;; Popup window for spellchecking
(use-package flyspell-correct)
(use-package flyspell-correct-popup)

;; Enable spellcheck on the fly for all text modes. This includes org, latex and LaTeX.
(add-hook 'text-mode-hook 'flyspell-mode)
(add-hook 'prog-mode-hook 'flyspell-prog-mode)

;; Enable right mouse click on macOS to see the list of suggestions.
(eval-after-load "flyspell"
  '(progn
     (define-key flyspell-mouse-map [down-mouse-3] #'flyspell-correct-word)
     (define-key flyspell-mouse-map [mouse-3] #'undefined)))

;; Search for synonyms
(use-package powerthesaurus
  :config
  (global-set-key (kbd "s-|") 'powerthesaurus-lookup-word-dwim)) ;; Cmd+Shift+\ search thesaurus

;; Word definition search
(use-package define-word
  :config
  (global-set-key (kbd "M-\\") 'define-word-at-point))

(use-package key-chord
  :config
  (setq key-chord-two-keys-delay 0.2)

  (key-chord-define-global "qq" 'kill-this-buffer)
  (key-chord-define-global "''" "`'\C-b")
  (key-chord-define-global ",," 'indent-for-comment-and-indent)

  (key-chord-mode 1))

(use-package doom-modeline
  :ensure t
  :config
  (setq
   doom-modeline-height 25
   doom-modeline-bar-width 3
   doom-modeline-icon t
   doom-modeline-major-mode-icon t
   doom-modeline-major-mode-color-icon t
   doom-modeline-buffer-state-icon t
   doom-modeline-minor-modes t
   doom-modeline-enable-word-count t
   doom-modeline-buffer-encoding t
   doom-modeline-indent-info t
   doom-modeline-checker-simple-format t
   m-modeline-vcs-max-length 12
   doom-modeline-persp-name t
   doom-modeline-persp-name-icon nil
   doom-modeline-lsp t
   )
  :hook (after-init . doom-modeline-mode))

(use-package treemacs
  :ensure t
  :defer t
  :init
  (with-eval-after-load 'winum
    (define-key winum-keymap (kbd "M-0") #'treemacs-select-window))
  :config
  (progn
    (setq treemacs-collapse-dirs                 (if (treemacs--find-python3) 3 0)
          treemacs-deferred-git-apply-delay      0.5
          treemacs-display-in-side-window        t
          treemacs-eldoc-display                 t
          treemacs-file-event-delay              5000
          treemacs-file-follow-delay             0.2
          treemacs-follow-after-init             t
          treemacs-git-command-pipe              ""
          treemacs-goto-tag-strategy             'refetch-index
          treemacs-indentation                   2
          treemacs-indentation-string            " "
          treemacs-is-never-other-window         nil
          treemacs-max-git-entries               5000
          treemacs-missing-project-action        'ask
          treemacs-no-png-images                 nil
          treemacs-no-delete-other-windows       t
          treemacs-project-follow-cleanup        nil
          treemacs-persist-file                  (expand-file-name ".cache/treemacs-persist" user-emacs-directory)
          treemacs-position                      'left
          treemacs-recenter-distance             0.1
          treemacs-recenter-after-file-follow    nil
          treemacs-recenter-after-tag-follow     nil
          treemacs-recenter-after-project-jump   'always
          treemacs-recenter-after-project-expand 'on-distance
          treemacs-show-cursor                   t
          treemacs-show-hidden-files             t
          treemacs-silent-filewatch              nil
          treemacs-silent-refresh                nil
          treemacs-sorting                       'alphabetic-desc
          treemacs-space-between-root-nodes      t
          treemacs-tag-follow-cleanup            t
          treemacs-tag-follow-delay              1.5
          treemacs-width                         40)

    ;; The default width and height of the icons is 22 pixels. If you are
    ;; using a Hi-DPI display, uncomment this to double the icon size.
    ;;(treemacs-resize-icons 44)

    (treemacs-follow-mode t)
    (treemacs-filewatch-mode t)
    (treemacs-fringe-indicator-mode t)
    (pcase (cons (not (null (executable-find "git")))
                 (not (null (treemacs--find-python3))))
      (`(t . t)
       (treemacs-git-mode 'deferred))
      (`(t . _)
       (treemacs-git-mode 'simple))))
  :bind
  (:map global-map
        ("M-0"       . treemacs-select-window)
        ("C-x t 1"   . treemacs-delete-other-windows)
        ("C-x t t"   . treemacs)
        ("C-x t B"   . treemacs-bookmark)))

(use-package treemacs-projectile
  :after treemacs projectile
  :ensure t)

(use-package treemacs-icons-dired
  :after treemacs dired
  :ensure t
  :config (treemacs-icons-dired-mode))

(use-package treemacs-magit
  :after treemacs magit
  :ensure t)

(use-package restclient
  :ensure t
  :mode ("\\.http\\'" . restclient-mode))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Keys
;; Enable the super key
(setq mac-right-command-modifier 'super)
(setq mac-command-modifier 'super)
;; Option or Alt is naturally 'Meta'
(setq mac-option-modifier 'meta)
;; Right Alt (option) can be used to enter symbols like em dashes '—' and euros '€' and stuff.
(setq mac-right-option-modifier 'nil)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Development tools ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; support multiple major modes
(use-package mmm-mode)

;; Easymotion like nav
(use-package avy
  :bind
  ("C-c SPC" . avy-goto-char))

(use-package hydra)

;; linting
(use-package flycheck)

(use-package company
  :config
  (setq company-idle-delay 0.3)
  (global-company-mode 1)
  (global-set-key (kbd "C-<tab>") 'company-complete))

;; language server protocol config
(use-package lsp-mode
  :config
  (setq lsp-prefer-flymake nil)
  :hook
  (php-mode . lsp)
  (go-mode . lsp)
  (ruby-mode . lsp)
  (js-mode . lsp)
  (ts-mode . lsp)
  :commands lsp)

;; fancy lsp-ui
(use-package lsp-ui
  :requires lsp-mode flycheck
  :config
  (setq lsp-ui-doc-enable t
        lsp-ui-doc-use-childframe nil
        lsp-ui-doc-position 'top
        lsp-ui-doc-include-signature t
        lsp-ui-sideline-enable nil
        lsp-ui-flycheck-enable t
        lsp-ui-flycheck-list-position 'right
        lsp-ui-flycheck-live-reporting t
        lsp-ui-peek-enable t
        lsp-ui-peek-list-width 60
        lsp-ui-peek-peek-height 25
        lsp-ui-sideline-enable nil
        lsp-ui-sideline-toggle-symbol-info nil)
  (add-hook 'lsp-mode-hook 'lsp-ui-mode))

(use-package company-lsp
  :commands company-lsp)

(use-package lsp-treemacs
  :commands lsp-treemacs-errors-list)

 ;; Disable client-side cache because the LSP server does a better job.
(setq company-transformers nil
      company-lsp-async t
      company-lsp-cache-candidates nil)

;; ;; Debugger config
;; (use-package dap-mode
;;   :diminish
;;   :functions dap-hydra/nil
;;   :bind (:map lsp-mode-map
;;               ("<f5>" . dap-debug)
;;               ("M-<f5>" . dap-hydra))
;;   :hook ((after-init . dap-mode)
;;          (dap-mode . dap-ui-mode)
;;          (dap-session-created . (lambda (&_rest) (dap-hydra)))
;;          (dap-terminated . (lambda (&_rest) (dap-hydra/nil)))
;;          (go-mode . (lambda () (require 'dap-go)))
;;          (php-mode . (lambda () (require 'dap-php)))
;;          ((js-mode js2-mode) . (lambda () (require 'dap-chrome))))
;;   )

(use-package yasnippet
  :config
  (yas-global-mode 1))

(use-package yaml-mode)
(use-package haml-mode)
(use-package markdown-mode)
(use-package rvm
  :config
  (rvm-use-default))

(use-package php-mode
  :ensure t
  :mode
  ("\\.php\\'" . php-mode))

(add-to-list 'auto-mode-alist '("\\.php$" . php-mode))

(use-package phpunit
  :ensure t)

(use-package web-mode
  :bind (("C-c ]" . emmet-next-edit-point)
         ("C-c [" . emmet-prev-edit-point)
         ("C-c o b" . browse-url-of-file))
  :mode
  (("\\.js\\'" . web-mode)
   ("\\.html?\\'" . web-mode)
   ("\\.phtml?\\'" . web-mode)
   ("\\.tpl\\.php\\'" . web-mode)
   ("\\.[agj]sp\\'" . web-mode)
   ("\\.as[cp]x\\'" . web-mode)
   ("\\.erb\\'" . web-mode)
   ("\\.mustache\\'" . web-mode)
   ("\\.djhtml\\'" . web-mode)
   ("\\.jsx$" . web-mode))
  :config
  (setq web-mode-markup-indent-offset 2
        web-mode-css-indent-offset 2
        web-mode-code-indent-offset 2)

  (add-hook 'web-mode-hook 'jsx-flycheck)

  ;; highlight enclosing tags of the element under cursor
  (setq web-mode-enable-current-element-highlight t)

  (defadvice web-mode-highlight-part (around tweak-jsx activate)
    (if (equal web-mode-content-type "jsx")
        (let ((web-mode-enable-part-face nil))
          ad-do-it)
      ad-do-it))

  (defun jsx-flycheck ()
    (when (equal web-mode-content-type "jsx")
      ;; enable flycheck
      (flycheck-select-checker 'jsxhint-checker)
      (flycheck-mode)))

  ;; editing enhancements for web-mode
  ;; https://github.com/jtkDvlp/web-mode-edit-element
  (use-package web-mode-edit-element
    :config (add-hook 'web-mode-hook 'web-mode-edit-element-minor-mode))

  ;; snippets for HTML
  ;; https://github.com/smihica/emmet-mode
  (use-package emmet-mode
    :init (setq emmet-move-cursor-between-quotes t) ;; default nil
    :diminish (emmet-mode . " e"))
  (add-hook 'web-mode-hook 'emmet-mode)

  (defun my-web-mode-hook ()
    "Hook for `web-mode' config for company-backends."
    (set (make-local-variable 'company-backends)
         '((company-tern company-css company-web-html company-files))))
  (add-hook 'web-mode-hook 'my-web-mode-hook)

  ;; Enable JavaScript completion between <script>...</script> etc.
  (defadvice company-tern (before web-mode-set-up-ac-sources activate)
    "Set `tern-mode' based on current language before running company-tern."
    (message "advice")
    (if (equal major-mode 'web-mode)
	(let ((web-mode-cur-language
	       (web-mode-language-at-pos)))
	  (if (or (string= web-mode-cur-language "javascript")
		  (string= web-mode-cur-language "jsx"))
	      (unless tern-mode (tern-mode))
	    (if tern-mode (tern-mode -1))))))
  (add-hook 'web-mode-hook 'company-mode)

  ;; to get completion data for angularJS
  (use-package ac-html-angular :defer t)
  ;; to get completion for twitter bootstrap
  (use-package ac-html-bootstrap :defer t)

  ;; to get completion for HTML stuff
  ;; https://github.com/osv/company-web
  (use-package company-web)

  (add-hook 'web-mode-hook 'company-mode))

;; configure CSS mode company backends
(use-package css-mode
  :config
  (defun my-css-mode-hook ()
    (set (make-local-variable 'company-backends)
         '((company-css company-dabbrev-code company-files))))
  (add-hook 'css-mode-hook 'my-css-mode-hook)
  (add-hook 'css-mode-hook 'company-mode))

;; impatient mode - Live refresh of web pages
;; https://github.com/skeeto/impatient-mode
(use-package impatient-mode
  :diminish (impatient-mode . " i")
  :commands (impatient-mode))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; UI / Theme ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; themes
(use-package dracula-theme)

;; Enable transparent title bar on macOS
(when (memq window-system '(mac ns))
  (add-to-list 'default-frame-alist '(ns-appearance . dark)) ;; {light, dark}
  (add-to-list 'default-frame-alist '(ns-transparent-titlebar . t)))

;; Font
(when (member "menlo" (font-family-list))
  (set-face-attribute 'default nil :font "Menlo 15"))

;; Pretty icons
(use-package all-the-icons)
;; MUST DO M-x all-the-icons-install-fonts after

;; editor font
(set-face-attribute 'default nil
                    :family "Source Code Pro"
                    :height 125
                    :weight 'normal
                    :width  'condensed)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; helm
(use-package helm-projectile
  :after (helm projectile))

(use-package helm-rg
  :config
  (setq helm-rg-default-directory 'git-root))

(use-package helm
  :init
  (require 'helm-config)
  :bind (("M-x" . helm-M-x)
	 ("s-o" . helm-find-files)
	 ("s-P" . helm-M-x)
	 ("s-f" . helm-occur)
	 ("C-x C-f" . helm-find-files)
	 ("s-p" . helm-projectile-find-file)
	 ("C-x v" . helm-projectile)
	 ("C-x c o" . helm-occur)
	 ("s-b" . helm-buffers-list)
	 ("C-x c k" . helm-show-kill-ring)
	 :map helm-map
	 ("<escape>" . helm-keyboard-quit)
	 ("<tab>" . helm-execute-persistent-action))
  :config
  (setq helm-split-window-in-side-p t
        helm-split-window-default-side 'below
	helm-idle-delay 0.0
	helm-input-idle-delay 0.01
	helm-quick-update t
	helm-ff-skip-boring-files t
        helm-echo-input-in-header-line t))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; Org-mode settings ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(use-package org
  :config
  (setq
   org-directory "~/Dropbox/Orgmode"
   org-agenda-sticky t
   org-directory "~/Dropbox/Orgmode"

   ;; agenda
   org-agenda-files (list (concat org-directory "/work.org")
                          (concat org-directory "/private.org")
                          (concat org-directory "/freelance.org")
                          (concat org-directory "/inbox.org")
                          (concat org-directory "/home.org"))
   org-refile-targets '((nil :maxlevel . 3) (org-agenda-files :maxlevel . 3))
   org-agenda-skip-scheduled-if-done t
   org-agenda-skip-archived-trees t
   org-agenda-skip-deadline-if-done t
   org-agenda-todo-ignore-scheduled 'future
   org-agenda-skip-scheduled-if-deadline-is-shown t
   org-agenda-skip-deadline-prewarning-if-scheduled nil
   org-agenda-repeating-timestamp-show-all nil
   org-deadline-warning-days 0
   org-scheduled-warning-days 0

   ;; state config
   org-log-into-drawer t
   org-log-state-notes-into-drawer t
   org-log-state-notes-insert-after-drawers nil

   ;; todo
   org-todo-keywords '((sequence "TODO(t)" "IN-PROGRESS(i)" "BLOCKED(b)" "|" "DONE(d)" "CANCELLED(c)"))

   ;; capture templates
   org-capture-templates
   '(("t" "Todo" entry
      (file "~/Dropbox/Orgmode/inbox.org")
      (file "~/Dropbox/Orgmode/tpl-in.txt"))
     ("n" "Note" entry
      (file+headline "~/Dropbox/Orgmode/notes.org" "Notes")
      "* %?\n%U")
     ("j" "Journal" plain
      (file+datetree "~/Dropbox/Orgmode/journal.org")
      (file "~/Dropbox/Orgmode/tpl-jrnl.txt"))
     ("w" "Weekly review" plain (file+olp+datetree "~/Dropbox/Orgmode/weekly-reviews.org")
      (file "~/Dropbox/Orgmode/tpl-weekly-review.txt") :tree-type week)))

  (require 'org-habit)
  :bind
  ("C-c l" . org-store-link)
  ("C-c a" . org-agenda))

(use-package org-bullets
  :config
  (setq org-hide-leading-stars t)
  (add-hook 'org-mode-hook
            (lambda ()
              (org-bullets-mode t))))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; other key bindings

(define-key key-translation-map (kbd "ESC") (kbd "C-g"))

;; Binding with Super
(global-set-key (kbd "s-s") 'save-buffer)             ;; save
(global-set-key (kbd "s-S") 'write-file)              ;; save as
(global-set-key (kbd "s-q") 'save-buffers-kill-emacs) ;; quit
(global-set-key (kbd "s-a") 'mark-whole-buffer)       ;; select all

;; bind undo/redo with the custom module
(global-set-key (kbd "s-z") 'undo)
(global-set-key (kbd "s-Z") 'undo-tree-redo)

(global-set-key (kbd "s-i") 'previous-line)
(global-set-key (kbd "s-k") 'next-line)
(global-set-key (kbd "s-j") 'left-char)
(global-set-key (kbd "s-l") 'right-char)

(global-set-key (kbd "s-<backspace>") 'kill-whole-line)
(global-set-key (kbd "M-S-<backspace>") 'kill-word)

;; Use Cmd for movement and selection.
(global-set-key (kbd "s-<right>") (kbd "C-e"))        ;; End of line
(global-set-key (kbd "S-s-<right>") (kbd "C-S-e"))    ;; Select to end of line
(global-set-key (kbd "s-<left>") (kbd "M-m"))         ;; Beginning of line (first non-whitespace character)
(global-set-key (kbd "S-s-<left>") (kbd "M-S-m"))     ;; Select to beginning of line
(global-set-key (kbd "s-<up>") 'beginning-of-buffer)  ;; First line
(global-set-key (kbd "s-<down>") 'end-of-buffer)      ;; Last line

;; Many commands in Emacs write the current position into mark ring.
;; These custom functions allow for quick movement backward and forward.
;; For example, if you were editing line 6, then did a search with Cmd+f, did something and want to come back,
;; press Cmd+, to go back to line 6. Cmd+. to go forward.
;; These keys are chosen because they are the same buttons as < and >, think of them as arrows.

(defun my-pop-local-mark-ring ()
  (interactive)
  (set-mark-command t))

(defun unpop-to-mark-command ()
  "Unpop off mark ring. Does nothing if mark ring is empty."
  (interactive)
      (when mark-ring
        (setq mark-ring (cons (copy-marker (mark-marker)) mark-ring))
        (set-marker (mark-marker) (car (last mark-ring)) (current-buffer))
        (when (null (mark t)) (ding))
        (setq mark-ring (nbutlast mark-ring))
        (goto-char (marker-position (car (last mark-ring))))))

(global-set-key (kbd "s-,") 'my-pop-local-mark-ring)
(global-set-key (kbd "s-.") 'unpop-to-mark-command)

;; Same keys with Shift will move you back and forward between open buffers.
(global-set-key (kbd "s-<") 'previous-buffer)
(global-set-key (kbd "s->") 'next-buffer)

;; Quickly insert new lines above or below the current line, with correct indentation.
(defun smart-open-line ()
  "Insert an empty line after the current line. Position the cursor at its beginning, according to the current mode."
  (interactive)
  (move-end-of-line nil)
  (newline-and-indent))

(defun smart-open-line-above ()
  "Insert an empty line above the current line. Position the cursor at it's beginning, according to the current mode."
  (interactive)
  (move-beginning-of-line nil)
  (newline-and-indent)
  (forward-line -1)
  (indent-according-to-mode))

(global-set-key (kbd "s-<return>") 'smart-open-line)            ;; Cmd+Return new line below
(global-set-key (kbd "s-S-<return>") 'smart-open-line-above)    ;; Cmd+Shift+Return new line above

;; Upcase and lowercase word or region, if selected.
;; To capitalize or un-capitalize word use Alt+c and Alt+l
(global-set-key (kbd "M-u") 'upcase-dwim)   ;; Alt+u upcase
(global-set-key (kbd "M-l") 'downcase-dwim) ;; Alt-l lowercase

;; Comment line or region.
(global-set-key (kbd "s-/") 'comment-line)

;; Visually find and replace text
(use-package visual-regexp
  :config
  (define-key global-map (kbd "s-r") 'vr/replace))  ;; Cmd+r find and replace

;; Multiple cursors. Similar to Sublime or VS Code.
(use-package multiple-cursors
  :config
  (setq mc/always-run-for-all 1)
  (global-set-key (kbd "s-d") 'mc/mark-next-like-this)        ;; Cmd+d select next occurrence of region
  (global-set-key (kbd "s-D") 'mc/mark-all-dwim)              ;; Cmd+Shift+d select all occurrences
  (global-set-key (kbd "M-s-d") 'mc/edit-beginnings-of-lines) ;; Alt+Cmd+d add cursor to each line in region
  (define-key mc/keymap (kbd "<return>") nil))

;; This is rather radical, but saves from a lot of pain in the ass.
;; When split is automatic, always split windows vertically
(setq split-height-threshold 0)
(setq split-width-threshold nil)

;; Go to other windows easily with one keystroke Cmd-something.
(global-set-key (kbd "s-1") (kbd "C-x 1"))  ;; Cmd-1 kill other windows (keep 1)
(global-set-key (kbd "s-2") (kbd "C-x 2"))  ;; Cmd-2 split horizontally
(global-set-key (kbd "s-3") (kbd "C-x 3"))  ;; Cmd-3 split vertically
(global-set-key (kbd "s-0") (kbd "C-x 0"))  ;; Cmd-0...
(global-set-key (kbd "s-w") (kbd "C-x 0"))  ;; ...and Cmd-w to close current window

;; Move between windows with Control-Command-Arrow and with =Cmd= just like in iTerm.
(use-package windmove
  :config
  (global-set-key (kbd "<C-s-left>")  'windmove-left)  ;; Ctrl+Cmd+left go to left window
  (global-set-key (kbd "s-[")  'windmove-left)         ;; Cmd+[ go to left window

  (global-set-key (kbd "<C-s-right>") 'windmove-right) ;; Ctrl+Cmd+right go to right window
  (global-set-key (kbd "s-]")  'windmove-right)        ;; Cmd+] go to right window

  (global-set-key (kbd "<C-s-up>")    'windmove-up)    ;; Ctrl+Cmd+up go to upper window
  (global-set-key (kbd "s-{")  'windmove-up)           ;; Cmd+Shift+[ go to upper window

  (global-set-key (kbd "<C-s-down>")  'windmove-down)  ;; Ctrl+Cmd+down go to down window
  (global-set-key (kbd "s-}")  'windmove-down))        ;; Cmd+Shift+] got to down window

;; Enable winner mode to quickly restore window configurations
(winner-mode 1)
(global-set-key (kbd "M-s-[") 'winner-undo)
(global-set-key (kbd "M-s-]") 'winner-redo)

;; Orgmode keybindings
(define-key global-map "\C-cc"
  (lambda () (interactive) (org-capture nil "a")))

(define-key global-map "\C-ct"
  (lambda () (interactive) (org-capture nil "t")))

(define-key global-map "\C-cj"
  (lambda () (interactive) (org-capture nil "j")))

(define-key global-map "\C-cn"
  (lambda () (interactive) (org-capture nil "n")))

(define-key global-map "\C-cr"
  (lambda () (interactive) (org-capture nil "r")))

(define-key global-map "\C-cp"
  (lambda () (interactive) (org-capture nil "p")))

(define-key global-map "\C-cw"
  (lambda () (interactive) (org-capture nil "w")))

;; Make font bigger/smaller.
(global-set-key (kbd "C-+") 'text-scale-increase)
(global-set-key (kbd "C--") 'text-scale-decrease)
(global-set-key (kbd "C-0") 'text-scale-adjust)

;; php-unit
(global-set-key (kbd "C-c C-t") 'phpunit-current-test)
(global-set-key (kbd "C-c M-t") 'phpunit-current-class)
