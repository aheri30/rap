CLASS lhc_Travel DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.

    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR Travel RESULT result.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR Travel RESULT result.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR Travel RESULT result.

    METHODS acceptTravel FOR MODIFY
      IMPORTING keys FOR ACTION Travel~acceptTravel RESULT result.

    METHODS createTravelByTemplate FOR MODIFY
      IMPORTING keys FOR ACTION Travel~createTravelByTemplate RESULT result.

    METHODS rejectTravel FOR MODIFY
      IMPORTING keys FOR ACTION Travel~rejectTravel RESULT result.

    METHODS validateCustomer FOR VALIDATE ON SAVE
      IMPORTING keys FOR Travel~validateCustomer.

    METHODS validateDates FOR VALIDATE ON SAVE
      IMPORTING keys FOR Travel~validateDates.

    METHODS validateStatus FOR VALIDATE ON SAVE
      IMPORTING keys FOR Travel~validateStatus.

ENDCLASS.

CLASS lhc_Travel IMPLEMENTATION.

  METHOD get_instance_features.

    READ ENTITIES OF z_i_travel_ec
    ENTITY travel
    FIELDS ( TravelId OverallStatus )
    WITH VALUE #( FOR key_row IN keys ( %key = key_row-%key ) )
    RESULT DATA(lt_travel_result).

    result = VALUE #( FOR ls_travel IN lt_travel_result (
                      %key = ls_travel-%key
                      %field-TravelId = if_abap_behv=>fc-f-read_only
                      %field-OverallStatus = if_abap_behv=>fc-f-read_only
                      %assoc-_Booking      = if_abap_behv=>fc-o-enabled
                      %action-acceptTravel = COND #( WHEN ls_travel-OverallStatus = 'A'
                                                     THEN if_abap_behv=>fc-o-disabled
                                                     ELSE if_abap_behv=>fc-o-enabled )
                       %action-rejectTravel = COND #( WHEN ls_travel-OverallStatus = 'X'
                                                     THEN if_abap_behv=>fc-o-disabled
                                                     ELSE if_abap_behv=>fc-o-enabled )
                          )  ).


  ENDMETHOD.

  METHOD get_instance_authorizations.
    DATA(lv_auth) = COND #( WHEN cl_abap_context_info=>get_user_technical_name( ) EQ 'CB9980002182'
     THEN  if_abap_behv=>auth-allowed
     ELSE if_abap_behv=>auth-unauthorized ).

    LOOP AT keys ASSIGNING FIELD-SYMBOL(<ls_keys>).
      APPEND INITIAL LINE TO result ASSIGNING FIELD-SYMBOL(<ls_result>).
      <ls_result> = VALUE #( %key = <ls_keys>-%key
                            %op-%update = lv_auth
                            %delete = ''
                            %action-acceptTravel = lv_auth
                            %action-rejectTravel = lv_auth
                            %action-createTravelByTemplate = lv_auth
                            %assoc-_Booking = lv_auth
                            ).

    ENDLOOP.

  ENDMETHOD.

  METHOD get_global_authorizations.

*  append initial line to result ASSIGNING FIELD-SYMBOL(<ls_result>).
*

  ENDMETHOD.

  METHOD acceptTravel.
    MODIFY ENTITIES OF z_i_travel_ec IN LOCAL MODE
    ENTITY Travel
    UPDATE FIELDS ( OverallStatus )
    WITH VALUE #( FOR key_row IN keys ( TravelId = key_row-TravelId
                                        OverallStatus = 'A' ) )
                 FAILED failed
                 REPORTED reported.

    READ ENTITIES OF z_i_travel_ec IN LOCAL MODE
    ENTITY travel
    FIELDS ( AgencyId
              CustomerId
              BeginDate
              EndDate
              BookingFee
              TotalPrice
              CurrencyCode
              OverallStatus
              Description
              CreatedAt
              CreatedBy
              LastChangedAt
              LastChangedBy )
              WITH VALUE #( FOR key_row1 IN keys ( TravelId = key_row1-TravelId ) )
              RESULT DATA(lt_travel).
    result = VALUE #( FOR ls_travel IN lt_travel ( TravelId = ls_travel-TravelId
                                                   %param  = ls_travel ) ).
    LOOP AT lt_travel ASSIGNING FIELD-SYMBOL(<ls_travel>).

      DATA(lv_travel_msg) = <ls_travel>-travelId.
      SHIFT lv_travel_msg LEFT DELETING LEADING '0'.

      APPEND VALUE #( travelId = <ls_travel>-travelId
                          %msg     = new_message( id = 'Z_MC_TRAVEL_EC'
                                                   number = '005'
                                                   v1 =  lv_travel_msg
                                                   severity = if_abap_behv_message=>severity-information )
                            %element-customerId = if_abap_behv=>mk-on ) TO reported-travel.

    ENDLOOP.
  ENDMETHOD.

  METHOD createTravelByTemplate.

