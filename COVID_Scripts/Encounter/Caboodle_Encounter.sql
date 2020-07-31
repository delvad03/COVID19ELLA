DROP TABLE IF EXISTS  #COVID;
--Patient has an encounter with a particular EDG diagnosis ID 
SELECT distinct PD.PrimaryMrn mrn, ef.EncounterEpicCsn, ef.EncounterKey,'Diagnosis' SOURCE 
INTO #COVID
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
(123,345,678) (123,345,678) --********EncounterEpicCsn is PHI (Replace with required EncounterEpicCsn for MRNs from Department of Health) ********
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
						  
DROP TABLE  if exists #COVID19;
SELECT distinct
ef.PatientDurableKey,
PrimaryMrn MRN,
ef.EncounterEpicCsn EncounterEpicCsn,
ef.encounterKey,
ef.Date ENCOUNTERDATE,
ef.DateKey,
ef.EndDateKey,
CAST(NULL AS NVARCHAR(500)) AS DiagnosisDescription,
pd.BirthDate AS DOB,
dd.YearsDisplayString AGE,
pd.Sex SEX,
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
CAST(NULL AS INTEGER)RESPIRATORY_RATE,
CAST(NULL AS INTEGER)CHRONIC_KIDNEY_DISEASE,
pd.PreferredLanguage as PREFERRED_LANGUAGE,
CAST(NULL AS INTEGER) ATRIAL_FIBRILLATION  ,
CAST(NULL AS INTEGER) HEART_FAILURE,
CAST(NULL AS INTEGER) ARDS,
CAST(NULL AS INTEGER) OBSTRUCTIVE_SLEEP_APNEA,
CAST(NULL AS INTEGER) CORONARY_ARTERY_DISEASE,
CAST(NULL AS INTEGER) CHRONIC_VIRAL_HEPATITIS,
CAST(NULL AS INTEGER) AlCOHOLIC_NONALCOHOLIC_LIVER_DISEASE,
CAST(NULL AS INTEGER) ACUTE_KIDNEY_INJURY,
CAST(NULL AS INTEGER) ACUTE_VENOUS_THROMBOEMBOLISM,
CAST(NULL AS INTEGER) CEREBRAL_INFARCTION,
CAST(NULL AS INTEGER)INTRACEREBRAL_HEMORRHAGE,
CAST(NULL AS INTEGER)  ACUTE_MI,
CAST(NULL AS NVARCHAR(500)) BLOOD_TYPE,
CAST(NULL AS INTEGER) CONVALESCENT_PLASMA,
CAST(NULL AS INTEGER) CROHNS_DISEASE,
CAST(NULL AS INTEGER) ULCERATIVE_COLITIS
INTO  #COVID19
from   ENcounterFact ef  inner join PatientDim pd on (ef.PatientDurableKey = Pd.DurableKey 
                                                       and Pd.ISCURRENT =1 and pd.IsValid = 1
													   and pd.primarymrn !='*Not Applicable' 
													   and pd.primarymrn not like '%TMP%'
													   and ef.EncounterEpicCsn is not null
													   )
		inner join DurationDim dd on (ef.AgeKey = dd.DurationKey)
		inner join #COVID cov on (cov.EncounterKey = ef.EncounterKey);

DROP TABLE IF EXISTS  #COVID_Diagnosis; 
SELECT distinct def.EncounterKey, dtd.Name into #COVID_Diagnosis
FROM DiagnosisEventFact def 
		INNER JOIN DIAGNOSISDIM dtd  on def.DiagnosisKey = dtd.DiagnosisKey  
WHERE dtd.DiagnosisEpicId in 
	  (1494811718,1494811719,1494811720,1494811721,1494811722,1494811735,1494811736,1494811737,1494811738,1494811739,1494811740,1494811743,1494811744,
		1494811745,1494811752,1494811753,1494811754,1494814600,1494816040,1494816041,1494816042,1494816043,1494816044,1494804919,1494804920,1494804921,
		1494804922,1494804937,1494804938,1494804939,1494804940,1494804941,1494805985,1494805988,1494805990,1494805991,1494805996,1494805997,1494810712,
		1494810720,1494810733,1494811348,1494811349,1494811350,1494811351,1494811352,1494811374,1494811375,1494811376,1494811378,1494811379,1494811381,
		1494811382,1494811383,1494811384,1494811388,1494811390,1494811392,1494811393,1494811394,1494811398,1494811399,1494811400,1494811402,1494811404,
		1494811405,1494811407,1494811436,1494811570,1494811571,1494811572,1494811625,1494811626,1494811629,1494811630,1494811631,1494811633,1494811634,
		1494811635,1494811636,1494811637,1494811638,1494811639,1494811640,1494811641,1494811642,1494811643,1494811644,1494811645,1494811646,1494811649,
		1494811650,1494811651,1494811652,1494811653,1494811654,1494811655,1494811656,1494811657,1494811658,1494811659,1494811660,1494811661,1494811663,
		1494811668,1494811669,1494811673,1494811674,1494811675,1494811676,1494811677,1494811678,1494811679,1494811680,1494811682,1494811683,1494811684,
		1494811688,1494811690,1494811692,1494811710);

DROP TABLE IF EXISTS  #COVID_Diagnos; 


SELECT DISTINCT *   INTO #COVID_Diagnos FROM
(
SELECT a.EncounterKey,  SourceList =  STUFF     (
 ( SELECT       ','    +  b.NAME
  FROM #COVID_Diagnosis b
 WHERE     b.EncounterKey = a.EncounterKey
FOR    XML    PATH    ( ''  ) ,  TYPE    ) . value   ( '.',  'NVARCHAR(MAX)' ) ,  1 ,  1 ,  ''  )
 FROM    #COVID_Diagnosis a
 GROUP     BY   a.EncounterKey
 ) A;


Merge into #COVID19 A
 USING #COVID_Diagnos B ON (A.EncounterKey =B.EncounterKey)
 WHEN MATCHED THEN UPDATE SET A.DiagnosisDescription = B.SourceList;

-- FACILITY
DROP TABLE  if exists #LOCATION;

select DISTINCT  
	  a.EncounterEpicCsn, 
	d.DepartmentName,
	 d.ServiceAreaName,
	  d.LocationName department_Location 
	  INTO 
	  #LOCATION
	 from #COVID19 c, ENcounterFact a, DEPARTMENTdim d 
	where  A.EncounterEpicCsn = c.EncounterEpicCsn
	and   a.DepartmentKey = d.DepartmentKey
	and d.DepartmentName is not null
	AND d.DepartmentName !='*Unspecified';

	MERGE INTO #COVID19 CO USING 
	#LOCATION LO ON (CO.EncounterEpicCsn = LO.EncounterEpicCsn)
	WHEN MATCHED THEN UPDATE SET
	CO.Facility = department_Location,
	co.LocationofCare = ServiceAreaName,
	co.Department_name = DepartmentName;
	
--initial temp
DROP TABLE  if exists #initial_temp;
	
SELECT distinct * into  #initial_temp FROM
(
SELECT distinct co.EncounterKey, FlowsheetRowDim.DisplayName,  
	  fsd.NumericValue value,   fsd.TakenInstant Measurement_Time,
	  row_NUMBER () over (partition by CO.EncounterKey order by fsd.TakenInstant) rnm
  FROM FlowsheetValueFact fsd
    INNER JOIN FlowsheetRowDim
      ON fsd.FlowsheetRowKey = FlowsheetRowDim.FlowsheetRowKey
  	  inner join FlowsheetTemplateDim td
	  on fsd.FlowsheetTemplateKey = td.FlowsheetTemplateKey
	  inner join #covid19 co on fsd.EncounterKey = co.EncounterKey
  WHERE FlowsheetRowDim.DisplayName  = 'temp'
  AND fsd.NumericValue  IS NOT NULL
  ) A
  WHERE RNM =1;

--------  ATRIAL_FIBRILLATION  ,HEART_FAILURE   , OBSTRUCTIVE_SLEEP_APNEA
DROP TABLE  if exists #ProblemList ;  
SELECT	DISTINCT D.MRN ,
		CASE WHEN C.VALUE LIKE 'I48%'  THEN 'ATRIAL_FIBRILLATION'
			 WHEN C.VALUE LIKE 'I50%' THEN 'HEART_FAILURE'  
			 WHEN C.VALUE = 'G47.33'  THEN 'OBSTRUCTIVE_SLEEP_APNEA'
		END GROUPNAME  
		INTO #PROBLEMLIST
FROM	PROBLEMLISTFACT A, DIAGNOSISDIM B, DIAGNOSISTERMINOLOGYDIM C, PATIENTDIM P, #COVID19 D
WHERE	A.DIAGNOSISKEY = B.DIAGNOSISKEY
AND		B.DIAGNOSISKEY = C.DIAGNOSISKEY
AND		A.PATIENTDURABLEKEY = P.DURABLEKEY
AND		P.PRIMARYMRN = D.MRN
AND		( C.VALUE LIKE 'I48%' OR
		  C.VALUE LIKE 'I50%' OR		 
		  C.VALUE =   'G47.33'
		)
