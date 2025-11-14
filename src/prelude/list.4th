: :r "/home/kolay/prog/gforth/src/prelude/list.4th" included ;

\ *** ============================== TUPLE ============================== *** \

: cons ( a b -- <a,b> )
  2 cells allocate throw \ a b adr ( alloc 2 cells of memory )
  >r      \ a b |R: adr
  r@      \ a b adr
  cell+ ! \ a ( save b to adr+ )
  r@      \ a adr
  !       \ _ ( save a to adr )
  r>      \ adr |R: _
;
\ \ ПОЯСНЕНИЕ Создаём узел в куче (через allocate)
\   2 cells allocate throw \ next-addr value new-addr
\   \ выделяем 2 ячейки памяти; allocate :: ( u -- a_addr wior )
\   \ где addr — адрес выделенной памяти (если всё прошло успешно); wior — I/O result code — код ошибки (I/O result, по стандарту Forth).
\   \ если на стеке wior = 0 thow не делает ничего, иначе выбрасывает ошибку с кодом wior
\ cell+ ( a-addr1 -- a-addr2 ) 
: car ( <a,b> -- a ) @ ;
: cdr ( <a,b> -- b ) cell+ @ ;

\ USAGE:
1 2 cons constant x
3 4 cons constant y
x y cons constant z
\ x car -- 1
\ x cdr -- 2
\ z car car -- 1
\ z cdr car -- 3




       

\ *** ============================== LIST ============================== *** \

\ Создаём узел в куче (через allocate)
\ USAGE: 0 17 node || head 27 node
: node ( next-node value -- addr )
  2 cells allocate throw    \ next-node val adr ( выделяем 2 ячейки памяти )
  >r                        \ next-node val |R: adr ( сохраняем адрес в R-стек )
  r@                        \ next-node val adr
  !                         \ next-node ( записываем value )
  r@                        \ next-node adr
  cell+ !                   \ _ ( записываем next в adr+ )
  r> ;                      \ adr |R: _ ( вернуть адрес узла )
\ \ ПОЯСНЕНИЕ Создаём узел в куче (через allocate)
\   2 cells allocate throw \ next-addr value new-addr
\   \ выделяем 2 ячейки памяти; allocate :: ( u -- a_addr wior )
\   \ где addr — адрес выделенной памяти (если всё прошло успешно); wior — I/O result code — код ошибки (I/O result, по стандарту Forth).
\   \ если на стеке wior = 0 thow не делает ничего, иначе выбрасывает ошибку с кодом wior
\ cell+ ( a-addr1 -- a-addr2 ) 

