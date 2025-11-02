@AbapCatalog.sqlViewName: 'ZV_BOOKING_EC'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface - Booking'
@Metadata.ignorePropagatedAnnotations: true
define view z_i_booking_ec
  as select from zbooking_ec as Booking
  composition [0..*] of z_i_booksuppl_ec  as _BookingSupplement

  association        to parent z_i_travel_ec     as _Travel on $projection.TravelId = _Travel.TravelId
  association [1..1] to /DMO/I_Customer   as _Customer      on $projection.CustomerId = _Customer.CustomerID
  association [1..1] to /DMO/I_Carrier    as _Carrier       on $projection.CarrierId = _Carrier.AirlineID
  association [1..*] to /DMO/I_Connection as _Connection    on $projection.ConnectionId = _Connection.ConnectionID
{
  key travel_id      as TravelId,
  key booking_id     as BookingId,
      booking_date   as BookingDate,
      customer_id    as CustomerId,
      carrier_id     as CarrierId,
      connection_id  as ConnectionId,
      flight_date    as FlightDate,
      flight_price   as FlightPrice,
      currency_code  as CurrencyCode,
      booking_status as BookingStatus,
      last_change_at as LastChangeAt,
      _Travel,
      _BookingSupplement,
      _Customer,
      _Carrier,
      _Connection
}
