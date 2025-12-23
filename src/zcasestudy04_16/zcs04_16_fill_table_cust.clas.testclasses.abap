*"* use this source file for your ABAP unit test classes

CLASS ltcl_test DEFINITION  FINAL FOR TESTING
  DURATION SHORT
  RISK LEVEL HARMLESS.

  PRIVATE SECTION.
    DATA: lt_file        TYPE TABLE OF zcs04_filedata,
          ls_source      TYPE zcs04_filedata,
          I_CheckMessage TYPE char256,
          I_checkFlag    TYPE abap_bool,
          My_badi        TYPE REF TO zcs4_customer_badi.


    METHODS:
      first_test     FOR TESTING RAISING cx_static_check,
      success_test_1 FOR TESTING RAISING cx_static_check,
      success_test_2 FOR TESTING RAISING cx_static_check,
      success_test_3 FOR TESTING RAISING cx_static_check,
      failure_test_1 FOR TESTING RAISING cx_static_check,
      failure_test_2 FOR TESTING RAISING cx_static_check,
      failure_test_3 FOR TESTING RAISING cx_static_check.
ENDCLASS.


CLASS ltcl_test IMPLEMENTATION.

  METHOD first_test.


    TRY.
        APPEND VALUE #( cuid ='1'  email = 'peter*petersen@gmx.de' ) TO lt_file.
        APPEND VALUE #( cuid ='2'  email = 'peter..petersen@gmx.de' ) TO lt_file.
        APPEND VALUE #( cuid ='3'  email = 'peter.petersen@gmx.d' ) TO lt_file.
        APPEND VALUE #( cuid ='4'  email = 'peter.petersen@g*x.de' ) TO lt_file.
        APPEND VALUE #( cuid ='5'  email = 'peter..petersen@gmx.worldwide' ) TO lt_file.
        APPEND VALUE #( cuid ='6'  email = 'peter.petersen.gmx.de' ) TO lt_file.
        APPEND VALUE #( cuid ='7'  email = 'peter*petersen@gmx,de' ) TO lt_file.
        APPEND VALUE #( cuid ='8'  email = 'peter..petersen@gmx;de' ) TO lt_file.
        APPEND VALUE #( cuid ='11'  email = 'peter.petersen@gmx.de' ) TO lt_file.
        APPEND VALUE #( cuid ='12'  email = 'hans.hansen@web.de' ) TO lt_file.
        APPEND VALUE #( cuid ='13'  email = 'karl.carlsen@carlsen.fr' ) TO lt_file.

        GET BADI My_badi.

        LOOP AT lt_file INTO ls_source.
*         call FUNCTION 'SX_INTERNET_ADDRESS_TO_NORMAL'
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
        ENDLOOP.

      CATCH cx_root.

        cl_abap_unit_assert=>fail( 'Es trat ein Fehler auf' ).
*cl_abap_unit_assert
    ENDTRY.
  ENDMETHOD.

  METHOD success_test_1.

    CLEAR lt_file.
    APPEND VALUE #( cuid ='1'  email = 'hans.hansen@web.de' ) TO lt_file.

    LOOP AT lt_file INTO ls_source.

      GET BADI My_badi.
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
    ENDLOOP.

    cl_abap_unit_assert=>assert_equals( act = i_checkflag exp = abap_true msg = 'Die E-Mail hans.hansen@web.de ist korrekt und wurde als nicht valide getestet. ' ).

  ENDMETHOD.

  METHOD failure_test_1.

    CLEAR lt_file.
    APPEND VALUE #( cuid ='1'  email = 'peter*petersen@gmx.de' ) TO lt_file.

    LOOP AT lt_file INTO ls_source.

      GET BADI My_badi.
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
    ENDLOOP.

    cl_abap_unit_assert=>assert_equals( act = i_checkflag exp = abap_false msg = 'Die E-Mail peter*petersen@gmx.de ist nicht korrekt und wurde als  valide getestet. ' ).

  ENDMETHOD.

  METHOD failure_test_2.

    CLEAR lt_file.
    APPEND VALUE #( cuid ='3'  email = 'peter.petersen@gmx.d' ) TO lt_file.

    LOOP AT lt_file INTO ls_source.

      GET BADI My_badi.
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
    ENDLOOP.

    cl_abap_unit_assert=>assert_equals( act = i_checkflag exp = abap_false msg = 'Die E-Mail peter.petersen@gmx.d ist nicht korrekt und wurde als valide getestet. ' ).

  ENDMETHOD.

  METHOD failure_test_3.

    CLEAR lt_file.
    APPEND VALUE #( cuid ='1'  email = 'peter.petersen.gmx.de' ) TO lt_file.

    LOOP AT lt_file INTO ls_source.

      GET BADI My_badi.
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
    ENDLOOP.

    cl_abap_unit_assert=>assert_equals( act = i_checkflag exp = abap_false msg = 'Die E-Mail peter.petersen.gmx.de ist nicht korrekt und wurde als valide getestet. ' ).

  ENDMETHOD.

  METHOD success_test_2.

    CLEAR lt_file.
    APPEND VALUE #( cuid ='13'  email = 'karl.carlsen@carlsen.fr' ) TO lt_file.

    LOOP AT lt_file INTO ls_source.

      GET BADI My_badi.
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
    ENDLOOP.

    cl_abap_unit_assert=>assert_equals( act = i_checkflag exp = abap_true msg = 'Die E-Mail karl.carlsen@carlsen.fr ist korrekt und wurde als nicht valide getestet. ' ).

  ENDMETHOD.

  METHOD success_test_3.

    CLEAR lt_file.
    APPEND VALUE #( cuid =' 23 '  email = 'peter.petersen@gmx.de' ) TO lt_file.

    LOOP AT lt_file INTO ls_source.

      GET BADI My_badi.
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
    ENDLOOP.

    cl_abap_unit_assert=>assert_equals( act = i_checkflag exp = abap_true msg = 'Die E-Mail peter.petersen@gmx.de ist korrekt und wurde als nicht valide getestet. ' ).

  ENDMETHOD.

ENDCLASS.
