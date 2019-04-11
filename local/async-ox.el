;;; autoExport.el --- For async exports -*- lexical-binding: t; -*-

(require 'package)
(setq package-enable-at-startup nil)
(package-initialize)

(require 'org)
(require 'ox)
(require 'cl)
(setq org-export-async-debug nil)

(provide 'autoExport)
;;; autoExport.el ends here
