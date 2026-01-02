INTERFACE zif_cs4_customer
  PUBLIC .


  INTERFACES if_badi_interface .

  METHODS : check_fields
    IMPORTING
      i_TblName    TYPE char256
    CHANGING
      i_customer   TYPE zcs04_filedata
      e_Message    TYPE char256
      e_Result     TYPE abap_bool
      e_FieldValue TYPE char256
    ,
    Check_DuplicateRows
      IMPORTING
        i_customer TYPE zcs04_filedata
      CHANGING
        e_Message  TYPE char256
        e_Result   TYPE abap_bool
        e_ID       TYPE  zcustomerid04
      ,

    Check_EmailValidation
      IMPORTING
        i_customer     TYPE zcs04_filedata
      CHANGING
        Email_Addr     TYPE char256
        Email_Validity TYPE abap_bool
        Err_Message    TYPE char256
      ,

    Numberof_NewPostedRecords
      IMPORTING
        i_Count TYPE int4
      ,
    CheckData_import
      IMPORTING
        i_customer_id  TYPE  zcustomerid04
        i_FileData     TYPE zcs04_filedata
      CHANGING
        c_Customer     TYPE zcs04_customers
        c_Exceptions   TYPE zcs04_exception.


ENDINTERFACE.
