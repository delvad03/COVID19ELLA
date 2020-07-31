--*********************
--Identified Ouput SQL
--*********************
  SELECT mrn,
         encounter_epic_csn,
         encounter_date,
         vital_signs_date,
         temp_max_datetime,
         temp_max,
         heart_rate_max_datetime,
         heart_rate_max,
         heart_rate_min_datetime,
         heart_rate_min,
         resp_rate_max_datetime,
         resp_rate_max,
         systol_bp_max_datetime,
         systol_bp_max,
         diastol_bp_max_datetime,
         diastol_bp_max,
         systol_bp_min_datetime,
         systolic_bp_min,
         diastol_bp_min_datetime,
         diastolic_bp_min,
         o2sat_min_datetime,
         o2sat_min,
         TRUNC (SYSDATE)     AS run_date
    FROM msdw_reporting.covid_vitals_stg vi
ORDER BY mrn, encounter_epic_csn, vital_signs_date;

--************************
--De-Identified Ouput SQL
--************************
  SELECT new_masked_mrn,
         new_masked_encounter_epic_csn,
         encounter_date,
         vital_signs_days_since_enc,
         temp_max_days_since_enc,
         temp_max,
         heart_rate_max_days_since_enc,
         heart_rate_max,
         heart_rate_min_days_since_enc,
         heart_rate_min,
         resp_rate_max_days_since_enc,
         resp_rate_max,
         systol_bp_max_days_since_enc,
         systol_bp_max,
         diastol_bp_max_days_since_enc,
         diastol_bp_max,
         systol_bp_min_days_since_enc,
         systolic_bp_min,
         diastol_bp_min_days_since_enc,
         diastolic_bp_min,
         o2sat_min_days_since_enc,
         o2sat_min,
         TRUNC (SYSDATE)     AS run_date
    FROM msdw_reporting.covid_vitals_stg_deid vi
ORDER BY masked_mrn, masked_encounter_epic_csn, vital_signs_days_since_enc;