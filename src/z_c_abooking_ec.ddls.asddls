@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Consumption - Booking Approval'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity z_c_abooking_ec as projection on z_i_booking_ec
{
     key TravelId,
    key BookingId,
    BookingDate,
    CustomerId,
    CarrierId,
    @ObjectModel.text.element: ['CarrierName']
    _Carrier.Name as CarrierName,
    ConnectionId,
    FlightDate,
    @Semantics.amount.currencyCode: 'CurrencyCode'
    FlightPrice,
    CurrencyCode,
    BookingStatus,
    LastChangeAt,
    
    /* Associations */
    _Travel : redirected to parent Z_C_ATRAVEL_EC,
    _Customer,
    _Carrier
}
