PROCEDURE proc_etl_covid19_encounter
AS
BEGIN
    INSERT INTO covid_etl_log (package_name, procedure_name, operation_name)
             VALUES ('PKG_COVID19_REPORT',
                     'proc_etl_covid19',
                     'proc_etl_covid19');

    COMMIT;

    EXECUTE IMMEDIATE 'CREATE INDEX covid_stg_mrn_idx ON covid_stg (mrn)';

    MERGE INTO msdw_reporting.covid_stg a
         USING (  SELECT DISTINCT
                         mrn,
                         encounterepiccsn,
                         LISTAGG (diagnosisdescription, ', ')
                             WITHIN GROUP (ORDER BY diagnosisdescription)    diagnosis_description
                    FROM (SELECT DISTINCT
                                 mrn,
                                 encounterepiccsn,
                                 UPPER (diagnosisdescription)    diagnosisdescription
                            FROM msdw_reporting.covid_stg)
                GROUP BY mrn, encounterepiccsn) b
            ON (a.encounterepiccsn = b.encounterepiccsn)
    WHEN MATCHED
    THEN
        UPDATE SET a.diagnosis_description = b.diagnosis_description;

    COMMIT;


    --SMOKINGSTATUS
    EXECUTE IMMEDIATE 'truncate table MSDW_REPORTING.COVID_SMOKINGSTATUS';

    INSERT INTO covid_etl_log (package_name, procedure_name, operation_name)
             VALUES ('PKG_COVID19_REPORT',
                     'proc_etl_covid19',
                     'covid_smokingstatus');

    COMMIT;

    INSERT INTO msdw_reporting.covid_smokingstatus
        SELECT y_mrn       AS mrn,
               pat_enc_csn_id,
               zt.name     smokingstatus,
               s.contact_date
          FROM clarity.social_hx@dwepic_link  s
               JOIN clarity.patient@dwepic_link p ON (s.pat_id = p.pat_id)
               JOIN clarity.zc_tobacco_user@dwepic_link zt
                   ON (zt.tobacco_user_c = s.tobacco_user_c);

    COMMIT;

    --MERGE SMOKING
    MERGE INTO msdw_reporting.covid_stg u
         USING (SELECT *
                  FROM (SELECT DISTINCT
                               mrn,
                               smokingstatus,
                               ROW_NUMBER ()
                                   OVER (PARTITION BY mrn
                                         ORDER BY contact_date DESC)    AS rnk
                          FROM msdw_reporting.covid_smokingstatus)
                 WHERE rnk = 1) s
            ON (u.mrn = s.mrn) 
    WHEN MATCHED
    THEN
        UPDATE SET u.smokingstatus = s.smokingstatus;

    COMMIT;

    UPDATE covid_etl_log
       SET end_date_time = SYSTIMESTAMP
     WHERE     package_name = 'PKG_COVID19_REPORT'
           AND procedure_name = 'proc_etl_covid19'
           AND operation_name = 'covid_smokingstatus'
           AND end_date_time IS NULL;

    COMMIT;

    --infection
    EXECUTE IMMEDIATE 'truncate table MSDW_REPORTING.COVID_INFECTION';

    INSERT INTO covid_etl_log (package_name, procedure_name, operation_name)
         VALUES ('PKG_COVID19_REPORT', 'proc_etl_covid19', 'covid_infection');

    COMMIT;

    INSERT INTO msdw_reporting.covid_infection
        SELECT DISTINCT
               p.pat_mrn_id        mrn,
               zinf.name           AS infection_status,
               CAST (
                   FROM_TZ (CAST (add_utc_dttm AS TIMESTAMP), 'UTC')
                       AT TIME ZONE 'US/Eastern'
                       AS DATE)    AS infectionstatus_date
          FROM clarity.infections@dwepic_link  inf
               INNER JOIN clarity.zc_infection@dwepic_link zinf
                   ON inf.infection_type_c = zinf.infection_c
               INNER JOIN clarity.zc_inf_status@dwepic_link stat
                   ON inf.inf_status_c = stat.inf_status_c
               INNER JOIN clarity.patient@dwepic_link p
                   ON p.pat_id = inf.pat_id
         WHERE zinf.name IN ('COVID-19',
                             'PUI - COVID',
                             'PUM - RESP',
                             'SUSC COVID');

    COMMIT;

    --MERGE INFECTION
    MERGE INTO msdw_reporting.covid_stg u
         USING (SELECT *
                  FROM (SELECT DISTINCT
                               mrn,
                               infection_status,
                               infectionstatus_date,
                               ROW_NUMBER ()
                                   OVER (PARTITION BY mrn
                                         ORDER BY infectionstatus_date DESC)    AS rnk
                          FROM msdw_reporting.covid_infection)
                 WHERE rnk = 1) s
            ON (u.mrn = s.mrn)  
    WHEN MATCHED
    THEN
        UPDATE SET
            u.infectionstatus = s.infection_status,
            u.infectionstatus_date = s.infectionstatus_date;

    COMMIT;

    UPDATE covid_etl_log
       SET end_date_time = SYSTIMESTAMP
     WHERE     package_name = 'PKG_COVID19_REPORT'
           AND procedure_name = 'proc_etl_covid19'
           AND operation_name = 'covid_infection'
           AND end_date_time IS NULL;

    COMMIT;

    INSERT INTO covid_etl_log (package_name, procedure_name, operation_name)
             VALUES ('PKG_COVID19_REPORT',
                     'proc_etl_covid19',
                     'update_demographics');

    COMMIT;

    --merge Demographic
    MERGE INTO msdw_reporting.covid_stg u
         USING (SELECT *
                  FROM (SELECT DISTINCT
                               y_mrn                                            AS mrn,
                               add_line_1,
                               zip,
                               zs.name                                          gender,
                               zb.name                                          ethnic_group,
                               zr.name                                          race,
                               ROW_NUMBER ()
                                   OVER (PARTITION BY mrn ORDER BY mrn DESC)    AS rnk
                          FROM patient@dwepic_link  p
                               JOIN (SELECT DISTINCT mrn
                                       FROM msdw_reporting.covid_stg) c
                                   ON c.mrn = p.y_mrn
                               LEFT JOIN zc_sex@dwepic_link zs
                                   ON zs.rcpt_mem_sex_c = p.sex_c
                               LEFT JOIN ethnic_background@dwepic_link eb
                                   ON eb.pat_id = p.pat_id
                               LEFT JOIN zc_ethnic_bkgrnd@dwepic_link zb
                                   ON zb.ethnic_bkgrnd_c = eb.ethnic_bkgrnd_c
                               LEFT JOIN patient_race@dwepic_link pr
                                   ON pr.pat_id = p.pat_id
                               LEFT JOIN zc_patient_race@dwepic_link zr
                                   ON zr.patient_race_c = pr.patient_race_c)
                 WHERE rnk = 1) s
            ON (u.mrn = s.mrn)
    WHEN MATCHED
    THEN
        UPDATE SET u.street = s.add_line_1,
                   u.zipcode = s.zip,
                   u.sex = s.gender,
                   u.ethnicity = s.ethnic_group;

    COMMIT;

    UPDATE covid_etl_log
       SET end_date_time = SYSTIMESTAMP
     WHERE     package_name = 'PKG_COVID19_REPORT'
           AND procedure_name = 'proc_etl_covid19'
           AND operation_name = 'update_demographics'
           AND end_date_time IS NULL;

    COMMIT;

    EXECUTE IMMEDIATE 'truncate table MSDW_REPORTING.COVID_BMI_NEW';

    INSERT INTO covid_etl_log (package_name, procedure_name, operation_name)
         VALUES ('PKG_COVID19_REPORT', 'proc_etl_covid19', 'covid_bmi_new');

    COMMIT;

    --All BMI for patients of the cohort 
    INSERT INTO msdw_reporting.covid_bmi_new
        SELECT DISTINCT a.y_mrn     mrn,
                        pat_enc_csn_id,
                        a.bmi,
                        effective_date_dttm
          FROM clarity.pat_enc@dwepic_link  a
               JOIN msdw_reporting.covid_stg b
                   ON a.y_mrn = b.mrn AND a.bmi IS NOT NULL;


    MERGE INTO msdw_reporting.covid_stg a
         USING (SELECT DISTINCT bmi, pat_enc_csn_id
                  FROM msdw_reporting.covid_bmi_new) b
            ON (a.encounterepiccsn = b.pat_enc_csn_id)
    WHEN MATCHED
    THEN
        UPDATE SET a.bmi = b.bmi;

    COMMIT;

    --BMI within 6 months of the encounter matched by patient and date if bmi is null
    --BMI within 12 months of the encounter matched by patient and date if bmi is null 
    MERGE INTO msdw_reporting.covid_stg a
         USING (SELECT *
                  FROM (SELECT mrn,
                               bmi,
                               ROW_NUMBER ()
                                   OVER (PARTITION BY a.mrn
                                         ORDER BY effective_date_dttm DESC)    rnm
                          FROM (SELECT DISTINCT
                                       a.mrn     mrn,
                                       a.bmi,
                                       a.effective_date_dttm
                                  FROM msdw_reporting.covid_bmi_new  a
                                       JOIN msdw_reporting.covid_stg b
                                           ON a.mrn = b.mrn
                                 WHERE     b.bmi IS NULL
                                       AND TRUNC (a.effective_date_dttm) >=
                                           ADD_MONTHS (
                                               TO_DATE (
                                                   SUBSTR (b.encounterdate,
                                                           1,
                                                           10),
                                                   'YYYY-MM-DD'),
                                               -12)
                                       AND TRUNC (a.effective_date_dttm) <=
                                           TO_DATE (
                                               SUBSTR (b.encounterdate,
                                                       1,
                                                       10),
                                               'YYYY-MM-DD')) a)
                 WHERE rnm = 1) b
            ON (a.mrn = b.mrn)
    WHEN MATCHED
    THEN
        UPDATE SET a.bmi = b.bmi
                 WHERE a.bmi IS NULL;

    COMMIT;

    UPDATE covid_etl_log
       SET end_date_time = SYSTIMESTAMP
     WHERE     package_name = 'PKG_COVID19_REPORT'
           AND procedure_name = 'proc_etl_covid19'
           AND operation_name = 'covid_bmi_new'
           AND end_date_time IS NULL;

    COMMIT;

    EXECUTE IMMEDIATE 'truncate table MSDW_REPORTING.COVID_ICU';

    INSERT INTO covid_etl_log (package_name, procedure_name, operation_name)
         VALUES ('PKG_COVID19_REPORT', 'proc_etl_covid19', 'covid_icu');

    COMMIT;

    INSERT INTO msdw_reporting.covid_icu
        SELECT b.bed_use_type,
               b.department_name,
               a.mrn,
               b.pat_enc_csn_id
          FROM msdw_reporting.covid_stg  a
               LEFT JOIN
               (SELECT hsp.pat_id,
                       pat_enc_csn_id,
                       hsp.bed_id,
                       bu.name     bed_use_type,
                       dep.department_name
                  FROM pat_enc_hsp@dwepic_link  hsp
                       LEFT JOIN cl_bed_use_type@dwepic_link bt
                           ON bt.bed_id = hsp.bed_id
                       LEFT JOIN zc_bed_use@dwepic_link bu
                           ON bt.bed_use_c = bu.bed_use_c
                       LEFT JOIN clarity_dep@dwepic_link dep
                           ON hsp.department_id = dep.department_id
                 WHERE hsp.bed_id IS NOT NULL) b
                   ON a.encounterepiccsn = b.pat_enc_csn_id
         WHERE b.pat_enc_csn_id IS NOT NULL;

    COMMIT;

    MERGE INTO msdw_reporting.covid_stg u
         USING (SELECT DISTINCT bed_use_type,
                                department_name,
                                mrn,
                                pat_enc_csn_id
                  FROM msdw_reporting.covid_icu) s
            ON (u.mrn = s.mrn AND u.encounterepiccsn = s.pat_enc_csn_id)
    WHEN MATCHED
    THEN
        UPDATE SET u.bed_use_type = s.bed_use_type;

    UPDATE covid_etl_log
       SET end_date_time = SYSTIMESTAMP
     WHERE     package_name = 'PKG_COVID19_REPORT'
           AND procedure_name = 'proc_etl_covid19'
           AND operation_name = 'covid_icu'
           AND end_date_time IS NULL;

    COMMIT;

    EXECUTE IMMEDIATE 'truncate table MSDW_REPORTING.COVID_LDA';

    INSERT INTO covid_etl_log (package_name, procedure_name, operation_name)
         VALUES ('PKG_COVID19_REPORT', 'proc_etl_covid19', 'covid_lda');

    COMMIT;

    INSERT INTO msdw_reporting.covid_lda (pat_enc_csn_id,
                                          initial_airway_type,
                                          initial_airway_date,
                                          description)
          SELECT DISTINCT lda.pat_enc_csn_id,
                          ifg.flo_meas_name         initial_airway_type,
                          lda.placement_instant     initial_airway_date,
                          lda.description
            FROM msdw_reporting.covid_stg co
                 INNER JOIN ip_lda_noaddsingle@dwepic_link lda
                     ON (    co.encounterepiccsn = lda.pat_enc_csn_id
                         AND lda.placement_instant IS NOT NULL)
                 INNER JOIN ip_flo_gp_data@dwepic_link ifg
                     ON (    ifg.flo_meas_id = lda.flo_meas_id
                         AND lda.flo_meas_id IN
                                 ('888400655', '8887070173', '888400638'))
        ORDER BY 1, 3;

    COMMIT;

    MERGE INTO msdw_reporting.covid_stg u
         USING (SELECT pat_enc_csn_id,
                       initial_airway_type,
                       initial_airway_date
                  FROM (SELECT pat_enc_csn_id,
                               initial_airway_type,
                               initial_airway_date,
                               ROW_NUMBER ()
                                   OVER (PARTITION BY pat_enc_csn_id
                                         ORDER BY initial_airway_date)    rnm
                          FROM msdw_reporting.covid_lda)
                 WHERE rnm = 1) s
            ON (u.encounterepiccsn = s.pat_enc_csn_id)
    WHEN MATCHED
    THEN
        UPDATE SET
            u.initial_airway_type = s.initial_airway_type,
            u.initial_airway_date = s.initial_airway_date;

    COMMIT;

    UPDATE covid_etl_log
       SET end_date_time = SYSTIMESTAMP
     WHERE     package_name = 'PKG_COVID19_REPORT'
           AND procedure_name = 'proc_etl_covid19'
           AND operation_name = 'covid_lda'
           AND end_date_time IS NULL;

    COMMIT;

    --Adding EXTERNAL_VISIT_ID from Clarity

    INSERT INTO covid_etl_log (package_name, procedure_name, operation_name)
             VALUES ('PKG_COVID19_REPORT',
                     'proc_etl_covid19',
                     'external_visit_id');

    COMMIT;

    UPDATE msdw_reporting.covid_stg cs
       SET external_visit_id =
               (SELECT enc.external_visit_id
                  FROM clarity.pat_enc@dwepic_link enc
                 WHERE     enc.y_mrn = cs.mrn
                       AND enc.pat_enc_csn_id = cs.encounterepiccsn)
     WHERE EXISTS
               (SELECT 1
                  FROM clarity.pat_enc@dwepic_link enc
                 WHERE     enc.y_mrn = cs.mrn
                       AND enc.pat_enc_csn_id = cs.encounterepiccsn);

    COMMIT;

    UPDATE covid_etl_log
       SET end_date_time = SYSTIMESTAMP
     WHERE     package_name = 'PKG_COVID19_REPORT'
           AND procedure_name = 'proc_etl_covid19'
           AND operation_name = 'external_visit_id'
           AND end_date_time IS NULL;

    COMMIT;

    --*********************************************************
    --Populate covid_facility From Clarity
    --*********************************************************
       INSERT INTO msdw_reporting.covid_facility
            WITH sub AS (
                SELECT
                    pat.y_mrn,
                    adt.pat_id,
                    adt.pat_enc_csn_id,
                    adt.event_id,
                    LAG(adt.event_id, 1, 0) OVER(
                        PARTITION BY adt.pat_enc_csn_id
                        ORDER BY
                            adt.event_id
                    ) AS prev_event_id_,
                    CASE
                        WHEN LAG(dep.department_name, 1, 0) OVER(
                            PARTITION BY adt.pat_enc_csn_id
                            ORDER BY
                                adt.event_id
                        ) = dep.department_name THEN
                            1
                        ELSE
                            0
                    END AS new_dep_,
                    coalesce(next_out_event_id, xfer_in_event_id) AS next_event_id,
                    adt.department_id,
                    dep.department_name,
                    cd4.service_grouper_c,
                    adt.accommodation_c,
                    adt.bed_id,
                    ce.bed_use_c,
                    adt.event_type_c,
                    coalesce(
                        CASE
                            WHEN adt.event_type_c IN(
                                2, 4
                            ) THEN
                                adt.effective_time
                        END, trunc(sysdate)) AS out_time,
                    CASE
                        WHEN adt.event_type_c IN (
                            1,
                            3
                        ) THEN
                            effective_time
                    END AS in_time,
                    CASE
                        WHEN ( adt.accommodation_c IN (
                            '10002',
                            '10003'
                        ) --10002 = Coronary Care , 10003 = Critical Care
                               OR cd4.service_grouper_c IN (
                            102,
                            137
                        ) --102= Critical Care, 137 = Peds Critical Care
                               OR ce.bed_use_c IN (
                            22,
                            23
                        ) ) --22 = Critical Care Surge and 23 = Critical Care
                         THEN
                            '1'
                        ELSE
                            '0'
                    END AS is_icu,
                    CASE
                        WHEN dep.department_name LIKE '%EMERGENCY%' THEN
                            '1'
                        ELSE
                            '0'
                    END AS is_ed,
                    CASE
                        WHEN ( adt.accommodation_c IN (
                            '10002',
                            '10003'
                        )
                               OR cd4.service_grouper_c IN (
                            102,
                            137
                        )
                               OR ce.bed_use_c IN (
                            22,
                            23
                        )
                               OR dep.department_name LIKE '%EMERGENCY%' ) THEN
                            '0'
                        ELSE
                            '1'
                    END AS is_ip_non_icu
                FROM
                    msdw_reporting.covid_stg      co
                    JOIN clarity_adt@dwepic_link       adt ON ( co.encounterepiccsn = adt.pat_enc_csn_id )
                    LEFT JOIN cl_bed_use_type@dwepic_link   ce ON adt.bed_id = ce.bed_id
                    INNER JOIN zc_event_type@dwepic_link     z ON adt.event_type_c = z.event_type_c
                    INNER JOIN clarity_dep@dwepic_link       dep ON adt.department_id = dep.department_id
                    LEFT JOIN clarity_dep_4@dwepic_link     cd4 ON cd4.department_id = dep.department_id
                    INNER JOIN patient@dwepic_link           pat ON pat.pat_id = adt.pat_id
-- Admission, Transfer In and out and discharge
                WHERE
                    z.event_type_c IN (
                        1,
                        2,
                        3,
                        4
                    )
                    AND adt.event_type_c IN (
                        1,
                        2,
                        3,
                        4
                    )
                    AND adt.delete_time IS NULL
                    AND adt.event_subtype_c <> 2  
            ), adt AS (
                SELECT
                    sub.y_mrn      mrn,
                    sub.pat_id,
                    sub.pat_enc_csn_id,
                    CONNECT_BY_ROOT sub.department_id AS department_id,
                    CONNECT_BY_ROOT sub.department_name AS department_name,
                    CONNECT_BY_ROOT sub.service_grouper_c AS service_grouper_c,
                    CONNECT_BY_ROOT sub.accommodation_c AS accommodation_c,
                    CONNECT_BY_ROOT sub.bed_use_c AS bed_use_c,
                    CONNECT_BY_ROOT sub.event_id AS adteventid,
                    CONNECT_BY_ROOT sub.is_icu AS is_icu,
                    CONNECT_BY_ROOT sub.is_ed AS is_ed,
                    CONNECT_BY_ROOT sub.is_ip_non_icu AS is_ip_non_icu,
                    CONNECT_BY_ROOT sub.in_time AS in_dttm,
                    sub.out_time   AS out_dttm
                FROM
                    sub
                WHERE
                    1 = CONNECT_BY_ISLEAF
                    AND ( 2 <= level
                          OR sub.next_event_id IS NULL )
                START WITH
                    0 = sub.new_dep_
                CONNECT BY NOCYCLE PRIOR sub.event_id = sub.prev_event_id_
                                   AND sub.department_name = PRIOR sub.department_name
            )
            SELECT
                hsp.pat_id,
                hsp.pat_enc_csn_id,
                hsp.hosp_admsn_time,
                hsp.adt_pat_class_c,
                pc.name        AS adt_pat_class,
                hsp.department_id,
                cd.department_name,
                hsp.accommodation_c,
                ac.name        AS accommodation,
                loc.loc_id,
                loc.loc_name   AS location_name,
                rom.room_name,
                bed.bed_label,
                use.name       AS bed_type,
                sg.name        AS service_grouper,
                MAX(adt.is_icu) AS had_icu,
                MAX(adt.is_ed) AS had_ed,
                MAX(adt.is_ip_non_icu) AS had_ip_non_icu
            FROM
                pat_enc_hsp@dwepic_link          hsp
                INNER JOIN adt ON hsp.pat_enc_csn_id = adt.pat_enc_csn_id
                INNER JOIN zc_pat_class@dwepic_link         pc ON pc.adt_pat_class_c = hsp.adt_pat_class_c
                INNER JOIN patient@dwepic_link              pt ON pt.pat_id = hsp.pat_id
                INNER JOIN zc_accommodation@dwepic_link     ac ON ac.accommodation_c = hsp.accommodation_c
                INNER JOIN clarity_dep@dwepic_link          cd ON cd.department_id = hsp.department_id
                INNER JOIN clarity_loc@dwepic_link          loc ON loc.loc_id = cd.rev_loc_id
                LEFT JOIN clarity_rom@dwepic_link          rom ON rom.room_id = hsp.room_id
                LEFT JOIN clarity_bed@dwepic_link          bed ON bed.bed_id = hsp.bed_id
                LEFT JOIN cl_bed_use_type@dwepic_link      ce ON ce.bed_id = bed.bed_id
                LEFT JOIN zc_bed_use@dwepic_link           use ON use.bed_use_c = ce.bed_use_c
                LEFT JOIN clarity_dep_4@dwepic_link        cd4 ON cd4.department_id = cd.department_id
                LEFT JOIN zc_service_grouper@dwepic_link   sg ON sg.service_grouper_c = cd4.service_grouper_c
            GROUP BY
                hsp.pat_id,
                hsp.pat_enc_csn_id,
                hsp.hosp_admsn_time,
                hsp.adt_pat_class_c,
                pc.name,
                hsp.department_id,
                cd.department_name,
                hsp.accommodation_c,
                ac.name,
                loc.loc_id,
                loc.loc_name,
                rom.room_name,
                bed.bed_label,
                use.name,
                sg.name;

        COMMIT;

    --Adding DEPARTMENT Info from Clarity

    MERGE INTO msdw_reporting.covid_stg u
         USING (SELECT cf.pat_enc_csn_id,
                       cf.had_ed,
                       cf.had_ip_non_icu,
                       cf.had_icu
                  FROM msdw_reporting.covid_facility cf) s
            ON (u.encounterepiccsn = s.pat_enc_csn_id)
    WHEN MATCHED
    THEN
        UPDATE SET
            u.emergency_department = s.had_ed,
            u.inpatient_non_icu = s.had_ip_non_icu,
            u.icu = had_icu;

    COMMIT;


