;;; alamode.el --- a simple package                     -*- lexical-binding: t; -*-

;; Copyright (C) 2021  Jeet Ray

;; Author: Jeet Ray <aiern@protonmail.com>
;; Keywords: lisp
;; Version: 0.0.1

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; Put a description of the package here

;;; Code:

(require 'deino)
(require 'meq)

;; Adapted From: https://gitlab.com/jjzmajic/hercules.el/-/blob/master/hercules.el#L83
;;;###autoload
(defun meq/toggle-inner (mode prefix mode-on map &optional use-hercules force) (interactive)
    (meq/disable-all-modal-modes)
    (if mode-on
        (when force (meq/which-key--show-popup map force))
        (funcall mode 1)
        (if use-hercules (ignore-errors (funcall (intern (concat "meq/" prefix "-hercules-show"))))
            (meq/which-key-show-top-level map))
        (setq current-modal-mode mode)
        (setq last-modal-mode mode)))

;; Adapted From: https://github.com/emacsorphanage/god-mode/blob/master/god-mode.el#L392
;;;###autoload
(defun meq/execute-with-current-bindings-inner (mode prefix mode-on map &optional use-hercules called-interactively)
    (interactive "d")
    (if called-interactively
        (unless mode-on
        (letrec ((caller this-command)
                (buffer (current-buffer))
                (cleanup
                    (lambda ()
                    ;; Perform cleanup in original buffer even if the command
                    ;; switched buffers.
                    (if (buffer-live-p buffer)
                        (with-current-buffer buffer
                            (unwind-protect
                                (meq/disable-all-modal-modes)
                                (when backup-modal-mode
                                    (funcall (intern (concat
                                        "meq/toggle-"
                                        (car (split-string (symbol-name mode) "-"))
                                        (when mode-was-hercules "-hercules")))))
                                (remove-hook 'post-command-hook post-hook)))
                        (remove-hook 'post-command-hook post-hook))))
                (kill-transient-map
                    (set-transient-map
                    map 'meq/god-prefix-command-p cleanup))
                (post-hook
                    (lambda ()
                    (unless (and
                            (eq this-command caller)
                            ;; If we've entered the minibuffer, this implies
                            ;; a non-prefix command was run, even if
                            ;; `this-command' has not changed.  For example,
                            ;; `execute-extended-command' behaves this way.
                            (not (window-minibuffer-p)))
                        (funcall kill-transient-map)))))
            (add-hook 'post-command-hook post-hook)
            ;; Pass the current prefix argument along to the next command.
            (setq prefix-arg current-prefix-arg)
            ;; Technically we don't need to activate %p mode since the
            ;; transient keymap is already in place, but it's useful to provide
            ;; a mode line lighter and run any hook functions the user has set
            ;; up.  This could be made configurable in the future.
            (setq backup-modal-mode current-modal-mode
                mode-was-hercules overriding-terminal-local-map)
            (meq/disable-all-modal-modes)
            (funcall (intern (concat "meq/toggle-" prefix)))
            (when use-hercules (funcall (intern (concat "meq/" prefix "-hercules-show"))))
            (setq deino-enabled-temporarily t)
            (message (format "Switched to %s mode for the next command ..." prefix))))
    (error "This function should only be called interactively")))

(defun meq/toggle-evil-or-aiern-execute (ua) (interactive "p")
    (cond
        ((= ua 4) (meq/toggle-evil))
        ((= ua 16) (meq/toggle-evil-force))
        (t (meq/aiern-execute-with-current-bindings t))))

(defdeino+ toggles (:color blue)
    ("a" meq/toggle-aiern "aiern"))
(defdeino+ all-keymaps (:color blue)
    ("a" (progn (setq all-keymaps-map 'aiern-normal-state-map)
    (meq/aiern-show-top-level)) "aiern"))

(hercules-def
    :show-funs #'meq/aiern-hercules-show
    :hide-funs #'meq/aiern-hercules-hide
    :toggle-funs #'meq/aiern-hercules-toggle
    :keymap 'aiern-normal-state-map
    ;; :transient t
)

;;;###autoload
(defun meq/aiern-hercules-toggle nil (interactive) (with-eval-after-load 'aiern))

;;;###autoload
(defun meq/aiern-show-top-level nil (interactive)
    (with-eval-after-load 'aiern (meq/which-key-show-top-level 'aiern-normal-state-map)))

;;;###autoload
(defun meq/toggle-aiern nil (interactive)
    (with-eval-after-load 'aiern (funcall 'meq/toggle-inner 'aiern-mode "aiern" (meq/fbatp aiern-mode) 'aiern-normal-state-map)))

;;;###autoload
(defun meq/toggle-aiern-force nil (interactive)
    (with-eval-after-load 'aiern (funcall 'meq/toggle-inner 'aiern-mode "aiern" (meq/fbatp aiern-mode) 'aiern-normal-state-map nil t)))

;;;###autoload
(defun meq/toggle-aiern-hercules nil (interactive)
    (with-eval-after-load 'aiern (funcall 'meq/toggle-inner 'aiern-mode "aiern" (meq/fbatp aiern-mode) 'aiern-normal-state-map t)))

;;;###autoload
(defun meq/toggle-aiern-hercules-force nil (interactive)
    (with-eval-after-load 'aiern (funcall 'meq/toggle-inner 'aiern-mode "aiern" (meq/fbatp aiern-mode) 'aiern-normal-state-map t t)))

;;;###autoload
(defun meq/aiern-execute-with-current-bindings (&optional called-interactively) (interactive "d")
    (with-eval-after-load 'aiern (funcall 'meq/execute-with-current-bindings-inner 'aiern-mode "aiern" (meq/fbatp aiern-mode) 'aiern-normal-state-map nil called-interactively)))

;;;###autoload
(defun meq/aiern-hercules-execute-with-current-bindings (&optional called-interactively) (interactive "d")
    (with-eval-after-load 'aiern (funcall 'meq/execute-with-current-bindings-inner 'aiern-mode "aiern" (meq/fbatp aiern-mode) 'aiern-normal-state-map t called-interactively)))

(with-eval-after-load 'aiern (add-to-list 'modal-modes 'aiern-mode) (add-to-list 'modal-prefixes "aiern"))

(defdeino+ toggles (:color blue)
    ("r" meq/toggle-ryo "ryo"))
(defdeino+ all-keymaps (:color blue)
    ("r" (progn (setq all-keymaps-map 'ryo-modal-mode-map)
    (meq/ryo-show-top-level)) "ryo"))

(hercules-def
    :show-funs #'meq/ryo-hercules-show
    :hide-funs #'meq/ryo-hercules-hide
    :toggle-funs #'meq/ryo-hercules-toggle
    :keymap 'ryo-modal-mode-map
    ;; :transient t
)

;;;###autoload
(defun meq/ryo-hercules-toggle nil (interactive) (with-eval-after-load 'ryo-modal))

;;;###autoload
(defun meq/ryo-show-top-level nil (interactive)
    (with-eval-after-load 'ryo-modal (meq/which-key-show-top-level 'ryo-modal-mode-map)))

;;;###autoload
(defun meq/toggle-ryo nil (interactive)
    (with-eval-after-load 'ryo-modal (funcall 'meq/toggle-inner 'ryo-modal-mode "ryo" (meq/fbatp ryo-modal-mode) 'ryo-modal-mode-map)))

;;;###autoload
(defun meq/toggle-ryo-force nil (interactive)
    (with-eval-after-load 'ryo-modal (funcall 'meq/toggle-inner 'ryo-modal-mode "ryo" (meq/fbatp ryo-modal-mode) 'ryo-modal-mode-map nil t)))

;;;###autoload
(defun meq/toggle-ryo-hercules nil (interactive)
    (with-eval-after-load 'ryo-modal (funcall 'meq/toggle-inner 'ryo-modal-mode "ryo" (meq/fbatp ryo-modal-mode) 'ryo-modal-mode-map t)))

;;;###autoload
(defun meq/toggle-ryo-hercules-force nil (interactive)
    (with-eval-after-load 'ryo-modal (funcall 'meq/toggle-inner 'ryo-modal-mode "ryo" (meq/fbatp ryo-modal-mode) 'ryo-modal-mode-map t t)))

;;;###autoload
(defun meq/ryo-execute-with-current-bindings (&optional called-interactively) (interactive "d")
    (with-eval-after-load 'ryo-modal (funcall 'meq/execute-with-current-bindings-inner 'ryo-modal-mode "ryo" (meq/fbatp ryo-modal-mode) 'ryo-modal-mode-map nil called-interactively)))

;;;###autoload
(defun meq/ryo-hercules-execute-with-current-bindings (&optional called-interactively) (interactive "d")
    (with-eval-after-load 'ryo-modal (funcall 'meq/execute-with-current-bindings-inner 'ryo-modal-mode "ryo" (meq/fbatp ryo-modal-mode) 'ryo-modal-mode-map t called-interactively)))

(with-eval-after-load 'ryo-modal (add-to-list 'modal-modes 'ryo-modal-mode) (add-to-list 'modal-prefixes "ryo"))

(defdeino+ toggles (:color blue)
    ("s" meq/toggle-sorrow "sorrow"))
(defdeino+ all-keymaps (:color blue)
    ("s" (progn (setq all-keymaps-map 'sorrow-mode-map)
    (meq/sorrow-show-top-level)) "sorrow"))

(hercules-def
    :show-funs #'meq/sorrow-hercules-show
    :hide-funs #'meq/sorrow-hercules-hide
    :toggle-funs #'meq/sorrow-hercules-toggle
    :keymap 'sorrow-mode-map
    ;; :transient t
)

;;;###autoload
(defun meq/sorrow-hercules-toggle nil (interactive) (with-eval-after-load 'sorrow))

;;;###autoload
(defun meq/sorrow-show-top-level nil (interactive)
    (with-eval-after-load 'sorrow (meq/which-key-show-top-level 'sorrow-mode-map)))

;;;###autoload
(defun meq/toggle-sorrow nil (interactive)
    (with-eval-after-load 'sorrow (funcall 'meq/toggle-inner 'sorrow-mode "sorrow" (meq/fbatp sorrow-mode) 'sorrow-mode-map)))

;;;###autoload
(defun meq/toggle-sorrow-force nil (interactive)
    (with-eval-after-load 'sorrow (funcall 'meq/toggle-inner 'sorrow-mode "sorrow" (meq/fbatp sorrow-mode) 'sorrow-mode-map nil t)))

;;;###autoload
(defun meq/toggle-sorrow-hercules nil (interactive)
    (with-eval-after-load 'sorrow (funcall 'meq/toggle-inner 'sorrow-mode "sorrow" (meq/fbatp sorrow-mode) 'sorrow-mode-map t)))

;;;###autoload
(defun meq/toggle-sorrow-hercules-force nil (interactive)
    (with-eval-after-load 'sorrow (funcall 'meq/toggle-inner 'sorrow-mode "sorrow" (meq/fbatp sorrow-mode) 'sorrow-mode-map t t)))

