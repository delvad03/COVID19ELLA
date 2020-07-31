DROP TABLE IF EXISTS  #MSD61COVID19_COHORT;
--Patient has an encounter with a particular EDG diagnosis ID 
SELECT distinct PD.DurableKey PatientDurableKey, PD.PrimaryMrn mrn, ef.EncounterEpicCsn, ef.EncounterKey,ef.DateKey, 'Diagnosis' SOURCE  INTO #MSD61COVID19_COHORT
FROM DiagnosisEventFact def 
		JOIN DIAGNOSISDIM dd  on (def.DiagnosisKey = dd.DiagnosisKey)
		JOIN ENcounterFact ef on (def.EncounterKey = ef.EncounterKey)
		JOIN PatientDim pd on (pd.DurableKey = ef.PatientDurableKey and pd.IsCurrent = 1 and pd.IsValid = 1)
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
SELECT distinct  PD.DurableKey PatientDurableKey,PD.PrimaryMrn mrn,ef.EncounterEpicCsn, ef.EncounterKey, ef.DateKey, 'Visit Type' 
FROM ENcounterFact ef INNER JOIN PatientDim pd on pd.DurableKey = ef.PatientDurableKey and pd.IsCurrent=1 and pd.IsValid = 1
WHERE ef.VisitType  like '%COVID%'
UNION
--Patient has a Lab Order for a SARS-CoV-2 lab test
SELECT DISTINCT PD.DurableKey PatientDurableKey, PD.PrimaryMrn mrn, ef.EncounterEpicCsn, ef.EncounterKey, ef.DateKey, 'Lab Order'
FROM ProcedureOrderFact pof	INNER JOIN encounterfact ef	ON pof.EncounterKey = ef.EncounterKey
INNER JOIN PatientDim pd on pd.DurableKey = ef.PatientDurableKey and pd.IsCurrent=1 and pd.IsValid = 1
WHERE ProcedureKey IN (302762,302621)
UNION
--Patient has a Lab Order for a SARS-CoV-2 lab test
SELECT DISTINCT PD.DurableKey PatientDurableKey, PD.PrimaryMrn mrn, ef.EncounterEpicCsn, ef.EncounterKey,ef.DateKey , 'Lab Order'
FROM LabTestFact ltf	INNER JOIN encounterfact ef	ON ltf.EncounterKey = ef.EncounterKey and ltf.ProcedureDurableKey IN (302762,302621)
INNER JOIN PatientDim pd on pd.DurableKey = ef.PatientDurableKey and pd.IsCurrent=1 and pd.IsValid = 1
UNION
--Patient has a Lab Test Result for a SARS-CoV-2 lab test
SELECT DISTINCT PD.DurableKey PatientDurableKey, PD.PrimaryMrn mrn, ef.EncounterEpicCsn, ef.EncounterKey,ef.DateKey, 'Lab Result'
FROM encounterfact ef INNER JOIN LabComponentResultFact lcrf on ef.EncounterKey = lcrf.EncounterKey and lcrf.LabComponentKey in (29430,29432)
 INNER JOIN PatientDim pd on pd.DurableKey = ef.PatientDurableKey and pd.IsCurrent=1 and pd.IsValid = 1
 UNION
 -- DOH Test
SELECT distinct PD.DurableKey PatientDurableKey, PD.PrimaryMrn mrn, ef.EncounterEpicCsn, ef.EncounterKey, ef.DateKey, 'DOH Tests' SOURCE 
FROM   ENcounterFact ef INNER JOIN PatientDim pd on pd.DurableKey = ef.PatientDurableKey and pd.IsCurrent=1 and pd.IsValid = 1
and EncounterEpicCsn   in 
(123,345,678) --********EncounterEpicCsn is PHI (Replace with required EncounterEpicCsn for MRNs from Department of Health) ********
UNION
--Positive COVID Antibody test
SELECT distinct PD.DurableKey PatientDurableKey, PD.PrimaryMrn mrn, ef.EncounterEpicCsn, ef.EncounterKey, ef.DateKey, 'COVID Antibody Positive'
		             from LabComponentResultFact  lcrf
		                  join LabComponentDim lcd on (lcrf.LabComponentKey = lcd.LabComponentKey 
			                                and lcd.LabComponentEpicId in (32930, 32933, 33098, 32931)
											and lcrf.Value ='Positive'
											)
						  join EncounterFact ef on (ef.EncounterKey = lcrf.EncounterKey)
						  join PatientDim pd on (pd.DurableKey = ef.PatientDurableKey and pd.IsCurrent =1);

drop table if exists #COVID61_DIAGNOSIS;
--COVID-19	ICD10 Code = 'U07.1'
select distinct co.mrn 
        ,co.EncounterEpicCsn 
		,'Pre-Existing_Condition' DIAGNOSIS_TYPE
		, 'COVID-19' DIAGNOSIS_GROUP
		,dtd.DisplayString DIAGNOSIS_DESCRIPTION 
		,da.DateValue DIAGNOSIS_ENTRY_DATE into #COVID61_DIAGNOSIS
from #MSD61COVID19_COHORT co
			 join DiagnosisEventFact  def on (co.PatientDurableKey = def.PatientDurableKey
			                                 and def.Type = 'Problem List' 
											 and def.StartDateKey <= co.DateKey
											 and (def.EndDateKey >= co.DateKey or def.EndDateKey <0
											 and  def.status = 'Active')
										 ) 
			 join DiagnosisDim dd on (def.DiagnosisKey = dd.DiagnosisKey)
			 join DiagnosisTerminologyDim dtd on (dd.DiagnosisKey = dtd.DiagnosisKey
												   and dtd.Type = 'ICD-10-CM'
												   and dtd.Value =  'U07.1') 
			 join DateDim da on (def.StartDateKey = da.DateKey)
			              union
select  DISTINCT co.mrn 
        ,co.EncounterEpicCsn 
		,'Encounter Diagnosis' DIAGNOSIS_TYPE
		, 'COVID-19' DIAGNOSIS_GROUP
		,dtd.DisplayString DIAGNOSIS_DESCRIPTION 
		,da.DateValue DIAGNOSIS_ENTRY_DATE  
from #MSD61COVID19_COHORT co
			 join DiagnosisEventFact  def on (co.EncounterKey = def.EncounterKey
			                                 and def.Type = 'Encounter Diagnosis')
			 join DiagnosisDim dd on (def.DiagnosisKey = dd.DiagnosisKey)
			 join DiagnosisTerminologyDim dtd on (dd.DiagnosisKey = dtd.DiagnosisKey
												   and dtd.Type = 'ICD-10-CM'
												   and dtd.Value =  'U07.1') 
			 join DateDim da on (def.StartDateKey = da.DateKey)
			 UNION		 
--Cancer	ICD10 Code Like 'C%'	 
select  distinct co.mrn 
        ,co.EncounterEpicCsn 
		,'Pre-Existing_Condition' DIAGNOSIS_TYPE
		, 'Cancer' DIAGNOSIS_GROUP
		,dtd.DisplayString DIAGNOSIS_DESCRIPTION 
		,da.DateValue DIAGNOSIS_ENTRY_DATE 
