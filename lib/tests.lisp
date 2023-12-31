;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(nl)
(confirm that (feature? 'std)                  returns t)
(setq!   lst  (unionql '(1 2 3) '(4 5 6)))
(confirm that lst                              returns '(6 5 4 3 2 1))
(confirm that (memql?   3 lst)                 returns t)
(confirm that (removeql 4 lst)                 returns '(6 5 3 2 1))
(confirm that (indexql  5 lst)                 returns 1)
(confirm that (mapcar! double lst)             returns '(12 10 8 6 4 2))
(confirm that (butlast '(1 2 3 4 5))           returns '(1 2 3 4))
(confirm that (reverse '(1 2 3 4 5))           returns '(5 4 3 2 1))
(confirm that (reverse (butlast '(1 2 3 4 5))) returns '(4 3 2 1))
(confirm that (unionql '(1 2 3) '(4 5 6))      returns '(6 5 4 3 2 1))

(setq!   lst (make-list 6 200))
(confirm that lst                              returns '(200 200 200 200 200 200))
(confirm that (list-set! lst 0 100)            returns 100)
(confirm that (list-ref  lst 0)                returns 100)
(confirm that lst                              returns '(100 200 200 200 200 200))
(confirm that (list-set! lst 1 101)            returns 101)
(confirm that (list-ref lst 1)                 returns 101)
(confirm that lst                              returns '(100 101 200 200 200 200))
(confirm that (list-set! lst 2 102)            returns 102)
(confirm that (list-ref lst 2)                 returns 102)
(confirm that lst                              returns '(100 101 102 200 200 200))
(confirm that (list-set! lst 3 103)            returns 103)
(confirm that (list-ref lst 3)                 returns 103)
(confirm that lst                              returns '(100 101 102 103 200 200))
(confirm that (list-set! lst 4 104)            returns 104)
(confirm that (list-ref lst 4)                 returns 104)
(confirm that lst                              returns '(100 101 102 103 104 200))
(confirm that (list-set! lst 5 105)            returns 105)
(confirm that (list-ref lst 5)                 returns 105)
(confirm that lst                              returns '(100 101 102 103 104 105))

(defun lshift4 (n) (<< n 4))
(add-logging-to lshift4)
(confirm that (lshift4 4) returns 64)

(unless *microbench-defuns*
 "For some reason, this test fails if *microbench-defuns* is set to t. Investigate."
 (confirm that (body lshift4)
  returns
  '(progn
    (princ "Applying " 'lshift4 " to parameters " (syms (env)) " with arguments " (vals (env)) ".") 
    (nl)
    (let ((result (progn (<< n 4))))
     (princ "Result of applying " 'lshift4 " was " result ".") (nl)
     result))))

(setq! lst $(2 4 1 5 3 7 9 6 8))
(confirm that (progn (select-and-move-to-front! (lambda (o) (eql? o 9)) lst) lst) returns '(9 2 4 1 5 3 7 6 8))
(confirm that (progn (select-and-move-to-front! (lambda (o) (eql? o 8)) lst) lst) returns '(8 9 2 4 1 5 3 7 6))
(confirm that (progn (select-and-move-to-front! (lambda (o) (eql? o 7)) lst) lst) returns '(7 8 9 2 4 1 5 3 6))
(confirm that (progn (select-and-move-to-front! (lambda (o) (eql? o 6)) lst) lst) returns '(6 7 8 9 2 4 1 5 3))
(confirm that (progn (select-and-move-to-front! (lambda (o) (eql? o 5)) lst) lst) returns '(5 6 7 8 9 2 4 1 3))
(confirm that (progn (select-and-move-to-front! (lambda (o) (eql? o 4)) lst) lst) returns '(4 5 6 7 8 9 2 1 3))
(confirm that (progn (select-and-move-to-front! (lambda (o) (eql? o 3)) lst) lst) returns '(3 4 5 6 7 8 9 2 1))
(confirm that (progn (select-and-move-to-front! (lambda (o) (eql? o 2)) lst) lst) returns '(2 3 4 5 6 7 8 9 1))
(confirm that (progn (select-and-move-to-front! (lambda (o) (eql? o 1)) lst) lst) returns '(1 2 3 4 5 6 7 8 9))

(confirm that (nthcdr 0 lst) returns '(1 2 3 4 5 6 7 8 9))
(confirm that (nthcdr 1 lst) returns '(2 3 4 5 6 7 8 9))
(confirm that (nthcdr 2 lst) returns '(3 4 5 6 7 8 9))
(setq! c (curry1 nthcdr 3))
(confirm that (c lst) returns '(4 5 6 7 8 9))
(confirm that (pop! lst)     returns 1)
(confirm that lst            returns '(2 3 4 5 6 7 8 9))
(confirm that (push! 99 lst) returns '(99 2 3 4 5 6 7 8 9))
(setq! lst '("asdw" "erer" "rerw" 1 nil (lambda (x) x) zoop z (1 2 . 3) 8))
(setq! split (split-list string? lst))
(ignore
 "This test cannot work until handling of strings containing escaped double quotes is fixed,"
 "and so for now we will ignore it."
 (confirm that (apply concat (intercalate " " (car split))) returns "\"asdw erer rerw\""))
(confirm that (cadr split) returns '(1 nil (lambda (x) x) zoop z (1 2 . 3) 8))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(ignore
 "Defun with support for stashing docstrings in a property. No tests written for this one yet."
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
(confirm that (bin-list-to-int  '(1 0 1 0 1 0 1))  returns 85)
(confirm that (bin-list-to-int*   1 0 1 0 1 0 1)   returns 85)

(confirm that (reduce  + '()          )            returns nil)
(confirm that (reduce  + '(1)         )            returns 1)
(confirm that (reduce  + '(1 2)       )            returns 3)
(confirm that (reduce  + '(1 2 3)     )            returns 6)
(confirm that (reduce  + '(1 2 3 4)   )            returns 10)
(confirm that (reduce  + '()         0)            returns 0)
(confirm that (reduce  + '(1)        0)            returns 1)
(confirm that (reduce  + '(1 2)      0)            returns 3)
(confirm that (reduce  + '(1 2 3)    0)            returns 6)
(confirm that (reduce  + '(1 2 3 4)  0)            returns 10)
(confirm that (rreduce + '()          )            returns nil)
(confirm that (rreduce + '(1)         )            returns 1)
(confirm that (rreduce + '(1 2)       )            returns 3)
(confirm that (rreduce + '(1 2 3)     )            returns 6)
(confirm that (rreduce + '(1 2 3 4)   )            returns 10)
(confirm that (rreduce + '()         0)            returns 0)
(confirm that (rreduce + '(1)        0)            returns 1)
(confirm that (rreduce + '(1 2)      0)            returns 3)
(confirm that (rreduce + '(1 2 3)    0)            returns 6)
(confirm that (rreduce + '(1 2 3 4)  0)            returns 10)

(confirm that (zip '(a b c) '(1 2 3))              returns '((a 1) (b 2) (c 3)))
(confirm that (zip '(a b c) '(1 2 3) '(x y z))     returns '((a 1 x) (b 2 y) (c 3 z)))

(setq!   lst                                               '(7 5 4 6 3 9 1 6 2 8 6))
(confirm that (sort!! lst <)                       returns '(1 2 3 4 5 6 6 6 7 8 9))

(confirm that ((reduced   +  ) $(1 2 3 4))         returns 10)
(confirm that ((reduced   + 4) $(1 2 3  ))         returns 10)
(confirm that ((rreduced  +  ) $(1 2 3 4))         returns 10)
(confirm that ((rreduced  + 4) $(1 2 3  ))         returns 10)
(confirm that ((reduced   +  ) '(1 2 3 4))         returns 10)
(confirm that ((reduced   + 4) '(1 2 3  ))         returns 10)
(confirm that ((rreduced  +  ) '(1 2 3 4))         returns 10)
(confirm that ((rreduced  + 4) '(1 2 3  ))         returns 10)
(confirm that ((reduced*  +  )   1 2 3 4 )         returns 10)
(confirm that ((reduced*  + 4)   1 2 3   )         returns 10)
(confirm that ((rreduced* +  )   1 2 3 4 )         returns 10)
(confirm that ((rreduced* + 4)   1 2 3   )         returns 10)

(setq! lst '(1 nil 2 3 nil 4 nil))
(confirm that (delq! nil lst)                      returns '(1 2 3 4))
(setq! lst '(1 2 3 2 4 2 5))
(confirm that (delq! 2 lst)                        returns '(1 2 3 2 4 2 5))
(setq! lst '(1 2 3 2 4 2 5))
(confirm that (delql! 2 lst)                       returns '(1 3 4 5))
(setq! lst '(1 2 3 2 4 2 5))
(confirm that (delql! 1 lst)                       returns '(2 3 2 4 2 5))
(setq! lst '((1 2) (3 4) (5 6)))
(defun filter-evens (lst) (delq! nil (mapcar (lambda (x) (when (even? x) x)) lst)))
(confirm that (mapcan filter-evens lst) returns '(2 4 6))
(confirm that (apply concat (intercalate " " '(These  are words)))  returns "These are words")
(confirm that (apply concat (intercalate " " '(These "are" words))) returns "These are words")
(confirm that (mapconcat string '(These  are  words) " ")           returns "These are words")
(confirm that (mapconcat string '(These "are" words) " ")           returns "These are words")
(confirm that (append      '(1 2) '(3 4)    '(5 6))                 returns '(1 2 3 4 5 6))
(confirm that (append      $(1 2) '(3 4)    $(5 6))                 returns '(1 2 3 4 5 6))
(confirm that (mapcan id  '((1 2)  (3 4)     (5 6)))                returns '(1 2 3 4 5 6))
(confirm that (mapcan id  '((1 2)  (3 4) nil (5 6)))                returns '(1 2 3 4 5 6))
(confirm that (mapcan cdr '((1 2 3) (4 5 6) (7 8 9)))               returns '(2 3 5 6 8 9))
(confirm that (prime? 7)                                            returns t)
(confirm that (prime? 8)                                            returns nil)
(confirm that (primes 8)                                            returns '(2 3 5 7 11 13 17 19))
(setq! lst '(1 2 3 4))
(confirm that (mapcar! double lst)                                  returns '(2 4 6 8))
(confirm that lst                                                   returns '(2 4 6 8))
(setq!   lst  '(a 2 3 (b 4 x (y 5)) (6 nil 7)))
(confirm that (transform  integer? double lst)                      returns '(a 4 6 (b 8 x (y 10)) (12 nil 14)))
(confirm that lst                                                   returns '(a 2 3 (b 4 x (y  5)) (6  nil  7)))
(confirm that (transform! integer? double lst)                      returns '(a 4 6 (b 8 x (y 10)) (12 nil 14)))
(confirm that lst                                                   returns '(a 4 6 (b 8 x (y 10)) (12 nil 14)))
(confirm that (make-string      10 "x")                             returns "xxxxxxxxxx")
(confirm that (pad-string-right 10 "x" "hello")                     returns "helloxxxxx")
(confirm that (pad-string-left  10 "x" "hello")                     returns "xxxxxhello")
(confirm that (mapconcat id '("hello" "to" "the" "world") " ")      returns "hello to the world")
(confirm that (mapconcat id '("hello" "to" "the" "world"))          returns "hellototheworld")
(confirm that (sort!! '(1 2 3 4 5 6) (lambda (x y) (and (even? x) (not (even? y))))) returns '(6 4 2 5 3 1))
(setq!   lst  (sort!! '(1 2 3 4 5 6) (lambda (x y) (and (even? x) (not (even? y))))))
(confirm that (filter even? lst) returns '(6 4 2))
(confirm that (funcall + 1 2 3 4 5 6) returns 21)
(confirm that (apply concat (mapcar* (curry1 ljust 20) "hello" "to" "the" "world"))
 returns "hello               to                  the                 world               ")
(confirm that (prog1 1 2 3) returns 1)
(confirm that (prog2 1 2 3) returns 2)

(confirm that (setq! pl '(a 10 b 20 c 30 d 40 e 50))   returns '(a 10 b 20 c 30 d 40  e 50))

(confirm that (plist-set  'a pl 1)                     returns '(a 1  b 20 c 30 d 40  e 50))
(confirm that pl                                       returns '(a 10 b 20 c 30 d 40  e 50))
(confirm that (plist-set! 'a pl 1)                     returns '(a 1  b 20 c 30 d 40  e 50))

(confirm that (plist-set  'b pl 2)                     returns '(a 1  b 2  c 30 d 40  e 50))
(confirm that pl                                       returns '(a 1  b 20 c 30 d 40  e 50))
(confirm that (plist-set! 'b pl 2)                     returns '(a 1  b 2  c 30 d 40  e 50))

(confirm that (plist-set  'c pl 3)                     returns '(a 1  b 2  c 3  d 40  e 50))
(confirm that pl                                       returns '(a 1  b 2  c 30 d 40  e 50))
(confirm that (plist-set! 'c pl 3)                     returns '(a 1  b 2  c 3  d 40  e 50))

(confirm that (plist-set  'd pl nil)                   returns '(a 1  b 2  c 3  d nil e 50))
(confirm that pl                                       returns '(a 1  b 2  c 3  d 40  e 50))
(confirm that (plist-set! 'd pl nil)                   returns '(a 1  b 2  c 3  d nil e 50))

(confirm that (plist-set  'e pl 5)                     returns '(a 1  b 2  c 3  d nil e 5 ))
(confirm that pl                                       returns '(a 1  b 2  c 3  d nil e 50))
(confirm that (plist-set! 'e pl 5)                     returns '(a 1  b 2  c 3  d nil e 5 ))

(confirm that pl                                       returns '(a 1  b 2  c 3  d nil e 5))

(confirm that (plist-get 'a pl)                        returns '1)
(confirm that (plist-get 'b pl)                        returns '2)
(confirm that (plist-get 'c pl)                        returns '3)
(confirm that (plist-get 'd pl)                        returns 'nil)
(confirm that (plist-get 'e pl)                        returns '5)
(confirm that (plist-get 'f pl)                        returns 'nil)

(confirm that (plist-has? 'a pl)                       returns 't)
(confirm that (plist-has? 'b pl)                       returns 't)
(confirm that (plist-has? 'c pl)                       returns 't)
(confirm that (plist-has? 'd pl)                       returns 't)
(confirm that (plist-has? 'e pl)                       returns 't)
(confirm that (plist-has? 'f pl)                       returns 'nil)

(confirm that (plist-keys pl)                          returns '(a b c d e))
(confirm that (plist-vals pl)                          returns '(1 2 3 nil 5))

(confirm that (plist-remove  'a pl)                    returns '(b 2 c 3 d nil e 5))
(confirm that pl                                       returns '(a 1 b 2 c 3 d nil e 5))
(confirm that (plist-remove! 'a pl)                    returns '(b 2 c 3 d nil e 5))

(confirm that (plist-remove  'd pl)                    returns '(b 2 c 3 e 5))
(confirm that (plist-remove! 'd pl)                    returns '(b 2 c 3 e 5))

(confirm that (plist-remove  'e pl)                    returns '(b 2 c 3))
(confirm that (plist-remove! 'e pl)                    returns '(b 2 c 3))

(confirm that (plist-remove  'c pl)                    returns '(b 2))
(confirm that (plist-remove! 'c pl)                    returns '(b 2))

(confirm that (plist-remove  'b pl)                    returns nil)
(confirm that (plist-remove! 'b pl)                    returns '(nil nil))

(confirm that (put 'a :foo :quux)                      returns 'a)
(confirm that (put 'b :bar :quux)                      returns 'b)
(confirm that (put 'c :baz :quux)                      returns 'c)
(confirm that (props :quux)                            returns '(:baz c :bar b :foo a))

(confirm that (props!  :quux  '(:corge d))             returns '(:corge d))
(confirm that (put 'a  :foo     :quux)                 returns 'a)
(confirm that (put 'b  :bar     :quux)                 returns 'b)
(confirm that (put 'c  :baz     :quux)                 returns 'c)

(confirm that (remove! :foo     :quux)                 returns 'a)
(confirm that (remove! :bar     :quux)                 returns 'b)
(confirm that (remove! :baz     :quux)                 returns 'c)
(confirm that (remove! :corge   :quux)                 returns 'd)

(confirm that (props   :quux)                          returns nil)

(confirm that (nconc! '(1 2 3) '(4 5 6) '(7 8 9))      returns '(1 2 3 4 5 6 7 8 9))
(confirm that (append '(1 2 3) '(4 5 6) '(7 8 9))      returns '(1 2 3 4 5 6 7 8 9))

(confirm that (memql?   3 '(1 2 3 4 5 6))              returns t)
(confirm that (memql?   9 '(1 2 3 4 5 6))              returns nil)
(confirm that (indexql  3 '(1 2 3 4 5 6))              returns 2)
(confirm that (indexql  9 '(1 2 3 4 5 6))              returns nil)
(confirm that (removeql 3 '(1 2 3 4 5 6))              returns '(1 2 4 5 6))
(confirm that (removeql 9 '(1 2 3 4 5 6))              returns '(1 2 3 4 5 6))

(confirm that (equal? '(1 . (2 . (3 . nil))) '(1 2 3)) returns t)
(confirm that (depth '(1 2 (3 4 (5)) (6 7)))           returns 3)

(confirm that (min 2 3 1 4 9 8 1 7)                    returns 1)
(confirm that (max 2 3 1 4 9 8 1 7)                    returns 9)

(confirm that (equal? '(:a (:nested list) ("containing" 6 :items)) '(:a (:nested list) ("containing" 6 :items)))
 returns t)
(confirm that (equal? '(:a (:nested list) ("containing" 6 :items)) '(:a (:nested list) ("containing" 6  items)))
 returns nil)

(confirm that (flatten  '("A" (deeply (:nested list)) (of (:many "elements"))))
 returns '("A" deeply  :nested list  of  :many "elements"))
(confirm that (flatten1 '("A" (deeply (:nested list)) (of (:many "elements"))))
 returns '("A" deeply (:nested list) of (:many "elements")))

(defun case-test-fun (n)
 (case n
  (1     (concat "O" "ne"))
  ((2 3) "Two")
  ((2)   "Three")
  (nil   "Nil 1")
  ((nil) "Nil 2")
  (else  "Other")))

(confirm that (case-test-fun 1)                  returns "One")
(confirm that (case-test-fun (+ 1 1))            returns "Two")
(confirm that (case-test-fun 4)                  returns "Other")
(confirm that (case-test-fun 'a)                 returns "Other")
(confirm that (case-test-fun nil)                returns "Nil 1")
(confirm that (round-up-to-nearest-multiple 7 8) returns  8)
(confirm that (round-up-to-nearest-multiple 9 8) returns 16)

(if *use-soft-rationals*
 (progn
  (confirm that (add-rational     3                 (rational 2 3)) returns '(11 . 3))
  (confirm that (add-rational     212               (rational 3 4)) returns '(851 . 4))
  (confirm that (add-rational     217               (rational 3 4)) returns '(871 . 4))
  (confirm that (add-rational     (rational 21 2)   (rational 3 4)) returns '(45  . 4))
  (confirm that (add-rational     (rational 21 7)   (rational 3 4)) returns '(15 . 4))
  (confirm that (sub-rational     3                 (rational 2 3)) returns '(7 . 3))
  (confirm that (sub-rational     212               (rational 3 4)) returns '(845 . 4))
  (confirm that (sub-rational     217               (rational 3 4)) returns '(865 . 4))
  (confirm that (sub-rational     (rational 21 2)   (rational 3 4)) returns '(39  . 4))
  (confirm that (sub-rational     (rational 21 7)   (rational 3 4)) returns '(9 . 4))
  (confirm that (mul-rational     3                 (rational 2 3)) returns 2)
  (confirm that (mul-rational     212               (rational 3 4)) returns 159)
  (confirm that (mul-rational     217               (rational 3 4)) returns '(651 . 4))
  (confirm that (mul-rational     (rational 21 2)   (rational 3 4)) returns '(63  . 8))
  (confirm that (mul-rational     (rational 21 7)   (rational 3 4)) returns '(9   . 4))
  (confirm that (div-rational     3                 (rational 2 3)) returns '(9  . 2))
  (confirm that (div-rational     212               (rational 3 4)) returns '(848 . 3))
  (confirm that (div-rational     217               (rational 3 4)) returns '(868 . 3))
  (confirm that (div-rational     (rational 21 2)   (rational 3 4)) returns 14)
  (confirm that (div-rational     (rational 21 7)   (rational 3 4)) returns 4))
 (progn
  (confirm that (add-rational     3                 2/3)            returns 11/3)
  (confirm that (add-rational     212               3/4)            returns 851/4)
  (confirm that (add-rational     217               3/4)            returns 871/4)
  (confirm that (add-rational     21/2              3/4)            returns 45/4)
  (confirm that (add-rational     21/7              3/4)            returns 15/4)
  (confirm that (sub-rational     3                 2/3)            returns 7/3)
  (confirm that (sub-rational     212               3/4)            returns 845/4)
  (confirm that (sub-rational     217               3/4)            returns 865/4)
  (confirm that (sub-rational     21/2              3/4)            returns 39/4)
  (confirm that (sub-rational     21/7              3/4)            returns 9/4)
  (confirm that (mul-rational     3                 2/3)            returns 2)
  (confirm that (mul-rational     212               3/4)            returns 159)
  (confirm that (mul-rational     217               3/4)            returns 651/4)
  (confirm that (mul-rational     21/2              3/4)            returns 63/8)
  (confirm that (mul-rational     21/7              3/4)            returns 9/4)
  (confirm that (div-rational     3                 2/3)            returns 9/2)
  (confirm that (div-rational     212               3/4)            returns 848/3)
  (confirm that (div-rational     217               3/4)            returns 868/3)
  (confirm that (div-rational     21/2              3/4)            returns 14)
  (confirm that (div-rational     21/7              3/4)            returns 4)))
(confirm that (round-to-nearest (approx-sqrt 14))                   returns 4)
(confirm that (round-to-nearest (approx-sqrt 16))                   returns 4)
(confirm that (round-to-nearest (approx-sqrt 25))                   returns 5)
(confirm that (round-to-nearest (approx-sqrt 36))                   returns 6)
(confirm that (round-to-nearest (approx-sqrt 49))                   returns 7)
(confirm that (round-to-nearest (approx-sqrt 60))                   returns 8)
(confirm that (round-to-nearest (approx-sqrt 64))                   returns 8)
(confirm that (round-to-nearest (rational  7 8))                    returns 1)
(confirm that (round-to-nearest (rational 14 8))                    returns 2)
(confirm that (is-square? 35)                                       returns nil)
(confirm that (is-square? 36)                                       returns t)
(confirm that (round-up-to-square 35)                               returns 36)
(confirm that (round-up-to-square 36)                               returns 36)

(setq! matrix (make-matrix 6 6 0))

(matrix-set! matrix 0 3 3)
(matrix-set! matrix 0 5 5)
(matrix-set! matrix 1 1 11)
(matrix-set! matrix 1 5 15)
(matrix-set! matrix 2 0 20)
(matrix-set! matrix 2 4 24)
(matrix-set! matrix 4 4 44)
(matrix-set! matrix 4 1 41)
(matrix-set! matrix 5 2 52)

(confirm that matrix returns
 '((0 0 0 3 0 5)
   (0 11 0 0 0 15)
   (20 0 0 0 24 0)
   (0 0 0 0 0 0)
   (0 41 0 0 44 0)
   (0 0 52 0 0 0)))

(confirm that
 (matrix-rotate-right
  '((1 2 3)
    (4 5 6)
    (7 8 9)))
 returns
 '((7 4 1)
   (8 5 2)
   (9 6 3)))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(ignore
 "Make some syntax kind of like this work:"
 (confirm that (random 10) is (and (>= 0 val) (< 10 val))))

#|

Write some tests for non-mutating plist-set.
Write some tests for bitwise operators.
Write some tests for random.
Write some tests for structs.

|#

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(nl)
(princ "All tests passed.")
(provide 'tests)
(nl)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