;;;###autoload
(defun meq/sorrow-execute-with-current-bindings (&optional called-interactively) (interactive "d")
    (with-eval-after-load 'sorrow (funcall 'meq/execute-with-current-bindings-inner 'sorrow-mode "sorrow" (meq/fbatp sorrow-mode) 'sorrow-mode-map nil called-interactively)))

;;;###autoload
(defun meq/sorrow-hercules-execute-with-current-bindings (&optional called-interactively) (interactive "d")
    (with-eval-after-load 'sorrow (funcall 'meq/execute-with-current-bindings-inner 'sorrow-mode "sorrow" (meq/fbatp sorrow-mode) 'sorrow-mode-map t called-interactively)))

(with-eval-after-load 'sorrow (add-to-list 'modal-modes 'sorrow-mode) (add-to-list 'modal-prefixes "sorrow"))

(defdeino+ toggles (:color blue)
    ("e" meq/toggle-evil "evil"))
(defdeino+ all-keymaps (:color blue)
    ("e" (progn (setq all-keymaps-map 'evil-normal-state-map)
    (meq/evil-show-top-level)) "evil"))

(hercules-def
    :show-funs #'meq/evil-hercules-show
    :hide-funs #'meq/evil-hercules-hide
    :toggle-funs #'meq/evil-hercules-toggle
    :keymap 'evil-normal-state-map
    ;; :transient t
)

;;;###autoload
(defun meq/evil-hercules-toggle nil (interactive) (with-eval-after-load 'evil))

;;;###autoload
(defun meq/evil-show-top-level nil (interactive)
    (with-eval-after-load 'evil (meq/which-key-show-top-level 'evil-normal-state-map)))

;;;###autoload
(defun meq/toggle-evil nil (interactive)
    (with-eval-after-load 'evil (funcall 'meq/toggle-inner 'evil-mode "evil" (meq/fbatp evil-mode) 'evil-normal-state-map)))

;;;###autoload
(defun meq/toggle-evil-force nil (interactive)
    (with-eval-after-load 'evil (funcall 'meq/toggle-inner 'evil-mode "evil" (meq/fbatp evil-mode) 'evil-normal-state-map nil t)))