from #MSD61COVID19_COHORT co
			 join DiagnosisEventFact  def on (co.PatientDurableKey = def.PatientDurableKey
			                                 and def.Type = 'Problem List' 
											 and def.StartDateKey <= co.DateKey
											 and (def.EndDateKey >= co.DateKey or def.EndDateKey <0)
											 and  def.status = 'Active'
										 ) 
			 join DiagnosisDim dd on (def.DiagnosisKey = dd.DiagnosisKey)
			 join DiagnosisTerminologyDim dtd on (dd.DiagnosisKey = dtd.DiagnosisKey
												   and dtd.Type = 'ICD-10-CM'
												   and dtd.Value like 'C%') 
			 join DateDim da on (def.StartDateKey = da.DateKey)
			              union
select  co.mrn 
        ,co.EncounterEpicCsn 
		,'Encounter Diagnosis' DIAGNOSIS_TYPE
		, 'Cancer' DIAGNOSIS_GROUP
		,dtd.DisplayString DIAGNOSIS_DESCRIPTION 
		,da.DateValue DIAGNOSIS_ENTRY_DATE 
from #MSD61COVID19_COHORT co
			 join DiagnosisEventFact  def on (co.EncounterKey = def.EncounterKey
			                                 and def.Type = 'Encounter Diagnosis')
			 join DiagnosisDim dd on (def.DiagnosisKey = dd.DiagnosisKey)
			 join DiagnosisTerminologyDim dtd on (dd.DiagnosisKey = dtd.DiagnosisKey
												   and dtd.Type = 'ICD-10-CM'
												   and dtd.Value like 'C%') 
			 join DateDim da on (def.StartDateKey = da.DateKey)			 
                  UNION
--Asthma	ICD10 Code Like 'J45%'			 
select distinct co.mrn 
        ,co.EncounterEpicCsn 
		,'Pre-Existing_Condition' DIAGNOSIS_TYPE
		, 'Asthma' DIAGNOSIS_GROUP
		,dtd.DisplayString DIAGNOSIS_DESCRIPTION 
		,da.DateValue DIAGNOSIS_ENTRY_DATE 
from #MSD61COVID19_COHORT co
			 join DiagnosisEventFact  def on (co.PatientDurableKey = def.PatientDurableKey
			                                 and def.Type = 'Problem List' 
											 and def.StartDateKey <= co.DateKey
											 and (def.EndDateKey >= co.DateKey or def.EndDateKey <0
											 and  def.status = 'Active')
										 ) 
			 join DiagnosisDim dd on (def.DiagnosisKey = dd.DiagnosisKey)
			 join DiagnosisTerminologyDim dtd on (dd.DiagnosisKey = dtd.DiagnosisKey
												   and dtd.Type = 'ICD-10-CM'
												   and dtd.Value like 'J45%') 
			 join DateDim da on (def.StartDateKey = da.DateKey)
			              union
select distinct co.mrn 
        ,co.EncounterEpicCsn 
		,'Encounter Diagnosis' DIAGNOSIS_TYPE
		, 'Asthma' DIAGNOSIS_GROUP
		,dtd.DisplayString DIAGNOSIS_DESCRIPTION 
		,da.DateValue DIAGNOSIS_ENTRY_DATE
from #MSD61COVID19_COHORT co
			 join DiagnosisEventFact  def on (co.EncounterKey = def.EncounterKey
			                                 and def.Type = 'Encounter Diagnosis')
			 join DiagnosisDim dd on (def.DiagnosisKey = dd.DiagnosisKey)
			 join DiagnosisTerminologyDim dtd on (dd.DiagnosisKey = dtd.DiagnosisKey
												   and dtd.Type = 'ICD-10-CM'
												   and dtd.Value like 'J45%') 
			 join DateDim da on (def.StartDateKey = da.DateKey)
                   UNION
--COPD	ICD10 Code like any of the following: 'J41%' OR 'J43%' OR 'J44%'
select distinct co.mrn 
        ,co.EncounterEpicCsn 
		,'Pre-Existing_Condition' DIAGNOSIS_TYPE
		, 'COPD' DIAGNOSIS_GROUP
		,dtd.DisplayString DIAGNOSIS_DESCRIPTION 
		,da.DateValue DIAGNOSIS_ENTRY_DATE 
from #MSD61COVID19_COHORT co
			 join DiagnosisEventFact  def on (co.PatientDurableKey = def.PatientDurableKey
			                                 and def.Type = 'Problem List' 
											 and def.StartDateKey <= co.DateKey
											 and (def.EndDateKey >= co.DateKey or def.EndDateKey <0
											 and  def.status = 'Active')
										 ) 
			 join DiagnosisDim dd on (def.DiagnosisKey = dd.DiagnosisKey)
			 join DiagnosisTerminologyDim dtd on (dd.DiagnosisKey = dtd.DiagnosisKey
												   and dtd.Type = 'ICD-10-CM'
												   and (dtd.Value like 'J41%' OR dtd.Value like  'J43%' OR dtd.Value like  'J44%' )
												   ) 
			 join DateDim da on (def.StartDateKey = da.DateKey)
			              union
select  distinct co.mrn 
        ,co.EncounterEpicCsn 
		,'Encounter Diagnosis'DIAGNOSIS_TYPE
		, 'COPD' DIAGNOSIS_GROUP
		,dtd.DisplayString DIAGNOSIS_DESCRIPTION 
		,da.DateValue DIAGNOSIS_ENTRY_DATE
from #MSD61COVID19_COHORT co
			 join DiagnosisEventFact  def on (co.EncounterKey = def.EncounterKey
			                                 and def.Type = 'Encounter Diagnosis')
			 join DiagnosisDim dd on (def.DiagnosisKey = dd.DiagnosisKey)
			 join DiagnosisTerminologyDim dtd on (dd.DiagnosisKey = dtd.DiagnosisKey
												   and dtd.Type = 'ICD-10-CM'
												   and (dtd.Value like 'J41%' OR dtd.Value like  'J43%' OR dtd.Value like  'J44%' )
												   )
			 join DateDim da on (def.StartDateKey = da.DateKey)
                              UNION
-- HTN	ICD10 Code = 'I10' OR ICD10 CODE like any of the following: 'I11%' or 'I12%' or 'I13%' or 'I15%'
select distinct co.mrn 
        ,co.EncounterEpicCsn 
		,'Pre-Existing_Condition' DIAGNOSIS_TYPE
		, 'HTN' DIAGNOSIS_GROUP
		,dtd.DisplayString DIAGNOSIS_DESCRIPTION 
		,da.DateValue DIAGNOSIS_ENTRY_DATE 
from #MSD61COVID19_COHORT co
			 join DiagnosisEventFact  def on (co.PatientDurableKey = def.PatientDurableKey
			                                 and def.Type = 'Problem List' 
											 and def.StartDateKey <= co.DateKey
											 and (def.EndDateKey >= co.DateKey or def.EndDateKey <0
											 and  def.status = 'Active')
										 ) 
			 join DiagnosisDim dd on (def.DiagnosisKey = dd.DiagnosisKey)
			 join DiagnosisTerminologyDim dtd on (dd.DiagnosisKey = dtd.DiagnosisKey
												   and dtd.Type = 'ICD-10-CM'
												    and (dtd.Value = 'I10' OR dtd.Value like 'I11%' or dtd.Value like  'I12%' 
													        or dtd.Value like  'I13%' or dtd.Value like  'I15%' )
														  and  def.status = 'Active'
												   ) 
			 join DateDim da on (def.StartDateKey = da.DateKey)
			              union
