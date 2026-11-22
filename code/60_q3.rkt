(define (inorder-list tree acc)
  (if (null? tree)
      acc
      (inorder-list (cadr tree)
                    (cons (car tree)
                          (inorder-list (caddr tree) acc)))))

(define (print-inorder tree)
  (display (inorder-list tree '()))
  (newline))

  (define (preorder-list tree acc)
  (if (null? tree)
      acc
      (cons (car tree)
            (preorder-list (cadr tree)
                           (preorder-list (caddr tree) acc)))))
