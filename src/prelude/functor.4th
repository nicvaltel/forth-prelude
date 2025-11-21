"/home/kolay/prog/forth/src/prelude/list.4th" included

: :r "/home/kolay/prog/forth/src/prelude/functor.4th" included ;




\ USAGE: 5 just ; \ Nothing = 0
: just ( a -- maybe<a> )
  cell allocate throw ( a adr ) \ alloc 1 cell of memory
  tuck                ( adr a adr )  
  !                   ( adr ) \ save a to adr
;

: nothing ( -- maybe<a> ) 0 ;

: is-just ( maybe<a> -- bool ) 0<> ;
: is-nothing ( maybe<a> -- bool ) 0= ;

: from-just ( maybe<a> -- a ) @ ;

: show-may ( mybe<a> -- )
  dup      ( may may )
  if            ( just<a> )
    ." Just( "
    from-just .  ( )
    ." )"
  else          ( nothing )
    drop        ( )
    ." Nothing" ( )
  then
;

\  5 just ' mul2 fmap-maybe => Just(10) ; nothing ' inc fmap-maybe => Nothing
: fmap-maybe ( maybe<a> func-xt -- maybe<b> )
  swap        ( func-xt may )
  dup         ( func-xt may may )
  is-just     ( func-xt may ?just )
  if          ( func-xt may ) \ when just
    from-just ( func-xt a )
    swap      ( a func-xt )
    execute   ( b )
    just      ( maybe<b> )
  else        ( func-xt nothing ) \ when nothing
    swap drop ( nothing )
  then
;

: pure-maybe ( a -- maybe<a> ) just ;

\ 5 just ' mul2 just app-maybe => Just (10)
: app-maybe ( maybe<a> maybe<func> -- maybe<b> )
  dup       ( may<a> may<f> may<f> )
  is-just   ( may<a> may<f> ?just )
  if             ( maybe<a> maybe<f> ) \ when may<f> is just
    from-just    ( maybe<a> f )
    fmap-maybe   ( maybe<b> )
  else           ( maybe<a> nothing ) \ when may<f> is nothing
    swap drop    ( nothing )
  then
;


\ USAGE: ' kleisli1  5 just bind-maybe => Just (50)
: bind-maybe ( kleisli1 maybe<a> -- maybe<b> )
  dup         ( kleisli1 may<a> may<a> )
  is-just     ( kleisli1 may<a> ?just )
  if          ( kleisli may<a> ) \ when may<a> is just
    from-just ( kleisli a )
    swap      ( a kleisli )
    execute   ( maybe<b> )
  else        ( kleisli nothing )
    swap
    drop      ( nothing )
  then
;

: kleisli1 ( a -- maybe<a> ) 10 * just ;
  
