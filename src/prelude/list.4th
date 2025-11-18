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
: snd ( <a,b> -- b ) cell+ @ ;

\ USAGE:
\ 1 2 pair constant pair-x
\ 3 4 pair constant pair-y
\ pair-x pair-y pair constant pair-z
\ pair-x fst \ -- 1
\ pair-x snd \ -- 2
\ pair-z fst fst \ -- 1
\ pair-z snd fst \ -- 3



: un-pair ( <a,b> -- a b )
  dup  \ <a,b> <a,b>
  fst  \ <a,b> a
  swap \ a <a,b>
  snd  \ a b
;



\ *** ============================== LIST ============================== *** \

\ USAGE: 17 0 node || 27 vec5 node
: node ( value next-node-adr -- new-node-adr ) pair ;

: head  ( list-adr -- value ) @ ;
: tail  ( list-adr -- next-node-adr  ) cell+ @ ;

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

\ USAGE: 66 vec5 append constant vec6 
\ USAGE 10 singleton 20 append 30 append => 30 : 10 : 20 : []
: append ( list val -- newList ) swap pair ;


: showl ( list-adr -- )
  begin
    dup 0<>            \ пока адрес не нулевой
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
    dup 0<>    ( adr adr<>0 )
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
  0 >r         ( adr |R: new-adr )
  begin
    dup 0<>    ( adr adr<>0 )
  while        ( adr )
    dup head   ( adr val )
    r>         ( adr val new-adr |R: _ )
    node       ( adr new-adr' )
    >r         ( adr |R: new-adr' )
    tail       ( adr' )
  repeat       ( adr |R: new-adr' )
  drop         ( )
  r>           ( new-adr' |R: _ )
  reverse
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
    dup 0<>    ( adr1 adr1<>0 )
  while        ( adr1 )
    dup head   ( adr1 val1 )
    r>         ( adr1 val1 new-adr |R: )
    node       ( adr1 new-adr' )
    >r         ( adr1 |R: new-adr' )
    tail       ( adr1' )
  repeat       ( adr1 |R: new-adr' )
  drop    ( )
  r>           ( new-adr' |R: _ )
;


: 2dup-execute ( xt adr -- xt adr f{val} )
  2dup    ( xt adr xt adr )
  head    ( xt adr xt val )
  swap    ( xt adr val xt )
  execute ( xt adr f{val} )
;

\ USAGE: : inc ( w -- w ) 1 + ; ' inc vec5 map || vec5 ' mul2 swap map showl
: map ( func-xt list-adr -- new-list-adr )
  0 >r               ( xt adr |R: new-adr ) \ put zero adress to r-stack
  begin
    dup 0<>          ( xt adr adr!=0 )
  while              ( xt adr )
    2dup-execute  ( xt adr f{val} )
    r>               ( xt adr new-val next-node |R: )
    node             ( xt adr next-node' )
    >r               ( xt adr |R: next-node' )
    tail             ( xt adr' )
  repeat             ( xt adr )
  drop drop          ( )
  r>                 ( adr-new |R: )
  reverse            ( adr-new )
;


\ USAGE: : predicate ( w -- bool ) 25 > ; ' predicate vec5 filter showl
: filter            ( predicate-xt list -- filtered-list )
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


\ partition p xs == (filter p xs, filter (not . p) xs)
\ USAGE: : predicate ( w -- bool ) 25 > ; 
\ ' predicate vec5 partition constant vecp 
\ vecp fst showl 50 : 40 : 30 : [] ok
\ vecp snd showl 20 : 10 : [] ok
: partition  ( predicate-xt list -- <filtered-list,filtered-not-list> )
  0 >r           ( xt vec |R: new-adr-true )
  0 >r           ( xt vec |R: new-adr-true new-adr-false  )
  begin          ( xt vec )
    dup 0<>      ( xt vec vec<>0 )
  while          ( xt vec )
    2dup-execute ( xt vec predicate{val} )
    if           ( xt vec )
      dup        ( xt vec vec )
      head       ( xt vec val )
      r>         ( xt vec val adr-false |R: adr-true )
      swap       ( xt vec adr-false val |R: adr-true )
      r>         ( xt vec adr-false val adr-true |R: )
      node       ( xt vec adr-false next-true-node )
      >r         ( xt vec adr-false |R: next-true-node )
      >r         ( xt vec |R: next-true-node adr-false )
    else         ( xt vec )
      dup        ( xt vec vec )
      head       ( xt vec val )
      r>         ( xt vec val adr-false |R: adr-true )
      node       ( xt vec next-false-node )
      >r         ( xt vec |R: adr-true next-false-node )
    then         ( xt vec )
    tail         ( xt vec' )
  repeat         ( xt vec' )
  drop drop      ( )
  r>             ( true-vec )
  reverse        ( true-vec )
  r>             ( true-vec false-vec )
  reverse        ( true-vec false-vec )
  swap           ( false-vec true-vec )
  pair           ( pair<true-vec,false-vec> )
;


  


\ USAGE: ' test-fold-func 0 vec5 foldl
: foldl ( func-xt initial-val list -- val )
        ( func-xt :: acc -> val -> acc)
  rot       ( initial vec xt )
  >r        ( initial vec      |R: xt )
  begin     ( acc vec )
    dup 0<> ( acc vec (vec<>0 )
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

\ USAGE: vec-x100 vec5 zip constant vs => (300,50) (200, 40) (100,30)
: zip ( list-a list-b -- list-pair<a,b> )
  0 >r                 ( v1 v2 |R: 0 )
  begin                ( v1 v2 |R: 0 )
    2dup               ( v1 v2 v1 v2 )
    zip-sub-check-next ( v1 v2 bool )
  while                ( v1 v2 |R: next-node )
    2dup               ( v1 v2 v1 v2 )
    zip-sub-get-values ( v1 v2 val1 val2 )
    pair               ( v1 v2 <val1,val2> )
    r>                 ( v1 v2 <val1,val2> next-node |R: )
    node               ( v1 v2 next-node' )
    >r                 ( v1 v2 |R: next-node' )
    zip-sub-get-next   ( v1' v2' )
  repeat               ( v1 v2 |R: next-node )
  drop drop            ( )
  r>                   ( next-node )
  reverse              ( next-node )
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
\ ' inc singleton ' mul2 append constant vecF
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
\ ' predicate singleton ' mul2 append constant vecPredicates
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
\ ' test-fold-func singleton ' mul2 append constant vec-fold-func
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
  append      ( list<v1,v2> ['un-pair, func-xt] )
  swap        ( ['un-pair, func-xt] list<v1,v2> )
  map'        ( new-list )
;


\ USAGE:
\ ' + singleton ' mul2 append constant vecF
\ vecF vec-x10 vec5 zip-with' constant vs => 130 : 100 : 70 : [] 
: zip-with' ( funcs-xts v1 v2 -- list )
  ( funcs-xts :: List of [v1 v2 -> v] )
  zip         ( [funcs-xts,..] list<v1,v2> )
  swap        ( list<v1,v2> [funcs-xts,..] )
  ['] un-pair ( list<v1,v2> [funcs-xts,..] 'un-pair )
  append      ( list<v1,v2> ['un-pair, funcs-xts,..] )
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
10 0 node constant vec1  \ next = NULL
20 vec1 node constant vec2 
30 vec2 node constant vec3
40 vec3 node constant vec4
50 vec4 node constant vec5

10   0 node 20  swap node 30  swap node constant vec-x10
100  0 node 200 swap node 300 swap node constant vec-x100

: inc ( n -- n ) 1 + ;
: mul2 ( n -- n ) 2 * ;
: test-fold-func ( acc x -- new-x ) 2 * + ;


: print-test-result ( bool -- ) if ." ok " else ." FAIL " then ;

: test-pairs ( -- )
  cr ." TEST-1: "
  pair-x fst
  1 = print-test-result

  cr ." TEST-2: " 
  pair-x snd
  2 = print-test-result

  cr ." TEST-3: "
  pair-z fst fst
  1 = print-test-result

  cr ." TEST-4: "
  pair-z snd fst
  3 = print-test-result

  cr ." TEST-5: "
  pair-y un-pair
  4 = print-test-result
  3 = print-test-result

  cr ." TEST-6: "
  17 0 node
  head-tail 
  0 = print-test-result
  17 = print-test-result

  cr ." TEST-7: "
  27 vec5 node
  head-tail tail tail head
  30 = print-test-result
  27 = print-test-result

  cr ." TEST-8: "
  vec5 reverse
  head-tail head
  20 = print-test-result
  10 = print-test-result


  cr ." TEST-9: "
  vec5 ['] mul2 swap map
  head-tail head
  80 = print-test-result
  100 = print-test-result


  
;

: run-test ( -- )
  test-pairs
;





\ *** ============================== EXAMPLE ============================== *** \


\ [[[ 1000 ,, node 2000 ,, 3000 ,, 4000 ,, 5000 ]]] constant vec-x1000
\ -1  0 node constant vec-zero


: inc ( n -- n ) 1 + ;
: mul2 ( n -- n ) 2 * ;
: test-fold-func ( acc x -- new-x ) 2 * + ;
\ ' inc singleton ' mul2 append constant vecF

: predicate ( w -- bool ) 25 > ;


\ \ Pairs
\ 1 2 pair constant pair-x
\ 3 4 pair constant pair-y
\ pair-x pair-y pair constant pair-z
\ pair-x fst \ -- 1
\ pair-x snd \ -- 2
\ pair-z fst fst \ -- 1
\ pair-z snd fst \ -- 3
