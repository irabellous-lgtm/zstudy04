CLASS lhc_zr_cs04_customers DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS:
      get_global_authorizations FOR GLOBAL AUTHORIZATION
        IMPORTING
        REQUEST requested_authorizations FOR ZrCs04Customers
        RESULT result,
      Read_Salutation_FromList FOR VALIDATE ON SAVE
        IMPORTING keys FOR ZrCs04Customers~Read_Salutation_FromList
        ,
      set_customer_id FOR DETERMINE ON SAVE
        IMPORTING keys FOR ZrCs04Customers~set_customer_id  ,
      earlynumbering_create FOR NUMBERING
        IMPORTING entities FOR CREATE ZrCs04Customers,
      set_SalesTarget FOR DETERMINE ON MODIFY
        IMPORTING keys FOR ZrCs04Customers~set_SalesTarget.
ENDCLASS.

CLASS lhc_zr_cs04_customers IMPLEMENTATION.
  METHOD get_global_authorizations.
  ENDMETHOD.

  METHOD Read_Salutation_FromList.
    DATA failed_record LIKE LINE OF failed-zrcs04customers.
    READ ENTITIES OF zr_cs04_customers IN LOCAL MODE
     ENTITY ZrCs04Customers
    FIELDS ( Salutation ) WITH CORRESPONDING #( keys ) RESULT DATA(lt_data).

    LOOP AT lt_data INTO DATA(ls_data) WHERE Salutation IS NOT INITIAL.
      SELECT  COUNT( * ) FROM zcs04_csalutation
       WHERE salutation = @ls_data-Salutation
        INTO @DATA(lv_Salutation).

      IF  lv_Salutation  = 0.
        APPEND VALUE #( %tky = ls_data-%tky
                        %element-salutation = if_abap_behv=>mk-on
                        %msg = new_message( id = 'ZCS04_MSG'
                                            number = '001'
                                            severity = if_abap_behv_message=>severity-error
                                            v1 = ls_data-Salutation
                                            )
                          ) TO reported-zrcs04customers.

        failed_record-%tky = ls_data-%tky.
        APPEND failed_record TO failed-zrcs04customers.
      ENDIF.
    ENDLOOP.

  ENDMETHOD.

  METHOD set_customer_id.
*DATA: lt_update TYPE TABLE FOR UPDATE zr_cs04_customers.
*
*    TRY.
*        READ ENTITIES OF zr_cs04_customers IN LOCAL MODE
*          ENTITY ZrCs04Customers
*          FIELDS ( customerid )
*          WITH CORRESPONDING #( keys  )
*          RESULT DATA(lt_data).
*
*        LOOP AT lt_data INTO DATA(ls_data)." WHERE customerid = 'X'."IS INITIAL.
*  "         lv_number = zcl_cs4_importcustomer=>get_customerid( EXPORTING i_object    = 'ZCS4_NUR' ).
*
*            APPEND VALUE #(
*          %tky = ls_data-%tky
*          customerid = '123456'
*        ) TO lt_update.
*
*        ENDLOOP.
*
*        IF lt_update IS NOT INITIAL.
*          MODIFY ENTITIES OF zr_cs04_customers IN LOCAL MODE
*            ENTITY ZrCs04Customers
*            UPDATE FIELDS ( customerid )
*            WITH lt_update
*            REPORTED DATA(reported_records)
*            FAILED   DATA(failed).
*          reported-zrcs04customers = CORRESPONDING #( reported_records-zrcs04customers ).
*        ENDIF.
*      CATCH cx_root INTO DATA(lx_error).
*        "       MESSAGE lx_error->get_text( ) TYPE 'W'. "E = Error, W = Warning, I = Info
*
*    ENDTRY.

  ENDMETHOD.

  METHOD earlynumbering_create.
    DATA failed_record LIKE LINE OF failed-zrcs04customers.
    LOOP AT entities INTO DATA(ls_Customer) .
      TRY.
          ls_Customer-customerid = zcl_cs4_importcustomer=>get_customerid( EXPORTING i_object = 'ZCS4_NUR' ).
          APPEND VALUE #( %cid = ls_Customer-%cid %is_draft = ls_Customer-%is_draft Customerid = ls_Customer-Customerid ) TO mapped-zrcs04customers.
        CATCH cx_root INTO DATA(ls_exception).
          APPEND VALUE #( %cid = ls_Customer-%cid
                          %is_draft = ls_Customer-%is_draft
                          %msg = new_message( id = 'ZCS04_MSG'
                                              number = '002'
                                              severity = if_abap_behv_message=>severity-error
                                              v1 = ls_exception->get_longtext(  )
                                              )
                            ) TO reported-zrcs04customers.
          failed_record-%cid = ls_Customer-%cid.
          failed_record-%is_draft = ls_Customer-%is_draft.
          APPEND failed_record TO failed-zrcs04customers.
      ENDTRY.
    ENDLOOP.
  ENDMETHOD.

  METHOD set_SalesTarget.
    DATA: update_amount TYPE TABLE FOR UPDATE zr_cs04_customers.
    TRY.
        READ ENTITIES OF zr_cs04_customers IN LOCAL MODE
             ENTITY ZrCs04Customers
             FIELDS ( SalesVolume Currency CurrencyTarget ChangeRateDate )
             WITH CORRESPONDING #( keys  )
             RESULT DATA(Amounts)
             FAILED DATA(read_failed).
        LOOP AT Amounts INTO DATA(Amount) .
          IF Amount-SalesVolume = 0 OR Amount-SalesVolume IS INITIAL.
            Amount-SalesVolumeTarget = 0.
          ELSE.
            cl_exchange_rates=>convert_to_foreign_currency( EXPORTING local_amount = Amount-SalesVolume
                                                            local_currency = Amount-Currency
                                                            foreign_currency = Amount-CurrencyTarget
                                                            date = COND #( WHEN Amount-ChangeRateDate IS INITIAL THEN sy-datum
                                                                                   ELSE Amount-ChangeRateDate )
                                                           IMPORTING  foreign_amount     = Amount-SalesVolumeTarget ).
          ENDIF.
          APPEND VALUE #( %tky = Amount-%tky SalesVolumeTarget = Amount-SalesVolumeTarget ) TO update_amount.
        ENDLOOP.
        IF update_amount IS NOT INITIAL.
          MODIFY ENTITIES OF zr_cs04_customers IN LOCAL MODE
              ENTITY ZrCs04Customers
              UPDATE FIELDS ( SalesVolumeTarget ) WITH update_amount
              REPORTED DATA(reported_records)
              FAILED   DATA(failed).
        ENDIF.
      CATCH cx_root INTO DATA(ls_exception).
        APPEND VALUE #( %tky = Amount-%tky
                        %msg = new_message( id = 'ZCS04_MSG'
                                            number = '003'
                                            severity = if_abap_behv_message=>severity-error
                                            v1 = ls_exception->get_longtext(  )
                                            )
                          ) TO reported-zrcs04customers.
    ENDTRY.

  ENDMETHOD.

ENDCLASS.
