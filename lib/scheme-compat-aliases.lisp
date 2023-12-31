(require 'misc-predicates)
(require 'misc-list-funs)
(require 'map)
(require 'list-index)
(require 'list-remove)
(require 'vector-list)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; tiny-clos scheme compat aliases:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(setq! #f            nil)
(setq! #t            t)
(setq! ???           'unspecified-result)
(setq! assoc         ahas?) 
(setq! assq          aget) 
(setq! collect-if    filter)
(setq! define        setq!)
(setq! display       write)
(setq! every         all?)
(setq! getl          pget)
(setq! gsort         sort!!)
(setq! make-vector   make-list)
(setq! map           mapcar)
(setq! map-append    mapcan)
(setq! position-of   indexq)
(setq! remove        removeq)
(setq! set!          setq!) ;should should be a macro that avoids re-defining what-scheme-implementation
(setq! vector-length list-length)
(setq! vector-ref    list-ref)
(setq! vector-set!   list-set!)
(setq! null?         nil?)  
(setq! pair?         cons?) 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(provide 'scheme-compat-aliases)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

