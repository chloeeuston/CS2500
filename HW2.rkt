;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname HW2) (read-case-sensitive #t) (teachpacks ((lib "image.rkt" "teachpack" "2htdp"))) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ((lib "image.rkt" "teachpack" "2htdp")) #f)))
;EXERCISE 1
; string -> boolean
; determine if the first and second half a string are the same (if it follows an XX pattern)


(define (duplicated? s)
  (cond [(odd? (string-length s)) #f]
        [(string=? (substring s 0 (/ (string-length s) 2))
                   (substring s (/ (string-length s) 2) (string-length s))) #t]
        [else #f]))
        
(check-expect (duplicated? "abab") #t)
(check-expect (duplicated? "abbb") #f)
(check-expect (duplicated? "aba") #f)

; EXERCISE 2
; number number -> image
; create an image of a holiday tree given two scalar quantities

(define ANGLE 120)

(define (pine-tree a d)
  (above
   (isosceles-triangle a ANGLE "solid" "forestgreen")
   (isosceles-triangle (+ a d) ANGLE "solid" "forestgreen")
   (isosceles-triangle (+ a (* 2 d)) ANGLE "solid" "forestgreen")
   (isosceles-triangle (+ a (* 3 d)) ANGLE "solid" "forestgreen")
   (isosceles-triangle (+ a (* 4 d)) ANGLE "solid" "forestgreen")
   (rectangle a (* a 1.5) "solid" "brown")))

(pine-tree 40 10)

#| The color and fill, "solid" and "forestgreen" are hard-coded into
this function. The function could be adjusted by defining "COLOR"
as forestgreen outside of the funtion. |#


; EXERCISE 3
; number number number number -> boolean
; determine if the closed interval [a,b] is nested inside [c,d].

; c <= a <= b <= d

(define (subset-interval a b c d)
  (cond [(and (<= c a) (<= a b) (<= b d)) #t]
        [else #f]))

(check-expect (subset-interval 4 5 3 6) #t)
(check-expect (subset-interval 6 6 7 1) #f)
(check-expect (subset-interval 4 4 3 5) #t)
(check-expect (subset-interval 3 2 1 4) #f)
(check-expect (subset-interval 4 5 4 7) #t)
(check-expect (subset-interval 2 2 2 2) #t)

; EXERCISE 4
; number number -> boolean
; determine the truth value of the implication give x and y boolean values.

(define (=> x y)
  (cond [(= y 1) #t]
        [(= x 0) #t]
        [else #f]))

(check-expect (=> 0 0) #t)
(check-expect (=> 0 1) #t)
(check-expect (=> 1 0) #f)
(check-expect (=> 1 1) #t)

#| "If Boston is the capital of the moon, there will be two exams in
Fundies 1." This statement is true. Since both the "x" and "y"
portions of this statement are true, the whole statement must
also be true. |#