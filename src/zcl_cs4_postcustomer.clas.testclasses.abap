*"* use this source file for your ABAP unit test classes
CLASS ltcl_test_email DEFINITION FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    DATA: lt_file        TYPE TABLE OF zcs04_filedata,
          ls_source      TYPE zcs04_filedata,
          I_CheckMessage TYPE char256,
          I_checkFlag    TYPE abap_bool,
          My_badi        TYPE REF TO zcs4_customer_badi.


    METHODS:
      success_test_1 FOR TESTING RAISING cx_static_check,
      success_test_2 FOR TESTING RAISING cx_static_check,
      success_test_3 FOR TESTING RAISING cx_static_check,
      failure_test_1 FOR TESTING RAISING cx_static_check,
      failure_test_2 FOR TESTING RAISING cx_static_check,
      failure_test_3 FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_test_email IMPLEMENTATION.

  METHOD success_test_1.

    CLEAR lt_file.
    DATA(lo_CheckCustomer) = NEW zcl_cs4_importcustomer( ).
    APPEND VALUE #( cuid ='1'  email = 'hans.hansen@web.de' ) TO lt_file.

    LOOP AT lt_file INTO ls_source.

      lo_CheckCustomer->check_emailvalidation(
              EXPORTING
                i_customer = ls_source
                i_keyfield = CONV char100( ls_source-cuid )
              CHANGING
                new_email  = ls_source-email
                e_message  = i_checkmessage
                e_result   = i_checkflag
            ).
      IF i_checkflag = abap_false.
        "insert into table exception i_checkmessage
        ls_source-memo = i_checkmessage.
      ENDIF.
    ENDLOOP.

    cl_abap_unit_assert=>assert_equals( act = i_checkflag exp = abap_true msg = 'Die E-Mail hans.hansen@web.de ist korrekt und wurde als nicht valide getestet. ' ).

  ENDMETHOD.

  METHOD failure_test_1.

    CLEAR lt_file.
    DATA(lo_CheckCustomer) = NEW zcl_cs4_importcustomer( ).

    APPEND VALUE #( cuid ='1'  email = 'peter*petersen@gmx.de' ) TO lt_file.

    LOOP AT lt_file INTO ls_source.

      lo_CheckCustomer->check_emailvalidation(
              EXPORTING
                i_customer = ls_source
                i_keyfield = CONV char100( ls_source-cuid )
              CHANGING
                new_email  = ls_source-email
                e_message  = i_checkmessage
                e_result   = i_checkflag
            ).
      IF i_checkflag = abap_false.
        "insert into table exception i_checkmessage
        ls_source-memo = i_checkmessage.
      ENDIF.
    ENDLOOP.

    cl_abap_unit_assert=>assert_equals( act = i_checkflag exp = abap_false msg = 'Die E-Mail peter*petersen@gmx.de ist nicht korrekt und wurde als  valide getestet. ' ).

  ENDMETHOD.

  METHOD failure_test_2.

    CLEAR lt_file.
    DATA(lo_CheckCustomer) = NEW zcl_cs4_importcustomer( ).

    APPEND VALUE #( cuid ='3'  email = 'peter.petersen@gmx.d' ) TO lt_file.

    LOOP AT lt_file INTO ls_source.

      lo_CheckCustomer->check_emailvalidation(
        EXPORTING
          i_customer = ls_source
          i_keyfield = CONV char100( ls_source-cuid )
        CHANGING
          new_email  = ls_source-email
          e_message  = i_checkmessage
          e_result   = i_checkflag
      ).
      IF i_checkflag = abap_false.
        "insert into table exception i_checkmessage
        ls_source-memo = i_checkmessage.
      ENDIF.
    ENDLOOP.

    cl_abap_unit_assert=>assert_equals( act = i_checkflag exp = abap_false msg = 'Die E-Mail peter.petersen@gmx.d ist nicht korrekt und wurde als valide getestet. ' ).

  ENDMETHOD.

  METHOD failure_test_3.

    CLEAR lt_file.
    DATA(lo_CheckCustomer) = NEW zcl_cs4_importcustomer( ).

    APPEND VALUE #( cuid ='1'  email = 'peter.petersen.gmx.de' ) TO lt_file.

    LOOP AT lt_file INTO ls_source.

      lo_CheckCustomer->check_emailvalidation(
        EXPORTING
          i_customer = ls_source
          i_keyfield = CONV char100( ls_source-cuid )
        CHANGING
          new_email  = ls_source-email
          e_message  = i_checkmessage
          e_result   = i_checkflag
      ).
      IF i_checkflag = abap_false.
        "insert into table exception i_checkmessage
        ls_source-memo = i_checkmessage.
      ENDIF.
    ENDLOOP.

    cl_abap_unit_assert=>assert_equals( act = i_checkflag exp = abap_false msg = 'Die E-Mail peter.petersen.gmx.de ist nicht korrekt und wurde als valide getestet. ' ).

  ENDMETHOD.

  METHOD success_test_2.

    CLEAR lt_file.
    DATA(lo_CheckCustomer) = NEW zcl_cs4_importcustomer( ).

    APPEND VALUE #( cuid ='13'  email = 'karl.carlsen@carlsen.fr' ) TO lt_file.

    LOOP AT lt_file INTO ls_source.

      lo_CheckCustomer->check_emailvalidation(
         EXPORTING
           i_customer = ls_source
           i_keyfield = CONV char100( ls_source-cuid )
         CHANGING
           new_email  = ls_source-email
           e_message  = i_checkmessage
           e_result   = i_checkflag
       ).
      IF i_checkflag = abap_false.
        "insert into table exception i_checkmessage
        ls_source-memo = i_checkmessage.
      ENDIF.
    ENDLOOP.

    cl_abap_unit_assert=>assert_equals( act = i_checkflag exp = abap_true msg = 'Die E-Mail karl.carlsen@carlsen.fr ist korrekt und wurde als nicht valide getestet. ' ).

  ENDMETHOD.

  METHOD success_test_3.

    CLEAR lt_file.
    DATA(lo_CheckCustomer) = NEW zcl_cs4_importcustomer( ).

    APPEND VALUE #( cuid =' 17 '  email = 'peter.petersen@gmx.de' ) TO lt_file.

    LOOP AT lt_file INTO ls_source.

      lo_CheckCustomer->check_emailvalidation(
        EXPORTING
          i_customer = ls_source
          i_keyfield = CONV char100( ls_source-cuid )
        CHANGING
          new_email  = ls_source-email
          e_message  = i_checkmessage
          e_result   = i_checkflag
      ).
      IF i_checkflag = abap_false.
        "insert into table exception i_checkmessage
        ls_source-memo = i_checkmessage.
      ENDIF.
    ENDLOOP.

    cl_abap_unit_assert=>assert_equals( act = i_checkflag exp = abap_true msg = 'Die E-Mail peter.petersen@gmx.de ist korrekt und wurde als nicht valide getestet. ' ).

  ENDMETHOD.

ENDCLASS.
