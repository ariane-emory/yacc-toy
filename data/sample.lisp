;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;; (log-macro t)
;; (log-core  t)
;; (log-eval  t)

(write (zip '(1 2 3) '(a b c) '(7 8 9) '(x y z) '(p q r))) (nl)
(write (zip '(1 2 3) '(a b c) '(7 8 9) '(x y z))) (nl)
(write (zip '(1 2 3) '(a b c) '(7 8 9))) (nl)
(write (zip '(1 2 3) '(a b c))) (nl)
(write (zip '(1 2 3))) (nl)

(setq! x 66)
(write (list 22 44 x)) (nl)
(write #(22 44 x)) (nl)
