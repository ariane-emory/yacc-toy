

(setq! left-nested-zip (reduced zip2))

(defun zip lists
 "Zip a list of lists."
 (mapcar flatten (apply left-nested-zip lists)))


(princ "flat 1: ")
;; (log-all t)
(write (mapcar flatten (left-nested-zip '(1 2 3) '(a b c) '(10 20 30) '(x y z)))) (nl)


(princ "flat 2: ")
;; (log-all t)
(write (zip '(1 2 3) '(a b c) '(10 20 30) '(x y z))) (nl)
