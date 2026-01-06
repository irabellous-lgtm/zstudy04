@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Customer Projection'
@UI.headerInfo: {
  typeName: 'Customer',
  typeNamePlural: 'Customers',
  title: { value: 'Customerid' }
  }
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZCDSPRJ17_Customer as projection on ZCDS17_Customer
{
    key Customerid,
    Salutation,
    LastName,
    FirstName,
    Company,
    Street,
    City,
    Country,
    Postcode,
    AccLock,
    LastDate,
     @Semantics.amount.currencyCode : 'currency'
    SalesVolume,
     @Semantics.amount.currencyCode : 'currency'
    SalesVolumeTarget,
    ChangeRateDate,
    Fax,
    Phone,
    Email,
    Url,
    Currency,
    CurrencyTarget,
    Language,
    Weblogin,
    Webpw,
    Memo,
    LocalCreatedBy,
    LocalCreatedAt,
    LocalLastChangedBy,
    LocalLastChangedAt,
    LastChangedAt,
    /* Associations */
    _Customerorders
}
