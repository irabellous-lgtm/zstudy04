@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'SALUTATION'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel:{
    resultSet.sizeCategory:#XS,
    usageType.serviceQuality: #X,
    usageType.sizeCategory: #S,
    usageType.dataClass: #MIXED
}
  
define view entity ZCS04_CSALUTATION as select from ZCS4_DomainSALUTATION
{
  key value_low as Salutation,
      @Semantics.text: true
      @UI.hidden: true
      text as Text
}
where language =  $session.system_language
