CLASS zcl_cs4_importcustomer DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    DATA : Customer_badi    TYPE REF TO zcs4_customer_badi.
    TYPES ty_t_FileData TYPE TABLE OF ztl_00_casestudy.

    CLASS-METHODS :
      Post_Exception
        CHANGING
          c_Result    TYPE abap_bool
          c_Exception TYPE zcs04_exception
        .
    METHODS : check_fields
      IMPORTING
        i_TblName  TYPE char256
        i_keyfield TYPE char100
      CHANGING
        i_customer TYPE zcs04_filedata
        e_Message  TYPE char256
        e_Result   TYPE abap_bool
      ,
      Check_DuplicateRows
        IMPORTING
          i_customer TYPE zcs04_customers
        CHANGING
          e_Message  TYPE char256
          e_Result   TYPE abap_bool
          e_ID       TYPE  zcustomerid04
        ,

      Get_CustomerId
        IMPORTING
          i_Object    TYPE  char10
        EXPORTING
          e_CusomerID TYPE  zcustomerid04
          e_Result    TYPE abap_bool
        RAISING
          cx_static_check
        ,
      Check_EmailValidation
        IMPORTING
          i_customer TYPE zcs04_filedata
          i_keyfield TYPE char100
        CHANGING
          e_Message  TYPE char256
          e_Result   TYPE abap_bool
          New_Email  TYPE char256
        ,

      post_customer
        EXPORTING
          e_result   TYPE abap_bool
          e_message  TYPE char256
        CHANGING
          i_customer TYPE zcs04_customers
          i_fileData TYPE zcs04_filedata
        ,

      Update_customer
        IMPORTING
          i_customer   TYPE zcs04_customers
          i_CustomerID TYPE  zcustomerid04
        EXPORTING
          e_result     TYPE abap_bool
          e_message    TYPE char256
        ,
      Get_fileData
        EXPORTING
          e_FileRows TYPE ty_t_FileData
          e_result   TYPE abap_bool
          e_message  TYPE char256
        ,
      Split_FileRow
        IMPORTING
          i_FileRow  TYPE ztl_00_casestudy
        EXPORTING
          e_customer TYPE zcs04_filedata
          e_result   TYPE abap_bool
          e_message  TYPE char256
        RAISING
          cx_uuid_error
        ,
      Insert_filerow
        IMPORTING
          i_Suuid     TYPE sysuuid_x16
        EXPORTING
          e_result    TYPE abap_bool
          e_message   TYPE char256
        CHANGING
          ls_customer TYPE zcs04_filedata
        ,
      Insert_Log
        IMPORTING
          i_message TYPE char256
          i_ErrType TYPE char1
        .

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_cs4_importcustomer IMPLEMENTATION.

  METHOD check_fields.

    DATA : lv_is_valid  TYPE abap_bool VALUE abap_true,
           lo_struct    TYPE REF TO cl_abap_structdescr,
           lt_comp      TYPE cl_abap_structdescr=>component_table,
           ls_exception TYPE zcs04_exception,
           ls_comp      LIKE LINE OF lt_comp
           .
    CLEAR e_Message.
    e_Result = abap_true.

    FIELD-SYMBOLS <fs_value> TYPE any.
    lo_struct ?= cl_abap_structdescr=>describe_by_name( i_tblname ).
    lt_comp = lo_struct->get_components( ).

    LOOP AT lt_comp INTO ls_comp.
      IF ls_comp-type->kind <> cl_abap_typedescr=>kind_elem.
        CONTINUE.
      ENDIF.
      DATA(lo_elem) = CAST cl_abap_elemdescr( ls_comp-type ).
      ASSIGN COMPONENT ls_comp-name OF STRUCTURE i_customer TO <fs_value>.
      DATA(Component_lenght) = CAST cl_abap_elemdescr( ls_comp-type )->output_length.
      IF sy-subrc = 0 AND strlen( |{ <fs_value> }| ) > Component_lenght.
        ls_exception-infotype = 'E'.
        ls_Exception-info_message = | The value of field { ls_comp-name } with Value : { <fs_value> } exceeds the defined length for this field. |.
        ls_Exception-exception_type = 'Field Lenght Incorrect'.
        ls_Exception-incorrectvalue = |{ <fs_value> }| .
        ls_Exception-key_field = i_keyfield.
        zcl_cs4_importcustomer=>Post_Exception( CHANGING c_exception = ls_Exception c_result = e_Result ).
        CLEAR ls_exception.
        e_Result = abap_false.
        e_Message = | Find Incorrect Field Lenght |.
      ENDIF.
    ENDLOOP.
