@Metadata.allowExtensions: true
@Metadata.ignorePropagatedAnnotations: true
@Endusertext: {
  Label: '###GENERATED Core Data Service Entity'
}
@Objectmodel: {
  Sapobjectnodetype.Name: 'zCS15_FILEDATA'
}
@AccessControl.authorizationCheck: #MANDATORY
define root view entity ZC_CS15_FILEDATA000
  provider contract TRANSACTIONAL_QUERY
  as projection on ZR_CS15_FILEDATA
  association [1..1] to ZR_CS15_FILEDATA as _BaseEntity on $projection.CUID = _BaseEntity.CUID
{
  key Cuid,
  Company,
  Street,
  Postcode,
  City,
  Medium,
  Mvalue1,
  Mvalue2,
  Fax,
  Phone,
  Email,
  Memo,
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
