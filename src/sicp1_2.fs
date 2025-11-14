: :r "/home/kolay/prog/gforth/src/sicp1_2.fs" included ;



: sub-factorial ( acc n -- acc ) recursive
  dup \ acc n n 
  1 <= \ acc n (n <= 1)
  if \ acc n
    drop \ acc
  else \ acc n
    tuck \ n acc n
    * \ n acc*n
    swap \ acc*n n
    1 - \ acc*n (n-1)
    sub-factorial
  then
;

: factorial ( n -- n )
  1
  swap
  sub-factorial
;

  
\ 0 1 1 2 3 5
\ fib(0)=0
\ fib(1)=1
\ fib(n) = fib(n-1) + fib(n-2)


: fib-slow ( n -- n ) recursive
  dup \ n n
  1 <= \ n bool
  if \ n
    1 = \ bool
    if \ _
      1
    else \ _
      0 \ when n = 0 or negative number => f(n) = 0
    then 
  else \ n
    dup \ n n
    1 - \ n (n-1)
    swap \ (n-1) n
    2 - \ (n-1) (n-2)
    fib-slow \ (n-1) fib(n-2)
    swap \ fib(n-2) (n-1)
    fib-slow \ fib(n-2) fib(n-1)
    + \ result = (fib(n-2) + fib(n-1))
  then
;


: fib-sub ( f'' f' c -- n ) recursive
  \ f'' = f(c-2) ; f'=f(c-1) ;  c = currentNumber (descending at 1 every call of fib-sub)
  dup \ f'' f' c c
  2 = \ f'' f' c (c==2)
  if \ f'' f' c
    drop \ f'' f'
    + \ result = f'' + f' (e.g. c = 2 => f(c) = 0 + 1)
  else
    1 - \ f'' f' (c-1)
    -rot \ (c-1) f'' f'
    dup \ (c-1) f'' f' f'
    rot \ (c-1) f' f' f''
    + \ (c-1) f' (f'+f'')
    rot \ f' (f'+f'') (c-1)
    fib-sub
  then
;


: fib ( n -- n )
  dup \ n n
  1 <= \ n bool
  if \ n
    1 = \ bool
    if \ _
      1
    else \ _
      0 \ when n = 0 or negative number => f(n) = 0
    then 
  else \ n
    0 1 \ n 0 1
    rot \ 0 1 n
    fib-sub
  then
;



: show-fib ( n -- )
  1 + \ (n+1)
  0 swap \ 0 (n+1)
  0 \ 0 (n+1) 0
  do \ 0 ( loop from 0 to n+1 )
    dup dup \ i i i
    cr
    ." fib( "
    . \ i i
    ." ) = "
    fib \ i fib(i)
    . \ i
    1 + \ (i+1)
  loop
  cr
;


\ *** ======================= 100 cents ======================= *** \

: coins-sub-clear-coins-list ( -1 c1 ... cn -- ) recursive
  -1 = \ -1 c1 c2 ... cn (cn==-1)
  if \ _
    \ stack is empty as far cn was only element
  else \ -1 c1 c2 ... c_n-1
    coins-sub-clear-coins-list
  then 
;



: coins-sub-list-length ( -1 c1 ... cn -- -1 c1 ... cn len ) recursive
  dup
  -1 =
  if \ -1
    0 \ -1 0
  else
    >r \ -1 c1 ... cn-1 
    coins-sub-list-length \ -1 c1 ... cn-1 len
    1 + \ \ -1 c1 ... cn-1 (len+1)
    r>
    swap
  then
;

: coins-sub-dup-arguments ( )
			  \ TODO Implement
;


: coins ( -1 c1 c2 ... cn mon -- numberOfWays ) recursive
	\ -1 means end of list of coins ( as far as all coins are positive numbers )
  dup \ -1 c1 c2 ... cn mon mon
  0 = \ -1 c1 c2 ... cn mon (mon = 0)
  if \ -1 c1 c2 ... cn mon
    \ mon = 0 so we found 1 way to change sum of money
    coins-sub-clear-coins-list
    1 \ 1 = result
  else
    over \ -1 c1 c2 ... cn mon cn
    -1 = \ -1 c1 c2 ... cn mon (cn==-1)
    if \ -1 mon
      \ list of conis is empty
      drop drop 0 \ 0
      \ zero ways to change
    else
      2dup \ -1 c1 c2 ... cn money cn money
      > \ -1 c1 c2 ... cn money (cn > money)
      if \ -1 c1 c2 ... cn money
	swap \ -1 c1 c2 ... cn-1 money cn
	drop \ c1 c2 .. cn-1 money
	coins \ new recursive step without cn
      else \ -1 c1 c2 ... cn money
	\ implement Q( cs mon) = Q( cs (mon - head(cs)) ) + Q( cs\head mon )
	coins-sub-dup-arguments
      then	
    then  
  then    
;




\ *** ======================= LIST =================== *** \


: my-list ( w1 ... wn len -- w1 ... wn len )
;

: my-list-head ( w1 .. wn len -- w1 ... wn-1 len-1 wn )
  1 -
  swap
;


: my-list-tail ( w1 .. wn len -- w1 ... wn-1 len-1 wn )
  1 -
  swap
  drop
;

: my-list-recursive ( w1 ... wn len -- wn ... w1 len )
  
;


