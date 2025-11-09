: :r "/home/kolay/prog/gforth/src/sicp1.fs" included ;

: square ( n -- n )
  dup
  *
;

: sum-of-squares ( x y -- z )
  ( z = x^2 + y^2 )
  square
  swap
  square
  +
;

: 3dup ( w1 w2 w3 -- w1 w2 w3 w1 w2 w3 )
  >r ( 1 2 | R: 3 )
  2dup ( 1 2 1 2 | R: 3 )
  r@ ( 1 2 1 2 3 | R: 3 )
  -rot ( 1 2 3 1 2 | R: 3 )
  r> ( 1 2 3 1 2 3 )
;

: 4dup ( w1 w2 w3 w4 -- w1 w2 w3 w4 w1 w2 w3 w4 )
  >r ( 1 2 3 | R: 4 )
  >r ( 1 2 | R: 4 3 )
  2dup ( 1 2 1 2 | R: 4 3 )
  2r@ ( 1 2 1 2 4 3 | R: 4 3 )
  swap ( 1 2 1 2 3 4 | R: 4 3 )
  2swap ( 1 2 3 4 1 2 | R: 4 3 )
  r>
  r> ( 1 2 3 4 1 2 3 4)
;  
  
: f2dup ( x y -- x y x y )
  fover ( x y -- x y x )
  fswap ( x y -- x x y )
  fdup \ x x y -- x x y y  
  f-rot \ x x y y -- x y y x
  \ frot \ x y y x -- x y x y
;


: f3dup ( r1 r2 r3 -- r1 r2 r3 r1 r2 r3 )
  fthird \ 1 2 3 1
  fthird \ 1 2 3 1 2
  fthird \ 1 2 3 1 2 3
;

: fsquare ( r -- r )
  fdup
  f*
;

: f-n-pow ( r w -- r )
  \ ( x n -- x^n)
  1 - \ n = n-1
  fdup   \ |F x x
  0 do  \ |F x x^(n-1)
    fover \ |F x x^(n-1) x
    f*  \ |F x x^n    
  loop
  fswap \ x^n x
  fdrop \ x^n
;

: faverage ( r1 r2 -- rAverage )
  \ rAverage = (r1 + r2) / 2
  f+
  2e0
  f/
;


\ ============ F-SOLVER ============ \



: f-solver ( xt xt guess x -- y ) recursive
	   \ ( checker improver guess x) y = sqrt(x) USAGE: ' f-sqrt-checker ' f-sqrt-improver 1e0 2e0 f-solver f.
	   \ UGAGE for cube root: ' f-3h-root-checker ' f-3th-root-improver 1e0 2e0 f-solver f.
	   \ USAGE 1) 1e-10  make-f-sqrt-checker checker 2) ' checker ' f-sqrt-improver 1e0 2e0 f-solver f.  !!! WARNING ": checker 1e-6 make-f-sqrt-checker ;" Is incorrect using
  over \ checker improver checker |F guess x
  f2dup \ checker improver checker improver |F guess x guess x
  EXECUTE \ checker improver bool |F guess x
  if \ checker improver |F guess x
    drop drop \ _ | F guess x
    fdrop \ _ |F guess
  else \ checker improver |F guess x
    ftuck \ checker improver |F x guess x
    dup \ checker improver improver | F x guess x
    EXECUTE \ checker improver |F x newGuess
    fswap \ checker improver |F newGuess x
    f-solver
  then
;  


\ ============ Square root ============ \

: f-sqrt-improver ( guess x -- newGuess )
  fover \ guess x guess
  f/ \ guess x/guess
  faverage \ newGuess = (guess + x/guess)/2
;

: f-sqrt-good-enough? ( residLevel guess x -- bool )
  fswap \ residLevel x guess
  fsquare \ residLevel x guess^2
  f- \ residLevel (x - guess^2)
  fabs \ residLevel |x - guess^2|
  f> \ bool = residLevel > |x - guess^2|
;

: f-sqrt-checker ( guess x -- bool )
  1e-6 \ guess x residLevel
  f-rot \ residLevel guess x
  f-sqrt-good-enough?
;

: make-f-sqrt-checker ( residLevel -- xt )
  \ USAGE: 1e-10  make-f-sqrt-checker checker
  \ !!! INCORRECT USAGE ": sqrt-checker-1e-6 1e-6 make-f-sqrt-checker ;" \ stack will be changed after this definition
  
  CREATE f, \ CREATE создаёт новое слово (например, sqrt-checker-1e-6). \ , записывает текущее residLevel в память по адресу HERE. (compile-time operations)
  DOES> ( guess x -- bool ) \ Когда это слово потом вызовут, DOES> получает этот адрес в виде аргумента. (run-time operations) ;
    f@ \ guess x residLevel \ F@ читает число (точность) из этого места памяти.
    f-rot \ residLevel guess x
    f-sqrt-good-enough?
;



\ ============ 3-th root ============ \

: f-3th-root-improver ( guess x -- newGuess )
  fover \ y x y
  fsquare \ y x y^2
  f/ \ y (x/y^2)
  fswap \ (x/y^2) y
  fdup \ (x/y^2) y y
  f+ \ (x/y^2) 2y
  f+ \ (x/y^2 + 2y)
  3e0 \ (x/y^2 + 2y) 3
  f/ \ (x/y^2 + 2y)/3
;

: f-3th-root-good-enough? ( residLevel guess x -- bool )
  fswap \ residLevel x guess
  3 f-n-pow \ residLevel x guess^3
  f- \ residLevel (x - guess^3)
  fabs \ residLevel |x - guess^3|
  f> \ bool = residLevel > |x - guess^3|
;

: f-3h-root-checker ( guess x -- bool )
  1e-6 \ guess x residLevel
  f-rot \ residLevel guess x
  f-3th-root-good-enough?
;


\ ================= PLAYGROUND =============

: my-req ( x -- x ) recursive
  dup
  1 <
  if
  else
  dup
  .
  1 -
  my-req
  then
;





: my-dup ( w -- w w )
  >r  \ _ |R w
  r@ \ w |R w
  r> \ w w 
;

: my-2dup ( w1 w2 -- w1 w2 w1 w2 )
  >r \ 1 |R 2
  >r \ _ |R 2 1
  r@ \ 1 |R 2 1
  r> \ 1 1 |R 2
  r@ \ 1 1 2 |R 2
  swap \ 1 2 1 |R 2
  r> \ 1 2 1 2
;

: my-3dup ( w1 w2 w3 -- w1 w2 w3 w1 w2 w3 )
  >r >r >r \ _ |R 3 2 1
  r@ \ 1 |R 3 2 1
  r> \ 1 1 |R 3 2
  r@ \ 1 1 2 |R 3 2
  swap \ 1 2 1 |R 3 2
  r> \ 1 2 1 2 |R 3
  r@ \ 1 2 1 2 3 |R 3
  -rot \ 1 2 3 1 2 |R 3
  r> \ 1 2 3 1 2 3
;


: say-hello ." Hello!" cr ;
: say-bye ." Bye!" cr ;

: do-twice ( xt -- )
  \ usage: ' say-hello do-twice 
  dup
  EXECUTE
  EXECUTE
;



: my-constant ( n -- )
  \ USAGE: 5 my-constant qqq
  create ,
  does> @
;

: my-closure ( n -- )
  \ USAGE: 18 my-closure fff
  create ,
  does>
  @
  cr
  ." MY-CLOSURE = "
  .
  cr
;