;;;###autoload
(defun meq/toggle-evil-hercules nil (interactive)
    (with-eval-after-load 'evil (funcall 'meq/toggle-inner 'evil-mode "evil" (meq/fbatp evil-mode) 'evil-normal-state-map t)))

;;;###autoload
(defun meq/toggle-evil-hercules-force nil (interactive)
    (with-eval-after-load 'evil (funcall 'meq/toggle-inner 'evil-mode "evil" (meq/fbatp evil-mode) 'evil-normal-state-map t t)))

;;;###autoload
(defun meq/evil-execute-with-current-bindings (&optional called-interactively) (interactive "d")
    (with-eval-after-load 'evil (funcall 'meq/execute-with-current-bindings-inner 'evil-mode "evil" (meq/fbatp evil-mode) 'evil-normal-state-map nil called-interactively)))

;;;###autoload
(defun meq/evil-hercules-execute-with-current-bindings (&optional called-interactively) (interactive "d")
    (with-eval-after-load 'evil (funcall 'meq/execute-with-current-bindings-inner 'evil-mode "evil" (meq/fbatp evil-mode) 'evil-normal-state-map t called-interactively)))

(with-eval-after-load 'evil (add-to-list 'modal-modes 'evil-mode) (add-to-list 'modal-prefixes "evil"))

