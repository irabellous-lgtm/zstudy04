@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'copy'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZCS04_COPY_d as select from zcs04_copy

{
    key company as Company,
    key street as Street,
    key postcode as Postcode,
    key city as City,
    medium as Medium,
    mvalue1 as Mvalue1,
    mvalue2 as Mvalue2,
    fax as Fax,
    phone as Phone,
    email as Email,
    memo as Memo,
    local_created_by as LocalCreatedBy,
    local_created_at as LocalCreatedAt,
    local_last_changed_by as LocalLastChangedBy,
    local_last_changed_at as LocalLastChangedAt,
    last_changed_at as LastChangedAt
}
