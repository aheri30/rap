@AbapCatalog.sqlViewName: 'ZV_EMPLOYEE_EC'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Employees'
@Metadata.ignorePropagatedAnnotations: true
define root view Z_I_EMPLOYEE_EC
  as select from zemployee_ec as Employee
{
  key e_number,
      e_name,
      e_department,
      status,
      job_title,
      start_date,
      end_date,
      email,
      m_numer,
      m_name,
      m_department,
      create_data_time,
      create_uname,
      lchg_update_time,
      lchg_uname
}
