CLASS zcl04_17_postcustomer DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun .
    CONSTANTS :
      gc_error   TYPE abap_char1 VALUE 'E',
      gc_warn    TYPE abap_char1 VALUE 'W',
      gc_info    TYPE abap_char1 VALUE 'I',
      gc_Success TYPE abap_char1 VALUE 'S'.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl04_17_postcustomer IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.

    DATA : lt_logTbl04    TYPE TABLE OF zcs04_logtbl,
           lt_file        TYPE TABLE OF zcs17_customers,
           ls_source      TYPE zcs17_customers,
           I_CheckMessage TYPE char256,
           I_checkFlag    TYPE abap_bool,
           i_DuplicateID  TYPE  ZCUSTOMERID04
           .

    TRY.
        DELETE FROM zcs04_logtbl.
        DELETE FROM zcs17_customers.
        COMMIT WORK.
        SELECT company, city, street, postcode, fax, phone, email, memo
         FROM zcs04_filedata INTO CORRESPONDING FIELDS OF TABLE @lt_file.
        IF sy-subrc IS INITIAL.
          LOOP AT lt_file INTO ls_source.
            DATA My_badi TYPE REF TO ZCS4_CUSTOMER_BADI.
            GET BADI My_badi.

            CALL BADI My_badi->check_fieldlength
              EXPORTING
                i_customer = ls_source
              IMPORTING
                e_message  = i_checkmessage
                e_result   = i_checkflag.
            IF i_checkflag = abap_false.
              "insert into table exception i_checkmessage
              CONTINUE.
            ENDIF.

            CALL BADI My_badi->check_emailvalidation
              EXPORTING
                i_customer = ls_source
              IMPORTING
                e_message  = i_checkmessage
                e_result   = i_checkflag.
            IF i_checkflag = abap_false.
              "insert into table exception i_checkmessage
*              ls_source-memo = ' Email has invalid format'.
               IF ls_source-memo IS INITIAL.
                ls_source-memo = i_checkmessage.
                    ELSE.
                ls_source-memo = ls_source-memo && `; ` && i_checkmessage.
               ENDIF.
            ENDIF.

            CALL BADI My_badi->check_duplicaterows
              EXPORTING
                i_customer = ls_source
              IMPORTING
                e_message  = i_checkmessage
                e_result   = i_checkflag
                e_ID       = i_DuplicateID.

            IF i_checkflag = abap_false.
            CALL BADI My_badi->update_customer
              EXPORTING
                i_customer   = ls_source
                i_customerid = i_DuplicateID
              IMPORTING
                e_message    = i_checkmessage
                e_result     = i_checkflag.
              "insert into table exception i_checkmessage
              CONTINUE.
            ENDIF.

            CALL BADI My_badi->get_customerid
              EXPORTING
                i_object    = 'Z17_NURANG'
              IMPORTING
                e_cusomerid = ls_source-customerid
                e_result    = i_checkflag.
            IF i_checkflag = abap_false.
              "insert into table exception Get number range has error
              CONTINUE.
            ENDIF.              .

            ls_source-country = 'DE'.
            ls_source-client = sy-mandt.
            ls_source-local_created_at = sy-datum.
            ls_source-local_created_by = sy-uname.
            CALL BADI My_badi->post_customer
              EXPORTING
                i_customer = ls_source
              IMPORTING
                e_message  = i_checkmessage
                e_result   = i_checkflag.
            IF i_checkflag = abap_false.
              "insert into table exception Company ... can not be inserted
            ELSE.
              APPEND VALUE #( sequence = cl_system_uuid=>create_uuid_x16_static( )
                                                   error_type = gc_success error_message = 'Customer : ' && ls_source-customerid && ' has been posted' local_created_by = sy-uname local_created_at = sy-datum ) TO lt_logTbl04.
            ENDIF.
          ENDLOOP.
        ENDIF.
      CATCH cx_a4c_bc_exception INTO DATA(lx_nr).
        APPEND VALUE #( sequence = cl_system_uuid=>create_uuid_x16_static( )
                                     error_type = gc_error error_message = 'Exception : ' && lx_nr->get_longtext( ) local_created_by = sy-uname local_created_at = sy-datum ) TO lt_logTbl04.

      CATCH cx_nr_object_not_found INTO DATA(lx_found).
        APPEND VALUE #( sequence = cl_system_uuid=>create_uuid_x16_static( )
                                      error_type = gc_error error_message = 'Exception number range object : ' && lx_found->get_longtext( ) local_created_by = sy-uname local_created_at = sy-datum ) TO lt_logTbl04.

      CATCH cx_number_ranges INTO DATA(lx_range).
        APPEND VALUE #( sequence = cl_system_uuid=>create_uuid_x16_static( )
                                      error_type = gc_error error_message = 'Exception number range object : ' && lx_range->get_longtext( ) local_created_by = sy-uname local_created_at = sy-datum ) TO lt_logTbl04.

      CATCH cx_static_check INTO DATA(lx_check).
        APPEND VALUE #( sequence = cl_system_uuid=>create_uuid_x16_static( )
                                      error_type = gc_error error_message = 'Exception number range object : ' && lx_check->get_longtext( ) local_created_by = sy-uname local_created_at = sy-datum ) TO lt_logTbl04.
      CATCH cx_root INTO DATA(lx_AllErr).
        APPEND VALUE #( sequence = cl_system_uuid=>create_uuid_x16_static( )
                                      error_type = gc_error error_message = 'Exception  : ' && lx_AllErr->get_longtext( ) local_created_by = sy-uname local_created_at = sy-datum ) TO lt_logTbl04.

        MODIFY zcs04_logtbl FROM TABLE @lt_logTbl04.

    ENDTRY.



  ENDMETHOD.
ENDCLASS.
