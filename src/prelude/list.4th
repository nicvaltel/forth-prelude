: :r "/home/kolay/prog/forth/src/prelude/list.4th" included ;

\ *** ============================== TUPLE ============================== *** \w


\ USAGE: 50 100 pair => <100, 50> => un-pair => 100 50
: pair ( b a -- <a,b> )
  2 cells allocate throw ( b a adr ) \ alloc 2 cells of memory  
  >r                     ( b a |R: adr )
  r@                     ( b a adr )
  !                      ( b ) \ save a to adr
  r@                     ( b adr )
  cell+ !                ( ) \ save b to adr+
  r>                     ( adr |R: _ )
;
( 100, 50 )
\ \ ПОЯСНЕНИЕ Создаём узел в куче (через allocate)
\   2 cells allocate throw \ next-addr value new-addr
\   \ выделяем 2 ячейки памяти; allocate :: ( u -- a_addr wior )
\   \ где addr — адрес выделенной памяти (если всё прошло успешно); wior — I/O result code — код ошибки (I/O result, по стандарту Forth).
\   \ если на стеке wior = 0 thow не делает ничего, иначе выбрасывает ошибку с кодом wior
\ cell+ ( a-addr1 -- a-addr2 )

: fst ( <a,b> -- a ) @ ;
: snd ( <a,b> -- b ) cell+ @ ;

\ USAGE:
\ 1 2 pair constant pair-x
\ 3 4 pair constant pair-y
\ pair-x pair-y pair constant pair-z
\ pair-x fst \ -- 1
\ pair-x snd \ -- 2
\ pair-z fst fst \ -- 1
\ pair-z snd fst \ -- 3

: free-pair ( pair -- ) free throw ;

: un-pair ( <a,b> -- b a )
  dup  \ <a,b> <a,b>
  snd  \ <a,b> b
  swap \ b <a,b>
  fst  \ b a
;

: show-pair ( <a,b> -- )
  ." <"
  dup fst .
  ." ,"
  snd .
  ." >"
;


\ USAGE: pair-x dup eq-pair ; pair-x pair-y eq-pair
: eq-pair ( <a1,b1> <a2,b2> -- bool )
  un-pair ( <a1,b1> b2 a2 )
  rot     ( b2 a2 <a1,b1> )
  un-pair ( b2 a2 b1 a1 )
  rot     ( b2 b1 a1 a2 )
  =       ( b2 b1 a1=a2 )
  -rot    ( a1=a2 b2 b1 )
  =       ( a1=a2 b2=b1 )
  and     ( a1=a2 && b2=b1 )
;



\ 10000000 bench-up-pair  Time (microseconds): 398628 
\  ok
\ 10000000 bench-up-pair  Time (microseconds): 404622 
\  ok
\ 10000000 bench-up-pair  Time (microseconds): 399574 


\ *** ============================== LIST ============================== *** \

\ USAGE: 0 17 node || vec5 27 node
: node ( next-node-adr value -- new-node-adr ) pair ; \ <value, next-node-adr>

: head  ( list-adr -- value ) fst ;
: tail  ( list-adr -- next-node-adr  ) snd ;

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

\ USAGE: 17 singleton
: singleton ( val -- list-adr )
  0 swap    ( 0 val )
  pair
;


\ USAGE: 66 vec5 cons constant vec6 
\ USAGE 10 singleton 20 cons 30 cons => 30 : 10 : 20 : []
: cons ( list val -- newList ) pair ;


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