INSERT INTO msdw_reporting.covid_race_ethnicity
                WITH cte AS (
                    SELECT
                        p.y_mrn   AS msmrn,
                        l.name    AS eth1_desc,
                        l.abbr    AS eth1_code,
                        upper(e.group_desc) AS eth1_group_msx,
                        rl.name   AS race1_desc,
                        pr.line,
                        rl.abbr   AS race1_code,
                        upper(sr.group_desc) race1_group_msx
                    FROM
                        msdw_reporting.covid_stg        co
                        INNER JOIN patient@dwepic_link             p ON co.mrn = p.y_mrn
                        INNER JOIN ethnic_background@dwepic_link   eb ON eb.pat_id = p.pat_id
                        INNER JOIN zc_ethnic_bkgrnd@dwepic_link    l ON eb.ethnic_bkgrnd_c = l.ethnic_bkgrnd_c
                                                                     AND eb.line = 1
                        LEFT OUTER JOIN s0_sparc_ethnicity@idm_db       e ON l.abbr = e.code
                        LEFT OUTER JOIN patient_race@dwepic_link        pr ON p.pat_id = pr.pat_id
                                                                       AND pr.line = 1
                        LEFT OUTER JOIN zc_patient_race@dwepic_link     rl ON pr.patient_race_c = rl.patient_race_c
                        LEFT OUTER JOIN s0_sparc_race@idm_db            sr ON rl.abbr = sr.code
                )
                SELECT
                    msmrn,
                    CASE
                        WHEN eth1_group_msx = 'HISPANIC' THEN
                            eth1_group_msx
                        ELSE
                            race1_group_msx
                    END AS race_ethnicity_combined
                FROM
                    cte;
					
					

    MERGE INTO msdw_reporting.covid_stg u
         USING (SELECT DISTINCT msmrn, race_ethnicity_combined
                  FROM covid_race_ethnicity) s
            ON (u.mrn = s.msmrn)
    WHEN MATCHED
    THEN
        UPDATE SET u.race_ethnicity_combined = s.race_ethnicity_combined;

    COMMIT;

    --        *************************
    --        Insurance Procedure Call
    --        *************************
    proc_etl_covid19_insurance ();

    EXECUTE IMMEDIATE 'truncate table MSDW_REPORTING.COVID';

    INSERT INTO msdw_reporting.covid
        SELECT DISTINCT
               mrn,
               encounterepiccsn
                   encounter_epic_csn,
               encounterkey,
               TO_DATE (SUBSTR (a.encounterdate, 1, 19),
                        'YYYY-MM-DD HH24:MI:SS')
                   encounter_date,
               UPPER (diagnosis_description)
                   diagnosis_description,
               TO_DATE (SUBSTR (a.dob, 1, 19), 'YYYY-MM-DD HH24:MI:SS')
                   dob,
               CAST (REGEXP_SUBSTR (age, '(\S*)(\s)') AS NUMBER)
                   age,
               UPPER (sex)
                   sex,
               UPPER (race)
                   race,
               UPPER (ethnicity)
                   ethnicity,
               UPPER (REPLACE (street, '|', ' '))
                   street,
               zipcode,
               UPPER (facility)
                   facility,
               UPPER (infectionstatus)
                   infection_status,
               a.infectionstatus_date
                   infection_status_date,
               UPPER (encountertype)
                   encounter_type,
               UPPER (admissiontype)
                   admission_type,
               UPPER (patientclass)
                   patient_class,
               UPPER (locationofcare)
                   location_of_care,
               TO_DATE (SUBSTR (a.dischargedatetime, 1, 19),
                        'YYYY-MM-DD HH24:MI:SS')
                   discharge_date,
               UPPER (dischargelocaton)
                   discharge_locaton,
               UPPER (covid_order)
                   covid_order,
               TO_DATE (SUBSTR (a.order_date, 1, 19),
                        'YYYY-MM-DD HH24:MI:SS')
                   date_covid_order,
               UPPER (covid_result)
                   covid_result,
               TO_DATE (SUBSTR (a.result_date, 1, 19),
                        'YYYY-MM-DD HH24:MI:SS')
                   date_covid_result,
               UPPER (smokingstatus)
                   smoking_status,
               CAST (asthma AS NUMBER)
                   asthma,
               CAST (copd AS NUMBER)
                   copd,
               CAST (htn AS NUMBER)
                   htn,
               CAST (obstructive_sleep_apnea AS NUMBER)
                   obstructive_sleep_apnea,
               CAST (obesity AS NUMBER)
                   obesity,
               CAST (diabetes AS NUMBER)
                   diabetes,
               CAST (hiv_flag AS NUMBER)
                   hiv_flag,
               CAST (cancer_flag AS NUMBER)
                   cancer_flag,
               CAST (atrial_fibrillation AS NUMBER)
                   atrial_fibrillation,
               CAST (heart_failure AS NUMBER)
                   heart_failure,
               CAST (ards AS NUMBER)
                   ards,
               CAST (bmi AS NUMBER)
                   bmi,
               CAST (temperature AS NUMBER)
                   temperature,
               CAST (temp_max AS NUMBER)
                   temp_max,
               CAST (systolic_bp AS NUMBER)
                   systolic_bp,
               CAST (diastolic_bp AS NUMBER)
                   diastolic_bp,
               CAST (o2_sat AS NUMBER)
                   o2_sat,
               CAST (o2sat_min AS NUMBER)
                   o2sat_min,
               CAST (deceased AS NUMBER)
                   deceased_indicator,
               CASE
                   WHEN a.deceaseddate = '0000-01-01'
                   THEN
                       NULL
                   ELSE
                       TRUNC (
                           TO_DATE (SUBSTR (a.deceaseddate, 1, 10),
                                    'YYYY-MM-DD'))
               END
                   AS deceased_date,
               UPPER (cancer_diagnosis_description)
                   cancer_diagnosis_description,
               UPPER (bed_use_type)
                   bed_use_type,
               UPPER (department_name)
                   department_name,
               cohort_inclusion_criteria,
               visittype,
               NVL (tocilizumab, '0')
                   AS tocilizumab,
               TO_DATE (date_of_first_tocilizumab, 'Mon dd yyyy HH:MIAM')
                   AS date_of_first_tocilizumab,
               NVL (remdesivir, '0')
                   AS remdesivir,
               TO_DATE (date_of_first_remdesivir, 'Mon dd yyyy HH:MIAM')
                   AS date_of_first_remdesivir,
               NVL (sarilumab, '0')
                   AS sarilumab,
               TO_DATE (date_of_first_sarilumab, 'Mon dd yyyy HH:MIAM')
                   AS date_of_first_sarilumab,
               NVL (hydroxychloroquine, '0')
                   AS hydroxychloroquine,
               TO_DATE (date_of_first_hydroxychloroquine,
                        'Mon dd yyyy HH:MIAM')
                   AS date_of_first_hydroxychloroquine,
               NVL (anakinra, '0')
                   AS anakinra,
               TO_DATE (date_of_first_anakinra, 'Mon dd yyyy HH:MIAM')
                   AS date_of_first_anakinra,
               NVL (azithromycin, '0')
                   AS azithromycin,
               TO_DATE (date_of_first_azithromycin, 'Mon dd yyyy HH:MIAM')
                   AS date_of_first_azithromycin,
               heart_rate,
               respiratory_rate,
               chronic_kidney_disease,
               preferred_language,
               initial_airway_type,
               TO_DATE (initial_airway_date, 'DD-MON-YY HH:MI:SS AM')
                   AS initial_airway_date,
               coronary_artery_disease,
               chronic_viral_hepatitis,
               alcoholic_nonalcoholic_liver_disease,
               acute_kidney_injury,
               acute_venous_thromboembolism,
               cerebral_infarction,
               DENSE_RANK ()
                   OVER (
                       PARTITION BY a.mrn
                       ORDER BY
                           (TO_DATE (SUBSTR (a.encounterdate, 1, 19),
                                     'YYYY-MM-DD HH24:MI:SS')))
                   enc_seq_number,
               external_visit_id,
               intracerebral_hemorrhage,
               emergency_department,
               inpatient_non_icu,
               icu,
               race_ethnicity_combined,
               acute_mi,
               blood_type,
               convalescent_plasma,
               ulcerative_colitis,
               crohns_disease,
               insurance
          FROM msdw_reporting.covid_stg a;

    COMMIT;


    EXECUTE IMMEDIATE 'truncate table MSDW_REPORTING.COVID_DEID';

    INSERT INTO msdw_reporting.covid_deid
        SELECT DISTINCT
               b.masked_mrn,
               c.masked_encounter_epic_csn,
               0
                   AS encounter_date,
               UPPER (diagnosis_description)
                   diagnosis_description,
               0
                   AS dob,
               CASE WHEN age > 89 THEN 90 ELSE age END
                   age,
               UPPER (sex)
                   sex,
               UPPER (race)
                   race,
               UPPER (ethnicity)
                   ethnicity,
               CASE WHEN a.street IS NOT NULL THEN 'xxx' ELSE NULL END
                   AS street,
               CASE
                   WHEN SUBSTR (a.zipcode, 1, 3) IN
                            (SELECT zipcode FROM msdw_protected_zipcode)
                   THEN
                       '000'
                   ELSE
                       SUBSTR (a.zipcode, 1, 3)
               END
                   AS zipcode,
               UPPER (facility)
                   facility,
               UPPER (infection_status)
                   infection_status,
               a.infection_status_date - a.encounter_date
                   infection_start_days_since_encounter,
               UPPER (encounter_type)
                   encounter_type,
               UPPER (admission_type)
                   admission_type,
               UPPER (patient_class)
                   patient_class,
               UPPER (location_of_care)
                   location_of_care,
               a.discharge_date - a.encounter_date
                   discharge_days_since_encounter,
               UPPER (discharge_locaton)
                   discharge_locaton,
               UPPER (covid_order)
                   covid_order,
               a.date_covid_order - a.encounter_date
                   covid_order_days_since_encounter,
               UPPER (covid_result)
                   covid_result,
               a.date_covid_result - a.encounter_date
                   covid_result_days_since_encounter,
               UPPER (smoking_status)
                   smoking_status,
               CAST (asthma AS NUMBER)
                   asthma,
               CAST (copd AS NUMBER)
                   copd,
               CAST (htn AS NUMBER)
                   htn,
               CAST (obstructive_sleep_apnea AS NUMBER)
                   obstructive_sleep_apnea,
               CAST (obesity AS NUMBER)
                   obesity,
               CAST (diabetes AS NUMBER)
                   diabetes,
               CAST (hiv_flag AS NUMBER)
                   hiv_flag,
               CAST (cancer_flag AS NUMBER)
                   cancer_flag,
               CAST (atrial_fibrillation AS NUMBER)
                   atrial_fibrillation,
               CAST (heart_failure AS NUMBER)
                   heart_failure,
               CAST (ards AS NUMBER)
                   ards,
               CAST (bmi AS NUMBER)
                   bmi,
               CAST (temperature AS NUMBER)
                   temperature,
               CAST (temp_max AS NUMBER)
                   temp_max,
               CAST (systolic_bp AS NUMBER)
                   systolic_bp,
               CAST (diastolic_bp AS NUMBER)
                   diastolic_bp,
               CAST (o2_sat AS NUMBER)
                   o2_sat,
               CAST (o2sat_min AS NUMBER)
                   o2sat_min,
               CAST (deceased_indicator AS NUMBER)
                   deceased_indicator,
               a.deceased_date - a.encounter_date
                   deceased_days_since_encounter,
               UPPER (cancer_diagnosis_description)
                   cancer_diagnosis_description,
               UPPER (bed_use_type)
                   bed_use_type,
               UPPER (department_name)
                   department_name,
               UPPER (cohort_inclusion_criteria)
                   cohort_inclusion_criteria,
               UPPER (visittype)
                   visittype,
               NVL (tocilizumab, '0')
                   AS tocilizumab,
               date_of_first_tocilizumab - encounter_date
                   AS date_of_first_tocilizumab,
               NVL (remdesivir, '0')
                   AS remdesivir,
               date_of_first_remdesivir - encounter_date
                   AS date_of_first_remdesivir,
               NVL (sarilumab, '0')
                   AS sarilumab,
               date_of_first_sarilumab - encounter_date
                   AS date_of_first_sarilumab,
               NVL (hydroxychloroquine, '0')
                   AS hydroxychloroquine,
               date_of_first_hydroxychloroquine - encounter_date
                   AS date_of_first_hydroxychloroquine,
               NVL (anakinra, '0')
                   AS anakinra,
               date_of_first_anakinra - encounter_date
                   AS date_of_first_anakinra,
               NVL (azithromycin, '0')
                   AS azithromycin,
               date_of_first_azithromycin - encounter_date
                   AS date_of_first_azithromycin,
               heart_rate,
               respiratory_rate,
               chronic_kidney_disease,
               preferred_language,
               initial_airway_type,
               TRUNC (initial_airway_date) - encounter_date
                   AS initial_airway_date,
               b.new_masked_mrn,
               c.new_masked_encounter_epic_csn,
               coronary_artery_disease,
               chronic_viral_hepatitis,
               alcoholic_nonalcoholic_liver_disease,
               acute_kidney_injury,
               acute_venous_thromboembolism,
               cerebral_infarction,
               DENSE_RANK ()
                   OVER (PARTITION BY a.mrn ORDER BY a.encounter_date)
                   enc_seq_number,
               (SELECT ext.masked_external_visit_id
                  FROM covid19_masked_ext_visit_map ext
                 WHERE ext.external_visit_id = a.external_visit_id)
                   masked_external_visit_id,
               intracerebral_hemorrhage,
               emergency_department,
               inpatient_non_icu,
               icu,
               race_ethnicity_combined,
               acute_mi,
               blood_type,
               convalescent_plasma,
               ulcerative_colitis,
               crohns_disease,
               insurance
          FROM msdw_reporting.covid                       a,
               msdw_reporting.covid19_masked_mrn_mapping  b,
               msdw_reporting.covid19_masked_enc_mapping  c
         WHERE a.mrn = b.mrn AND a.encounter_epic_csn = c.encounter_epic_csn;

    COMMIT;

    UPDATE covid_etl_log
       SET end_date_time = SYSTIMESTAMP
     WHERE     package_name = 'PKG_COVID19_REPORT'
           AND procedure_name = 'proc_etl_covid19'
           AND operation_name = 'proc_etl_covid19'
           AND end_date_time IS NULL;

    COMMIT;
END proc_etl_covid19_encounter;