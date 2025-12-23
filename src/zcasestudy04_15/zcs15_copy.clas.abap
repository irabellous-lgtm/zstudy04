CLASS zcs15_copy DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcs15_copy IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

  DATA lt_data TYPE STANDARD TABLE OF zcs15_filedata.

  delete from zcs15_filedata.

SELECT *
  FROM zcs04_filedata
  INTO CORRESPONDING FIELDS OF TABLE @lt_data.

INSERT   zcs15_filedata
  FROM TABLE @lt_data.

out->write( 'ok' ).

  ENDMETHOD.
ENDCLASS.
