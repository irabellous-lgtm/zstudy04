CLASS zcl_cs4_postcustomer DEFINITION
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



CLASS zcl_cs4_postcustomer IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.

    DATA : lt_logTbl04       TYPE TABLE OF zcs04_logtbl,
           lt_file           TYPE TABLE OF zcs04_filedata,
           ls_source         TYPE zcs04_filedata,
           I_CheckMessage    TYPE char256,
           i_FieldValue      TYPE char256,
           I_checkFlag       TYPE abap_bool,
           i_DuplicateID     TYPE  zcustomerid04,
           ls_customer       TYPE  zcs04_customers,
           My_badi           TYPE REF TO zcs4_customer_badi,
           ls_Exception      TYPE zcs04_exception,
           Num_PostedRecords TYPE int4
           .

    TRY.
        DELETE FROM zcs04_logtbl.
        "DELETE FROM zcs04_customers.
        "DELETE FROM zcs04_exception .
        COMMIT WORK.
        GET BADI My_badi.
        DATA(lo_CheckCustomer) = NEW zcl_cs4_importcustomer( ).
        SELECT company, city, street, postcode, fax, phone, email, memo
         FROM zcs04_filedata WHERE newpostaddr = @abap_true  INTO CORRESPONDING FIELDS OF TABLE @lt_file.
        IF sy-subrc IS INITIAL.

          LOOP AT lt_file INTO ls_source.
            CLEAR i_DuplicateID.
            CLEAR ls_Exception.
            ls_customer = CORRESPONDING #( ls_source ).
            lo_CheckCustomer->check_duplicaterows(
              EXPORTING
                i_customer = ls_customer
              CHANGING
                e_message  = i_checkmessage
                e_result   = i_checkflag
                e_ID       = i_DuplicateID
                ).

            IF i_checkflag = abap_false.
              ls_customer-customerid = i_DuplicateID.
            ELSE.
              TRY.
                lo_CheckCustomer->Get_CustomerId(
                 EXPORTING
                   i_object    = 'ZCS4_NUR'
                 IMPORTING
                   e_cusomerid = ls_customer-customerid
                   e_result    = i_checkflag
                 ).
              CATCH cx_static_check INTO DATA(lx_GetNum_err).
                i_checkflag  = abap_false.
                lo_CheckCustomer->insert_log( i_message = | Exception : ' {  lx_GetNum_err->get_text( ) }|  i_errtype = gc_error ).
                CONTINUE.
              ENDTRY.
              IF i_checkflag = abap_false.
                "insert into table exception Get number range has error
                CONTINUE.
              ENDIF.
            ENDIF.

            CALL BADI My_badi->checkdata_import
              EXPORTING
                i_customer_id  = ls_customer-customerid
                i_FileData     = ls_source
              CHANGING
                c_customer     = ls_customer
                c_Exceptions   = ls_Exception.

            IF ls_Exception-exception_type IS NOT INITIAL.
              lo_CheckCustomer->post_exception( CHANGING c_Exception = ls_Exception c_result = i_checkflag ).
            ENDIF.

            lo_CheckCustomer->check_fields(
              EXPORTING
                i_TblName    = 'ZCS04_CUSTOMERS'
                i_keyfield   = CONV char100( ls_customer-customerid )
              CHANGING
                i_customer   = ls_source
                e_message    = i_checkmessage
                e_result     = i_checkflag
                ).
              IF i_checkflag = abap_false.
                lo_CheckCustomer->insert_log( i_message =   | Exception : Update Exception Table|  i_errtype = gc_error ).
              ENDIF.

            lo_CheckCustomer->check_emailvalidation(
              EXPORTING
                i_customer = ls_source
                i_keyfield = CONV char100( ls_customer-customerid )
              CHANGING
                e_message  = i_checkmessage
                e_result   = i_checkflag
                new_email  = ls_source-email
            ).
            IF i_checkflag = abap_false.
              "insert into table exception i_checkmessage
              ls_source-memo = i_checkmessage.
            ENDIF.

            IF i_DuplicateID IS NOT INITIAL.
              lo_CheckCustomer->update_customer(
                EXPORTING
                  i_customer   = ls_customer
                  i_customerid = i_DuplicateID
                IMPORTING
                 e_result     = i_checkflag
                 e_message    = i_checkmessage
              ).
              CONTINUE.
            ENDIF.

            lo_CheckCustomer->post_customer(
              IMPORTING
                e_result   = i_checkflag
                e_message  = i_checkmessage
              CHANGING
                i_customer = ls_customer
                i_fileData = ls_source
            ).

            IF i_checkflag = abap_false.
              "insert into table exception Company ... can not be inserted
            ELSE.
             lo_CheckCustomer->insert_log( i_message =  |Customer : { ls_customer-customerid } has been posted | i_errtype = gc_success ).
            ENDIF.
          ENDLOOP.
          SELECT COUNT( * ) FROM zcs04_filedata
            WHERE newpostaddr = @abap_true
              INTO @Num_PostedRecords.
          IF sy-subrc <> 0.
            Num_PostedRecords = 0.
          ENDIF.

          CALL BADI My_badi->numberof_newpostedrecords
            EXPORTING
              i_Count = Num_PostedRecords.
          i_checkmessage = | Number of new posted recorsd are : { Num_PostedRecords }| .
        ENDIF.

      CATCH cx_a4c_bc_exception INTO DATA(lx_nr).
        APPEND VALUE #( sequence = cl_system_uuid=>create_uuid_x16_static( )
                                     error_type = gc_error error_message = | Exception : ' {  lx_nr->get_longtext( ) }| local_created_by = sy-uname local_created_at = sy-datum ) TO lt_logTbl04.

      CATCH cx_nr_object_not_found INTO DATA(lx_found).
        APPEND VALUE #( sequence = cl_system_uuid=>create_uuid_x16_static( )
                                      error_type = gc_error error_message = | Exception number range object :  {  lx_found->get_longtext( ) }| local_created_by = sy-uname local_created_at = sy-datum ) TO lt_logTbl04.

      CATCH cx_number_ranges INTO DATA(lx_range).
        APPEND VALUE #( sequence = cl_system_uuid=>create_uuid_x16_static( )
                                      error_type = gc_error error_message = | Exception number range object : { lx_range->get_longtext( ) }| local_created_by = sy-uname local_created_at = sy-datum ) TO lt_logTbl04.

      CATCH cx_static_check INTO DATA(lx_check).
        APPEND VALUE #( sequence = cl_system_uuid=>create_uuid_x16_static( )
                                      error_type = gc_error error_message = |Exception number range object : { lx_check->get_longtext( ) }| local_created_by = sy-uname local_created_at = sy-datum ) TO lt_logTbl04.
      CATCH cx_root INTO DATA(lx_AllErr).
        APPEND VALUE #( sequence = cl_system_uuid=>create_uuid_x16_static( )
                                      error_type = gc_error error_message = | Exception  : { lx_AllErr->get_longtext( ) }| local_created_by = sy-uname local_created_at = sy-datum ) TO lt_logTbl04.

        MODIFY zcs04_logtbl FROM TABLE @lt_logTbl04.

    ENDTRY.


  ENDMETHOD.


ENDCLASS.
