;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname HW1) (read-case-sensitive #t) (teachpacks ((lib "image.rkt" "teachpack" "2htdp") (lib "universe.rkt" "teachpack" "2htdp"))) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ((lib "image.rkt" "teachpack" "2htdp") (lib "universe.rkt" "teachpack" "2htdp")) #f)))
; EXERCISE 1

(/ (+ 29550 5870 4090 620) (* 4 37))

; EXERCISE 2

(define (poly1 x) (+ (* 1/100 x x x) (* -2/100 x x) (* 2 x) 1))

; EXERCISE 3

(define (poly2 x) (+ 1 (* x (+ 2 (* x (+ -2/100 (* x 1/100)))))))

(poly1 1)
(poly2 1)
(poly1 5)
(poly2 5)

; EXERCISE 4

(define SCENE (empty-scene 100 100))
(define DOT (circle 5 "solid" "red"))

(define (poly-diff x) (- (poly1 x) (poly2 x)))

(define (poly-diff->scene x) (place-image
 DOT
 x (+ (poly-diff x) 50)
 SCENE))

(poly-diff->scene 5)
(poly-diff->scene 10)

(animate poly-diff->scene)

#| When you animate the poly-diff function, the animation
 shows the dot moving straight across the scene, without
going up or down. The lack of change in y proves that there
if no difference between poly1 and poly2. This differs when
you introduce a bug, as the dot moves vertically when you
adjust either polynomial, representing the difference between
the functions.|#


   ; EXERCISE 5

(define (hw02-12 p)
  (cond [(> p 0) (* (/ 30 (+ (* 11 (/ 100 p)) 1)) (/ 100 p))]
        [(= p 0) (/ 30 11)]))

(hw02-12 100)
(hw02-12 50)
(hw02-12 25)

; EXERCISE 6

(define (hw01 p) (* (/ p 100) (* (/ 30 (+ (* 11 (/ 100 p)) 1)) (/ 100 p))))

(hw01 100)
(hw01 50)
(hw01 25)

; EXERCISE 7

(define (histogram-bar h) (rectangle 30 (- (* 50 h) 20) "solid" "black"))

; EXERCISE 8

(define (histogram p0 p1 p2 p3 p4 p5 p6 p7 p8 p9 p10) (beside/align "bottom"
                                                       (histogram-bar (hw02-12 p0))
                                                       (histogram-bar (hw02-12 p1))
                                                       (histogram-bar (hw02-12 p2))
                                                       (histogram-bar (hw02-12 p3))
                                                       (histogram-bar (hw02-12 p4))
                                                       (histogram-bar (hw02-12 p5))
                                                       (histogram-bar (hw02-12 p6))
                                                       (histogram-bar (hw02-12 p7))
                                                       (histogram-bar (hw02-12 p8))
                                                       (histogram-bar (hw02-12 p9))
                                                       (histogram-bar (hw02-12 p10))))

; EXERCISE 9

(histogram 0 300 600 900 1200 1500 1800 2100 2400 2700 3000)
(histogram 0 10 20 30 40 50 60 70 80 90 100)

#| The "right" choice for the p value is subjective to how much
the teacher wants it to be worth. However, since the graph does not
increase/decrease linearly, it would make more sense for the p value
to be in the middle/upper values, where the graph flattens out more. |#