AND (
     (D.EndDateKey >= A.StartDateKey AND (D.EndDateKey <= A.EndDateKey OR A.EndDateKey <0 )) 
       OR (A.EndDateKey >= D.DateKey AND (A.EndDateKey <= D.EndDateKey  OR D.EndDateKey <0))
       OR(A.EndDateKey <0 AND D.EndDateKey <0)
	   OR (A.StartDateKey >= D.DateKey AND A.EndDateKey < 0)
	   OR (D.DateKey >= A.StartDateKey AND A.EndDateKey <0)
      ) 
AND (A.EndDateKey >= D.EndDateKey OR A.EndDateKey <0)
AND		C.TYPE = 'ICD-10-CM';

merge into  #covid19 a using (select distinct mrn from #ProblemList where  groupName = 'ATRIAL_FIBRILLATION'  ) b
on A.MRN = B.mrn 
when Matched then update SET a.ATRIAL_FIBRILLATION  = 1;
update #covid19 set ATRIAL_FIBRILLATION = 0 where ATRIAL_FIBRILLATION is null;
  
   
merge into  #covid19 a using (select distinct mrn from #ProblemList where  groupName = 'HEART_FAILURE'  ) b
on A.MRN = B.mrn 
when Matched then update SET a.HEART_FAILURE  = 1;
update #covid19 set HEART_FAILURE = 0 where HEART_FAILURE is null;
    
merge into  #covid19 a using (select distinct mrn from #ProblemList where  groupName = 'OBSTRUCTIVE_SLEEP_APNEA'  ) b
on A.MRN = B.mrn 
when Matched then update SET a.OBSTRUCTIVE_SLEEP_APNEA  = 1;
update #covid19 set OBSTRUCTIVE_SLEEP_APNEA = 0 where OBSTRUCTIVE_SLEEP_APNEA is null;
 
 
 ------ ARDS
  DROP TABLE  if exists #LUNGS ;  
select DISTINCT D.MRN ,
  'ARDS'   groupName,
d.encounterkey   
 into #LUNGS
from encounterfact ef,  DiagnosisDiM b, DiagnosisTerminologyDim c,   #COVID19 D
where  ef.PrimaryDiagnosisKey = b.DiagnosisKey
and  b.DiagnosisKey = c.DiagnosisKey
AND d.encounterkey   = ef.EncounterKey   
AND    c.value = 'J80'
 AND C.TYPE = 'ICD-10-CM'
 union   
select DISTINCT D.MRN ,
  'ARDS'   groupName,
d.encounterkey 
from encounterfact ef, DiagnosisEventFact  def   , DiagnosisDiM b, DiagnosisTerminologyDim c,   #COVID19 D
where  
def.EncounterKey = ef.EncounterKey 
and def.DiagnosisKey = b.DiagnosisKey
and  b.DiagnosisKey = c.DiagnosisKey
AND d.encounterkey   = ef.EncounterKey   
AND    c.value = 'J80'
AND C.TYPE = 'ICD-10-CM'
AND def.TYPE = 'Encounter Diagnosis';

merge into  #covid19 a using (select distinct encounterkey  from #LUNGS hl  where  groupName = 'ARDS') b
on A.encounterkey = B.encounterkey 
when Matched then update SET a.ARDS  = 1;
update #covid19 set ARDS = 0 where ARDS is null; 
  
   
-- MAX TEMP
  MERGE INTO #covid19 A
  USING #initial_temp B ON A.EncounterKey = B.EncounterKey
  WHEN MATCHED THEN UPDATE SET A.Temperature = B.value;
  
DROP TABLE  if exists #max_temp;
  
  SELECT distinct co.EncounterKey, 
	  max(fsd.NumericValue) value into  #max_temp
  FROM FlowsheetValueFact fsd
    INNER JOIN FlowsheetRowDim
      ON fsd.FlowsheetRowKey = FlowsheetRowDim.FlowsheetRowKey
  	  inner join FlowsheetTemplateDim td
	  on fsd.FlowsheetTemplateKey = td.FlowsheetTemplateKey
	  inner join #covid19 co on fsd.EncounterKey = co.EncounterKey
  WHERE FlowsheetRowDim.DisplayName  = 'temp'
  AND fsd.NumericValue  IS NOT NULL
  group by co.EncounterKey;


  MERGE INTO #covid19 A
  USING #max_temp B ON A.EncounterKey = B.EncounterKey
  WHEN MATCHED THEN UPDATE SET A.Temp_Max = B.value;
  
--Diabetes
DROP TABLE  if exists #Diabetes
SELECT	DISTINCT 
		P.PRIMARYMRN,
		A.ENCOUNTERKEY, 
		B.NAME 
		INTO #DIABETES
FROM	PROBLEMLISTFACT A, DIAGNOSISDIM B, DiagnosisTerminologyDim DT, PATIENTDIM P, #COVID19 C
WHERE   A.DIAGNOSISKEY = B.DIAGNOSISKEY 
AND		B.DiagnosisKey = DT.DiagnosisKey
AND		A.PATIENTDURABLEKEY = P.DURABLEKEY
AND		C.MRN  = P.PRIMARYMRN 
AND (
     (C.EndDateKey >= A.StartDateKey AND (C.EndDateKey <= A.EndDateKey OR A.EndDateKey <0 )) 
       OR (A.EndDateKey >= C.DateKey AND (A.EndDateKey <= C.EndDateKey  OR C.EndDateKey <0))
       OR(A.EndDateKey <0 AND C.EndDateKey <0)
	   OR (A.StartDateKey >= C.DateKey AND A.EndDateKey < 0)
	   OR (C.DateKey >= A.StartDateKey AND A.EndDateKey <0)
      ) 
AND (A.EndDateKey >= C.EndDateKey OR A.EndDateKey <0)
AND		(DT.VALUE LIKE 'E08%' OR DT.VALUE LIKE 'E09%' OR DT.VALUE LIKE 'E10%' OR DT.VALUE LIKE 'E11%'
             OR DT.VALUE LIKE 'E13%' OR DT.VALUE LIKE 'O24.0%' OR DT.VALUE LIKE 'O24.1%' OR DT.VALUE LIKE 'O24.3%' OR DT.VALUE LIKE 'O24.8%') 
AND		P.ISCURRENT = 1;

merge into  #covid19 a using (select distinct PrimaryMrn from #Diabetes) b
on A.MRN = B.PrimaryMrn 
when Matched then update SET a.DIABETES = '1';

update #covid19 set DIABETES = '0' where DIABETES is null;

--Asthma
DROP TABLE  if exists #Asthma;  
select DISTINCT D.MRN into #Asthma
from ProblemListFact a, DiagnosisDiM b, DiagnosisTerminologyDim c, PATIENTDIM P, #COVID19 D
where  A.DiagnosisKey = b.DiagnosisKey
and  b.DiagnosisKey = c.DiagnosisKey
AND A.PatientDurableKey = P.DurableKey
AND p.primarymrn = D.mrn
AND  c.value like 'J45%'
AND (
     (D.EndDateKey >= A.StartDateKey AND (D.EndDateKey <= A.EndDateKey OR A.EndDateKey <0 )) 
       OR (A.EndDateKey >= D.DateKey AND (A.EndDateKey <= D.EndDateKey  OR D.EndDateKey <0))
       OR(A.EndDateKey <0 AND D.EndDateKey <0)
	   OR (A.StartDateKey >= D.DateKey AND A.EndDateKey < 0)
	   OR (D.DateKey >= A.StartDateKey AND A.EndDateKey <0)
      ) 
AND (A.EndDateKey >= D.EndDateKey OR A.EndDateKey <0)
AND C.TYPE = 'ICD-10-CM';

merge into  #covid19 a using (select distinct mrn from #Asthma) b
on A.MRN = B.mrn 
when Matched then update SET a.Asthma = '1';
update #covid19 set Asthma = '0' where Asthma is null;


--HTN
DROP TABLE  if exists #HTN;
SELECT	DISTINCT 
		P.PRIMARYMRN,
		A.ENCOUNTERKEY, 
		B.NAME
		INTO  #HTN
FROM	PROBLEMLISTFACT A, DIAGNOSISDIM B, DIAGNOSISTERMINOLOGYDIM DT, PATIENTDIM P , #COVID19 C
WHERE	A.DIAGNOSISKEY = B.DIAGNOSISKEY 
AND		B.DIAGNOSISKEY = DT.DIAGNOSISKEY
AND		A.PATIENTDURABLEKEY = P.DURABLEKEY
AND		C.MRN  = P.PRIMARYMRN  
AND		(DT.VALUE = 'I10' OR DT.VALUE LIKE 'I12%' OR DT.VALUE LIKE 'I13%' OR DT.VALUE LIKE 'I15%') 
AND (
     (C.EndDateKey >= A.StartDateKey AND (C.EndDateKey <= A.EndDateKey OR A.EndDateKey <0 )) 
       OR (A.EndDateKey >= C.DateKey AND (A.EndDateKey <= C.EndDateKey  OR C.EndDateKey <0))
       OR(A.EndDateKey <0 AND C.EndDateKey <0)
	   OR (A.StartDateKey >= C.DateKey AND A.EndDateKey < 0)
	   OR (C.DateKey >= A.StartDateKey AND A.EndDateKey <0)
      ) 
