CLASS zcs4_17_badi_class DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES zcs4_17_testinterface .

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcs4_17_badi_class IMPLEMENTATION.


 METHOD zcs4_17_testinterface~Get_CustomerID.

    e_Result = abap_true.
    e_cusomerid = 0.
    TRY.
*cl_numberrange_intervals=>create(
*  EXPORTING
*    object   = 'ZCS4_NUR'
*    interval = VALUE #(
*                 ( nrrangenr  = '01'        " Interval number
*                 fromnumber = '000001'    " Start
*                 tonumber   = '999999'    " End
*                 externind  = space )  " Internal number range
*                )
* ).
        cl_numberrange_runtime=>number_get(
          EXPORTING
          object =  i_object "'Z17_NURANG'
          subobject = space
          nr_range_nr = '01'
          IMPORTING
            number = DATA(l_number)
        ).
        e_cusomerid = l_number.

        IF strlen( l_number ) < 6.
          e_cusomerid = l_number.
        ELSE.
          e_cusomerid = substring(
                       val = l_number
                       off = strlen( l_number ) - 6
                       len = 6 ).
        ENDIF.
      CATCH cx_root  INTO DATA(cx_message).
        e_Result = abap_false.
    ENDTRY.
  ENDMETHOD.

  METHOD zcs4_17_testinterface~Check_FieldLength.

    e_Message = ''.
    e_Result = abap_true.

    IF strlen( i_customer-company ) > 60.
      e_Message = ' Lenght of Company is more than 60 Char'.
      e_Result = abap_false.
      RETURN.
    ENDIF.

    IF strlen( i_customer-city ) > 30.
      e_Message = ' Lenght of City is more than 30 Char'.
      e_Result = abap_false.
      RETURN.
    ENDIF.

    IF strlen( i_customer-street ) > 50.
      e_Message = ' Lenght of Street is more than 50 Char'.
      e_Result = abap_false.
      RETURN.
    ENDIF.

    IF strlen( i_customer-postcode ) > 8.
      e_Message = ' Lenght of postcode is more than 8 Char'.
      e_Result = abap_false.
      RETURN.
    ENDIF.
  ENDMETHOD.

  METHOD zcs4_17_testinterface~Check_DuplicateRows.
    e_Message = ''.
    e_Result = abap_true.
    SELECT SINGLE customerid
      FROM zcs17_customers
      WHERE company  = @i_customer-company
        AND city     = @i_customer-city
        AND street   = @i_customer-street
        AND postcode = @i_customer-postcode
      INTO @DATA(lv_existing).

    IF sy-subrc = 0.
      e_Message = ' We have douplicate data for this Company :  ' && i_customer-company.
      e_Result = abap_false.
      e_ID     = lv_existing.
    ENDIF.

  ENDMETHOD.

  METHOD zcs4_17_testinterface~Check_EmailValidation.
    e_Message = ''.
    e_Result = abap_true.
    DATA: lv_pattern TYPE string VALUE
            '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$',
          lo_matcher TYPE REF TO cl_abap_matcher.

    e_result  = abap_true.
    CLEAR e_message.

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


  METHOD zcs4_17_testinterface~Post_Customer.
    e_Message = ''.
    e_Result = abap_true.
    IF ( i_customer-first_name IS NOT INITIAL ) OR
       ( i_customer-last_name IS NOT INITIAL ) OR
       ( i_customer-company IS NOT INITIAL ).
      TRY.
          MODIFY zcs17_customers FROM @i_customer.
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

  METHOD zcs4_17_testinterface~Update_Customer.
    DATA: ls_Customer TYPE zcs17_customers,
          new_meme    TYPE zmemo04.
    e_Message = ''.
    e_Result = abap_true.
    IF i_customerid IS NOT INITIAL.
      TRY.
          SELECT * FROM zcs17_customers WHERE customerid = @i_customerid INTO @ls_Customer.
          ENDSELECT.
          IF ( i_customer-phone IS NOT INITIAL ).
            IF ( ls_Customer-phone IS INITIAL  ).
              ls_Customer-phone = i_customer-phone .
            ELSE.
              new_meme =  new_meme && '  extra Phone:  ' &&  i_customer-phone && ',' .
            ENDIF.
          ENDIF.
          IF ( i_customer-fax IS NOT INITIAL ).
            IF ( ls_Customer-fax IS INITIAL  ).
              ls_Customer-fax = i_customer-fax .
            ELSE.
              new_meme =  new_meme && ' extra Fax:  ' &&  i_customer-fax && ','.
            ENDIF.
          ENDIF.
          IF ( i_customer-email IS NOT INITIAL ).
            IF ( ls_Customer-email IS INITIAL  ).
              ls_Customer-email = i_customer-email .
            ELSE.
              new_meme = new_meme && ' extra Email:  ' &&  i_customer-email && ','.
            ENDIF.
          ENDIF.
          ls_Customer-memo =  ls_Customer-memo && i_customer-memo && new_meme.
          ls_Customer-customerid = i_customerid.
          ls_Customer-client = sy-mandt.
          MODIFY zcs17_customers FROM @ls_Customer.
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


ENDCLASS.
