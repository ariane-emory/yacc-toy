;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defmacro quotify (x) $('quote x))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; (nl) (princ "Before.")
;; `(1 2 ,(- 5 2) (4 5))
;; (nl) (princ "After.")
;; (nl)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(setq! lists (list (list 1 2 3) (list 4 5 6) (list 7 8 9)))

;; `(cons left-nested-zip ,lists) 
;; `(mapcar flatten (cons left-nested-zip ,lists))
;; `(mapcar flatten (cons left-nested-zip ,@lists))

(log-macro t)
(log-macro nil)

(eval `(mapcar princ ',lists))


(nl)
(write (zip '(a b c) '(1 2 3)))

;; (nl)
;; (old-zip '(a b c) '(1 2 3))

(nl)
(princ "Done.")









