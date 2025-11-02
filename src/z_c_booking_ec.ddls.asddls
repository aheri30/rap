@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Consumption - Booking'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity z_c_booking_ec as projection on z_i_booking_ec
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
     _Travel : redirected to parent z_c_travel_ec,
    _BookingSupplement : redirected to composition child z_c_booksuppl_ec,
    _Carrier,
    _Connection,
    _Customer
   
}
