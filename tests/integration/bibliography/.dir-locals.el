;;; Emacs directory local variables for the project

((nil
  .
  ((eval
    .
    (setq-local my-project-root
                (expand-file-name
                 (locate-dominating-file default-directory
                                         ".envrc"))))))

 (latex-mode
  .
  ((eval
    .
    (progn
      (setq-local reftex-use-external-file-finders nil)
      (setq-local reftex-bibpath-environment-variables
                  (list
                   (format "%s//:"
                           (expand-file-name "bibliography"
                                             my-project-root))))
      (setq-local reftex-cite-format "\\SBcite{%l}")
      (reftex-reset-mode))))))

;;; End of file
