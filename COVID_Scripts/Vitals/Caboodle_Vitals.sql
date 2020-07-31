DROP TABLE IF EXISTS  #COVID_tmp;
--Patient has an encounter with a particular EDG diagnosis ID 
SELECT distinct PD.PrimaryMrn mrn, ef.EncounterEpicCsn, ef.EncounterKey,'Diagnosis' SOURCE  INTO #COVID_tmp
FROM DiagnosisEventFact def 
		JOIN DIAGNOSISDIM dd  on (def.DiagnosisKey = dd.DiagnosisKey)
		JOIN ENcounterFact ef on (def.EncounterKey = ef.EncounterKey)
		JOIN PatientDim pd on (pd.DurableKey = ef.PatientDurableKey and pd.IsCurrent = 1)
		JOIN DiagnosisTerminologyDim dtd on (dtd.DiagnosisKey = dd.DiagnosisKey)
		WHERE dd.DiagnosisEpicId in 
	   (1494811718,1494811719,1494811720,1494811721,1494811722,1494811735,1494811736,1494811737,1494811738,1494811739,1494811740,1494811743,1494811744,
		1494811745,1494811752,1494811753,1494811754,1494814600,1494816040,1494816041,1494816042,1494816043,1494816044,1494804919,1494804920,1494804921,
		1494804922,1494804937,1494804938,1494804939,1494804940,1494804941,1494805985,1494805988,1494805990,1494805991,1494805996,1494805997,1494810712,
		1494810720,1494810733,1494811348,1494811349,1494811350,1494811351,1494811352,1494811374,1494811375,1494811376,1494811378,1494811379,1494811381,
		1494811382,1494811383,1494811384,1494811388,1494811390,1494811392,1494811393,1494811394,1494811398,1494811399,1494811400,1494811402,1494811404,
		1494811405,1494811407,1494811436,1494811570,1494811571,1494811572,1494811625,1494811626,1494811629,1494811630,1494811631,1494811633,1494811634,
		1494811635,1494811636,1494811637,1494811638,1494811639,1494811640,1494811641,1494811642,1494811643,1494811644,1494811645,1494811646,1494811649,
		1494811650,1494811651,1494811652,1494811653,1494811654,1494811655,1494811656,1494811657,1494811658,1494811659,1494811660,1494811661,1494811663,
		1494811668,1494811669,1494811673,1494811674,1494811675,1494811676,1494811677,1494811678,1494811679,1494811680,1494811682,1494811683,1494811684,
		1494811688,1494811690,1494811692,1494811710,1494821577)
		OR dtd.Value = 'U07.1'
UNION
--Patient has an encounter with a particular Visit Type
SELECT distinct PD.PrimaryMrn mrn,ef.EncounterEpicCsn, ef.EncounterKey , 'Visit Type' 
FROM ENcounterFact ef INNER JOIN PatientDim pd on pd.DurableKey = ef.PatientDurableKey and pd.IsCurrent=1
WHERE ef.VisitType  like '%COVID%'
UNION
--Patient has a Lab Order for a SARS-CoV-2 lab test
SELECT DISTINCT PD.PrimaryMrn mrn, ef.EncounterEpicCsn, ef.EncounterKey, 'Lab Order'
FROM ProcedureOrderFact pof	INNER JOIN encounterfact ef	ON pof.EncounterKey = ef.EncounterKey
INNER JOIN PatientDim pd on pd.DurableKey = ef.PatientDurableKey and pd.IsCurrent=1
WHERE ProcedureKey IN (302762,302621)
UNION
--Patient has a Lab Order for a SARS-CoV-2 lab test
SELECT DISTINCT PD.PrimaryMrn mrn, ef.EncounterEpicCsn, ef.EncounterKey, 'Lab Order'
FROM LabTestFact ltf	INNER JOIN encounterfact ef	ON ltf.EncounterKey = ef.EncounterKey and ltf.ProcedureDurableKey IN (302762,302621)
INNER JOIN PatientDim pd on pd.DurableKey = ef.PatientDurableKey and pd.IsCurrent=1
UNION
--Patient has a Lab Test Result for a SARS-CoV-2 lab test
SELECT DISTINCT PD.PrimaryMrn mrn, ef.EncounterEpicCsn, ef.EncounterKey , 'Lab Result'
FROM encounterfact ef INNER JOIN LabComponentResultFact lcrf on ef.EncounterKey = lcrf.EncounterKey and lcrf.LabComponentKey in (29430,29432)
 INNER JOIN PatientDim pd on pd.DurableKey = ef.PatientDurableKey and pd.IsCurrent=1
 UNION
 -- DOH Test