*  keys[ 1 ] -
*  mapped-

    READ ENTITIES OF z_i_travel_ec
    ENTITY Travel
    FIELDS ( TravelId AgencyId CustomerId BookingFee TotalPrice CurrencyCode OverallStatus )
    WITH VALUE #( FOR row_key IN keys ( %key = row_key-%key ) )
    RESULT DATA(lt_entity_travel)
    FAILED failed
    REPORTED reported.

    CHECK failed IS INITIAL.

    DATA lt_create_travel TYPE TABLE FOR CREATE z_i_travel_ec\\Travel.
    SELECT MAX( travel_id ) FROM ztravel_ec INTO @DATA(lv_travel_id).
    DATA(lv_today) = cl_abap_context_info=>get_system_date(  ).

    lt_create_travel = VALUE #( FOR create_row IN lt_entity_travel INDEX INTO idx
                               (  TravelId      = lv_travel_id + idx
                                  AgencyId      = create_row-AgencyId
                                  CustomerId    = create_row-CustomerId
                                  BeginDate     = lv_today
                                  EndDate       = lv_today + 30
                                  BookingFee    = create_row-BookingFee
                                  TotalPrice    = create_row-TotalPrice
                                  CurrencyCode  = create_row-CurrencyCode
                                  OverallStatus = create_row-OverallStatus
                                  description   = 'Add Comments'
                                ) ).

    MODIFY ENTITIES OF z_i_travel_ec
            IN LOCAL MODE ENTITY travel
            CREATE FIELDS ( TravelId
                            AgencyId
                            CustomerId
                            BeginDate
                            EndDate
                            BookingFee
                            TotalPrice
                            CurrencyCode
                            description
                            OverallStatus )
       WITH lt_create_travel
       MAPPED mapped
       FAILED failed
       REPORTED reported.

    result = VALUE #( FOR result_row IN  lt_create_travel INDEX INTO idx
                    ( %cid_ref = keys[ idx ]-%cid_ref
                      %key     = keys[ idx ]-%key
                      %param   = CORRESPONDING #( result_row )
                                       ) ).

  ENDMETHOD.

  METHOD rejectTravel.

    MODIFY ENTITIES OF z_i_travel_ec IN LOCAL MODE
      ENTITY Travel
      UPDATE FIELDS ( OverallStatus )
      WITH VALUE #( FOR key_row IN keys ( TravelId = key_row-TravelId
                                          OverallStatus = 'X' ) )
                   FAILED failed
                   REPORTED reported.

    READ ENTITIES OF z_i_travel_ec IN LOCAL MODE
    ENTITY travel
    FIELDS ( AgencyId
              CustomerId
              BeginDate
              EndDate
              BookingFee
              TotalPrice
              CurrencyCode
              OverallStatus
              Description
              CreatedAt
              CreatedBy
              LastChangedAt
              LastChangedBy )
              WITH VALUE #( FOR key_row1 IN keys ( TravelId = key_row1-TravelId ) )
              RESULT DATA(lt_travel).
    result = VALUE #( FOR ls_travel IN lt_travel ( TravelId = ls_travel-TravelId
                                                   %param  = ls_travel ) ).

    LOOP AT lt_travel ASSIGNING FIELD-SYMBOL(<ls_travel>).

      DATA(lv_travel_msg) = <ls_travel>-travelId.
      SHIFT lv_travel_msg LEFT DELETING LEADING '0'.

      APPEND VALUE #( travelId = <ls_travel>-travelId
                          %msg     = new_message( id = 'Z_MC_TRAVEL_EC'
                                                   number = '006'
                                                   v1 =  lv_travel_msg
                                                   severity = if_abap_behv_message=>severity-information )
                            %element-customerId = if_abap_behv=>mk-on ) TO reported-travel.

    ENDLOOP.

  ENDMETHOD.

  METHOD validateCustomer.
    READ ENTITIES OF z_i_travel_ec IN LOCAL MODE
    ENTITY Travel
    FIELDS ( CustomerId )
    WITH CORRESPONDING #( keys )
    RESULT DATA(lt_travel).

    DATA lt_customer TYPE SORTED TABLE OF /dmo/customer WITH UNIQUE KEY customer_id.

    lt_customer = CORRESPONDING #( lt_travel DISCARDING DUPLICATES MAPPING customer_id = CustomerId EXCEPT * ).
    DELETE lt_customer WHERE customer_id IS INITIAL.
    SELECT FROM /dmo/customer FIELDS customer_id
    FOR ALL ENTRIES IN @lt_customer
    WHERE customer_id EQ @lt_customer-customer_id
    INTO TABLE @DATA(lt_customer_db).

    LOOP AT lt_travel ASSIGNING FIELD-SYMBOL(<ls_travel>).
      IF <ls_travel>-CustomerId IS INITIAL
      OR NOT line_exists( lt_customer_db[ customer_id =  <ls_travel>-CustomerId ] ) .

        APPEND VALUE #( travelId = <ls_travel>-travelId ) TO failed-travel.

        APPEND VALUE #( travelId = <ls_travel>-travelId
                        %msg     = new_message( id = 'Z_MC_TRAVEL_EC'
                                                 number = '001'
                                                 v1 =  <ls_travel>-travelId
                                                 severity = if_abap_behv_message=>severity-error )
                          %element-customerId = if_abap_behv=>mk-on ) TO reported-travel.

      ENDIF.
    ENDLOOP.


  ENDMETHOD.

  METHOD validateDates.
    READ ENTITY z_i_travel_ec\\Travel

  FIELDS ( CustomerId )
  WITH CORRESPONDING #( keys )
  RESULT DATA(lt_travel).


    LOOP AT lt_travel ASSIGNING FIELD-SYMBOL(<ls_travel>).
      IF <ls_travel>-EndDate LT <ls_travel>-BeginDate.


        APPEND VALUE #( travelId = <ls_travel>-travelId ) TO failed-travel.

        APPEND VALUE #( travelId = <ls_travel>-travelId
                        %msg     = new_message( id = 'Z_MC_TRAVEL_EC'
                                                 number = '003'
                                                  v1 =  <ls_travel>-BeginDate
                                                   v2 =  <ls_travel>-EndDate
                                                 v3 =  <ls_travel>-travelId
                                                 severity = if_abap_behv_message=>severity-error )
                          %element-BeginDate = if_abap_behv=>mk-on
                           %element-EndDate = if_abap_behv=>mk-on ) TO reported-travel.

      ELSEIF <ls_travel>-BeginDate LT cl_abap_context_info=>get_system_date(  ).
        APPEND VALUE #( travelId = <ls_travel>-travelId ) TO failed-travel.

        APPEND VALUE #( travelId = <ls_travel>-travelId
                        %msg     = new_message( id = 'Z_MC_TRAVEL_EC'
                                                 number = '002'
                                                  v1 =  <ls_travel>-BeginDate

                                                 severity = if_abap_behv_message=>severity-error )
                          %element-BeginDate = if_abap_behv=>mk-on
                           %element-EndDate = if_abap_behv=>mk-on ) TO reported-travel.

      ENDIF.
    ENDLOOP.


  ENDMETHOD.

  METHOD validateStatus.

    READ ENTITY z_i_travel_ec\\Travel

