@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'SALUTATION Domain'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED}
    
define view entity ZCS4_DomainSALUTATION as select from 
  DDCDS_CUSTOMER_DOMAIN_VALUE_T( p_domain_name: 'ZDSALUTATION04' )
{
      @UI.hidden: true
  key domain_name,
      @UI.hidden: true
  key value_position,
      @Semantics.language: true
  key language,
      value_low,
      @Semantics.text: true
      @UI.hidden: true
      text
}   