AND (A.EndDateKey >= C.EndDateKey OR A.EndDateKey <0)
AND		DT.TYPE = 'ICD-10-CM'
AND		P.ISCURRENT = 1;

merge into  #covid19 a using (select distinct PrimaryMrn from #HTN) b
on A.MRN = B.PrimaryMrn 
when Matched then update SET a.HTN = '1';

update #covid19 set HTN = '0' where HTN is null;


--COPD
DROP TABLE  if exists #COPD;

select DISTINCT D.MRN into #COPD
from ProblemListFact a, DiagnosisDiM b, DiagnosisTerminologyDim c, PATIENTDIM P, #COVID19 D
where  A.DiagnosisKey = b.DiagnosisKey
and  b.DiagnosisKey = c.DiagnosisKey
AND A.PatientDurableKey = P.DurableKey
AND p.primarymrn = D.mrn
AND ( c.value LIKE 'J41%' OR c.value LIKE 'J43%' OR c.value LIKE 'J44%' )
AND (
     (D.EndDateKey >= A.StartDateKey AND (D.EndDateKey <= A.EndDateKey OR A.EndDateKey <0 )) 
       OR (A.EndDateKey >= D.DateKey AND (A.EndDateKey <= D.EndDateKey  OR D.EndDateKey <0))
       OR(A.EndDateKey <0 AND D.EndDateKey <0)
	   OR (A.StartDateKey >= D.DateKey AND A.EndDateKey < 0)
	   OR (D.DateKey >= A.StartDateKey AND A.EndDateKey <0)
      ) 
AND (A.EndDateKey >= D.EndDateKey OR A.EndDateKey <0)
AND C.TYPE = 'ICD-10-CM';
 
merge into  #covid19 a using (select distinct MRN from #COPD) b
on A.MRN = b.mrn 
when Matched then update SET a.COPD = '1';

update #covid19 set COPD = '0' where COPD is null;

--Obesity
DROP TABLE  if exists #Obesity;
select DISTINCT 
p.PrimaryMrn,
A.encounterkey, 
b.name into #Obesity
from ProblemListFact a, DiagnosisDiM b, PatientDim p , #covid19 c, DiagnosisTerminologyDim t
where  A.DiagnosisKey = b.DiagnosisKey 
and A.PatientDurableKey = P.DurableKey
and c.mrn  = p.PrimaryMrn
and b.DiagnosisKey = t.DiagnosisKey
AND (
     (C.EndDateKey >= A.StartDateKey AND (C.EndDateKey <= A.EndDateKey OR A.EndDateKey <0 )) 
       OR (A.EndDateKey >= C.DateKey AND (A.EndDateKey <= C.EndDateKey  OR C.EndDateKey <0))
       OR(A.EndDateKey <0 AND C.EndDateKey <0)
	   OR (A.StartDateKey >= C.DateKey AND A.EndDateKey < 0)
	   OR (C.DateKey >= A.StartDateKey AND A.EndDateKey <0)
      ) 
AND (A.EndDateKey >= C.EndDateKey OR A.EndDateKey <0)
AND t.TYPE = 'ICD-10-CM'
AND ( t.value LIKE 'E66.0%' OR t.value IN ('E66.1', 'E66.2', 'E66.8', 'E66.9') )
AND p.IsCurrent = 1;

merge into  #covid19 a using (select distinct PrimaryMrn from #Obesity) b
on A.MRN = B.PrimaryMrn 
when Matched then update SET a.Obesity = '1';

update #covid19 set Obesity = '0' where Obesity is null;

-- LAB
drop table if exists #LABS;
SELECT DISTINCT   c.EncounterKey,
  COVID_ORDER = ISNULL(ltf.TestName, pd.Name),
  Order_Date = ISNULL(ltf.OrderedInstant, pof.OrderedInstant),
  lcrf.Value COVID_RESULT,
  lcrf.ResultInstant Result_Date  into #LABS
FROM #COVID c
LEFT JOIN 
       ( select ltf.* from LabTestFact ltf 
                      JOIN ProcedureDim prd on ltf.ProcedureKey = prd.ProcedureKey  AND prd.ProcedureEpicId IN(422027,422031)	   
        )ltf
       ON ltf.EncounterKey = c.EncounterKey
LEFT JOIN 
          (select pof.* from  ProcedureOrderFact pof
		      JOIN ProcedureDim prd on pof.ProcedureKey = prd.ProcedureKey  AND prd.ProcedureEpicId IN(422027,422031)
		 ) pof  ON pof.EncounterKey = c.EncounterKey 
LEFT JOIN ProcedureDim pd ON pd.DurableKey = pof.ProcedureDurableKey 
LEFT JOIN 
        (select lcrf.* from LabComponentResultFact  lcrf
		       JOIN LabComponentDim lcd ON lcrf.LabComponentKey = lcd.LabComponentKey and lcd.LabComponentEpicId in (32677,32679)
		)  lcrf  ON lcrf.EncounterKey = c.EncounterKey 
  AND ( lcrf.LabOrderEpicId = ltf.LabOrderEpicId   OR    lcrf.LabOrderEpicId = pof.ProcedureOrderEpicId) 
  AND (  lcrf.ProcedureDurableKey = pof.ProcedureDurableKey  OR  lcrf.ProcedureDurableKey = ltf.ProcedureDurableKey );

-- Blood Pressure	
DROP TABLE  if exists #bp;
		
  SELECT distinct * into  #bp FROM
  (
SELECT distinct  Substring(value,0,charindex('/',value))sbp,
 SUBSTRING(Value, CHARINDEX('/', Value)+1, len(Value)) dpb, 
 row_NUMBER () over (partition by CO.EncounterKey order by fsd.TakenInstant) rnm,
 co.EncounterKey 
  FROM FlowsheetValueFact fsd
    INNER JOIN FlowsheetRowDim
      ON fsd.FlowsheetRowKey = FlowsheetRowDim.FlowsheetRowKey
        inner join FlowsheetTemplateDim td
      on fsd.FlowsheetTemplateKey = td.FlowsheetTemplateKey
      inner join #covid19 co on fsd.EncounterKey = co.EncounterKey
  WHERE 
  flowsheetrowepicid = '5' and value is not null
) a where rnm =1
  ;

MERGE Into #covid19 a using #bp b
			on a.encounterKey =b.encounterKey 
			when matched then update set
			a.SYSTOLIC_BP = b.sbp
           ,a.DIASTOLIC_BP = b.dpb;
		   
--SPO2
DROP TABLE  if exists #SPO2;
SELECT  DISTINCT MRN, ENCOUNTERKEY, DISPLAYNAME, SPO2_BEGINIGN_OF_ENC, SPO2_MIN_FOR_ENC, SPO2_MEASUREMENT_TIME
        INTO #SPO2
    FROM (SELECT DISTINCT
               MRN,
               CO.ENCOUNTERKEY,
               FLOWSHEETROWDIM.DISPLAYNAME,
               FSD.NUMERICVALUE AS SPO2_BEGINIGN_OF_ENC,
               MIN (FSD.NUMERICVALUE)OVER (PARTITION BY MRN, CO.ENCOUNTERKEY ORDER BY MRN, CO.ENCOUNTERKEY) AS SPO2_MIN_FOR_ENC,
               FSD.TAKENINSTANT AS SPO2_MEASUREMENT_TIME,
               ROW_NUMBER () OVER (PARTITION BY CO.ENCOUNTERKEY ORDER BY FSD.TAKENINSTANT) AS RNM
          FROM FLOWSHEETVALUEFACT  FSD INNER JOIN FLOWSHEETROWDIM ON (FSD.FLOWSHEETROWKEY = FLOWSHEETROWDIM.FLOWSHEETROWKEY)
               INNER JOIN FLOWSHEETTEMPLATEDIM TD ON (FSD.FLOWSHEETTEMPLATEKEY = TD.FLOWSHEETTEMPLATEKEY)
               INNER JOIN #COVID19 CO ON (FSD.ENCOUNTERKEY = CO.ENCOUNTERKEY)
         WHERE FLOWSHEETROWDIM.DISPLAYNAME IN ('SPO2')
               AND FSD.NUMERICVALUE IS NOT NULL
        ) A
WHERE RNM = 1;

