: :r "/home/kolay/prog/forth/src/prelude/adt.4th" included ;

"/home/kolay/prog/forth/src/prelude/list.4th" included


\ : adt ( adt-data adt-type-id -- adt ) pair ;

\ : get-adt-type-id ( adt -- adt-type-id ) fst ;

\ : get-adt-data ( adt -- adt-data ) snd ;


: adt-type ( list-constructors adt-type-id -- adt-type ) pair ;

: get-adt-type-id ( adt-type -- adt-type-id ) fst ;

: get-adt-type-constructors ( adt-type -- list-constructors ) snd ;


: constructor ( list-adt constructor-id ) pair ;

: get-constructor-id ( constructor -- constructor-id ) fst ;

: get-constructor-list-adt ( constructor -- list-adt ) snd ;


: adt ( constructor adt-id -- adt ) pair ;

: get-adt-id ( adt -- adt-id ) fst ;

: get-adt-constructors ( adt -- constructor ) snd ;










1 constant adt-data-type-int


: adt-int ( n -- adt )
  adt-data-type-int ( n adt-int-data-type )
  adt
;

: un-adt-int ( adt -- n ) snd ;

