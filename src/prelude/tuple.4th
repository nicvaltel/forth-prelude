: :r "/home/kolay/prog/forth/src/prelude/tuple.4th" included ;

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



\ *** ============================== TESTING ============================== *** \

\ \ Pairs
2 1 pair constant pair-x
4 3 pair constant pair-y
pair-y pair-x pair constant pair-z

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

: run-test ( -- )
  test-pairs
;
