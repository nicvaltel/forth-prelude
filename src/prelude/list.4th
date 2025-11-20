: :r "/home/kolay/prog/forth/src/prelude/list.4th" included ;

\ *** ============================== TUPLE ============================== *** \w

: pair ( a b -- <a,b> )
  2 cells allocate throw ( a b adr ) \ alloc 2 cells of memory
  >r                     ( a b |R: adr )
  r@                     ( a b adr )
  cell+ !                ( a ) \ save b to adr+
  r@                     ( a adr )
  !                      ( _ ) \ save a to adr
  r>                     ( adr |R: _ )
;
\ \ ПОЯСНЕНИЕ Создаём узел в куче (через allocate)
\   2 cells allocate throw \ next-addr value new-addr
\   \ выделяем 2 ячейки памяти; allocate :: ( u -- a_addr wior )
\   \ где addr — адрес выделенной памяти (если всё прошло успешно); wior — I/O result code — код ошибки (I/O result, по стандарту Forth).
\   \ если на стеке wior = 0 thow не делает ничего, иначе выбрасывает ошибку с кодом wior
\ cell+ ( a-addr1 -- a-addr2 )

: fst ( <a,b> -- a ) @ ;
: snd ( <a,b> -- b ) cell+ @ ; \ immediate

\ USAGE:
\ 1 2 pair constant pair-x
\ 3 4 pair constant pair-y
\ pair-x pair-y pair constant pair-z
\ pair-x fst \ -- 1
\ pair-x snd \ -- 2
\ pair-z fst fst \ -- 1
\ pair-z snd fst \ -- 3

: free-pair ( pair -- ) free throw ;


: un-pair ( <a,b> -- a b )
  dup  \ <a,b> <a,b>
  fst  \ <a,b> a
  swap \ a <a,b>
  snd  \ a b
;

\ : un-pair ( pair -- a b )
\   dup @ \ a
\   swap cell+ @
\ ;
\ 10000000 bench-up-pair  Time (microseconds): 398628 
\  ok
\ 10000000 bench-up-pair  Time (microseconds): 404622 
\  ok
\ 10000000 bench-up-pair  Time (microseconds): 399574 


\ *** ============================== LIST ============================== *** \

\ USAGE: 17 0 node || 27 vec5 node
: node ( value next-node-adr -- new-node-adr ) pair ;

: head  ( list-adr -- value ) @ ;
: tail  ( list-adr -- next-node-adr  ) cell+ @ ;

: ?null ( list -- bool ) 0= ;

: ?not-null ( list -- bool ) 0<> ;


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


: singleton ( val -- list-adr ) 0 pair ;


\ USAGE: 66 vec5 cons constant vec6 
\ USAGE 10 singleton 20 cons 30 cons => 30 : 10 : 20 : []
: cons ( list val -- newList ) swap pair ;


\ USAGE: vec5 free-list
: free-list ( list -- )
  begin
    dup          ( list list )
  while
    dup tail     ( list next )
    swap         ( next list )
    free throw   ( next ) \ free current node
  repeat
  drop ;         ( ) \ drop final 0


: showl ( list-adr -- )
  begin
    dup             \ пока адрес не нулевой
  while
    dup head   .       \ печатаем значение
    ." : "
    tail                \ переходим к следующему
  repeat
  ." []"
  drop
;

: .showl ( list-adr -- list-adr ) dup showl ;


