--*********************
--Identified Ouput SQL
--*********************
  SELECT mrn,
         encounter_epic_csn,
         encounter_date,
         record_type,
         administration_date,
         order_date,
         CASE
             WHEN generic_name = 'NO (ppm)' THEN generic_name
             ELSE medication_name
         END                AS medication_name,
         generic_name,
         strength,
         form,
         route,
         dose,
         dose_uom,
         TRUNC (SYSDATE)    AS run_date
    FROM msdw_reporting.covid19_medications_final la
ORDER BY 1, 2, 3;

--************************
--De-Identified Ouput SQL
--************************
  SELECT new_masked_mrn,
         new_masked_encounter_epic_csn,
         record_type,
         med_admin_days_since_enc,
         med_order_days_since_enc,
         CASE
             WHEN generic_name = 'NO (ppm)' THEN generic_name
             ELSE medication_name
         END                AS medication_name,
         generic_name,
         strength,
         form,
         route,
         dose,
         dose_uom,
         TRUNC (SYSDATE)    AS run_date
    FROM msdw_reporting.covid19_medications_final_deid la
ORDER BY 1, 2;