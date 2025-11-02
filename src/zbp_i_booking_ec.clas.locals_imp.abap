CLASS lhc_Booking DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS calculateTotalFlightPrice FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Booking~calculateTotalFlightPrice.

    METHODS valideStatus FOR VALIDATE ON SAVE
      IMPORTING keys FOR Booking~valideStatus.

    METHODS get_features FOR FEATURES IMPORTING keys
    REQUEST requested_features FOR Booking RESULT result.

ENDCLASS.

CLASS lhc_Booking IMPLEMENTATION.

  METHOD calculateTotalFlightPrice.
    IF NOT keys IS INITIAL.
      zcl_aux_travel_det_ec=>calculate_price( it_travel_id = VALUE #( FOR GROUPS <booking> OF booking_key IN keys
                                                                      GROUP BY booking_key-TravelId
                                                                       WITHOUT MEMBERS ( <booking> ) ) ).
    ENDIF.
  ENDMETHOD.

  METHOD valideStatus.

    READ ENTITY z_i_travel_ec\\Booking

  FIELDS ( BookingStatus )
  WITH CORRESPONDING #( keys )
  RESULT DATA(lt_bookings).


    LOOP AT lt_bookings ASSIGNING FIELD-SYMBOL(<ls_booking>).

      CASE <ls_booking>-BookingStatus.
        WHEN 'N'.
        WHEN 'B'.
        WHEN 'X'.
        WHEN OTHERS.

          APPEND VALUE #( %key = <ls_booking>-%key ) TO failed-booking.

          APPEND VALUE #( %key = <ls_booking>-%key
                          %msg     = new_message( id = 'Z_MC_TRAVEL_EC'
                                                   number = '004'
                                                    v1 =  <ls_booking>-BookingStatus
                                                    v2 = <ls_booking>-BookingId

                                                   severity = if_abap_behv_message=>severity-error )
                            %element-OverallStatus = if_abap_behv=>mk-on ) TO reported-travel.
      ENDCASE.



    ENDLOOP.



  ENDMETHOD.

  METHOD get_features.

    READ ENTITIES OF z_i_travel_ec
    ENTITY Booking
    FIELDS ( BookingId BookingDate CustomerId BookingStatus )
    WITH VALUE #( FOR key_row IN keys ( %key = key_row-%key ) )
    RESULT DATA(lt_booking_result).

    result = VALUE #( FOR ls_travel IN lt_booking_result (
                      %key = ls_travel-%key


                      %assoc-_BookingSupplement      = if_abap_behv=>fc-o-enabled

                          )  ).


  ENDMETHOD.

ENDCLASS.
