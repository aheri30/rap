@AbapCatalog.sqlViewName: 'ZV_BOOK_EC'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CDS Interface - Boooking Supplement'
@Metadata.ignorePropagatedAnnotations: true
define view z_i_booksuppl_ec
  as select from zbooksuppl_ec as BookingSupplement
  association        to parent z_i_booking_ec as _Booking        on  $projection.TravelId  = _Booking.TravelId
                                                                 and $projection.BookingId = _Booking.BookingId

  association [1..1] to z_i_travel_ec         as _Travel         on  $projection.TravelId = _Travel.TravelId
  association [1..1] to /DMO/I_Supplement     as _Supplement     on  $projection.SupplementId = _Supplement.SupplementID
  association [1..*] to /DMO/I_SupplementText as _SupplementText on  $projection.SupplementId = _SupplementText.SupplementID
{
  key travel_id             as TravelId,
  key booking_id            as BookingId,
  key booking_supplement_id as BookingSupplementId,
      supplement_id         as SupplementId,
      @Semantics.amount.currencyCode: 'currency'
      price                 as Price,
      @Semantics.currencyCode: true
      currency              as Currency,
      last_changed_at       as LastChangedAt,
      _Booking,
      _Travel,
      _Supplement,
      _SupplementText
}
