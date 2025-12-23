@AccessControl.authorizationCheck: #MANDATORY
@Metadata.allowExtensions: true
@ObjectModel.sapObjectNodeType.name: 'ZCS04_EXCEPTION'
@EndUserText.label: '###GENERATED Core Data Service Entity'
define root view entity ZR_CS04_EXCEPTION
  as select from zcs04_exception
{
  key exc_id as ExcID,
  infotype as Infotype,
  info_message as InfoMessage,
  exception_type as ExceptionType,
  company as Company,
  log_date as LogDate,
  log_tim as LogTim,
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