SELECT distinct PD.PrimaryMrn mrn, ef.EncounterEpicCsn, ef.EncounterKey,'DOH Tests' SOURCE 
FROM   ENcounterFact ef INNER JOIN PatientDim pd on pd.DurableKey = ef.PatientDurableKey and pd.IsCurrent=1
and EncounterEpicCsn   in 
(123,345,678) --********EncounterEpicCsn is PHI (Replace with required EncounterEpicCsn for MRNs from Department of Health) ********
UNION
 --Positive COVID Antibody test
SELECT DISTINCT PD.PrimaryMrn, ef.EncounterEpicCsn, ef.EncounterKey , 'COVID Antibody Positive'
		             from LabComponentResultFact  lcrf
		                  join LabComponentDim lcd on (lcrf.LabComponentKey = lcd.LabComponentKey 
			                                and lcd.LabComponentEpicId in (32930, 32933, 33098, 32931)
											and lcrf.Value ='Positive'
											)
						  join EncounterFact ef on (ef.EncounterKey = lcrf.EncounterKey)
						  join PatientDim pd on (pd.DurableKey = ef.PatientDurableKey and pd.IsCurrent =1); 
						  
DROP TABLE  if exists #COVID_tmp19;
SELECT distinct
Pd.PrimaryMrn MRN,
ef.EncounterEpicCsn EncounterEpicCsn,
ef.encounterKey,
ef.Date ENCOUNTERDATE,
CAST(NULL AS NVARCHAR(500)) AS DiagnosisDescription,
pd.BirthDate AS DOB,
dd.YearsDisplayString AGE,
pd.GenderIdentity SEX,
pd.FirstRace RACE,
pd.Ethnicity ETHNICITY,
CAST(NULL AS NVARCHAR(500)) AS STREET,
CAST(NULL AS NVARCHAR(500)) AS ZIPCODE,
CAST(NULL AS NVARCHAR(500)) AS FACILITY,
CAST(NULL AS NVARCHAR(500)) AS INFECTIONSTATUS,
CAST(NULL AS NVARCHAR(500)) AS INFECTIONSTATUS_DATE,
ef.Type ENCOUNTERTYPE,
ef.AdmissionType,
ef.PatientClass,
CAST(NULL AS NVARCHAR(500)) AS LOCATIONOFCARE,
CAST(NULL AS NVARCHAR(500)) AS CareAreaName,
 ef.DischargeInstant DISCHARGEDATETIME,
