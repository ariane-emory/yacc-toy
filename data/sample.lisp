(setq! lst-base '(1 a 2 b 3 4 5 6 ((7 8 (unquote 9) 10 11 12 13))))
(setq! lst lst-base)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defun xform (obj pred? if-fun else-fun)
 (cond
  ((pred? obj) (if-fun   obj))
  ((atom? obj) (else-fun obj))
  (t (cons
      (xform (car obj) pred? if-fun else-fun)
      (xform (cdr obj) pred? if-fun else-fun)))))

(write (xform lst integer? 2* id))
(nl)

(defun swap (x) 'xxx)

(write (xform lst integer? 2* swap))
(nl)

(princ "Done.")
(nl)