\ USAGE: list-x10 length
: length ( list -- n )
  0      ( list 0 )
  swap   ( 0 list )
  begin
    dup  ( n list list )
  while  ( n list ) \ when list<>0
    swap ( list n )
    1 +  ( list n+1 )
    swap ( n+1 list )
    tail ( n+1 list' )
  repeat ( n list )
  drop   ( n ) 
;


\ USAGE: vec5 reverse constant vec-rev
: reverse ( list-adr -- rev-list-adr )
  0 >r         ( vec |R: 0 ) \ put zero adress to r-stack for new result list
  begin        ( vec )
    dup        ( vec vec <>0 ) \ 0 = false
  while        ( vec )
    r>         ( vec next-node |R: )
    over       ( vec next-node vec )
    head       ( vec next-node val )
    node       ( vec adr node-next' )
    >r         ( vec |R: node-next' )
    tail       ( vec' )
  repeat       ( vec )
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
: list-join ( list1 list2 -- list-1-2 ) recursive
  swap        ( v2 v1 )
  dup         ( v2 v1 v1 )
  if          ( v2 v1 ) \ when v1<>0
    head-tail ( v2 val1 v1-tail )
    rot       ( val1 v1-tail v2 )
    list-join ( val1 joined )
    swap      ( joined val1 )
    node      ( joined' )    
  else        ( v2 0 ) \ when v1=0
    drop      ( v2 )
  then
;


\ USAGE: : inc ( w -- w ) 1 + ; vec5 ' inc map || ' mul2 vec5 swap map showl
: map ( list-adr func-xt  -- new-list-adr ) recursive
  >r             ( list |R: xt )
  dup            ( list list )
  if             ( list ) \ when list is not empty
    tail-head    ( list-next val )
    r@           ( list-next val xt )
    execute      ( list-next f{val} )
    swap         ( f{val} list-next )
    r>           ( f{val} list-next xt |R: )
    map          ( f{val} new-list-next )
    swap         ( new-list-next f{val} )
    node         ( new-list )
  else           ( 0 ) \ when list is empty
    r>           ( 0 xt |R: )
    drop         ( 0 ) \ return zero as next-adress of last node
  then           ( new-list )
;


\ USAGE: : predicate ( w -- bool ) 30 > ; vec5 ' predicate filter showl
: filter ( list predicate-xt -- filtered-list ) recursive
  >r             ( list |R: xt )
  dup            ( list list )
  if             ( list )         \ list is not empty
    head-tail    ( val list-next )
    r@           ( val list-next xt )
    filter       ( val filtered-list-next )
    swap         ( filtered-list-next val )
    dup          ( filtered-list-next val val )
    r>           ( filtered-list-next val val xt |R: )
    execute      ( filtered-list-next val predicate{val} )
    if           ( filtered-list-next val ) \ when predicate{val} = true
      node       ( filtered-list )
    else
      drop       ( filtered-list-next )
    then
  else           ( 0 ) \ list is empty
    r>           ( 0 xt |R: )
    drop         ( 0 ) \ return empty list
  then           
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


\ USAGE: vec5 17 ' test-fold-func foldl
: foldl ( list initial-val func-xt -- val )
        \ func-xt ( val acc -- acc)
  >r        ( list initial |R: xt )
  swap      ( inital list )
  begin     ( acc list )
    dup     ( acc list list )
  while     ( acc list  |R: xt ) \ list is not empty
    dup     ( acc list list )
    head    ( acc list val )
    rot     ( list val acc )
    r@      ( list val acc xt )
    execute ( list acc' )
    swap    ( acc' list )
    tail    ( acc' list' )
  repeat
  r>        ( acc' list' xt |R: )
  drop drop ( acc' )
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


\ USAGE: vec5 vec-x100 zip constant vs => (100,50) (200, 400) (300,30) (400, 200) (500,10)
: zip ( list-b list-a -- list-pair<a,b> ) recursive
  2dup                 ( v2 v1 v2 v1 )
  and                  ( v2 v1 bool ) \ bool = 0 when v1 is null or v2 is null
  if                   ( v2 v1 ) \ both lists are not null
    2dup               ( v2 v1 v2 v1 )
    zip-sub-get-values ( v2 v1 val2 val1 )
    pair               ( v2 v1 <val1,val2> )
    -rot               ( <val1,val2> v2 v1 )
    zip-sub-get-next   ( <val1,val2> v2' v1' )
    zip                ( <val1,val2> list-pair-next )
    swap               ( list-pair-next  <val1,val2> )
    node               ( list-pair' )
  else                 ( v1 v2 ) \ some of lists is null
    drop drop          ( )
    0                  ( 0 ) \ return null list
  then
;

  

\ *** ============================== COMPOSITION ============================== *** \w


: compose ( some-args-in-stack ... list-xts -- val )
  begin
    dup       ( args.. vec-xt vec-xt )
  while       ( args.. vec-xt ) \ when vec-xt<>0
    head-tail ( args.. func-xt vec-xt-tail )
    >r        ( args.. func-xt |R: vec-xt-tail ) \ main stack should be clean from vec-xt-tail before call execute
    execute   ( exec-result.. )
    r>        ( exec-result.. vec-xt-tail |R: )
  repeat      ( exec-result.. vec-xt-tail-null )
  drop        ( exec-result.. )
;


\ USAGE :
\ : inc ( w -- w ) 1 + ;
\ : mul2 ( w -- w ) 2 * ;
\ ' inc singleton ' mul2 cons constant vecF
\ vec5 vecF map' => 101 : 801 : 61 : 401 : 21 : []
: map' ( list-adr list-func-xts -- new-list-adr ) recursive
  >r             ( list |R: xts )
  dup            ( list list )
  if             ( list ) \ when list is not empty
    tail-head    ( list-next val )
    r@           ( list-next val xts )
    compose      ( list-next f{val} ) \ the only change relative to map
    swap         ( f{val} list-next )
    r>           ( f{val} list-next xts |R: )
    map'         ( f{val} new-list-next )
    swap         ( new-list-next f{val} )
    node         ( new-list )
  else           ( 0 ) \ when list is empty
    r>           ( 0 xt |R: )
    drop         ( 0 ) \ return zero as next-adress of last node
  then           ( new-list )
;


\ USAGE: 
\ ' predicate singleton ' mul2 cons constant vecPredicates
\ vec5 vecPredicates filter' => 50 : 400 : 30 : 200 : [] 
: filter' ( list list-predicate-xts -- filtered-list ) recursive
  >r             ( list |R: xts )
  dup            ( list list )
  if             ( list )         \ list is not empty
    head-tail    ( val list-next )
    r@           ( val list-next xts )
    filter'      ( val filtered-list-next )
    swap         ( filtered-list-next val )
    dup          ( filtered-list-next val val )
    r>           ( filtered-list-next val val xts |R: )
    compose      ( filtered-list-next val predicate{val} )  \ the only change relative to filter
    if           ( filtered-list-next val ) \ when predicate{val} = true
      node       ( filtered-list )
    else
      drop       ( filtered-list-next )
    then
  else           ( 0 ) \ list is empty
    r>           ( 0 xts |R: )
    drop         ( 0 ) \ return empty list
  then           
;


\ USAGE:
\ ' test-fold-func singleton ' mul2 cons constant vec-fold-func
\ vec5 0 vec-fold-func foldl' => 120093
\ vec5 17 vec-fold-func foldl' => 137501
: foldl' ( list initial-val list-func-xts -- val )
         \ func-xt ( val acc -- acc)
  >r        ( list initial |R: xts )
  swap      ( inital list )
  begin     ( acc list )
    dup     ( acc list list )
  while     ( acc list  |R: xts ) \ list is not empty
    dup     ( acc list list )
    head    ( acc list val )
    rot     ( list val acc )
    r@      ( list val acc xts )
    compose ( list acc' )
    swap    ( acc' list )
    tail    ( acc' list' )
  repeat
  r>        ( acc' list' xt |R: )
  drop drop ( acc' )
;


\ USAGE: vec-x10 vec4 ' + zip-with showl => 410 : 50 : 230 : 50 : [] 
: zip-with ( v2 v1 func-xt -- list )
  \ func-xt ( v2 v1 -- v )
  singleton   ( v2 v1 [func-xt] )
  ['] un-pair ( v2 v1 [func-xt] 'un-pair )
  node        ( v2 v1 ['un-pair, func-xt] )
  -rot        ( ['un-pair, func-xt] v2 v1 )
  zip         ( ['un-pair, func-xt] list<v1,v2> )
  swap        ( list<v1,v2> ['un-pair, func-xt] )
  map'        ( new-list )
;

\ USAGE:
\ ' + singleton ' mul2 cons constant vecF
\ vec-x10 vec4 vecF zip-with' showl => 810 : 80 : 430 : 60 : []
: zip-with' ( v2 v1 funcs-xts -- list )
  \ func-xt ( v2 v1 -- v )
  ['] un-pair ( v2 v1 [func-xt] 'un-pair )
  node        ( v2 v1 ['un-pair, func-xt] )
  -rot        ( ['un-pair, func-xt] v2 v1 )
  zip         ( ['un-pair, func-xt] list<v1,v2> )
  swap        ( list<v1,v2> ['un-pair, func-xt] )
  map'        ( new-list )
;


\ *** ============================== TESTING ============================== *** \

\ \ Pairs
2 1 pair constant pair-x
4 3 pair constant pair-y
pair-y pair-x pair constant pair-z

\ \ Lists
0 10     node constant vec1  \ next = NULL
vec1 200 node constant vec2 
vec2 30  node constant vec3
vec3 400 node constant vec4
vec4 50  node constant vec5

10  singleton 20  cons 30  cons 40  cons 50  cons reverse  constant vec-x10
100 singleton 200 cons 300 cons 400 cons 500 cons reverse constant vec-x100


: inc ( n -- n ) 1 + ;
: mul2 ( n -- n ) 2 * ;

: predicate ( w -- bool ) 30 > ;

: test-fold-func ( x acc -- new-x )
  2 *  ( x acc*2 )
  swap ( acc*2 x )
  1 +  ( acc*2 x+1 )
  3 *  ( acc*2 [x+1]*3 )
  +    ( acc*2 + 3*[x+1] )
;  


: print-test-result ( bool -- ) if ." ok " else ." FAIL " then ;

: test-pairs ( -- )
  cr ." Test pair"
  
  cr ." Test-01: "
  pair-x fst
  1 = print-test-result

  cr ." Test-02: " 
  pair-x snd
  2 = print-test-result

  cr ." Test-03: "
  pair-z fst fst
  1 = print-test-result

  cr ." Test-04: "
  pair-z snd fst
  3 = print-test-result

  cr ." Test-05: "
  pair-y un-pair
  3 = print-test-result
  4 = print-test-result

  cr ." Test-06: "
  pair-x dup eq-pair
  print-test-result

  cr ." Test-07: "
  pair-x pair-y eq-pair
  invert
  print-test-result

;

: test-list ( -- )
  cr ." Test list"
  
  cr ." Test-01: "
  0 17 node
  head-tail 
  0 = print-test-result
  17 = print-test-result

  cr ." Test-02: "
  vec5 27 node
  head-tail tail tail head
  30 = print-test-result
  27 = print-test-result

  cr ." Test-03: "
  vec-x10 length
  5 = print-test-result

  cr ." Test-04: "
  vec5 reverse
  head-tail head
  200 = print-test-result
  10 = print-test-result
  
  cr ." Test-05: "
  0 reverse
  0= print-test-result
;

: test-map-filter-fold ( -- )
  cr ." Test map, filter, fold"
  
  cr ." Test-01: "
  vec5 ['] mul2 map
  head-tail head
  800 = print-test-result
  100 = print-test-result

  cr ." Test-02: "
  0 ['] inc  map
  0= print-test-result

  cr ." Test-03: "
  vec5 ['] predicate filter
  head-tail head-tail head
  200 = print-test-result
  400 = print-test-result
  50 = print-test-result

  cr ." Test-04: "
  0 ['] predicate filter
  0= print-test-result

  cr ." Test-05: "
  vec5 0 ['] test-fold-func foldl
  13683 = print-test-result

  cr ." Test-06: "
  vec5 17 ['] test-fold-func foldl
  14227 = print-test-result

  cr ." Test-07: "
  0 17 ['] test-fold-func foldl
  17 = print-test-result
;

: run-test ( -- )
  test-pairs
  test-list
  test-map-filter-fold
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