MERGE INTO #covid19 A
  USING #SPO2 B ON A.EncounterKey = B.EncounterKey
  WHEN MATCHED THEN UPDATE SET A.O2_SAT = B.SPO2_BEGINIGN_OF_ENC, A.O2SAT_MIN = B.SPO2_MIN_FOR_ENC;
  
  -- HIV DIAGNOSIS
DROP TABLE  if exists #HIV;  
select DISTINCT D.MRN into #HIV
from ProblemListFact a, DiagnosisDiM b, DiagnosisTerminologyDim c, PATIENTDIM P, #COVID19 D
where  A.DiagnosisKey = b.DiagnosisKey
and  b.DiagnosisKey = c.DiagnosisKey
AND A.PatientDurableKey = P.DurableKey
AND p.primarymrn = d.mrn
AND  c.value  IN ('B20','B97.35','Z21','O98.7','O98.71','O98.711','O98.712','O98.713','O98.719','O98.72','O98.73')
AND (
     (D.EndDateKey >= A.StartDateKey AND (D.EndDateKey <= A.EndDateKey OR A.EndDateKey <0 )) 
       OR (A.EndDateKey >= D.DateKey AND (A.EndDateKey <= D.EndDateKey  OR D.EndDateKey <0))
       OR(A.EndDateKey <0 AND D.EndDateKey <0)
	   OR (A.StartDateKey >= D.DateKey AND A.EndDateKey < 0)
	   OR (D.DateKey >= A.StartDateKey AND A.EndDateKey <0)
      ) 
AND (A.EndDateKey >= D.EndDateKey OR A.EndDateKey <0)
AND C.TYPE = 'ICD-10-CM';

 MERGE INTO #COVID19 A
USING #HIV B ON A.MRN = B.MRN WHEN MATCHED THEN UPDATE SET  HIV_Flag = '1' ;

UPDATE #COVID19 SET HIV_Flag = '0' WHERE HIV_Flag IS NULL;

-- CANCER DIAGNOSIS 
 DROP TABLE  if exists #COMORBID_CANCER;  
 select DISTINCT D.MRN, C.DisplayString  diagnosis INTO  #COMORBID_CANCER
from ProblemListFact a, DiagnosisDiM b, DiagnosisTerminologyDim c, PATIENTDIM P, #COVID19 D
where  A.DiagnosisKey = b.DiagnosisKey
and  b.DiagnosisKey = c.DiagnosisKey
AND A.PatientDurableKey = P.DurableKey
AND p.primarymrn = d.mrn
AND  c.value  LIKE 'C%'
AND (
     (D.EndDateKey >= A.StartDateKey AND (D.EndDateKey <= A.EndDateKey OR A.EndDateKey <0 )) 
       OR (A.EndDateKey >= D.DateKey AND (A.EndDateKey <= D.EndDateKey  OR D.EndDateKey <0))
       OR(A.EndDateKey <0 AND D.EndDateKey <0)
	   OR (A.StartDateKey >= D.DateKey AND A.EndDateKey < 0)
	   OR (D.DateKey >= A.StartDateKey AND A.EndDateKey <0)
      ) 
AND (A.EndDateKey >= D.EndDateKey OR A.EndDateKey <0)
AND C.TYPE = 'ICD-10-CM';
 
 DROP TABLE  if exists #COMORBID_CANCER2;  
  select distinct t1.MRN,
  STUFF((SELECT distinct   t2.diagnosis + ';'
         from #COMORBID_CANCER t2
         where t1.MRN = t2.MRN
            FOR XML PATH(''), TYPE
            ).value('.', 'NVARCHAR(MAX)') 
        ,1,0,'') diagnosis
		into #COMORBID_CANCER2
from #COMORBID_CANCER t1; 

MERGE INTO #COVID19 A
USING #COMORBID_CANCER2 B ON A.MRN = B.MRN WHEN 
MATCHED THEN UPDATE SET  Cancer_Flag = '1', A.Cancer_Diagnosis_Description = B.diagnosis ;

UPDATE #COVID19 SET Cancer_Flag = '0' WHERE Cancer_Flag IS NULL;

DROP TABLE IF EXISTS #COHORT_INCLUSION_CRITERIA;

