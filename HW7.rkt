;; The first three lines of this file were inserted by DrRacket. They record metadata
;; about the language level of this file in a form that our tools can easily process.
#reader(lib "htdp-beginner-reader.ss" "lang")((modname HW7) (read-case-sensitive #t) (teachpacks ((lib "image.rkt" "teachpack" "2htdp"))) (htdp-settings #(#t constructor repeating-decimal #f #t none #f ((lib "image.rkt" "teachpack" "2htdp")) #f)))
;;; PROBLEM 1

(require 2htdp/image)
(require 2htdp/universe)


;;; Data Definitions:

 
;;; A Brick is a (make-brick Number Number Color)
(define-struct brick [x y color])

;;; A Pt (2D point) is a (make-posn Integer Integer)

;;; A Tetra is a (make-tetra Pt Bricks)
;;; The center point is the point around which the tetra
;;; rotates when it spins.
(define-struct tetra [center bricks])

;;; A Bricks (Set of Bricks) is one of:
;;; - empty
;;; - (cons Brick Bricks)
;;; Order does not matter.

;;; A World is a (make-world Tetra Bricks)
;;; The set of bricks represents the pile of bricks
;;; at the bottom of the screen.
(define-struct world [tetra pile])



;;; Rendering Functions:
;;; - place-image/cell : Image Number Number Image -> Image
;;;   place-image but with cell coordinates
;;; - brick->image : Brick -> Image
;;;   produces an image of a single brick
;;; - brick+scene : Brick Image -> Image
;;;   places a Brick onto the scene
;;; - bricks+scene : Bricks Image -> Image
;;;   adds all of the Bricks in the list to the scene
;;; - tetra+scene : Tetra + Image -> Image
;;;   adds a given tetra to the scene
;;; - score-screen : World -> Image
;;;   displays the score (number of bricks) on the screen


;;; Brick Mechanincs:
;;; - brick-rotate-ccw : Brick Pt -> Brick
;;;   rotates the brick counterclockwise around the point
;;; - bricks-rotate-ccw : Bricks Pt -> Bricks
;;;   rotates each Brick counterclockwise around the point
;;; - tetra-rotate-ccw : Tetra -> Tetra
;;;   rotates a Tetra counterclockwise around its center

;;; - brick-rotate-cw : Brick Pt -> Brick
;;;   rotates the brick clockwise around the point
;;; - bricks-rotate-cw : Bricks Pt -> Bricks
;;;   rotates each brick clockwise around the point
;;; - tetra-rotate-cw : Tetra -> Tetra
;;;   roates a Tetra clockwise around its center

;;; - brick-fall : Brick -> Brick
;;;   moves the Brick down one cell
;;; - bricks-fall : Bricks -> Bricks
;;;   moves each Brick from the Bricks down one cell
;;; - tetra-fall : Tetra -> Tetra
;;;   moves the Bricks and the rotational point down one cell

;;; - brick-move-left : Brick -> Brick
;;;   moves the Brick to the left one cell
;;; - bricks-move-left : Bricks -> Bricks
;;;   moves each Brick in the Bricks to the left one cell
;;; - tetra-move-left : Tetra -> Tetra
;;;   moves a Tetra and its center to the left one cell

;;; - brick-move-right : Brick -> Brick
;;;   moves the Brick to the right one cell
;;; - bricks-move-right : Bricks -> Bricks
;;;   moves each Brick in the Bricks to the right one cell
;;; - tetra-move-right : Tetra -> Tetra
;;;   moves a Tetra and its center to the right one cell


;;; Big-bang requirements:
;;; - next-world : World -> World
;;; - world->scene : World -> Image
;;; - key-handler : World KE -> World


;;; Detection:
;;; - tetra-ground-collide? : World -> Boolean
;;;   is the tetra on the ground?
;;; - tetra-pile-collide? : World -> Boolean
;;;   is the tetra on the pile?
;;; - tetra-collide? : World -> Boolean
;;;   is the tetra on the ground or on the pile?
;;; - too-far-left? : Tetra -> Boolean
;;;   is a Tetra on the left boundary of the board?
;;; - too-far-right? : Tetra -> Boolean
;;;   is a Tetra on the right boundary of the board?
;;; - game-over? : World -> Boolean
;;;   has the pile reached the top of the board?


;;; Other:
;;; - new-random-tetra : World -> World
;;;   add a new random tetra to an existing world
;;; - number->tetra : Number -> Tetra
;;;   produces a tetra given a number
;;; - count-bricks: Bricks -> Natural
;;;   the number of individual Bricks on the board


;;; Templates:


