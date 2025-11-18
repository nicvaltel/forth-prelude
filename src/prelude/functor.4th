"/home/kolay/prog/forth/src/prelude/list.4th" included

: :r "/home/kolay/prog/forth/src/prelude/functor.4th" included ;



: just ( a -- maybe<a> ) true pair ;
: nothing ( -- maybe<a> ) 0 false pair ;
  
: is-just ( maybe<a> -- bool ) snd ;
: is-nothing ( maybe<a> -- bool ) snd invert ;


: show-may ( mybe<a> -- )
  un-pair ( a is-just)
  if            ( a )
    ." Just( "
    .           ( )
    ." )"
  else          ( a )
    ." Nothing" ( a )
    drop        ( )
  then
;



\ ' mul2 5 just fmap-maybe => <10, -1>
: fmap-maybe ( func-xt maybe<a> -- maybe<b> )
  un-pair     ( func-xt a is-just )
  if          ( func-xt a)
    swap      ( a func-xt )
    execute   ( b )
    just      ( maybe<b> )
  else        ( func-xt a )
    drop drop ( )
    nothing   ( maybe<b> )
  then  
;



: pure-maybe ( a -- maybe<a> ) just ;


: app-maybe ( maybe<func> maybe<a> -- maybe<b> )
  swap un-pair   ( maybe<a> func is-just )
  if             ( maybe<a> func )
    swap         ( funct maybe<a> )
    fmap-maybe   ( maybe<b> )
  else           ( maybe<a> func )
    drop drop    ( )
    nothing      ( maybe<b> )
  then
;



\ USAGE: 5 just ' kleisli1 bind-maybe 
: bind-maybe ( maybe<a> kleisli -- maybe<b> )
  swap        ( kleisli maybe<a> )
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
  