*    i_customer-company = COND string( WHEN strlen( i_customer-company ) > 60 THEN i_customer-company+0(60) ELSE i_customer-company ).
  ENDMETHOD.

  METHOD Check_DuplicateRows.
    CLEAR e_Message.
    e_Result = abap_true.
    SELECT SINGLE customerid
      FROM zcs04_customers
      WHERE company  = @i_customer-company
        AND city     = @i_customer-city
        AND street   = @i_customer-street
        AND postcode = @i_customer-postcode
      INTO @DATA(lv_existing).

    IF sy-subrc = 0.
      e_Message = | We have douplicate data for this Company :  { i_customer-company }|.
      e_Result = abap_false.
      e_ID     = lv_existing.
    ENDIF.

  ENDMETHOD.

  METHOD Check_EmailValidation.
    DATA : ls_exception TYPE zcs04_exception.
    TRY.
        e_result = abap_true.
        GET BADI Customer_badi.
        CALL BADI Customer_badi->check_emailvalidation
          EXPORTING
            i_customer     = i_customer
          CHANGING
            Email_Addr     = new_email
            Err_Message    = e_message
            Email_Validity = e_result.
        IF e_result = abap_false.
          ls_exception-infotype = 'E'.
          ls_Exception-info_message = | The value of field Email with Value : { i_customer-email } is incorrect. |.
          ls_Exception-exception_type = 'Email is Incorrect'.
          ls_Exception-incorrectvalue = |{ i_customer-email }| .
          ls_Exception-key_field = i_keyfield.
          zcl_cs4_importcustomer=>Post_Exception( CHANGING c_exception = ls_Exception c_result = e_Result ).
        ENDIF.
      CATCH cx_badi_not_implemented INTO DATA(cxBadi_Err).
    ENDTRY.
    e_Message = ''.
    e_Result = abap_true.
    DATA: lv_pattern TYPE string VALUE
            '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$',
          lo_matcher TYPE REF TO cl_abap_matcher.

    e_result  = abap_true.
    CLEAR e_message.
    new_email = i_customer-email.
    IF i_customer-email IS NOT INITIAL.
      lo_matcher = cl_abap_matcher=>create(
        pattern = lv_pattern
        text    = i_customer-email
      ).
      IF lo_matcher->match( ) = abap_false.
        e_message = 'Email has invalid format'.
        e_result  = abap_false.
      ENDIF.
    ENDIF.

  ENDMETHOD.

  METHOD Post_Exception.
    c_Result = abap_True.
    c_Exception-client = sy-mandt.
    c_Exception-Exc_ID = cl_system_uuid=>create_uuid_x16_static( ).
    c_Exception-log_date = sy-datum.
    c_Exception-log_tim = sy-timlo.
    INSERT zcs04_exception FROM @c_Exception.
    IF sy-subrc <> 0.
      c_result  = abap_false.
    ENDIF.
  ENDMETHOD.


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


  METHOD get_customerid.
    e_result = abap_true.
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
    e_CusomerID = l_number.
    IF strlen( l_number ) < 6.
      e_CusomerID = l_number.
    ELSE.
      e_CusomerID = substring(
                   val = l_number
                   off = 14
                   len = 6 ).
    ENDIF.


  ENDMETHOD.

  METHOD Get_fileData.
    e_result = abap_true.
    CLEAR e_message.
    SELECT *  FROM ztl_00_casestudy INTO TABLE @e_FileRows .
    IF sy-subrc <> 0.
      e_result = abap_false.
      e_message = | Read File unsuccessful.|.
    ELSE.
      e_result = abap_true.

      UPDATE zcs04_filedata SET newpostaddr = @abap_false.
      DELETE FROM zcs04_logtbl.
      COMMIT WORK.
    ENDIF.
  ENDMETHOD.

  METHOD split_filerow.
    e_result = abap_true.
    CLEAR e_message.
    DATA: lt_Line TYPE TABLE OF string.
    SPLIT i_filerow-import AT ';' INTO TABLE lt_Line.
    IF lines( lt_Line ) <> 7.
      e_result = abap_false.
      e_message = | Row of file with Key: { i_filerow-uuid } hasnot Correct format columns |.
      RETURN.
    ENDIF.
    CLEAR e_customer.
    e_customer = VALUE zcs04_filedata(
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
  ENDMETHOD.

  METHOD insert_filerow.
    e_result = abap_true.
    CLEAR e_message.
    SELECT SINGLE * FROM zcs04_filedata
                 WHERE company = @ls_customer-company AND
                      city = @ls_customer-city AND street = @ls_customer-street AND
                      postcode = @ls_customer-postcode AND
                      medium = @ls_customer-medium AND  mvalue1 = @ls_customer-mvalue1 AND
                      mvalue2 = @ls_customer-mvalue2 INTO @DATA(ls_Temp).
    IF sy-subrc = 0.
      e_result = abap_false.
      RETURN.
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
        e_message = | Row of file with Key: { i_Suuid }  has invalid data for field medium. | .
    ENDCASE.
    ls_customer-newpostaddr = abap_true.
  ENDMETHOD.

  METHOD insert_log.
    DATA : lt_logTbl04 TYPE TABLE OF zcs04_logtbl.
    APPEND  VALUE #( sequence = cl_system_uuid=>create_uuid_x16_static( )
                     error_type = i_errtype error_message = i_message local_created_by = sy-uname local_created_at = sy-datum ) TO lt_logTbl04 .
    MODIFY zcs04_logtbl FROM TABLE @lt_logTbl04.
  ENDMETHOD.

ENDCLASS.