: [[[ 1 ;

: ,, ( n val -- val n+1 )
  swap ( val n )
  1 +  ( val n+1 )
;

\ USAGE: [[[ 1 ,, 2 ,, 3 ]]]
: ]]] ( x ... x_n-1 n xn -- list )
  swap
  0 >r      ( x ... xn n      |R: list )
  begin     ( x ... xn n      |R: list )
    dup 0<> ( x ... xn n n<>0 |R: list )
  while     ( x ... xn n      |R: list )
    swap    ( x ... n xn      |R: list )
    r>      ( x ... n xn list |R: )
    node    ( x ... n list'   |R: )
    >r      ( x ... n         |R: list' )
    1 -     ( x ... n-1       |R: list' )
  repeat    ( 0               |R: list' )
  drop
  r>
;




\ USAGE: vec5 reverse constant vec-rev
: reverse ( list-adr -- rev-list-adr )
  0 >r         ( adr |R: 0 ) \ put zero adress to r-stack for new result list
  begin        ( adr )
    dup        ( adr adr<>0 ) \ 0 = false
  while        ( adr )
    dup head   ( adr val )
    r>         ( adr val node-next |R: )
    node       ( adr node-next' )
    >r         ( adr |R: node-next' )
    tail       ( adr' )
  repeat       ( adr )
  drop         ( )
  r>           ( node-next |R: )
;


\ USAGE: vec5 clone constant vec5clone
: clone ( adr -- new-adr )
  reverse    ( adr' )
  dup        ( adr' adr' )
  reverse    ( adr' new-adr )
  swap       ( new-adr adr' )
  free-list  ( new-adr )
;

\ EXAMPLE:
\  vec5 clone constant vec5clone 
\  vec5clone showl --  50 40 30 20 10  ok
\  33 vec5 tail tail ! --  ok
\  vec5 showl  50 40 33 20 10  ok
\  vec5clone showl  50 40 30 20 10  ok


\ USAGE: vec-x10 vec-x100 list-join
: list-join ( list1 list2 -- list-1-2 )
  >r           ( adr1 |R: adr2 )
  reverse      ( reversed-adr1 )
  begin
    dup        ( adr1 adr1<>0 )
  while        ( adr1 )
    dup head   ( adr1 val1 )
    r>         ( adr1 val1 new-adr |R: )
    node       ( adr1 new-adr' )
    >r         ( adr1 |R: new-adr' )
    tail       ( adr1' )
  repeat       ( adr1 |R: new-adr' )
  drop         ( )
  r>           ( new-adr' |R: _ )
;


: 2dup-execute ( xt adr -- xt adr f{val} )
  2dup    ( xt adr xt adr )
  head    ( xt adr xt val )
  swap    ( xt adr val xt )
  execute ( xt adr f{val} )
;

\ USAGE: : inc ( w -- w ) 1 + ; ' inc vec5 map || vec5 ' mul2 swap map showl
: map-loop ( func-xt list-adr -- new-list-adr )
  0 >r               ( xt adr |R: new-adr ) \ put zero adress to r-stack
  begin
    dup              ( xt adr adr!=0 )
  while              ( xt adr )
    2dup-execute     ( xt adr f{val} )
    r>               ( xt adr new-val next-node |R: )
    node             ( xt adr next-node' )
    >r               ( xt adr |R: next-node' )
    tail             ( xt adr' )
  repeat             ( xt adr )
  drop drop          ( )
  r>                 ( adr-new |R: )
  reverse            ( adr-new )
;


\ USAGE: : inc ( w -- w ) 1 + ; ' inc vec5 map || vec5 ' mul2 swap map showl
: map ( func-xt list-adr -- new-list-adr ) recursive
  dup ?null      ( xt list ?null ) \ can be changed to " dup " and switch if and else code
  if             ( xt 0 )         \ list is empty
    swap drop    ( 0 ) \ return zero as nex-adress of last node
  else           ( xt list )
    2dup-execute ( xt list f{val} )
    -rot         ( f{val} xt list )
    tail         ( f{val} xt list-tail )
    map          ( f{val} new-list )
    node         ( new-list' )
  then           ( new-list )
;



\ USAGE: : predicate ( w -- bool ) 25 > ; ' predicate vec5 filter showl
: filter-loop            ( predicate-xt list -- filtered-list )
  0 >r              ( xt vec |R: new-adr )
  begin             ( xt vec )
    dup 0<>         ( xt vec vec<>0 )
  while             ( xt vec )
    2dup-execute    ( xt vec predicate{val} )
    if              ( xt vec )
      dup           ( xt vec vec )
      head          ( xt vec val )
      r>            ( xt vec val next-node )
      node          ( xt vec next-node' )
      >r            ( xt vec )
    else            ( xt vec )
    then            ( xt vec )
    tail            ( xt vec' )
  repeat            ( xt vec' )
  drop drop         ( )
  r>                ( vec' )
  reverse           ( vec' )
;



\ USAGE: : predicate ( w -- bool ) 25 > ; ' predicate vec5 filter showl
: filter ( predicate-xt list -- filtered-list ) recursive
  dup ?null      ( xt list ?null ) \ can be changed to " dup " and switch if and else code
  if             ( xt 0 )         \ list is empty
    swap drop    ( 0 ) \ return zero as next-adress of last node
  else           ( xt list )
    swap         ( list xt )
    >r           ( list |R: xt )
    head-tail    ( val list-tail )
    r@           ( val list-tail xs )
    swap         ( val xs list-tail )
    filter       ( val new-list )
    over         ( val new-list val )
    r>           ( val new-list val xt |R: )
    execute      ( val new-list predicate{val} )
    if           ( val new-list  ) \ predicate = true
      node       ( new-list' )
    else         ( val new-list ) \ predicate = false
      swap drop  ( new-list )
    then 
  then           ( new-list )
;



\ \ partition p xs == (filter p xs, filter (not . p) xs)
\ \ USAGE: : predicate ( w -- bool ) 25 > ; 
\ \ ' predicate vec5 partition constant vecp 
\ \ vecp fst showl 50 : 40 : 30 : [] ok
\ \ vecp snd showl 20 : 10 : [] ok
\ : partition  ( predicate-xt list -- <filtered-list,filtered-not-list> )
\   0 >r           ( xt vec |R: new-adr-true )
\   0 >r           ( xt vec |R: new-adr-true new-adr-false  )
\   begin          ( xt vec )
\     dup 0<>      ( xt vec vec<>0 )
\   while          ( xt vec )
\     2dup-execute ( xt vec predicate{val} )
\     if           ( xt vec )
\       dup        ( xt vec vec )
\       head       ( xt vec val )
\       r>         ( xt vec val adr-false |R: adr-true )
\       swap       ( xt vec adr-false val |R: adr-true )
\       r>         ( xt vec adr-false val adr-true |R: )
\       node       ( xt vec adr-false next-true-node )
\       >r         ( xt vec adr-false |R: next-true-node )
\       >r         ( xt vec |R: next-true-node adr-false )
\     else         ( xt vec )
\       dup        ( xt vec vec )
\       head       ( xt vec val )
\       r>         ( xt vec val adr-false |R: adr-true )
\       node       ( xt vec next-false-node )
\       >r         ( xt vec |R: adr-true next-false-node )
\     then         ( xt vec )
\     tail         ( xt vec' )
\   repeat         ( xt vec' )
\   drop drop      ( )
\   r>             ( true-vec )
\   reverse        ( true-vec )
\   r>             ( true-vec false-vec )
\   reverse        ( true-vec false-vec )
\   swap           ( false-vec true-vec )
\   pair           ( pair<true-vec,false-vec> )
\ ;


  



\ USAGE: ' test-fold-func 0 vec5 foldl
: foldl ( func-xt initial-val list -- val )
        ( func-xt :: acc -> val -> acc)
  rot       ( initial vec xt )
  >r        ( initial vec      |R: xt )
  begin     ( acc vec )
    dup     ( acc vec (vec<>0 )
  while     ( acc vec          |R: xt )
    tuck    ( vec acc vec )
    head    ( vec acc val )
    r@      ( vec acc val xt   |R: xt )
    execute ( vec acc' )
    swap    ( acc' vec )
    tail    ( acc' vec' )
  repeat
  r>        ( acc' vec' xt     |R: )
  drop drop ( acc' )
;




: zip-sub-check-next ( v1 v2 -- bool )
    0<>  ( v1 v2<>0 )
    swap ( v2<>0 v1 )
    0<>  ( v2<>0 v1<>0 )
    and  ( v2<>0 && v1<>0 )
;

: zip-sub-get-values ( v1 v2 -- x1 x2 )
    head ( v1 v2 v1 v2-val )
    swap ( v1 v2 v2-val v1 )
    head ( v1 v2 v2-val v1-val )
    swap ( v1 v2 v1-val v2-val )
;

: zip-sub-get-next ( v1 v2 -- adr1 adr2 )
    tail ( v1 v2' )
    swap ( v2' v1 )
    tail ( v2' v1' )
    swap ( v1' v2' )
;


\ USAGE: vec-x100 vec5 zip constant vs => (100,50) (200, 400) (300,30) (400, 200) (500,10)
: zip ( list-a list-b -- list-pair<a,b> ) recursive
  2dup                 ( v1 v2 v1 v2 )
  and                  ( v1 v2 bool ) \ bool = 0 when v1 is null or v2 is null
  if                   ( v1 v2 ) \ both lists are not null
    2dup               ( v1 v2 v1 v2 )
    zip-sub-get-next   ( v1 v2 v1' v2' )
    zip                ( v1 v2 list-pair-next )
    -rot               ( list-pair v1 v2 )
    zip-sub-get-values ( list-pair val1 val2 )
    pair               ( list-pair <val1,val2> )
    swap               ( <val1,val2> list-pair )
    node               ( list-pair' )
  else                 ( v1 v2 ) \ some of lists is null
    drop drop          ( )
    0                  ( 0 ) \ return null list
  then
;

  

\ *** ============================== COMPOSITION ============================== *** \w


: compose ( some-args-in-stack ... list-xt -- val )
  begin
    dup       ( args.. vec-xt vec-xt )
    0<>       ( args.. vec-xt vec-xt<>0 )
  while       ( args.. vec-xt )
    head-tail ( args.. func-xt vec-xt-tail )
    >r        ( args.. func-xt |R: vec-xt-tail ) \ main stack should be clean from vec-xt-tail before call execute
    execute   ( exec-result.. )
    r>        ( exec-result.. vec-xt-tail |R: )
  repeat      ( exec-result.. vec-xt-tail-null )
  drop        ( exec-result.. )
;


: 2dup-compose ( vec-funcs-xt adr )
    2dup    ( vec-funcs-xt adr vec-funcs-xt adr )
    head    ( vec-funcs-xt adr vec-funcs-xt val )
    swap    ( vec-funcs-xt adr val vec-funcs-xt )
    compose ( vec-funcs-xt adr f{val} )
;


\ USAGE :
\ : inc ( w -- w ) 1 + ;
\ : mul2 ( w -- w ) 2 * ;
\ ' inc singleton ' mul2 cons constant vecF
\ vecF vec5 map' => 101 : 81 : 61 : 41 : 21 : []
: map' ( vec-funcs-xt vec -- vec-new )
  0 >r      ( vec-xt vec                 |R: 0 )
  begin
    dup 0<> ( vec-funcs-xt adr adr<>0 )
  while     ( vec-funcs-xt adr )
    2dup-compose ( vec-funcs-xt adr f{val} )
    r>      ( vec-funcs-xt adr f{val} next-node |R: )
    node    ( vec-funcs-xt adr next-node' )
    >r      ( vec-funcs-xt adr                  |R: next-node' )
    tail    ( vec-funcs-xt adr' )
  repeat    ( vec-funcs-xt adr )
  drop drop ( )
  r>        ( adr-new )
  reverse   ( adr-new )
;


\ USAGE: 
\ ' predicate singleton ' mul2 cons constant vecPredicates
\ vecPredicates vec5 filter' => 50 : 40 : 30 : 20 : [] 
: filter' ( vec-predicates-xt list -- filtered-list )
  0 >r       ( xts vec |R: new-adr )
  begin      ( xts vec )
    dup 0<>  ( xts vec vec<>0 )
  while      ( xts vec )
    2dup-compose  ( xts vec predicates{val} )
    if       ( xts vec )
      dup    ( xts vec vec )
      head   ( xts vec val )
      r>     ( xts vec val next-node )
      node   ( xts vec next-node' )
      >r     ( xts vec )
    else     ( xts vec )
    then     ( xts vec )
    tail     ( xts vec' )
  repeat     ( xts vec' )
  drop drop  ( )
  r>         ( vec' )
  reverse    ( vec' )
;


\ USAGE:
\ ' test-fold-func singleton ' mul2 cons constant vec-fold-func
\ vec-fold-func 0 vec5 foldl' => 600
: foldl' ( vec-funcs-xts initial-val list -- val )
         ( func-xt :: acc -> val -> acc)
  rot       ( initial list xts )
  cr .showl
  >r        ( initial list     |R: xts )
  begin     ( acc list )
    dup 0<> ( acc list (list<>0 )
  while     ( acc list          |R: xts )
    tuck    ( list acc list )
    head    ( list acc list )
    r@      ( list acc list xts  |R: xts )    
    compose ( list acc' )
    swap    ( acc' list )
    tail    ( acc' list' )
  repeat
  r>        ( acc' list' xts    |R: )
  drop drop ( acc' )
;


\ USAGE: ' + vec-x10 vec5 zip-with constant vs => 80 60 40
: zip-with ( func-xt v1 v2 -- list )
  ( func-xt :: v1 v2 -> v )
  zip         ( func-xt list<v1,v2> )
  swap        ( list<v1,v2> func-xt )
  singleton   ( list<v1,v2> [func-xt] )
  ['] un-pair ( list<v1,v2> [func-xt] 'un-pair )
  cons      ( list<v1,v2> ['un-pair, func-xt] )
  swap        ( ['un-pair, func-xt] list<v1,v2> )
  map'        ( new-list )
;


\ USAGE:
\ ' + singleton ' mul2 cons constant vecF
\ vecF vec-x10 vec5 zip-with' constant vs => 130 : 100 : 70 : [] 
: zip-with' ( funcs-xts v1 v2 -- list )
  ( funcs-xts :: List of [v1 v2 -> v] )
  zip         ( [funcs-xts,..] list<v1,v2> )
  swap        ( list<v1,v2> [funcs-xts,..] )
  ['] un-pair ( list<v1,v2> [funcs-xts,..] 'un-pair )
  cons      ( list<v1,v2> ['un-pair, funcs-xts,..] )
  swap        ( ['un-pair, funcs-xts,..] list<v1,v2> )
  map'        ( new-list )
;


: test-word1-sub
  r> r>
  dup
  .
  >r >r
  \ alternative
  \ r@
  \ .
;


: test-word1
  100
  >r
  test-word1-sub
  r>
;


\ *** ============================== TESTING ============================== *** \

\ \ Pairs
1 2 pair constant pair-x
3 4 pair constant pair-y
pair-x pair-y pair constant pair-z

\ \ Lists
10  0    node constant vec1  \ next = NULL
200 vec1 node constant vec2 
30  vec2 node constant vec3
400 vec3 node constant vec4
50  vec4 node constant vec5

10  singleton 20  cons 30  cons 40  cons 50  cons reverse constant vec-x10
100 singleton 200 cons 300 cons 400 cons 500 cons reverse constant vec-x100


: inc ( n -- n ) 1 + ;
: mul2 ( n -- n ) 2 * ;

: predicate ( w -- bool ) 30 > ;

: test-fold-func ( acc x -- new-x )
  1 +  ( acc x+1 )
  3 *  ( acc [x+1]*3 )
  swap ( [x+1]*3 acc )
  2 *  ( [x+1]*3 acc*2 )
  +    ( acc*2 + 3*[x+1] )
;  


: print-test-result ( bool -- ) if ." ok " else ." FAIL " then ;

: test-pairs ( -- )
  cr ." TEST PAIRS"
  
  cr ." TEST-01: "
  pair-x fst
  1 = print-test-result

  cr ." TEST-02: " 
  pair-x snd
  2 = print-test-result

  cr ." TEST-03: "
  pair-z fst fst
  1 = print-test-result

  cr ." TEST-04: "
  pair-z snd fst
  3 = print-test-result

  cr ." TEST-05: "
  pair-y un-pair
  4 = print-test-result
  3 = print-test-result
;

: test-list ( -- )
  cr ." TEST LIST"
  
  cr ." TEST-01: "
  17 0 node
  head-tail 
  0 = print-test-result
  17 = print-test-result

  cr ." TEST-02: "
  27 vec5 node
  head-tail tail tail head
  30 = print-test-result
  27 = print-test-result

  cr ." TEST-03: "
  vec5 reverse
  head-tail head
  200 = print-test-result
  10 = print-test-result
  
  cr ." TEST-04: "
  0 reverse
  0= print-test-result

  cr ." TEST-05: "
  vec5 ['] mul2 swap map
  head-tail head
  800 = print-test-result
  100 = print-test-result

  cr ." TEST-06: "
  ['] inc 0 map
  0= print-test-result

  cr ." TEST-07: "
  ['] predicate vec5 filter
  head-tail head-tail head
  200 = print-test-result
  400 = print-test-result
  50 = print-test-result

  cr ." TEST-08: "
  ['] predicate 0 filter
  0= print-test-result

  cr ." TEST-09: "
  ['] test-fold-func 0 vec5 foldl
  13683 = print-test-result

  cr ." TEST-10: "
  ['] test-fold-func 17 vec5 foldl
  14227 = print-test-result

  cr ." TEST-11: "
  ['] test-fold-func 17 0 foldl
  17 = print-test-result
;

: run-test ( -- )
  test-pairs
  test-list
;


\ *** ============================== BENCHMARK  ============================== *** \

\ Benchmark: run pair N times and measure time
\ Usage: 1000000 bench-pair

variable start-time
variable end-time

: now ( -- u )  utime drop  ;  \ микросекунды как целое число

\ USAGE: 1000000 bench-pair  Time (microseconds): 62361 
: bench-pair ( n -- )
  now                  ( time )
  start-time !         ( )  \ засечь время
  0 do                 
    123 456 pair drop        \ вызвать pair, результат выбросить
  loop
  now end-time !

  end-time @ start-time @ -  \ разница во времени
  ." Time (microseconds): " . cr
;

\ USAGE: 1000000 bench-pair  Time (microseconds): 62361 
: bench-up-pair ( n -- )
  now                  ( time )
  start-time !         ( )  \ засечь время
  0 do                 
    123 456
    pair
    un-pair
    drop drop        \ результат выбросить
  loop
  now end-time !

  end-time @ start-time @ -  \ разница во времени
  ." Time (microseconds): " . cr
;


\ USAGE:
\ 100000000 test-fill-list  constant big-list
\ big-list free-list
: test-fill-list ( n -- list-adr )
  0         ( n zero-list-adr )
  swap      ( zero-list-adr n )
  0 do      ( list )
    17      ( list 17 )
    cons    ( new-list )
  loop
;

    

\ *** ============================== EXAMPLE ============================== *** \


\ [[[ 1000 ,, node 2000 ,, 3000 ,, 4000 ,, 5000 ]]] constant vec-x1000
\ -1  0 node constant vec-zero


: inc ( n -- n ) 1 + ;
: mul2 ( n -- n ) 2 * ;
\ ' inc singleton ' mul2 cons constant vecF




\ \ Pairs
\ 1 2 pair constant pair-x
\ 3 4 pair constant pair-y
\ pair-x pair-y pair constant pair-z
\ pair-x fst \ -- 1
\ pair-x snd \ -- 2
\ pair-z fst fst \ -- 1
\ pair-z snd fst \ -- 3


\ USAGE:
\ 500000000 big-alloc   ok 1
\ free-pair   ok
: big-alloc ( n -- adr )
  dup                  ( n n )
  cells allocate throw ( n adr0 )
  dup                  ( n adr0 adr0 )
  rot                  ( adr0 adr0 n )
  0                    ( adr0 adr0 n 0)
  do                   ( adr0 adr ) \ 0 -> n
    dup                ( adr0 adr adr )
    777
    swap               ( adr0 adr 777 adr )
    !                  ( adr0 adr )
    cell+              ( adr0 adr+ )
  loop                 ( adr0 adr )
  drop                 ( adr0 )
;
