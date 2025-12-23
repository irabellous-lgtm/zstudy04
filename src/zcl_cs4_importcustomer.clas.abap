CLASS zcl_cs4_importcustomer DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    METHODS check_fields
      IMPORTING
        i_TblName    TYPE char256
      CHANGING
        i_customer   TYPE zcs04_filedata
        e_Message    TYPE char256
        e_Result     TYPE abap_bool
        e_FieldValue TYPE char256
      .
    METHODS Check_DuplicateRows
      IMPORTING
        i_customer TYPE zcs04_customers
      CHANGING
        e_Message  TYPE char256
        e_Result   TYPE abap_bool
        e_ID       TYPE  zcustomerid04
      .

    METHODS Check_EmailValidation
      IMPORTING
        i_customer TYPE zcs04_filedata
      CHANGING
        e_Message  TYPE char256
        e_Result   TYPE abap_bool
      .
    METHODS Post_Exception
      IMPORTING
        i_infotype      TYPE char1
        i_Message       TYPE char256
        i_exceptionType TYPE char256
        i_CompanyName   TYPE char256
        i_FieldValue    TYPE char256
      CHANGING
        ls_Exception    TYPE zcs04_exception
        e_Result        TYPE abap_bool
      .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_cs4_importcustomer IMPLEMENTATION.

  METHOD check_fields.

    DATA : lv_is_valid TYPE abap_bool VALUE abap_true,
           lo_struct   TYPE REF TO cl_abap_structdescr,
           lt_comp     TYPE cl_abap_structdescr=>component_table,
           ls_comp     LIKE LINE OF lt_comp.
    CLEAR e_Message.
    e_Result = abap_true.
    CLEAR e_fieldvalue.
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
        e_Result = abap_false.
        e_fieldvalue = |{ <fs_value> }| .
        e_Message = | The value of field { ls_comp-name } with Value : { <fs_value> } exceeds the defined length for this field. |.
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

  METHOD Post_Exception.
    e_Result = abap_True.
    ls_Exception-client = sy-mandt.
    ls_Exception-Exc_ID = cl_system_uuid=>create_uuid_x16_static( ).
    ls_Exception-infotype = i_infotype.
    ls_Exception-info_message = i_Message.
    ls_Exception-exception_Type = i_exceptionType.
    ls_Exception-company  =  i_CompanyName.
    ls_Exception-IncorrectValue = i_FieldValue.
    ls_Exception-log_date = sy-datum.
    ls_Exception-log_tim = sy-timlo.
    INSERT zcs04_exception FROM @ls_Exception.
    IF sy-subrc <> 0.
      e_result  = abap_false.
    ENDIF.
  ENDMETHOD.


ENDCLASS.