: value@ ( addr -- n ) @ ;
: next@  ( addr -- addr' ) cell+ @ ;



\ USAGE: 66 head5 append constant head6 
: append ( value next-head-addr -- addr )
  swap \ next-head-addr value
  node
;

: tail ( head-addr -- tail-addr value )
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

: .show-list dup show-list ;


\ USAGE: head5 clone constant head5clone
: clone ( adr -- new-adr )
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


\ USAGE: head reverse constant head-rev
: reverse ( adr -- new-adr )
  0 >r \ put zero adress to r-stack for new result list
  begin
    dup 0<> \ adr (adr!=0)
  while
    dup \ adr adr
    value@ \ adr val
    r> \ adr val node-next
    swap \ adr node-next val
    node \ adr node-next'
    >r \ adr
    next@
  repeat \ adr
  drop \ _
  r> \ node-next  
;


\ USAGE: : inc ( w -- w ) 1 + ; ' inc head map || head5 reverse ' inc swap map show-list
: map ( xt adr -- adr-new )
  0 >r ( put zero adress to r-stack )
  begin
    dup 0<> \ xt adr (adr!=0)
  while \ xt adr
    2dup \ xt adr xt adr
    value@ \ xt adr xt val
    swap \ xt adr val xt
    execute \ xt adr f(val)
    r> \ xt adr f(val) next-node
    swap \ xt adr next-node f(val)
    node \ xt adr next-node'
    >r \ xt adr
    next@ \ xt adr'
  repeat \ xt adr
  drop drop \ _
  r> \ adr-new
  reverse
;


\ USAGE: : predicate ( w -- bool ) 25 > ; ' predicate head5 filter show-list
: filter ( xt vec -- vec )
  ( xt :: x -> bool, vec :: list )
  0 >r \ put zero adress to r-stack
  begin
    dup 0<> \ xt vec (vec!=0)
  while \ xt vec
    2dup \ xt vec xt vec
    value@ \ xt vec xt val
    swap \ xt vec val xt
    execute \ xt vec predicate(val)
    if \ xt vec
      dup \ xt vec vec
      r> \ xt vec vec next-node
      swap \ xt vec next-node vec
      value@ \ xt vec next-node val
      node \ xt vec next-node'
      >r \ xt vec
    else
    then
    next@ \ xt vec'
  repeat \ xt vec'
  drop drop \ _
  r> \ vec'
  reverse
;



\ USAGE: ' - 0 head foldl
: foldl ( xt initial vec -- val )
  ( xt :: acc -> val -> acc)
  rot \ initial vec xt
  >r \ initial vec |R: xt
  begin \ acc vec
    dup 0<> \ acc vec (vec<>0)
  while \  acc vec |R: xt
    tuck \ vec acc vec
    value@ \ vec acc val
    r@ \ vec acc val xt |R: xt
    execute \ vec acc'
    swap \ acc' vec
    next@ \ acc' vec'
  repeat
  r> \ acc' vec' xt
  drop drop \ acc'
;

    
: zip-with-sub-check-next ( v1 v2 -- bool )
    0<>  \ v1 (v2<>0)
    swap \ (v2<>0) v1
    0<>  \ (v2<>0) (v1<>0)
    and  \ (v2 !=0 && v1 != 0)
;

: zip-with-sub-get-values ( v1 v2 -- x1 x2 )
    value@ \ v1 v2 v1 v2-val
    swap \ v1 v2 v2-val v1
    value@ \ v1 v2 v2-val v1-val
    swap \ v1 v2 v1-val v2-val
;

: zip-with-sub-get-next ( v1 v2 -- adr1 adr2 )
    next@ \ v1 v2'
    swap \ v2' v1
    next@ \ v2' v1'
    swap \ v1' v2'
;

\ USAGE: ' + vec1 head5 zip-with constant vs 
: zip-with ( xt v1 v2 -- list )
  \ xt :: v1 v2 -> v
  rot \ v1 v2 xt
  >r \ v1 v2 |R: xt
  0 >r \ v1 v2 |R: xt 0
  begin \ v1 v2
    2dup \ v1 v2 v1 v2
    zip-with-sub-check-next \ v1 v2 bool
  while \ v1 v2
    2dup \ v1 v2 v1 v2
    zip-with-sub-get-values \ v1 v2 v1-val v2-val
    r> \ v1 v2 v1-val v2-val next-node |R: xt
    -rot \ v1 v2 next-node v1-val v2-val |R: xt
    r@ \ v1 v2 next-node v1-val v2-val xt |R: xt
    execute \ v1 v2 next-node f(v1,v2)
    node \ v1 v2 next-node'
    >r \ v1 v2 |R: xt next-node'
    zip-with-sub-get-next
  repeat \ v1 v2
  drop drop \ _ |R: xt next-node'
  r> r> \ next-node' xt |R: _
  drop \ next-node'
  reverse \ next-node'
;



\ *** ============================== EXAMPLE ============================== *** \

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

0 10  node 20  node 30  node constant vec1
0 100 node 200 node 300 node constant vec2
0 -1 node constant vec-zero


: inc ( w -- w ) 1 + ;
: predicate ( w -- bool ) 25 > ;


