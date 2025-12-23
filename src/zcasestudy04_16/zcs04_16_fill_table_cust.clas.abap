CLASS zcs04_16_fill_table_cust DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .

    CONSTANTS:
      gc_error   TYPE abap_char1 VALUE 'E',
      gc_warn    TYPE abap_char1 VALUE 'W',
      gc_info    TYPE abap_char1 VALUE 'I',
      gc_Success TYPE abap_char1 VALUE 'S'.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcs04_16_fill_table_cust IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

  DATA: lt_file        TYPE TABLE OF zcs04_filedata,
          ls_source      TYPE zcs04_filedata,
          I_CheckMessage TYPE char256,
          I_checkFlag    TYPE abap_bool,
          My_badi        TYPE REF TO zcs4_customer_badi.

          clear lt_file.
   APPEND VALUE #( cuid ='12'  email = 'peter*petersen@gmx.de' ) TO lt_file.

out->write( lt_file ).
    LOOP AT lt_file INTO ls_source.
    out->write( ls_source ).
    get badi My_badi.
   CALL BADI My_badi->check_emailvalidation
            EXPORTING
              i_customer = ls_source
             CHANGING
              e_message  = i_checkmessage
              e_result   = i_checkflag.
          IF i_checkflag = abap_false.
            "insert into table exception i_checkmessage
            ls_source-memo = i_checkmessage.
          ENDIF.
  out->write( i_checkmessage ).
  out->write( i_checkflag ).

        ENDLOOP.

*cl_abap_unit_assert=>assert_equals( act = i_checkflag exp = abap_false msg = 'Die E-Mail hans.hansen@web.de ist korrekt und ist valide getestet. ' ).
*cl_abap_unit_assert=>assert_equals( act = i_checkflag exp = abap_true msg =   ls_source-memo ).

