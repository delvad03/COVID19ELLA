PROCEDURE proc_etl_covid19_vital
AS
BEGIN
    INSERT INTO covid_etl_log (package_name, procedure_name, operation_name)
             VALUES ('PKG_COVID19_REPORT',
                     'proc_etl_covid19_vital',
                     'proc_etl_covid19_vital');

    COMMIT;

    INSERT INTO msdw_reporting.covid_vitals_stg_deid
          SELECT b.masked_mrn,
                 c.masked_encounter_epic_csn,
                 0
                     AS encounter_date,
                 ROUND (
                       TRUNC (
                           TO_DATE (vital_signs_date, 'mm/dd/yyyy hh:mi:ss am'))
                     - TRUNC (
                           TO_DATE (a.encounter_date, 'mm/dd/yyyy hh:mi:ss am')))
                     vital_signs_days_since_enc,
                 ROUND (
                       EXTRACT (
                           DAY FROM   CAST (
                                          TO_DATE (temp_max_datetime,
                                                   'mm/dd/yyyy hh:mi:ss am')
                                              AS TIMESTAMP)
                                    - CAST (
                                          TO_DATE (encounter_date,
                                                   'mm/dd/yyyy hh:mi:ss am')
                                              AS TIMESTAMP))
                     +   EXTRACT (
                             HOUR FROM   CAST (
                                             TO_DATE (temp_max_datetime,
                                                      'mm/dd/yyyy hh:mi:ss am')
                                                 AS TIMESTAMP)
                                       - CAST (
                                             TO_DATE (encounter_date,
                                                      'mm/dd/yyyy hh:mi:ss am')
                                                 AS TIMESTAMP))
                       / 24
                     +   EXTRACT (
                             MINUTE FROM   CAST (
                                               TO_DATE (
                                                   temp_max_datetime,
                                                   'mm/dd/yyyy hh:mi:ss am')
                                                   AS TIMESTAMP)
                                         - CAST (
                                               TO_DATE (
                                                   encounter_date,
                                                   'mm/dd/yyyy hh:mi:ss am')
                                                   AS TIMESTAMP))
                       / 1440,
                     2)
                     temp_max_days_since_enc,
                 temp_max,
                 ROUND (
                       EXTRACT (
                           DAY FROM   CAST (
                                          TO_DATE (heart_rate_max_datetime,
                                                   'mm/dd/yyyy hh:mi:ss am')
                                              AS TIMESTAMP)
                                    - CAST (
                                          TO_DATE (encounter_date,
                                                   'mm/dd/yyyy hh:mi:ss am')
                                              AS TIMESTAMP))
                     +   EXTRACT (
                             HOUR FROM   CAST (
                                             TO_DATE (heart_rate_max_datetime,
                                                      'mm/dd/yyyy hh:mi:ss am')
                                                 AS TIMESTAMP)
                                       - CAST (
                                             TO_DATE (encounter_date,
                                                      'mm/dd/yyyy hh:mi:ss am')
                                                 AS TIMESTAMP))
                       / 24
                     +   EXTRACT (
                             MINUTE FROM   CAST (
                                               TO_DATE (
                                                   heart_rate_max_datetime,
                                                   'mm/dd/yyyy hh:mi:ss am')
                                                   AS TIMESTAMP)
                                         - CAST (
                                               TO_DATE (
                                                   encounter_date,
                                                   'mm/dd/yyyy hh:mi:ss am')
                                                   AS TIMESTAMP))
                       / 1440,
                     2)
                     heart_rate_max_days_since_enc,
                 heart_rate_max,
                 ROUND (
                       EXTRACT (
                           DAY FROM   CAST (
                                          TO_DATE (heart_rate_min_datetime,
                                                   'mm/dd/yyyy hh:mi:ss am')
                                              AS TIMESTAMP)
                                    - CAST (
                                          TO_DATE (encounter_date,
                                                   'mm/dd/yyyy hh:mi:ss am')
                                              AS TIMESTAMP))
                     +   EXTRACT (
                             HOUR FROM   CAST (
                                             TO_DATE (heart_rate_min_datetime,
                                                      'mm/dd/yyyy hh:mi:ss am')
                                                 AS TIMESTAMP)
                                       - CAST (
                                             TO_DATE (encounter_date,
                                                      'mm/dd/yyyy hh:mi:ss am')
                                                 AS TIMESTAMP))
                       / 24
                     +   EXTRACT (
                             MINUTE FROM   CAST (
                                               TO_DATE (
                                                   heart_rate_min_datetime,
                                                   'mm/dd/yyyy hh:mi:ss am')
                                                   AS TIMESTAMP)
                                         - CAST (
                                               TO_DATE (
                                                   encounter_date,
                                                   'mm/dd/yyyy hh:mi:ss am')
                                                   AS TIMESTAMP))
                       / 1440,
                     2)
                     heart_rate_min_days_since_enc,
                 heart_rate_min,
                 ROUND (
                       EXTRACT (
                           DAY FROM   CAST (
                                          TO_DATE (resp_rate_max_datetime,
                                                   'mm/dd/yyyy hh:mi:ss am')
                                              AS TIMESTAMP)
                                    - CAST (
                                          TO_DATE (encounter_date,
                                                   'mm/dd/yyyy hh:mi:ss am')
                                              AS TIMESTAMP))
                     +   EXTRACT (
                             HOUR FROM   CAST (
                                             TO_DATE (resp_rate_max_datetime,
                                                      'mm/dd/yyyy hh:mi:ss am')
                                                 AS TIMESTAMP)
                                       - CAST (
                                             TO_DATE (encounter_date,
                                                      'mm/dd/yyyy hh:mi:ss am')
                                                 AS TIMESTAMP))
                       / 24
                     +   EXTRACT (
                             MINUTE FROM   CAST (
                                               TO_DATE (
                                                   resp_rate_max_datetime,
                                                   'mm/dd/yyyy hh:mi:ss am')
                                                   AS TIMESTAMP)
                                         - CAST (
                                               TO_DATE (
                                                   encounter_date,
                                                   'mm/dd/yyyy hh:mi:ss am')
                                                   AS TIMESTAMP))
                       / 1440,
                     2)
                     resp_rate_max_days_since_enc,
                 resp_rate_max,
                 ROUND (
                       EXTRACT (
                           DAY FROM   CAST (
                                          TO_DATE (systol_bp_max_datetime,
                                                   'mm/dd/yyyy hh:mi:ss am')
                                              AS TIMESTAMP)
                                    - CAST (
                                          TO_DATE (encounter_date,
                                                   'mm/dd/yyyy hh:mi:ss am')
                                              AS TIMESTAMP))
                     +   EXTRACT (
                             HOUR FROM   CAST (
                                             TO_DATE (systol_bp_max_datetime,
                                                      'mm/dd/yyyy hh:mi:ss am')
                                                 AS TIMESTAMP)
                                       - CAST (
                                             TO_DATE (encounter_date,
                                                      'mm/dd/yyyy hh:mi:ss am')
                                                 AS TIMESTAMP))
                       / 24
                     +   EXTRACT (
                             MINUTE FROM   CAST (
                                               TO_DATE (
                                                   systol_bp_max_datetime,
                                                   'mm/dd/yyyy hh:mi:ss am')
                                                   AS TIMESTAMP)
                                         - CAST (
                                               TO_DATE (
                                                   encounter_date,
                                                   'mm/dd/yyyy hh:mi:ss am')
                                                   AS TIMESTAMP))
                       / 1440,
                     2)
                     systol_bp_max_days_since_enc,
                 systol_bp_max,
                 ROUND (
                       EXTRACT (
                           DAY FROM   CAST (
                                          TO_DATE (diastol_bp_max_datetime,
                                                   'mm/dd/yyyy hh:mi:ss am')
                                              AS TIMESTAMP)
                                    - CAST (
                                          TO_DATE (encounter_date,
                                                   'mm/dd/yyyy hh:mi:ss am')
                                              AS TIMESTAMP))
                     +   EXTRACT (
                             HOUR FROM   CAST (
                                             TO_DATE (diastol_bp_max_datetime,
                                                      'mm/dd/yyyy hh:mi:ss am')
                                                 AS TIMESTAMP)
                                       - CAST (
                                             TO_DATE (encounter_date,
                                                      'mm/dd/yyyy hh:mi:ss am')
                                                 AS TIMESTAMP))
                       / 24
                     +   EXTRACT (
                             MINUTE FROM   CAST (
                                               TO_DATE (
                                                   diastol_bp_max_datetime,
                                                   'mm/dd/yyyy hh:mi:ss am')
                                                   AS TIMESTAMP)
                                         - CAST (
                                               TO_DATE (
                                                   encounter_date,
                                                   'mm/dd/yyyy hh:mi:ss am')
                                                   AS TIMESTAMP))
                       / 1440,
                     2)
                     diastol_bp_max_days_since_enc,
                 diastol_bp_max,
                 ROUND (
                       EXTRACT (
                           DAY FROM   CAST (
                                          TO_DATE (o2sat_min_datetime,
                                                   'mm/dd/yyyy hh:mi:ss am')
                                              AS TIMESTAMP)
                                    - CAST (
                                          TO_DATE (encounter_date,
                                                   'mm/dd/yyyy hh:mi:ss am')
                                              AS TIMESTAMP))
                     +   EXTRACT (
                             HOUR FROM   CAST (
                                             TO_DATE (o2sat_min_datetime,
                                                      'mm/dd/yyyy hh:mi:ss am')
                                                 AS TIMESTAMP)
                                       - CAST (
                                             TO_DATE (encounter_date,
                                                      'mm/dd/yyyy hh:mi:ss am')
                                                 AS TIMESTAMP))
                       / 24
                     +   EXTRACT (
                             MINUTE FROM   CAST (
                                               TO_DATE (
                                                   o2sat_min_datetime,
                                                   'mm/dd/yyyy hh:mi:ss am')
                                                   AS TIMESTAMP)
                                         - CAST (
                                               TO_DATE (
                                                   encounter_date,
                                                   'mm/dd/yyyy hh:mi:ss am')
                                                   AS TIMESTAMP))
                       / 1440,
                     2)
                     o2sat_min_days_since_enc,
                 o2sat_min,
                 b.new_masked_mrn,
                 c.new_masked_encounter_epic_csn,
                 ROUND (
                       EXTRACT (
                           DAY FROM   CAST (
                                          TO_DATE (systol_bp_min_datetime,
                                                   'mm/dd/yyyy hh:mi:ss am')
                                              AS TIMESTAMP)
                                    - CAST (
                                          TO_DATE (encounter_date,
                                                   'mm/dd/yyyy hh:mi:ss am')
                                              AS TIMESTAMP))
                     +   EXTRACT (
                             HOUR FROM   CAST (
                                             TO_DATE (systol_bp_min_datetime,
                                                      'mm/dd/yyyy hh:mi:ss am')
                                                 AS TIMESTAMP)
                                       - CAST (
                                             TO_DATE (encounter_date,
                                                      'mm/dd/yyyy hh:mi:ss am')
                                                 AS TIMESTAMP))
                       / 24
                     +   EXTRACT (
                             MINUTE FROM   CAST (
                                               TO_DATE (
                                                   systol_bp_min_datetime,
                                                   'mm/dd/yyyy hh:mi:ss am')
                                                   AS TIMESTAMP)
                                         - CAST (
                                               TO_DATE (
                                                   encounter_date,
                                                   'mm/dd/yyyy hh:mi:ss am')
                                                   AS TIMESTAMP))
                       / 1440,
                     2)
                     systol_bp_min_days_since_enc,
                 systolic_bp_min,
                 ROUND (
                       EXTRACT (
                           DAY FROM   CAST (
                                          TO_DATE (diastol_bp_min_datetime,
                                                   'mm/dd/yyyy hh:mi:ss am')
                                              AS TIMESTAMP)
                                    - CAST (
                                          TO_DATE (encounter_date,
                                                   'mm/dd/yyyy hh:mi:ss am')
                                              AS TIMESTAMP))
                     +   EXTRACT (
                             HOUR FROM   CAST (
                                             TO_DATE (diastol_bp_min_datetime,
                                                      'mm/dd/yyyy hh:mi:ss am')
                                                 AS TIMESTAMP)
                                       - CAST (
                                             TO_DATE (encounter_date,
                                                      'mm/dd/yyyy hh:mi:ss am')
                                                 AS TIMESTAMP))
                       / 24
                     +   EXTRACT (
                             MINUTE FROM   CAST (
                                               TO_DATE (
                                                   diastol_bp_min_datetime,
                                                   'mm/dd/yyyy hh:mi:ss am')
                                                   AS TIMESTAMP)
                                         - CAST (
                                               TO_DATE (
                                                   encounter_date,
                                                   'mm/dd/yyyy hh:mi:ss am')
                                                   AS TIMESTAMP))
                       / 1440,
                     2)
                     diastol_bp_min_days_since_enc,
                 diastolic_bp_min
            FROM msdw_reporting.covid_vitals_stg a
                 JOIN msdw_reporting.covid19_masked_mrn_mapping b
                     ON a.mrn = b.mrn
                 JOIN msdw_reporting.covid19_masked_enc_mapping c
                     ON CAST (a.encounter_epic_csn AS VARCHAR (999)) =
                        c.encounter_epic_csn
        ORDER BY b.masked_mrn, c.masked_encounter_epic_csn, vital_signs_date;

    UPDATE covid_etl_log
       SET end_date_time = SYSTIMESTAMP
     WHERE     package_name = 'PKG_COVID19_REPORT'
           AND procedure_name = 'proc_etl_covid19_vital'
           AND operation_name = 'proc_etl_covid19_vital'
           AND end_date_time IS NULL;

    COMMIT;
END proc_etl_covid19_vital;