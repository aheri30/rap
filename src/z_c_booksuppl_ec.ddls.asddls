@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Consumption - Boooking Supplement'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define view entity z_c_booksuppl_ec as projection on z_i_booksuppl_ec
{
    key TravelId,
    key BookingId,
    key BookingSupplementId,
    SupplementId,
    _SupplementText.Description as SupplementDescription : localized, 
    @Semantics.amount.currencyCode: 'Currency'
    Price,
    Currency,
    LastChangedAt,
    /* Associations */
     _Travel : redirected to z_c_travel_ec,
    _Booking : redirected to parent z_c_booking_ec,
    _Supplement,
    _SupplementText
   
}
