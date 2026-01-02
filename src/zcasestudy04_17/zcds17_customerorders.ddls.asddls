@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Customerorders  CDS'
@Metadata.ignorePropagatedAnnotations: true
define view entity ZCDS17_Customerorders as select from zcs17_custorders 
    association to parent ZCDS17_Customer as _Customer
    on $projection.Customerid = _Customer.Customerid
{    @ObjectModel.foreignKey.association: '_Customer'
    key customerid as Customerid,
    key orderid as Orderid,
    order_date as OrderDate,
    @Semantics.amount.currencyCode : 'Currency'
    order_total as OrderTotal,
    discount as Discount,
    info as Info,
    status as Status,
    currency as Currency,
    local_created_by as LocalCreatedBy,
    local_created_at as LocalCreatedAt,
    local_last_changed_by as LocalLastChangedBy,
    local_last_changed_at as LocalLastChangedAt,
    last_changed_at as LastChangedAt,
    _Customer

}
