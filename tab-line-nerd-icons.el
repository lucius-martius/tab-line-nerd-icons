;;; tab-line-nerd-icons.el --- Add icons to tab-line tabs -*- lexical-binding: t -*-

;; Copyright (C) 2024 Lucius Martius


;; Author: Lucius Martius <lucius-martius@dorsai.eu>
;; Keywords: lisp
;; Version: 0.1
;; Package-Requires: ((emacs "27.1") (nerd-icons "0.0.1"))
;; URL: https://github.com/lucius_martius/tab-line-nerd-icons

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program. If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; This package uses the nerd-icons package to apply appropriate icons to tab-line tabs.

;; The minor mode `tab-line-nerd-icons-global-mode' adds an :around advice to the default
;; function `tab-line-tab-name-format-default' for tab-name-formatting.
;; If you use a custom function for tab-name generation, you need to add the advice manually.

;; This should work in GUI mode and terminal, as long as `nerd-icons' is properly installed.

;;; Code:

(require 'nerd-icons)
(require 'tab-line)

(defcustom tab-line-nerd-icons-space-width 0.4
  "Adjusts the width of the space between the icon and tab-name."
  :group 'tab-line-nerd-icons
  :type 'float)

(defcustom tab-line-nerd-icons-base-icon-height 0.85
  "Adjusts the height of the tab icons."
  :group 'tab-line-nerd-icons
  :type 'float)

(defun tab-line-nerd-icons-add-icon-advice (orig-fn tab &rest args)
  "Add an icon based on the TAB's buffer to the result of ORIG-FN."
  (if-let* ((base-str (apply orig-fn tab args))
            (buffer-p (bufferp tab))
            (icon (with-current-buffer tab (nerd-icons-icon-for-buffer)))
            (icon (when (stringp icon) (concat icon " ")))
            (base-props (text-properties-at 0 base-str))
            (icon-face `(,(get-text-property 0 'face icon)
                         (:height ,tab-line-nerd-icons-base-icon-height
                          :inherit ,(plist-get base-props 'face))))
            (icon-raise (+ (plist-get (get-text-property 0 'display icon) 'raise) 0.15)))
      (concat (propertize (apply 'propertize icon base-props)
                          'face icon-face
                          'display `((space-width ,tab-line-nerd-icons-space-width)
                                     (raise ,icon-raise)))
              base-str)
    base-str))

;;;###autoload
(define-minor-mode tab-line-nerd-icons-global-mode
  "Add an icon to the label for tab-line tabs."
  :global t
  :group 'tab-line-nerd-icons
  :init-value nil
  (if tab-line-nerd-icons-global-mode
      (advice-add #'tab-line-tab-name-format-default :around
                  #'tab-line-nerd-icons-add-icon-advice)
    (advice-remove #'tab-line-tab-name-format-default
                   #'tab-line-nerd-icons-add-icon-advice)))

(provide 'tab-line-nerd-icons)

;;; tab-line-nerd-icons.el ends here
