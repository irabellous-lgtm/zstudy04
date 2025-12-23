CLASS zcl_cs4_importdata DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
    CONSTANTS:
      gc_error   TYPE abap_char1 VALUE 'E',
      gc_warn    TYPE abap_char1 VALUE 'W',
      gc_info    TYPE abap_char1 VALUE 'I',
      gc_Success TYPE abap_char1 VALUE 'S'.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_cs4_importdata IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.

    DATA:
      lt_file     TYPE TABLE OF ztl_00_casestudy,
      lt_customer TYPE TABLE OF zcs04_filedata WITH EMPTY KEY,
      ls_customer TYPE zcs04_filedata,
      lt_Line     TYPE TABLE OF string,
      lt_logTbl04 TYPE TABLE OF zcs04_logtbl.


    TRY.
        SELECT *  FROM ztl_00_casestudy  INTO TABLE @lt_file.
        IF sy-subrc <> 0.
          APPEND  VALUE #( sequence = cl_system_uuid=>create_uuid_x16_static( )
                           error_type = gc_info error_message = 'Table ztl_00_casestudy is Empty' local_created_by = sy-uname local_created_at = sy-datum ) TO lt_logTbl04 .
          MODIFY zcs04_logtbl FROM TABLE @lt_logTbl04.
        ELSE.
          "DELETE FROM zcs04_filedata.
          UPDATE zcs04_filedata SET newpostaddr = @abap_false.
          DELETE FROM zcs04_logtbl.
          COMMIT WORK.

          LOOP AT lt_file INTO DATA(ls_source).
            SPLIT ls_source-import AT ';' INTO TABLE lt_Line.
            IF lines( lt_Line ) < 7.
              APPEND VALUE #( sequence = cl_system_uuid=>create_uuid_x16_static( )
                               error_type = gc_error error_message = | Row of file with Key: { ls_source-uuid } hasnot all columns |  local_created_by = sy-uname local_created_at = sy-datum ) TO lt_logTbl04.
              CONTINUE.
            ENDIF.
            CLEAR ls_customer.
            ls_customer = VALUE zcs04_filedata(
            client   = sy-mandt
            cuid      = cl_system_uuid=>create_uuid_x16_static( )
            company  = replace( val = lt_Line[ 1 ] regex = '"' with = '' occ = 0 )
            street   = replace( val = lt_Line[ 2 ] regex = '"' with = '' occ = 0 )
            postcode = replace( val = lt_Line[ 3 ] regex = '"' with = '' occ = 0 )
            city     = replace( val = lt_Line[ 4 ] regex = '"' with = '' occ = 0 )
            medium   = replace( val = lt_Line[ 5 ] regex = '"' with = '' occ = 0 )
            mvalue1  = replace( val = lt_Line[ 6 ] regex = '"' with = '' occ = 0 )
            mvalue2  = replace( val = lt_Line[ 7 ] regex = '"' with = '' occ = 0 )
          ).

            SELECT SINGLE * FROM zcs04_filedata
             WHERE company = @ls_customer-company AND
                  city = @ls_customer-city AND street = @ls_customer-street AND
                  postcode = @ls_customer-postcode AND
                  medium = @ls_customer-medium AND  mvalue1 = @ls_customer-mvalue1 AND
                  mvalue2 = @ls_customer-mvalue2 INTO @DATA(ls_Temp).
            IF sy-subrc = 0.
              CONTINUE.
            ENDIF.
            CASE to_upper( ls_customer-medium ).
              WHEN  'EMAIL'.
                ls_customer-email = ls_customer-mvalue1.
              WHEN  'TELEFAX'.
                ls_customer-fax = |{ ls_customer-mvalue1 }/{ ls_customer-mvalue2 }|.
              WHEN ''.
                ls_customer-phone = |{ ls_customer-mvalue1 }/{ ls_customer-mvalue2 }|.
              WHEN OTHERS.
                ls_customer-memo = | Es gibt ein ungültiges Medium für den Wert:  { ls_customer-mvalue1 } { ls_customer-mvalue2 }|.
                APPEND VALUE #( sequence = cl_system_uuid=>create_uuid_x16_static( )
                                error_type = gc_warn error_message = | Row of file with Key: { ls_source-uuid }  has invalid data for field medium. |  local_created_by = sy-uname local_created_at = sy-datum ) TO lt_logTbl04 .
            ENDCASE.
            ls_customer-newpostaddr = abap_true.
            APPEND ls_customer TO lt_customer.
          ENDLOOP.
          SORT lt_customer BY company city street postcode medium mvalue1 mvalue2.
          DELETE ADJACENT DUPLICATES FROM lt_customer
            COMPARING company city street postcode medium mvalue1 mvalue2.
          MODIFY zcs04_filedata FROM TABLE @lt_customer.
          IF sy-subrc IS NOT INITIAL.
            APPEND VALUE #( sequence = cl_system_uuid=>create_uuid_x16_static( )
                            error_type = gc_error error_message = 'Data couldnot insert '  local_created_by = sy-uname local_created_at = sy-datum ) TO lt_logTbl04.
          ELSE.
            APPEND  VALUE #( sequence = cl_system_uuid=>create_uuid_x16_static( )
                       error_type = gc_success error_message = 'Data has been imported '
                       local_created_by = sy-uname local_created_at = cl_abap_context_info=>get_system_date( ) )  TO lt_logTbl04 .
          ENDIF.

        ENDIF.
      CATCH cx_sy_open_sql_db INTO DATA(lx_sql1).
        APPEND  VALUE #( sequence = cl_system_uuid=>create_uuid_x16_static( )
                         error_type = gc_error error_message = | Data Couldnot Insert, Database Error: { lx_sql1->get_longtext( ) }| local_created_by = sy-uname local_created_at = sy-datum ) TO lt_logTbl04 .
      CATCH cx_root INTO DATA(lx_error1).
        APPEND  VALUE #( sequence = cl_system_uuid=>create_uuid_x16_static( )
                         error_type = gc_error error_message = | Data Couldnot Insert, Error: { lx_error1->get_longtext( ) }| local_created_by = sy-uname local_created_at = sy-datum ) TO lt_logTbl04 .
    ENDTRY.
    MODIFY zcs04_logtbl FROM TABLE @lt_logTbl04.
  ENDMETHOD.
ENDCLASS.
