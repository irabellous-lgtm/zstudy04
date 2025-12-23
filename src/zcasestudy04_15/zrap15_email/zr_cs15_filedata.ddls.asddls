@AccessControl.authorizationCheck: #MANDATORY
@Metadata.allowExtensions: true
@ObjectModel.sapObjectNodeType.name: 'zCS15_FILEDATA'
@EndUserText.label: '###GENERATED Core Data Service Entity'
define root view entity ZR_CS15_FILEDATA
  as select from ZCS15_FILEDATA
{
  key cuid as Cuid,
  company as Company,
  street as Street,
  postcode as Postcode,
  city as City,
  medium as Medium,
  mvalue1 as Mvalue1,
  mvalue2 as Mvalue2,
  fax as Fax,
  phone as Phone,
  email as Email,
  memo as Memo,
  @Semantics.user.createdBy: true
  local_created_by as LocalCreatedBy,
  @Semantics.systemDateTime.createdAt: true
  local_created_at as LocalCreatedAt,
  @Semantics.user.localInstanceLastChangedBy: true
  local_last_changed_by as LocalLastChangedBy,
  @Semantics.systemDateTime.localInstanceLastChangedAt: true
  local_last_changed_at as LocalLastChangedAt,
  @Semantics.systemDateTime.lastChangedAt: true
  last_changed_at as LastChangedAt
}
