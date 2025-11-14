: :r "/home/kolay/prog/gforth/src/sicp_2_1.fs" included ;

\ *** ============================== PAIRS ============================== *** \

: cons ( x y -- x y ) ;

: dispatch-save ( x y m -- x-or-y )
  dup \ x y m m
  0 = \ x y m (m == 0)
  if \ x y m
    drop \ x y
    over \ x y x
    \ save x y and return x
  else \ x y m
    dup \ x y m m
    1 = \ x y m (m == 1)
    if \ x y m
      drop dup \ x y y
      \ save x y and return y
    else \ x y m
      \ m ! 1 && m != 0 => error
      cr ." argument = "
      . 
      " Error: dispatch-save -- argument is not 0 or 1 -- CONS " THROW
    then    
  then
;


: dispatch ( x y m -- x-or-y )
  dup \ x y m m
  0 = \ x y m (m == 0)
  if \ x y m
    drop drop \ x
    \ return x
  else \ x y m
    dup \ x y m m
    1 = \ x y m (m == 1)
    if \ x y m
      drop swap drop \ y
      \ return y
    else \ x y m
      \ m ! 1 && m != 0 => error
      cr ." argument = "
      . 
      " Error: dispatch-save -- argument is not 0 or 1 -- CONS " THROW
    then    
  then
;

: car 0 dispatch ;
: cdr 1 dispatch ;

: car-save 0 dispatch-save ;
: cdr-save 1 dispatch-save ;




\ *** ============================== LIST ============================== *** \

\ abi-code my+  ( n1 n2 -- n3 )
\   \ SP passed in di, returned in ax,  address of FP passed in si
\   8 di d) ax lea        \ compute new sp in result reg
\   di )    dx mov        \ get old tos
\   dx    ax ) add        \ add to new tos
\   ret
\   end-code

\ Создаём узел в куче (через allocate)
: node ( next-adr value -- addr )
  2 cells allocate throw    \ выделяем 2 ячейки памяти
  dup >r                    \ сохраняем адрес в R-стек
  swap over !               \ записываем value
  cell+ !                   \ записываем next
  r> ;                      \ вернуть адрес узла

\ \ alternative
\ : node ( next value -- addr )
\   2 cells allocate throw  \ next-adr val new-adr
\   -rot    \ new-adr val next-adr
\   third   \ new-adr val next-adr new-adr
\   tuck !  \ new-adr val new-adr 
\   cell+ ! \ new-adr
\ ;                     
\ \ USAGE: 0 10 node constant head1
\ \ USAGE: head1 20 node constant head2
\ \ USAGE 0 10 node 20 node 30 node constant head



\ \ ПОЯСНЕНИЕ Создаём узел в куче (через allocate)
\ : node ( next-addr value -- addr )
  
\   2 cells allocate throw \ next-addr value new-addr
\   \ выделяем 2 ячейки памяти; allocate :: ( u -- a_addr wior )
\   \ где addr — адрес выделенной памяти (если всё прошло успешно); wior — I/O result code — код ошибки (I/O result, по стандарту Forth).
\   \ если на стеке wior = 0 thow не делает ничего, иначе выбрасывает ошибку с кодом wior
  
\   dup \ next-addr value new-addr new-addr  
\   >r  \ next-addr value new-addr 
\   \ сохраняем адрес в R-стек

\   swap \ next-addr new-addr value
\   over \ next-addr new-addr value new-addr
\   ! \ next-addr new-addr
\   \ записываем value;  ! :: ( w a-addr -- )
\   cell+ \ next-addr new-addr+
\   \ cell+ :: ( a-addr1 -- a-addr2 )
\   ! \ _
\   \ записываем next
\   r> \ new-addr
\   \ вернуть адрес узла
\ ;     


