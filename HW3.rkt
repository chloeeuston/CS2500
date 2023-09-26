;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname HW3) (read-case-sensitive #t) (teachpacks ((lib "image.rkt" "teachpack" "2htdp"))) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ((lib "image.rkt" "teachpack" "2htdp")) #f)))
; EXERCISE 1


; number number -> number number
; create a data representation for time. 

(define-struct time [hours minutes])

; number number -> number
; create a function to easier identify minutes and hours

(define (minutes? hours minutes)
  (time-minutes (make-time hours minutes)))
(define (hours? hours minutes)
  (time-hours (make-time hours minutes)))

(check-expect (minutes? 5 2) 2)
(check-expect (hours? 5 2) 5)

; number number -> number number
; create a function to add a minute to the inputted time

(define (tock hours minutes)
  (if (and (= (hours? hours minutes) 0) (< (minutes? hours minutes) 59))
           (make-time 12 (+ (minutes? hours minutes) 1))
           (if (< (minutes? hours minutes) 59)
               (make-time (hours? hours minutes) (+ (minutes? hours minutes) 1))
               (if (< (hours? hours minutes) 11)
                   (make-time (+ (hours? hours minutes) 1) 0)
                   (make-time 12 0)))))

(check-expect (tock 0 15) (make-time 12 16))
(check-expect (tock 3 20) (make-time 3 21))
(check-expect (tock 3 59) (make-time 4 0))
(check-expect (tock 11 59) (make-time 12 0))

; number -> string
; create a function that displays time as a text.

(define (time->text hours minutes)
  (string-append
   (if (= (hours? hours minutes) 0)
       "12"
       (if (< (hours? hours minutes) 10)
           (string-append "0" (number->string (hours? hours minutes)))
           (number->string (hours? hours minutes))))
   ":"
   (if (< (minutes? hours minutes) 10)
       (string-append "0" (number->string (minutes? hours minutes)))
       (number->string (minutes? hours minutes)))))

(check-expect (time->text 0 5) "12:05")
(check-expect (time->text 4 9) "04:09")
(check-expect (time->text 11 1) "11:01")
(check-expect (time->text 11 15) "11:15")


; EXERCISE 2


(define (dist-to-O x y)
  (sqrt (+ (* x x) (* y y))))

(check-expect (dist-to-O 3 4) 5)
#| this is an example of applying a programmer-written function,
or a "plugin" step and a Dr. Racket built-in primitive function.
The "sqrt" and +/* are built in arithmatic functions, however
the "dist-to-O" function was a programmer-written function.|#

(define-struct point [x y])

(define (dist-to-O2 p)
  (sqrt (+ (sqr (point-x p))
           (sqr (point-y p)))))

(check-expect (dist-to-O2 (make-point 3 4)) 5)
#| this is an example of a built-in Dr. Racket function and a
programmer-written function. The "define-struct," "sqr," and
"sqrt" functions are all Dr. Racket built-in functions, where
the "dis-to-O" function is programmer-written. |#

(define (step x)
  (cond [(< 1 x) (sqr x)]
        [(< 0 x) (* 2 x)]
        [else    (sqr (+ x 1))]))

(check-expect (step 0) 1)
#| this is an example of built-in Dr. Racket function, conditional
 step, and programmer-written function. The built-in Dr. Racket
functions are "<," "sqr," and "+/*." The conditional step is shown
by the "cond" in the second line of the code. Lastly, the
programmer-written function in the "step x" function. |#


; EXERCISE 3


; string string number number -> string string number number
; create a data representation for stocks

(define-struct stock [name symbol low high])

(check-expect (make-stock "apple" "APPL" 50 100)
              (make-stock "apple" "APPL" 50 100))

; number -> number
; create functions to easier represent high/low values

(define (low? name symbol low high)
  (stock-low (make-stock name symbol low high)))
(define (high? name symbol low high)
  (stock-high (make-stock name symbol low high)))

(check-expect (low? "apple" "APPL" 50 100) 50)
(check-expect (high? "apple" "APPL" 50 100) 100)

; number number -> number
; create a function to compute the average stock price

(define (avg-price name symbol low high)
  (/ (+ (low? name symbol low high) (high? name symbol low high)) 2))

(check-expect (avg-price "apple" "APPL" 50 100) 75) 