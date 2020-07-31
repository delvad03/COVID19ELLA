DROP TABLE IF EXISTS  #fltCOVID;
--Patient has an encounter with a particular EDG diagnosis ID 
SELECT distinct PD.PrimaryMrn mrn, ef.EncounterEpicCsn, ef.EncounterKey,'Diagnosis' SOURCE  INTO #fltCOVID
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
(123,345,678)  --********EncounterEpicCsn is PHI (Replace with required EncounterEpicCsn for MRNs from Department of Health) ********
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


DROP TABLE  if exists #cohortCOVID;
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
CAST(NULL AS NVARCHAR(500)) AS DATE_OF_FIRST_AZITHROMYCIN
INTO  #cohortCOVID
from   ENcounterFact ef  inner join PatientDim pd on ef.PatientDurableKey = Pd.DurableKey 
		inner join DurationDim dd on ef.AgeKey = dd.DurationKey
		INNER JOIN #fltCOVID COV ON COV.EncounterKey = EF.EncounterKey
		and Pd.ISCURRENT =1 and pd.IsValid = 1
and ef.EncounterEpicCsn is not null
and pd.primarymrn !='*Not Applicable'
and pd.primarymrn NOT LIKE '%TMP%';

 
 --LABS
DROP TABLE IF exists #LAB_NAMES;
SELECT	DISTINCT LCD.LabComponentKey, LCD.LabComponentEpicId, LCD.Name AS LAB_NAMES,
		CASE
			 


			WHEN LabComponentEpicId IN (32721, 32930, 32931, 32933, 32935, 32936, 33098, 33012) THEN 'COVID-19 ANTIBODY ASSAY' 
			WHEN LabComponentEpicId IN (  28458, 22336, 25414, 27034, 31679, 32722, 23465) THEN 'INTERLEUKIN-6' ---
			WHEN   LabComponentEpicId IN (32725 , 6237, 28457)  THEN  'INTERLEUKIN 1 BETA'	
			WHEN   LabComponentEpicId IN (22331, 4508, 27101, 32724, 28460, 14142) THEN 'TNF ALPHA'		
			WHEN  LabComponentEpicId IN (32723, 28459, 14141, 3567)  THEN  'INTERLEUKIN 8'	
			WHEN LabComponentEpicId IN (3043, 18148, 22256, 10049, 9179, 31349)  THEN 'D-DIMER' ---
			WHEN LabComponentEpicId IN (12355, 3207, 14501,  18246, 25634 ) THEN 'FERRITIN' ---
			WHEN 	LabComponentEpicId IN (3629, 18498, 16536, 28319, 14592, 7676) THEN 	 'LDH'
			WHEN LabComponentEpicId IN (24406, 3211, 3210, 31493,  18250) THEN 'FIBRINOGEN' ---
			WHEN LabComponentEpicId IN (  11671, 8790, 11721,    22772,12142,  12062, 14446, 18123, 6325,  23473) THEN 'C-REACTIVE PROTEIN' ---
			WHEN LabComponentEpicId IN (2744, 18124, 9158)  THEN   'C-REATIVE PROTEIN HS'	
			WHEN LabComponentEpicId IN (30614, 26136, 10908, 27057, 28734)  THEN  'PROCALCITONIN'	
            WHEN LabComponentEpicId IN (4709, 8798, 19030, 182356, 21561, 14800) THEN 'WBC'  
			WHEN LabComponentEpicId IN (2707, 16402) THEN 'BLOOD CULTURE'
			WHEN LabComponentEpicId IN (2591, 14355, 12343, 8411, 13844, 32387, 2592, 15623, 25770) THEN 'AST'
			WHEN LabComponentEpicId IN (2484, 14330, 16473, 8405, 15047, 26452, 27723, 24298, 12351, 15624) THEN 'ALT'	
			WHEN LabComponentEpicId IN (17838, 7917, 12796, 27438, 25026) THEN 'Alkaline Phosphatase'	
			WHEN LabComponentEpicId IN (4319, 12320, 4692, 4691, 7201, 8463 ) THEN 'Sodium'	
			WHEN LabComponentEpicId IN ( 4115, 14808, 4751, 12321, 4690, 4112, 4689, 7202, 8457, 4110, 25612 ) THEN 'Potassium'	
			WHEN LabComponentEpicId IN (	5200, 5199, 14816, 10924, 10923, 6491, 6492, 14528, 14529 )	THEN 	'eGFR'
	        WHEN LabComponentEpicId IN ( 18369, 14101, 17194, 8438, 13927, 12200, 19461, 14543, 22254, 18341, 3377)   THEN 'Hemoglobin'
			WHEN LabComponentEpicId IN (14813, 12325, 12239,19482, 15621, 31728, 13846, 14375, 30882,4585, 4584, 4694, 8476) THEN 'BUN'	
			WHEN LabComponentEpicId IN (2991, 14811, 2988, 4670, 6485, 7755) THEN 'Serum Creatinine'			
			WHEN LabComponentEpicId IN ( 3698,17338, 3697, 19091, 23075, 6360) THEN   'LYMPHOCYTE #'
			WHEN LabComponentEpicId IN ( 3699, 17337) THEN   'LYMPHOCYTE (%)'
			WHEN LabComponentEpicId IN ( 3138, 9998, 3137, 6363, 18215,17113, 19086, 23077, 23082 ,9311) THEN   'EOSINOPHIL #'
			WHEN LabComponentEpicId IN ( 3139, 18214) THEN   'EOSINOPHIL (%)'
			WHEN LabComponentEpicId IN ( 2644, 8795, 6364, 16920, 19083, 23078, 23083, 2643) THEN   'BASOPHIL #'
			WHEN LabComponentEpicId IN ( 2645, 16919) THEN   'BASOPHIL (%)'
			WHEN LabComponentEpicId IN ( 3798, 8451, 3797, 19099, 23081,6362,17393, 9310) THEN   'MONOCYTE #'
			WHEN LabComponentEpicId IN ( 3799, 17392) THEN   'MONOCYTE (%)'
			WHEN LabComponentEpicId IN ( 3857, 8821, 19105, 8712, 23079, 6357, 23074, 17417, 19064) THEN   'NEUTROPHIL #'
			WHEN LabComponentEpicId IN ( 3858, 17416) THEN   'NEUTROPHIL (%)'
			WHEN LabComponentEpicId IN ( 4063, 18731, 4081, 17520, 21565, 22257, 9877, 32389, 13847) THEN   'PLATELET'
			WHEN LabComponentEpicId IN ( 3370, 3371, 3375, 8437) THEN   'HEMATOCRIT'
			WHEN LabComponentEpicId IN ( 4492, 14807, 21393) THEN   'TROPONIN I'
			WHEN LabComponentEpicId IN ( 22355, 22354, 22356, 24614, 24613, 27293) THEN   'ANTICARDIOLIPIN ANTIBODY'
			WHEN LabComponentEpicId IN ( 22374, 22360, 22361, 24797, 24798, 25155, 24617, 24615, 24616, 13495, 13494,13493) THEN   'BETA-2 GLYCOPROTEIN I ANTIBODY'
			WHEN LabComponentEpicId IN ( 2520, 2521) THEN   'PHOSPHOLIPID ANTIBODY'
			WHEN LabComponentEpicId IN ( 3142, 18217, 8836, 6956, 22140) THEN   'ESR'
			WHEN LabComponentEpicId IN ( 8524, 17946) THEN   'BRAIN NATRIURETIC PROTEIN'
			WHEN LabComponentEpicId IN ( 3733, 18551, 6298) THEN   'MCV'
			WHEN LabComponentEpicId IN ( 3731, 18548, 6310) THEN   'MCH'
			WHEN LabComponentEpicId IN ( 3732, 18550, 6311) THEN   'MCHC'
			WHEN LabComponentEpicId IN ( 3734, 18587, 18588, 6313, 12210) THEN   'MEAN PLATELET VOLUME (MPV)'
			WHEN LabComponentEpicId IN ( 4233, 18799, 8589) THEN   'RBC COUNT'
			WHEN LabComponentEpicId IN ( 2564, 17884, 22206, 23884, 22264) THEN   'PTT'
			WHEN LabComponentEpicId IN ( 26587, 18776, 4129, 4165, 24605, 22260) THEN   'PROTHROMBIN TIME'
			WHEN LabComponentEpicId IN ( 3549, 18436, 3553, 3550, 25717, 24606, 3552) THEN   'INR'
			WHEN LabComponentEpicId IN ( 2444, 11792, 2446, 22065, 27837, 24587) THEN   'ALBUMIN'
			WHEN LabComponentEpicId IN ( 2767, 14812, 30198, 12218) THEN   'CALCIUM'
			WHEN LabComponentEpicId IN ( 4587, 18988, 7475) THEN   'URIC ACID'
			WHEN LabComponentEpicId IN ( 2685, 14817, 26450, 24295, 27721, 22195, 19760) THEN   'TOTAL BILIRUBIN'
			WHEN LabComponentEpicId IN ( 4024, 21488, 19110, 4023, 14277) THEN   'PH ARTERIAL'
			WHEN LabComponentEpicId IN ( 21471, 4025, 4026, 18700, 18713, 14100, 14285) THEN   'PH VENOUS'
			WHEN LabComponentEpicId IN ( 4019) THEN   'PH CAPILLARY'
			WHEN LabComponentEpicId IN ( 21472, 3962, 3963, 18680, 14105, 14286) THEN   'PC02 VENOUS'
			WHEN LabComponentEpicId IN ( 3961, 21489, 19109, 3960, 14278) THEN   'PCO2 ARTERIAL'
			WHEN LabComponentEpicId IN ( 3959) THEN   'PCO2 CAPILLARY'
			WHEN LabComponentEpicId IN ( 21473, 4092, 4093, 18735, 14287, 14107) THEN   'PO2 VENOUS'
			WHEN LabComponentEpicId IN ( 21490, 4091, 19111, 4090, 14093, 14279) THEN   'PO2 ARTERIAL'
			WHEN LabComponentEpicId IN ( 2630, 14095, 14281) THEN   'BASE EXCESS ARTERIAL'
			WHEN LabComponentEpicId IN ( 2631,  17917) THEN   'BASE EXCESS VENOUS'
			WHEN LabComponentEpicId IN ( 3883, 21500, 19108, 3885, 14097) THEN   'O2 SATURATION ARTERIAL'
			WHEN LabComponentEpicId IN ( 21479, 3886, 3881, 18633, 14108, 14291) THEN   'O2 SATURATION VENOUS'
			WHEN LabComponentEpicId IN ( 3882) THEN   'O2 SATURATION CAPILLARY'
			WHEN LabComponentEpicId IN ( 3354, 21495, 3353, 14094, 14280) THEN   'HCO3 ARTERIAL'
			WHEN LabComponentEpicId IN ( 21476,  3355,  3356,  14111,  14288) THEN   'HCO3 VENOUS'
			WHEN LabComponentEpicId IN ( 3352) THEN   'HCO3 CAPILLARY'
 			WHEN LabComponentEpicId IN ( 3285, 14809, 8435, 12251, 14534, 22231, 24436, 22451, 18290, 22248,5304, 16210, 24326, 4673, 21498, 4671, 4675, 4672, 4674) THEN   'GLUCOSE'
			WHEN LabComponentEpicId IN ( 2844, 14815, 32123, 12322, 4666, 32135, 5885, 4665, 7203, 32126, 8424) THEN   'CHLORIDE'
			WHEN LabComponentEpicId IN ( 2983, 18111, 21449, 27456) THEN   'CREATINE_KINASE'
			WHEN LabComponentEpicId IN ( 31041, 14814, 32124, 32130, 16482, 32127, 12329, 11664) THEN   'ANION_GAP'
			WHEN LabComponentEpicId IN ( 16233, 16232, 4980, 19778, 19779, 19844, 19843, 30590, 30591, 12307, 12306, 31308, 31307, 32535, 23503, 23502, 26157, 26153, 21763, 21764, 9328) THEN   'INFLUENZA_A_AND_B'
			WHEN LabComponentEpicId IN ( 16239, 19780, 19849, 30592, 12313, 19705, 19707) THEN   'RSV'
			WHEN LabComponentEpicId IN ( 4883, 21392, 17005, 5887) THEN   'CREATINE_KINASE_MB'
			WHEN LabComponentEpicId IN ( 4683, 21499, 4681, 14284) THEN   'LACTATE_ARTERIAL'
			WHEN LabComponentEpicId IN ( 32773 ) THEN   'QUANTITATIVE COVID-19 ANTIBODIES'
			WHEN LabComponentEpicId IN ( 8606, 8612, 8625, 8589 ) THEN   'TRANSFUSION_RBC'
			WHEN LabComponentEpicId IN ( 8648,11935,15706,11956,11954,8586,14826 ) THEN 'TRANSFUSION_PLA'
			WHEN LabComponentEpicID IN (32136, 29460, 14099) THEN 'OXYHEMOGLOBIN_ARTERIAL'
			WHEN LabComponentEpicID IN (32137, 14102, 2787) THEN 'CARBOXYHEMOGLOBIN_ARTERIAL'
			WHEN LabComponentEpicID IN (32139, 14104) THEN 'DEOXYHEMOGLOBIN_ARTERIAL'
			WHEN LabComponentEpicID IN (32138, 14103, 3760) THEN 'METHEMOGLOBIN_ARTERIAL'
			WHEN LabComponentEpicID IN (32122, 3379) THEN 'HEMOGLOBIN_ARTERIAL'
			WHEN LabComponentEpicID IN (4162, 14819, 4161, 18865, 4774, 32359) THEN 'TOTAL_PROTEIN'
			WHEN LabComponentEpicID IN (13079, 3382, 18319, 3424, 30200, 27099, 8439, 30569, 10885, 11663, 30201) THEN 'HEMOGLOBIN_A1C'
			WHEN LabComponentEpicID IN (3344, 18316, 26448, 22807, 27719, 24299) THEN 'HAPTOGLOBIN'
			WHEN LabComponentEpicID IN (2785, 12345, 16464, 2888, 8421) THEN 'CO2_TOTAL'

		END AS LAB_NAME
		INTO #LAB_NAMES
