INTERFACE zif_cs17_testinterface2
  PUBLIC .
 TYPES: BEGIN OF ty_import_context,
           source_system TYPE string,
           run_id         TYPE string,
           bp_external_id TYPE string,
         END OF ty_import_context.


  TYPES: BEGIN OF ty_address_result,
           address_id  TYPE string,   "Addr
           is_new      TYPE abap_bool,
           has_error   TYPE abap_bool,
           error_text  TYPE string,
         END OF ty_address_result.

  TYPES ty_t_address_result TYPE STANDARD TABLE OF ty_address_result WITH EMPTY KEY.
  TYPES ty_t_string         TYPE STANDARD TABLE OF string WITH EMPTY KEY.

  "API Response
  TYPES: BEGIN OF ty_additional_info,
           new_address_count   TYPE i,
           failed_address_ids  TYPE ty_t_string,"ID ٍError
           warnings            TYPE ty_t_string, "Err Msgا
         END OF ty_additional_info.


  INTERFACES if_badi_interface .

*   METHODS  After_import_response
*    IMPORTING
*      i_context       TYPE ty_import_context
*      i_addresses     TYPE ty_t_address_result
*    CHANGING
*      cs_additional    TYPE ty_additional_info.
*
* METHOD Numberof_NewAddress.
*     IMPORTING
*       i_ProtokolTbl  TYPE zcs17_customers
*     EXPORTING
*       e_NewAddr      TYPE i
*       e_ErrorInfo    TYPE

*ENDMETHOD.
ENDINTERFACE.
