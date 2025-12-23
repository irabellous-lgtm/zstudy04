CLASS zcs15_email DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
  interFACES if_oo_adt_classrun.

  PROTECTED SECTION.
  PRIVATE SECTION.
 CLASS-METHODS is_email_valid
  IMPORTING iv_email TYPE zemail04
  RETURNING VALUE(rv_valid) TYPE abap_bool.
ENDCLASS.


CLASS zcs15_email IMPLEMENTATION.

 METHOD if_oo_adt_classrun~main.

DATA: lt_data TYPE STANDARD TABLE OF zcs04_copy,
      ls_data TYPE zcs04_copy.


"select table
  SELECT *
  FROM zcs04_copy
  WHERE email IS NOT NULL
    AND email <> ''
  INTO   TABLE @lt_data  .


 LOOP AT lt_data INTO ls_data.

"  check e-mail
 IF is_email_valid( ls_data-email ) = abap_false.

" if false then email in memo


IF ls_data-memo IS INITIAL.
ls_data-memo = |Invalid E-Mail: { ls_data-email }|.
ELSE.
ls_data-memo = |{ ls_data-memo }; Invalid E-Mail: { ls_data-email }|.
ENDIF.


CLEAR ls_data-email.

" modify
    MODIFY zcs04_copy FROM @ls_data.

*UPDATE zcs04_copy
* SET memo = @ls_data-memo,
* email = @ls_data-email
* WHERE company = @ls_data-company
* AND street = @ls_data-street
* AND postcode = @ls_data-postcode
* AND city = @ls_data-city.

*out->write( ls_data ).
  ENDIF.

ENDLOOP.

COMMIT WORK.

out->write( 'OK' ).

endmethod.


METHOD is_email_valid.

  DATA lv_email TYPE string.
  DATA lv_count TYPE i.

" delete space
  lv_email = condense( val = iv_email ).

  FIND REGEX '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'
    IN lv_email
    MATCH COUNT lv_count.

  rv_valid = xsdbool( lv_count > 0 ).

ENDMETHOD.

ENDCLASS.