ef.DischargeDisposition  DISCHARGELOCATON, 
CAST(NULL AS NVARCHAR(500)) AS SMOKINGSTATUS, 
CAST(NULL AS NVARCHAR(500)) AS Asthma ,
CAST(NULL AS NVARCHAR(500)) AS COPD ,
CAST(NULL AS NVARCHAR(500)) AS HTN ,
CAST(NULL AS NVARCHAR(500)) AS Obesity ,
CAST(NULL AS NVARCHAR(500)) AS DIABETES ,
CAST(NULL AS NVARCHAR(500)) AS HIV_Flag,
CAST(NULL AS NVARCHAR(500)) Cancer_Flag,
CAST(NULL AS NVARCHAR(3200)) Cancer_Diagnosis_Description,
CAST(NULL AS NVARCHAR(500)) BMI,
CAST(NULL AS NVARCHAR(500)) AS TEMPERATURE,
CAST(NULL AS NVARCHAR(500)) AS TEMP_MAX,
CAST(NULL AS NVARCHAR(500)) AS SYSTOLIC_BP,
CAST(NULL AS NVARCHAR(500)) AS DIASTOLIC_BP,
CAST(NULL AS NVARCHAR(500)) AS O2_SAT,
CAST(NULL AS NVARCHAR(500)) AS O2SAT_MIN,
CASE When pd.DeathDate is not null then '1' else '0' end as DECEASED,
pd.DeathDate DECEASEDDATE,
CAST(NULL AS NVARCHAR(3200)) AS Department_name,
ef.visittype,
CAST(NULL AS NVARCHAR(500)) COHORT_INCLUSION_CRITERIA,
CAST(NULL AS NVARCHAR(1)) AS TOCILIZUMAB,
CAST(NULL AS NVARCHAR(500)) AS DATE_OF_FIRST_TOCILIZUMAB,
CAST(NULL AS NVARCHAR(1)) AS REMDESIVIR, 
CAST(NULL AS NVARCHAR(500)) AS DATE_OF_FIRST_REMDESIVIR, 
CAST(NULL AS NVARCHAR(1)) AS SARILUMAB, 
CAST(NULL AS NVARCHAR(500)) AS DATE_OF_FIRST_SARILUMAB,  
CAST(NULL AS NVARCHAR(1)) AS HYDROXYCHLOROQUINE, 
CAST(NULL AS NVARCHAR(500)) AS DATE_OF_FIRST_HYDROXYCHLOROQUINE, 
CAST(NULL AS NVARCHAR(1)) AS ANAKINRA, 
CAST(NULL AS NVARCHAR(500)) AS DATE_OF_FIRST_ANAKINRA, 
CAST(NULL AS NVARCHAR(1)) AS AZITHROMYCIN, 
CAST(NULL AS NVARCHAR(500)) AS DATE_OF_FIRST_AZITHROMYCIN,
CAST(NULL AS INTEGER) HEART_RATE,
CAST(NULL AS INTEGER) HEART_RATE_MIN,
CAST(NULL AS INTEGER)RESPIRATORY_RATE
INTO  #COVID_tmp19
from   ENcounterFact ef  inner join PatientDim pd on ef.PatientDurableKey = Pd.DurableKey 
		inner join DurationDim dd on ef.AgeKey = dd.DurationKey
		INNER JOIN #COVID COV ON COV.EncounterKey = EF.EncounterKey
		and Pd.ISCURRENT =1 and pd.IsValid = 1
and ef.EncounterEpicCsn is not null
and pd.primarymrn !='*Not Applicable'
and pd.primarymrn NOT LIKE '%TMP%';


DROP TABLE IF EXISTS #COVID_VITALS_ALL;

SELECT DISTINCT  
	co.EncounterKey,
	frd.DisplayName,
	frd.flowsheetrowepicid, 
	CONCAT(measdate.DateValue ,' ', meastime.TimeValue) MeasureInstant,
	measdate.DateValue MeasureDate,
	fsd.value MeasureValue
into #COVID_VITALS_ALL
FROM FlowsheetValueFact fsd
	INNER JOIN FlowsheetRowDim frd
		ON fsd.FlowsheetRowKey = frd.FlowsheetRowKey
    INNER JOIN FlowsheetTemplateDim td
		on fsd.FlowsheetTemplateKey = td.FlowsheetTemplateKey
	INNER JOIN #COVID_tmp19 co 
		on fsd.EncounterKey = co.EncounterKey
	INNER JOIN DateDim measdate
		ON fsd.DateKey = measdate.DateKey
	INNER JOIN TimeOfDayDim meastime
		ON fsd.TimeOfDayKey = meastime.TimeOfDayKey
  WHERE frd.FlowsheetRowEpicId in('5','6','8','9','10') 
		and fsd.value is not null 
		and value <> ''
;