(defdeino+ toggles (:color blue)
    ("g" meq/toggle-god "god"))
(defdeino+ all-keymaps (:color blue)
    ("g" (progn (setq all-keymaps-map 'global-map)
    (meq/god-show-top-level)) "god"))

(hercules-def
    :show-funs #'meq/god-hercules-show
    :hide-funs #'meq/god-hercules-hide
    :toggle-funs #'meq/god-hercules-toggle
    :keymap 'global-map
    ;; :transient t
)

;;;###autoload
(defun meq/god-hercules-toggle nil (interactive) (with-eval-after-load 'god-mode))

;;;###autoload
(defun meq/god-show-top-level nil (interactive)
    (with-eval-after-load 'god-mode (meq/which-key-show-top-level 'global-map)))

;;;###autoload
(defun meq/toggle-god nil (interactive)
    (with-eval-after-load 'god-mode (funcall 'meq/toggle-inner 'god-local-mode "god" (meq/fbatp god-local-mode) 'global-map)))

;;;###autoload
(defun meq/toggle-god-force nil (interactive)
    (with-eval-after-load 'god-mode (funcall 'meq/toggle-inner 'god-local-mode "god" (meq/fbatp god-local-mode) 'global-map nil t)))

;;;###autoload
(defun meq/toggle-god-hercules nil (interactive)
    (with-eval-after-load 'god-mode (funcall 'meq/toggle-inner 'god-local-mode "god" (meq/fbatp god-local-mode) 'global-map t)))

