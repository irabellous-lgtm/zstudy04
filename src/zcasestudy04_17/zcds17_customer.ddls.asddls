@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Customer CDS'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZCDS17_Customer as select from zcs17_customers
composition[0..*] of ZCDS17_Customerorders as _Customerorders
{
    key customerid as Customerid,
    salutation as Salutation,
    last_name as LastName,
    first_name as FirstName,
    company as Company,
    street as Street,
    city as City,
    country as Country,
    postcode as Postcode,
    acc_lock as AccLock,
    last_date as LastDate,
   @Semantics.amount.currencyCode : 'currency'
    sales_volume as SalesVolume,
   @Semantics.amount.currencyCode : 'currency'
    sales_volume_target as SalesVolumeTarget,
    change_rate_date as ChangeRateDate,
    fax as Fax,
    phone as Phone,
    email as Email,
    url as Url,
    currency as Currency,
    currency_target as CurrencyTarget,
    language as Language,
    weblogin as Weblogin,
    webpw as Webpw,
    memo as Memo,
    local_created_by as LocalCreatedBy,
    local_created_at as LocalCreatedAt,
    local_last_changed_by as LocalLastChangedBy,
    local_last_changed_at as LocalLastChangedAt,
    last_changed_at as LastChangedAt,
    _Customerorders
     // Make association public
}