DROP TABLE IF EXISTS #COVID_VITALS_AGG; 
SELECT 
	MRN,
	EncounterEpicCsn,
	ENCOUNTERDATE,
	MeasureItem,
	MeasureValue,
	MeasureDate,
	MeasureInstant
INTO #COVID_VITALS_AGG
FROM
(
	SELECT
		co.MRN,
		co.EncounterEpicCsn,
		co.ENCOUNTERDATE,
		'SYSTOL_BP' MeasureItem,
		SUBSTRING(MeasureValue,0,CHARINDEX('/',MeasureValue)) MeasureValue, 
		MeasureDate,
		MeasureInstant,
		row_NUMBER () over (partition by va.EncounterKey, MeasureDate 
							order by CAST(SUBSTRING(MeasureValue,0,CHARINDEX('/',MeasureValue)) as numeric(16,7)) desc, MeasureInstant desc
							) rnk
	FROM #COVID_VITALS_ALL va 
			INNER JOIN #COVID_tmp19 co
				on va.EncounterKey = co.EncounterKey
	WHERE FlowsheetRowEpicId = 5
	UNION ALL
	SELECT
		co.MRN,
		co.EncounterEpicCsn,
		co.ENCOUNTERDATE,
		'DIASTOL_BP' MeasureItem,
		SUBSTRING(MeasureValue, CHARINDEX('/', MeasureValue)+1, len(MeasureValue)) MeasureValue, 
		MeasureDate,
		MeasureInstant,
		row_NUMBER () over (partition by va.EncounterKey, MeasureDate 
							order by CAST(SUBSTRING(MeasureValue, CHARINDEX('/', MeasureValue)+1, len(MeasureValue)) as numeric(16,7)) desc, MeasureInstant desc) rnk
	FROM #COVID_VITALS_ALL va 
			INNER JOIN #COVID_tmp19 co
				on va.EncounterKey = co.EncounterKey
	WHERE FlowsheetRowEpicId = 5
	UNION ALL
	SELECT
		co.MRN,
		co.EncounterEpicCsn,
		co.ENCOUNTERDATE,
		'TEMP' MeasureItem,
		CAST(MeasureValue as numeric(16,7)) MeasureValue, 
		MeasureDate,
		MeasureInstant,
		row_NUMBER () over (partition by va.EncounterKey, MeasureDate 
							order by CAST(MeasureValue as numeric(16,7))  desc, MeasureInstant desc	) rnk
	FROM #COVID_VITALS_ALL va 
			INNER JOIN #COVID_tmp19 co
				on va.EncounterKey = co.EncounterKey
	WHERE FlowsheetRowEpicId = 6
	UNION ALL
	SELECT
		co.MRN,
		co.EncounterEpicCsn,
		co.ENCOUNTERDATE,
		'HEART_RATE' MeasureItem,
		MeasureValue, 
		MeasureDate,
		MeasureInstant,
		row_NUMBER () over (partition by va.EncounterKey, MeasureDate 
							order by CAST(MeasureValue as numeric(16,7)) desc, MeasureInstant desc) rnk
	FROM #COVID_VITALS_ALL va 
			INNER JOIN #COVID_tmp19 co
				on va.EncounterKey = co.EncounterKey
	WHERE FlowsheetRowEpicId = 8
	UNION ALL
	SELECT
		co.MRN,
		co.EncounterEpicCsn,
		co.ENCOUNTERDATE,
		'HEART_RATE_MIN' MeasureItem,
		MeasureValue, 
		MeasureDate,
		MeasureInstant,
		row_NUMBER () over (partition by va.EncounterKey, MeasureDate 
							order by CAST(MeasureValue as numeric(16,7)) asc, MeasureInstant asc) rnk
	FROM #COVID_VITALS_ALL va 
			INNER JOIN #COVID_tmp19 co
				on va.EncounterKey = co.EncounterKey
	WHERE FlowsheetRowEpicId = 8
	UNION ALL
	SELECT
		co.MRN,
		co.EncounterEpicCsn,
		co.ENCOUNTERDATE,
		'RESP_RATE' MeasureItem,
		MeasureValue, 
		MeasureDate,
		MeasureInstant,
		row_NUMBER () over (partition by va.EncounterKey, MeasureDate 
							order by CAST(MeasureValue as numeric(16,7)) desc, MeasureInstant desc) rnk
	FROM #COVID_VITALS_ALL va 
			INNER JOIN #COVID_tmp19 co
				on va.EncounterKey = co.EncounterKey
	WHERE FlowsheetRowEpicId = 9
	UNION ALL
	SELECT
		co.MRN,
		co.EncounterEpicCsn,
		co.ENCOUNTERDATE,
		'O2SAT' MeasureItem,
		MeasureValue, 
		MeasureDate,
		MeasureInstant,
		row_NUMBER () over (partition by va.EncounterKey, MeasureDate 
							order by CAST(MeasureValue as numeric(16,7)) asc, MeasureInstant asc) rnk
	FROM #COVID_VITALS_ALL va 
			INNER JOIN #COVID_tmp19 co
				on va.EncounterKey = co.EncounterKey
	WHERE FlowsheetRowEpicId = 10
    UNION ALL
	SELECT
		co.MRN,
		co.EncounterEpicCsn,
		co.ENCOUNTERDATE,
		'SYSTOL_BP_MIN' MeasureItem,
		SUBSTRING(MeasureValue,0,CHARINDEX('/',MeasureValue)) MeasureValue, 
		MeasureDate,
		MeasureInstant,
		row_NUMBER () over (partition by va.EncounterKey, MeasureDate 
							order by  CAST(SUBSTRING(MeasureValue,0,CHARINDEX('/',MeasureValue)) as numeric(16,7)) asc,  MeasureInstant asc) rnk
	FROM #COVID_VITALS_ALL va 
			INNER JOIN #COVID_tmp19 co
				on va.EncounterKey = co.EncounterKey
	WHERE FlowsheetRowEpicId = 5
	UNION ALL
	SELECT
		co.MRN,
		co.EncounterEpicCsn,
		co.ENCOUNTERDATE,
		'DIASTOL_BP_MIN' MeasureItem,
		SUBSTRING(MeasureValue, CHARINDEX('/', MeasureValue)+1, len(MeasureValue)) MeasureValue, 
		MeasureDate,
		MeasureInstant,
		row_NUMBER () over (partition by va.EncounterKey, MeasureDate 
							order by CAST(SUBSTRING(MeasureValue, CHARINDEX('/', MeasureValue)+1, len(MeasureValue)) as numeric(16,7)) asc,  MeasureInstant asc) rnk
	FROM #COVID_VITALS_ALL va 
			INNER JOIN #COVID_tmp19 co
				on va.EncounterKey = co.EncounterKey
	WHERE FlowsheetRowEpicId = 5
) a
WHERE rnk = 1
ORDER BY EncounterEpicCsn, MeasureInstant;

