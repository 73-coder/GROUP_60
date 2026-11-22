(define (inorder-list tree acc)
  (if (null? tree)
      acc
      (inorder-list (cadr tree)
                    (cons (car tree)
                          (inorder-list (caddr tree) acc)))))