@Metadata.allowExtensions: true
@Metadata.ignorePropagatedAnnotations: true
@Endusertext: {
  Label: '###GENERATED Core Data Service Entity'
}
@Objectmodel: {
  Sapobjectnodetype.Name: 'ZCS04_CUSTORDERS'
}
@AccessControl.authorizationCheck: #MANDATORY
define root view entity ZC_CS04_CUSTORDERS000
  provider contract TRANSACTIONAL_QUERY
  as projection on ZR_CS04_CUSTORDERS
  association [1..1] to ZR_CS04_CUSTORDERS as _BaseEntity on $projection.CUSTOMERID = _BaseEntity.CUSTOMERID and $projection.ORDERID = _BaseEntity.ORDERID
{
  key Customerid,
  key Orderid,
  OrderDate,
  @Semantics: {
    Amount.Currencycode: 'Currency'
  }
  OrderTotal,
  Discount,
  Info,
  Status,
  @Consumption: {
    Valuehelpdefinition: [ {
      Entity.Element: 'Currency', 
      Entity.Name: 'I_CurrencyStdVH', 
      Useforvalidation: true
    } ]
  }
  Currency,
  @Semantics: {
    User.Createdby: true
  }
  LocalCreatedBy,
  @Semantics: {
    Systemdatetime.Createdat: true
  }
  LocalCreatedAt,
  @Semantics: {
    User.Localinstancelastchangedby: true
  }
  LocalLastChangedBy,
  @Semantics: {
    Systemdatetime.Localinstancelastchangedat: true
  }
  LocalLastChangedAt,
  @Semantics: {
    Systemdatetime.Lastchangedat: true
  }
  LastChangedAt,
  _BaseEntity
}
