(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-enabled-themes (quote (tsdh-dark)))
 '(inhibit-startup-screen t)
 '(package-selected-packages (quote (flycheck))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

;; ###################################################
;; Jss Customisation QuickRef:

;; These should all toggle:
;; <f12>       : folding of indented regions
;; <f11>       : highlight-indentation-mode
;; <f10>       : highlight-indentation-current-column-mode
;; <f9>        : font-lock-mode
;;
;; TIPS:
;;
;; 1) Can't seem to stop emacs splitting windows with buffer list when opening multiple files
;; But can use C-x 1 to close the buffer window, without middle-clicking on mode line, which is error-prone
;;
;; 2) If using emacs without modofied syntax table setup below:
;;      -Selecting whole words containing multiple - and _ characters can be done 
;;       by just double-click ON on of the - or _ characters.


;; ###################################################
;; Tell emacs where is your personal elisp lib dir
(add-to-list 'load-path "~/.emacs.d/lisp/")

;; ###################################################
;; Fix infuriating default setting which pastes to mouse location, instead of cursor:
;; Slightest movement of mouse when you do the middle-click, and paste goes into wrong location.
;;
;; Just put the cursor where you want to paste, then middle-clicK:
;; This works beautifully. Thank Christ.
(setq mouse-yank-at-point t)

;; Increase default window size:
(add-to-list 'default-frame-alist '(height . 45))
(add-to-list 'default-frame-alist '(width . 150))

;; ###################################################
;; Fix horrific indent behaviour when hitting newline:
;; This is now the default, and it sucks

;; THIS WORKS:
(when (fboundp 'electric-indent-mode) (electric-indent-mode -1))

;;Method below was working, but not anymore:

;;(defun set-newline-and-indent ()
;;  (local-set-key (kbd "RET") 'newline-and-indent))

;;(defun set-newline-no-indent ()
;;  (local-set-key (kbd "RET") 'newline))

;;(add-hook 'lisp-mode-hook 'set-newline-no-indent)
;;(add-hook 'text-mode-hook 'set-newline-no-indent)
;;(add-hook 'prog-mode-hook 'set-newline-no-indent)
;;(add-hook 'sh-mode-hook 'set-newline-no-indent)

;;;;;;;;;;(define-key global-map (kbd "RET") 'newline-and-indent)
;;(define-key global-map (kbd "RET") 'newline)

;; ###################################################
;; fix stupid emacs word separator so i can click on identifiers and grab the whole thing
;; without it splitting on - amb _
;;
;; TIP:
;; Bah. Methods below don't work, but you can at least select a whole word containing 
;; multiple - and _ characters by double-clicking ON on of the - or _ characters.

;;    ‘standard-syntax-table’ – This function returns the standard syntax table; most major-modes inherit it.
;;    ‘text-mode-syntax-table’ – Syntax table used by the major mode for editing text files.
;;    ‘c-mode-syntax-table’ – Syntax table for C-mode buffers.
;;    ‘java-mode-syntax-table’ – Syntax table for java-mode buffers.
;;    ‘emacs-lisp-mode-syntax-table’ – For EmacsLispMode buffers.
;;    ‘lisp-mode-syntax-table’ – Syntax table for lisp-mode buffers.
;;    ‘lisp-interaction-mode-syntax-table’ – Used in the scratch buffer.
;;    ‘message-mode-syntax-table’ – Syntax table used in message mode.

;;This works!! Just modify the default current syntax table:
(modify-syntax-entry ?_ "w")
(modify-syntax-entry ?- "w")

;; Bah. Not working:
;;(require 'misc)
;;(modify-syntax-entry ?_ "w" 'standard-syntax-table)
;;(modify-syntax-entry ?- "w" 'standard-syntax-table)

;; ###################################################
;; from ./.emacs.d/lisp/highlight-indentation.el
;; highlight-indentation-mode                  guidelines indentation (space indentation only).
;; highlight-indentation-current-column-mode   guidelines for current-point indentation (space indentation only).

(load "highlight-indentation") ;; best not to include the ending “.el” or “.elc”
(add-to-list 'auto-mode-alist '("\\.yml\\'" . sh-mode))

;;Hmm, one would think add-to-list should be adding to a list of enabled modes,
;; but if i enable this, then it turns off sh-mode.
;;If i disable this, the prog-mode-hook turns it on anyway :-)
;;(add-to-list 'auto-mode-alist '("\\.yml\\'" . highlight-indentation-mode))

(set-face-background 'highlight-indentation-face "#e3e3d3")
(set-face-background 'highlight-indentation-current-column-face "#c3b3b3")

;;annoying to have this on by default as it hides cursor in leftmost column
;;(add-hook 'text-mode-hook 'highlight-indentation-mode)
;;(add-hook 'prog-mode-hook 'highlight-indentation-mode)

;;use f10 and f11 to toggle on and off:
(global-set-key (kbd "<f11>") 'highlight-indentation-mode)
(global-set-key (kbd "<f10>") 'highlight-indentation-current-column-mode)

;; ###################################################
(defun aj-toggle-fold ()
  "Toggle fold all lines larger than indentation on current line"
  (interactive)
  (let ((col 1))
    (save-excursion
      (back-to-indentation)
      (setq col (+ 1 (current-column)))
      (set-selective-display
       (if selective-display nil (or col 1))))))
;; alt-ctrl-i:
(global-set-key [(M C i)] 'aj-toggle-fold)
;;i prefer alt-f or f12:
(global-set-key (kbd "<f12>") 'aj-toggle-fold)

;; ###################################################
;; http://ergoemacs.org/emacs/whitespace-mode.html
;; Alt+x whitespace-mode (in emacs 23 or later), to make all whitespaces visible
;; Alt+x whitespace-newline-mode to make (only) newline visible.

;; ###################################################
;; Set dark theme with:
;; M-x customize-themes
;; tsdh-dark  - this is nice

;; ###################################################
;; Nay want to try custom themes from melpa:
;;(require 'package) ;; You might already have this line
;;(let* ((no-ssl (and (memq system-type '(windows-nt ms-dos))
;;                    (not (gnutls-available-p))))
;;       (url (concat (if no-ssl "http" "https") "://melpa.org/packages/")))
;;  (add-to-list 'package-archives (cons "melpa" url) t))
;;(when (< emacs-major-version 24)
;;  ;; For important compatibility libraries like cl-lib
;;  (add-to-list 'package-archives '("gnu" . "http://elpa.gnu.org/packages/")))
;;(package-initialize) ;; You might already have this line

;; ###################################################
;;Major modes:

;;asm-mode 	Assembly code
;;awk-mode 	awk code
;;c++-mode 	C++ code
;;c-mode 	C code
;;fortran-mode 	Fortran code
;;fundamental-mode 	Default mode
;;latex-mode 	LaTeX files
;;lisp-mode 	
;;Lisp code (other than Emacs Lisp)
;;pascal-mode 	Pascal code
;;perl-mode 	Perl code
;;scheme-mode 	Scheme code
;;sgml-mode 	SGML code
;;tex-mode 	TeX files
;;text-mode 	Regular text
;;
;;also some/all programming major modes are derived from: prog-mode 

;; ###################################################
;; Minor modes:
;; https://www.gnu.org/software/emacs/manual/html_node/emacs/Minor-Modes.html

;; font-lock
(global-set-key (kbd "<f9>") 'font-lock-mode)

;; ###################################################
;;flycheck syntax checking package:
(require 'package)

;;uncomment temporarily to install/update flycheck mode, then comment out again:
;;(add-to-list 'package-archives
;;  '("MELPA Stable" . "http://stable.melpa.org/packages/") t)

(package-initialize)

;;uncomment to update:
;;(package-refresh-contents)

;;uncomment to enable:
;;(package-install 'flycheck)
;;(global-flycheck-mode)
;; ###################################################
