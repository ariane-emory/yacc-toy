;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; list funs (deprecated map variants):                                                 ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(defun mapcar-r (fun lst)
 "Map fun over LST, returning the resulting list."
 (unless (fun? fun)   (error "FUN must be a function"))
 (unless (list? lst)  (error "LST must be a list"))
 (when lst
  (cons (fun (car lst)) (mapcar-r fun (cdr lst)))))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defun mapcar-r! (fun lst)
  "Map fun over LST, altering the list."
  (unless (fun? fun)   (error "FUN must be a function"))
  (unless (list? lst)  (error "LST must be a list"))
  (letrec
   ((mapcar-internal!
     (lambda (fun lst)
      (when lst
       (rplaca! lst (fun (car lst)))
       (mapcar-r! fun (cdr lst))))))
   (mapcar-internal! fun lst)
   lst))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defun mapconcat-reduced (fun lst . rest)
  "Map fun over LST, returning the result of concatenating the resulting
   strings."
  (unless (fun? fun)     (error "FUN must be a function"))
  (unless (list? lst)    (error "LST must be a list"))
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
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defun mapcan-r (fun lst)
  "Map fun over LST and concatenate the results by altering them."
  (unless (fun? fun)   (error "FUN must be a function"))
  (unless (list? lst)  (error "LST must be a list"))
  (when lst
   (let ((result (fun (car lst)))
         (rest   (mapcan-r fun (cdr lst))))
    (if result
     (nconc! result rest)
     rest))))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; list funs (deprecated append/nconc variants):                                         ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (setq! append2
  (lambda (lst1 lst2)
   "Append LST1 and LST2."
   (unless (list? lst1) (error "LST1 must be a list"))
   (unless (list? lst2) (error "LST2 must be a list"))
   (if (nil? lst1)
    lst2
    (cons (car lst1) (append2 (cdr lst1) lst2)))))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(setq! nconc! (reduced* nconc2!))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(setq! append (reduced* append2))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; list funs (deprecated reverse):                                                       ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 (defun reverse (lst)
  "Returns a new list that is the reverse of the input list."
  (unless (list? lst) (error "LST must be a list"))
  (letrec
   ((reverse-internal
     (lambda (lst acc)
      (if (nil? lst)
       acc
       (reverse-internal (cdr lst) (cons (car lst) acc))))))
   (reverse-internal lst nil)))
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


(provide 'deprecated)
