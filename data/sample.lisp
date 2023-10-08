;; old version
(setq transform!
      (lambda (pred fun obj)
        (if (not (eq :CONS (type obj))) 
            (if (pred obj) 
                (setf obj (fun obj)))
          (let ((head (car obj))
                (tail (cdr obj)))
            (cond 
              ((nil? obj) obj)
              ((pred head)
               (rplaca obj (fun head)))
              ((eq :CONS (type head))
               (transform! pred fun head)))
            (if tail
                (rplacd obj (transform! pred fun tail)))
            (if (and (not (eq :CONS (type tail))) (pred tail))
                (rplacd obj (fun tail)))))
        obj))


(setq transform!
      (lambda (pred fun obj)
        (let ((process-cons
               (lambda (obj)
                 (let ((head (car obj))
                       (tail (cdr obj)))
                   (when (pred head)
                     (rplaca obj (fun head)))
                   (when (eq :CONS (type head))
                     (transform! pred fun head))
                   (when tail
                     (rplacd obj (transform! pred fun tail)))
                   (when (and (not (eq :CONS (type tail))) (pred tail))
                     (rplacd obj (fun tail)))))))
          (cond 
           ((and (not (eq :CONS (type obj))) (pred obj))
            (setf obj (fun obj)))
           ((eq :CONS (type obj))
            (process-cons obj)))
          obj)))



(setq transform!
  (lambda (pred fun obj)
    (cond
      ((pred obj) (setf obj (fun obj)))
      ((eq :CONS (type obj))
       (let ((head (car obj))
             (tail (cdr obj)))
         (cond
           ((pred head) (rplaca obj (fun head)))
           ((eq :CONS (type head)) (transform! pred fun head)))         
         (if tail (rplacd obj (transform! pred fun tail)))
         (if (and (not (eq :CONS (type tail))) (pred tail))
             (rplacd obj (fun tail)))))
      (t obj))
    obj)) 

(setq l '(2 (4 8)))
(transform! (lambda (x) (eq :INTEGER (type x))) (lambda (x) (* 2 x)) l)
(print l) ;; sucessfully prints (4 (8 16)).

(setq l (transform! (lambda (x) (eq :INTEGER (type x))) (lambda (x) (* 2 x)) '(2 (4 8))))
(print l) ;; successfully prints (4 (8 16)).

(setq l '(2 (4 . a)))
(transform! (lambda (obj) (eq :INTEGER (type obj))) (lambda (num) (* 2 num)) l)
(print l) ;; should print (4 (8 . 16))

(setq l (transform! (lambda (x) (eq :INTEGER (type x))) (lambda (x) (* 2 x)) '(2 (4 . 8))))
(print l) ;; should (4 (8 . 16))!
