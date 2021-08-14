;; Packages from melpa stable
(require 'package)
(add-to-list 'package-archives '("melpa-stable" . "https://stable.melpa.org/packages/") t)
(package-initialize)

;; More screen estate.
(show-paren-mode 1)
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)

;; Buffer handling stuff on. Bell off.
(desktop-save-mode 1)
(winner-mode 1)
(setq visible-bell t)

;; Remove M-o, no need for enriched text and M-o is annoying.
(global-set-key (kbd "M-o") nil)

;; Make sure to not exit by accident
(defun jn-are-you-really-sure-advice (orig-fun &rest args)
  (let* ((n1 (random 10)) (n2 (random 10))
	 (ans (read-from-minibuffer (format
				     "Really sure? What is %d plus %d? " n1 n2))))
    (when (= (+ n1 n2)
	     (string-to-number ans))
      (apply orig-fun args))))
(advice-add 'save-buffers-kill-terminal :around #'jn-are-you-really-sure-advice)

;; Exercise!
(require 'notifications)
(defvar curr-notification-id nil)
(defun jn-getup-reminder ()
  (when (integerp curr-notification-id)
    (notifications-close-notification curr-notification-id))
  (setf curr-notification-id
	(notifications-notify :title "Take a break!"
                              :body "Stand Up Get Up!"
                              :level 'info)))
(defvar jn-getup-timer (run-at-time 1200 1200 'jn-getup-reminder))

;; Same for Windows, if ever stuck with that platform.
;; (defun jn-getup-reminder ()
;;   (when (integerp curr-notification-id)
;;     (w32-notification-close curr-notification-id))
;;   (setf curr-notification-id
;; 	(w32-notification-notify :title "Take a break!"
;; 				 :body "Stand Up Get Up!"
;; 				 :level 'info)))

(setq-default indent-tabs-mode nil)
(column-number-mode 1)
(setq next-line-add-newlines nil)

;; Slime
(load (expand-file-name "~/quicklisp/slime-helper.el"))
(setq inferior-lisp-program "sbcl")

;; Tramp to recognize "Verification code:" as password prompt.
(setq tramp-password-prompt-regexp
      (format "^.*\\(%s\\).*:\^@? *"
              ;; `password-word-equivalents' has been introduced with Emacs 24.4.
              (regexp-opt (or (cons "verification code" (bound-and-true-p password-word-equivalents))
                              '("password" "passphrase")))))

;; Ace-jump & ace-window settings (packages ace-jump-mode and ace-window)
(autoload 'ace-jump-mode "ace-jump-mode")
(define-key global-map (kbd "C-c j") 'ace-jump-mode)
(define-key global-map (kbd "C-c o") 'ace-window)

;; Paredit
(autoload 'enable-paredit-mode "paredit")
(dolist (hook '(emacs-lisp-mode-hook eval-expression-minibuffer-setup-hook
                ielm-mode-hook lisp-mode-hook lisp-interaction-mode-hook
                scheme-mode-hook clojure-mode-hook))
  (add-hook hook #'enable-paredit-mode))

;; ----------------------------------------------------------------------
;; Pic image interactive editing.

(defun pic-name-as-svg (pic-file-name)
  (concat (file-name-sans-extension pic-file-name) ".svg"))

(defun pic-make-svg-of (pic-file-name)
  (shell-command
     (format "pikchr --svg-only %s > %s" pic-file-name (pic-name-as-svg pic-file-name))))

(defun pic-preview (pic-file-name)
  (save-selected-window
    (let* ((svg-file-name (pic-name-as-svg pic-file-name))
           (revert-without-query
            (list (regexp-quote (abbreviate-file-name svg-file-name)))))
      (find-file-other-window (pic-name-as-svg pic-file-name) t))))

(defun pic-after-save ()
  (let ((pic-file-name (buffer-file-name)))
    (when (equalp (file-name-extension pic-file-name) "pic")
      (pic-make-svg-of pic-file-name)
      (pic-preview pic-file-name))))

(add-hook 'after-save-hook #'pic-after-save)

;; Pic image interactive editing ends.
;; ----------------------------------------------------------------------

;; 
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   '(elisp-lint package-lint org-static-blog magit elisp-slime-nav paredit ace-window ace-jump-mode)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
