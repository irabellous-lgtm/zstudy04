CLASS zcl_17_badi_testbadi2 DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_badi_interface .
    INTERFACES zif_cs17_testinterface2 .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_17_badi_testbadi2 IMPLEMENTATION.


  METHOD zif_cs17_testinterface2~after_import_response.
     DATA lv_new TYPE i VALUE 0.

    CLEAR cs_additional-failed_address_ids.
    CLEAR cs_additional-warnings.

    LOOP AT i_addresses ASSIGNING FIELD-SYMBOL(<a>).
      IF <a>-is_new = abap_true.
        lv_new += 1.
      ENDIF.

      IF <a>-has_error = abap_true.
        APPEND <a>-address_id TO cs_additional-failed_address_ids.

        IF <a>-error_text IS NOT INITIAL.
          APPEND |Addr { <a>-address_id }: { <a>-error_text }|
            TO cs_additional-warnings.
        ENDIF.
      ENDIF.
    ENDLOOP.

    cs_additional-new_address_count = lv_new.
  ENDMETHOD.
ENDCLASS.
