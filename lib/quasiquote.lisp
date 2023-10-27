(require 'std-minimal)
(require 'append)

(report-time-us "def quasiquoted                "
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; quasiquotation:                                                                      ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (setq! append2
  (lambda (lst1 lst2)
   "Append two LST1 and LST2."
   (unless (list? lst1) (error "LST1 must be a list"))
   (unless (list? lst2) (error "LST2 must be a list"))
   (if (nil? lst1)
    lst2
    (cons (car lst1) (append2 (cdr lst1) lst2)))))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (setq! quasiquote expand-quasiquoted)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 )

(provide 'quasiquote)
