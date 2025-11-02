CLASS zcl_aux_travel_det_ec DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES: tt_travel_reported    TYPE TABLE FOR REPORTED z_i_travel_ec,
           tt_booking_reported   TYPE TABLE FOR REPORTED z_i_booking_ec,
           tt_booksuppl_reported TYPE TABLE FOR REPORTED z_i_booksuppl_ec.

    TYPES: tt_travel_id TYPE TABLE OF /dmo/travel_id.

    CLASS-METHODS calculate_price IMPORTING it_travel_id       TYPE  tt_travel_id
                                  EXPORTING et_travel_reported TYPE tt_travel_reported .

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_aux_travel_det_ec IMPLEMENTATION.
  METHOD calculate_price.

    DATA: lv_total_booking_price TYPE /dmo/total_price,
          lv_total_supple_price  TYPE /dmo/total_price.

    IF it_travel_id IS INITIAL.
      RETURN.
    ENDIF.

    READ ENTITIES OF z_i_travel_ec
    ENTITY Travel
    FIELDS ( TravelId CurrencyCode )
    WITH VALUE #( FOR lv_travel_id IN it_travel_id (
                    TravelId = lv_travel_id

                     ) )
                    RESULT DATA(lt_read_travel).

    READ ENTITIES OF z_i_travel_ec
    ENTITY Travel BY \_Booking
    FROM VALUE #( FOR lv_travel_id IN it_travel_id (
                    TravelId = lv_travel_id
                    %control-FlightPrice = if_abap_behv=>mk-on
                    %control-CurrencyCode = if_abap_behv=>mk-on
                     ) )
                    RESULT DATA(lt_read_booking).

    LOOP AT lt_read_booking INTO DATA(ls_booking)
    GROUP BY ls_booking-TravelId INTO DATA(ls_travel_key).

      ASSIGN lt_read_travel[ KEY entity COMPONENTS TravelId = ls_travel_key ]
      TO FIELD-SYMBOL(<ls_travel>).

      LOOP AT GROUP ls_travel_key  INTO DATA(ls_booking_result)
      GROUP BY ls_booking_result-CurrencyCode INTO DATA(lv_currency_code).

        lv_total_booking_price = 0.


        LOOP AT GROUP lv_currency_code INTO DATA(ls_booking_line).

          lv_total_booking_price +=   ls_booking_line-FlightPrice.

        ENDLOOP.

        IF lv_currency_code EQ <ls_travel>-CurrencyCode.
          <ls_travel>-TotalPrice +=  lv_total_booking_price.
        ELSE.

          /dmo/cl_flight_amdp=>convert_currency(
            EXPORTING
              iv_amount               = lv_total_booking_price
              iv_currency_code_source = lv_currency_code
              iv_currency_code_target = <ls_travel>-CurrencyCode
              iv_exchange_rate_date   = cl_abap_context_info=>get_system_date( )
          IMPORTING
            ev_amount               = DATA(lv_amount_converted)
          ).

          <ls_travel>-TotalPrice +=  lv_amount_converted.

        ENDIF.

      ENDLOOP.

    ENDLOOP.


    READ ENTITIES OF z_i_travel_ec
    ENTITY Booking BY \_BookingSupplement
    FROM VALUE #( FOR ls_travel IN lt_read_booking (
                TravelId = ls_travel-TravelId
                BookingId = ls_travel-BookingId
                %control-Price = if_abap_behv=>mk-on
                %control-Currency = if_abap_behv=>mk-on
                 ) )
                RESULT DATA(lt_read_booksupll).

    LOOP AT lt_read_booksupll INTO DATA(ls_booksuppl)
    GROUP BY ls_booksuppl-TravelId INTO DATA(w_travel_id).


      ASSIGN lt_read_travel[ KEY entity COMPONENTS TravelId = w_travel_id ]
          TO FIELD-SYMBOL(<fs_travel>).


      LOOP AT GROUP w_travel_id INTO DATA(w_booksuppl_travel)
      GROUP BY w_booksuppl_travel-Currency INTO DATA(w_currency).
        lv_total_supple_price = 0.

        LOOP AT GROUP w_currency INTO DATA(w_booksuppl_currency).
          lv_total_supple_price += w_booksuppl_currency-price.
        ENDLOOP.

        IF w_currency EQ <fs_travel>-CurrencyCode.
          <fs_travel>-TotalPrice +=  lv_total_supple_price.
        ELSE.

          /dmo/cl_flight_amdp=>convert_currency(
            EXPORTING
              iv_amount               = lv_total_supple_price
              iv_currency_code_source = lv_currency_code
              iv_currency_code_target = <fs_travel>-CurrencyCode
              iv_exchange_rate_date   = cl_abap_context_info=>get_system_date( )
          IMPORTING
            ev_amount               = DATA(lv_amount_converted_sppl)
          ).

          <fs_travel>-TotalPrice +=  lv_amount_converted_sppl.

        ENDIF.

      ENDLOOP.

    ENDLOOP.

    MODIFY ENTITIES OF z_i_travel_ec
    ENTITY Travel
    UPDATE FROM VALUE #( FOR ls_travel_bo IN lt_read_travel (
                            travelid = ls_travel_bo-travelid
                            TotalPrice = ls_travel_bo-TotalPrice
                            %control-TotalPrice = if_abap_behv=>mk-on

                             ) ).


*et_travel_reported
  ENDMETHOD.

ENDCLASS.