SELECT DISTINCT * INTO #COHORT_INCLUSION_CRITERIA 
FROM (
SELECT a.MRN, a.EncounterEpicCSN,  SourceList = STUFF(
( SELECT ';' + b.Source FROM #COVID b WHERE b.MRN = a.MRN AND
( b.EncounterEpicCSN = a.EncounterEpicCSN OR (b.EncounterEpicCSN IS NULL AND a.EncounterEpicCSN IS NULL )
 ) FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'), 1, 1, '') 
FROM #COVID a
GROUP BY a.MRN, a.EncounterEpicCSN ) A;

MERGE INTO #COVID19 A
USING #COHORT_INCLUSION_CRITERIA B 
ON A.EncounterEpicCSN = B.EncounterEpicCSN WHEN MATCHED THEN UPDATE SET
A.COHORT_INCLUSION_CRITERIA = B.SourceList; 

--CHRONIC_KIDNEY_DISEASE 
 DROP TABLE  if exists #CHRONIC_KIDNEY_DISEASE;  
 select DISTINCT D.MRN INTO  #CHRONIC_KIDNEY_DISEASE
from ProblemListFact a, DiagnosisDiM b, DiagnosisTerminologyDim c, PATIENTDIM P, #COVID19 D
where  A.DiagnosisKey = b.DiagnosisKey
and  b.DiagnosisKey = c.DiagnosisKey
AND A.PatientDurableKey = P.DurableKey
AND p.primarymrn = d.mrn
AND  (c.value  LIKE 'N18%' OR c.value like 'I12.%' OR c.value like 'I13.%'
      OR c.value in ('E08.22', 'E09.22', 'E10.22', 'E11.22','E13.22')
      )
AND (
     (D.EndDateKey >= A.StartDateKey AND (D.EndDateKey <= A.EndDateKey OR A.EndDateKey <0 )) 
       OR (A.EndDateKey >= D.DateKey AND (A.EndDateKey <= D.EndDateKey  OR D.EndDateKey <0))
       OR(A.EndDateKey <0 AND D.EndDateKey <0)
	   OR (A.StartDateKey >= D.DateKey AND A.EndDateKey < 0)
	   OR (D.DateKey >= A.StartDateKey AND A.EndDateKey <0)
      ) 
AND (A.EndDateKey >= D.EndDateKey OR A.EndDateKey <0)
AND C.TYPE = 'ICD-10-CM';
 
 
MERGE INTO #COVID19 A
USING #CHRONIC_KIDNEY_DISEASE B ON A.MRN = B.MRN WHEN 
MATCHED THEN UPDATE SET  A.CHRONIC_KIDNEY_DISEASE = '1';

UPDATE #COVID19 SET CHRONIC_KIDNEY_DISEASE = '0' WHERE CHRONIC_KIDNEY_DISEASE IS NULL;


--MEDS
DROP TABLE IF exists #COVID19MED_NAMES;
SELECT	DISTINCT MedicationKey ,
		CASE WHEN MedicationKey IN (5249, 17248, 17676, 15809, 19356, 89810, 95081, 99654, 111957, 115883, 107072, 107147, 107180, 121054, 121056, 121372, 121382, 120682, 120695, 111373, 125765, 125772, 123111, 123112, 124354, 124355, 124360, 124361, 125970, 125971, 123929, 122734, 122735, 122736, 122737, 130387) THEN 'TOCILIZUMAB' 
			 WHEN MedicationKey IN (12474, 6604, 4108, 119166) THEN 'HYDROXYCHLOROQUINE'
			 WHEN MedicationKey IN (121676, 121677, 124398, 124399, 124400, 124401, 121420, 121421, 130383) THEN 'SARILUMAB'
			 WHEN MedicationKey IN (130379, 130398, 130400)  THEN 'REMDESIVIR'
			 WHEN MedicationKey IN (11540, 19407, 130020) THEN 'ANAKINRA'
			 WHEN MedicationKey IN (3042, 7008, 8039, 11064, 14078, 5290, 9486, 13842, 491, 507, 4712, 4767, 13436, 4221, 10479, 3163, 9831, 10046, 32910, 44617, 71552, 81439, 83909, 95389, 101332, 30, 127639, 127645, 127646, 127647, 129910) THEN 'AZITHROMYCIN'
		END AS MEDICATION_NAME
		INTO #COVID19MED_NAMES
FROM	MedicationDim MD 
WHERE	MD.NAME is not null
and		MedicationKey  IN (5249, 17248, 17676, 15809, 19356, 89810, 95081, 99654, 111957, 115883, 107072, 107147, 107180, 121054, 121056, 121372, 121382, 120682, 120695, 111373, 125765, 125772, 123111, 123112, 124354, 124355, 124360, 124361, 125970, 125971, 123929, 122734, 122735, 122736, 122737, 130387,
						   12474, 6604, 4108, 119166,
						   121676, 121677, 124398, 124399, 124400, 124401, 121420, 121421, 130383,
						   130379, 130398, 130400,
						   11540, 19407, 130020,
						   3042, 7008, 8039, 11064, 14078, 5290, 9486, 13842, 491, 507, 4712, 4767, 13436, 4221, 10479, 3163, 9831, 10046, 32910, 44617, 71552, 81439, 83909, 95389, 101332, 30, 127639, 127645, 127646, 127647, 129910
						   ); 


DROP TABLE IF EXISTS #TEMP_COVID19_MED;
SELECT	DISTINCT C.MRN, E.EncounterEpicCsn, C.EncounterKey, C.ENCOUNTERDATE,
		F.StartInstant AS MED_DATE, MEDICATION_NAME, 
		CASE WHEN MD.MEDICATION_NAME IN ('ACTEMRA', 'TOCILIZUMAB') then '1' ELSE NULL END AS TOCILIZUMAB,
		CASE WHEN MD.MEDICATION_NAME IN ('ACTEMRA', 'TOCILIZUMAB') then F.StartInstant ELSE NULL END AS DATE_OF_TOCILIZUMAB, 
		CASE WHEN MD.MEDICATION_NAME IN ('ACTEMRA', 'TOCILIZUMAB') then MIN(F.StartInstant) OVER (PARTITION BY MRN, E.ENCOUNTERKEY, MD.MEDICATION_NAME ORDER BY MRN, E.ENCOUNTERKEY, MD.MEDICATION_NAME) ELSE NULL END AS DATE_OF_FIRST_TOCILIZUMAB, 
		CASE WHEN MD.MEDICATION_NAME = 'HYDROXYCHLOROQUINE' then '1' ELSE NULL END AS HYDROXYCHLOROQUINE,
		CASE WHEN MD.MEDICATION_NAME = 'HYDROXYCHLOROQUINE' then MIN(F.StartInstant) OVER (PARTITION BY MRN, E.ENCOUNTERKEY, MD.MEDICATION_NAME ORDER BY MRN, E.ENCOUNTERKEY, MD.MEDICATION_NAME) ELSE NULL END AS DATE_OF_FIRST_HYDROXYCHLOROQUINE,
		CASE WHEN MD.MEDICATION_NAME = 'SARILUMAB' then '1' ELSE NULL END AS SARILUMAB,
		CASE WHEN MD.MEDICATION_NAME = 'SARILUMAB' then MIN(F.StartInstant) OVER (PARTITION BY MRN, E.ENCOUNTERKEY, MD.MEDICATION_NAME ORDER BY MRN, E.ENCOUNTERKEY, MD.MEDICATION_NAME) ELSE NULL END AS DATE_OF_FIRST_SARILUMAB,
		CASE WHEN MD.MEDICATION_NAME = 'REMDESIVIR' then '1' ELSE NULL END AS REMDESIVIR,
		CASE WHEN MD.MEDICATION_NAME = 'REMDESIVIR' then MIN(F.StartInstant) OVER (PARTITION BY MRN, E.ENCOUNTERKEY, MD.MEDICATION_NAME ORDER BY MRN, E.ENCOUNTERKEY, MD.MEDICATION_NAME) ELSE NULL END AS DATE_OF_FIRST_REMDESIVIR,
		CASE WHEN MD.MEDICATION_NAME = 'ANAKINRA' then '1' ELSE NULL END AS ANAKINRA,
		CASE WHEN MD.MEDICATION_NAME = 'ANAKINRA' then MIN(F.StartInstant) OVER (PARTITION BY MRN, E.ENCOUNTERKEY, MD.MEDICATION_NAME ORDER BY MRN, E.ENCOUNTERKEY, MD.MEDICATION_NAME) ELSE NULL END AS DATE_OF_FIRST_ANAKINRA,
		CASE WHEN MD.MEDICATION_NAME = 'AZITHROMYCIN' then '1' ELSE NULL END AS AZITHROMYCIN, 
		CASE WHEN MD.MEDICATION_NAME = 'AZITHROMYCIN' then MIN(F.StartInstant) OVER (PARTITION BY MRN, E.ENCOUNTERKEY, MD.MEDICATION_NAME ORDER BY MRN, E.ENCOUNTERKEY, MD.MEDICATION_NAME) ELSE NULL END AS DATE_OF_FIRST_AZITHROMYCIN
		INTO #TEMP_COVID19_MED
FROM	#COVID19 C INNER JOIN ENcounterFact E ON (C.EncounterEpicCsn = E.EncounterEpicCsn)
INNER JOIN MedicationEventFact F ON (E.EncounterKey = F.EncounterKey )
INNER JOIN MedicationDim M ON (F.MEDICATIONKEY = M.MEDICATIONKEY)
INNER JOIN #COVID19MED_NAMES Md ON (F.MEDICATIONKEY = Md.MEDICATIONKEY)
WHERE	F.StartInstant NOT IN (-1, -2, -3); 


DROP TABLE IF EXISTS #COVID19_MED;
SELECT	DISTINCT MRN, ENCOUNTEREPICCSN, EncounterKey, ENCOUNTERDATE,
		TOCILIZUMAB, DATE_OF_FIRST_TOCILIZUMAB, 
		REMDESIVIR,  DATE_OF_FIRST_REMDESIVIR,
		SARILUMAB,  DATE_OF_FIRST_SARILUMAB, 
		HYDROXYCHLOROQUINE,  DATE_OF_FIRST_HYDROXYCHLOROQUINE,
		ANAKINRA, DATE_OF_FIRST_ANAKINRA,
		AZITHROMYCIN,   DATE_OF_FIRST_AZITHROMYCIN
		INTO #COVID19_MED
FROM	(
SELECT	DISTINCT MRN, ENCOUNTEREPICCSN, EncounterKey, ENCOUNTERDATE,
		MAX(TOCILIZUMAB) OVER (PARTITION BY MRN, ENCOUNTEREPICCSN ORDER BY MRN, ENCOUNTEREPICCSN) AS TOCILIZUMAB,   
		MAX(DATE_OF_FIRST_TOCILIZUMAB) OVER (PARTITION BY MRN, ENCOUNTEREPICCSN ORDER BY MRN, ENCOUNTEREPICCSN) AS DATE_OF_FIRST_TOCILIZUMAB, 
		MAX(HYDROXYCHLOROQUINE) OVER (PARTITION BY MRN, ENCOUNTEREPICCSN ORDER BY MRN, ENCOUNTEREPICCSN) AS HYDROXYCHLOROQUINE, 
		MAX(DATE_OF_FIRST_HYDROXYCHLOROQUINE) OVER (PARTITION BY MRN, ENCOUNTEREPICCSN ORDER BY MRN, ENCOUNTEREPICCSN) AS DATE_OF_FIRST_HYDROXYCHLOROQUINE,
		MAX(SARILUMAB) OVER (PARTITION BY MRN, ENCOUNTEREPICCSN ORDER BY MRN, ENCOUNTEREPICCSN) AS SARILUMAB, 
		MAX(DATE_OF_FIRST_SARILUMAB) OVER (PARTITION BY MRN, ENCOUNTEREPICCSN ORDER BY MRN, ENCOUNTEREPICCSN) AS DATE_OF_FIRST_SARILUMAB,
		MAX(REMDESIVIR) OVER (PARTITION BY MRN, ENCOUNTEREPICCSN ORDER BY MRN, ENCOUNTEREPICCSN) AS REMDESIVIR, 
		MAX(DATE_OF_FIRST_REMDESIVIR) OVER (PARTITION BY MRN, ENCOUNTEREPICCSN ORDER BY MRN, ENCOUNTEREPICCSN) AS DATE_OF_FIRST_REMDESIVIR,
		MAX(ANAKINRA) OVER (PARTITION BY MRN, ENCOUNTEREPICCSN ORDER BY MRN, ENCOUNTEREPICCSN) AS ANAKINRA, 
		MAX(DATE_OF_FIRST_ANAKINRA) OVER (PARTITION BY MRN, ENCOUNTEREPICCSN ORDER BY MRN, ENCOUNTEREPICCSN) AS DATE_OF_FIRST_ANAKINRA,
		MAX(AZITHROMYCIN) OVER (PARTITION BY MRN, ENCOUNTEREPICCSN ORDER BY MRN, ENCOUNTEREPICCSN) AS AZITHROMYCIN, 
		MAX(DATE_OF_FIRST_AZITHROMYCIN) OVER (PARTITION BY MRN, ENCOUNTEREPICCSN ORDER BY MRN, ENCOUNTEREPICCSN) AS DATE_OF_FIRST_AZITHROMYCIN
FROM	#TEMP_COVID19_MED
) B
ORDER BY 1	
; 

MERGE INTO #COVID19 U
USING  #COVID19_MED S 
	ON (U.ENCOUNTERKEY = S.ENCOUNTERKEY) 
WHEN MATCHED THEN UPDATE 
	SET U.TOCILIZUMAB = S.TOCILIZUMAB,
		U.DATE_OF_FIRST_TOCILIZUMAB = S.DATE_OF_FIRST_TOCILIZUMAB,
		U.REMDESIVIR = S.REMDESIVIR,
		U.DATE_OF_FIRST_REMDESIVIR = S.DATE_OF_FIRST_REMDESIVIR,
		U.SARILUMAB = S.SARILUMAB,
		U.DATE_OF_FIRST_SARILUMAB = S.DATE_OF_FIRST_SARILUMAB,
		U.HYDROXYCHLOROQUINE = S.HYDROXYCHLOROQUINE,
		U.DATE_OF_FIRST_HYDROXYCHLOROQUINE = S.DATE_OF_FIRST_HYDROXYCHLOROQUINE,
		U.ANAKINRA = S.ANAKINRA,
		U.DATE_OF_FIRST_ANAKINRA = S.DATE_OF_FIRST_ANAKINRA,
		U.AZITHROMYCIN = S.AZITHROMYCIN,
		U.DATE_OF_FIRST_AZITHROMYCIN = S.DATE_OF_FIRST_AZITHROMYCIN
; 

--HEART_RATE & RESPIRATORY_RATE

DROP TABLE IF EXISTS #PULSE_RESP;
SELECT DISTINCT EncounterKey, VariableName,VALUE,MeasurementInstant INTO #PULSE_RESP
FROM 
(
SELECT DISTINCT EncounterKey, VariableName,VALUE,MeasurementInstant,
    ROW_NUMBER() OVER(PARTITION BY EncounterKey,VariableName ORDER BY MeasurementInstant) rnm
 FROM 
(
SELECT distinct  FSD.EncounterKey,
       FlowsheetRowDim.DisplayName VariableName,
	  FSD.NumericValue VALUE,	  
	  CAST( measdate.DateValue AS DATETIME ) + CAST( meastime.TimeValue AS DATETIME ) MeasurementInstant
  FROM FlowsheetValueFact fsd INNER JOIN #COVID19 CO ON fsd.EncounterKey = CO.EncounterKey
  INNER JOIN FlowsheetRowDim   ON fsd.FlowsheetRowKey = FlowsheetRowDim.FlowsheetRowKey
        and flowsheetrowepicid in ('8' ,'9') 
  	  inner join FlowsheetTemplateDim td on fsd.FlowsheetTemplateKey = td.FlowsheetTemplateKey
	   INNER JOIN DateDim measdate      ON FSD.DateKey = measdate.DateKey
      INNER JOIN TimeOfDayDim meastime    ON FSD.TimeOfDayKey = meastime.TimeOfDayKey
	  WHERE FSD.NumericValue IS NOT NULL
	  ) A
	       )A
		   WHERE RNM =1;
--Pulse
MERGE INTO #COVID19 CO
USING (SELECT DISTINCT * FROM  #PULSE_RESP S WHERE VariableName = 'Pulse') S
	ON (CO.ENCOUNTERKEY = S.ENCOUNTERKEY) 
WHEN MATCHED THEN UPDATE 
	SET CO.HEART_RATE = S.VALUE;		   

--Resp
MERGE INTO #COVID19 CO
USING (SELECT DISTINCT * FROM  #PULSE_RESP S WHERE VariableName = 'Resp') S
	ON (CO.ENCOUNTERKEY = S.ENCOUNTERKEY) 
WHEN MATCHED THEN UPDATE 
	SET CO.RESPIRATORY_RATE = S.VALUE;	
	
--CORONARY_ARTERY_DISEASE
DROP TABLE  if exists #CORONARY_ARTERY_DISEASE
  
select DISTINCT 
p.PrimaryMrn 
 into #CORONARY_ARTERY_DISEASE
from ProblemListFact a, DiagnosisDiM b, PatientDim p , #covid19 c, DiagnosisTerminologyDim dtd
where   c.mrn  = p.PrimaryMrn 
and A.PatientDurableKey = P.DurableKey
and A.DiagnosisKey = b.DiagnosisKey 
and dtd.DiagnosisKey = b.DiagnosisKey
AND (
     (C.EndDateKey >= A.StartDateKey AND (C.EndDateKey <= A.EndDateKey OR A.EndDateKey <0 )) 
       OR (A.EndDateKey >= C.DateKey AND (A.EndDateKey <= C.EndDateKey  OR C.EndDateKey <0))
       OR(A.EndDateKey <0 AND C.EndDateKey <0)
	   OR (A.StartDateKey >= C.DateKey AND A.EndDateKey < 0)
	   OR (C.DateKey >= A.StartDateKey AND A.EndDateKey <0)
      ) 
AND (A.EndDateKey >= C.EndDateKey OR A.EndDateKey <0)
AND (dtd.value like 'I21%' or dtd.value like 'I22%' or dtd.value like 'I23%' or dtd.value like 'I24%' or dtd.value like 'I25%')
AND dtd.TYPE = 'ICD-10-CM'
AND P.IsCurrent = 1;

merge into  #covid19 a using   #CORONARY_ARTERY_DISEASE b
on A.MRN = B.PrimaryMrn 
when Matched then update SET a.CORONARY_ARTERY_DISEASE = '1';

update #covid19 set CORONARY_ARTERY_DISEASE = '0' where CORONARY_ARTERY_DISEASE is null;

--CHRONIC_VIRAL_HEPATITIS	
DROP TABLE  if exists #CHRONIC_VIRAL_HEPATITIS
  
select DISTINCT 
p.PrimaryMrn 
 into #CHRONIC_VIRAL_HEPATITIS
from ProblemListFact a, DiagnosisDiM b, PatientDim p , #covid19 c, DiagnosisTerminologyDim dtd
where   c.mrn  = p.PrimaryMrn 
and A.PatientDurableKey = P.DurableKey
and A.DiagnosisKey = b.DiagnosisKey 
and dtd.DiagnosisKey = b.DiagnosisKey
AND (
     (C.EndDateKey >= A.StartDateKey AND (C.EndDateKey <= A.EndDateKey OR A.EndDateKey <0 )) 
       OR (A.EndDateKey >= C.DateKey AND (A.EndDateKey <= C.EndDateKey  OR C.EndDateKey <0))
       OR(A.EndDateKey <0 AND C.EndDateKey <0)
	   OR (A.StartDateKey >= C.DateKey AND A.EndDateKey < 0)
	   OR (C.DateKey >= A.StartDateKey AND A.EndDateKey <0)
      ) 
AND (A.EndDateKey >= C.EndDateKey OR A.EndDateKey <0)
AND  dtd.value LIKE 'B18%'
AND dtd.TYPE = 'ICD-10-CM'
AND P.IsCurrent = 1;

merge into  #covid19 a using   #CHRONIC_VIRAL_HEPATITIS b
on A.MRN = B.PrimaryMrn 
when Matched then update SET a.CHRONIC_VIRAL_HEPATITIS = '1';

update #covid19 set CHRONIC_VIRAL_HEPATITIS = '0' where CHRONIC_VIRAL_HEPATITIS is null;

-- AlCOHOLIC_NONALCOHOLIC_LIVER_DISEASE	
DROP TABLE  if exists #AlCOHOLIC_NONALCOHOLIC_LIVER_DISEASE
  
select DISTINCT 
p.PrimaryMrn 
 into #AlCOHOLIC_NONALCOHOLIC_LIVER_DISEASE
from ProblemListFact a, DiagnosisDiM b, PatientDim p , #covid19 c, DiagnosisTerminologyDim dtd
where   c.mrn  = p.PrimaryMrn 
and A.PatientDurableKey = P.DurableKey
and A.DiagnosisKey = b.DiagnosisKey 
and dtd.DiagnosisKey = b.DiagnosisKey
AND (
     (C.EndDateKey >= A.StartDateKey AND (C.EndDateKey <= A.EndDateKey OR A.EndDateKey <0 )) 
       OR (A.EndDateKey >= C.DateKey AND (A.EndDateKey <= C.EndDateKey  OR C.EndDateKey <0))
       OR(A.EndDateKey <0 AND C.EndDateKey <0)
	   OR (A.StartDateKey >= C.DateKey AND A.EndDateKey < 0)
	   OR (C.DateKey >= A.StartDateKey AND A.EndDateKey <0)
      ) 
AND (A.EndDateKey >= C.EndDateKey OR A.EndDateKey <0)
AND ( dtd.value in ('K75.81', 'K76.0') or  dtd.value  like 'K70%' or  dtd.value  like 'K74%') 
AND dtd.TYPE = 'ICD-10-CM'
AND P.IsCurrent = 1;

merge into  #covid19 a using   #AlCOHOLIC_NONALCOHOLIC_LIVER_DISEASE b
on A.MRN = B.PrimaryMrn 
when Matched then update SET a.AlCOHOLIC_NONALCOHOLIC_LIVER_DISEASE = '1';

update #covid19 set AlCOHOLIC_NONALCOHOLIC_LIVER_DISEASE = '0' where AlCOHOLIC_NONALCOHOLIC_LIVER_DISEASE is null;
 
 ------ ACUTE_KIDNEY_INJURY
 DROP TABLE  if exists #ACUTE_KIDNEY_INJURY ;  
select DISTINCT D.MRN ,
  'ARDS'   groupName,
d.encounterkey   
 into #ACUTE_KIDNEY_INJURY
from encounterfact ef,  DiagnosisDiM b, DiagnosisTerminologyDim c,   #COVID19 D
where  ef.PrimaryDiagnosisKey = b.DiagnosisKey
and  b.DiagnosisKey = c.DiagnosisKey
AND d.encounterkey   = ef.EncounterKey   
AND    c.value like 'N17%'
 AND C.TYPE = 'ICD-10-CM'
 UNION   
select DISTINCT D.MRN ,
  'ARDS'   groupName,
d.encounterkey  
from encounterfact ef, DiagnosisEventFact  def   , DiagnosisDiM b, DiagnosisTerminologyDim c,   #COVID19 D
where  
def.EncounterKey = ef.EncounterKey 
and def.DiagnosisKey = b.DiagnosisKey
and  b.DiagnosisKey = c.DiagnosisKey
AND d.encounterkey   = ef.EncounterKey   
AND    c.value like 'N17%'
AND C.TYPE = 'ICD-10-CM'
AND def.TYPE = 'Encounter Diagnosis';

merge into  #covid19 a using (select distinct encounterkey  from #ACUTE_KIDNEY_INJURY hl) b
on A.encounterkey = B.encounterkey 
when Matched then update SET a.ACUTE_KIDNEY_INJURY  = 1;
update #covid19 set ACUTE_KIDNEY_INJURY = 0 where ACUTE_KIDNEY_INJURY is null; 

--ACUTE_VENOUS_THROMBOEMBOLISM	
DROP TABLE  if exists #ACUTE_VENOUS_THROMBOEMBOLISM ;  
select DISTINCT D.MRN ,
  'ARDS'   groupName,
d.encounterkey   
 into #ACUTE_VENOUS_THROMBOEMBOLISM
from encounterfact ef,  DiagnosisDiM b, DiagnosisTerminologyDim c,   #COVID19 D
where  ef.PrimaryDiagnosisKey = b.DiagnosisKey
and  b.DiagnosisKey = c.DiagnosisKey
AND d.encounterkey   = ef.EncounterKey   
AND (c.value LIKE 'I26%' OR c.value LIKE 'I82.4%')
AND C.TYPE = 'ICD-10-CM'
 UNION   
select DISTINCT D.MRN ,
  'ARDS'   groupName,
d.encounterkey  
from encounterfact ef, DiagnosisEventFact  def   , DiagnosisDiM b, DiagnosisTerminologyDim c,   #COVID19 D
where  
def.EncounterKey = ef.EncounterKey 
and def.DiagnosisKey = b.DiagnosisKey
and  b.DiagnosisKey = c.DiagnosisKey
AND d.encounterkey   = ef.EncounterKey   
AND (c.value LIKE 'I26%' OR c.value LIKE 'I82.4%')
AND C.TYPE = 'ICD-10-CM'
AND def.TYPE = 'Encounter Diagnosis';

merge into  #covid19 a using (select distinct encounterkey  from #ACUTE_VENOUS_THROMBOEMBOLISM hl) b
on A.encounterkey = B.encounterkey 
when Matched then update SET a.ACUTE_VENOUS_THROMBOEMBOLISM  = 1;
update #covid19 set ACUTE_VENOUS_THROMBOEMBOLISM = 0 where ACUTE_VENOUS_THROMBOEMBOLISM is null; 

--CEREBRAL_INFARCTION  
drop table if exists #CEREBRAL_INFARCTION;
select distinct  co.MRN 
                ,co.encounterkey
                into #CEREBRAL_INFARCTION 
from #COVID19 co
join encounterfact ef on (co.encounterkey = ef.encounterkey)
join DiagnosisDiM did on (did.DiagnosisKey = ef.PrimaryDiagnosisKey)
join DiagnosisTerminologyDim dtd on (dtd.DiagnosisKey = did.DiagnosisKey
                                     and  dtd.value like 'I63%' 
                                     and dtd.type = 'ICD-10-CM'	
                                    )
									
		union 
select distinct  co.MRN
                ,co.encounterkey    
from #COVID19 co
join  DiagnosisEventFact  def on (def.EncounterKey = co.EncounterKey
                                  and def.type = 'Encounter Diagnosis')
join  DiagnosisDiM did on (did.DiagnosisKey = def.DiagnosisKey)
join  DiagnosisTerminologyDim dtd on (dtd.DiagnosisKey = did.DiagnosisKey
                                     and  dtd.value like 'I63%' 
                                     and dtd.type = 'ICD-10-CM'	
                                    );
 
merge into  #covid19 a using (select distinct encounterkey from #CEREBRAL_INFARCTION) b
on A.encounterkey = B.encounterkey 
when Matched then update SET a.CEREBRAL_INFARCTION = '1';

update #covid19 set CEREBRAL_INFARCTION = '0' where CEREBRAL_INFARCTION is null;

 ------ INTRACEREBRAL_HEMORRHAGE
 DROP TABLE  if exists #INTRACEREBRAL_HEMORRHAGE ;  
select DISTINCT D.MRN , 
d.encounterkey   
 into #INTRACEREBRAL_HEMORRHAGE
from encounterfact ef,  DiagnosisDiM b, DiagnosisTerminologyDim c,   #COVID19 D
where  ef.PrimaryDiagnosisKey = b.DiagnosisKey
and  b.DiagnosisKey = c.DiagnosisKey
AND d.encounterkey   = ef.EncounterKey   
AND    c.value like 'I61%'
 AND C.TYPE = 'ICD-10-CM'
 UNION   
select DISTINCT D.MRN , 
d.encounterkey  
from encounterfact ef, DiagnosisEventFact  def   , DiagnosisDiM b, DiagnosisTerminologyDim c,   #COVID19 D
where  
def.EncounterKey = ef.EncounterKey 
and def.DiagnosisKey = b.DiagnosisKey
and  b.DiagnosisKey = c.DiagnosisKey
AND d.encounterkey   = ef.EncounterKey   
AND    c.value like 'I61%'
AND C.TYPE = 'ICD-10-CM'
AND def.TYPE = 'Encounter Diagnosis';
 
 merge into  #covid19 a using (select distinct encounterkey  from #INTRACEREBRAL_HEMORRHAGE hl) b
on A.encounterkey = B.encounterkey 
when Matched then update SET a.INTRACEREBRAL_HEMORRHAGE  = 1;
update #covid19 set INTRACEREBRAL_HEMORRHAGE = 0 where INTRACEREBRAL_HEMORRHAGE is null; 

--ACUTE_MI
drop table if exists #ACUTE_MI;
select distinct  co.MRN 
                ,co.encounterkey
                into #ACUTE_MI 
from #COVID19 co
join encounterfact ef on (co.encounterkey = ef.encounterkey)
join DiagnosisDiM did on (did.DiagnosisKey = ef.PrimaryDiagnosisKey)
join DiagnosisTerminologyDim dtd on (dtd.DiagnosisKey = did.DiagnosisKey
                                     and  dtd.value like 'I21%' 
                                     and dtd.type = 'ICD-10-CM'	
                                    )
									
		union 
select distinct  co.MRN
                ,co.encounterkey    
from #COVID19 co
join  DiagnosisEventFact  def on (def.EncounterKey = co.EncounterKey
                                  and def.type = 'Encounter Diagnosis')
join  DiagnosisDiM did on (did.DiagnosisKey = def.DiagnosisKey)
join  DiagnosisTerminologyDim dtd on (dtd.DiagnosisKey = did.DiagnosisKey
                                     and  dtd.value like 'I21%' 
                                     and dtd.type = 'ICD-10-CM'	
                                    );
 
merge into  #covid19 a using (select distinct encounterkey from #ACUTE_MI) b
on A.encounterkey = B.encounterkey 
when Matched then update SET a.ACUTE_MI = '1';

update #covid19 set ACUTE_MI = '0' where ACUTE_MI is null;

--Blood Type
DROP TABLE IF EXISTS #BLOOD_TYPE;
WITH ABORH AS
(SELECT ABO.PatientDurableKey
 ,ABO.ResultDateKey
 ,(ABO.Value + ' ' + RH.Value) AS BloodType
 FROM LabComponentResultFact ABO
 INNER JOIN LabComponentResultFact RH ON ABO.LabOrderEpicId = RH.LabOrderEpicId AND ABO.PatientDurableKey = RH.PatientDurableKey
 INNER JOIN LabComponentDim LCD ON ABO.LabComponentKey = LCD.LabComponentKey
 INNER JOIN LabComponentDim LCD2 ON RH.LabComponentKey = LCD2.LabComponentKey
 WHERE LCD.LabComponentEpicId = 8500
 AND LCD2.LabComponentEpicId = 8561
 AND UPPER(ABO.ResultStatus) IN ('FINAL RESULT','EDITED RESULT - FINAL')
 AND UPPER(RH.ResultStatus) IN ('FINAL RESULT','EDITED RESULT - FINAL')
 AND UPPER(ABO.Value) NOT IN ('CANCELED','INVLD','') 
 AND UPPER(RH.Value) NOT IN ('CANCELED','INVLD','') 
 AND ABO.ResultDateKey >= 20180101
UNION 
SELECT PatientDurableKey
 ,ResultDateKey
 ,Value AS BloodType
 FROM LabComponentResultFact LCRF
 INNER JOIN LabComponentDim LCD ON LCRF.LabComponentKey = LCD.LabComponentKey
 WHERE LCD.LabComponentEpicId = 11543
 AND UPPER(ResultStatus) IN ('FINAL RESULT','EDITED RESULT - FINAL')
 AND UPPER(LCRF.Value) NOT IN ('CANCELED','INVLD','')
 AND ResultDateKey >= 20180101
)
,
ABORH2 AS
(
SELECT ROW_NUMBER() OVER(PARTITION BY PatientDurableKey ORDER BY ResultDateKey DESC) AS ROW_NUM
 ,PatientDurableKey
 ,ResultDateKey
 ,BloodType
FROM ABORH
)
SELECT PatientDurableKey
 ,ResultDateKey
 ,BloodType INTO #BLOOD_TYPE
FROM ABORH2 
WHERE ROW_NUM = 1;

MERGE INTO #COVID19 C
 using #BLOOD_TYPE BT on (c.PatientDurableKey = BT.PatientDurableKey)
 WHEN MATCHED THEN UPDATE SET
 C.BLOOD_TYPE = BT.BloodType;
 
 --CONVALESCENT_PLASMA
DROP TABLE IF EXISTS #CONVALESCENT_PLASMA;
SELECT DISTINCT   c.EncounterKey INTO #CONVALESCENT_PLASMA
FROM #COVID c 
  JOIN LabComponentResultFact  lcrf ON (lcrf.EncounterKey = c.EncounterKey)
  JOIN LabComponentDim lcd ON ( lcrf.LabComponentKey = lcd.LabComponentKey
                                and ( ( lcd.LabComponentEpicId = 14826 AND lcrf.Value IN ('CCT19', 'C19CT'))
								      OR lcd.LabComponentEpicId = 32870
                                    )
                                );	
 
MERGE INTO #COVID19 C
 using #CONVALESCENT_PLASMA CP on (c.EncounterKey = CP.EncounterKey)
 WHEN MATCHED THEN UPDATE SET
 C.CONVALESCENT_PLASMA = 1;

 UPDATE #COVID19  SET CONVALESCENT_PLASMA = 0 WHERE CONVALESCENT_PLASMA IS NULL;
 
-- CROHNS_DISEASE
DROP TABLE  if exists #CROHNS_DISEASE;  
select DISTINCT D.MRN into #CROHNS_DISEASE
from ProblemListFact a, DiagnosisDiM b, DiagnosisTerminologyDim c, PATIENTDIM P, #COVID19 D
where  A.DiagnosisKey = b.DiagnosisKey
and  b.DiagnosisKey = c.DiagnosisKey
AND A.PatientDurableKey = P.DurableKey
AND p.primarymrn = D.mrn
AND c.value like 'K50%'
AND (
     (D.EndDateKey >= A.StartDateKey AND (D.EndDateKey <= A.EndDateKey OR A.EndDateKey <0 )) 
       OR (A.EndDateKey >= D.DateKey AND (A.EndDateKey <= D.EndDateKey  OR D.EndDateKey <0))
       OR(A.EndDateKey <0 AND D.EndDateKey <0)
	   OR (A.StartDateKey >= D.DateKey AND A.EndDateKey < 0)
	   OR (D.DateKey >= A.StartDateKey AND A.EndDateKey <0)
      ) 
AND (A.EndDateKey >= D.EndDateKey OR A.EndDateKey <0)
AND C.TYPE = 'ICD-10-CM';

merge into  #covid19 a using (select distinct mrn from #CROHNS_DISEASE) b
on A.MRN = B.mrn 
when Matched then update SET a.CROHNS_DISEASE = '1';
update #covid19 set CROHNS_DISEASE = '0' where CROHNS_DISEASE is null;

-- ULCERATIVE_COLITIS 
DROP TABLE  if exists #ULCERATIVE_COLITIS;  
select DISTINCT D.MRN into #ULCERATIVE_COLITIS
from ProblemListFact a, DiagnosisDiM b, DiagnosisTerminologyDim c, PATIENTDIM P, #COVID19 D
where  A.DiagnosisKey = b.DiagnosisKey
and  b.DiagnosisKey = c.DiagnosisKey
AND A.PatientDurableKey = P.DurableKey
AND p.primarymrn = D.mrn
AND  c.value like 'K51%'
AND (
     (D.EndDateKey >= A.StartDateKey AND (D.EndDateKey <= A.EndDateKey OR A.EndDateKey <0 )) 
       OR (A.EndDateKey >= D.DateKey AND (A.EndDateKey <= D.EndDateKey  OR D.EndDateKey <0))
       OR(A.EndDateKey <0 AND D.EndDateKey <0)
	   OR (A.StartDateKey >= D.DateKey AND A.EndDateKey < 0)
	   OR (D.DateKey >= A.StartDateKey AND A.EndDateKey <0)
      ) 
AND (A.EndDateKey >= D.EndDateKey OR A.EndDateKey <0)
AND C.TYPE = 'ICD-10-CM';

merge into  #covid19 a using (select distinct mrn from #ULCERATIVE_COLITIS) b
on A.MRN = B.mrn 
when Matched then update SET a.ULCERATIVE_COLITIS = '1';
update #covid19 set ULCERATIVE_COLITIS = '0' where ULCERATIVE_COLITIS is null;
 
 
SELECT DISTINCT
MRN
,EncounterEpicCsn
,co.encounterKey
,ENCOUNTERDATE
,DiagnosisDescription
,DOB
,AGE
,SEX
,RACE
,ETHNICITY
,STREET
,ZIPCODE
,FACILITY
,INFECTIONSTATUS
,INFECTIONSTATUS_DATE
,ENCOUNTERTYPE
,co.AdmissionType
,co.PatientClass
,LOCATIONOFCARE
,DISCHARGEDATETIME
,DISCHARGELOCATON
,COVID_ORDER
,Order_Date
,COVID_RESULT
,Result_Date
,SMOKINGSTATUS
,Asthma
,COPD
,HTN
,Obesity
,DIABETES
,HIV_Flag
,Cancer_Flag
,Cancer_Diagnosis_Description
,BMI
,TEMPERATURE
,TEMP_MAX
,SYSTOLIC_BP
,DIASTOLIC_BP
,O2_SAT
,O2SAT_MIN
,DECEASED
,DECEASEDDATE
,Department_Name,
VisitType,
COHORT_INCLUSION_CRITERIA,
TOCILIZUMAB,
DATE_OF_FIRST_TOCILIZUMAB,
REMDESIVIR, 
DATE_OF_FIRST_REMDESIVIR, 
SARILUMAB, 
DATE_OF_FIRST_SARILUMAB,  
HYDROXYCHLOROQUINE, 
DATE_OF_FIRST_HYDROXYCHLOROQUINE, 
ANAKINRA, 
DATE_OF_FIRST_ANAKINRA, 
AZITHROMYCIN, 
DATE_OF_FIRST_AZITHROMYCIN,
HEART_RATE,
RESPIRATORY_RATE,
CHRONIC_KIDNEY_DISEASE,
PREFERRED_LANGUAGE,
ATRIAL_FIBRILLATION  ,
HEART_FAILURE,
ARDS,
OBSTRUCTIVE_SLEEP_APNEA,
CORONARY_ARTERY_DISEASE,
CHRONIC_VIRAL_HEPATITIS,
AlCOHOLIC_NONALCOHOLIC_LIVER_DISEASE,
ACUTE_KIDNEY_INJURY,
ACUTE_VENOUS_THROMBOEMBOLISM,
CEREBRAL_INFARCTION,
INTRACEREBRAL_HEMORRHAGE,
ACUTE_MI,
BLOOD_TYPE,
CONVALESCENT_PLASMA,
ULCERATIVE_COLITIS,
CROHNS_DISEASE
FROM #COVID19 CO LEFT OUTER JOIN  #LABS LAB
ON LAB.EncounterKey = CO.EncounterKey 
where COVID_RESULT NOT IN  ('GENMARK EPLEX','NASOPHARYNGEAL SWAB','ROCHE LIGHTCYCLER 480 II','ROCHE COBAS 6800 SYSTEM')
OR COVID_RESULT is null;
