@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Consumption - travel'
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
define root view entity z_c_travel_ec
  as projection on z_i_travel_ec
{

  key     TravelId,
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
          @Semantics.amount.currencyCode: 'CurrencyCode'
          @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_VIRT_ELEM_EC'
  virtual DiscountPrice : /dmo/total_price,
          /* Associations */
          _Agency,
          _Booking : redirected to composition child z_c_booking_ec,
          _Currency,
          _Customer
}
