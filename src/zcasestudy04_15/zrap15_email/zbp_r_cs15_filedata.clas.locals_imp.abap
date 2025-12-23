CLASS LHC_ZR_CS15_FILEDATA DEFINITION INHERITING FROM CL_ABAP_BEHAVIOR_HANDLER.
  PRIVATE SECTION.
    METHODS:
      GET_GLOBAL_AUTHORIZATIONS FOR GLOBAL AUTHORIZATION
        IMPORTING
           REQUEST requested_authorizations FOR ZrCs15Filedata
        RESULT result,
      fill_memo_from_email FOR DETERMINE ON MODIFY
            IMPORTING keys FOR ZrCs15Filedata~fill_memo_from_email.

          METHODS validate_email FOR VALIDATE ON SAVE
            IMPORTING keys FOR ZrCs15Filedata~validate_email.
ENDCLASS.

CLASS LHC_ZR_CS15_FILEDATA IMPLEMENTATION.
  METHOD GET_GLOBAL_AUTHORIZATIONS.
  ENDMETHOD.




  METHOD fill_memo_from_email.




  read entities of ZR_CS15_FILEDATA in local mode
    ENTITY ZR_CS15_FILEDATA
    FIELDS ( Email Memo )
    WITH CORRESPONDING #( keys )
    RESULT DATA(customers).

  LOOP AT customers ASSIGNING FIELD-SYMBOL(<cust>).

    DATA(lv_email) = condense( <cust>-Email ).
    DATA(lv_memo) = <cust>-memo.


    IF lv_email IS NOT INITIAL AND ( lv_email NP '*@*.*' OR lv_email CA ' !#$%&()*+,/:;>=<?{}?\|''"' ).


      IF <cust>-Memo IS INITIAL.
        lv_memo = |Invalid e-mail moved to memo: { lv_email }|.
      ELSE.
        lv_memo = |{ <cust>-Memo }; Invalid e-mail moved to memo: { lv_email }|.
      ENDIF.



      modify entities of ZR_CS15_FILEDATA in local mode
        ENTITY ZR_CS15_FILEDATA
        UPDATE FIELDS ( Email Memo )
        WITH VALUE #( ( %tky = <cust>-%tky
                        Email = ''
                        Memo  = lv_memo ) ).

    ENDIF.

  ENDLOOP.


  ENDMETHOD.

  METHOD validate_email.

  read entities of ZR_CS15_FILEDATA in local mode
    ENTITY ZR_CS15_FILEDATA
    FIELDS ( Email )
    WITH CORRESPONDING #( keys )
    RESULT DATA(customers).

  LOOP AT customers ASSIGNING FIELD-SYMBOL(<cust>).
    DATA(lv_email) = condense( <cust>-Email ).

    IF lv_email IS NOT INITIAL
       AND ( lv_email NP '*@*.*'
             OR lv_email CA ' !#$%&()*+,/:;>=<?{}?\|''"' ).

      reported-zrcs15filedata = VALUE #(  (   %tky = <cust>-%tky
                           %msg = new_message(
                             id       = 'ZMSG15'
                             number   = '001'
                             severity = if_abap_behv_message=>severity-warning
                             v1       = lv_email ) ) ) .
    ENDIF.
  ENDLOOP.

  ENDMETHOD.

ENDCLASS.