FIELDS ( CustomerId )
WITH CORRESPONDING #( keys )
RESULT DATA(lt_travel).


    LOOP AT lt_travel ASSIGNING FIELD-SYMBOL(<ls_travel>).

      CASE <ls_travel>-OverallStatus.
        WHEN 'O'.
        WHEN 'A'.
        WHEN 'X'.
        WHEN OTHERS.

          APPEND VALUE #( travelId = <ls_travel>-travelId ) TO failed-travel.

          APPEND VALUE #( travelId = <ls_travel>-travelId
                          %msg     = new_message( id = 'Z_MC_TRAVEL_EC'
                                                   number = '004'
                                                    v1 =  <ls_travel>-OverallStatus

                                                   severity = if_abap_behv_message=>severity-error )
                            %element-OverallStatus = if_abap_behv=>mk-on ) TO reported-travel.
      ENDCASE.



    ENDLOOP.


  ENDMETHOD.

ENDCLASS.

CLASS lsc_Z_I_TRAVEL_EC DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PUBLIC SECTION.

    CONSTANTS: create TYPE string VALUE 'CREATE',
               update TYPE string VALUE 'UPDATE',
               delete TYPE string VALUE 'DELETE'.

  PROTECTED SECTION.

    METHODS save_modified REDEFINITION.

    METHODS cleanup_finalize REDEFINITION.

