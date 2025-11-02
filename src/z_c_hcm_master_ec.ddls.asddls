@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'HCM Master'
@Metadata.ignorePropagatedAnnotations: true
@Metadata: {
    allowExtensions: true
}
define root view entity z_c_hcm_master_ec
  as projection on z_i_hcm_master_ec
{
      @ObjectModel.text.element: [ 'EmployeeName' ]
  key e_number         as EmployeeNumber,
      e_name           as EmployeeName,
      e_department     as EmployeeDespartment,
      status           as EmployeeStatus,
      job_title        as JobTitle,
      start_date       as StartDate,
      end_date         as EndDate,
      email            as Email,
      @ObjectModel.text.element: [ 'ManagerName' ]
      m_numer          as ManagerNumber,
      m_name           as ManagerName,
      m_department     as ManagerDepartment,
      
      create_data_time as CreatedOn,
      @Semantics.user.createdBy: true
      create_uname     as CreatedBy,
      
      lchg_update_time as ChangedOn,
      @Semantics.user.lastChangedBy: true
      lchg_uname       as changedBy
}
