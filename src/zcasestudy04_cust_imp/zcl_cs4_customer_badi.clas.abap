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
ENDMETHOD.

  METHOD zif_cs4_customer~Check_DuplicateRows.


  ENDMETHOD.

  METHOD zif_cs4_customer~Check_EmailValidation.
*    e_Message = ''.
*    e_Result = abap_true.
*    DATA: lv_pattern TYPE string VALUE
*            '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$',
*          lo_matcher TYPE REF TO cl_abap_matcher.
*
*    e_result  = abap_true.
*    CLEAR e_message.
*
*    IF i_customer-email IS NOT INITIAL.
*      lo_matcher = cl_abap_matcher=>create(
*        pattern = lv_pattern
*        text    = i_customer-email
*      ).
*      IF lo_matcher->match( ) = abap_false.
*        e_message = 'Email has invalid format'.
*        e_result  = abap_false.
*      ENDIF.
*    ENDIF.
*
  ENDMETHOD.

  METHOD zif_cs4_customer~Numberof_NewPostedRecords.

  ENDMETHOD.

  METHOD zif_cs4_customer~IncorrectData_Import.

  ENDMETHOD.

ENDCLASS.