ENDCLASS.

CLASS lsc_Z_I_TRAVEL_EC IMPLEMENTATION.

  METHOD save_modified.

    DATA: lt_travel_log   TYPE STANDARD TABLE OF zlog_ec,
          lt_travel_log_u TYPE STANDARD TABLE OF zlog_ec.

    DATA(lv_user) = cl_abap_context_info=>get_user_technical_name(  ).

    IF update-travel
     IS NOT INITIAL.

      lt_travel_log = CORRESPONDING #( update-travel MAPPING travel_id        = travelID ).

      LOOP AT update-travel INTO DATA(ls_update_travel).

        ASSIGN lt_travel_log[ travel_id = ls_update_travel-TravelId ] TO FIELD-SYMBOL(<ls_travel_log_bd>).

        GET TIME STAMP FIELD <ls_travel_log_bd>-created_at.
        <ls_travel_log_bd>-changing_operation = lsc_z_i_travel_ec=>update.
        IF ls_update_travel-%control-CustomerId EQ cl_abap_behv=>flag_changed.

          <ls_travel_log_bd>-changed_field_name = 'customer_id'.
          <ls_travel_log_bd>-changed_field_value = ls_update_travel-CustomerId.
          <ls_travel_log_bd>-user_mode = lv_user.

          TRY.
              <ls_travel_log_bd>-change_id = cl_system_uuid=>create_uuid_x16_static(  ).
            CATCH cx_uuid_error.
          ENDTRY.
          APPEND <ls_travel_log_bd> TO lt_travel_log_u.
        ENDIF.


      ENDLOOP.



    ENDIF.


    IF NOT create-travel IS INITIAL.

      lt_travel_log  = CORRESPONDING #( create-travel MAPPING travel_id        = travelID ).

      LOOP AT lt_travel_log ASSIGNING FIELD-SYMBOL(<fs_travel_log>).

        GET TIME STAMP FIELD <fs_travel_log>-created_at.
        <fs_travel_log>-changing_operation = lsc_z_i_travel_ec=>create.

        READ TABLE create-travel WITH TABLE KEY entity COMPONENTS TravelId = <fs_travel_log>-travel_id
        INTO DATA(ls_travel).

        IF sy-subrc EQ 0.

          IF ls_travel-%control-BookingFee EQ cl_abap_behv=>flag_changed.

            <fs_travel_log>-changed_field_name = 'booking_fee'.
            <fs_travel_log>-changed_field_value = ls_travel-BookingFee.
            <fs_travel_log>-user_mode = lv_user.
            TRY.
                <fs_travel_log>-change_id = cl_system_uuid=>create_uuid_x16_static(  ).
              CATCH cx_uuid_error.
            ENDTRY.

            APPEND <fs_travel_log> TO lt_travel_log_u.

          ENDIF.

        ENDIF.

      ENDLOOP.

    ENDIF.

    IF NOT delete-travel IS INITIAL.
      lt_travel_log = CORRESPONDING #( delete-travel MAPPING travel_id        = travelID ).

      LOOP AT lt_travel_log ASSIGNING FIELD-SYMBOL(<ls_travel_log_del>).

        GET TIME STAMP FIELD <ls_travel_log_del>-created_at.
        <ls_travel_log_del>-changing_operation = lsc_z_i_travel_ec=>delete.
        <ls_travel_log_del>-user_mode = lv_user.


        TRY.
            <ls_travel_log_del>-change_id = cl_system_uuid=>create_uuid_x16_static(  ).
          CATCH cx_uuid_error.
        ENDTRY.

        APPEND <ls_travel_log_del> TO lt_travel_log_u.


      ENDLOOP.


    ENDIF.

    IF NOT lt_travel_log_u IS INITIAL.
      INSERT zlog_ec FROM TABLE @lt_travel_log_u.
    ENDIF.

  ENDMETHOD.

  METHOD cleanup_finalize.
  ENDMETHOD.

ENDCLASS.