;;;###autoload
(defun meq/toggle-god-hercules-force nil (interactive)
    (with-eval-after-load 'god-mode (funcall 'meq/toggle-inner 'god-local-mode "god" (meq/fbatp god-local-mode) 'global-map t t)))

;;;###autoload
(defun meq/god-execute-with-current-bindings (&optional called-interactively) (interactive "d")
    (with-eval-after-load 'god-mode (funcall 'meq/execute-with-current-bindings-inner 'god-local-mode "god" (meq/fbatp god-local-mode) 'global-map nil called-interactively)))

;;;###autoload
(defun meq/god-hercules-execute-with-current-bindings (&optional called-interactively) (interactive "d")
    (with-eval-after-load 'god-mode (funcall 'meq/execute-with-current-bindings-inner 'god-local-mode "god" (meq/fbatp god-local-mode) 'global-map t called-interactively)))

(with-eval-after-load 'god-mode (add-to-list 'modal-modes 'god-local-mode) (add-to-list 'modal-prefixes "god"))

(defdeino+ toggles (:color blue)
    ("x" meq/toggle-xah "xah"))
(defdeino+ all-keymaps (:color blue)
    ("x" (progn (setq all-keymaps-map 'xah-fly-command-map)
    (meq/xah-show-top-level)) "xah"))

(hercules-def
    :show-funs #'meq/xah-hercules-show
    :hide-funs #'meq/xah-hercules-hide
    :toggle-funs #'meq/xah-hercules-toggle
    :keymap 'xah-fly-command-map
    ;; :transient t
)

;;;###autoload
(defun meq/xah-hercules-toggle nil (interactive) (with-eval-after-load 'xah-fly-keys))

;;;###autoload
(defun meq/xah-show-top-level nil (interactive)
    (with-eval-after-load 'xah-fly-keys (meq/which-key-show-top-level 'xah-fly-command-map)))

;;;###autoload
(defun meq/toggle-xah nil (interactive)
    (with-eval-after-load 'xah-fly-keys (funcall 'meq/toggle-inner 'xah-fly-keys "xah" (meq/fbatp xah-fly-keys) 'xah-fly-command-map)))

;;;###autoload
(defun meq/toggle-xah-force nil (interactive)
    (with-eval-after-load 'xah-fly-keys (funcall 'meq/toggle-inner 'xah-fly-keys "xah" (meq/fbatp xah-fly-keys) 'xah-fly-command-map nil t)))

;;;###autoload
(defun meq/toggle-xah-hercules nil (interactive)
    (with-eval-after-load 'xah-fly-keys (funcall 'meq/toggle-inner 'xah-fly-keys "xah" (meq/fbatp xah-fly-keys) 'xah-fly-command-map t)))

;;;###autoload
(defun meq/toggle-xah-hercules-force nil (interactive)
    (with-eval-after-load 'xah-fly-keys (funcall 'meq/toggle-inner 'xah-fly-keys "xah" (meq/fbatp xah-fly-keys) 'xah-fly-command-map t t)))

;;;###autoload
(defun meq/xah-execute-with-current-bindings (&optional called-interactively) (interactive "d")
    (with-eval-after-load 'xah-fly-keys (funcall 'meq/execute-with-current-bindings-inner 'xah-fly-keys "xah" (meq/fbatp xah-fly-keys) 'xah-fly-command-map nil called-interactively)))

;;;###autoload
(defun meq/xah-hercules-execute-with-current-bindings (&optional called-interactively) (interactive "d")
    (with-eval-after-load 'xah-fly-keys (funcall 'meq/execute-with-current-bindings-inner 'xah-fly-keys "xah" (meq/fbatp xah-fly-keys) 'xah-fly-command-map t called-interactively)))

(with-eval-after-load 'xah-fly-keys (add-to-list 'modal-modes 'xah-fly-keys) (add-to-list 'modal-prefixes "xah"))

(defdeino+ toggles (:color blue)
    ("o" meq/toggle-objed "objed"))
