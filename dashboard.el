;;; dashboard.el --- Dashboard mode -*- lexical-binding: t -*-

(defvar figlet "
      ::::::::::  :::   :::      :::     ::::::::  ::::::::       :::::::::     :::     :::::::: :::    ::::::::::::  ::::::::     :::    ::::::::: ::::::::: 
     :+:        :+:+: :+:+:   :+: :+:  :+:    :+::+:    :+:      :+:    :+:  :+: :+:  :+:    :+::+:    :+::+:    :+::+:    :+:  :+: :+:  :+:    :+::+:    :+: 
    +:+       +:+ +:+:+ +:+ +:+   +:+ +:+       +:+             +:+    +:+ +:+   +:+ +:+       +:+    +:++:+    +:++:+    +:+ +:+   +:+ +:+    +:++:+    +:+  
   +#++:++#  +#+  +:+  +#++#++:++#++:+#+       +#++:++#++      +#+    +:++#++:++#++:+#++:++#+++#++:++#+++#++:++#+ +#+    +:++#++:++#++:+#++:++#: +#+    +:+   
  +#+       +#+       +#++#+     +#++#+              +#+      +#+    +#++#+     +#+       +#++#+    +#++#+    +#++#+    +#++#+     +#++#+    +#++#+    +#+    
 #+#       #+#       #+##+#     #+##+#    #+##+#    #+#      #+#    #+##+#     #+##+#    #+##+#    #+##+#    #+##+#    #+##+#     #+##+#    #+##+#    #+#     
#############       ######     ### ########  #########      ######## ###     ### ######## ###    ############  ######## ###     ######    ############   
")

(defun list-recent-file-button (files &rest parameters)
  "Spawn the list of recently opened files and make them clickable"
  (let ((file-idx 1)
        (offset (or (plist-get parameters :offset) 0)))
    (dolist (file files)
      (let ((current-file file))
        (insert (make-string offset ?\s))
        (insert "* ")
        (insert-button
         (format "[%s] %s" (string-pad (format "%d" file-idx) 2 ?\s t) file)
         'action #'(lambda (_btn) (find-file current-file)))
        (insert "\n")
        (setq file-idx (1+ file-idx))))))

(defun print-list-italic-with-padding (list padding dot)
  (dolist (element list)
    (insert (string-pad "" padding ?\s t))
    (insert (propertize (format "%s %s\n" dot element) 'face 'italic))))

(defun refresh-dashboard-buffer ()
  (interactive)
  (let ((inhibit-read-only t)
        (pos (point)))
    (generate-dashboard-buffer)
    (goto-char pos)))

(defun print-list-bookmark (&rest parameters)
  (let ((file-idx 1)
        (offset (or (plist-get parameters :offset) 0))
        (bookmarks bookmark-alist))
    (dolist (bookmark bookmarks)
      (let ((bookname (car bookmark))
            (filename (alist-get 'filename bookmark)))

        (message (format"bookname %s" bookname))
        (message (format"filename %s" filename))

        (insert (make-string offset ?\s))
        (insert "* ")
        (insert-button
         (format "[%s] %s" (string-pad (format "%d" file-idx) 2 ?\s t) bookname)
         'action #'(lambda (_btn) (find-file filename)))
        (insert "\n")
        (setq file-idx (1+ file-idx))))))

(defun generate-dashboard-buffer ()
  (interactive)
  (with-current-buffer (get-buffer-create "*dashboard*")
    (let ((inhibit-read-only t))
      (erase-buffer)
      (insert (make-string 4 ?\n))
      (insert (propertize figlet 'face 'bold))
      (insert "\n\n")

      (insert (propertize "# AUJOURD'HUI\n-------------\n" 'face 'bold))
      (insert (format "%s\n" (format-time-string "%A %d %B %Y%n%R %z (%Z)%nsemaine %U")))
      (insert "\n")
      
      (insert (propertize "# PROPRIÉTÉS\n------------\n" 'face 'bold))
      (insert (format "Utilisateur : %s\n" (string-pad (format " %s" (user-login-name)) 10 ?. t)))
      (insert (format "Machine     : %s\n" (string-pad (format " %s" (system-name)) 10 ?. t)))
      (insert "\n")
      
      ;; RECENT FILES
      (when (not (null recentf-list))
        (insert (propertize "# FICHIERS RÉCENTS\n------------------\n" 'face 'bold))
        (list-recent-file-button recentf-list
                                 :offset 4))
      ;; KNOWN PROJECTILE PROJECTS
      (when (not (null projectile-known-projects))
        (insert "\n")
        (insert (propertize "# PROJETS PROJECTILE\n--------------------\n" 'face 'bold))
        (list-recent-file-button projectile-known-projects
                                 :offset 4))

      (when (not (null bookmark-alist))
        (insert "\n")
        (insert (propertize "# MARQUE-PAGES\n--------------\n" 'face 'bold))
        (print-list-bookmark :offset 4))
      
      ;; HELP
      (insert (propertize "\n# AIDE\n------\n" 'face 'bold))
      (print-list-italic-with-padding '("g : rafraîchir"
                                        "q : quitter")
                                      4 "*")
      ;; REFRESH BUTTON
      (insert "\n")
      (insert-button "[ RAFRAÎCHIR ]" 'action #'(lambda (_btn) (refresh-dashboard-buffer)))
      (insert "\n")
      
      ;; Center all lines and then align on left
      (indent-rigidly (point-min) (point-max) 30)
      
      ;; Go to the first element in the first list
      (goto-char (point-min))
      (re-search-forward "\\s-*\\* "))))

(defun dashboard-check-back-indent-condition ()
  (interactive)
  (if (re-search-forward "\\s-*\\* " (line-end-position) t)
    (goto-char (match-end 0))
    (when (looking-at-p "\\s-+[a-zA-Z]")
      (back-to-indentation)
      (when (looking-at-p "\\*")
        (forward-char 2)))))

(defun is-on-header ()
  (interactive)
  (if (string-match "^\\s-*# [a-zA-Z ]+" (buffer-substring (line-beginning-position) (line-end-position)))
      (message "on")
    (message "off")))

(defun dashboard-next-line ()
  (interactive)
  "Move to the next line and go back to indentation if in left padding"
  (next-line 1)
  (dashboard-check-back-indent-condition))

(defun dashboard-previous-line ()
  (interactive)
  "Move to the previous line and go back to indentation if in left padding"
  (previous-line 1)
  (dashboard-check-back-indent-condition))

(defun dashboard-goto-next-header ()
  (interactive)
  (when (is-on-header)
    (forward-line 1))
  (when (re-search-forward "^\\s-*# " nil t)
    (goto-char (match-end 0))))

(defun dashboard-goto-previous-header ()
  (interactive)
  (when (is-on-header)
    (previous-line 1))
  (when (re-search-backward "^\\s-*# " nil t)
    (goto-char (match-end 0))))

(defun dashboard-quit ()
  (interactive)
  "Delete the window and the dashboard buffer"
  (quit-window t))

(defvar dashboard-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map (kbd "g") #'refresh-dashboard-buffer)
    (define-key map (kbd "n") #'dashboard-next-line)
    (define-key map (kbd "p") #'dashboard-previous-line)
    (define-key map (kbd "N") #'dashboard-goto-next-header)
    (define-key map (kbd "P") #'dashboard-goto-previous-header)
    (define-key map (kbd "<down>") #'dashboard-next-line)
    (define-key map (kbd "<up>") #'dashboard-previous-line)
    (define-key map (kbd "q") #'dashboard-quit)
    (define-key map (kbd "x") #'outline-cycle)
    map))
  
(define-derived-mode dashboard-mode special-mode "Dashboard"
  "Major mode for Dashboard"
  :keymap dashboard-mode-map
  (setq-local outline-regexp "^\\s-*# [a-zA-Z]")
  (outline-minor-mode 1))

(defun open-dashboard ()
  (interactive)
  (generate-dashboard-buffer)
  (with-current-buffer "*dashboard*"
    (dashboard-mode))
  (get-buffer "*dashboard*"))

(provide 'dashboard)
;;; dashboard.el ends here
