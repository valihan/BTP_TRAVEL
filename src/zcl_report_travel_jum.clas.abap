CLASS zcl_report_travel_jum DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_report_travel_jum IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.

**********************************************************************
* Read entity by mykey
    READ ENTITY zi_travel_m_jum
    ALL FIELDS WITH VALUE #( ( %key-mykey = '02D5290E594C1EDA93815C50CD7AE62A' ) )
     RESULT DATA(lt_travel)
*     RESULT FINAL(read_entity)
     FAILED FINAL(read_failed).

    IF read_failed-travel IS NOT INITIAL.
      "...
      out->write( |Read failed| ).
      RETURN.
    ENDIF.

    IF lt_travel IS NOT INITIAL.
*   output the result as a console message
      DATA(lv_lines) = lines( lt_travel ).
      out->write( |{ sy-dbcnt } travel entries readed successfully! lines = { lv_lines }| ).
    ENDIF.

**********************************************************************
* Read all entities
    SELECT FROM zi_travel_m_jum FIELDS travel_id, agency_id, customer_id, begin_date, end_date, total_price, currency_code
      INTO TABLE @DATA(lt_travel_jum).
    IF sy-subrc <> 0.
      RETURN.
    ENDIF.

    SELECT FROM /dmo/agency FIELDS agency_id, country_code
      FOR ALL ENTRIES IN @lt_travel_jum
      WHERE agency_id = @lt_travel_jum-agency_id
      INTO TABLE @DATA(lt_agency_db).

    SELECT FROM /dmo/customer FIELDS customer_id, country_code
      FOR ALL ENTRIES IN @lt_travel_jum
      WHERE customer_id = @lt_travel_jum-customer_id
      INTO TABLE @DATA(lt_customer_db).

    LOOP AT lt_travel_jum ASSIGNING FIELD-SYMBOL(<lfs_travel_jum>).
      ASSIGN lt_agency_db[ agency_id = <lfs_travel_jum>-agency_id ] TO FIELD-SYMBOL(<lfs_agency>).
      IF sy-subrc <> 0.
        out->write( |Agency { <lfs_travel_jum>-agency_id } is unknown| ).
      ENDIF.

      ASSIGN lt_customer_db[ customer_id = <lfs_travel_jum>-customer_id ] TO FIELD-SYMBOL(<lfs_customer>).
      IF sy-subrc <> 0.
        out->write( |Customer { <lfs_travel_jum>-agency_id } is unknown| ).
      ENDIF.

      IF <lfs_agency>-country_code <> <lfs_customer>-country_code.
        out->write( |Customer { <lfs_travel_jum>-customer_id }/{ <lfs_customer>-country_code } request in agency from other country ({ <lfs_agency>-country_code })| ).
      ENDIF.
    ENDLOOP.

*      out->write( lt_travel_jum ).


  ENDMETHOD.
ENDCLASS.
