--*********************
--Identified Ouput SQL
--*********************
SELECT mrn,
       encounterepiccsn,
       diagnosis_type,
       diagnosis_group,
       diagnosis_description,
       diagnosis_entry_date
  FROM msdw_reporting.covid_diag;

--************************
--De-Identified Ouput SQL
--************************
SELECT masked_mrn,
       masked_encounter_epic_csn,
       diagnosis_type,
       diagnosis_group,
       diagnosis_description,
       diagnosis_entry_date
  FROM msdw_reporting.covid_diag_deid;