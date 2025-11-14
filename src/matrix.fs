: :r "/home/kolay/prog/gforth/src/matrix.fs" included ;


\ *** ============================== LIST ============================== *** \

\ Создаём узел в куче (через allocate)
: node ( next-adr value -- addr )
  2 cells allocate throw    \ выделяем 2 ячейки памяти
  dup >r                    \ сохраняем адрес в R-стек
  swap over !               \ записываем value
  cell+ !                   \ записываем next
  r> ;                      \ вернуть адрес узла

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

: .show-list dup show-list ;


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



\ USAGE: : inc ( w -- w ) 1 + ; ' inc head map-list
: map-list ( xt adr -- adr-new )
  0 >r \ put zero adress to r-stack
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
;



\ *** ============================== VECTORS  ============================== *** \


\ \ USAGE: vec1 vec2 vec-acc vector-sum constant vs 
\ : vector-sum-1 ( v1 v2 v-adr -- v )
\   >r \ v1 v2
\   begin
\     2dup \ v1 v2 v1 v2
\     value@ \ v1 v2 v1 v2-val
\     swap \ v1 v2 v2-val v1
\     value@ \ v1 v2 v2-val v1-val
\     + \ v1 v2 v-sum
\     r> \ v1 v2 v-sum v-adr
\     swap \ v1 v2 v-adr v-sum
\     node \ v1 v2 v-adr'
\     >r \ v1 v2
      
\     dup next@ \ v1 v2 v2-next
\     0<> \ v1 v2 (v2-next != 0)
\   while
\     next@ \ v1 v2'
\     swap \  v2' v1
\     next@ \ v2' v1'
\     swap \  v1' v2'
\   repeat
\   drop drop \
\   r> \ v-adr'
\   ;


\ USAGE: vec1 vec2 vector-sum constant vs 
: vector-sum ( v1 v2 -- v )
  0 \ v1 v2 0
  >r \ v1 v2
  begin
    2dup \ v1 v2 v1 v2
    value@ \ v1 v2 v1 v2-val
    swap \ v1 v2 v2-val v1
    value@ \ v1 v2 v2-val v1-val
    + \ v1 v2 v-sum
    r> \ v1 v2 v-sum v-adr
    swap \ v1 v2 v-adr v-sum
    node \ v1 v2 v-adr'
    >r \ v1 v2    
      
    dup next@ \ v1 v2 v2-next
    0<> \ v1 v2 (v2-next != 0)
  while
    next@ \ v1 v2'
    swap \  v2' v1
    next@ \ v2' v1'
    swap \  v1' v2'
  repeat
  drop drop \
  r> \ v-adr'
  ;

    
    
0 10 node 20 node 30 node constant vec1
0 100 node 200 node 300 node constant vec2
0 -1 node constant vec-acc
