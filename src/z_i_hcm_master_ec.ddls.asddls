@AbapCatalog.sqlViewName: 'ZV_HCM_EC'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'HCM Master'
@Metadata.ignorePropagatedAnnotations: true
define root view z_i_hcm_master_ec
  as select from zhcm_master_ec
{
  key e_number         ,
      e_name           ,
      e_department     ,
      status           ,
      job_title        ,
      start_date       ,
      end_date         ,
      email            ,
      m_numer          ,
      m_name           ,
      m_department     ,
      create_data_time ,
      create_uname     ,
      lchg_update_time ,
      lchg_uname       
}
