: :r "/home/kolay/prog/forth/src/prelude/list.4th" included ;




\ *** ============================== TUPLE ============================== *** \w

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
\ 1 2 cons constant x
\ 3 4 cons constant y
\ x y cons constant z
\ x car -- 1
\ x cdr -- 2
\ z car car -- 1
\ z cdr car -- 3


: un-cons ( <a,b> -- a b )
  dup  \ <a,b> <a,b>
  car  \ <a,b> a
  swap \ a <a,b>
  cdr  \ a b
;

       

\ *** ============================== LIST ============================== *** \

\ USAGE: 17 0 node || 27 head node
: node ( val tail-adr -- head-adr )  cons ;

: value@ ( addr -- val ) @ ;
: next@  ( addr -- addr' ) cell+ @ ;

: singleton ( val -- list ) 0 node ;

\ USAGE: 66 head5 append constant head6 
\ USAGE 10 singleton 20 append 30 append => 30 : 10 : 20 : []
: append ( list val -- newList ) swap node ;

: tail ( head-addr -- tail-addr )
  next@ \ val tail-addr
;

: head ( head-adr -- val ) value@ ;
: .head ( head-adr -- head-adr val ) dup head ;

: tail-head ( head-adr -- tail-adr head-value )
  dup \ head-adr head-adr
  tail \ head-adr tail-adr
  swap \ tail-adr head-adr
  head \ tail-adr head-val
;

: head-tail ( head-adr -- head-value tail-adr )
  dup  \ head-adr head-adr
  head \ head-adr head-val
  swap \ head-val head-adr
  tail \ head-val tail-adr
;

  
: showl ( addr -- )
  begin
    dup 0<>            \ пока адрес не нулевой
  while
    dup value@ .       \ печатаем значение
    ." : "
    next@              \ переходим к следующему
  repeat
  ." []"
  drop ;

: .showl dup showl ;

\ USAGE: head reverse constant head-rev
: reverse ( adr -- new-adr )
  0 >r \ put zero adress to r-stack for new result list
  begin
    dup 0<> \ adr (adr<>0)
  while \ adr
    .head \ adr val
    r> \ adr val node-next
    node \ adr node-next'
    >r \ adr
    tail \ adr'
  repeat \ adr
  drop \ _
  r> \ node-next  
;


: [[[ 1 ;

: ,, ( n val -- val n+1 )
  swap \ val n
  1 +  \ val n+1
;

\ USAGE: [[[ 1 ,, 2 ,, 3 ]]]
: ]]] ( x ... x_n-1 n xn -- list )
  swap
  0 >r \ x ... xn n |R: list
  begin \ x ... xn n |R: list
    dup 0<>
  while  \ x ... xn n      |R: list
    swap \ x ... n xn      |R: list
    r>   \ x ... n xn list |R: _
    node \ x ... n list'   |R: _
    >r   \ x ... n         |R: list'
    1 -  \ x ... (n-1)     |R: list'
  repeat \ 0 | R: list'
  drop
  r>
;


\ USAGE: head5 clone constant head5clone
: clone ( adr -- new-adr )
  0 >r \ adr |R: new-adr
  begin
    dup 0<> \ adr (adr<>0)
  while \ adr
    .head \ adr val
    r> \ adr val new-adr |R: _
    node \ adr new-adr'
    >r \ adr |R: new-adr'
    tail \ adr'
  repeat \ adr |R: new-adr'
  drop \ _
  r> \ new-adr' |R: _
  reverse
;
\ EXAMPLE:
\  head5 clone-list constant head5clone 
\  head5clone showl  10 20 30 40 50  ok
\  33 head5 next@ next@ !  ok
\  head5 showl  50 40 33 20 10  ok
\  head5clone showl  10 20 30 40 50  ok




\ USAGE: : inc ( w -- w ) 1 + ; ' inc head map || head5 reverse ' inc swap map showl
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
    node \ xt adr next-node'
    >r \ xt adr
    next@ \ xt adr'
  repeat \ xt adr
  drop drop \ _
  r> \ adr-new
  reverse
;


\ USAGE: : predicate ( w -- bool ) 25 > ; ' predicate head5 filter showl
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
      value@ \ xt vec val
      r>     \ xt vec val next-node
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



\ USAGE: ' - 0 head5 foldl
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


: zip-sub-check-next ( v1 v2 -- bool )
    0<>  \ v1 (v2<>0)
    swap \ (v2<>0) v1
    0<>  \ (v2<>0) (v1<>0)
    and  \ (v2 !=0 && v1 != 0)
;

: zip-sub-get-values ( v1 v2 -- x1 x2 )
    value@ \ v1 v2 v1 v2-val
    swap \ v1 v2 v2-val v1
    value@ \ v1 v2 v2-val v1-val
    swap \ v1 v2 v1-val v2-val
;

: zip-sub-get-next ( v1 v2 -- adr1 adr2 )
    next@ \ v1 v2'
    swap \ v2' v1
    next@ \ v2' v1'
    swap \ v1' v2'
;


\ USAGE: vec2 head5 zip constant vs => (300,50) (200, 40) (100,30)
: zip ( v1 v2 -- vecCons )
  ( list a, list b ->  list <a,b> )
  0 >r  \ v1 v2 |R: 0
  begin \ v1 v2 |R: 0
    2dup \ v1 v2 v1 v2
    zip-sub-check-next \ v1 v2 bool
  while \ v1 v2 |R: next-node
    2dup \ v1 v2 v1 v2
    zip-sub-get-values \ v1 v2 val1 val2
    cons \ v1 v2 <val1,val2>
    r> \ v1 v2 <val1,val2> next-node |R: _
    node \ v1 v2 next-node'
    >r   \ v1 v2 |R: next-node'
    zip-sub-get-next \ v1' v2'
  repeat \ v1 v2 |R: next-node
  drop drop \ _
  r> \ next-node
  reverse \ next-node
;


\ USAGE: ' + vec1 head5 zip-with constant vs => 80 60 40
: zip-with ( xt v1 v2 -- list )
  \ xt :: v1 v2 -> v
  rot \ v1 v2 xt
  0 >r \ v1 v2 xt |R: 0
  >r \ v1 v2 |R: 0 xt
  begin \ v1 v2 |R: next-head' xt
    2dup \ v1 v2 v1 v2
    zip-sub-check-next \ v1 v2 bool
  while \ v1 v2 |R: next-head' xt
    2dup \ v1 v2 v1 v2
    zip-sub-get-values \ v1 v2 v1-val v2-val
    r@ \ v1 v2 v1-val v2-val xt |R: next-head xt
    execute \ v1 v2 f(v1,v2)
    r>      \ v1 v2 f(v1,v2) xt           |R: next-head
    swap    \ v1 v2 xt f(v1,v2)           |R: next-head
    r>      \ v1 v2 xt f(v1,v2) next-head |R: _
    node \ v1 v2 xt next-head'
    >r >r \ v1 v2 |R: next-head' xt
    zip-sub-get-next
  repeat \ v1 v2 |R: next-head' xt
  drop drop \ _
  r> drop \ _ |R: next-head'
  r> \ next-head' |R: _
  reverse \ next-node'
;



\ *** ============================== COMPOSITION ============================== *** \w


: compose ( vecXt -- val )
  begin
    dup \ vecXt vecXt
    0<> \ vecXt (vecXt<>0)
  while \ vecXt
    head-tail \ vecXt-xt vecXt-tail
    >r \ vecXt-xt \ main stack should be clean from vecXt elements before call execute
    execute \ execResult
    r> \ execResult vecXt-tail
  repeat \ execResult vecXt-tail-null
  drop \ execResult
;


\ USAGE :
\ : inc ( w -- w ) 1 + ;
\ : mul2 ( w -- w ) 2 * ;
\ ' inc singleton ' mul2 append constant vecF
\ vecF head5 map-compose 
: map-compose ( vecXt vec -- vec-new )
  0 >r ( put zero adress to r-stack )
  begin
    dup 0<> \ vecXt adr (adr!=0)
  while \ vecXtadr
    2dup \ vecXt adr vecXt adr
    value@ \ vecXt adr vecXt val
    swap \ vecXt adr val vecXt
    compose \ vecXt adr f(val)
    r> \ vecXt adr f(val) next-node
    node \ vecXt adr next-node'
    >r \ vecXt adr
    next@ \ vecXt adr'
  repeat \ vecXt adr
  drop drop \ _
  r> \ adr-new
  reverse
;


\ *** ============================== EXAMPLE ============================== *** \

10 0 node constant head1  \ next = NULL
20 head1 node constant head2 
30 head2 node constant head3
40 head3 node constant head4
50 head4 node constant head5
\ to add: head5 60 node constant head6


10 0 node \ узел со значением 10 \ next = NULL
20 swap node \ узел со значением 20
30 swap node \ узел со значением 30
constant lshead

10  0 node 20  swap node 30  swap node constant vec1
100 0 node 200 swap node 300 swap node constant vec2
\ 1000 0 node 2000 ::: 3000 ::: 4000 ::: 5000 ::: constant vec3
-1  0 node constant vec-zero


: inc ( w -- w ) 1 + ;
: mul2 ( w -- w ) 2 * ;
' inc singleton ' mul2 append constant vecF

: predicate ( w -- bool ) 25 > ;