: value@ ( addr -- n ) @ ;
: next@  ( addr -- addr' ) cell+ @ ;


0 10 node constant head1 
head1 20 node constant head2 
head2 30 node constant head3
head3 40 node constant head4
head4 50 node constant head5
\ to add: head5 60 node constant head6


0           \ NULL
10 node \ узел со значением 10
20 node \ узел со значением 20
30 node \ узел со значением 30
constant head

\ USAGE: 66 head5 push-list constant head6 
: push-list ( value next-head-addr -- addr )
  swap \ next-head-addr value
  node
;

: pop-list ( head-addr -- tail-addr value )
  dup \ head-addr head-addr
  value@ \ head-addr val
  swap \ val head-addr
  next@ \ val tail-addr
  swap \ tail-addr value
;

  
: show-list ( addr -- )
  begin
    dup 0<>            \ пока адрес не нулевой
  while
    dup value@ .       \ печатаем значение
    next@              \ переходим к следующему
  repeat
  drop ;


\ USAGE: head5 clone-list constant head5clone
: clone-list ( adr -- new-adr )
  0 swap \ 0 adr
  begin
    dup 0<> \ 0 adr
  while
    dup value@ \ 0 adr val
    rot \ adr val 0
    swap \ adr 0 val
    node \ adr new-adr
    swap \ new-adr adr
    next@ \ new-adr adr'
  repeat
  drop \ new-adr
;
\ EXAMPLE:
\  head5 clone-list constant head5clone 
\  head5clone show-list  10 20 30 40 50  ok
\  33 head5 next@ next@ !  ok
\  head5 show-list  50 40 33 20 10  ok
\  head5clone show-list  10 20 30 40 50  ok



: reverse-list-sub ( adr acc -- acc ) recursive
  swap \ acc adr
  dup 0= \ acc adr bool
  if \ acc adr
    \ adr is empty
    drop \ acc
  else \ acc adr
    dup \ acc adr adr
    value@ \ acc adr val
    swap \ acc val adr
    next@ \ acc val adr'
    -rot \ adr' acc val
    node \ adr' acc
    reverse-list-sub
  then
;


\ USAGE: head5 clone-list constant head5rev
: reverse-list ( adr -- new-adr )
  dup 0= \ adr
  if
    \ one element list - return the same
  else \ adr
    dup \ adr adr
    value@ \ adr val
    0 swap \ adr 0 val
    node \ adr acc-adr
    reverse-list-sub
  then
  
;



  
\ *** ============================== COINS ============================== *** \

0 0 node constant zero-list
0 0 node 1 node 5 node 10 node 25 node 50 node constant coins-list
0 0 node 50 node 10 node 5 node 5 node 1 node constant coins-list-rev

\ USAGE: coins-list 100 coins . 292 
: coins ( cs mon -- numberOfWays ) recursive
	\ cs - list of coins empty list contains 0 as value; mon - sum of money in cents
  dup 0= \ cs mon (mon=0)
  if \ cs mon
    \ mon = 0 so we found 1 way to change sum of money
    drop drop \ _
    1 \ 1 = result
  else \ cs mon
    swap \ mon cs
    dup value@ \ mon cs val
    0= \ mon cs (val=0)
    if \ mon cs
      \ list of coins is empty
      drop drop 0 \ 0
      \ zero ways to change
    else \ mon cs
      2dup \ mon cs mon cs
      value@ \ mon cs mon val
      < \ mon cs (mon < val)
      if \ mon cs
	next@ \ mon cs'
	swap \ cs' mon
	coins \ new recursive step without first coin
      else \ mon cs
	\ Q( cs mon) = Q( cs (mon - head(cs)) ) + Q( cs\head mon )
	2dup \ mon cs mon cs
	dup value@ \ mon cs mon cs val
	rot \ mon cs cs val mon
	swap \ mon cs cs mon val
	- \ mon cs cs (mon-val)	
	coins \ mon cs Q1
	\ Q1 = Q( cs, mon - head(cs))
	-rot \ Q1 mon cs

	next@ \ Q1 mon cs'
	swap \ Q1 cs' mon
	coins \ Q1 Q2
	\ Q2 =  Q( cs-next mon )

	+ \ Q1 + Q2 - this is an answer!
      then	
    then  
  then    
;


\ *** ============================== Nth-POWER ============================== *** \

: n-pow ( x n -- y ) recursive
  dup 0= \ x n n==0
  if \ x n
    drop drop 1 \ answer
  else \ x n
    dup \ x n n
    2 mod \ x n (n`mod`2)
    0= \ x n (n`mod`2==0)
    if \ x n
      2 / \ x n/2
      n-pow \ x^(n/2)
      dup * \ x^n :: answer
    else \ x n
      1 - \ x n-1
      over \ x n-1 x
      swap \ x x n-1
      n-pow \ x x^(n-1)
      * \ x^n :: answer    
    then
  then
;





  