;;;(define (brick-template brick)
;;;  (... (brick-x brick)...
;;;       (brick-y brick)...
;;;       (brick-color brick)...))

;;;(define (bricks-template bricks)
;;;  (cond [(empty? bricks)...]
;;;        [else... (brick-template (first bricks))...
;;;                 (bricks-template (rest bricks))...]))

;;; (define (tetra-template tetra)
;;;   (... (tetra-center tetra)...
;;;        (tetra-bricks tetra)...))


;;; Constants :

(define BOARD-HEIGHT 20)
(define BOARD-WIDTH 10)
(define PIXELS/CELL 30)
(define BOARD (empty-scene (* BOARD-WIDTH  PIXELS/CELL)
                           (* BOARD-HEIGHT PIXELS/CELL)))
(define TICK-RATE 0.3)
(define INITIAL-POINT (make-posn (- (* BOARD-WIDTH 1/2) 1)
                                 (- BOARD-HEIGHT 2))) ; the starting point of a tetra


(define TETRA-O (make-tetra (make-posn (+ 1/2 (posn-x INITIAL-POINT))
                                       (+ 1/2 (posn-y INITIAL-POINT)))
                            (list (make-brick (+ 1 (posn-x INITIAL-POINT))
                                              (posn-y INITIAL-POINT)
                                              "green")
                                  (make-brick (posn-x INITIAL-POINT)
                                              (+ 1 (posn-y INITIAL-POINT))
                                              "green")
                                  (make-brick (posn-x INITIAL-POINT)
                                              (posn-y INITIAL-POINT)
                                              "green")
                                  (make-brick (+ 1 (posn-x INITIAL-POINT))
                                              (+ 1 (posn-y INITIAL-POINT))
                                              "green"))))

(define TETRA-I (make-tetra (make-posn (- (posn-x INITIAL-POINT) 1/2)
                                       (+ (posn-y INITIAL-POINT) 1/2))
                            (list (make-brick (posn-x INITIAL-POINT)
                                              (+ (posn-y INITIAL-POINT) 1)
                                              "blue")
                                  (make-brick (+ (posn-x INITIAL-POINT) 1)
                                              (+ (posn-y INITIAL-POINT) 1)
                                              "blue")
                                  (make-brick (+ (posn-x INITIAL-POINT) 2)
                                              (+ (posn-y INITIAL-POINT) 1)
                                              "blue")
                                  (make-brick (- (posn-x INITIAL-POINT) 1)
                                              (+ (posn-y INITIAL-POINT) 1)
                                              "blue"))))


(define TETRA-L (make-tetra (make-posn (posn-x INITIAL-POINT)
                                       (posn-y INITIAL-POINT))
                            (list (make-brick (posn-x INITIAL-POINT)
                                              (posn-y INITIAL-POINT)
                                              "purple")
                                  (make-brick (+ (posn-x INITIAL-POINT) 1)
                                              (+ (posn-y INITIAL-POINT) 1)
                                              "purple")
                                  (make-brick (+ (posn-x INITIAL-POINT) 1)
                                              (posn-y INITIAL-POINT)
                                              "purple")
                                  (make-brick (- (posn-x INITIAL-POINT) 1)
                                              (posn-y INITIAL-POINT)
                                              "purple"))))

(define TETRA-J (make-tetra (make-posn (posn-x INITIAL-POINT)
                                       (posn-y INITIAL-POINT))
                            (list (make-brick (posn-x INITIAL-POINT)
                                              (posn-y INITIAL-POINT)
                                              "cyan")
                                  (make-brick (- (posn-x INITIAL-POINT) 1)
                                              (+ (posn-y INITIAL-POINT) 1)
                                              "cyan")
                                  (make-brick (+ (posn-x INITIAL-POINT) 1)
                                              (posn-y INITIAL-POINT)
                                              "cyan")
                                  (make-brick (- (posn-x INITIAL-POINT) 1)
                                              (posn-y INITIAL-POINT)
                                              "cyan"))))
                            
(define TETRA-T (make-tetra (make-posn (posn-x INITIAL-POINT)
                                       (posn-y INITIAL-POINT))
                            (list (make-brick (posn-x INITIAL-POINT)
                                              (posn-y INITIAL-POINT)
                                              "orange")
                                  (make-brick (posn-x INITIAL-POINT)
                                              (+ 1 (posn-y INITIAL-POINT))
                                              "orange")
                                  (make-brick (+ 1 (posn-x INITIAL-POINT))
                                              (posn-y INITIAL-POINT)
                                              "orange")
                                  (make-brick (- (posn-x INITIAL-POINT) 1)
                                              (posn-y INITIAL-POINT)
                                              "orange"))))

