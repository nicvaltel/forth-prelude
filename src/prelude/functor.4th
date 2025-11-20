"/home/kolay/prog/forth/src/prelude/list.4th" included

: :r "/home/kolay/prog/forth/src/prelude/functor.4th" included ;


\ Just a = <true, a> \ Nothing = <false, anything>
: just ( a -- maybe<a> ) true pair ;
: nothing ( -- maybe<a> ) 0 false pair ;
  
: is-just ( maybe<a> -- bool ) fst ;
: is-nothing ( maybe<a> -- bool ) fst invert ;


: show-may ( mybe<a> -- )
  un-pair ( a is-just )
  if            ( a )
    ." Just( "
    .           ( )
    ." )"
  else          ( a )
    ." Nothing" ( a )
    drop        ( )
  then
;

\  5 just ' mul2 fmap-maybe => <-1, 10>
: fmap-maybe ( maybe<a> func-xt -- maybe<b> )
  swap        ( func-xt maybe<a> )
  un-pair     ( func-xt a is-just )
  if          ( func-xt a )
    swap      ( a func-xt )
    execute   ( b )
    just      ( maybe<b> )
  else        ( func-xt a )
    drop drop ( )
    nothing   ( maybe<b> )
  then  
;


: pure-maybe ( a -- maybe<a> ) just ;

\ 5 just ' mul2 just app-maybe => <-1,10>
: app-maybe ( maybe<a> maybe<func> -- maybe<b> )
  un-pair   ( maybe<a> func is-just )
  if             ( maybe<a> func )
    fmap-maybe   ( maybe<b> )
  else           ( maybe<a> func )
    drop drop    ( )
    nothing      ( maybe<b> )
  then
;


\ USAGE: ' kleisli1  5 just bind-maybe => Just (50)
: bind-maybe ( kleisli1 maybe<a> -- maybe<b> )
  un-pair     ( kleisli a is-just )
  if          ( kleisli a )
    swap      ( a kleisli )
    execute   ( maybe<b> )
  else        ( kleisli a )
    drop drop ( )
    nothing   ( maybe<b> )    
  then
;

: kleisli1 ( a -- maybe<a> ) 10 * just ;
  