(defdeino+ all-keymaps (:color blue)
    ("o" (progn (setq all-keymaps-map 'objed-map)
    (meq/objed-show-top-level)) "objed"))

(hercules-def
    :show-funs #'meq/objed-hercules-show
    :hide-funs #'meq/objed-hercules-hide
    :toggle-funs #'meq/objed-hercules-toggle
    :keymap 'objed-map
    ;; :transient t
)

;;;###autoload
(defun meq/objed-hercules-toggle nil (interactive) (with-eval-after-load 'objed))

;;;###autoload
(defun meq/objed-show-top-level nil (interactive)
    (with-eval-after-load 'objed (meq/which-key-show-top-level 'objed-map)))

;;;###autoload
(defun meq/toggle-objed nil (interactive)
    (with-eval-after-load 'objed (funcall 'meq/toggle-inner 'objed-mode "objed" (meq/fbatp objed-mode) 'objed-map)))

;;;###autoload
(defun meq/toggle-objed-force nil (interactive)
    (with-eval-after-load 'objed (funcall 'meq/toggle-inner 'objed-mode "objed" (meq/fbatp objed-mode) 'objed-map nil t)))

;;;###autoload
(defun meq/toggle-objed-hercules nil (interactive)
    (with-eval-after-load 'objed (funcall 'meq/toggle-inner 'objed-mode "objed" (meq/fbatp objed-mode) 'objed-map t)))

;;;###autoload
(defun meq/toggle-objed-hercules-force nil (interactive)
    (with-eval-after-load 'objed (funcall 'meq/toggle-inner 'objed-mode "objed" (meq/fbatp objed-mode) 'objed-map t t)))

;;;###autoload
(defun meq/objed-execute-with-current-bindings (&optional called-interactively) (interactive "d")
    (with-eval-after-load 'objed (funcall 'meq/execute-with-current-bindings-inner 'objed-mode "objed" (meq/fbatp objed-mode) 'objed-map nil called-interactively)))

;;;###autoload
(defun meq/objed-hercules-execute-with-current-bindings (&optional called-interactively) (interactive "d")
    (with-eval-after-load 'objed (funcall 'meq/execute-with-current-bindings-inner 'objed-mode "objed" (meq/fbatp objed-mode) 'objed-map t called-interactively)))

(with-eval-after-load 'objed (add-to-list 'modal-modes 'objed-mode) (add-to-list 'modal-prefixes "objed"))

(defdeino+ toggles (:color blue)
    ("k" meq/toggle-kakoune "kakoune"))
(defdeino+ all-keymaps (:color blue)
    ("k" (progn (setq all-keymaps-map 'ryo-modal-mode-map)
    (meq/kakoune-show-top-level)) "kakoune"))

(hercules-def
    :show-funs #'meq/kakoune-hercules-show
    :hide-funs #'meq/kakoune-hercules-hide
    :toggle-funs #'meq/kakoune-hercules-toggle
    :keymap 'ryo-modal-mode-map
    ;; :transient t
)

;;;###autoload
(defun meq/kakoune-hercules-toggle nil (interactive) (with-eval-after-load 'kakoune))

;;;###autoload
(defun meq/kakoune-show-top-level nil (interactive)
    (with-eval-after-load 'kakoune (meq/which-key-show-top-level 'ryo-modal-mode-map)))

;;;###autoload
(defun meq/toggle-kakoune nil (interactive)
    (with-eval-after-load 'kakoune (funcall 'meq/toggle-inner 'ryo-modal-mode "kakoune" (meq/fbatp ryo-modal-mode) 'ryo-modal-mode-map)))

;;;###autoload
(defun meq/toggle-kakoune-force nil (interactive)
    (with-eval-after-load 'kakoune (funcall 'meq/toggle-inner 'ryo-modal-mode "kakoune" (meq/fbatp ryo-modal-mode) 'ryo-modal-mode-map nil t)))

;;;###autoload
(defun meq/toggle-kakoune-hercules nil (interactive)
    (with-eval-after-load 'kakoune (funcall 'meq/toggle-inner 'ryo-modal-mode "kakoune" (meq/fbatp ryo-modal-mode) 'ryo-modal-mode-map t)))

