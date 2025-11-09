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

: faverage ( r1 r2 -- rAverage )
  \ rAverage = (r1 + r2) / 2
  f+
  2e0
  f/
;


\ ============ F-SOLVER ============ \



: f-solver ( xt xt guess x -- y ) recursive
  \ ( checker improver guess x) y = sqrt(x) USAGE: ' f-solver-sqrt-checker ' f-sqrt-improver 1e0 2e0 f-solver f.
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

: f-solver-sqrt-checker ( guess x -- bool )
  1e-6 \ guess x residLevel
  f-rot \ residLevel guess x
  f-sqrt-good-enough?
;

\ ================= Test functions =============

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


