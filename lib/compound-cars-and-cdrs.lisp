(report-time-us "def compound car/cdrs          "
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 ;; compound car/cdrs:                                                                   ;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
 )

(provide 'compound-cars-and-cdrs)
