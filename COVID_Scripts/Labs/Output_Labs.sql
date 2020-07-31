--*********************
--Identified Ouput SQL
--*********************
  SELECT mrn,
         encounter_epic_csn,
         encounter_date,
         lab_order_name,
         order_date,
         lab_component_name,
         result,
         result_numeric,
         result_uom,
         result_status,
         result_date,
         lab_component_type,
         TRUNC (SYSDATE)     AS run_date
    FROM msdw_reporting.covid19_labs_final la
ORDER BY 1, 2, 3;

--************************
--De-Identified Ouput SQL
--************************
  SELECT new_masked_mrn,
         new_masked_encounter_epic_csn,
         lab_order_name,
         lab_order_days_since_enc,
         result_days_since_enc,
         lab_component_name,
         result,
         result_numeric,
         result_uom,
         result_status,
         lab_component_type,
         TRUNC (SYSDATE)     AS run_date
    FROM msdw_reporting.covid19_labs_final_deid la
ORDER BY 1, 2;