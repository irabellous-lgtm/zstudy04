@Metadata.allowExtensions: true
@Metadata.ignorePropagatedAnnotations: true
@Endusertext: {
  Label: '###GENERATED Core Data Service Entity'
}
@Objectmodel: {
  Sapobjectnodetype.Name: 'ZCS04_EXCEPTION'
}
@AccessControl.authorizationCheck: #MANDATORY
define root view entity ZC_CS04_EXCEPTION
  provider contract TRANSACTIONAL_QUERY
  as projection on ZR_CS04_EXCEPTION
  association [1..1] to ZR_CS04_EXCEPTION as _BaseEntity on $projection.EXCID = _BaseEntity.EXCID
{
  key ExcID,
  Infotype,
  InfoMessage,
  Company,
  LogDate,
  LogTim,
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
