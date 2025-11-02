@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Consumption - travel Approval'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity Z_C_ATRAVEL_EC
  as projection on z_i_travel_ec
{

  key TravelId,
      AgencyId,
      CustomerId,
      BeginDate,
      EndDate,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      BookingFee,
      @Semantics.amount.currencyCode: 'CurrencyCode'
      TotalPrice,
      CurrencyCode,
      Description,
      OverallStatus as TravelStatus,

      LastChangedAt,
      /* Associations */

       _Booking : redirected to composition child z_c_abooking_ec,

      _Customer
}