(define TETRA-Z (make-tetra (make-posn (posn-x INITIAL-POINT)
                                       (posn-y INITIAL-POINT))
                            (list (make-brick (posn-x INITIAL-POINT)
                                              (posn-y INITIAL-POINT)
                                              "pink")
                                  (make-brick (posn-x INITIAL-POINT)
                                              (+ 1 (posn-y INITIAL-POINT))
                                              "pink")
                                  (make-brick (+ 1 (posn-x INITIAL-POINT))
                                              (posn-y INITIAL-POINT)
                                              "pink")
                                  (make-brick (- (posn-x INITIAL-POINT) 1)
                                              (+ 1 (posn-y INITIAL-POINT))
                                              "pink"))))

(define TETRA-S (make-tetra (make-posn (posn-x INITIAL-POINT)
                                       (posn-y INITIAL-POINT))
                            (list (make-brick (posn-x INITIAL-POINT)
                                              (posn-y INITIAL-POINT)
                                              "red")
                                  (make-brick (posn-x INITIAL-POINT)
                                              (+ 1 (posn-y INITIAL-POINT))
                                              "red")
                                  (make-brick (+ 1 (posn-x INITIAL-POINT))
                                              (+ 1 (posn-y INITIAL-POINT))
                                              "red")
                                  (make-brick (- (posn-x INITIAL-POINT) 1)
                                              (posn-y INITIAL-POINT)
                                              "red"))))


;;; place-image/cell : Image Number Number Image -> Image
;;; place-image but with cell coordinates


(define (place-image/cell i1 x y i2)
  (place-image i1
               (* PIXELS/CELL (+ 1/2 x))
               (* PIXELS/CELL (- BOARD-HEIGHT (+ 1/2 y)))
               i2))

(check-expect (place-image/cell (circle 5 "solid" "red") 15 20 BOARD)
              (place-image (circle 5 "solid" "red")
                           (* (+ 1/2 15) PIXELS/CELL)
                           (* PIXELS/CELL (- BOARD-HEIGHT (+ 1/2 20)))
                           BOARD))
(check-expect (place-image/cell (square 10 "outline" "black") 0 0 BOARD)
              (place-image (square 10 "outline" "black")
                           (* (+ 1/2 0) PIXELS/CELL)
                           (* PIXELS/CELL (- BOARD-HEIGHT (+ 1/2 0)))
                           BOARD))


;;; brick->image : Brick -> Image
;;; produces an image of a single brick


(define (brick->image brick)
  (overlay (square PIXELS/CELL "outline" "black")
           (square PIXELS/CELL "solid" (brick-color brick))))

(check-expect (brick->image (make-brick 6 4 "red"))
              (overlay (square 30 "outline" "black")
                       (square 30 "solid" "red")))
(check-expect (brick->image (make-brick 6 4 "pink"))
              (overlay (square 30 "outline" "black")
                       (square 30 "solid" "pink")))


;;; brick+scene : Brick Image -> Image
;;; places a Brick onto the scene


(define (brick+scene brick scene)
  (place-image/cell (brick->image brick)
                    (brick-x brick)
                    (brick-y brick)
                    scene))

(check-expect (brick+scene (make-brick 5 15 "cyan")
                           BOARD)
              (place-image/cell (overlay (square 30 "outline" "black")
                                         (square 30 "solid" "cyan"))
                                5 15 BOARD))
(check-expect (brick+scene (make-brick 2 10 "blue")
                           BOARD)
              (place-image/cell (overlay (square 30 "outline" "black")
                                         (square 30 "solid" "blue"))
                                2 10 BOARD))


;;; bricks+scene : Bricks Image -> Image
;;; adds all of the Bricks in the list to the scene


(define (bricks+scene bricks scene)
  (cond [(empty? bricks) scene]
        [else (brick+scene (first bricks)
                           (bricks+scene (rest bricks) scene))]))

