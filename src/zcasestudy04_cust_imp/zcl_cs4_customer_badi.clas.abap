CLASS zcl_cs4_customer_badi DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_badi_interface .
    INTERFACES zif_cs4_customer .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_cs4_customer_badi IMPLEMENTATION.


  METHOD zif_cs4_customer~check_fields.

    DATA : lv_is_valid TYPE abap_bool VALUE abap_true,
           lo_struct   TYPE REF TO cl_abap_structdescr,
           lt_comp     TYPE cl_abap_structdescr=>component_table,
           ls_comp     LIKE LINE OF lt_comp.
    CLEAR e_Message.
    e_Result = abap_true.
*   CLEAR e_fieldvalue.
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
*        e_fieldvalue = |{ <fs_value> }| .
        e_Message = | The value of field { ls_comp-name } with Value : { <fs_value> } exceeds the defined length for this field. |.
      ENDIF.
    ENDLOOP.
*    i_customer-company = COND string( WHEN strlen( i_customer-company ) > 60 THEN i_customer-company+0(60) ELSE i_customer-company ).
  ENDMETHOD.

  METHOD zif_cs4_customer~Check_DuplicateRows.
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

  METHOD zif_cs4_customer~Check_EmailValidation.
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

  METHOD zif_cs4_customer~Numberof_NewPostedRecords.

  ENDMETHOD.

  METHOD zif_cs4_customer~IncorrectData_Import.

  ENDMETHOD.

ENDCLASS.
