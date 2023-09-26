;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-intermediate-lambda-reader.ss" "lang")((modname HW9) (read-case-sensitive #t) (teachpacks ((lib "image.rkt" "teachpack" "2htdp"))) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ((lib "image.rkt" "teachpack" "2htdp")) #f)))
;;; EXERCISE 1

; str-in-list-even?/v1: LOS String -> Boolean
; determines if the given string occurs in a list of strings
; an even number of times

(define (str-in-list-even?/v1 los s)
  (even?
   (length
    (filter (lambda (los-s) (string=? s los-s)) los))))

(check-expect (str-in-list-even?/v1
               '("apple" "pear" "blueberry" "mango")
               "apple")
              #f)
(check-expect (str-in-list-even?/v1
               '("apple" "apple" "pear" "blueberry" "mango")
               "apple")
              #t)
(check-expect (str-in-list-even?/v1
               '("pear" "blueberry" "mango")
               "apple")
              #t)

;;; EXERCISE 2

; str-in-list-even?/v2: LoS String -> Boolean
; does the string occur in a list of strings an even
; number of times?
(define (str-in-list-even?/v2 los s)
  (foldr (lambda (input-s b) (if (string=? s input-s)
                                 (not b)
                                 b))
         #t
         los))

(check-expect (str-in-list-even?/v2
               '("apple" "pear" "blueberry" "mango")
               "apple")
              #f)
(check-expect (str-in-list-even?/v2
               '("apple" "apple" "pear" "blueberry" "mango")
               "apple")
              #t)
(check-expect (str-in-list-even?/v2
               '("pear" "blueberry" "mango")
               "apple")
              #t)

;;; EXERCISE 3

; do-to-all-if: (X Y) [X -> Boolean] [X -> Y] [Listof X] -> [Listof Y]
; applies test to all items on the list if they satisfy the given test

(define (do-to-all-if test f lon)
  (map (lambda (n)
         (if (test n)
             (f n)
             n))
       lon))

(check-expect (do-to-all-if negative? sub1 (list 10 -10 -20 20))
              (list 10 -11 -21 20))
(check-expect (do-to-all-if negative? sub1 '())
              '())
(check-expect (do-to-all-if string? string-length '("apple" "banana" "cat"))
              '(5 6 3))
(check-expect (do-to-all-if string? string-length '('apple "banana" "cat"))
              '('apple 6 3))
      

;;; EXERCISE 4

; concat-all-strs: LoS -> String
; condenses all strings in a list into one string

(define (concat-all-strs los)
  (foldr (lambda (current-s s) (string-append current-s s))
         ""
         los))

(check-expect (concat-all-strs '("i " "like " "dogs"))
              "i like dogs")
(check-expect (concat-all-strs '())
              "")

;;; EXERCISE 5

; biggest-number: Lonnn (list of nonnegative numbers) -> Number
; outputs the biggest number in the list
(define (biggest-number lonnn)
  (foldr (lambda (current-nnn n) (if (>= current-nnn n)
                                     current-nnn
                                     n))
         0
         lonnn))

(check-expect (biggest-number '(1 3 5 7 9)) 9)
(check-expect (biggest-number '(1 9 5 37 2)) 37)
(check-expect (biggest-number '(8 2 4 5 2)) 8)
(check-expect (biggest-number '(1 1 1 1 1)) 1)

;;; EXERCISE 6

; page->volume: Number LoP ->  Number
; what volume is the given page number in?

(define (page->volume p lop)
  (foldr (lambda (current b)
           (if (< p current)
               (- b 1)
               b))
         (length lop)
         lop))

(check-expect (page->volume 150 (list 101 201 301)) 1)
(check-expect (page->volume 300 (list 101 201 301)) 2)
(check-expect (page->volume 301 (list 101 201 301)) 3)
(check-expect (page->volume 999 (list 101 201 301)) 3)
(check-expect (page->volume   1 (list 101 201 301)) 0)

;;; EXERCISE 7

; all-in-range: (X Y) [X X -> Boolean] [X] [X] [Listof X] -> Boolean
; are all the values in the list within the range according to the given test?

(define (all-in-range test min max lov)
  (andmap (lambda (x) (and (test x min)
                           (not (test x max))))
          lov))

(check-expect (all-in-range > 0 10 '(1 6 3 8 2))
              #t)
(check-expect (all-in-range > 0 10 '(1 6 3 8 2 0))
              #f)
(check-expect (all-in-range > 0 10 '(1 6 11 8 2))
              #f)
(check-expect (all-in-range string>? "aardvark" "banana"
                            '("apple" "art" "astrology" "astronomy"))
              #t)
(check-expect (all-in-range string>? "aardvark" "banana"
                            '("apple" "art" "astrology" "astronomy" "cat"))
              #f) 

;;; EXERCISE 8

; NumSet = [ListOf Number]
; Order of items in the list irrelevant; repetitions not allowed.
 
; NumSet Number -> Boolean
; Is the number a member of the set?
(define (contains? s n) 
  (ormap (lambda (elt) (= elt n)) s))
 
; Add the element e to set s.
; Number NumSet -> NumSet
(define (elt+set e s)
  (if (contains? s e) s
      (cons e s)))

; union: [Listof Numbers] [Listof Numbers] -> [Listof Numbers]
; combines the contents of two sets without repeating numbers
(define (union s1 s2)
  (append s1 (filter (lambda (n)
                       (not (contains? s1 n)))
                     s2)))

(check-expect (union '(1 2 3 4 5)
                     '(6 7 8 9 10))
              '(1 2 3 4 5 6 7 8 9 10))
(check-expect (union '(1 2 3 4 5 6)
                     '(6 7 8 9 10))
              '(1 2 3 4 5 6 7 8 9 10))