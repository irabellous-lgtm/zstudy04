@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CustomerOrders Projection'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZCDSPRJ17_CustomerOrders as projection on ZCDS17_Customerorders
{
    key Customerid,
    key Orderid,
    OrderDate,
    @Semantics.amount.currencyCode : 'Currency'
    OrderTotal,
    Discount,
    Info,
    Status,
    Currency,
    LocalCreatedBy,
    LocalCreatedAt,
    LocalLastChangedBy,
    LocalLastChangedAt,
    LastChangedAt
    /* Associations */
//    _Customer
}
