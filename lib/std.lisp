;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 'standard library', such as it is:                                         ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; crucial macros, without which nothing else in std will even work:          ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(setq! defmacro
 (macro (name params . body)
  (unless (eq? :SYMBOL (type name))
   (error "NAME must be a symbol"))
  (unless (or (eq? :CONS (type params)) (eq? :SYMBOL (type params)))
   (error "PARAMS must be a list or symbol"))
  (unless (eq? :CONS (type body))
   (error "BODY must be a cons"))
  $('setq! name $('macro params . body))))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defmacro defun (name params . body)
 (unless (eq? :SYMBOL (type name))
  (error "NAME must be a symbol"))
 (unless (or (eq? :CONS (type params)) (eq? :SYMBOL (type params)))
  (error "PARAMS must be a list or symbol"))
 (unless (eq? :CONS (type body))
  (error "BODY must be a cons"))
 $('setq! name $('lambda params . body)))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; time evaluation:                                                           ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defmacro time exprs
 "Return how long it takes to evaluate EXPRS in milliseconds."
 $('let $($('begin $('now)))
   (cons 'progn exprs)
   $('elapsed 'begin)))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defmacro report-time (msg . exprs)
 (unless (eq? :STRING (type msg)) (error "MSG must be a string"))
 $('progn
   $('princ msg)
   $('let $($('time-taken (cons 'time exprs)))
     $('princ '" in ")
     $('princ 'time-taken)
     $('princ '" us.")
     $('nl))))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defmacro time-us exprs
 "Return how long it takes to evaluate EXPRS in microseconds."
 $('let $($('begin $('now-us)))
   (cons 'progn exprs)
   $('elapsed-us 'begin)))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defmacro report-time-us (msg . exprs)
 (unless (eq? :STRING (type msg)) (error "MSG must be a string"))
 $('progn
   $('princ msg)
   $('let $($('time-taken (cons 'time-us exprs)))
     $('princ '" in ")
     $('princ 'time-taken)
     $('princ '" us.")
     $('nl))))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; simpler-version of std load time measuerement:                          ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(setq! before (now-us))
(setq! print-load-time-us
 (lambda ()
  (princ "Loaded in ")
  (princ (elapsed-us before))
  (princ " us.")
  (nl)))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


(report-time-us "def aliases for builtins       "
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; simple aliases:                                                           ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (setq! s       setq!)
 (setq! setcar! rplaca!)
 (setq! setcdr! rplacd!)
 (setq! ¬       not)          
 (setq! ∨       or )           
 (setq! ∧       and)
 (setq! list?   tail?)
 (setq! setcdr! rplacd!)
 (setq! setcar! rplaca!)
 (setq! λ       lambda)
 (setq! lte     <=)
 (setq! gte     >=)
 (setq! lt      <)
 (setq! gt      >)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 )


(report-time-us "def type preds                 "
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; type predicates:                                                          ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defun type?     (typ o) (eq? typ       (type           o)))
 (defun atom?     (o)     (not (type?    :CONS           o)))
 (defun char?     (o)          (type?    :CHAR           o))
 (defun cons?     (o)          (type?    :CONS           o))
 (defun core?     (o)          (type?    :CORE           o))
 (defun env?      (o)          (type?    :ENV            o))
 (defun error?    (o)          (type?    :ERROR          o))
 (defun float?    (o)          (type?    :FLOAT          o))
 (defun integer?  (o)          (type?    :INTEGER        o))
 (defun lambda?   (o)          (type?    :LAMBDA         o))
 (defun λ?        (o)          (type?    :LAMBDA         o))
 (defun macro?    (o)          (type?    :MACRO          o))
 (defun rational? (o)          (type?    :RATIONAL       o))
 (defun string?   (o)          (type?    :STRING         o))
 (defun symbol?   (o)          (type?    :SYMBOL         o))
 (defun improper? (o)     (and (tail? o) (not (proper?   o))))
 (defun fun?      (o)     (or  (core? o) (lambda? o) (macro? o)))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (setq! pair? cons?) ;; scheme compatability
 (setq! null? nil?)  ;; scheme compatability
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 )


(report-time-us "def compound car/cdrs          "
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; compound car/cdrs:                                                        ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defun caar     (lst)               (car (car lst)))
 (defun cadr     (lst)               (car (cdr lst)))
 (defun cdar     (lst)               (cdr (car lst)))
 (defun cddr     (lst)               (cdr (cdr lst)))
 (defun caaar    (lst)          (car (car (car lst))))
 (defun caadr    (lst)          (car (car (cdr lst))))
 (defun cadar    (lst)          (car (cdr (car lst))))
 (defun caddr    (lst)          (car (cdr (cdr lst))))
 (defun cdaar    (lst)          (cdr (car (car lst))))
 (defun cdadr    (lst)          (cdr (car (cdr lst))))
 (defun cddar    (lst)          (cdr (cdr (car lst))))
 (defun cdddr    (lst)          (cdr (cdr (cdr lst))))
 (defun caaaar   (lst)     (car (car (car (car lst)))))
 (defun caaadr   (lst)     (car (car (car (cdr lst)))))
 (defun caadar   (lst)     (car (car (cdr (car lst)))))
 (defun caaddr   (lst)     (car (car (cdr (cdr lst)))))
 (defun cadaar   (lst)     (car (cdr (car (car lst)))))
 (defun cadadr   (lst)     (car (cdr (car (cdr lst)))))
 (defun caddar   (lst)     (car (cdr (cdr (car lst)))))
 (defun cadddr   (lst)     (car (cdr (cdr (cdr lst)))))
 (defun cdaaar   (lst)     (cdr (car (car (car lst)))))
 (defun cdaadr   (lst)     (cdr (car (car (cdr lst)))))
 (defun cdadar   (lst)     (cdr (car (cdr (car lst)))))
 (defun cdaddr   (lst)     (cdr (car (cdr (cdr lst)))))
 (defun cddaar   (lst)     (cdr (cdr (car (car lst)))))
 (defun cddadr   (lst)     (cdr (cdr (car (cdr lst)))))
 (defun cdddar   (lst)     (cdr (cdr (cdr (car lst)))))
 (defun cddddr   (lst)     (cdr (cdr (cdr (cdr lst)))))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 )


(report-time-us "def quasiquoted                "
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; quasiquotation:                                                           ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (setq! append2
  (lambda (lst1 lst2)
   "Append two LST1 and LST2."
   (unless (tail? lst1) (error "LST1 must be a tail"))
   (unless (tail? lst2) (error "LST2 must be a tail"))
   (if (nil? lst1)
    lst2
    (cons (car lst1) (append2 (cdr lst1) lst2)))))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defmacro expand-quasiquoted (expr)
  "Expand a quasiquoted expression and resolve unquotes and"
  "unquote-splicings within."
  (cond
   ;; If it's not a cons then it's an atom that we should quote.
   ((atom? expr)
    $('quote expr))
   ;; Directly replace (unquote x) with x.
   ((eq? (car expr) 'unquote)
    (car (cdr expr)))
   ;; If the second element of the list is an unquote-splicing, we want to use
   ;; append2.
   ((and
     (cons? (cdr expr))
     (cons? (cadr expr))
     (eq?   (caadr expr) 'unquote-splicing))
    $('append2
      $('list $('expand-quasiquoted (car expr)))
      (cadadr expr)))
   ;; If the second element of the list is an unquote, use cons but without
   ;; splicing.
   ((and
     (cons? (cdr expr))
     (eq?   (cadr expr) 'unquote))
    $('cons
      $('expand-quasiquoted (car expr))
      (caddr expr)))
   ;; Error out for splicing outside of list context
   ((eq? (car expr) 'unquote-splicing)
    (error "unquote-splicing can't occur at top level"))
   ;; If the list is regular, we just recurse on both its parts
   (t $('cons
        $('expand-quasiquoted (car expr))
        $('expand-quasiquoted (cdr expr))))))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (setq! quasiquote expand-quasiquoted)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 )


(report-time-us "get numbered access            "
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; list funs (retrieving by position):                                       ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defun first    (lst)                    (car lst))
 (defun second   (lst)                   (cadr lst))
 (defun third    (lst)                  (caddr lst))
 (defun fourth   (lst)                 (cadddr lst))
 (defun fifth    (lst)            (car (cddddr lst)))
 (defun sixth    (lst)           (cadr (cddddr lst)))
 (defun seventh  (lst)          (caddr (cddddr lst)))
 (defun eighth   (lst)         (cadddr (cddddr lst)))
 (defun ninth    (lst)    (car (cddddr (cddddr lst))))
 (defun tenth    (lst)   (cadr (cddddr (cddddr lst))))
 (defun eleventh (lst)  (caddr (cddddr (cddddr lst))))
 (defun twelfth  (lst) (cadddr (cddddr (cddddr lst))))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defun zero?     (n)   (= n 0))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defun nth (index lst)
  "Get the nth item in LST."
  (unless (integer? index) (error "INDEX must be an integer"))
  (unless (tail? lst)      (error "LST must be a tail"))
  (cond
   ((zero? index) (car lst))
   (lst          (nth (- index 1) (cdr lst)))))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defun nthcdr (n lst)
  "Get the nth cdr of LST."
  (unless (integer? n) (error "N must be an integer"))
  (unless (tail? lst)  (error "LST must be a tail"))
  (if (zero? n)
   lst
   (nthcdr (1- n) (cdr lst))))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defun last (lst)
  "Get last item in a LST."
  (unless (tail? lst) (error "LST must be a tail"))
  (cond
   ((nil? (cdr lst)) lst)
   (lst              (last (cdr lst)))))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 )


(report-time-us "def tail-chaser macros         "
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; list funs (tail chaser macros):                                           ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defmacro make-chase-fun (params . cond-clauses)
  "Creates a function for recursive traversal and processing of lists.
  
  This macro is a generalized version that allows customization of 
  the parameter order through the PARAMS parameter.
  
  PARAMS:       A list of length 2 that specifies the parameter order.
                One parameter must be the symbol 'lst.
  COND-CLAUSES: The conditions to process the list."
  (unless (cons? params)        (error "PARAMS must be a list"))
  (unless (cons? cond-clauses)  (error "COND-clauses must be a list"))
  (unless (= 2 (length params)) (error "PARAMS needs length 2"))
  (let* ((lst-is-first? (eq? 'lst (first  params)))
         (user-param    (if lst-is-first? (second params) (first params)))
         (lambda-params (cons (first params) (cons (second params) 'rest))))
   (unless (or lst-is-first? (eq? 'lst (second params)))
    (error "one of the PARAMS must be the symbol 'lst"))
   `(lambda ,lambda-params
     (let ((position lst))
      (letrec
       ((chase-internal
         (lambda (,user-param lst . rest)
          (setq! position lst)
          (let ((head (car position))
                (tail (cdr position)))
           (cond ,@cond-clauses))))
        (chase
         (lambda (,user-param . rest)
          (chase-internal ,user-param (cdr position) . rest))))
       (chase-internal ,user-param position . rest))))))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 )


(report-time-us "def reduction functions        "
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; list funs (reduction):                                                    ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (letrec
  ((reduce-inner
    (lambda (fun lst)
     (cond
      ((nil? lst)        nil)
      ((nil? (cdr lst))  (car lst))
      (t                 (reduce-inner fun (cons (fun (car lst) (cadr lst)) (cddr lst))))))))
  (defun reduce (fun lst . init-val)
   "Left-reduce ('foldl' in Haskell) LST by applying FUN to successive pairs."
   (cond
    ((not (fun? fun))  (error "FUN must be a function"))
    ((not (tail? lst)) (error "LST must be a tail"))
    ((cdr init-val)    (error "INIT-VAL must be a single object"))
    ((nil? init-val)   (reduce-inner fun lst))
    (t                 (reduce-inner fun (cons (car init-val) lst))))))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (letrec
  ((rreduce-inner
    (lambda (fun lst)
     (cond
      ((nil? lst)        nil)
      ((nil? (cdr lst))  (car lst))
      (t                 (fun (car lst) (rreduce-inner fun (cdr lst))))))))
  (defun rreduce (fun lst . init-val)
   "Right-reduce ('foldr' in Haskell) LST by applying FUN to successive pairs."
   (cond
    ((not (fun? fun))  (error "FUN must be a function"))
    ((not (tail? lst)) (error "LST must be a tail"))
    ((cdr init-val)    (error "INIT-VAL must be a single object"))
    ((nil? init-val)   (rreduce-inner fun lst))
    (t                 (rreduce-inner fun (append2 lst (list (car init-val))))))))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defun reduced (fun . init-val)
  "Return a function that is a left reduction of the binary function FUN."
  (unless (fun? fun)   (error "FUN must be a function"))
  (when (cdr init-val) (error "INIT-VAL must be a single object"))
  (lambda (lst) (reduce fun lst . init-val)))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defun reduced* (fun . init-val)
  "Return a function that is a left reduction of the binary function FUN."
  "which takes loose args."
  (unless (fun? fun)   (error "FUN must be a function"))
  (when (cdr init-val) (error "INIT-VAL must be a single object"))
  (lambda args ((reduced fun . init-val) args)))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defun rreduced (fun . init-val)
  "Return a function that is a right reduction of the binary function FUN."
  (unless (fun? fun)   (error "FUN must be a function"))
  (when (cdr init-val) (error "INIT-VAL must be a single object"))
  (lambda (lst) (rreduce fun lst . init-val)))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defun rreduced* (fun . init-val)
  "Return a function that is a right reduction of the binary function FUN."
  "which takes loose args."
  (unless (fun? fun)   (error "FUN must be a function"))
  (when (cdr init-val) (error "INIT-VAL must be a single object"))
  (lambda args ((rreduced fun . init-val) args)))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 )


(report-time-us "def map variants               "
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; list funs (map variants):                                                 ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defun mapcar (fun lst)
  "Map fun over LST, returning the resulting list."
  (unless (fun? fun)   (error "FUN must be a function"))
  (unless (tail? lst)  (error "LST must be a tail"))
  (when lst
   (cons (fun (car lst)) (mapcar fun (cdr lst)))))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defun mapcar* (fun . args) (apply mapcar fun (list args)))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defun mapcar! (fun lst)
  "Map fun over LST, altering the list."
  (unless (fun? fun)   (error "FUN must be a function"))
  (unless (tail? lst)  (error "LST must be a tail"))
  (letrec
   ((mapcar-internal!
     (lambda (fun lst)
      (when lst
       (rplaca! lst (fun (car lst)))
       (mapcar! fun (cdr lst))))))
   (mapcar-internal! fun lst)
   lst))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defun mapconcat (fun lst . rest)
  "Map fun over LST, returning the result of concatenating the resulting
   strings."
  (unless (fun? fun)     (error "FUN must be a function"))
  (unless (tail? lst)    (error "LST must be a tail"))
  (unless (or (nil? rest) (single? rest))
   (error "MAPCONCAT takes exactly only one optional arguments after LST"))
  (let ((delimiter (car rest)))
   (unless (or (nil? delimiter) (string? delimiter))
    (error "DELIMITER must be a string or nil"))
   (if lst
    (reduce
     (lambda (acc item) (concat acc delimiter item))
     (mapcar fun lst))
    "")))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defun mapcan (fun lst)
  "Map fun over LST and concatenate the results by altering them."
  (unless (fun? fun)   (error "FUN must be a function"))
  (unless (tail? lst)  (error "LST must be a tail"))
  (when lst
   (let ((result (fun (car lst)))
         (rest   (mapcan fun (cdr lst))))
    (if result
     (nconc! result rest)
     rest))))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defun mapc (fun lst)
  "Apply FUN to each element of LST for side effects only and return LST."
  (unless (fun? fun)   (error "FUN must be a function"))
  (unless (tail? lst)  (error "LST must be a tail"))
  (let ((current lst))
   (while current
    (fun (car current))
    (setq! current (cdr current)))
   lst))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defun mapc* (fun . args) (apply mapc fun (list args)))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 )


(report-time-us "def append/nconc variants      "
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; list funs (append/nconc variants):                                        ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (setq! append (reduced* append2))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defun nconc2! (lst1 lst2)
  "Destructively join LST1 an LST2."
  (unless (tail? lst1) (error "LST1 must be a tail"))
  (unless (tail? lst2) (error "LST2 must be a tail"))
  (cond
   ((nil? lst1) lst2)
   (t           (rplacd! (last lst1) lst2) lst1)))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (setq! nconc! (reduced* nconc2!))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 )


(report-time-us "def push functions             "
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; list funs (push/push-back):                                               ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defun push-back (lst elem) 
  "Non-destructively push ELEM onto the tail of LST."
  (unless (tail? lst) (error "LST must be a tail"))
  (append lst (cons elem nil)))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defun push (elem lst)
  "Non-destructively pop ELEM from the head of LST."
  "The only difference from car is tha an empty LST may not be popped."
  (unless (cons? lst) (error "LST must be a tail"))
  (cons elem lst))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defun push (elem lst)
  "Non-destructively push ELEM onto the head of LST, aka cons."
  (unless (tail? lst) (error "LST must be a tail"))
  (cons elem lst))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;;  (defun push-back! (lst elem)
 ;;   "Destructively push ELEM onto the tail of LST."
 ;;   (unless (tail? lst) (error "LST must be a tail"))
 ;;   (rplacd! (last lst) (cons elem nil))
 ;;   lst)
 ;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;;  (defun push! (elem lst)
 ;;   "Destructively push ELEM onto the head of LST."
 ;;   (unless (tail? lst) (error "LST must be a tail"))
 ;;   (let ((old-car (car lst)))
 ;;    (rplaca! lst elem)
 ;;    (rplacd! lst (cons old-car (cdr lst)))
 ;;    lst))
 ;; ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;;  (defmacro push! (val list-sym)
 ;;   "Destructively push an item onto the list bound to LIST-SYM."
 ;;   (unless (symbol? list-sym) (error "LIST-SYM must be a symbol"))
 ;;   $('if $('not $('symbol? $('quote list-sym)))
 ;;     $('error "LIST-SYM must be a symbol")
 ;;     $('setq! list-sym $('cons val list-sym))))
 ;;  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; (defmacro pop! (list-sym)
 ;;  "Destructively pop an item from the list bound to LIST-SYM."
 ;;  (unless (symbol? list-sym) (error "LIST-SYM must be a symbol"))
 ;;  $('if $('not $('symbol? $('quote list-sym)))
 ;;    $('error "LIST-SYM must be a symbol")
 ;;    $('let $($('head $('car list-sym)))
 ;;      $('setq! list-sym $('cdr list-sym))
 ;;      'head)))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 )


(report-time-us "def flatten funs               "
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; list funs (flattening):                                                   ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defun flatten1 (lst)
  (unless (tail? lst) (error "LST must be a tail"))
  (cond
   ((nil? lst) nil)
   ((tail? (car lst))
    (append (car lst) (flatten1 (cdr lst))))
   (t (cons (car lst) (flatten1 (cdr lst))))))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defun flatten-left (lst)
  "Flatten a left-nested list structure LST."
  (unless (tail? lst) (error "LST must be a tail"))
  (if (cons? (car lst))i)
  (append (flatten-left (car lst)) $(cadr lst))
  lst)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defun flatten (lst)
  (unless (tail? lst) (error "LST must be a tail"))
  (when lst
   (if (cons? (car lst))
    (append (flatten (car lst)) (flatten (cdr lst)))
    (cons (car lst) (flatten (cdr lst))))))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 )


(report-time-us "def zipping funs               "
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; list funs (zipping):                                                      ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defun zip2 (lst1 lst2)
  "Zip LST1 and LST2."
  (unless (tail? lst1) (error "LST1 must be a tail"))
  (unless (tail? lst2) (error "LST2 must be a tail"))
  (cond
   ((∨ (nil? lst1) (nil? lst2)) nil)
   (t  (cons  $((car lst1) (car lst2))
        (zip2   (cdr lst1) (cdr lst2))))))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defun zip3 (l1 l2 l3)
  "Zip the three lists LST1, LST2 and LST3."
  (unless (tail? l1) (error "LST1 must be a tail"))
  (unless (tail? l2) (error "LST2 must be a tail"))
  (unless (tail? l3) (error "LST3 must be a tail"))
  (mapcar flatten1 (reduce zip2 $(l2 l3) l1)))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (setq! left-nested-zip (reduced* zip2))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defmacro zip lists
  "Zip many lists. This might not flatten properly if the zipped elements are
  themselves lists."
  (unless (tail? lists) (error "LISTS must be a tail"))
  (if (cdr lists)
   $('mapcar 'flatten (cons 'left-nested-zip lists))
   $('mapcar 'list  (car lists))))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 )


(report-time-us "def transform                  "
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; list funs (transform):                                                    ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defun transform! (pred? fun obj)
  "Destructively transform the cons tree OBJ by replacing members matching
  PRED? with the result of applying FUN to them."
  (when (not (lambda? fun)) (error "FUN must be a function"))
  (when (atom? obj)         (error "OBJ must be a list"))
  (cond
   ((pred? obj) (set! obj (fun obj)))
   ((cons? obj)
    (let ((head (car obj))
          (tail (cdr obj)))
     (cond
      ((pred? head) (rplaca! obj (fun head)))
      ((cons? head) (transform! pred? fun head)))
     (cond
      ((pred? tail) (rplacd! obj (fun tail)))
      ((cons? tail) (rplacd! obj (transform! pred? fun tail))))))
   (t obj))
  obj)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defun transform (pred? fun obj)
  "Transform OBJ by replacing members matching PRED? with the result of
  applying FUN to them or, if obj is not a cons tree, by applying FUN to
  OBJ."
  (unless (fun? pred?) (error "PRED? must be a function"))
  (unless (fun? fun?)  (error "FUN must be a function"))
  (cond
   ((and (atom? obj) (pred? obj)) (fun obj))
   ((atom? obj) obj)
   (t
    (cons
     (transform pred? fun (car obj))
     (transform pred? fun (cdr obj))))))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defun prefetch (expr)
  "Try to optimize EXPR by replacing it's symbol? members with the result of
  looking them up. This is, mysteriously, not a very effective optimization."
  (transform!
   (lambda (x) (and (symbol? x) (bound? x)))
   (lambda (x) (eval x))
   expr))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 )


(report-time-us "def sort!!                     "
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; list funs (sorting):                                                      ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (letrec
  ((half
    (lambda (lst)
     "Splits LST into two approximately equal parts."
     (let ((slow lst)
           (fast (cdr lst)))
      (while (and fast (cdr fast))
       (setq! slow (cdr slow))
       (setq! fast (cddr fast)))
      (let ((right (cdr slow)))
       (rplacd! slow nil)
       (cons lst right)))))
   (merge
    (lambda (left right pred?)
     "Merge two sorted lists, LST1 and LST2, into a single sorted list according"
     "to the binary predicate PRED?."
     (cond
      ((nil? left)  right)
      ((nil? right) left)
      ((pred? (car left) (car right))
       (cons (car left) (merge (cdr left) right pred?)))
      (t
       (cons (car right) (merge left (cdr right) pred?)))))))
  (defun sort!!  (lst pred?)
   "Just a basic merge sort of LST by PRED?, destroying LST in the process and"
   "returning a new list."
   (unless (tail? lst)  (error "LST must be a tail"))
   (unless (fun? pred?) (error "PRED? must be a function"))
   (if (or (nil? lst) (nil? (cdr lst)))
    lst
    (let* ((splits (half lst))
           (left   (car splits))
           (right  (cdr splits)))
     (merge (sort!!  left pred?)
      (sort!!  right pred?) pred?)))))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 )

(report-time-us "def misc list funs             "
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; list funs (unsorted):                                                     ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defun list* args
  (let*
   ((chase
	   (lambda (args)
		  (cond
       ((nil? args)       nil)
		   ((nil? (cdr args)) (car args))
		   (t                 (cons (car args) (chase (cdr args))))))))
   (chase args)))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defun depth (lst)
  "Get the depth of a nested list structure. This one is untested."
  (unless (tail? lst) (error "LST must be a tail"))
  (if (atom? lst)
   0
   (max 1 (+ (depth (car lst)) (depth (cdr lst))))))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defun filter (pred? lst)
  "Return a list containing those members of lst satisfying pred?."
  (unless (fun? pred?) (error "PRED? must be a function"))
  (unless (tail? lst)  (error "LST must be a tail"))
  (cond
   ((nil? lst) nil)
   ((pred? (car lst))
    (cons (car lst) (filter pred? (cdr lst))))
   (t (filter pred? (cdr lst)))))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defun intercalate (intercalated lst)
  "Intercalate intercalated between items."
  (unless (tail? lst) (error "LST must be a tail"))
  (if (or (nil? lst) (nil? (cdr lst)))
   lst
   (cons (car lst)
    (cons intercalated
     (intercalate intercalated (cdr lst))))))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defun butlast (lst)
  "Returns a new list that contains all the elements of the input list except"
  "last one."
  (unless (tail? lst) (error "LST must be a tail"))
  (if (or (nil? lst) (nil? (cdr lst)))
   nil
   (cons (car lst) (butlast (cdr lst)))))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defun reverse (lst)
  "Returns a new list that is the reverse of the input list."
  (unless (tail? lst) (error "LST must be a tail"))
  (letrec
   ((reverse-internal
     (lambda (lst acc)
      (if (nil? lst)
       acc
       (reverse-internal (cdr lst) (cons (car lst) acc))))))
   (reverse-internal lst nil)))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defun removeq! (obj lst)
  "Remove the first item eq? to OBJ from LST."
  (unless (tail? lst) (error "LST must be a tail"))
  (let ((head (car lst))
        (tail (cdr lst)))
   (if (eq? obj head)
    (if (nil? tail)
     (error "can't remove last item from LST")
     (rplaca! lst (second lst))
     (rplacd! lst (cddr   lst)))
    (let ((prev     lst)
          (current  (cdr lst)))
     (letrec
      ((chase
        (lambda (lst)
         (let ((head (car lst))
               (next (cdr lst)))
          (cond
           ((eq? obj head) (progn (rplacd! prev next) obj))
           (next            (progn (setq! prev lst) (chase next)))
           (t               (error "OBJ was not found in LST"))
           )))))
      (chase current))))))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defun removeql! (obj lst)
  "Remove the first item eql? to OBJ from LST."
  (unless (tail? lst) (error "LST must be a tail"))
  (let ((head (car lst))
        (tail (cdr lst)))
   (if (eql? obj head)
    (if (nil? tail)
     (error "can't remove last item from LST")
     (rplaca! lst (second lst))
     (rplacd! lst (cddr   lst)))
    (let ((prev     lst)
          (current  (cdr lst)))
     (letrec
      ((chase
        (lambda (lst)
         (let ((head (car lst))
               (next (cdr lst)))
          (cond
           ((eql? obj head) (progn (rplacd! prev next) obj))
           (next            (progn (setq! prev lst) (chase next)))
           (t               (error "OBJ was not found in LST"))
           )))))
      (chase current))))))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defun copy-list (lst)
  "Take shallow copy of LST."
  (unless (tail? lst) (error "LST must be a tail"))
  (when lst (cons (car lst) (copy-list (cdr lst)))))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 )


(report-time-us "def union                      "
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; list funs (unions):                                                       ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defun union2 (equalityp? lst1 lst2)
  "Return the union of LST1 and LST2, using memp? to test for duplicates."
  (unless (fun? equalityp?) (error "EQUALITYP? must be a function"))
  (unless (tail? lst1)      (error "LST1 must be a tail"))
  (unless (tail? lst2)      (error "LST2 must be a tail"))
  (let* ((memp?    (make-member-pred equalityp?))
         (combine  (lambda (acc x) (if (memp? x acc) acc (cons x acc))))
         (union1   (reduce combine lst1 '())))
   (reduce combine lst2 union1)))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (setq! union2q
  (lambda (lst1 lst2)
   "Return the union of LST1 and LST2, using eq? to test for duplicates."
   (unless (tail? lst1) (error "LST1 must be a tail"))
   (unless (tail? lst2) (error "LST2 must be a tail"))
   (union2 eq? lst1 lst2)))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (setq! unionq
  (reduced* union2q))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (setq! union2ql
  (lambda (lst1 lst2)
   "Return the union of LST1 and LST2, using eql? to test for duplicates."
   (unless (tail? lst1) (error "LST1 must be a tail"))
   (unless (tail? lst2) (error "LST2 must be a tail"))
   (union2 eql? lst1 lst2)))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (setq! unionql
  (reduced* union2ql))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 )


(report-time-us "def predicates                 "
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; equal? predicate:                                                         ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defun equal? (o1 o2)
  "True when O1 and O2 are eql? or cons trees whose atomic mebers are equal?."
  (cond
   ((and (atom? o1) (atom? o2)) (eql? o1 o2))
   ((and (cons? o1) (cons? o2))
    (and (equal? (car o1) (car o2))
     (equal? (cdr o1) (cdr o2))))
   (t nil)))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; even?/odd? predicates:                                                    ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defun even?(n)
  "t if N is even."
  (unless (integer? n) (error "N must be an integer"))
  (zero? (% n 2 )))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defun odd?(n)
  "t if N is odd."
  (unless (integer? n) (error "N must be an integer"))
  (= 1 (% n 2 )))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; always?/never? predicates:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defun always?(x) "always true." t)
 (defun never? (x) "never true."  nil)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defun single? (lst)
  "true if LST is a list with single item."
  (unless (cons? lst) (error "LST must be a cons"))
  (not (cdr lst)))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defun double? (lst)
  "true if LST is list with two items."
  (unless (cons? lst) (error "LST must be a cons"))
  (not (cddr lst)))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defun single? (lst)
  "true if LST is a list with three items."
  (unless (cons? lst) (error "LST must be a cons"))
  (not (cdddr lst)))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; manipulate predicates:                                                    ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defun compose-pred1s preds
  "Does what it says on the tin and composes unary predicatess PREDS."
  (unless (all? fun? preds) (error "PREDS must be functions"))
  (lambda (val)
   (lets
    ((fun
      (lambda (preds)
       (cond
        ((nil? (car preds))       t)
        ((not  ((car preds) val)) nil)
        (t     (fun (cdr preds)))))))
    (fun preds))))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; invert a predicate:                                                       ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defun invert-pred1 pred?
  "Does what it says on the tin and inverts a unary predicate PRED?."
  (unless (fun? pred?) (error "PRED? must be a function"))
  (lambda (val)
   (not (pred? val))))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 )


(report-time-us "def log toggles                "
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; log toggle helpers, these should be replaced with macros:                 ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defun with-toggled-fun1 (toggled-fun)
  "Get a function that enables TOGGLED-FUN, evaluates FUN-OR-EXPR and sets"
  "TOGGLED-FUN back to it's prior state."
  (unless (fun? toggled-fun) (error "TOGGLED-FUN must be a function"))
  (lambda (fun-or-expr)
   (if (lambda? fun-or-expr)
    (let* ((old    (toggled-fun t))
           (result (fun-or-expr))
           (new    (toggled-fun old)))
     result)
    (let* ((old    (toggled-fun t))
           (result (eval fun-or-expr))
           (new    (toggled-fun old)))
     result))))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defun with-toggled-fun (toggled-fun)
  "Get a function that enables TOGGLED-FUN, evaluates FUN-OR-EXPRS and sets"
  "TOGGLED-FUN back to it's prior state."
  (unless (fun? toggled-fun) (error "TOGGLED-FUN must be a function"))
  (lambda funs-or-exprs
   (last (mapcar (with-toggled-fun1 toggled-fun) funs-or-exprs))))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (setq! with-log-eval  (with-toggled-fun log-eval))
 (setq! with-log-core  (with-toggled-fun log-core))
 (setq! with-log-macro (with-toggled-fun log-macro))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 )


(report-time-us "def fancy prints               "
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; fancy output funs:                                                        ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; (defmacro princn args       $(progn (cons princ args)                $(nl)))
 ;; (defmacro printn args       $(progn (cons print args)                $(nl)))
 ;; (defmacro putn   args       $(progn (cons put   args)                $(nl)))
 ;; (defmacro writen args       $(progn (cons write args)                $(nl)))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defun princn  args       (apply princ   args) (nl))
 (defun printn  args       (apply print   args) (nl))
 (defun putn    args       (apply put     args) (nl))
 (defun writen  args       (apply write   args) (nl))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defun princni (i . args) (apply princn  (intercalate i args)))
 (defun printni (i . args) (apply printn  (intercalate i args)))
 (defun putni   (i . args) (apply putn    (intercalate i args)))
 (defun writeni (i . args) (apply writen  (intercalate i args)))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defun princns args       (apply princni (cons " " args)))
 (defun printns args       (apply printni (cons " " args)))
 (defun putns   args       (apply putni   (cons " " args)))
 (defun writens args       (apply writeni (cons " " args)))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 )


(report-time-us "def unsorted                   "
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; random unsorted stuff:                                                    ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defun apply* (fun . args)
  "Try to remember how this one works and document it."
  (unless (fun? fun) (error "FUN must be a function"))
  (apply fun (apply list* args)))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defun curry1 (fun arg1)
  "Curry the first argument of FUN as ARG1. This would be better if it were a macro."
  (unless (fun? fun) (error "FUN must be a function"))
  (lambda args
   (apply fun arg1 args)))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defun id     (o)   o)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defun spc    ()    (princ " "))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defun max(a b)
  "Return the larger of A and B."
  (unless (integer? a) (error "A must be an integer"))
  (unless (integer? b) (error "B must be an integer"))
  (if (> a b) a b))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defun min(a b)
  "Return the smaller of A and B."
  (unless (integer? a) (error "A must be an integer"))
  (unless (integer? b) (error "B must be an integer"))
  (if (< a b) a b))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defun 1+(n)
  "Return N + 1."
  (unless (integer? n) (error "N must be an integer"))
  (+ 1 n))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defun 1-(n)
  "Return N - 1."
  (unless (integer? n) (error "N must be an integer"))
  (- n 1))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defun double(n)
  "Return N * 2."
  (unless (integer? n) (error "N must be an integer"))
  (<< n 1))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (setq! 2*     double)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defmacro ignore args
  "Ignores ARGS and do nothing."
  nil)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defun benchmark (repetitions print-interval qexpr)
  "Benchmark QEXPR by running it REPETITIONS times and returning the"
  "total/average time in ms, printing updates ever PRINT-INTERVAL iterations."

  "THIS PROBABLY NEEDS AN UPDATE!"
  (unless (integer? repetitions)   (error "REPETITIONS must be an integer"))
  (unless (integer? print-interval)(error "PRINT-INTERVAL must be an integer"))
  (nl)
  (let ((ctr   0)
        (total 0))
   (repeat repetitions
    (setq! ctr (1+ ctr))
    (let ((before (time)))
     (eval qexpr)
     (setq! total (+ total (elapsed before))))
    (when (zero? (% ctr print-interval))
     (nl)
     (princ "Iteration #")
     (princ ctr)
     (princ ", ")
     (princ (÷ total 1000))
     (princ " ms so far.")))
   (nl)
   (princ "total ums: ")
   (princ total) (nl)
   (princ "total ms: ")
   (princ (÷ total 1000)) (nl)
   (princ "total s: ")
   (princ (÷ total 1000000)) (nl)
   (let ((each-ms (÷ total repetitions 1000)))
    (princ "each ms: ")
    (princ (÷ total repetitions 1000))
    (nl)
    each-ms)))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defun add-logging-to (fun)
  "Add logging to a function FUN."
  (unless (fun? fun) (error "FUN must be a function"))
  (if (has? :added-logging fun)
   (error "logging was already added to this fun")
   (let* ((fun-name      (get :last-bound-to fun))
          (old-fun-body  (body fun))
          (old-body-tail (cdr old-fun-body))
          (new-body
           `((princ
              "Applying " ',fun-name
              " to parameters "  (syms (env))
              " with arguments " (vals (env)) ".")
             (nl)
             (let ((result (progn ,@old-body-tail)))
              (princ "Result of applying " ',fun-name " was " result ".")
              (nl)
              result))))
    (rplacd! (body fun) new-body))
   (put! t :added-logging fun) (nl)
   fun))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defmacro funcall (fun . args)
  "Apply FUN to ARGS. This only exists to make porting code from other Lisps easier."
  (unless (fun? (eval fun)) (error "FUN must be a function"))
  (cons fun args))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defun root-env ()
  "Get the root environment."
  (setq! pos (env))
  (while (env pos)
   (write pos) (nl)
   (setq! pos (env pos)))
  pos) 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defmacro defconstant (sym value)
  "Set SYM to VALUE and mark it as constant."
  (unless (symbol? sym) (error "SYM must be a symbol"))
  $('progn
    $('setq! sym value)
    $('put! 't ':constant $('quote sym))
    value))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 )


(report-time-us "def list predicates            "
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; list funs (more unsorted):                                                ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defmacro defun-list-pred-fun (name combiner base-case)
  `(defun ,name (pred? lst)
    (if lst
     (,combiner
      (pred? (car lst))
      (,name pred? (cdr lst)))
     ,base-case)))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defun-list-pred-fun any? or  nil)
 (defun-list-pred-fun all? and t)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defmacro defun-list-transform-fun (name transformer)
  `(defun ,name (lsts)
    (when lsts
     (cons (,transformer (car lsts)) (,name (cdr lsts))))))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defun-list-transform-fun heads caar)
 (defun-list-transform-fun tails cdar)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 )


(report-time-us "def vector-lists               "
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; list funs (vector-style list API):                                         ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (setq! list-set!
  (make-chase-fun (lst index)
   ((zero? index) (rplaca! position (car rest)))
   (position (chase (1- index) (car rest)))
   (t (error "INDEX out of range"))))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (setq! list-ref
  (make-chase-fun (lst index)
   ((zero? index) head)
   (position (chase (1- index)))
   (t (error "INDEX out of range"))))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (setq! list-length length)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defun make-list (size init-val)
  "Make a new list of length SIZE with it's cars set to INIT-VAL."
  (unless (integer? size) (error "SIZE must be an integer"))
  (cond
   ((zero? size)  nil)
   (t            (cons init-val (make-list (1- size) init-val)))))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 )


(report-time-us "def tail chasers               "
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defmacro make-member-pred (pred?)
  `(make-chase-fun (obj lst)
    ((,pred? obj head) t)
    (position (chase obj))))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defmacro make-remove-fun (pred?)
  `(make-chase-fun (obj lst)
    ((,pred? obj head) tail)
    (position (cons head (chase obj)))))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defmacro make-index-fun (pred?)
  `(make-chase-fun (obj lst)
    ((,pred? obj head) (car rest))
    (position (chase obj (if rest (1+ (car rest)) 1)))))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (setq! indexq   (make-index-fun   eq?))
 (setq! memq?    (make-member-pred eq?))
 (setq! removeq  (make-remove-fun  eq?))
 (setq! indexql  (make-index-fun   eql?))
 (setq! memql?   (make-member-pred eql?))
 (setq! removeql (make-remove-fun  eql?))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 )


(report-time-us "def list split funs            "
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defun split-list-alternate! (pred? lst)
  "Destructively split the LST into two sublists:"
  "1. The longest initial sublist of elements satisfying PRED?"
  "2. The rest of the elements."
  (unless (fun? pred?) (error "PRED? must be a function"))
  (unless (tail? lst) (error "LST must be a tail"))
  (let ((front nil)
        (back lst))
   (while (and back (pred? (car back)))
    (push! (pop! back) front))
   $((reverse front) back)))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defun split-list (pred? lst)
  "Destructivly split LST into two sublists:"
  "1. The longest initial sublist of elements satisfying PRED?"
  "2. The rest of the elements."
  (unless (fun? pred?) (error "PRED? must be a function"))
  (unless (tail? lst) (error "LST must be a tail"))
  (let ((prev nil)
        (current lst))
   (while (and current (pred? (car current)))
    (setq! prev current)
    (setq! current (cdr current)))
   (if prev
    (progn
     (rplacd! prev nil)
     $(lst current))
    $(nil lst))))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defun split-list (pred? lst)
  "Split LST into two sublists:"
  "1. The longest initial sublist of elements satisfying PRED?"
  "2. The rest of the elements."
  (unless (fun? pred?) (error "PRED? must be a function"))
  (unless (tail? lst) (error "LST must be a tail"))
  (let ((front nil)
        (current lst))
   (while (and current (pred? (car current)))
    (setq front (cons (car current) front))
    (setq current (cdr current)))
   $((reverse front) current)))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 )


(report-time-us "def delq!/delql!               "
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defun delq! (item lst)
  "Destructively remove all items eq? to ITEM from LST."
  (unless (tail? lst) (error "LST must be a tail"))
  (when lst
   (while (and lst (eq? (car lst) item))
    (setq! lst (cdr lst)))
   (let ((ptr lst))
    (while (and ptr (cdr ptr))
     (if (eq? (cadr ptr) item)
      (rplacd! ptr (cddr ptr))
      (setq! ptr (cdr ptr)))))
   lst))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defun delql! (item lst)
  "Destructively remove all items eql? to ITEM from LST."
  (unless (tail? lst) (error "LST must be a tail"))
  (when lst
   (while (and lst (eql? (car lst) item))
    (setq! lst (cdr lst)))
   (let ((ptr lst))
    (while (and ptr (cdr ptr))
     (if (eql? (cadr ptr) item)
      (rplacd! ptr (cddr ptr))
      (setq! ptr (cdr ptr)))))
   lst))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 )

(report-time-us "def prime?/primes              "
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defun prime? (num)
  "Check if a number is prime."
  (unless (integer? num) (error "NUM must be an integer"))
  (if (or (= num 0) (= num 1))
   nil
   (let ((limit (/ num 2))
         (divisor 2)
         (is-prime t))
    (while (and (<= divisor limit) is-prime)
     (if (= (% num divisor) 0)
      (setq! is-prime nil)
      (setq! divisor (+ divisor 1))))
    is-prime)))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defun primes (n)
  "Return the first n prime numbers."
  (unless (integer? n) (error "N must be an integer"))
  (let ((count 0)
        (num 2)
        (primes '()))
   (while (< count n)
    (when (prime? num)
     (setq! count (+ count 1))
     (setq! primes (append2 primes (list num))))
    (setq! num (+ num 1)))
   primes))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 )

(report-time-us "def selection sort parts       "
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defun remove-first! (pred? lst)
  "Destructively remove the first item matching PRED? from LST."
  (unless (fun? pred?) (error "PRED? must be a function"))
  (unless (tail? lst)  (error "LST must be a tail"))
  (if (pred? (car lst))
   (if (cdr lst)
    (progn 
     (rplaca! lst (cadr lst))
     (rplacd! lst (cddr lst)))
    (error "can't remove last item"))
   (let ((prev lst) (current (cdr lst)))
    (while (and current (not (pred? (car current))))
     (setq! prev current)
     (setq! current (cdr current)))
    (if current
     (progn
      (rplacd! prev (cdr current))
      (car current))
     (error "obj was not in lst")))))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defun select-and-move-to-front! (pred? lst)
  "Move the first item in LST matching PRED? to its head."
  (unless (fun? pred? ) (error "PRED? must be a function"))
  (unless (tail? lst)  (error "LST must be a tail"))
  (let ((head (car lst)))
   (if (pred? head)
    head
    (let ((obj      (remove-first! pred? lst))
          (new-tail (cons (car lst) (cdr lst))))
     (rplaca! lst obj)
     (rplacd! lst new-tail)
     obj))))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 )


(report-time-us "def documentation funs         "
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defun doc (obj)
  "Get an object OBJ's documentation."
  (let* ((doc       (or (get :doc obj) "This object has no documentation."))
         (binding   (get :last-bound-to obj))
         (is-fun    (or (lambda? obj) (macro? obj)))
         (name      (or binding (string obj)))
         (params    (when is-fun
                     (string (cons name (params obj)))))
         (docstring (if is-fun
                     (concat params ": " doc)
                     (concat name   ": " doc))))
   docstring))
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 )


(report-time-us "def require-equal and test     "
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (ignore
  "An old version of require-equal that we are no longer using."

  "Signal an error unless VAL is equal? to TEST-VAL, otherwise return the result"
  "of evaluating EXPR."
  (defun require-equal (test-val val)
   (if (equal? test-val val)
    val
    (error "require-equal failed: " test-val " ≠ " val))))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defmacro require-equal (test-val expr)
  "Signal an error unless EXPR evaluates to TEST-VAL, otherwise return the"
  "result of evaluating EXPR."
  $('let $($('val expr))
    $('if $('equal? test-val 'val)
      'val
      $('error
        $('concat
          '"require-equal failed: "
          $('string test-val)
          '" ≠ "
          $('string 'val))))))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (setq! confirm-2nd-column 70)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defmacro confirm (that expr returns expected)
  "Test whether EXPR evaluates to EXPECTED."
  (unless (eq? 'that   that)     (error "expected 'that as 2nd argument"))
  (unless (eq? 'returns returns) (error "expected 'returns as 4th argument"))
  $('progn
    $('let $($('printed $('princ $('string $('quote expr)))))
      $('while $('< 'printed confirm-2nd-column)
        $('princ '" ")
        $('setq! 'printed $('+ 1 'printed)))
      $('princ '" ⇒ ")
      (when (cons? expected)
       $('princ "'"))
      $('write $('require-equal
                 expected
                 expr))
      $('nl))))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 )


(report-time-us "def string funs                "
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defun make-string (size init-val)
  "Make a new string of length SIZE with it's chars set to INIT-VAL."
  (unless (integer? size)         (error "SIZE must be an integer."))
  (unless (string? init-val)      (error "INIT-VAL must be a string."))
  (unless (= 1 (length init-val)) (error "INIT-VAL must be a string of length 1."))
  (apply concat (make-list size init-val)))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defun pad-string-right (size init-val str)
  "Pad STR to SIZE with INIT-VAL."
  (unless (integer? size)         (error "SIZE must be an integer."))
  (unless (string? init-val)      (error "INIT-VAL must be a string."))
  (unless (= 1 (length init-val)) (error "INIT-VAL must be a string of length 1."))
  (let ((pad (make-string (- size (length str)) init-val)))
   (concat str pad)))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defun pad-string-left (size init-val str)
  "Pad STR to SIZE with INIT-VAL."
  (unless (integer? size)         (error "SIZE must be an integer."))
  (unless (string? init-val)      (error "INIT-VAL must be a string."))
  (unless (= 1 (length init-val)) (error "INIT-VAL must be a string of length 1."))
  (let ((pad (make-string (- size (length str)) init-val)))
   (concat pad str)))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defun left-justify  (size str) (pad-string-right size " " str))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defun right-justify (size str) (pad-string-left size " " str))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 )


(report-time "def prog1/prog2                "
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defmacro prog1 (expr1 . exprs)
  "Evaluate EXPR1, then evaluate EXPRS in order, and return the value of EXPR1."
  $('let $($('result $('eval expr1)))
    $('progn . exprs)
    'result))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defmacro prog2 (expr1 expr2 . exprs)
  "Evaluate EXPR1, then evaluate EXPR2, then evaluate EXPRS in order, and return the value of EXPR2."
  $('progn
    expr1
    $('let $($('result2 $('eval expr2)))
      $('progn . exprs)
      'result2)))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 )


(report-time-us "def plist-keys/plist-values    " 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defun plist-keys (lst)
  "Extracts the keys from a plist LST."
  (unless (list? lst) (error "LST must be a list"))
  (when lst (cons (car lst) (plist-keys (cddr lst)))))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defun plist-values (lst)
  "Extracts the values from a plist LST."
  (when lst (plist-keys (cdr lst))))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 )


(report-time-us "def feature?/provide           "
 ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defun feature? (feature)
  "t if FEATURE is present in *features*."
  (unless (keyword? feature) (error "FEATURE must be a keyword."))
  (memq? feature *features*))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defun provide (feature)
  "Add FEATURE to *features* if it is not already present."
  (unless (keyword? feature)  (error "FEATURE must be a keyword."))
  (unless (feature? feature)  (push! feature *features*))
  )
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 )


(report-time-us "def scheme compat              "
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; tiny-clos scheme compat:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (setq! #f            nil)
 (setq! #t            t)
 (setq! ???           'unspecified-result)
 (setq! assoc         ahas?) 
 (setq! assq          aget) 
 (setq! collect-if    filter)
 (setq! define        setq!)
 (setq! display       write)
 (setq! else          t)
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
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 )


(report-time-us "def elisp compat               "
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; tiny-clos scheme compat:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (setq! nreverse reverse)
 (setq! put      put!)
 (setq! setq     setq!)
 (setq! rplaca   rplaca!)
 (setq! rplacd   rplacd!)
 (setq! nconc    nconc!)
 (setq! null     nil?)
 (setq! identity id)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 )


(report-time-us "def aliases for std funs   "
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; simple aliases:                                                           ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (setq! pkeys   plist-keys)
 (setq! pvals   plist-values)
 (setq! ljust   left-justify)
 (setq! rjust   right-justify)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 )


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(print-load-time-us)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(when (and (bound? 'provide) (fun? provide)) (provide :std))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;