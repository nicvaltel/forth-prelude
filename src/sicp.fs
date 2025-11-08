: r "/home/kolay/prog/gforth/src/sicp.fs" included ;


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

: f2dup ( x y -- x y x y )
  fover ( x y -- x y x )
  fswap ( x y -- x x y )
  fdup \ x x y -- x x y y  
  f-rot \ x x y y -- x y y x
  \ frot \ x y y x -- x y x y
;

: f-sub-sqrt-mean ( guess x -- c)
  fswap \ x guess
  fdup \ x guess guess
  frot \ guess guess x
  fswap
  f/ \ guess x/guess
  f+ \ (x + x/guess)
  2e0 f/ \ (x + x/guess)/2
;
  
  

: f-sqrt-iter ( guess x -- y ) recursive
  f2dup \ guess x guess x
  fswap \ guess x x guess
  fdup \ guess x x guess guess
  f* \ guess x x guess^2  
  f- \ guess x (x - guess^2)
  fabs \ guess x |abs (x - guess^2) |
  1e-6 \ guess x |abs (x - guess^2) | 1e-6
  f< \ guess x (|abs (guess - x) | < 1e-6)
  if
  fdrop
  else \ guess x
  fswap \ x guess
  fover \ x guess x
  f-sub-sqrt-mean \ x newGuess
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
  

  	    
  
  