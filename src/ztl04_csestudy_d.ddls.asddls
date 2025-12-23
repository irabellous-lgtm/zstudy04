@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'CASESTUDY'
@Metadata.ignorePropagatedAnnotations: true
define view entity ztl04_csestudy_d as select from ztl_00_casestudy
{
    key uuid as Uuid,
    import as Import,
    local_created_by as LocalCreatedBy,
    local_created_at as LocalCreatedAt,
    local_last_changed_by as LocalLastChangedBy,
    local_last_changed_at as LocalLastChangedAt,
    last_changed_at as LastChangedAt
}
