;; Basic setting
(setq inhibit-splash-screen t)
(setq inhibit-startup-message t)

;; 80 characters rule
(setq column-number-mode t)
(setq-default fill-column 80)
(setq-default auto-fill-function 'do-auto-fill)

;; highlight parentthess
(show-paren-mode 1)
;; backup everything to ~/.saves
(setq
 backup-by-copying t
 backup-directory-alist '(("." . "~/.saves/")))

;;; auto refresh file
(global-auto-revert-mode t)
(tool-bar-mode -1)
(toggle-scroll-bar -1)

;; add MELPA
(require 'package)
(setq package-archives
      '(("gnu" . "https://elpa.gnu.org/packages/")
	("melpa-stb" . "https://stable.melpa.org/packages/")
	("melpa" . "https://melpa.org/packages/"))
      tls-checktrust t
      tls-program '("gnutls-cli --x509cafile %t -p %p %h")
      gnutls-verify-error t)
(add-to-list 'package-archives
             '("melpa-stable" . "https://stable.melpa.org/packages/") t)
(package-initialize)

;; setup use-package
(setq use-package-always-ensure nil)

(unless (require 'use-package nil t)
  (if (not (yes-or-no-p (concat "Refresh packages, install use-package and"
				" other packages used by init file? ")))
      (error "you need to install use-package first")
    (package-refresh-contents)
    (package-install 'use-package)
    (require 'use-package)
    (setq use-package-always-ensure t)))


(use-package alect-themes
  :ensure t
  :config
  (load-theme 'alect-black t))

;;; Productivity
;;; ------------


;;; ### Key discoverability ###

;;; If you type a prefix key (such as `C-x r`) and wait some time then
;;; display window with keys that can follow.

(use-package which-key
  :config
  (which-key-mode))

;;; List of personal key bindings

(global-set-key (kbd "C-c h b") 'describe-personal-keybindings)

(use-package remind-bindings
  :bind ("H-?" . remind-bindings-togglebuffer))

;;; ### More efficient buffer/file selection ###

(setq recentf-max-saved-items 100)

(global-set-key "\C-cq" #'bury-buffer)

(use-package flx
  :after ivy)

(use-package counsel
  :demand
  :init
  (setq ivy-use-virtual-buffers t
	ivy-re-builders-alist
	'((counsel-git-grep . ivy--regex-plus)
	  (counsel-rg . ivy--regex-plus)
	  (swiper . ivy--regex-plus)
	  (swiper-all . ivy--regex-plus)
	  (t . ivy--regex-fuzzy)))
  :config
  (add-to-list 'ivy-ignore-buffers "\\`\\*remind-bindings\\*")
  (ivy-mode 1)
  (counsel-mode 1)
  :bind
  (("C-c E" . counsel-flycheck)
   ("C-c f" . counsel-fzf)
   ("C-c g" . counsel-git)
   ("C-c j" . counsel-git-grep)
   ("C-c L" . counsel-locate)
   ("C-c o" . counsel-outline)
   ("C-c r" . counsel-rg)
   ("C-c R" . counsel-register)
   ("C-c T" . counsel-load-theme)))

(use-package ivy-rich
  :config
  (setq ivy-rich-display-transformers-list
	(plist-put ivy-rich-display-transformers-list
		   'ivy-switch-buffer
		   '(:columns
		     ((ivy-switch-buffer-transformer (:width 40))
		      (ivy-rich-switch-buffer-project
		       (:width 15 :face success))
		      (ivy-rich-switch-buffer-path
		       (:width (lambda (x)
				 (ivy-rich-switch-buffer-shorten-path
				  x (ivy-rich-minibuffer-width 0.3))))))
		     :predicate (lambda (cand) (get-buffer cand)))))
  (ivy-rich-mode 1))

;; explorer sidebar
(use-package treemacs
  :ensure t
  :defer t
  :init
  (with-eval-after-load 'winum
    (define-key winum-keymap (kbd "M-0") #'treemacs-select-window))
  :config
  (progn
    (setq treemacs-collapse-dirs                 (if treemacs-python-executable 3 0)
          treemacs-deferred-git-apply-delay      0.5
          treemacs-directory-name-transformer    #'identity
          treemacs-display-in-side-window        t
          treemacs-eldoc-display                 t
          treemacs-file-event-delay              5000
          treemacs-file-extension-regex          treemacs-last-period-regex-value
          treemacs-file-follow-delay             0.2
          treemacs-file-name-transformer         #'identity
          treemacs-follow-after-init             t
          treemacs-git-command-pipe              ""
          treemacs-goto-tag-strategy             'refetch-index
          treemacs-indentation                   2
          treemacs-indentation-string            " "
          treemacs-is-never-other-window         nil
          treemacs-max-git-entries               5000
          treemacs-missing-project-action        'ask
          treemacs-move-forward-on-expand        nil
          treemacs-no-png-images                 nil
          treemacs-no-delete-other-windows       t
          treemacs-project-follow-cleanup        nil
          treemacs-persist-file                  (expand-file-name ".cache/treemacs-persist" user-emacs-directory)
          treemacs-position                      'left
          treemacs-read-string-input             'from-child-frame
          treemacs-recenter-distance             0.1
          treemacs-recenter-after-file-follow    nil
          treemacs-recenter-after-tag-follow     nil
          treemacs-recenter-after-project-jump   'always
          treemacs-recenter-after-project-expand 'on-distance
          treemacs-show-cursor                   nil
          treemacs-show-hidden-files             t
          treemacs-silent-filewatch              nil
          treemacs-silent-refresh                nil
          treemacs-sorting                       'alphabetic-asc
          treemacs-space-between-root-nodes      t
          treemacs-tag-follow-cleanup            t
          treemacs-tag-follow-delay              1.5
          treemacs-user-mode-line-format         nil
          treemacs-user-header-line-format       nil
          treemacs-width                         35
          treemacs-workspace-switch-cleanup      nil)

    ;; The default width and height of the icons is 22 pixels. If you are
    ;; using a Hi-DPI display, uncomment this to double the icon size.
    ;;(treemacs-resize-icons 44)

    (treemacs-follow-mode t)
    (treemacs-filewatch-mode t)
    (treemacs-fringe-indicator-mode 'always)
    (pcase (cons (not (null (executable-find "git")))
                 (not (null treemacs-python-executable)))
      (`(t . t)
       (treemacs-git-mode 'deferred))
      (`(t . _)
       (treemacs-git-mode 'simple))))
  :bind
  (:map global-map
        ("M-0"       . treemacs-select-window)
        ("C-x t 1"   . treemacs-delete-other-windows)
        ("C-x t t"   . treemacs)
        ("C-x t B"   . treemacs-bookmark)
        ("C-x t C-t" . treemacs-find-file)
        ("C-x t M-t" . treemacs-find-tag)))

(use-package treemacs-evil
  :after treemacs evil
  :ensure t)

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

(use-package treemacs-persp ;;treemacs-perspective if you use perspective.el vs. persp-mode
  :after treemacs persp-mode ;;or perspective vs. persp-mode
  :ensure t
  :config (treemacs-set-scope-type 'Perspectives))

;; Cycle through buffers’ history
(use-package buffer-flip
  :bind
  (("H-f" . buffer-flip)
   :map buffer-flip-map
   ("H-f" . buffer-flip-forward)
   ("H-F" . buffer-flip-backward)
   ("C-g" . buffer-flip-abort)))

;; Window selection enhancements
(use-package ace-window
  :init
  (setq aw-scope 'frame ; limit to single frame
        aw-keys '(?a ?s ?d ?f ?g ?h ?j ?k ?l))
  :bind
  ("C-x o" . ace-window))

(use-package windmove
  :demand
  :bind
  (("H-w j" . windmove-down)
   ("H-w k" . windmove-up)
   ("H-w h" . windmove-left)
   ("H-w l" . windmove-right))
  :config
  (windmove-default-keybindings))

(use-package windswap
  :demand
  :bind
  (("H-w J" . windswap-down)
   ("H-w K" . windswap-up)
   ("H-w H" . windswap-left)
   ("H-w L" . windswap-right))
  :config
  (windswap-default-keybindings))

;; Allow for Undo/Redo of window manipulations (such as C-x 1)
(winner-mode 1)

;; In buffer movement enhancements
;; Improved in buffer search
(use-package ctrlf
  :config
  (ctrlf-mode 1))

;; Type substring and wait to select one of its visible occurrences (even in
;; other windows) with a single or two letters.
(use-package avy
  :bind
  (("H-." . avy-goto-char-timer)
   ("H-," . avy-goto-line)))

;; Bind key o to selection of a link in help or info buffers by a single or two
;; letters. 
(use-package ace-link
  :config
  (ace-link-setup-default))

;; Select from visible errors by a single letter
(use-package avy-flycheck
  :bind
  ("C-c '" . avy-flycheck-goto-error))

;; Go to last change in the current buffer
(use-package goto-chg
  :bind
  ("C-c G" . goto-last-change))

;; Editing enhancement
(use-package smartparens
  :defer)

;; Edit with multiple cursors
(use-package multiple-cursors
  :bind
  (("C-c n" . mc/mark-next-like-this)
   ("C-c p" . mc/mark-previous-like-this)))

;; Fix trailing spaces but only in modified lines
(use-package ws-butler
  :hook (prog-mode . ws-butler-mode))

;; Expand region
(use-package expand-region
  :bind ("H-e" . er/expand-region))

;; Spell checking
(setq ispell-dictionary "american")

(defun my-american-dict ()
  "Change dictionary to american."
  (interactive)
  (setq ispell-local-dictionary "american")
  (flyspell-mode 1)
  (flyspell-buffer))

(defalias 'ir #'ispell-region)

;; Shell and terminal
(use-package shell-pop
  :init
  (setq shell-pop-full-span t)
  :bind (("C-c s" . shell-pop)))

;; Git
(use-package magit
  :bind (("C-x g" . magit-status)
         ("C-x M-g" . magit-dispatch)))

;; Yasnippet and abbrev mode
(setq-default abbrev-mode 1)

(use-package yasnippet
  :hook (after-init . yas-global-mode)
  :bind
  (:map yas-minor-mode-map
        ("C-c & t" . yas-describe-tables)
        ("C-c & &" . org-mark-ring-goto)))

(use-package yasnippet-snippets
  :defer)

(use-package ivy-yasnippet
  :bind
  (("C-c y" . ivy-yasnippet)))

;; For programming
;; Use company for auto completion
(use-package company
  :init
  (setq company-idle-delay nil  ; avoid auto completion popup, use TAB
                                ; to show it
        company-async-timeout 15        ; completion may be slow
        company-tooltip-align-annotations t)
  :hook (after-init . global-company-mode)
  :bind
  (:map prog-mode-map
        ("C-i" . company-indent-or-complete-common)
        ("C-M-i" . counsel-company)))

;; Language server
(use-package eglot
  :config
  (add-to-list 'eglot-server-programs '(f90-mode . ("fortls")))
  (add-hook 'f90-mode-hook 'eglot-ensure)
  )

;; PDF view and edit
(use-package pdf-tools
  :ensure t
  :config

  ;;initialize
  (pdf-tools-install)

  ;; open pdfs scaled to fit page
  (setq-default pdf-view-display-size 'fit-page)

  ;; automatically annotate highlights
  (setq-default pdf-annot-activate-created-annotations t)
  )

;; Web browser
(use-package eww
  :ensure t
  :config
  (setq eww-search-prefix "https://www.google.com/search?q=")

  )

;; Python environment
(use-package pyvenv
  :ensure t
  :init
  (pyvenv-mode 1)
  (setenv "WORKON_HOME" "/home/duosifan/miniconda3/envs")
  (pyvenv-tracking-mode 1))

(use-package conda
  :config (progn
            (conda-env-initialize-interactive-shells)
            (conda-env-initialize-eshell)
            (conda-env-autoactivate-mode t)
            (setq conda-env-home-directory (expand-file-name "~/miniconda3"))
            (custom-set-variables '(conda-anaconda-home "~/miniconda3"))))

(use-package jupyter
  :commands (jupyter-run-server-repl
             jupyter-run-repl
             jupyter-server-list-kernels)
  :init (eval-after-load 'jupyter-org-extensions ; conflicts with my helm config, I use <f2 #>
          '(unbind-key "C-c h" jupyter-org-interaction-mode-map))
  (setq indent-tabs-mode nil)
  )

;; ob
(use-package ob
  :ensure nil
  :config (progn
            ;; load more languages for org-babel
            (org-babel-do-load-languages
             'org-babel-load-languages
             '((python . t)
	       (shell . t)
               (jupyter . t)))          ; must be last
            (setq org-babel-default-header-args:shell  '((:results . "output replace")
							 (:session . "project")
							 (:async   . "yes"))
                  org-babel-default-header-args:jupyter-python '((:async . "yes")
                                                                 (:session . "py")
                                                                 (:kernel . "CFL3D")))
            (setq org-confirm-babel-evaluate nil)
	    (setq org-export-babel-evaluate nil)
            (add-hook 'org-babel-after-execute-hook 'org-display-inline-images))
  )

;; org configuration
(use-package org
  :defer t
  :init
  (setq org-log-done t)
  (setq org-agenda-files (list "~/org/work.org"
                               "~/org/school.org"
                               "~/org/home.org"))
  :bind(
	("\C-cl" . org-store-link)
	("\C-ca" . org-agenda))
  )


(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(conda-anaconda-home "~/miniconda3")
 '(custom-safe-themes
   '("04dd0236a367865e591927a3810f178e8d33c372ad5bfef48b5ce90d4b476481" default))
 '(package-selected-packages
   '(pyvenv alect-themes conda jupyter treemacs-persp treemacs-magit treemacs-icons-dired treemacs-projectile treemacs-evil pdf-tools nimbus-theme zenburn-theme solarized-theme eglot company ivy-yasnippet yasnippet-snippets yasnippet magit shell-pop expand-region ws-butler multiple-cursors smartparens goto-chg avy-flycheck ace-link ctrlf windswap buffer-flip treemacs ivy-rich counsel flx remind-bindings which-key use-package)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
