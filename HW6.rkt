;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname HW6) (read-case-sensitive #t) (teachpacks ((lib "image.rkt" "teachpack" "2htdp"))) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ((lib "image.rkt" "teachpack" "2htdp")) #f)))
; EXERCISE 1



; a los (list of strings) is one of
; - '()
; (cons String los)


;(define (los-template los)
;  (cond [(empty? los)...]
;        [else... (first los)... (los-template (rest los))]))


; new-los: los Natural -> los
; a list of strings in a los that have length less than n


(define (new-los los n)
  (cond [(empty? los) '()]
        [(< (string-length (first los)) n)
         (cons (first los) (new-los (rest los) n))]
        [else (new-los (rest los) n)]))


(check-expect (new-los
               (cons "hello" (cons "abc" (cons "hi" '()))) 5)
              (cons "abc" (cons "hi" '())))
(check-expect (new-los '() 3) '())



; EXERCISE 2



; los-greater?: los Natural -> Boolean
; do all the strings in los have length greater than n?


(define (string-greater los n)
  (cond [(empty? los) #t]
        [else (and (> (string-length (first los)) n)
                   (string-greater (rest los) n))]))


(check-expect (string-greater
               (list "hello" "world" "there") 4) #t)
(check-expect (string-greater
               (list "hi" "hey" "hello") 4) #f)
(check-expect (string-greater '() 4) #t)



; EXERCISE 3



; a lon (list of numbers) is one of:
; - '()
; - (cons Number lon)


;(define (lon-template los)
;  (cond [(empty? lns)...]
;        [else... (first lon)... (lon-template (rest lon))]))


; lon-add: lon Number -> lon
; add a number to each element in the list of numbers


(define (lon-add lon n)
  (cond [(empty? lon) '()]
        [else (cons (+ (first lon) n) (lon-add (rest lon) n))]))

(check-expect (lon-add (cons 5 (cons 3 (cons 0 '()))) 3)
              (cons 8 (cons 6 (cons 3 '()))))
(check-expect (lon-add '() 6) '())



; EXERCISE 4



; lon-div: lon Number -> lon
; divide a number by every element in a list


(define (lon-div lon n)
  (cond [(empty? lon) '()]
        [(= (first lon) 0) (cons "DIV0" (lon-div (rest lon) n))]
        [else (cons (/ n (first lon)) (lon-div (rest lon) n))]))

(check-expect (lon-div (cons 2 (cons 4 (cons 3 '()))) 12)
              (cons 6 (cons 3 (cons 4 '()))))
(check-expect (lon-div (cons 4 (cons 0 '())) 8)
              (cons 2 (cons "DIV0" '())))
(check-expect (lon-div '() 5) '())



; EXERCISE 5



(define BG-WIDTH 100)
(define BG-HEIGHT 100)
(define BG (empty-scene BG-WIDTH BG-HEIGHT))


; los->image: los -> Image
; an image of the first string in the list


(define (los->image los)
  (cond [(empty? los) BG]
        [else (place-image (text (first los) 10 "blue")
                           (/ BG-WIDTH 2) (/ BG-HEIGHT 2)
                           BG)]))


; next-image: los -> los
; the next string in the list


(define (next-image los)
  (cond [(empty? los) " "]
        [else (rest los)]))


(require 2htdp/universe)


; mouse: World Number Number MouseEvent -> World
; outputs the next WorldState if the mouse is clicked


(define (mouse w x y me)
  (cond
    [(mouse=? me "button-down") (next-image w)]
    [else w]))


; slideshow: los -> Image
; displays the list of strings one by one at each click.


(define (slideshow los)
  (big-bang los
    (to-draw los->image)
    (on-mouse mouse)))


; EXERCISE 6



(define-struct date [year month day])

; a Date is a (make-date Natural Natural Natural)


; a loe, list of exercises, is one of:
; - '()
; - (cons Exercise loe)

(define-struct assignment [loe date])



; EXERCISE 7



; a loa, list of assignments, is one of:
; - '()
; - (cons assignment loa)


; add0: string -> string
; adds a zero to a single digit number as a string


(define (add0 n)
  (cond [(= (string-length n) 1)
         (string-append "0" n)]
        [else n]))

(check-expect (add0 "5") "05")
(check-expect (add0 "15") "15")


; date->value: Date -> Number
; describes a date as a quantified number


(define (date->value date)
  (string->number
   (string-append
    (number->string (date-year date))
    (add0 (number->string (date-month date)))
    (add0 (number->string (date-day date))))))


(check-expect (date->value (make-date 2022 7 13)) 20220713)
(check-expect (date->value (make-date 2022 12 6)) 20221206)


; due-exercises: loa Date -> loe
; the list of exercises in the list of assignments that are due before a date


(define (due-exercises loa date)
  (cond [(empty? loa) '()]
        [(< (date->value (assignment-date (first loa)))
            (date->value date))
         (append (assignment-loe (first loa)) (due-exercises (rest loa) date))]
        [else (due-exercises (rest loa) date)]))


(check-expect (due-exercises (list (make-assignment (list "EX1" "EX2")
                                                    (make-date 2022 5 4))
                                   (make-assignment (list "EX3" "EX4")
                                                    (make-date 2022 5 21)))
                             (make-date 2022 5 20))
              (cons "EX1" (cons "EX2" '())))
(check-expect (due-exercises '() (make-date 2022 5 6))
              '())
