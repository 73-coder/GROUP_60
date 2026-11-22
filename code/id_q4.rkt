#lang racket/base

(define (my-length lst)
  (if (null? lst)
      0
      (+ 1 (my-length (cdr lst)))))

(define (my-map f lst)
  (if (null? lst)
      '()
      (cons (f (car lst))
            (my-map f (cdr lst)))))

(define (make-inserter x len-ok?)
  (define (process lst)
    (let ((processed
           (my-map (lambda (e)
                     (if (or (null? e) (pair? e))
                         (process e)
                         e))
                   lst)))
      (if (len-ok? (my-length lst))
          (cons x processed)
          processed)))
  process)