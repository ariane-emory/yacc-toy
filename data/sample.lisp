;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(nl)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(setq!                   lst                                                        (unionql '(1 2 3) '(4 5 6)))
;;======================================================================================================================
(test       lst                                                        (6 5 4 3 2 1))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(test          (memql?   3 lst)                                           t)
(test        (removeql 4 lst)                                           (6 5 3 2 1))
(test         (indexql  5 lst)                                           1)
(test           (mapcar! double lst)                                       (12 10 8 6 4 2))
(test           (butlast '(1 2 3 4 5))                                     (1 2 3 4))
(test           (reverse '(1 2 3 4 5))                                     (5 4 3 2 1))
(test   (reverse (butlast '(1 2 3 4 5)))                           (4 3 2 1))
(test             (unionql '(1 2 3) '(4 5 6))                                (6 5 4 3 2 1))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(nl)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(setq!                   lst                                                        (make-list 6 200))
;;======================================================================================================================
(test         lst                                                        (200 200 200 200 200 200))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(list-set! lst 0 100)
;;======================================================================================================================
(test   lst                                                        (100 200 200 200 200 200))
(test       (list-ref lst 0)                                           100)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(list-set! lst 1 101)
;;======================================================================================================================
(test   lst                                                        (100 101 200 200 200 200))
(test       (list-ref lst 1)                                           101)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
(list-set! lst 2 102)
;;======================================================================================================================
(test   lst                                                        (100 101 102 200 200 200))
(test       (list-ref lst 2)                                           102)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
(list-set! lst 3 103)
;;======================================================================================================================
(test   lst                                                        (100 101 102 103 200 200))
(test       (list-ref lst 3)                                           103)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;                        
(list-set! lst 4 104)
;;======================================================================================================================
(test   lst                                                        (100 101 102 103 104 200))
(test       (list-ref lst 4)                                           104)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
(list-set! lst 5 105)
;;======================================================================================================================
(test   lst                                                        (100 101 102 103 104 105))
(test       (list-ref lst 5)                                           105)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(nl) 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun lshift4 (n) (<< n 4))
(add-logging-to lshift4)
;;======================================================================================================================
(test 
 (body lshift4)
 (progn
  (princ "Applying " 'lshift4 " to parameters " (syms (env)) " with arguments " (vals (env)) ".") 
  (nl)
  (let ((result (progn (<< n 4))))
   (princ "Result of applying " 'lshift4 " was " result ".") (nl)
   result)))
(test  (lshift4 4)                                                         64)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(nl)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(setq! lst $(2 4 1 5 3 7 9 6 8))
;;======================================================================================================================
(test  (progn (select-and-move-to-front! (lambda (o) (eql? o 9)) lst) lst)  (9 2 4 1 5 3 7 6 8))
(test  (progn (select-and-move-to-front! (lambda (o) (eql? o 8)) lst) lst)  (8 9 2 4 1 5 3 7 6))
(test  (progn (select-and-move-to-front! (lambda (o) (eql? o 7)) lst) lst)  (7 8 9 2 4 1 5 3 6))
(test  (progn (select-and-move-to-front! (lambda (o) (eql? o 6)) lst) lst)  (6 7 8 9 2 4 1 5 3))
(test  (progn (select-and-move-to-front! (lambda (o) (eql? o 5)) lst) lst)  (5 6 7 8 9 2 4 1 3))
(test  (progn (select-and-move-to-front! (lambda (o) (eql? o 4)) lst) lst)  (4 5 6 7 8 9 2 1 3))
(test  (progn (select-and-move-to-front! (lambda (o) (eql? o 3)) lst) lst)  (3 4 5 6 7 8 9 2 1))
(test  (progn (select-and-move-to-front! (lambda (o) (eql? o 2)) lst) lst)  (2 3 4 5 6 7 8 9 1))
(test  (progn (select-and-move-to-front! (lambda (o) (eql? o 1)) lst) lst)  (1 2 3 4 5 6 7 8 9))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(nl)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(test  (nthcdr 0 lst)                                                     (1 2 3 4 5 6 7 8 9))
(test  (nthcdr 1 lst)                                                     (2 3 4 5 6 7 8 9))
(test  (nthcdr 2 lst)                                                     (3 4 5 6 7 8 9))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(nl)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(setq!           c                                                                  (curry1 nthcdr 3))
;;======================================================================================================================
(test         (c lst)                                                            (4 5 6 7 8 9))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(nl)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(test      (pop! lst)                                                         1)
(test     (push! 99 lst)                                                     (99 2 3 4 5 6 7 8 9))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(ignore
 "This would result (deliberately) in an invalid call, so we ignore it for now."
 "It remains here only to serve as an example."
 ;; a deliberate invalid call:
 (nl) (princ "AN ERROR WILL FOLLOW: ") (nl)
 ;; (log-eval t)
 (s x 2 3))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(ignore
 "This one triggers an indentation bug, investigate:"
 (defun split-list (pred? lst)
  (let ((front nil)
        (current lst))
   (while (and current (funcall pred? (car current)))
    (setq front (cons (car current) front))
    (setq current (cdr current)))
   $((fake-reverse front) current))))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(nl)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(setq!           lst                                    '("asdw" "erer" "rerw" 1 nil (lambda (x) x) zoop z (1 2 . 3) 8))
(setq!           split (split-list string?              lst))
;;======================================================================================================================
(ignore
 "This test cannot work until handling of strings containing escaped double quotes is fixed,"
 "and so for now we will ignore it."
 (test  (apply concat (intercalate " " (car split))) "\"asdw erer rerw\""))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(test      (cadr split)                           (1 nil (lambda (x) x) zoop z (1 2 . 3) 8))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(ignore
 "No tests written for this one yet."
 (defmacro defun (name params . docs-and-body)
  (let* ((split (split-list string? docs-and-body))
         (docs  (apply concat (intercalate " " (car split))))
         (body  (cadr split)))
   $('progn 
     $('setq! name $('lambda params . body))
     $('put! docs ':doc name))))
 (defun somefun (x y)
  "Multiply two"
  "numbers."
  (* x y))
 (write (get :doc somefun)) (nl)
 (write (doc somefun))      (nl)
 (write (doc write))        (nl))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(nl)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun binlist-to-dec-1 (lst)
 (letrec
  ((chase
    (lambda (acc lst)
     (if (nil? lst)
      acc
      (chase (+ (<< acc 1) (car lst)) (cdr lst))))))
  (chase 0 lst)))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun binlist-to-dec-2 (lst) (reduce   (lambda (x y) (+ (<< x 1) y)) lst 0))
(setq! binlist-to-dec-3       (reduced  (lambda (x y) (+ (<< x 1) y))))
(setq! bins-to-dec            (reduced* (lambda (x y) (+ (<< x 1) y))))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(test       (binlist-to-dec-1 '(1 0 1 0 1 0 1))    85)
(test       (binlist-to-dec-2 '(1 0 1 0 1 0 1))    85)
(test       (binlist-to-dec-3 '(1 0 1 0 1 0 1))    85)
(test            (bins-to-dec        1 0 1 0 1 0 1)     85)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(nl)
(test  (reduce  + '())                    nil)
(test  (reduce  + '(1))                     1)
(test  (reduce  + '(1 2))                   3)
(test  (reduce  + '(1 2 3))                 6)
(test  (reduce  + '(1 2 3 4))              10)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(nl)
(test  (reduce  + '()         0)            0)
(test  (reduce  + '(1)        0)            1)
(test  (reduce  + '(1 2)      0)            3)
(test  (reduce  + '(1 2 3)    0)            6)
(test  (reduce  + '(1 2 3 4)  0)           10)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(nl)
(test  (rreduce + '())                    nil)
(test  (rreduce + '(1))                     1)
(test  (rreduce + '(1 2))                   3)
(test  (rreduce + '(1 2 3))                 6)
(test  (rreduce + '(1 2 3 4))              10)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(nl)
(test  (rreduce + '()         0)            0)
(test  (rreduce + '(1)        0)            1)
(test  (rreduce + '(1 2)      0)            3)
(test  (rreduce + '(1 2 3)    0)            6)
(test  (rreduce + '(1 2 3 4)  0)           10)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(nl)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(test  (zip '(a b c) '(1 2 3))            ((a 1) (b 2) (c 3)))
(test  (zip '(a b c) '(1 2 3) '(x y z))   ((a 1 x) (b 2 y) (c 3 z)))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(nl)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(setq mylist '(7 5 4 6 3 9 1 6 2 8 6))
(defun less-than (a b) (< a b))
;;======================================================================================================================
(test  (sort!! mylist less-than)            (1 2 3 4 5 6 6 6 7 8 9))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(setq mylist '(7 5 4 6 3 9 1 6 2 8 6))
;;======================================================================================================================
(test  (sort!! mylist <)                    (1 2 3 4 5 6 6 6 7 8 9))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(nl)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(setq! sum                                          (reduced* +))
;;======================================================================================================================
(test                           (sum  1 2 3 4) 10)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(setq! sum                                          (reduced* + 4))
;;======================================================================================================================
(test                           (sum  1 2 3) 10)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(setq! sum                                          (rreduced* +))
;;======================================================================================================================
(test                           (sum  1 2 3 4) 10)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(setq! sum                                          (rreduced* + 4))
;;======================================================================================================================
(test                           (sum  1 2 3) 10)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(setq! sum                                          (reduced  +))
;;======================================================================================================================
(test                           (sum '(1 2 3 4)) 10)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(setq! sum                                          (reduced  + 4))
;;======================================================================================================================
(test                           (sum '(1 2 3)) 10)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(setq! sum                                          (rreduced  +))
;;======================================================================================================================
(test                           (sum '(1 2 3 4)) 10)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(setq! sum                                          (rreduced  + 4))
;;======================================================================================================================
(test                           (sum '(1 2 3)) 10)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(nl)
(princ "All tests passed.")
(nl)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