FROM	LabComponentDim LCD 
WHERE    LCD.LabComponentEpicId IN 
(
	32721, 32930, 32931, 32933, 32935, 32936 , 33098, 33012, ------  COVID-19 ANTIBODY ASSAY
	28458, 22336, 25414, 27034, 31679, 32722, 23465,   --  Interleukin 6
	32725 , 6237, 28457  ,-----  'INTERLEUKIN 1 BETA'
	22331, 4508, 27101, 32724, 28460, 14142 ,-----   TNF ALPHA	
	32723, 28459, 14141, 3567,-----    INTERLEUKIN 8	
	3043, 18148, 22256, 10049, 9179, 31349,     --D-Dimer  ---	
	12355, 3207, 14501, 18246, 25634  , --FERRITIN  ---	
	3629, 18498, 16536, 28319, 14592, 7676 , --LDH  ---	
	24406, 3211, 3210, 31493,  18250,  --fibrinogen  ---	
	     11671, 8790, 11721,    22772,12142,  12062, 14446, 18123, 6325,  23473 ,  --- 'C-REACTIVE PROTEIN' 
	2744, 18124, 9158,-----   C-REATIVE PROTEIN HS
	30614, 26136, 10908, 27057, 28734,-----  PROCALCITONIN		
    4709, 8798, 19030, 182356, 21561, 14800, --WBC       
	2707, 16402,-----BLOOD CULTURE
	2591, 14355, 12343, 8411, 13844, 32387, 2592, 15623, 25770,-----AST
	2484, 14330, 16473, 8405, 15047, 26452, 27723, 24298, 12351, 15624 , -----ALT	
	17838, 7917, 12796, 27438, 25026, --- Alkaline Phosphatase 
	4319, 12320, 4692, 4691, 7201, 8463, ---'Sodium'	
	4115, 14808, 4751, 12321, 4690, 4112, 4689, 7202, 8457, 4110, 25612 ,---- 'Potassium'	
	5200, 5199, 14816, 10924, 10923, 6491, 6492, 14528, 14529,	 	-----	 eGFR
	18369, 14101, 17194, 8438, 13927, 12200, 19461, 14543, 22254, 18341,3377, --- Hemoglobin	
	14813, 12325, 12239,19482, 15621, 31728, 13846, 14375, 30882,4585, 4584, 4694, 8476, -----BUN
	2991, 14811, 2988, 4670, 6485, 7755  -----Serum Creatinine
,	3698,17338, 3697, 19091, 23075, 6360	 -----	Lymphocyte #
,	3699,17337	 -----	Lymphocyte (%)
,	3138, 9998, 3137, 6363, 18215, 17113, 19086, 23077, 23082 ,9311	 -----	Eosinophil #
,	3139,18214	 -----	Eosinophil (%)
,	2644, 8795, 6364, 16920, 19083, 23078, 23083, 2643	 -----	Basophil #
,	2645, 16919	 -----	Basophil (%)
,	3798, 8451, 3797, 19099, 23081, 6362,17393, 9310	 -----	Monocyte #
,	3799, 17392	 -----	Monocyte (%)
,	3857, 8821, 19105, 8712, 23079, 6357, 23074,17417, 19064	 -----	Neutrophil #
,	3858, 17416	 -----	Neutrophil (%)
,	4063, 18731, 4081, 17520, 21565, 22257, 9877, 32389, 13847	 -----	Platelet
,	3370, 3371, 3375, 8437	 -----	Hematocrit
,	4492, 14807, 21393	 -----	Troponin I
,	22355, 22354, 22356, 24614, 24613, 27293	 -----	Anticardiolipin Antibody
,	22374, 22360, 22361, 24797, 24798, 25155, 24617, 24615, 24616, 13495, 13494,13493	 -----	Beta-2 Glycoprotein I Antibody
,	2520, 2521	 -----	Phospholipid Antibody
,	3142, 18217, 8836, 6956, 22140	 -----	ESR
,	8524, 17946	 -----	Brain Natriuretic Protein
,	3733, 18551, 6298	 -----	MCV
,	3731, 18548, 6310	 -----	MCH
,	3732, 18550, 6311	 -----	MCHC
,	3734, 18587, 18588, 6313, 12210	 -----	Mean Platelet Volume (MPV)
,	4233, 18799, 8589	 -----	RBC Count
,	2564, 17884, 22206, 23884, 22264	 -----	PTT
,	26587, 18776, 4129, 4165, 24605, 22260	 -----	Prothrombin Time
,	3549, 18436, 3553, 3550, 25717, 24606, 3552	 -----	INR
,	2444, 11792, 2446, 22065, 27837, 24587	 -----	Albumin
,	2767, 14812, 30198, 12218	 -----	Calcium
,	4587, 18988, 7475	 -----	Uric Acid
,	2685, 14817, 26450, 24295, 27721, 22195, 19760	 -----	Total Bilirubin
,	4024, 21488, 19110, 4023, 14277	 -----	pH Arterial
,	21471, 4025, 4026, 18700, 18713, 14100, 14285	 -----	pH Venous
,	4019	 -----	pH Capillary
,	21472, 3962, 3963, 18680, 14105, 14286	 -----	pC02 Venous
,	3961, 21489, 19109, 3960, 14278	 -----	pCO2 Arterial
,	3959	 -----	pCO2 Capillary
,	21473, 4092, 4093, 18735, 14287, 14107	 -----	pO2 Venous
,	21490, 4091, 19111, 4090, 14093, 14279	 -----	pO2 Arterial
,	2630, 14095, 14281	 -----	Base Excess Arterial
,	2631,  17917	 -----	Base Excess Venous
,	3883, 21500, 19108, 3885, 14097	 -----	O2 Saturation Arterial
,	21479, 3886, 3881, 18633, 14108, 14291	 -----	O2 Saturation Venous
,	3882	 -----	O2 Saturation Capillary
,	3354, 21495, 3353, 14094, 14280	 -----	HCO3 Arterial
,	21476,  3355,  3356,  14111,  14288	 -----	HCO3 Venous
,	3352	 -----	HCO3 Capillary
,   3285, 14809, 8435, 12251, 14534, 22231, 24436, 22451, 18290, 22248,5304, 16210, 24326, 4673, 21498, 4671, 4675, 4672, 4674 ---   'GLUCOSE'  
,   2844, 14815, 32123, 12322, 4666, 32135, 5885, 4665, 7203, 32126, 8424 ---   'CHLORIDE'
,   2983, 18111, 21449, 27456 ---   'CREATINE_KINASE'
,   31041, 14814, 32124, 32130, 16482, 32127, 12329, 11664 ---   'ANION_GAP'
,   16233, 16232, 4980, 19778, 19779, 19844, 19843, 30590, 30591, 12307, 12306, 31308, 31307, 32535, 23503, 23502, 26157, 26153, 21763, 21764, 9328 ---   'INFLUENZA_A_AND_B'
,   16239, 19780, 19849, 30592, 12313, 19705, 19707 ---   'RSV'
,   4883, 21392, 17005, 5887 --- 'CREATINE_KINASE_MB'
,   4683, 21499, 4681, 14284 --- 'LACTATE_ARTERIAL'
,   32773                    --- 'QUANTITATIVE COVID-19 ANTIBODIES'
,   8606, 8612, 8625, 8589   ---  'TRANSFUSION_RBC'
,   8648,11935,15706,11956,11954,8586,14826 --- 'TRANSFUSION_PLA'
,   32136, 29460, 14099 -- OXYHEMOGLOBIN_ARTERIAL
,   32137, 14102, 2787  -- CARBOXYHEMOGLOBIN_ARTERIAL
,   32139, 14104        -- DEOXYHEMOGLOBIN_ARTERIAL
,   32138, 14103, 3760  -- METHEMOGLOBIN_ARTERIAL
,   32122, 3379         -- HEMOGLOBIN_ARTERIAL
,   4162, 14819, 4161, 18865, 4774, 32359 --'TOTAL_PROTEIN'
,   13079, 3382, 18319, 3424, 30200, 27099, 8439, 30569, 10885, 11663, 30201 -- 'HEMOGLOBIN_A1C'
,   3344, 18316, 26448, 22807, 27719, 24299 -- 'HAPTOGLOBIN'
,   2785, 12345, 16464, 2888, 8421 -- 'CO2_TOTAL'
); 

