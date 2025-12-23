CLASS lhc_ZCS04_COPY_d DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR ZCS04_COPY_d RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR ZCS04_COPY_d RESULT result.

    METHODS fill_memo_from_email FOR DETERMINE ON MODIFY
      IMPORTING keys FOR ZCS04_COPY_d~fill_memo_from_email.

    METHODS validate_email FOR VALIDATE ON SAVE
      IMPORTING keys FOR ZCS04_COPY_d~validate_email.

ENDCLASS.

CLASS lhc_ZCS04_COPY_d IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD validate_email.
    read entities of ZCS04_COPY_d in local mode
    ENTITY   ZCS04_COPY_d
    FIELDS ( Email )
    with CORRESPONDING #( keys )
    RESULT DATA(customers).

   LOOP at customers ASSIGNING FIELD-SYMBOL(<cust>).

   data(lv_email) = <cust>-Email.
*   if <cust>-Email is initial or <cust>-Email NP '*@*.*'.
   if lv_email NP '*@*.*'.



*   failed-zcs04_copy_d = value #(
*        ( %tky = <cust>-%tky )
*        ).

   reported-zcs04_copy_d = value #( (  %tky = <cust>-%tky
                                        %msg = new_message(
                                         id = 'ZMSG15'
                                         number = '001'
                                         severity = if_abap_behv_message=>severity-warning
                                         v1 = <cust>-email  ) ) ).

     contiNUE.
    endif.
   if lv_email CA  ' !#$%&()*+,/:;>=<?{}?\|''"'.

*   failed-zcs04_copy_d = value #(
*        ( %tky = <cust>-%tky )
*        ).

   reported-zcs04_copy_d = value #( (  %tky = <cust>-%tky
                                        %msg = new_message(
                                         id = 'ZMSG15'
                                         number = '002'
                                         severity = if_abap_behv_message=>severity-warning
                                         v1 = <cust>-email  ) ) ).

     contiNUE.
    endif.

    endloop.


  ENDMETHOD.

  METHOD fill_memo_from_email.
     read entities of ZCS04_COPY_d in local mode
    ENTITY   ZCS04_COPY_d
    FIELDS ( Email )
    with CORRESPONDING #( keys )
    RESULT DATA(customers).

    LOOP at customers ASSIGNING FIELD-SYMBOL(<cust>).
     data(lv_email) = <cust>-Email.
    DATA(lv_memo)  = <cust>-memo.

    IF lv_email IS NOT INITIAL
       AND ( lv_email NP '*@*.*'
             OR lv_email CA ' !#$%&()*+,/:;>=<?{}?\|''"' ).

      " 🔹 1. Готовим новый MEMO
      IF <cust>-Memo IS INITIAL.
        lv_memo = |Invalid e-mail moved to memo: { lv_email }|.
      ELSE.
        lv_memo = |{ <cust>-Memo }; Invalid e-mail moved to memo: { lv_email }|.
      ENDIF.

      " 🔹 2. Обрезаем до 255 символов (CHAR поле!)
*      lv_memo = lv_memo(255).

      " 🔹 3. Обновляем запись
      modify entities of ZCS04_COPY_d in local mode
        ENTITY ZCS04_COPY_d
        UPDATE FIELDS ( Email Memo )
        WITH VALUE #(
          ( %tky = <cust>-%tky
            Email = ''
            Memo  = lv_memo ) ).


  endif.
  endloop.

  ENDMETHOD.

ENDCLASS.
