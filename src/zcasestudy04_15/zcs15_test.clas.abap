CLASS zcs15_test DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcs15_test IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.

  DATA cnt TYPE i.

SELECT count( * )
  FROM ztl_04_casestudy
  into @cnt.

out->write( cnt ).


SELECT count( * )
  FROM zcs04_filedata
  into @cnt.

out->write( cnt ).

*DATA: lv_csv    TYPE string,
*      lt_fields TYPE STANDARD TABLE OF string,
*      ls_target TYPE zcs04_cust_test.
*
*" 1. Читаем CSV из таблицы-источника
*SELECT SINGLE import
*  FROM ztl04_csestudy_d
*  INTO @lv_csv.
*
*IF sy-subrc <> 0.
*  out->write( 'Нет данных для импорта' ).
*ENDIF.
*
*" 2. Убираем кавычки
*REPLACE ALL OCCURRENCES OF '"' IN lv_csv WITH ''.
*
*" 3. Разбиваем CSV по ;
*SPLIT lv_csv AT ';' INTO TABLE lt_fields.
*
*" 4. Заполняем целевую структуру
*READ TABLE lt_fields INDEX 1 INTO ls_target-company.
*READ TABLE lt_fields INDEX 2 INTO ls_target-street.
*READ TABLE lt_fields INDEX 3 INTO ls_target-postcode.
*READ TABLE lt_fields INDEX 4 INTO ls_target-city.
*READ TABLE lt_fields INDEX 5 INTO ls_target-fax.
*READ TABLE lt_fields INDEX 6 INTO ls_target-phone.
*READ TABLE lt_fields INDEX 7 INTO ls_target-email.
*
*ls_target-client = sy-mandt.
*
*" 5. Запись в таблицу
*INSERT
**CORRESPONDING FIELDS OF TABLE
*zcs04_cust_test FROM @ls_target.
*
*IF sy-subrc = 0.
*  COMMIT WORK.
*ELSE.
*  ROLLBACK WORK.
*ENDIF.
*


  ENDMETHOD.
ENDCLASS.
