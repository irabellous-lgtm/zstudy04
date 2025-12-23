INTERFACE zcs4_17_testinterface

  PUBLIC .

  INTERFACES if_badi_interface .

   METHODS Get_CustomerID
    IMPORTING
      i_Object TYPE  char10
    EXPORTING
      e_CusomerID  TYPE  ZCUSTOMERID04
      e_Result   TYPE abap_bool
    RAISING
      cx_static_check.

  METHODS Check_FieldLength
    IMPORTING
      i_customer TYPE zcs04_customers
    EXPORTING
      e_Message  TYPE char256
      e_Result   TYPE abap_bool
    RAISING
      cx_static_check.

  METHODS Check_DuplicateRows
    IMPORTING
      i_customer TYPE zcs04_customers
    EXPORTING
      e_Message  TYPE char256
      e_Result   TYPE abap_bool
      e_ID       TYPE  ZCUSTOMERID04
    RAISING
      cx_static_check.

  METHODS Check_EmailValidation
    IMPORTING
      i_customer TYPE zcs04_customers
    EXPORTING
      e_Message  TYPE char256
      e_Result   TYPE abap_bool
    RAISING
      cx_static_check.

  METHODS Post_Customer
    IMPORTING
      i_customer TYPE zcs04_customers
    EXPORTING
      e_Message  TYPE char256
      e_Result   TYPE abap_bool
    RAISING
      cx_static_check.

   METHODS Update_Customer
    IMPORTING
      i_customer TYPE zcs04_customers
      i_CustomerID  TYPE  ZCUSTOMERID04
    EXPORTING
      e_Message  TYPE char256
      e_Result   TYPE abap_bool
    RAISING
      cx_static_check.
ENDINTERFACE.
