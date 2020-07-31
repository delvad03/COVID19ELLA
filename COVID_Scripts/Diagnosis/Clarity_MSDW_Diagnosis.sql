PROCEDURE proc_etl_covid19_diag
AS
BEGIN
    INSERT INTO covid_etl_log (package_name, procedure_name, operation_name)
             VALUES ('PKG_COVID19_REPORT',
                     'proc_etl_covid19_diag',
                     'proc_etl_covid19_diag');

    COMMIT;

    INSERT INTO covid_diag_deid
          SELECT m_mrn.new_masked_mrn,
                 m_enc.new_masked_encounter_epic_csn,
                 cd.diagnosis_type,
                 cd.diagnosis_group,
                 cd.diagnosis_description,
                 CASE
                     WHEN cd.diagnosis_type = 'Encounter Diagnosis'
                     THEN
                         0
                     ELSE
                           TO_DATE (cd.diagnosis_entry_date, 'YYYY-MM-DD')
                         - TRUNC (
                               TO_DATE (cs.encounterdate,
                                        'YYYY-MM-DD HH24:MI:SS'))
                 END    AS diagnosis_entry_date_since_encounter
            FROM msdw_reporting.covid_diag cd
                 JOIN msdw_reporting.covid19_masked_mrn_mapping m_mrn
                     ON cd.mrn = m_mrn.mrn
                 JOIN msdw_reporting.covid19_masked_enc_mapping m_enc
                     ON cd.encounterepiccsn = m_enc.encounter_epic_csn
                 JOIN (SELECT DISTINCT encounterepiccsn, encounterdate
                         FROM msdw_reporting.covid_stg) cs
                     ON cs.encounterepiccsn = cd.encounterepiccsn
        ORDER BY m_mrn.new_masked_mrn,
                 m_enc.new_masked_encounter_epic_csn,
                 diagnosis_entry_date;


    UPDATE covid_etl_log
       SET end_date_time = SYSTIMESTAMP
     WHERE     package_name = 'PKG_COVID19_REPORT'
           AND procedure_name = 'proc_etl_covid19_diag'
           AND operation_name = 'proc_etl_covid19_diag'
           AND end_date_time IS NULL;

    COMMIT;
END proc_etl_covid19_diag;