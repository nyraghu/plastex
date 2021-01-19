(TeX-add-style-hook
 "main"
 (lambda ()
   (TeX-add-to-alist 'LaTeX-provided-package-options
                     '(("basicnotes" "prefix=BN") ("biblatex" "bibencoding=utf8" "style=simplebibliography")))
   (TeX-run-style-hooks
    "latex2e"
    "article"
    "art10"
    "basicnotes"
    "biblatex")
   (LaTeX-add-labels
    "sec:hello-world"
    "sec:hello-universe")
   (LaTeX-add-bibliographies))
 :latex)

