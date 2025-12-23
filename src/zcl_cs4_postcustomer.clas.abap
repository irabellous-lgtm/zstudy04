CLASS zcl_cs4_postcustomer DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    METHODS post_customer
      EXPORTING
        e_result   TYPE abap_bool
        e_message  TYPE char256
      CHANGING
        i_customer TYPE zcs04_customers
        i_fileData TYPE zcs04_filedata.

    METHODS Update_customer
      IMPORTING
        i_customer   TYPE zcs04_customers
        i_CustomerID TYPE  zcustomerid04
      EXPORTING
        e_result     TYPE abap_bool
        e_message    TYPE char256.

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

  METHOD update_customer.
    DATA: ls_Customer TYPE zcs04_customers,
          new_meme    TYPE zmemo04.
    CLEAR e_Message.
    e_Result = abap_true.
    IF i_customerid IS NOT INITIAL.
      TRY.
          SELECT * FROM zcs04_customers WHERE customerid = @i_customerid INTO @ls_Customer.
          ENDSELECT.
          IF ( i_customer-phone IS NOT INITIAL ).
            IF ( ls_Customer-phone IS INITIAL  ).
              ls_Customer-phone = i_customer-phone .
            ELSE.
              new_meme =  |{ new_meme } extra Phone:  { i_customer-phone } ,| .
            ENDIF.
          ENDIF.
          IF ( i_customer-fax IS NOT INITIAL ).
            IF ( ls_Customer-fax IS INITIAL  ).
              ls_Customer-fax = i_customer-fax .
            ELSE.
              new_meme = |{ new_meme }  extra Fax: { i_customer-fax } ,| .
            ENDIF.
          ENDIF.
          IF ( i_customer-email IS NOT INITIAL ).
            IF ( ls_Customer-email IS INITIAL  ).
              ls_Customer-email = i_customer-email .
            ELSE.
              new_meme = |{ new_meme }  extra Email: { i_customer-email } ,| .
            ENDIF.
          ENDIF.
          ls_Customer-memo =  |{ ls_Customer-memo } { i_customer-memo }  { new_meme }| .
          ls_Customer-customerid = i_customerid.
          ls_Customer-client = sy-mandt.
          MODIFY zcs04_customers FROM @ls_Customer.
          COMMIT WORK.
          IF sy-subrc <> 0.
            e_Result = abap_false.
            e_message = |{ sy-msgty } { sy-msgid }-{ sy-msgno }: { sy-msgv1 }|.
          ENDIF.
        CATCH cx_static_check INTO DATA(lx_post).
          e_Result = abap_false.
          e_message = lx_post->get_longtext(  ).
      ENDTRY.
    ENDIF.
  ENDMETHOD.

  METHOD post_customer.
    e_result  = abap_true.
    CLEAR e_message.
    IF i_customer-first_name IS INITIAL
       AND i_customer-last_name  IS INITIAL
       AND i_customer-company    IS INITIAL.
      e_result  = abap_false.
      e_message = 'Customer has no name or company'.
      RETURN.
    ENDIF.
    i_customer-country = 'DE'.
    i_customer-client = sy-mandt.
    i_customer-local_created_at = sy-datum.
    i_customer-local_created_by = sy-uname.
    TRY.
        MODIFY zcs04_customers FROM @i_customer.
        IF sy-subrc <> 0.
          e_result  = abap_false.
          e_message = | Post failed : { sy-msgty } { sy-msgid }-{ sy-msgno }: { sy-msgv1 }|.
          RETURN.
*        ELSE.
*          i_filedata-newpostaddr = abap_true.
*          UPDATE zcs04_filedata FROM @i_filedata.
*          IF sy-subrc <> 0.
*            e_result  = abap_false.
*            e_message = | Post failed : { sy-msgty } { sy-msgid }-{ sy-msgno }: { sy-msgv1 }|.
*          ENDIF.
        ENDIF.

        COMMIT WORK.
      CATCH cx_static_check INTO DATA(lx_post).
        e_result  = abap_false.
        e_message = lx_post->get_longtext( ).
    ENDTRY.
  ENDMETHOD.

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

            lo_CheckCustomer->check_fields(
              EXPORTING
                i_TblName    = 'ZCS04_CUSTOMERS'
              CHANGING
                i_customer   = ls_source
                e_message    = i_checkmessage
                e_fieldvalue = i_FieldValue
                e_result     = i_checkflag
                ).
            IF i_checkflag = abap_false.
              CLEAR ls_Exception.
              lo_CheckCustomer->post_exception(
                EXPORTING
                  i_infotype      = 'E'
                  i_message       = i_checkmessage
                  i_exceptiontype =  'Field Lenght'
                  i_companyname   = ls_source-company
                  i_fieldvalue    = i_FieldValue
                CHANGING
                  ls_exception    = ls_Exception
                  e_result        = i_checkflag
              ).
              IF i_checkflag = abap_false.
                APPEND VALUE #( sequence = cl_system_uuid=>create_uuid_x16_static( )
                                  error_type = gc_error error_message = | Exception : Update Exception Table| local_created_by = sy-uname local_created_at = sy-datum ) TO lt_logTbl04.
              ENDIF.
            ENDIF.
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
              update_customer(
                EXPORTING
                  i_customer   = ls_customer
                  i_customerid = i_DuplicateID
                IMPORTING
                 e_result     = i_checkflag
                 e_message    = i_checkmessage
              ).
              CONTINUE.
            ENDIF.

*            cl_numberrange_intervals=>create(
*                EXPORTING
*                 object   = 'ZCS4_NUR'
*                  interval = VALUE #(
*                 ( nrrangenr  = '01'        " Interval number
*                 fromnumber = '000001'    " Start
*                 tonumber   = '999999'    " End
*                 externind  = space )  " Internal number range
*                )
*              ).
            cl_numberrange_runtime=>number_get(
              EXPORTING
              object =  'ZCS4_NUR' "'Z17_NURANG'
              subobject = space
              nr_range_nr = '01'
              IMPORTING
                number = DATA(l_number)
            ).
            ls_customer-customerid = l_number.
            IF strlen( l_number ) < 6.
              ls_customer-customerid = l_number.
            ELSE.
              ls_customer-customerid = substring(
                           val = l_number
                           off = 14
                           len = 6 ).
            ENDIF.

            CALL BADI My_badi->incorrectdata_import
              EXPORTING
                i_customer_id  = ls_customer-customerid
                i_errortype    = ls_Exception-infotype
                i_errormessage = ls_Exception-info_message
                i_errorvalue   = ls_Exception-incorrectvalue
              CHANGING
                c_customer     = ls_customer.

            post_customer(
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
              APPEND VALUE #( sequence = cl_system_uuid=>create_uuid_x16_static( )
                                                   error_type = gc_success error_message = |Customer : { ls_customer-customerid } has been posted | local_created_by = sy-uname local_created_at = sy-datum ) TO lt_logTbl04.
            ENDIF.
          ENDLOOP.
          SELECT COUNT( * ) FROM zcs04_filedata
            WHERE newpostaddr = @abap_true
              INTO @Num_PostedRecords.
          IF sy-subrc <> 0.
            Num_PostedRecords = 0.
          ENDIF.
          CALL BADI My_badi->numberof_newpostedrecords
            IMPORTING
              i_count = Num_PostedRecords.

          .
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