;;;###autoload
(defun meq/toggle-kakoune-hercules-force nil (interactive)
    (with-eval-after-load 'kakoune (funcall 'meq/toggle-inner 'ryo-modal-mode "kakoune" (meq/fbatp ryo-modal-mode) 'ryo-modal-mode-map t t)))

;;;###autoload
(defun meq/kakoune-execute-with-current-bindings (&optional called-interactively) (interactive "d")
    (with-eval-after-load 'kakoune (funcall 'meq/execute-with-current-bindings-inner 'ryo-modal-mode "kakoune" (meq/fbatp ryo-modal-mode) 'ryo-modal-mode-map nil called-interactively)))

;;;###autoload
(defun meq/kakoune-hercules-execute-with-current-bindings (&optional called-interactively) (interactive "d")
    (with-eval-after-load 'kakoune (funcall 'meq/execute-with-current-bindings-inner 'ryo-modal-mode "kakoune" (meq/fbatp ryo-modal-mode) 'ryo-modal-mode-map t called-interactively)))

(with-eval-after-load 'kakoune (add-to-list 'modal-modes 'ryo-modal-mode) (add-to-list 'modal-prefixes "kakoune"))

(defdeino+ toggles (:color blue)
    ("m" meq/toggle-modalka "modalka"))
(defdeino+ all-keymaps (:color blue)
    ("m" (progn (setq all-keymaps-map 'modalka-mode-map)
    (meq/modalka-show-top-level)) "modalka"))

(hercules-def
    :show-funs #'meq/modalka-hercules-show
    :hide-funs #'meq/modalka-hercules-hide
    :toggle-funs #'meq/modalka-hercules-toggle
    :keymap 'modalka-mode-map
    ;; :transient t
)

;;;###autoload
(defun meq/modalka-hercules-toggle nil (interactive) (with-eval-after-load 'modalka))

;;;###autoload
(defun meq/modalka-show-top-level nil (interactive)
    (with-eval-after-load 'modalka (meq/which-key-show-top-level 'modalka-mode-map)))

;;;###autoload
(defun meq/toggle-modalka nil (interactive)
    (with-eval-after-load 'modalka (funcall 'meq/toggle-inner 'modalka-mode "modalka" (meq/fbatp modalka-mode) 'modalka-mode-map)))

;;;###autoload
(defun meq/toggle-modalka-force nil (interactive)
    (with-eval-after-load 'modalka (funcall 'meq/toggle-inner 'modalka-mode "modalka" (meq/fbatp modalka-mode) 'modalka-mode-map nil t)))

;;;###autoload
(defun meq/toggle-modalka-hercules nil (interactive)
    (with-eval-after-load 'modalka (funcall 'meq/toggle-inner 'modalka-mode "modalka" (meq/fbatp modalka-mode) 'modalka-mode-map t)))

;;;###autoload
(defun meq/toggle-modalka-hercules-force nil (interactive)
    (with-eval-after-load 'modalka (funcall 'meq/toggle-inner 'modalka-mode "modalka" (meq/fbatp modalka-mode) 'modalka-mode-map t t)))

;;;###autoload
(defun meq/modalka-execute-with-current-bindings (&optional called-interactively) (interactive "d")
    (with-eval-after-load 'modalka (funcall 'meq/execute-with-current-bindings-inner 'modalka-mode "modalka" (meq/fbatp modalka-mode) 'modalka-mode-map nil called-interactively)))

;;;###autoload
(defun meq/modalka-hercules-execute-with-current-bindings (&optional called-interactively) (interactive "d")
    (with-eval-after-load 'modalka (funcall 'meq/execute-with-current-bindings-inner 'modalka-mode "modalka" (meq/fbatp modalka-mode) 'modalka-mode-map t called-interactively)))

(with-eval-after-load 'modalka (add-to-list 'modal-modes 'modalka-mode) (add-to-list 'modal-prefixes "modalka"))

(provide 'alamode)
;;; alamode.el ends here
