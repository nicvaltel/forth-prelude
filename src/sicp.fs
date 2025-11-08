: :r "/home/kolay/prog/gforth/src/sicp.fs" included ;


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

: func1 ( x -- f )
  \ ( f = [x + 1]^2 + [2 * x]^2 )
  dup
  1 +
  swap
  2 *
  sum-of-squares
;

\ 0 = False -1 = True; any not zero number = True
: my-abs ( x -- |x| )
  dup
  0 >
  if
  else negate
  then
;

: my-geq-stupid ( x y -- boolean )
  -
  dup
  0 >
  swap
  0 =
  or
;


\ invert is logical not: -1 invert = 0 ; 0 invert = -1
: my-geq-smart ( x y -- boolean )
  -
  0 <
  invert
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
  fover ( r1 r2 r3 -- r1 r2 r3 r2)
  fover ( r1 r2 r3 r2 -- r1 r2 r3 r2 r3)
;
  


: f-sqrt-iter-sub-new-guess ( guess x -- c )
  fover \ guess x guess
  f/ \ guess x/guess
  f+ \ (x + x/guess)
  2e0 f/ \ (x + x/guess)/2
;

: f-sqrt-iter-sub-res ( x guess -- |x - guess^2| )
  f* \ x guess^2
  f- \ x - guess^2
  fabs
;


: f-sqrt-iter ( guess x -- y ) recursive
  \ ( y = sqrt (x) usage: 1e0 2e0  f-sqrt-iter f. )
  f2dup \ guess x guess x
  fswap \ guess x x guess
  
  fdup \ guess x x guess guess
  f-sqrt-iter-sub-res \ guess x |abs (x - guess^2) |

  1e-6 \ guess x |abs (x - guess^2) | 1e-6
  f< \ guess x (|abs (guess^2 - x) | < residLevel)
  if \ guess x
  fdrop \ clear x in stack
  else \ guess x
  ftuck \ x guess x
  f-sqrt-iter-sub-new-guess \ x newGuess
  fswap \ newGuess x
  f-sqrt-iter
  then
;

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

