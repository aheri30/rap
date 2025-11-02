CLASS lhc_Supplement DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS calculateTotalSupplPrice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Supplement~calculateTotalSupplPrice.

ENDCLASS.

CLASS lhc_Supplement IMPLEMENTATION.

  METHOD calculateTotalSupplPrice.

    IF NOT keys IS INITIAL.

      zcl_aux_travel_det_ec=>calculate_price(
     EXPORTING
       it_travel_id       = VALUE #( FOR GROUPS <booking_suppl> OF booking_key IN keys
                                                                   GROUP BY booking_key-TravelId
                                                                    WITHOUT MEMBERS ( <booking_suppl> ) )
*        IMPORTING
*          et_travel_reported =
   ).


    ENDIF.

  ENDMETHOD.

ENDCLASS.

CLASS lsc_supplement DEFINITION INHERITING FROM cl_abap_behavior_saver.

  PUBLIC SECTION.
    CONSTANTS: create TYPE  string VALUE 'C',
               update TYPE  string VALUE 'U',
               delete TYPE  string VALUE 'D'.

  PROTECTED SECTION.
    METHODS save_modified REDEFINITION.
ENDCLASS.

CLASS lsc_supplement IMPLEMENTATION.

  METHOD save_modified.

    DATA: lt_supplemets TYPE STANDARD TABLE OF zbooksuppl_ec,
          lv_op_type    TYPE zde_flag,
          lv_updated    TYPE zde_flag.

    DATA: lt_db_data     TYPE STANDARD TABLE OF zbooksuppl_ec,
          lt_merged_data TYPE STANDARD TABLE OF zbooksuppl_ec,
          lt_update_keys TYPE STANDARD TABLE OF  zbooksuppl_ec.

    IF NOT create-supplement IS INITIAL.

      lt_supplemets = VALUE #( FOR  w_suppl  IN create-supplement (
                    booking_id = w_suppl-BookingId
                    booking_supplement_id = w_suppl-BookingSupplementId
                    currency = w_suppl-Currency
                    price = w_suppl-Price
                    supplement_id = w_suppl-SupplementId
                    travel_id = w_suppl-TravelId ) ).
      lv_op_type = lsc_supplement=>create.

    ENDIF.
    IF NOT update-supplement IS INITIAL.
      " 1. Obtener las claves de los registros modificados
      lt_update_keys = VALUE #( FOR update_entry IN update-supplement (
                           travel_id             = update_entry-TravelId
                           booking_id            = update_entry-BookingId
                           booking_supplement_id = update_entry-BookingSupplementId
                         ) ).

      " 2. Leer los datos existentes (completos) desde la BD
      SELECT * FROM zbooksuppl_ec
        FOR ALL ENTRIES IN @lt_update_keys

        WHERE travel_id             = @lt_update_keys-travel_id
          AND booking_id            = @lt_update_keys-booking_id
          AND booking_supplement_id = @lt_update_keys-booking_supplement_id
           INTO TABLE @lt_db_data.

      " 3. Fusionar: Usar los datos de la BD como BASE
      "    y aplicar solo los cambios recibidos en update-supplement.
      lt_merged_data = CORRESPONDING #(
                           BASE ( lt_db_data )
                           update-supplement
                           MAPPING
                             travel_id             = TravelId
                             booking_id            = BookingId
                             booking_supplement_id = BookingSupplementId
                             supplement_id         = SupplementId
                             currency              = Currency
                             price                 = Price
                             last_changed_at       = LastChangedAt
                             " Asegúrate de mapear AQUÍ TODOS los campos de la tabla zbooksuppl_ec
                         ).

      lt_supplemets = lt_merged_data.
      lv_op_type = lsc_supplement=>update.

    ENDIF.
    IF NOT delete-supplement IS INITIAL.

      lt_supplemets = VALUE #( FOR  w_suppl_d  IN delete-supplement (
                     booking_id = w_suppl_d-BookingId
                     booking_supplement_id = w_suppl_d-BookingSupplementId
                     travel_id = w_suppl_d-TravelId ) ).
      lv_op_type = lsc_supplement=>delete.

    ENDIF.

    IF NOT lt_supplemets IS INITIAL.

      CALL FUNCTION 'Z_SUPPL_EC'
        EXPORTING
          it_supplement = lt_supplemets
          iv_op_type    = lv_op_type
        IMPORTING
          ev_updated    = lv_updated.

      IF lv_updated EQ abap_true.

*    reported-supplement

      ELSE.



      ENDIF.


    ENDIF.


  ENDMETHOD.
ENDCLASS.