--Results
DROP TABLE IF EXISTS #COVID_VITALS;
CREATE TABLE #COVID_VITALS (
	MRN varchar(50),
	ENCOUNTER_EPIC_CSN numeric(18,0),
	ENCOUNTER_DATE datetime,
	VITAL_SIGNS_DATE datetime,
	TEMP_MAX_DATETIME datetime,
	TEMP_MAX decimal(6,2),
	HEART_RATE_MAX_DATETIME datetime,
	HEART_RATE_MAX integer,
	HEART_RATE_MIN_DATETIME datetime,
	HEART_RATE_MIN integer,
	RESP_RATE_MAX_DATETIME datetime,
	RESP_RATE_MAX integer,
	SYSTOL_BP_MAX_DATETIME datetime,
	SYSTOL_BP_MAX integer,
	DIASTOL_BP_MAX_DATETIME datetime,
	DIASTOL_BP_MAX integer,
	O2SAT_MIN_DATETIME datetime,
	O2SAT_MIN integer,
	SYSTOL_BP_MIN_DATETIME	datetime, 
	SYSTOLIC_BP_MIN integer,
	DIASTOL_BP_MIN_DATETIME datetime,
	DIASTOLIC_BP_MIN integer
);

INSERT INTO #COVID_VITALS
(MRN, ENCOUNTER_EPIC_CSN, Encounter_Date, VITAL_SIGNS_DATE )
SELECT DISTINCT MRN, EncounterEpicCsn, ENCOUNTERDATE, MeasureDate 
FROM #COVID_VITALS_AGG
ORDER BY MRN,ENCOUNTERDATE,MeasureDate 
;

