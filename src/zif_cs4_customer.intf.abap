INTERFACE zif_cs4_customer
  PUBLIC .


  INTERFACES if_badi_interface .

  METHODS check_fields
    IMPORTING
      i_TblName    TYPE char256
    CHANGING
      i_customer   TYPE zcs04_filedata
      e_Message    TYPE char256
      e_Result     TYPE abap_bool
      e_FieldValue TYPE char256
    .
  METHODS Check_DuplicateRows
    IMPORTING
      i_customer TYPE zcs04_filedata
    CHANGING
      e_Message  TYPE char256
      e_Result   TYPE abap_bool
      e_ID       TYPE  zcustomerid04
    .

  METHODS Check_EmailValidation
    IMPORTING
      i_customer TYPE zcs04_filedata
    CHANGING
      e_Message  TYPE char256
      e_Result   TYPE abap_bool
    .

  METHODS Numberof_NewPostedRecords
    EXPORTING
      i_Count TYPE int4.



  METHODS IncorrectData_Import
    IMPORTING
      i_customer_id  TYPE  zcustomerid04
      i_ErrorType    TYPE  char1
      i_ErrorMessage TYPE char256
      i_ErrorValue   TYPE char256
    CHANGING
      c_Customer     TYPE zcs04_customers.


ENDINTERFACE.
