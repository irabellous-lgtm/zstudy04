CLASS zcs4_17_badi_testbadi2_fb DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_badi_interface .
    INTERFACES zif_cs17_testinterface2 .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.


CLASS zcs4_17_badi_testbadi2_fb IMPLEMENTATION.

 METHOD zif_cs17_testinterface2~After_import_response.
   " Default and safe
    cs_additional-new_address_count = 0.
    CLEAR cs_additional-failed_address_ids.
    CLEAR cs_additional-warnings.
  ENDMETHOD.

ENDCLASS.