DROP TABLE IF EXISTS #TEMP_COVID_LAB;
SELECT * INTO #TEMP_COVID_LAB FROM (
SELECT	DISTINCT  C.MRN, C.EncounterEpicCsn, C.EncounterKey, C.ENCOUNTERDATE,
case 
when 
ln.LabComponentEpicID IN (8648,11935,15706) OR (ln.LabComponentEpicId='14826' AND
f.Value IN ('LPL','FFP5','FP1','FPHER')) then 'TRANSFUSION_PLASMA'
when ln.LabComponentEpicID IN (11956,11954,8586) OR (ln.LabComponentEpicId= 14826 AND f.Value in ('PL2I','PLI','PL1I','PL3I','PPL1','PPL3','PPL2'))
then 'TRANSFUSION_PLATELETS'
else
upper (ln.LAB_NAME) end as LAB_NAME   ,
pd.name  procedure_name, 
lcd.name LabComponent ,
f.value  LAB_RESULT,
F.NumericValue  Numeric_LAB_RESULT, 
f.unit,
f.ResultStatus,
CONVERT(datetime, convert(varchar(10), F.ResultDateKey)) Result_date ,
tod.TimeValue Result_Time  , 
CONVERT(datetime, convert(varchar(10), F.OrderedDateKey)) Order_date,
 tod2.TimeValue Order_Time ,
 lcd.type LAB_COMPONENT_TYPE 
