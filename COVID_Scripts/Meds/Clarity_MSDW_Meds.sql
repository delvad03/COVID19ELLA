PROCEDURE proc_etl_covid19_meds
AS
BEGIN
    INSERT INTO covid_etl_log (package_name, procedure_name, operation_name)
             VALUES ('PKG_COVID19_REPORT',
                     'proc_etl_covid19_meds',
                     'proc_etl_covid19_meds');

    COMMIT;

    INSERT INTO covid19_medications_final
        SELECT DISTINCT
               mrn,
               encounter_epic_csn,
               TO_DATE (SUBSTR (encounter_date, 1, 16), 'yyyy-mm-dd hh24:mi')
                   encounter_date,
               TO_DATE (SUBSTR (administration_date, 1, 16),
                        'yyyy-mm-dd hh24:mi')
                   administration_date,
               medication_name,
               generic_name,
               strength,
               form,
               route,
               dose,
               dose_uom,
               record_type,
               TO_DATE (SUBSTR (order_date, 1, 16), 'yyyy-mm-dd hh24:mi')
                   order_date
          FROM covid19_medications_v2;

    COMMIT;

    INSERT INTO covid19_medications_final_deid
        SELECT mkmrn.masked_mrn,
               mkenc.masked_encounter_epic_csn,
               ROUND (
                     EXTRACT (
                         DAY FROM   CAST (administration_date AS TIMESTAMP)
                                  - CAST (encounter_date AS TIMESTAMP))
                   +   EXTRACT (
                           HOUR FROM   CAST (
                                           administration_date AS TIMESTAMP)
                                     - CAST (encounter_date AS TIMESTAMP))
                     / 24
                   +   EXTRACT (
                           MINUTE FROM   CAST (
                                             administration_date AS TIMESTAMP)
                                       - CAST (encounter_date AS TIMESTAMP))
                     / 1440,
                   2)
                   med_admin_days_since_enc,
               medication_name,
               generic_name,
               strength,
               form,
               route,
               dose,
               dose_uom,
               mkmrn.new_masked_mrn,
               mkenc.new_masked_encounter_epic_csn,
               ROUND (
                   EXTRACT (
                       DAY FROM   CAST (order_date AS TIMESTAMP)
                                - CAST (encounter_date AS TIMESTAMP)))
                   med_order_days_since_enc,
               record_type
          FROM covid19_medications_final  a
               JOIN covid19_masked_mrn_mapping mkmrn ON mkmrn.mrn = a.mrn
               JOIN covid19_masked_enc_mapping mkenc
                   ON mkenc.encounter_epic_csn = a.encounter_epic_csn;

    COMMIT;

    UPDATE covid_etl_log
       SET end_date_time = SYSTIMESTAMP
     WHERE     package_name = 'PKG_COVID19_REPORT'
           AND procedure_name = 'proc_etl_covid19_meds'
           AND operation_name = 'proc_etl_covid19_meds'
           AND end_date_time IS NULL;

    COMMIT;
END proc_etl_covid19_meds;