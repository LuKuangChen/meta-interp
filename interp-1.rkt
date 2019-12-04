#lang racket
;; The basic interpreter

(define (extend-env x v env)
  `((,x . ,v) . ,env))

(define (apply-env env y)
  (match env
    [`() (error y)]
    [`((,x . ,v) . ,env)
     (if (equal? x y) v
         (apply-env env y))]))

(define (valof e env)
  (match e
    [`(quote ,d) d]
    [`(error ,e) (error (valof e env))]
    [`(pair? ,e) (pair? (valof e env))]
    [`(cons ,e1 ,e2) (cons (valof e1 env) (valof e2 env))]
    [`(car ,e) (car (valof e env))]
    [`(cdr ,e) (cdr (valof e env))]
    [`(symbol? ,e) (symbol? (valof e env))]
    [`(equal? ,e1 ,e2) (equal? (valof e1 env) (valof e2 env))]
    [`(if ,e1 ,e2 ,e3)
     (if (valof e1 env)
         (valof e2 env)
         (valof e3 env))]
    [(? symbol?) (apply-env env e)]
    [`(λ (,x) ,body)
     (λ (arg)
       (valof body (extend-env x arg env)))]
    [`(,rator ,rand)
     ((valof rator env)
      (valof rand env))]))

(define (eval e)
  (valof e '()))

(equal? (eval '((((λ (+) (+ +))
                  (λ (+)
                    (λ (n)
                      (λ (m)
                        (if (equal? n '())
                            m
                            (cons 's (((+ +) (cdr n)) m)))))))
                 '(s s))
                '(s s s)))
        '(s s s s s))