(check-expect (bricks+scene '() BOARD)
              BOARD)
(check-expect (bricks+scene (list (make-brick 3 17 "purple")
                                  (make-brick 6 10 "orange"))
                            BOARD)
              (brick+scene (make-brick 3 17 "purple")
                           (brick+scene (make-brick 6 10 "orange") BOARD)))


;;; tetra+scene : Tetra + Image -> Image
;;; adds a given tetra to the scene


(define (tetra+scene tetra scene)
  (bricks+scene (tetra-bricks tetra) scene))

(check-expect (tetra+scene (make-tetra (make-posn 8 8) '()) BOARD)
              BOARD)
(check-expect (tetra+scene TETRA-S BOARD)
              (bricks+scene (tetra-bricks TETRA-S) BOARD))


;;; tetra-ground-collide? : World -> Boolean
;;; is the tetra on the ground?


(define (tetra-ground-collide? world)
  (cond [(empty? (tetra-bricks (world-tetra world))) #f] 
        [(= (brick-y (first (tetra-bricks (world-tetra world))))
            0) #t]
        [else (tetra-ground-collide? (make-world
                                      (make-tetra
                                       (tetra-center (world-tetra world))
                                       (rest (tetra-bricks (world-tetra world))))
                                      (world-pile world)))]))

(check-expect (tetra-ground-collide?
               (make-world (make-tetra (make-posn 5 1)
                                       (list (make-brick 5 2 "red")
                                             (make-brick 5 0 "red")))
                           '())) #t)
(check-expect (tetra-ground-collide?
               (make-world TETRA-J '())) #f)
                                                        

;;; tetra-pile-collide? : World -> Boolean
;;; is the tetra on the pile?


(define (tetra-pile-collide? world)
  (cond [(empty? (tetra-bricks (world-tetra world))) #f]
        [(empty? (world-pile world)) #f]
        [(and (= (brick-x (first (tetra-bricks (world-tetra world))))
                 (brick-x (first (world-pile world))))
              (= (- (brick-y (first (tetra-bricks (world-tetra world)))) 1)
                 (brick-y (first (world-pile world))))) #t]
        [(tetra-pile-collide?
          (make-world (make-tetra (tetra-center (world-tetra world))
                                  (rest (tetra-bricks (world-tetra world))))
                      (world-pile world))) #t]
        [(tetra-pile-collide?
          (make-world (world-tetra world)
                      (rest (world-pile world)))) #t]
        [else #f]))

(check-expect (tetra-pile-collide?
               (make-world (make-tetra
                            (make-posn 5 6)
                            (list (make-brick 5 6 "pink")
                                  (make-brick 5 5 "pink")))
                            (list (make-brick 4 4 "purple")
                                  (make-brick 5 4 "purple")))) #t)
(check-expect (tetra-pile-collide?
               (make-world TETRA-O '())) #f)
(check-expect (tetra-pile-collide?
               (make-world TETRA-O
                           (list (make-brick 8 12 "cyan")
                                 (make-brick 7 12 "cyan")))) #f)


;;; tetra-collide? : World -> Boolean
;;; is the tetra on the ground or on the pile?


(define (tetra-collide? world)
  (cond [(or (tetra-ground-collide? world)
             (tetra-pile-collide? world)) #t]
        [else #f]))

(check-expect (tetra-collide?
               (make-world TETRA-O
                           (list (make-brick 8 12 "cyan")
                                 (make-brick 7 12 "cyan")))) #f)
(check-expect (tetra-collide?
               (make-world (make-tetra (make-posn 5 1)
                                       (list (make-brick 5 2 "red")
                                             (make-brick 5 0 "red")))
                           '())) #t)


;;; too-far-left? : Tetra -> Boolean
;;; is a Tetra on the left boundary of the board?


(define (too-far-left? tetra)
  (cond [(empty? (tetra-bricks tetra)) #f] 
        [(= (brick-x (first (tetra-bricks tetra)))
            0) #t]
        [else (too-far-left?  (make-tetra
                               (tetra-center tetra)
                               (rest (tetra-bricks tetra))))]))

(check-expect (too-far-left?
               (make-tetra (make-posn 5 1)
                           (list (make-brick 1 2 "red")
                                 (make-brick 0 2 "red")))) #t)
(check-expect (too-far-left?
               (make-tetra (make-posn 5 10) '())) #f)
(check-expect (too-far-left?
               (make-tetra (make-posn 5 1)
                           (list (make-brick 1 2 "red")
                                 (make-brick 2 2 "red")))) #f)


;;; too-far-right? : Tetra -> Boolean
;;; is a Tetra on the right boundary of the board?


(define (too-far-right? tetra)
  (cond [(empty? (tetra-bricks tetra)) #f] 
        [(= (brick-x (first (tetra-bricks tetra)))
            9) #t]
        [else (too-far-right?  (make-tetra
                                (tetra-center tetra)
                                (rest (tetra-bricks tetra))))]))

(check-expect (too-far-right?
               (make-tetra (make-posn 5 1)
                           (list (make-brick 1 2 "red")
                                 (make-brick 0 2 "red")))) #f)
(check-expect (too-far-right?
               (make-tetra (make-posn 5 10) '())) #f)
(check-expect (too-far-right?
               (make-tetra (make-posn 5 1)
                           (list (make-brick 7 2 "red")
                                 (make-brick 8 2 "red")
                                 (make-brick 9 2 "red")))) #t)


;;; brick-rotate-ccw : Brick Pt -> Brick
;;; rotates the brick counterclockwise around the point


(define (brick-rotate-ccw brick pt)
  (make-brick (+ (posn-x pt)
                 (- (posn-y pt)
                    (brick-y brick)))
              (+ (posn-y pt)
                 (- (brick-x brick)
                    (posn-x pt)))
              (brick-color brick)))

(check-expect (brick-rotate-ccw
               (make-brick 9 9 "blue")
               (make-posn 10 10))
              (make-brick 11 9 "blue"))
(check-expect (brick-rotate-ccw
               (make-brick 1 10 "orange")
               (make-posn 3 14))
              (make-brick 7 12 "orange"))


;;; bricks-rotate-ccw : Bricks Pt -> Bricks
;;; rotates each Brick counterclockwise around the point


(define (bricks-rotate-ccw bricks pt)
  (cond [(empty? bricks) '()]
        [else (cons (brick-rotate-ccw (first bricks) pt)
                    (bricks-rotate-ccw (rest bricks) pt))]))

(check-expect (bricks-rotate-ccw
               (list (make-brick 8 3 "green")
                     (make-brick 7 3 "green"))
               (make-posn 5 10))
              (list (brick-rotate-ccw
                     (make-brick 8 3 "green")
                     (make-posn 5 10))
                    (brick-rotate-ccw
                     (make-brick 7 3 "green")
                     (make-posn 5 10))))
(check-expect (bricks-rotate-ccw '()
                                 (make-posn 9 9))
              '())
                    

;;; tetra-rotate-ccw : Tetra -> Tetra
;;; rotates a Tetra counterclockwise around its center


(define (tetra-rotate-ccw tetra)
  (make-tetra (tetra-center tetra)
              (bricks-rotate-ccw (tetra-bricks tetra)
                                 (tetra-center tetra))))

(check-expect (tetra-rotate-ccw
               (make-tetra
                (make-posn 5 15)
                (list (make-brick 5 14 "purple")
                      (make-brick 6 14 "purple"))))
              (make-tetra
               (make-posn 5 15)
               (bricks-rotate-ccw
                (list (make-brick 5 14 "purple")
                      (make-brick 6 14 "purple"))
                (make-posn 5 15))))
(check-expect (tetra-rotate-ccw TETRA-L)
              (make-tetra
               (make-posn 4 18)
               (list (make-brick 4 18 "purple")
                     (make-brick 3 19 "purple")
                     (make-brick 4 19 "purple")
                     (make-brick 4 17 "purple"))))


;;; brick-rotate-cw : Brick Pt -> Brick
;;; rotates the Brick clockwise around the point


(define (brick-rotate-cw brick pt)
  (brick-rotate-ccw
   (brick-rotate-ccw
    (brick-rotate-ccw brick pt) pt) pt))

(check-expect (brick-rotate-cw (make-brick 4 8 "cyan")
                               (make-posn 5 10))
              (make-brick 3 11 "cyan"))
(check-expect (brick-rotate-cw (make-brick 6 6 "purple")
                               (make-posn 6 6))
              (make-brick 6 6 "purple"))


;;; bricks-rotate-cw : Bricks Pt -> Bricks
;;; rotates each Brick clockwise around the point


(define (bricks-rotate-cw bricks pt)
  (cond [(empty? bricks) '()]
        [else (cons (brick-rotate-cw (first bricks) pt)
                    (bricks-rotate-cw (rest bricks) pt))]))

(check-expect (bricks-rotate-cw '() (make-posn 5 5))
              '())
(check-expect (bricks-rotate-cw
               (list (make-brick 2 14 "blue")
                     (make-brick 3 14 "blue")
                     (make-brick 3 15 "blue"))
               (make-posn 5 15))
              (list (make-brick 4 18 "blue")
                    (make-brick 4 17 "blue")
                    (make-brick 5 17 "blue")))


;;; tetra-rotate-cw : Tetra -> Tetra
;;; rotates the Tetra clockwise around its center


(define (tetra-rotate-cw tetra)
  (make-tetra (tetra-center tetra)
              (bricks-rotate-cw (tetra-bricks tetra)
                                (tetra-center tetra))))

(check-expect (tetra-rotate-cw
               (make-tetra
                (make-posn 5 15)
                (list (make-brick 5 14 "purple")
                      (make-brick 6 14 "purple"))))
              (make-tetra (make-posn 5 15)
                          (list (make-brick 4 15 "purple")
                                (make-brick 4 14 "purple"))))
(check-expect (tetra-rotate-cw TETRA-Z)
              (make-tetra
               (make-posn 4 18)
               (list (make-brick 4 18 "pink")
                     (make-brick 5 18 "pink")
                     (make-brick 4 17 "pink")
                     (make-brick 5 19 "pink"))))
 

;;; brick-fall : Brick -> Brick
;;; moves the Brick down one cell


(define (brick-fall brick)
  (make-brick (brick-x brick)
              (- (brick-y brick) 1)
              (brick-color brick)))

(check-expect (brick-fall (make-brick 6 16 "blue"))
              (make-brick 6 15 "blue"))
(check-expect (brick-fall (make-brick 6 1 "blue"))
              (make-brick 6 0 "blue"))


;;; - bricks-fall : Bricks -> Bricks
;;;   moves each Brick from the Bricks down one cell


(define (bricks-fall bricks)
  (cond [(empty? bricks) '()]
        [else (cons (brick-fall (first bricks))
                    (bricks-fall (rest bricks)))]))


(check-expect (bricks-fall (list (make-brick 6 10 "red")
                                 (make-brick 9 18 "purple")
                                 (make-brick 3 11 "green")))
              (list (make-brick 6 9 "red")
                    (make-brick 9 17 "purple")
                    (make-brick 3 10 "green")))
(check-expect (bricks-fall '()) '())


;;; - tetra-fall : Tetra -> Tetra
;;;   moves the Bricks and the rotational point down one cell


(define (tetra-fall tetra)
  (make-tetra (make-posn (posn-x (tetra-center tetra))
                         (- (posn-y (tetra-center tetra)) 1))
              (bricks-fall (tetra-bricks tetra))))


(check-expect (tetra-fall (make-tetra (make-posn 4 18)
                                      (list (make-brick 4 10 "cyan")
                                            (make-brick 6 14 "blue"))))
              (make-tetra (make-posn 4 17)
                          (list (make-brick 4 9 "cyan")
                                (make-brick 6 13 "blue"))))
(check-expect (tetra-fall (make-tetra (make-posn 3 10) '()))
              (make-tetra (make-posn 3 9) '()))


;;; brick-move-left : Brick -> Brick
;;; moves the Brick to the left one cell


(define (brick-move-left brick)
  (cond [(= (brick-x brick) 0)
         brick]
        [else (make-brick (- (brick-x brick) 1)
                          (brick-y brick)
                          (brick-color brick))]))

(check-expect (brick-move-left (make-brick 5 15 "green"))
              (make-brick 4 15 "green"))
(check-expect (brick-move-left (make-brick 1 15 "green"))
              (make-brick 0 15 "green"))


;;; bricks-move-left : Bricks -> Bricks
;;; moves each Brick in the Bricks to the left one cell


(define (bricks-move-left bricks)
  (cond [(empty? bricks) '()]
        [else (cons (brick-move-left (first bricks))
                    (bricks-move-left (rest bricks)))]))

(check-expect (bricks-move-left (list (make-brick 6 14 "pink")
                                      (make-brick 3 10 "green")
                                      (make-brick 8 8 "orange")))
              (list (make-brick 5 14 "pink")
                    (make-brick 2 10 "green")
                    (make-brick 7 8 "orange")))
(check-expect (bricks-move-left '()) '())


;;; tetra-move-left : Tetra -> Tetra
;;; moves a Tetra and its center to the left one cell


(define (tetra-move-left tetra)
  (make-tetra (make-posn (- (posn-x (tetra-center tetra)) 1)
                         (posn-y (tetra-center tetra)))
              (bricks-move-left (tetra-bricks tetra))))

(check-expect (tetra-move-left (make-tetra
                                (make-posn 5 5)
                                (list (make-brick 7 8 "blue")
                                      (make-brick 4 9 "orange"))))
              (make-tetra (make-posn 4 5)
                          (list (make-brick 6 8 "blue")
                                (make-brick 3 9 "orange"))))
(check-expect (tetra-move-left
               (make-tetra (make-posn 4 8)
                           '()))
              (make-tetra (make-posn 3 8)
                          '()))


;;; brick-move-right : Brick -> Brick
;;; moves the Brick to the right one cell


(define (brick-move-right brick)
  (cond [(= (brick-x brick) (- BOARD-WIDTH 1))
         brick]
        [else (make-brick (+ (brick-x brick) 1)
                          (brick-y brick)
                          (brick-color brick))]))

(check-expect (brick-move-right (make-brick 6 12 "purple"))
              (make-brick 7 12 "purple"))
(check-expect (brick-move-right (make-brick 9 12 "purple"))
              (make-brick 9 12 "purple"))


;;; bricks-move-right : Bricks -> Bricks
;;; moves each Brick to the right one cell


(define (bricks-move-right bricks)
  (cond [(empty? bricks) '()]
        [else (cons (brick-move-right (first bricks))
                    (bricks-move-right (rest bricks)))]))

(check-expect (bricks-move-right (list (make-brick 6 14 "pink")
                                       (make-brick 3 10 "green")
                                       (make-brick 8 8 "orange")))
              (list (make-brick 7 14 "pink")
                    (make-brick 4 10 "green")
                    (make-brick 9 8 "orange")))
(check-expect (bricks-move-right '()) '())


;;; tetra-move-right :
;;; moves a Tetra and its center to the right one cell


(define (tetra-move-right tetra)
  (make-tetra (make-posn (+ (posn-x (tetra-center tetra)) 1)
                         (posn-y (tetra-center tetra)))
              (bricks-move-right (tetra-bricks tetra))))

(check-expect (tetra-move-right (make-tetra
                                 (make-posn 5 5)
                                 (list (make-brick 7 8 "blue")
                                       (make-brick 4 9 "orange"))))
              (make-tetra (make-posn 6 5)
                          (list (make-brick 8 8 "blue")
                                (make-brick 5 9 "orange"))))
(check-expect (tetra-move-right
               (make-tetra (make-posn 4 8)
                           '()))
              (make-tetra (make-posn 5 8)
                          '()))
 

;;; number->tetra : NumberN -> Tetra
;;; produces a tetra given a number 

;;; a NumberN is one of: 0,1,2,3,4,5,6


(define (number->tetra n)
  (cond [(= n 0) TETRA-O]
        [(= n 1) TETRA-I]
        [(= n 2) TETRA-L]
        [(= n 3) TETRA-J]
        [(= n 4) TETRA-T]
        [(= n 5) TETRA-Z]
        [(= n 6) TETRA-S]))


(check-expect (number->tetra 0)
              TETRA-O)
(check-expect (number->tetra 4)
              TETRA-T)


;;; Constant definition for the initial world:
(define INITIAL-WORLD (make-world (number->tetra (random 7))
                                  '()))


;;; new-random-tetra : World -> World
;;; add a new random tetra to an existing world


(define (new-random-tetra world)
  (make-world (number->tetra (random 7))
              (world-pile world)))

(check-random (new-random-tetra
               (make-world
                (make-tetra (make-posn 5 5)
                            '()) '()))
              (make-world
               (number->tetra (random 7)) '()))
(check-random (new-random-tetra
               (make-world
                TETRA-S '()))
              (make-world
               (number->tetra (random 7)) '()))


;;; KEY HANDLER:
;;; World KE -> World


(define (key-handler world ke)
  (cond [(and (key=? "left" ke) (not (too-far-left? (world-tetra world))))
         (make-world (tetra-move-left (world-tetra world))
                     (world-pile world))]
        [(and (key=? "right" ke) (not (too-far-right? (world-tetra world))))
         (make-world (tetra-move-right (world-tetra world))
                     (world-pile world))]
        [(key=? "s" ke)
         (make-world (tetra-rotate-cw (world-tetra world))
                     (world-pile world))]
        [(key=? "a" ke)
         (make-world (tetra-rotate-ccw (world-tetra world))
                     (world-pile world))]
        [else world]))


(check-expect (key-handler
               (make-world
                (make-tetra
                 (make-posn 7 10)
                 (list (make-brick 4 15 "green")
                       (make-brick 5 15 "green"))) '())
               "left")
              (make-world
               (make-tetra
                (make-posn 6 10)
                (list (make-brick 3 15 "green")
                      (make-brick 4 15 "green"))) '()))
(check-expect (key-handler
               (make-world
                (make-tetra
                 (make-posn 7 10)
                 (list (make-brick 4 15 "green")
                       (make-brick 5 15 "green"))) '())
               "right")
              (make-world
               (make-tetra
                (make-posn 8 10)
                (list (make-brick 5 15 "green")
                      (make-brick 6 15 "green"))) '()))
(check-expect (key-handler
               (make-world
                (make-tetra
                 (make-posn 5 10)
                 (list (make-brick 4 15 "green")
                       (make-brick 5 15 "green"))) '())
               "s")
              (make-world
               (make-tetra
                (make-posn 5 10)
                (list (make-brick 10 11 "green")
                      (make-brick 10 10 "green"))) '()))
(check-expect (key-handler
               (make-world
                (make-tetra
                 (make-posn 5 10)
                 (list (make-brick 4 15 "green")
                       (make-brick 5 15 "green"))) '())
               "a")
              (make-world
               (make-tetra
                (make-posn 5 10)
                (list (make-brick 0 9 "green")
                      (make-brick 0 10 "green"))) '()))


;;; next world : World -> World
;;; makes the next world 


(define (next-world world)
  (cond [(tetra-collide? world)
         (make-world (world-tetra (new-random-tetra world))
                     (cons
                      (first (tetra-bricks (world-tetra world)))
                      (cons (first (rest (tetra-bricks
                                          (world-tetra world))))
                            (cons (first (rest (rest (tetra-bricks
                                                      (world-tetra world)))))
                                  (cons (first (rest (rest (rest (tetra-bricks
                                                                  (world-tetra world))))))
                                        (world-pile world))))))]
        [else (make-world (tetra-fall (world-tetra world))
                          (world-pile world))]))


(check-expect (next-world
               (make-world
                (make-tetra
                 (make-posn 4 1)
                 (list (make-brick 5 1 "red")
                       (make-brick 4 1 "red"))) '()))
              (make-world
               (make-tetra
                (make-posn 4 0)
                (list (make-brick 5 0 "red")
                      (make-brick 4 0 "red")))
               '()))


;;; world->image : World -> Image
;;; displays an image of a World


(define (world->image world)
  (tetra+scene (world-tetra world)
               (cond [(empty? (world-pile world))
                      (bricks+scene (world-pile world)
                                    BOARD)]
                     [else (bricks+scene (world-pile world)
                                         BOARD)])))

(check-expect (world->image
               (make-world
                TETRA-Z '()))
              (tetra+scene TETRA-Z
                           BOARD))
(check-expect (world->image
               (make-world
                TETRA-L
                (list (make-brick 5 0 "blue")
                      (make-brick 6 0 "blue"))))
              (tetra+scene TETRA-L
                           (bricks+scene
                            (list (make-brick 5 0 "blue")
                                  (make-brick 6 0 "blue"))
                            BOARD)))


;;; game-over? : World -> Boolean
;;; has the pile reached the top of the board?


(define (game-over? world)
  (cond [(empty? (world-pile world)) #f]
        [(>= (brick-y (first (world-pile world)))
             (- BOARD-HEIGHT 1)) #t]
        [else (game-over? (make-world
                           (make-tetra
                            (tetra-center (world-tetra world))
                            (tetra-bricks (world-tetra world)))
                           (rest (world-pile world))))]))

(check-expect (game-over?
               (make-world TETRA-O '())) #f)
(check-expect (game-over?
               (make-world TETRA-J
                           (list
                            (make-brick 5 10 "red")
                            (make-brick 6 10 "red")))) #f)
(check-expect (game-over?
               (make-world TETRA-I
                           (list
                            (make-brick 6 18 "pink")
                            (make-brick 6 19 "pink")))) #t)


;;; count-bricks: Bricks -> Natural
;;; the number of individual Bricks on the board


(define (count-bricks pile)
  (cond [(empty? pile) 0]
        [else (+ 1 (count-bricks (rest pile )))]))

(check-expect (count-bricks '()) 0)
(check-expect (count-bricks (cons
                             (make-brick 4 19 "blue")
                             (cons
                              (make-brick 5 19 "blue")
                              (cons
                               (make-brick 6 19 "blue")
                               (cons
                                (make-brick 3 19 "blue") '()))))) 4)


;;; score-screen : World -> Image
;;; displays the score (number of bricks) on the screen


(define (score-screen world)
  (place-image
   (text (string-append "Score: "
                        (number->string (count-bricks
                                         (world-pile world))))
         24 "red") 150 100 BOARD))

(check-expect (score-screen (make-world (number->tetra (random 7))
                                        '()))
              (place-image (text "Score: 0" 24 "red") 150 100 BOARD))
(check-expect (score-screen (make-world (number->tetra (random 7))
                                        (cons
                                         (make-brick 4 19 "blue")
                                         (cons
                                          (make-brick 5 19 "blue")
                                          (cons
                                           (make-brick 6 19 "blue")
                                           (cons
                                            (make-brick 3 19 "blue") '()))))))
              (place-image (text "Score: 4" 24 "red") 150 100 BOARD))



(big-bang INITIAL-WORLD
  [on-tick next-world TICK-RATE]
  [to-draw world->image]
  [on-key key-handler]
  [stop-when game-over? score-screen])
