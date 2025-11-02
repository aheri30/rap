FUNCTION z_suppl_ec.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(IT_SUPPLEMENT) TYPE  ZTT_SUPPL_EC
*"     REFERENCE(IV_OP_TYPE) TYPE  ZDE_FLAG
*"  EXPORTING
*"     REFERENCE(EV_UPDATED) TYPE  ZDE_FLAG
*"----------------------------------------------------------------------
  CHECK NOT it_supplement IS INITIAL.

  CASE iv_op_type.
    WHEN 'C'.
      INSERT zbooksuppl_ec FROM TABLE @it_supplement.
    WHEN 'U'.
      UPDATE zbooksuppl_ec FROM TABLE @it_supplement.
    WHEN 'D'.
      DELETE zbooksuppl_ec FROM TABLE @it_supplement.
  ENDCASE.

  IF sy-subrc EQ 0.
    ev_updated = abap_true.
  ENDIF.




ENDFUNCTION.