select  distinct co.mrn 
        ,co.EncounterEpicCsn 
		,'Encounter Diagnosis' DIAGNOSIS_TYPE
		, 'HTN' DIAGNOSIS_GROUP
		,dtd.DisplayString DIAGNOSIS_DESCRIPTION 
		,da.DateValue DIAGNOSIS_ENTRY_DATE
from #MSD61COVID19_COHORT co
			 join DiagnosisEventFact  def on (co.EncounterKey = def.EncounterKey
			                                 and def.Type = 'Encounter Diagnosis')
			 join DiagnosisDim dd on (def.DiagnosisKey = dd.DiagnosisKey)
			 join DiagnosisTerminologyDim dtd on (dd.DiagnosisKey = dtd.DiagnosisKey
												   and dtd.Type = 'ICD-10-CM'
												    and (dtd.Value = 'I10' or dtd.Value like 'I11%' or dtd.Value like  'I12%' or dtd.Value like  'I13%' 
													                       or dtd.Value like  'I15%' )
													    )
			 join DateDim da on (def.StartDateKey = da.DateKey)			 
                  UNION
--Obstructive Sleep Apnea	ICD10 = 'G47.33'
select distinct co.mrn 
        ,co.EncounterEpicCsn 
		,'Pre-Existing_Condition' DIAGNOSIS_TYPE
		, 'Obstructive Sleep Apnea' DIAGNOSIS_GROUP
		,dtd.DisplayString DIAGNOSIS_DESCRIPTION 
		,da.DateValue DIAGNOSIS_ENTRY_DATE 
from #MSD61COVID19_COHORT co
			 join DiagnosisEventFact  def on (co.PatientDurableKey = def.PatientDurableKey
			                                 and def.Type = 'Problem List' 
											 and def.StartDateKey <= co.DateKey
											 and (def.EndDateKey >= co.DateKey or def.EndDateKey <0)
											 and  def.status = 'Active'
										 ) 
			 join DiagnosisDim dd on (def.DiagnosisKey = dd.DiagnosisKey)
			 join DiagnosisTerminologyDim dtd on (dd.DiagnosisKey = dtd.DiagnosisKey
												   and dtd.Type = 'ICD-10-CM' 
												   and dtd.Value = 'G47.33'
												   ) 
			 join DateDim da on (def.StartDateKey = da.DateKey)
			              union
select  distinct co.mrn 
        ,co.EncounterEpicCsn 
		,'Encounter Diagnosis' DIAGNOSIS_TYPE
		, 'Obstructive Sleep Apnea' DIAGNOSIS_GROUP
		,dtd.DisplayString DIAGNOSIS_DESCRIPTION 
		,da.DateValue DIAGNOSIS_ENTRY_DATE
from #MSD61COVID19_COHORT co
			 join DiagnosisEventFact  def on (co.EncounterKey = def.EncounterKey
			                                 and def.Type = 'Encounter Diagnosis')
			 join DiagnosisDim dd on (def.DiagnosisKey = dd.DiagnosisKey)
			 join DiagnosisTerminologyDim dtd on (dd.DiagnosisKey = dtd.DiagnosisKey
												   and dtd.Type = 'ICD-10-CM' 
												   and dtd.Value = 'G47.33'
												   )
			 join DateDim da on (def.StartDateKey = da.DateKey)
               UNION