Merge into #COVID_VITALS A
USING #COVID_VITALS_AGG B ON (B.EncounterEpicCsn =A.ENCOUNTER_EPIC_CSN
							  and B.MeasureDate =A.VITAL_SIGNS_DATE
							  and B.MeasureItem = 'TEMP')
WHEN MATCHED THEN UPDATE SET A.TEMP_MAX = B.MeasureValue, A.TEMP_MAX_DATETIME = MeasureInstant
;

Merge into #COVID_VITALS A
USING #COVID_VITALS_AGG B ON (B.EncounterEpicCsn =A.ENCOUNTER_EPIC_CSN
							   and B.MeasureDate =A.VITAL_SIGNS_DATE
							   and B.MeasureItem = 'SYSTOL_BP')
WHEN MATCHED THEN UPDATE SET A.SYSTOL_BP_MAX = B.MeasureValue, A.SYSTOl_BP_MAX_DATETIME = MeasureInstant
;

Merge into #COVID_VITALS A
USING #COVID_VITALS_AGG B ON (B.EncounterEpicCsn =A.ENCOUNTER_EPIC_CSN
							   and B.MeasureDate =A.VITAL_SIGNS_DATE
							   and B.MeasureItem = 'DIASTOL_BP')
WHEN MATCHED THEN UPDATE SET A.DIASTOL_BP_MAX = B.MeasureValue, A.DIASTOL_BP_MAX_DATETIME = MeasureInstant
;

Merge into #COVID_VITALS A
USING #COVID_VITALS_AGG B ON (B.EncounterEpicCsn =A.ENCOUNTER_EPIC_CSN
							   and B.MeasureDate =A.VITAL_SIGNS_DATE
							   and B.MeasureItem = 'DIASTOL_BP')
WHEN MATCHED THEN UPDATE SET A.DIASTOL_BP_MAX = B.MeasureValue, A.DIASTOL_BP_MAX_DATETIME = MeasureInstant
;

Merge into #COVID_VITALS A
USING #COVID_VITALS_AGG B ON (B.EncounterEpicCsn =A.ENCOUNTER_EPIC_CSN
							   and B.MeasureDate =A.VITAL_SIGNS_DATE
							   and B.MeasureItem = 'HEART_RATE')
WHEN MATCHED THEN UPDATE SET A.HEART_RATE_MAX = B.MeasureValue, A.HEART_RATE_MAX_DATETIME = MeasureInstant
;

Merge into #COVID_VITALS A
USING #COVID_VITALS_AGG B ON (B.EncounterEpicCsn =A.ENCOUNTER_EPIC_CSN
							   and B.MeasureDate =A.VITAL_SIGNS_DATE
							   and B.MeasureItem = 'HEART_RATE_MIN')
WHEN MATCHED THEN UPDATE SET A.HEART_RATE_MIN = B.MeasureValue, A.HEART_RATE_MIN_DATETIME = MeasureInstant
;

Merge into #COVID_VITALS A
USING #COVID_VITALS_AGG B ON (B.EncounterEpicCsn =A.ENCOUNTER_EPIC_CSN
							   and B.MeasureDate =A.VITAL_SIGNS_DATE
							   and B.MeasureItem = 'RESP_RATE')
WHEN MATCHED THEN UPDATE SET A.RESP_RATE_MAX = B.MeasureValue, A.RESP_RATE_MAX_DATETIME = MeasureInstant
;