FROM	#cohortCOVID C 
INNER JOIN LabComponentResultFact F ON (C.encounterkey = F.EncounterKey)  
INNER JOIN #LAB_NAMES ln ON (F.LabComponentKey = ln.LabComponentKey)
INNER JOIN LabComponentDim lcd on lcd.LabComponentKey  = f.LabComponentKey 
INNER JOIN   datedim dd on dd.DateKey   =   F.ResultDateKey
INNER JOIN TimeOfDayDim tod on tod.TimeOfDayKey = f.ResultTimeOfDayKey
INNER JOIN TimeOfDayDim tod2 on tod2.TimeOfDayKey = f.OrderedTimeOfDayKey
INNER JOIN ProcedureDim pd on pd.DurableKey  = f.ProcedureDurableKey 
WHERE	F.ResultDateKey NOT IN (-1, -2, -3)
 ) A
ORDER BY 1;

 --- RESULT 
 select  MRN ,	EncounterEpicCsn,	ENCOUNTERDATE	,Lab_Order	,Order_date	,LabComponent	,LAB_RESULT,	Numeric_LAB_RESULT,	unit,	ResultStatus	,Result_date ,LAB_COMPONENT_TYPE   
 
 from 
 (
 select a.* ,
 row_number ()  over (partition by MRN,ORDER_DATE,LabComponent,	RESULT_DATE,	Numeric_LAB_RESULT	 
order by MRN,ORDER_DATE,Lab_Order,LabComponent,	RESULT_DATE,	Numeric_LAB_RESULT  )   rnk 
  from 
 (
select  
distinct 
MRN,
EncounterEpicCsn,
ENCOUNTERDATE,
procedure_name Lab_Order, 
cast ( substring ( convert (varchar , a.Order_date  , 120) ,1, 10)     +' '+	cast (Order_Time as char(10)) as varchar (30)) Order_date ,
LabComponent,
LAB_RESULT,
Numeric_LAB_RESULT,
unit,
ResultStatus,
cast (   substring ( convert (varchar ,Result_date  , 120) ,1, 10)      +' '+	cast (Result_Time as char(10)) as varchar (30)) 	Result_date  
,lab_name  LAB_COMPONENT_TYPE    
from  #TEMP_COVID_LAB  a
inner join patientdim p on a.mrn  = p.PrimaryMrn  and  p.iscurrent = 1
) a )aa
where aa.rnk  = 1
and aa.LAB_COMPONENT_TYPE <>  'TRANSFUSION_PLA';