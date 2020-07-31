PROCEDURE proc_etl_covid19_labs
AS
BEGIN
    INSERT INTO covid_etl_log (package_name, procedure_name, operation_name)
             VALUES ('PKG_COVID19_REPORT',
                     'proc_etl_covid19_labs',
                     'proc_etl_covid19_labs');

    COMMIT;


    INSERT INTO covid19_labs_final (mrn,
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
                                    lab_component_type)
        SELECT DISTINCT
               mrn,
               encounterepiccsn
                   encounter_epic_csn,
               TO_DATE (SUBSTR (encounterdate, 1, 16), 'yyyy-mm-dd hh24:mi')
                   encounter_date,
               lab_order
                   lab_order_name,
               TO_DATE (SUBSTR (order_date, 1, 16), 'yyyy-mm-dd hh24:mi')
                   order_date,
               labcomponent
                   lab_component_name,
               lab_result
                   result,
               numeric_lab_result
                   result_numeric,
               unit
                   result_uom,
               resultstatus
                   result_status,
               TO_DATE (SUBSTR (result_date, 1, 16), 'yyyy-mm-dd hh24:mi')
                   result_date,
               lab_component_type
          FROM covid19_labs;

    COMMIT;

    INSERT INTO covid19_labs_final_deid
        SELECT mkmrn.masked_mrn,
               mkenc.masked_encounter_epic_csn,
               lab_order_name,
               ROUND (
                     EXTRACT (
                         DAY FROM   CAST (order_date AS TIMESTAMP)
                                  - CAST (encounter_date AS TIMESTAMP))
                   +   EXTRACT (
                           HOUR FROM   CAST (order_date AS TIMESTAMP)
                                     - CAST (encounter_date AS TIMESTAMP))
                     / 24
                   +   EXTRACT (
                           MINUTE FROM   CAST (order_date AS TIMESTAMP)
                                       - CAST (encounter_date AS TIMESTAMP))
                     / 1440,
                   2)    lab_order_days_since_enc,
               ROUND (
                     EXTRACT (
                         DAY FROM   CAST (result_date AS TIMESTAMP)
                                  - CAST (encounter_date AS TIMESTAMP))
                   +   EXTRACT (
                           HOUR FROM   CAST (result_date AS TIMESTAMP)
                                     - CAST (encounter_date AS TIMESTAMP))
                     / 24
                   +   EXTRACT (
                           MINUTE FROM   CAST (result_date AS TIMESTAMP)
                                       - CAST (encounter_date AS TIMESTAMP))
                     / 1440,
                   2)    result_days_since_enc,
               lab_component_name,
               result,
               result_numeric,
               result_uom,
               result_status,
               lab_component_type,
               mkmrn.new_masked_mrn,
               mkenc.new_masked_encounter_epic_csn
          FROM covid19_labs_final  a
               JOIN covid19_masked_mrn_mapping mkmrn ON mkmrn.mrn = a.mrn
               JOIN covid19_masked_enc_mapping mkenc
                   ON mkenc.encounter_epic_csn = a.encounter_epic_csn;

    COMMIT;

    UPDATE covid_etl_log
       SET end_date_time = SYSTIMESTAMP
     WHERE     package_name = 'PKG_COVID19_REPORT'
           AND procedure_name = 'proc_etl_covid19_labs'
           AND operation_name = 'proc_etl_covid19_labs'
           AND end_date_time IS NULL;

    COMMIT;
END proc_etl_covid19_labs;