Merge into #COVID_VITALS A
USING #COVID_VITALS_AGG B ON (B.EncounterEpicCsn =A.ENCOUNTER_EPIC_CSN
							   and B.MeasureDate =A.VITAL_SIGNS_DATE
							   and B.MeasureItem = 'O2SAT')
WHEN MATCHED THEN UPDATE SET A.O2SAT_MIN = B.MeasureValue, A.O2SAT_MIN_DATETIME = MeasureInstant
;

Merge into #COVID_VITALS A
USING #COVID_VITALS_AGG B ON (B.EncounterEpicCsn =A.ENCOUNTER_EPIC_CSN
							   and B.MeasureDate =A.VITAL_SIGNS_DATE
							   and B.MeasureItem = 'SYSTOL_BP_MIN')
WHEN MATCHED THEN UPDATE SET A.SYSTOLIC_BP_MIN = B.MeasureValue, A.SYSTOL_BP_MIN_DATETIME = MeasureInstant
;

Merge into #COVID_VITALS A
USING #COVID_VITALS_AGG B ON (B.EncounterEpicCsn =A.ENCOUNTER_EPIC_CSN
							   and B.MeasureDate =A.VITAL_SIGNS_DATE
							   and B.MeasureItem = 'DIASTOL_BP_MIN')
WHEN MATCHED THEN UPDATE SET A.DIASTOLIC_BP_MIN = B.MeasureValue, A.DIASTOL_BP_MIN_DATETIME = MeasureInstant
;

SELECT
	MRN,
	ENCOUNTER_EPIC_CSN,
	FORMAT(ENCOUNTER_DATE, 'MM/dd/yyyy hh:mm:ss tt') ENCOUNTER_DATE,
	FORMAT(VITAL_SIGNS_DATE, 'MM/dd/yyyy hh:mm:ss tt') VITAL_SIGNS_DATE ,
	FORMAT(TEMP_MAX_DATETIME, 'MM/dd/yyyy hh:mm:ss tt') TEMP_MAX_DATETIME ,
	TEMP_MAX,
	FORMAT(HEART_RATE_MAX_DATETIME, 'MM/dd/yyyy hh:mm:ss tt') HEART_RATE_MAX_DATETIME ,
	HEART_RATE_MAX,
	FORMAT(HEART_RATE_MIN_DATETIME, 'MM/dd/yyyy hh:mm:ss tt') HEART_RATE_MIN_DATETIME ,
	HEART_RATE_MIN,
	FORMAT(RESP_RATE_MAX_DATETIME, 'MM/dd/yyyy hh:mm:ss tt') RESP_RATE_MAX_DATETIME ,
	RESP_RATE_MAX,
	FORMAT(SYSTOL_BP_MAX_DATETIME, 'MM/dd/yyyy hh:mm:ss tt') SYSTOL_BP_MAX_DATETIME ,
	SYSTOL_BP_MAX,
	FORMAT(DIASTOL_BP_MAX_DATETIME, 'MM/dd/yyyy hh:mm:ss tt') DIASTOL_BP_MAX_DATETIME ,
	DIASTOL_BP_MAX,
	FORMAT(O2SAT_MIN_DATETIME, 'MM/dd/yyyy hh:mm:ss tt') O2SAT_MIN_DATETIME ,
	O2SAT_MIN,
	FORMAT(SYSTOL_BP_MIN_DATETIME, 'MM/dd/yyyy hh:mm:ss tt') SYSTOL_BP_MIN_DATETIME,	
	SYSTOLIC_BP_MIN, 
	FORMAT(DIASTOL_BP_MIN_DATETIME, 'MM/dd/yyyy hh:mm:ss tt') DIASTOL_BP_MIN_DATETIME,
	DIASTOLIC_BP_MIN  
FROM #COVID_VITALS
order BY MRN, ENCOUNTER_DATE, VITAL_SIGNS_DATE;
