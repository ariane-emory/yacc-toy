;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; 'standard library', such as it is:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; std config:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(setq! *use-safe-provide*      nil)
(setq! *microbench*            t)
(setq! *microbench-defmacros*  t)
(setq! *microbench-defuns*     t)
(setq! *microbench-provides*   t)
(setq! *log-std-load*          t)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; simpler-version of std load time measuerement:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(setq! *before-std* (now-us))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; crucial macros, without which nothing else in std will even work:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(setq! defmacro
 (macro (name params . body)
  (unless (eq? :SYMBOL (type name))
   (error "NAME must be a symbol"))
  (unless (or (eq? :CONS (type params)) (eq? :SYMBOL (type params)))
   (error "PARAMS must be a list or symbol"))
  (unless (eq? :CONS (type body))
   (error "BODY must be a cons"))
  $('setq! name $('macro params . body))))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defmacro defun (name params . body)
 (unless (eq? :SYMBOL (type name))
  (error "NAME must be a symbol"))
 (unless (or (eq? :CONS (type params)) (eq? :SYMBOL (type params)))
  (error "PARAMS must be a list or symbol"))
 (unless (eq? :CONS (type body))
  (error "BODY must be a cons"))
 $('setq! name $('lambda params . body)))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; feature? and provide:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(let
 ((feature-memq?
   (if (bound? 'memq?)
    memq?
    (lambda (elem lst)
     (let ((found nil))
      (while (and lst (not found))
       (if (eq? elem (car lst))
        (setq! found t)
        (setq! lst (cdr lst))))
      found)))))
 (defun feature? (feature)
  "t if FEATURE is present in *features*."
  (unless (and (eq? :SYMBOL (type feature)) (not (keyword? feature)))
   (error "FEATURE must be a non-keyword symbol"))
  (feature-memq? feature *features*)))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun safe-provide (feature)
 "Add FEATURE to *features* if it is not already present."
 (unless (and (eq? :SYMBOL (type feature)) (not (keyword? feature)))
  (error "FEATURE must be a non-keyword symbol"))
 (unless (feature? feature) (push! feature *features*))
 feature)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun provide! (feature)
 "Add FEATURE to *features*."
 (push! feature *features*))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(setq! provide (if *use-safe-provide* safe-provide provide!))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; microbenchmark:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(when (and *microbench* *microbench-defmacros*)
 (setq! defmacro-base defmacro)
 (setq! defmacro
  (macro (name params . body)
   $('progn
     $('setq! '*microbench-before* $('now-us))
     $('let $($('microbenced-macro's-result $('defmacro-base name params . body)))
       $('nl)
       $('princ "defmacrod  " $('quote name) " in "
         $('elapsed-us '*microbench-before*) " us.")
       $('setq! name name) ;; re-assign to fix :last-bound-to
       'microbenced-macro's-result)))))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(when (and *microbench* *microbench-defuns*)
 (setq! defun-base defun)
 (defmacro defun (name params . body)
  $('progn
    $('setq! '*microbench-before* $('now-us))
    $('let $($('microbenched-fun's-result $('defun-base name params . body)))
      $('nl)
      $('princ "defunned   " $('quote name) " in "
        $('elapsed-us '*microbench-before*) " us.")
      $('setq! name name) ;; re-assign to fix :last-bound-to
      'microbenched-fun's-result))))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(when (and *microbench* *microbench-provides*)
 (setq! provide-base provide)
 (defun provide (feature)
  (setq! *microbench-before* (now-us))
  (let ((result (provide-base feature)))
   (nl)
   (princ "provide    '" feature " in " (elapsed-us *microbench-before*) " us."))))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; already defined above:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(provide 'features)
(provide 'microbench)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; type predicates:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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
(defun improper? (o)     (and (list? o) (not (proper?   o))))
(defun fun?      (o)     (or  (core? o) (lambda? o) (macro? o)))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun zero?     (n)   (= n 0))
(defun one?      (n)   (= n 1))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(setq! list? tail?)
(setq! pair? cons?) ;; scheme compatability
(setq! null? nil?)  ;; scheme compatability
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(when *log-std-load*
 (log-eval t)
 (log-core t))

(when *std-modules*
 (let ((module
        (list
         'basic-funs
         'core-aliases
         'compound-cars-and-cdrs
         'append-and-nconc
         'quasiquote
         'list-access-funs
         'tail-chaser-macros
         'reduce
         'map
         'zip
         'push-pop-funs
         'flatten
         'transform
         'merge-sort
         'list-member
         'list-index
         'list-remove
         'union
         'misc-list-funs
         'misc-predicates
         'log-toggle
         'print-macros
         'benchmark
         'unsorted-funs
         'vector-list
         'split-list
         'delq
         'prime-funs
         'selection-sort
         'doc
         'test-macros
         'string-funs
         'prog-macros
         'plist-funs
         'remove-prop-macro
         'scheme-compat-aliases
         'elisp-compat-aliases
         'std-aliases
         )))
  (while module
   (require (car module))
   (setq! module (cdr module)))))


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(provide 'std)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(nl)
(princ "Loaded in   ")
(princ (elapsed-us *before-std*))
(princ " us.")
(nl)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