*  DATA:
*      lt_count type I value 0,
*      lt_counter type i value 0,
*      lt_import_04     TYPE TABLE OF ztl_00_casestudy,
*      lt_Line     TYPE TABLE OF string,
*      lt_customer_split_04 TYPE TABLE OF zcs04_filedata WITH EMPTY KEY,
*      ls_customer_split_04 TYPE zcs04_filedata,
*      lt_customer_duplicate_04 TYPE  sorted TABLE OF zcs04_filedata WITH Unique KEY company street postcode city,
*      ls_customer_duplikate_04 type zcs04_filedata,
*
*       lt_logTbl04 TYPE TABLE OF zcs04_logtbl.
*
*
*      SELECT * FROM ztl_00_casestudy  INTO TABLE @lt_import_04.
*      select count( * ) from ztl_00_casestudy into @DATA(anzahl).
*out->write( anzahl ).
*
*
*
*      DELETE FROM zcs04_filedata.
*          DELETE FROM zcs04_logtbl.
*          LOOP AT lt_import_04 INTO DATA(ls_source).
*            SPLIT ls_source-import AT ';' INTO TABLE lt_Line.
*            IF lines( lt_Line ) < 7.
*              APPEND VALUE #( sequence = cl_system_uuid=>create_uuid_x16_static( )
*                               error_type = gc_error error_message = 'Row of file with Key: ' && ls_source-uuid && ' hasnot all columns '  local_created_by = sy-uname local_created_at = sy-datum ) TO lt_logTbl04.
*              CONTINUE.
*            ENDIF.
*            CLEAR ls_customer_split_04.
*            ls_customer_split_04 = VALUE zcs04_filedata(
*              company  = replace( val = lt_Line[ 1 ] regex = '"' with = '' occ = 0 )
*              street   = replace( val = lt_Line[ 2 ] regex = '"' with = '' occ = 0 )
*              postcode = replace( val = lt_Line[ 3 ] regex = '"' with = '' occ = 0 )
*              city     = replace( val = lt_Line[ 4 ] regex = '"' with = '' occ = 0 )
*              medium   = replace( val = lt_Line[ 5 ] regex = '"' with = '' occ = 0 )
*              mvalue1  = replace( val = lt_Line[ 6 ] regex = '"' with = '' occ = 0 )
*              mvalue2  = replace( val = lt_Line[ 7 ] regex = '"' with = '' occ = 0 )
*            ).
*
*            CASE to_upper( ls_customer_split_04-medium ).
*              WHEN  'EMAIL'.
*                ls_customer_split_04-email = ls_customer_split_04-mvalue1.
*              WHEN  'TELEFAX'.
*                ls_customer_split_04-fax = ls_customer_split_04-mvalue1 && ls_customer_split_04-mvalue2.
*              WHEN ''.
*                ls_customer_split_04-phone = ls_customer_split_04-mvalue1 && ls_customer_split_04-mvalue2.
*              WHEN OTHERS.
*                ls_customer_split_04-memo = 'Es gibt ein ungültiges Medium für den Wert: ' && ls_customer_split_04-mvalue1 && ls_customer_split_04-mvalue2.
*                APPEND VALUE #( sequence = cl_system_uuid=>create_uuid_x16_static( )
*                                error_type = gc_warn error_message = 'Row of file with Key: ' && ls_source-uuid && ' has invalid data for field medium. '  local_created_by = sy-uname local_created_at = sy-datum ) TO lt_logTbl04 .
*            ENDCASE.
*            ls_customer_split_04-cuid =  lt_count.
*            lt_count = lt_count + 1.
*            APPEND ls_customer_split_04 TO lt_customer_split_04.
*
*          ENDLOOP.
*
*
**modify  zcs04_filedata FROM TABLE @lt_customer_split_04.
*
*Sort lt_customer_split_04 by company street postcode city.
*
*
*loop at lt_customer_split_04 into ls_customer_split_04.
*    MOVE-CORRESPONDING ls_customer_split_04 to ls_customer_duplikate_04.
*    insert ls_customer_duplikate_04 into table lt_customer_duplicate_04.
*    endloop.
*
*DELETE ADJACENT DUPLICATES FROM lt_customer_duplicate_04 comparing company street postcode city.
**out->write( lt_customer_split_04 ).
**out->write( 'Hallo' ).
**out->write( lt_customer_duplicate_04 ).
*out->write( 'Hallo' ).
*
*
*loop at lt_customer_duplicate_04 into ls_customer_duplikate_04.
*
*loop at lt_customer_split_04 into ls_customer_split_04 where phone is not INITIAL and company = ls_customer_duplikate_04-company and street = ls_customer_duplikate_04-street
*and postcode = ls_customer_duplikate_04-postcode and city = ls_customer_duplikate_04-city.
**out->write( ls_customer_split_04-phone ).
**out->write( ls_customer_duplikate_04-phone ).
**out->write( '-' ).
*
*if ls_customer_duplikate_04-phone is initial.
*ls_customer_duplikate_04-phone = ls_customer_duplikate_04-phone && ls_customer_split_04-phone.
*lt_counter = lt_counter + 1.
*endif.
*if ls_customer_duplikate_04-phone is not initial and ls_customer_split_04-phone <> ls_customer_duplikate_04-phone.
*
* ls_customer_duplikate_04-memo = ls_customer_duplikate_04-memo && ' extra Phone:  ' && ls_customer_split_04-phone && ';'.
* lt_counter = lt_counter + 1.
* out->write( 'Duplikat Phone' ).
*out->write( ls_customer_duplikate_04-memo ).
*out->write( '-' ).
*
*endif.
*
*modify lt_customer_duplicate_04 from ls_customer_duplikate_04 transporting phone.
*modify lt_customer_duplicate_04 from ls_customer_duplikate_04 transporting memo.
*
*endloop.
*
*loop at lt_customer_split_04 into ls_customer_split_04 where fax is not INITIAL and company = ls_customer_duplikate_04-company and street = ls_customer_duplikate_04-street
*and postcode = ls_customer_duplikate_04-postcode and city = ls_customer_duplikate_04-city.
**out->write( ls_customer_split_04-phone ).
**out->write( ls_customer_duplikate_04-phone ).
**out->write( '-' ).
*
*if ls_customer_duplikate_04-fax is initial.
*ls_customer_duplikate_04-fax = ls_customer_duplikate_04-fax && ls_customer_split_04-fax.
*lt_counter = lt_counter + 1.
*endif.
*if ls_customer_duplikate_04-fax is not initial and ls_customer_split_04-fax <> ls_customer_duplikate_04-fax.
*
*
* ls_customer_duplikate_04-memo = ls_customer_duplikate_04-memo && ' extra Fax:  ' && ls_customer_split_04-fax && ';'.
* lt_counter = lt_counter + 1.
* out->write( 'Duplikat Fax' ).
*out->write( ls_customer_duplikate_04-memo ).
*out->write( '-' ).
*
*endif.
*
*modify lt_customer_duplicate_04 from ls_customer_duplikate_04 transporting fax.
*modify lt_customer_duplicate_04 from ls_customer_duplikate_04 transporting memo.
*
*endloop.
*
*loop at lt_customer_split_04 into ls_customer_split_04 where email is not INITIAL and company = ls_customer_duplikate_04-company and street = ls_customer_duplikate_04-street
*and postcode = ls_customer_duplikate_04-postcode and city = ls_customer_duplikate_04-city.
**out->write( ls_customer_split_04-phone ).
**out->write( ls_customer_duplikate_04-phone ).
**out->write( '-' ).
*
*
*if ls_customer_duplikate_04-email is initial.
*ls_customer_duplikate_04-email = ls_customer_duplikate_04-email && ls_customer_split_04-email.
*lt_counter = lt_counter + 1.
*endif.
*
*
*if ls_customer_duplikate_04-email is not initial and ls_customer_split_04-email <> ls_customer_duplikate_04-email.
*
* ls_customer_duplikate_04-memo = ls_customer_duplikate_04-memo && ' extra EMail:  ' && ls_customer_split_04-email && ';'.
* lt_counter = lt_counter + 1.
* out->write( 'Duplikat Email' ).
*out->write( ls_customer_duplikate_04-memo ).
*out->write( '-' ).
*
*endif.
*
*modify lt_customer_duplicate_04 from ls_customer_duplikate_04 transporting email.
*modify lt_customer_duplicate_04 from ls_customer_duplikate_04 transporting memo.
*
*endloop.
*
*
*
*
*endloop.
*
**out->write( lt_customer_split_04 ).
*out->write( lt_counter ).
**out->write( lt_customer_duplicate_04 ).
*out->write( 'Hallo6' ).
*
*DELETE FROM zcs04_filedata.
*INSERT   zcs04_filedata  FROM TABLE @lt_customer_duplicate_04.


  ENDMETHOD.
ENDCLASS.