-- Obesity	ICD10 Code LIKE 'E66.0%' OR ICD10 Code IN ('E66.1', 'E66.2', 'E66.8', 'E66.9)
select distinct co.mrn 
        ,co.EncounterEpicCsn 
		,'Pre-Existing_Condition' DIAGNOSIS_TYPE
		, 'Obesity' DIAGNOSIS_GROUP
		,dtd.DisplayString DIAGNOSIS_DESCRIPTION 
		,da.DateValue DIAGNOSIS_ENTRY_DATE 
from #MSD61COVID19_COHORT co
			 join DiagnosisEventFact  def on (co.PatientDurableKey = def.PatientDurableKey
			                                 and def.Type = 'Problem List' 
											 and def.StartDateKey <= co.DateKey
											 and (def.EndDateKey >= co.DateKey or def.EndDateKey <0)
											 and  def.status = 'Active'
										 ) 
			 join DiagnosisDim dd on (def.DiagnosisKey = dd.DiagnosisKey)
			 join DiagnosisTerminologyDim dtd on (dd.DiagnosisKey = dtd.DiagnosisKey
												   and dtd.Type = 'ICD-10-CM' 
												   and ( dtd.Value  like 'E66.0%' OR dtd.Value in ('E66.1', 'E66.2', 'E66.8', 'E66.9'))
												   )  
			 join DateDim da on (def.StartDateKey = da.DateKey)
			              union
select  distinct co.mrn 
        ,co.EncounterEpicCsn 
		,'Encounter Diagnosis' DIAGNOSIS_TYPE
		, 'Obesity' DIAGNOSIS_GROUP
		,dtd.DisplayString DIAGNOSIS_DESCRIPTION 
		,da.DateValue DIAGNOSIS_ENTRY_DATE
from #MSD61COVID19_COHORT co
			 join DiagnosisEventFact  def on (co.EncounterKey = def.EncounterKey
			                                 and def.Type = 'Encounter Diagnosis')
			 join DiagnosisDim dd on (def.DiagnosisKey = dd.DiagnosisKey)
			 join DiagnosisTerminologyDim dtd on (dd.DiagnosisKey = dtd.DiagnosisKey
												   and dtd.Type = 'ICD-10-CM' 
												   and ( dtd.Value  like 'E66.0%' OR dtd.Value in ('E66.1', 'E66.2', 'E66.8', 'E66.9'))
												   ) 
			 join DateDim da on (def.StartDateKey = da.DateKey)
                    UNION
-- Diabetes	ICD10 like any of the following: 'E08%' or 'E09%' or 'E10%' or 'E11%' or 'E13%' or 'O24.0%' or 'O24.1%' or 'O24.3%' or 'O24.8%'
select distinct co.mrn 
        ,co.EncounterEpicCsn 
		,'Pre-Existing_Condition' DIAGNOSIS_TYPE
		, 'Diabetes' DIAGNOSIS_GROUP
		,dtd.DisplayString DIAGNOSIS_DESCRIPTION 
		,da.DateValue DIAGNOSIS_ENTRY_DATE 
from #MSD61COVID19_COHORT co
			 join DiagnosisEventFact  def on (co.PatientDurableKey = def.PatientDurableKey
			                                 and def.Type = 'Problem List' 
											 and def.StartDateKey <= co.DateKey
											 and (def.EndDateKey >= co.DateKey or def.EndDateKey <0)
											 and  def.status = 'Active'
										 ) 
			 join DiagnosisDim dd on (def.DiagnosisKey = dd.DiagnosisKey)
			 join DiagnosisTerminologyDim dtd on (dd.DiagnosisKey = dtd.DiagnosisKey
												   and dtd.Type = 'ICD-10-CM' 
												   and ( dtd.Value like 'E08%' or dtd.Value like 'E09%' or  dtd.Value like 'E10%' or dtd.Value like 'E11%' or dtd.Value like 'E13%' 
												   or dtd.Value like 'O24.0%' or dtd.Value like 'O24.1%' or dtd.Value like 'O24.3%' or dtd.Value like 'O24.8%')
												   )  
			 join DateDim da on (def.StartDateKey = da.DateKey)
			              union
select  distinct co.mrn 
        ,co.EncounterEpicCsn 
		,'Encounter Diagnosis' DIAGNOSIS_TYPE
		, 'Diabetes' DIAGNOSIS_GROUP
		,dtd.DisplayString DIAGNOSIS_DESCRIPTION 
		,da.DateValue DIAGNOSIS_ENTRY_DATE
from #MSD61COVID19_COHORT co
			 join DiagnosisEventFact  def on (co.EncounterKey = def.EncounterKey
			                                 and def.Type = 'Encounter Diagnosis')
			 join DiagnosisDim dd on (def.DiagnosisKey = dd.DiagnosisKey)
			 join DiagnosisTerminologyDim dtd on (dd.DiagnosisKey = dtd.DiagnosisKey
												   and dtd.Type = 'ICD-10-CM' 
												   and ( dtd.Value like 'E08%' or dtd.Value like 'E09%' or  dtd.Value like 'E10%' or dtd.Value like 'E11%' or dtd.Value like 'E13%' 
												   or dtd.Value like 'O24.0%' or dtd.Value like 'O24.1%' or dtd.Value like 'O24.3%' or dtd.Value like 'O24.8%')
												   ) 
			 join DateDim da on (def.StartDateKey = da.DateKey)
                       UNION
-- Chronic Kidney Disease	ICD10 IN ('E08.22', 'E09.22', 'E10.22', 'E11.22','E13.22') OR ICD10 like any of the following: 'I12%' or 'I13%' or 'N18%'	
select distinct co.mrn 
        ,co.EncounterEpicCsn 
		,'Pre-Existing_Condition' DIAGNOSIS_TYPE
		, 'Chronic Kidney Disease' DIAGNOSIS_GROUP
		,dtd.DisplayString DIAGNOSIS_DESCRIPTION 
		,da.DateValue DIAGNOSIS_ENTRY_DATE 
from #MSD61COVID19_COHORT co
			 join DiagnosisEventFact  def on (co.PatientDurableKey = def.PatientDurableKey
			                                 and def.Type = 'Problem List' 
											 and def.StartDateKey <= co.DateKey
											 and (def.EndDateKey >= co.DateKey or def.EndDateKey <0)
											 and  def.status = 'Active'
										 ) 
			 join DiagnosisDim dd on (def.DiagnosisKey = dd.DiagnosisKey)
			 join DiagnosisTerminologyDim dtd on (dd.DiagnosisKey = dtd.DiagnosisKey
												   and dtd.Type = 'ICD-10-CM' 
												   and ( dtd.Value IN ('E08.22', 'E09.22', 'E10.22', 'E11.22','E13.22') or dtd.Value like 'I12%' or dtd.Value LIKE 'I13%' or dtd.Value LIKE 'N18%')
												   )  
			 join DateDim da on (def.StartDateKey = da.DateKey)
			              union
select  distinct co.mrn 
        ,co.EncounterEpicCsn 
		,'Encounter Diagnosis' DIAGNOSIS_TYPE
		, 'Chronic Kidney Disease' DIAGNOSIS_GROUP
		,dtd.DisplayString DIAGNOSIS_DESCRIPTION 
		,da.DateValue DIAGNOSIS_ENTRY_DATE
from #MSD61COVID19_COHORT co
			 join DiagnosisEventFact  def on (co.EncounterKey = def.EncounterKey
			                                 and def.Type = 'Encounter Diagnosis')
			 join DiagnosisDim dd on (def.DiagnosisKey = dd.DiagnosisKey)
			 join DiagnosisTerminologyDim dtd on (dd.DiagnosisKey = dtd.DiagnosisKey
												   and dtd.Type = 'ICD-10-CM' 
												   and ( dtd.Value IN ('E08.22', 'E09.22', 'E10.22', 'E11.22','E13.22') or dtd.Value like 'I12%' or dtd.Value LIKE 'I13%' or dtd.Value LIKE 'N18%')
												   ) 
			 join DateDim da on (def.StartDateKey = da.DateKey)
                      UNION
-- HIV	ICD10 Codes IN ('B20','B97.35','Z21','O98.7','O98.71','O98.711','O98.712','O98.713','O98.719','O98.72','O98.73')
select distinct co.mrn 
        ,co.EncounterEpicCsn 
		,'Pre-Existing_Condition' DIAGNOSIS_TYPE
		, 'HIV' DIAGNOSIS_GROUP
		,dtd.DisplayString DIAGNOSIS_DESCRIPTION 
		,da.DateValue DIAGNOSIS_ENTRY_DATE 
from #MSD61COVID19_COHORT co
			 join DiagnosisEventFact  def on (co.PatientDurableKey = def.PatientDurableKey
			                                 and def.Type = 'Problem List' 
											 and def.StartDateKey <= co.DateKey
											 and (def.EndDateKey >= co.DateKey or def.EndDateKey <0)
											 and  def.status = 'Active'
										 ) 
			 join DiagnosisDim dd on (def.DiagnosisKey = dd.DiagnosisKey)
			 join DiagnosisTerminologyDim dtd on (dd.DiagnosisKey = dtd.DiagnosisKey
												   and dtd.Type = 'ICD-10-CM' 
												   and dtd.Value IN ('B20','B97.35','Z21','O98.7','O98.71','O98.711','O98.712','O98.713','O98.719','O98.72','O98.73')
												   )  
			 join DateDim da on (def.StartDateKey = da.DateKey)
			              union
select  distinct co.mrn 
        ,co.EncounterEpicCsn 
		,'Encounter Diagnosis' DIAGNOSIS_TYPE
		, 'HIV' DIAGNOSIS_GROUP
		,dtd.DisplayString DIAGNOSIS_DESCRIPTION 
		,da.DateValue DIAGNOSIS_ENTRY_DATE
from #MSD61COVID19_COHORT co
			 join DiagnosisEventFact  def on (co.EncounterKey = def.EncounterKey
			                                 and def.Type = 'Encounter Diagnosis')
			 join DiagnosisDim dd on (def.DiagnosisKey = dd.DiagnosisKey)
			 join DiagnosisTerminologyDim dtd on (dd.DiagnosisKey = dtd.DiagnosisKey
												   and dtd.Type = 'ICD-10-CM' 
												   and dtd.Value IN ('B20','B97.35','Z21','O98.7','O98.71','O98.711','O98.712','O98.713','O98.719','O98.72','O98.73')
												   ) 
			 join DateDim da on (def.StartDateKey = da.DateKey)			 
                 UNION
--Coronary Artery Disease	ICD10 like any of the following: 'I21%' or 'I22%' or 'I23%' or 'I24%' or 'I25%'
select distinct co.mrn 
        ,co.EncounterEpicCsn 
		,'Pre-Existing_Condition' DIAGNOSIS_TYPE
		, 'Coronary Artery Disease' DIAGNOSIS_GROUP
		,dtd.DisplayString DIAGNOSIS_DESCRIPTION 
		,da.DateValue DIAGNOSIS_ENTRY_DATE 
from #MSD61COVID19_COHORT co
			 join DiagnosisEventFact  def on (co.PatientDurableKey = def.PatientDurableKey
			                                 and def.Type = 'Problem List' 
											 and def.StartDateKey <= co.DateKey
											 and (def.EndDateKey >= co.DateKey or def.EndDateKey <0)
											 and  def.status = 'Active'
										 ) 
			 join DiagnosisDim dd on (def.DiagnosisKey = dd.DiagnosisKey)
			 join DiagnosisTerminologyDim dtd on (dd.DiagnosisKey = dtd.DiagnosisKey
												   and dtd.Type = 'ICD-10-CM' 
												   and  ( dtd.Value LIKE 'I21%' or dtd.Value LIKE 'I22%' or dtd.Value LIKE 'I23%' or  dtd.Value LIKE 'I24%' or dtd.Value LIKE 'I25%')
												   )  
			 join DateDim da on (def.StartDateKey = da.DateKey)
			              union
select  distinct co.mrn 
        ,co.EncounterEpicCsn 
		,'Encounter Diagnosis' DIAGNOSIS_TYPE
		, 'Coronary Artery Disease' DIAGNOSIS_GROUP
		,dtd.DisplayString DIAGNOSIS_DESCRIPTION 
		,da.DateValue DIAGNOSIS_ENTRY_DATE
from #MSD61COVID19_COHORT co
			 join DiagnosisEventFact  def on (co.EncounterKey = def.EncounterKey
			                                 and def.Type = 'Encounter Diagnosis')
			 join DiagnosisDim dd on (def.DiagnosisKey = dd.DiagnosisKey)
			 join DiagnosisTerminologyDim dtd on (dd.DiagnosisKey = dtd.DiagnosisKey
												   and dtd.Type = 'ICD-10-CM' 
												   and  ( dtd.Value LIKE 'I21%' or dtd.Value LIKE 'I22%' or dtd.Value LIKE 'I23%' or  dtd.Value LIKE 'I24%' or dtd.Value LIKE 'I25%')
												   ) 
			 join DateDim da on (def.StartDateKey = da.DateKey)
            UNION
-- Atrial Fibrillation	ICD10 LIKE 'I48%'			 
select distinct co.mrn 
        ,co.EncounterEpicCsn 
		,'Pre-Existing_Condition' DIAGNOSIS_TYPE
		, 'Atrial Fibrillation' DIAGNOSIS_GROUP
		,dtd.DisplayString DIAGNOSIS_DESCRIPTION 
		,da.DateValue DIAGNOSIS_ENTRY_DATE 
from #MSD61COVID19_COHORT co
			 join DiagnosisEventFact  def on (co.PatientDurableKey = def.PatientDurableKey
			                                 and def.Type = 'Problem List' 
											 and def.StartDateKey <= co.DateKey
											 and (def.EndDateKey >= co.DateKey or def.EndDateKey <0)
											 and  def.status = 'Active'
										 ) 
			 join DiagnosisDim dd on (def.DiagnosisKey = dd.DiagnosisKey)
			 join DiagnosisTerminologyDim dtd on (dd.DiagnosisKey = dtd.DiagnosisKey
												   and dtd.Type = 'ICD-10-CM' 
												   and dtd.Value LIKE 'I48%'
												   )  
			 join DateDim da on (def.StartDateKey = da.DateKey)
			              union
select  distinct co.mrn 
        ,co.EncounterEpicCsn 
		,'Encounter Diagnosis' DIAGNOSIS_TYPE
		, 'Atrial Fibrillation' DIAGNOSIS_GROUP
		,dtd.DisplayString DIAGNOSIS_DESCRIPTION 
		,da.DateValue DIAGNOSIS_ENTRY_DATE
from #MSD61COVID19_COHORT co
			 join DiagnosisEventFact  def on (co.EncounterKey = def.EncounterKey
			                                 and def.Type = 'Encounter Diagnosis') 
			 join DiagnosisDim dd on (def.DiagnosisKey = dd.DiagnosisKey)
			 join DiagnosisTerminologyDim dtd on (dd.DiagnosisKey = dtd.DiagnosisKey
												   and dtd.Type = 'ICD-10-CM' 
												   and dtd.Value LIKE 'I48%'
												   ) 
			 join DateDim da on (def.StartDateKey = da.DateKey)
	           UNION
--Heart Failure	ICD10 LIKE 'I50%'	
select distinct co.mrn 
        ,co.EncounterEpicCsn 
		,'Pre-Existing_Condition' DIAGNOSIS_TYPE
		, 'Heart Failure' DIAGNOSIS_GROUP
		,dtd.DisplayString DIAGNOSIS_DESCRIPTION 
		,da.DateValue DIAGNOSIS_ENTRY_DATE 
from #MSD61COVID19_COHORT co
			 join DiagnosisEventFact  def on (co.PatientDurableKey = def.PatientDurableKey
			                                 and def.Type = 'Problem List' 
											 and def.StartDateKey <= co.DateKey
											 and (def.EndDateKey >= co.DateKey or def.EndDateKey <0)
											 and  def.status = 'Active'
										 ) 
			 join DiagnosisDim dd on (def.DiagnosisKey = dd.DiagnosisKey)
			 join DiagnosisTerminologyDim dtd on (dd.DiagnosisKey = dtd.DiagnosisKey
												   and dtd.Type = 'ICD-10-CM' 
												   and dtd.Value LIKE 'I50%'
												   )  
			 join DateDim da on (def.StartDateKey = da.DateKey)
			              union
select  distinct co.mrn 
        ,co.EncounterEpicCsn 
		,'Encounter Diagnosis' DIAGNOSIS_TYPE
		, 'Heart Failure' DIAGNOSIS_GROUP
		,dtd.DisplayString DIAGNOSIS_DESCRIPTION 
		,da.DateValue DIAGNOSIS_ENTRY_DATE
from #MSD61COVID19_COHORT co
			 join DiagnosisEventFact  def on (co.EncounterKey = def.EncounterKey
			                                 and def.Type = 'Encounter Diagnosis') 
			 join DiagnosisDim dd on (def.DiagnosisKey = dd.DiagnosisKey)
			 join DiagnosisTerminologyDim dtd on (dd.DiagnosisKey = dtd.DiagnosisKey
												   and dtd.Type = 'ICD-10-CM' 
												   and dtd.Value LIKE 'I50%'
												   ) 
			 join DateDim da on (def.StartDateKey = da.DateKey)
			 UNION
--Chronic Viral Hepatitis	ICD10 LIKE 'B18%'			 
select distinct co.mrn 
        ,co.EncounterEpicCsn 
		,'Pre-Existing_Condition' DIAGNOSIS_TYPE
		, 'Chronic Viral Hepatitis' DIAGNOSIS_GROUP
		,dtd.DisplayString DIAGNOSIS_DESCRIPTION 
		,da.DateValue DIAGNOSIS_ENTRY_DATE 
from #MSD61COVID19_COHORT co
			 join DiagnosisEventFact  def on (co.PatientDurableKey = def.PatientDurableKey
			                                 and def.Type = 'Problem List' 
											 and def.StartDateKey <= co.DateKey
											 and (def.EndDateKey >= co.DateKey or def.EndDateKey <0)
											 and  def.status = 'Active'
										 ) 
			 join DiagnosisDim dd on (def.DiagnosisKey = dd.DiagnosisKey)
			 join DiagnosisTerminologyDim dtd on (dd.DiagnosisKey = dtd.DiagnosisKey
												   and dtd.Type = 'ICD-10-CM' 
												   and dtd.Value LIKE 'B18%'
												   )  
			 join DateDim da on (def.StartDateKey = da.DateKey)
			              union
select  distinct co.mrn 
        ,co.EncounterEpicCsn 
		,'Encounter Diagnosis' DIAGNOSIS_TYPE
		, 'Chronic Viral Hepatitis' DIAGNOSIS_GROUP
		,dtd.DisplayString DIAGNOSIS_DESCRIPTION 
		,da.DateValue DIAGNOSIS_ENTRY_DATE
from #MSD61COVID19_COHORT co
			 join DiagnosisEventFact  def on (co.EncounterKey = def.EncounterKey
			                                 and def.Type = 'Encounter Diagnosis')
			 join DiagnosisDim dd on (def.DiagnosisKey = dd.DiagnosisKey)
			 join DiagnosisTerminologyDim dtd on (dd.DiagnosisKey = dtd.DiagnosisKey
												   and dtd.Type = 'ICD-10-CM' 
												   and dtd.Value LIKE 'B18%'
												   ) 
			 join DateDim da on (def.StartDateKey = da.DateKey)
			         UNION
--Alcoholic/Nonalcoholic Liver Disease	ICD10 CODE IN ('K75.81', 'K76.0') or ICD10 code like any of the following: 'K70%' or 'K74%'
select distinct co.mrn 
        ,co.EncounterEpicCsn 
		,'Pre-Existing_Condition' DIAGNOSIS_TYPE
		, 'Alcoholic/Nonalcoholic Liver' DIAGNOSIS_GROUP
		,dtd.DisplayString DIAGNOSIS_DESCRIPTION 
		,da.DateValue DIAGNOSIS_ENTRY_DATE 
from #MSD61COVID19_COHORT co
			 join DiagnosisEventFact  def on (co.PatientDurableKey = def.PatientDurableKey
			                                 and def.Type = 'Problem List' 
											 and def.StartDateKey <= co.DateKey
											 and (def.EndDateKey >= co.DateKey or def.EndDateKey <0)
											 and  def.status = 'Active'
										 ) 
			 join DiagnosisDim dd on (def.DiagnosisKey = dd.DiagnosisKey)
			 join DiagnosisTerminologyDim dtd on (dd.DiagnosisKey = dtd.DiagnosisKey
												   and dtd.Type = 'ICD-10-CM' 
												    and ( dtd.Value in ('K75.81', 'K76.0') OR dtd.Value  like 'K70%' OR dtd.Value  like 'K74%')
												   )  
			 join DateDim da on (def.StartDateKey = da.DateKey)
			              union
select  distinct co.mrn 
        ,co.EncounterEpicCsn 
		,'Encounter Diagnosis' DIAGNOSIS_TYPE
		, 'Alcoholic/Nonalcoholic Liver' DIAGNOSIS_GROUP
		,dtd.DisplayString DIAGNOSIS_DESCRIPTION 
		,da.DateValue DIAGNOSIS_ENTRY_DATE
from #MSD61COVID19_COHORT co
			 join DiagnosisEventFact  def on (co.EncounterKey = def.EncounterKey
			                                 and def.Type = 'Encounter Diagnosis') 
			 join DiagnosisDim dd on (def.DiagnosisKey = dd.DiagnosisKey)
			 join DiagnosisTerminologyDim dtd on (dd.DiagnosisKey = dtd.DiagnosisKey
												   and dtd.Type = 'ICD-10-CM' 
												    and ( dtd.Value in ('K75.81', 'K76.0') OR dtd.Value  like 'K70%' OR dtd.Value  like 'K74%')
												   ) 
			 join DateDim da on (def.StartDateKey = da.DateKey)	
                    UNION
--Crohn's Disease	ICD10 Code LIKE 'K50%'		
select  distinct co.mrn 
        ,co.EncounterEpicCsn 
		,'Pre-Existing_Condition' DIAGNOSIS_TYPE
		, 'Crohn''s Disease' DIAGNOSIS_GROUP
		,dtd.DisplayString DIAGNOSIS_DESCRIPTION 
		,da.DateValue DIAGNOSIS_ENTRY_DATE
from #MSD61COVID19_COHORT co
			 join DiagnosisEventFact  def on (co.PatientDurableKey = def.PatientDurableKey
			                                 and def.Type = 'Problem List' 
											 and def.StartDateKey <= co.DateKey
											 and (def.EndDateKey >= co.DateKey or def.EndDateKey <0)
											 and  def.status = 'Active'
										 ) 
			 join DiagnosisDim dd on (def.DiagnosisKey = dd.DiagnosisKey)
			 join DiagnosisTerminologyDim dtd on (dd.DiagnosisKey = dtd.DiagnosisKey
												   and dtd.Type = 'ICD-10-CM' 
												   and dtd.Value LIKE 'K50%'
												   )  
			 join DateDim da on (def.StartDateKey = da.DateKey)
			              union
select  distinct co.mrn 
        ,co.EncounterEpicCsn 
		,'Encounter Diagnosis' DIAGNOSIS_TYPE
		, 'Crohn''s Disease' DIAGNOSIS_GROUP
		,dtd.DisplayString DIAGNOSIS_DESCRIPTION 
		,da.DateValue DIAGNOSIS_ENTRY_DATE
from #MSD61COVID19_COHORT co
			 join DiagnosisEventFact  def on (co.EncounterKey = def.EncounterKey
			                                 and def.Type = 'Encounter Diagnosis')
			 join DiagnosisDim dd on (def.DiagnosisKey = dd.DiagnosisKey)
			 join DiagnosisTerminologyDim dtd on (dd.DiagnosisKey = dtd.DiagnosisKey
												   and dtd.Type = 'ICD-10-CM' 
												   and dtd.Value LIKE 'K50%'
												   ) 
			 join DateDim da on (def.StartDateKey = da.DateKey)	
                  UNION
--Ulcerative Colitis	ICD10 Code LIKE 'K51%'		
select  distinct co.mrn 
        ,co.EncounterEpicCsn 
		,'Pre-Existing_Condition' DIAGNOSIS_TYPE
		, 'Ulcerative Colitis' DIAGNOSIS_GROUP
		,dtd.DisplayString DIAGNOSIS_DESCRIPTION 
		,da.DateValue DIAGNOSIS_ENTRY_DATE
from #MSD61COVID19_COHORT co
			 join DiagnosisEventFact  def on (co.PatientDurableKey = def.PatientDurableKey
			                                 and def.Type = 'Problem List' 
											 and def.StartDateKey <= co.DateKey
											 and (def.EndDateKey >= co.DateKey or def.EndDateKey <0)
											 and  def.status = 'Active'
										 ) 
			 join DiagnosisDim dd on (def.DiagnosisKey = dd.DiagnosisKey)
			 join DiagnosisTerminologyDim dtd on (dd.DiagnosisKey = dtd.DiagnosisKey
												   and dtd.Type = 'ICD-10-CM' 
												   and dtd.Value LIKE 'K51%'
												   )  
			 join DateDim da on (def.StartDateKey = da.DateKey)
			              union
select  distinct co.mrn 
        ,co.EncounterEpicCsn 
		,'Encounter Diagnosis' DIAGNOSIS_TYPE
		, 'Ulcerative Colitis' DIAGNOSIS_GROUP
		,dtd.DisplayString DIAGNOSIS_DESCRIPTION 
		,da.DateValue DIAGNOSIS_ENTRY_DATE
from #MSD61COVID19_COHORT co
			 join DiagnosisEventFact  def on (co.EncounterKey = def.EncounterKey
			                                 and def.Type = 'Encounter Diagnosis')
			 join DiagnosisDim dd on (def.DiagnosisKey = dd.DiagnosisKey)
			 join DiagnosisTerminologyDim dtd on (dd.DiagnosisKey = dtd.DiagnosisKey
												   and dtd.Type = 'ICD-10-CM' 
												   and dtd.Value LIKE 'K51%'
												   ) 
			 join DateDim da on (def.StartDateKey = da.DateKey)	
                  UNION
--ARDS	ICD10 Code = 'J80'		
select  distinct co.mrn 
        ,co.EncounterEpicCsn 
		,'Pre-Existing_Condition' DIAGNOSIS_TYPE
		, 'ARDS' DIAGNOSIS_GROUP
		,dtd.DisplayString DIAGNOSIS_DESCRIPTION 
		,da.DateValue DIAGNOSIS_ENTRY_DATE
from #MSD61COVID19_COHORT co
			 join DiagnosisEventFact  def on (co.PatientDurableKey = def.PatientDurableKey
			                                 and def.Type = 'Problem List' 
											 and def.StartDateKey <= co.DateKey
											 and (def.EndDateKey >= co.DateKey or def.EndDateKey <0)
											 and  def.status = 'Active'
										 ) 
			 join DiagnosisDim dd on (def.DiagnosisKey = dd.DiagnosisKey)
			 join DiagnosisTerminologyDim dtd on (dd.DiagnosisKey = dtd.DiagnosisKey
												   and dtd.Type = 'ICD-10-CM' 
												   and dtd.Value = 'J80'
												   )  
			 join DateDim da on (def.StartDateKey = da.DateKey)
			              union
select  distinct co.mrn 
        ,co.EncounterEpicCsn 
		,'Encounter Diagnosis' DIAGNOSIS_TYPE
		, 'ARDS' DIAGNOSIS_GROUP
		,dtd.DisplayString DIAGNOSIS_DESCRIPTION 
		,da.DateValue DIAGNOSIS_ENTRY_DATE
from #MSD61COVID19_COHORT co
			 join DiagnosisEventFact  def on (co.EncounterKey = def.EncounterKey
			                                 and def.Type = 'Encounter Diagnosis')
			 join DiagnosisDim dd on (def.DiagnosisKey = dd.DiagnosisKey)
			 join DiagnosisTerminologyDim dtd on (dd.DiagnosisKey = dtd.DiagnosisKey
												   and dtd.Type = 'ICD-10-CM' 
												   and dtd.Value = 'J80'
												   ) 
			 join DateDim da on (def.StartDateKey = da.DateKey)	
                  UNION
--Acute Kidney Injury	ICD10 Code LIKE 'N17%'	
select   distinct co.mrn 
        ,co.EncounterEpicCsn 
		,'Pre-Existing_Condition' DIAGNOSIS_TYPE
		, 'Acute Kidney Injury' DIAGNOSIS_GROUP
		,dtd.DisplayString DIAGNOSIS_DESCRIPTION 
		,da.DateValue DIAGNOSIS_ENTRY_DATE
from #MSD61COVID19_COHORT co
			 join DiagnosisEventFact  def on (co.PatientDurableKey = def.PatientDurableKey
			                                 and def.Type = 'Problem List' 
											 and def.StartDateKey <= co.DateKey
											 and (def.EndDateKey >= co.DateKey or def.EndDateKey <0)
											 and  def.status = 'Active'
										 ) 
			 join DiagnosisDim dd on (def.DiagnosisKey = dd.DiagnosisKey)
			 join DiagnosisTerminologyDim dtd on (dd.DiagnosisKey = dtd.DiagnosisKey
												   and dtd.Type = 'ICD-10-CM' 
												   and dtd.Value like 'N17%'
												   )  
			 join DateDim da on (def.StartDateKey = da.DateKey)
			              union
select  distinct co.mrn 
        ,co.EncounterEpicCsn 
		,'Encounter Diagnosis' DIAGNOSIS_TYPE
		, 'Acute Kidney Injury' DIAGNOSIS_GROUP
		,dtd.DisplayString DIAGNOSIS_DESCRIPTION 
		,da.DateValue DIAGNOSIS_ENTRY_DATE
from #MSD61COVID19_COHORT co
			 join DiagnosisEventFact  def on (co.EncounterKey = def.EncounterKey
			                                 and def.Type = 'Encounter Diagnosis') 
			 join DiagnosisDim dd on (def.DiagnosisKey = dd.DiagnosisKey)
			 join DiagnosisTerminologyDim dtd on (dd.DiagnosisKey = dtd.DiagnosisKey
												   and dtd.Type = 'ICD-10-CM' 
												   and dtd.Value like 'N17%'
												   ) 
			 join DateDim da on (def.StartDateKey = da.DateKey)
            UNION	
-- Acute Venous Thromboembolism	ICD10 Code like any of the following: 'I26%' or 'I82.4%'
select   distinct co.mrn 
        ,co.EncounterEpicCsn 
		,'Pre-Existing_Condition' DIAGNOSIS_TYPE
		, 'Acute Venous Thromboembolism' DIAGNOSIS_GROUP
		,dtd.DisplayString DIAGNOSIS_DESCRIPTION 
		,da.DateValue DIAGNOSIS_ENTRY_DATE
from #MSD61COVID19_COHORT co
			 join DiagnosisEventFact  def on (co.PatientDurableKey = def.PatientDurableKey
			                                 and def.Type = 'Problem List' 
											 and def.StartDateKey <= co.DateKey
											 and (def.EndDateKey >= co.DateKey or def.EndDateKey <0)
											 and  def.status = 'Active'
										 ) 
			 join DiagnosisDim dd on (def.DiagnosisKey = dd.DiagnosisKey)
			 join DiagnosisTerminologyDim dtd on (dd.DiagnosisKey = dtd.DiagnosisKey
												   and dtd.Type = 'ICD-10-CM' 
												   and (dtd.Value like 'I26%' or dtd.Value like  'I82.4%')
												   )  
			 join DateDim da on (def.StartDateKey = da.DateKey)
			              union
select  distinct co.mrn 
        ,co.EncounterEpicCsn 
		,'Encounter Diagnosis' DIAGNOSIS_TYPE
		, 'Acute Venous Thromboembolism' DIAGNOSIS_GROUP
		,dtd.DisplayString DIAGNOSIS_DESCRIPTION 
		,da.DateValue DIAGNOSIS_ENTRY_DATE
from #MSD61COVID19_COHORT co
			 join DiagnosisEventFact  def on (co.EncounterKey = def.EncounterKey
			                                 and def.Type = 'Encounter Diagnosis') 
			 join DiagnosisDim dd on (def.DiagnosisKey = dd.DiagnosisKey)
			 join DiagnosisTerminologyDim dtd on (dd.DiagnosisKey = dtd.DiagnosisKey
												   and dtd.Type = 'ICD-10-CM' 
												   and (dtd.Value like 'I26%' or dtd.Value like  'I82.4%')
												   ) 
			 join DateDim da on (def.StartDateKey = da.DateKey)
                            UNION			 

-- Cerebral Infarction	ICD10 Code LIKE 'I63%'			 
select  distinct co.mrn 
        ,co.EncounterEpicCsn 
		,'Pre-Existing_Condition' DIAGNOSIS_TYPE
		, 'Cerebral Infarction' DIAGNOSIS_GROUP
		,dtd.DisplayString DIAGNOSIS_DESCRIPTION 
		,da.DateValue DIAGNOSIS_ENTRY_DATE
from #MSD61COVID19_COHORT co
			 join DiagnosisEventFact  def on (co.PatientDurableKey = def.PatientDurableKey
			                                 and def.Type = 'Problem List' 
											 and def.StartDateKey <= co.DateKey
											 and (def.EndDateKey >= co.DateKey or def.EndDateKey <0)
											 and  def.status = 'Active'
										 ) 
			 join DiagnosisDim dd on (def.DiagnosisKey = dd.DiagnosisKey)
			 join DiagnosisTerminologyDim dtd on (dd.DiagnosisKey = dtd.DiagnosisKey
												   and dtd.Type = 'ICD-10-CM' 
												   and dtd.Value like 'I63%'
												   )  
			 join DateDim da on (def.StartDateKey = da.DateKey)
			              union
select  distinct co.mrn 
        ,co.EncounterEpicCsn 
		,'Encounter Diagnosis' DIAGNOSIS_TYPE
		, 'Cerebral Infarction' DIAGNOSIS_GROUP
		,dtd.DisplayString DIAGNOSIS_DESCRIPTION 
		,da.DateValue DIAGNOSIS_ENTRY_DATE
from #MSD61COVID19_COHORT co
			 join DiagnosisEventFact  def on (co.EncounterKey = def.EncounterKey
			                                 and def.Type = 'Encounter Diagnosis')
			 join DiagnosisDim dd on (def.DiagnosisKey = dd.DiagnosisKey)
			 join DiagnosisTerminologyDim dtd on (dd.DiagnosisKey = dtd.DiagnosisKey
												   and dtd.Type = 'ICD-10-CM' 
												   and dtd.Value like 'I63%'
												   ) 
			 join DateDim da on (def.StartDateKey = da.DateKey)
			 UNION
--Intracerebral Hemorrhage	ICD10 Code LIKE 'I61%'
select  distinct co.mrn 
        ,co.EncounterEpicCsn 
		,'Pre-Existing_Condition' DIAGNOSIS_TYPE
		, 'Intracerebral Hemorrhage' DIAGNOSIS_GROUP
		,dtd.DisplayString DIAGNOSIS_DESCRIPTION 
		,da.DateValue DIAGNOSIS_ENTRY_DATE
from #MSD61COVID19_COHORT co
			 join DiagnosisEventFact  def on (co.PatientDurableKey = def.PatientDurableKey
			                                 and def.Type = 'Problem List' 
											 and def.StartDateKey <= co.DateKey
											 and (def.EndDateKey >= co.DateKey or def.EndDateKey <0)
											 and  def.status = 'Active'
										 ) 
			 join DiagnosisDim dd on (def.DiagnosisKey = dd.DiagnosisKey)
			 join DiagnosisTerminologyDim dtd on (dd.DiagnosisKey = dtd.DiagnosisKey
												   and dtd.Type = 'ICD-10-CM' 
												   and dtd.Value like 'I61%'
												   )  
			 join DateDim da on (def.StartDateKey = da.DateKey)
			              union
select  distinct co.mrn 
        ,co.EncounterEpicCsn 
		,'Encounter Diagnosis' DIAGNOSIS_TYPE
		, 'Intracerebral Hemorrhage' DIAGNOSIS_GROUP
		,dtd.DisplayString DIAGNOSIS_DESCRIPTION 
		,da.DateValue DIAGNOSIS_ENTRY_DATE
from #MSD61COVID19_COHORT co
			 join DiagnosisEventFact  def on (co.EncounterKey = def.EncounterKey
			                                 and def.Type = 'Encounter Diagnosis')
			 join DiagnosisDim dd on (def.DiagnosisKey = dd.DiagnosisKey)
			 join DiagnosisTerminologyDim dtd on (dd.DiagnosisKey = dtd.DiagnosisKey
												   and dtd.Type = 'ICD-10-CM' 
												   and dtd.Value like 'I61%'
												   ) 
			 join DateDim da on (def.StartDateKey = da.DateKey)
			 UNION
--Acute_MI	ICD10 Code LIKE 'I21%'
select  distinct co.mrn 
        ,co.EncounterEpicCsn 
		,'Pre-Existing_Condition' DIAGNOSIS_TYPE
		, 'Acute_MI' DIAGNOSIS_GROUP
		,dtd.DisplayString DIAGNOSIS_DESCRIPTION 
		,da.DateValue DIAGNOSIS_ENTRY_DATE
from #MSD61COVID19_COHORT co
			 join DiagnosisEventFact  def on (co.PatientDurableKey = def.PatientDurableKey
			                                 and def.Type = 'Problem List' 
											 and def.StartDateKey <= co.DateKey
											 and (def.EndDateKey >= co.DateKey or def.EndDateKey <0)
											 and  def.status = 'Active'
										 ) 
			 join DiagnosisDim dd on (def.DiagnosisKey = dd.DiagnosisKey)
			 join DiagnosisTerminologyDim dtd on (dd.DiagnosisKey = dtd.DiagnosisKey
												   and dtd.Type = 'ICD-10-CM' 
												   and dtd.Value like 'I21%'
												   )  
			 join DateDim da on (def.StartDateKey = da.DateKey)
			              union
select  distinct co.mrn 
        ,co.EncounterEpicCsn 
		,'Encounter Diagnosis' DIAGNOSIS_TYPE
		, 'Acute_MI' DIAGNOSIS_GROUP
		,dtd.DisplayString DIAGNOSIS_DESCRIPTION 
		,da.DateValue DIAGNOSIS_ENTRY_DATE
from #MSD61COVID19_COHORT co
			 join DiagnosisEventFact  def on (co.EncounterKey = def.EncounterKey
			                                 and def.Type = 'Encounter Diagnosis')
			 join DiagnosisDim dd on (def.DiagnosisKey = dd.DiagnosisKey)
			 join DiagnosisTerminologyDim dtd on (dd.DiagnosisKey = dtd.DiagnosisKey
												   and dtd.Type = 'ICD-10-CM' 
												   and dtd.Value like 'I21%'
												   ) 
			 join DateDim da on (def.StartDateKey = da.DateKey)			 
			 ;

SELECT * FROM #COVID61_DIAGNOSIS;