data cohort;
set out_data.cohort_june;
where died ne 2;
run;
*n=1,484;

data cohort_2;
	set cohort;
		if (-1<Time_from_ELLA_to_last_follow_up<0) then Time_from_ELLA_to_last_follow_up=0;
data cohort_2;
	set cohort_2;
	where (Time_from_ELLA_to_last_follow_up>=0);
run;
*n=1,311;

data cohort_2;
	set cohort_2;
	where SARS_PCR=1;
	run;


DATA VALID_1;
	SET out_data.cohort_VALID;
	WHERE DIED NE .;
		if (-1<Time_from_ELLA_to_last_follow_up<0) then Time_from_ELLA_to_last_follow_up=0;
data VALID_2;
	set VALID_1;
	where (Time_from_ELLA_to_last_follow_up>=0);
run;
*n=719;

data VALID_3(KEEP=Time_from_ELLA_to_last_follow_up died TNF_A_BIN IL_6_BIN IL_8_BIN IL_1b_BIN gender age_grp race_eth diabetes 
		htn smoke ckd asthma copd chf atrial_fibrillation cancer_flag sleep_apnea
		bmi_3);
	set VALID_2;
	where SARS_PCR=1;
	run;
DATA VALID_3;
	SET VALID_3;
	IF CMISS(OF _ALL_) THEN DELETE;
	IF NMISS(OF _ALL_) THEN DELETE;
RUN;

data valid_4(keep=MRN Time_from_ELLA_to_last_follow_up died tnf_a_bin IL_6_bin IL_8_bin IL_1b_bin
		gender age_grp race_eth diabetes 
		htn smoke ckd asthma chf atrial_fibrillation copd cancer_flag sleep_apnea bmi_3
		severity_numeric
		SYSTOL_BP_MAX
		O2SAT_MIN
		D_DIMER_log2
		ALBUMIN
		CALCIUM
		CHLORIDE
		PLATELET);
	set VALID_2;
	where SARS_PCR=1;
	run;
DATA VALID_4;
	SET VALID_4;
	IF CMISS(OF _ALL_) THEN DELETE;
	IF NMISS(OF _ALL_) THEN DELETE;
RUN;

ods _all_ close; 
ods pdf file="&doc.Results_for_external_validity_%sysfunc(date(),date9.).pdf";
ods html path= "&doc." (url=none) file="Results_for_external_validity_%sysfunc(date(),date9.).xls";

proc phreg data=cohort_2 plots(overlay=individual)=roc rocoptions(at=2 4 6 9);
title "COX model: ALL CYTOKINES";
	class TNF_A_BIN(ref="Low") IL_6_BIN(ref="Low") IL_8_BIN(ref="Low") IL_1b_BIN(ref="Low") 
	gender(ref="c. Male") age_grp(ref=">70") race_eth(ref="d. NH White")
	diabetes(ref="c. No") htn(ref="c. No") smoke(ref="d. Non-smoker") ckd(ref="c. No") 
	asthma(ref="c. No") copd(ref="c. No")  atrial_fibrillation(ref="c. No")
	chf(ref="c. No") cancer_flag(ref="c. No") bmi_3(ref="BMI<=30")
	 sleep_apnea(ref="c. No") /*severity_numeric(ref="1")*/
	/param=glm;
   model Time_from_ELLA_to_last_follow_up*died(0)= TNF_A_BIN IL_6_BIN IL_8_BIN IL_1b_BIN gender age_grp race_eth diabetes 
		htn smoke ckd asthma copd chf atrial_fibrillation cancer_flag sleep_apnea
		bmi_3 /*severity_numeric*/
		/*SYSTOL_BP_MAX O2SAT_MIN D_DIMER_log2 ALBUMIN CALCIUM CHLORIDE PLATELET*/
		/risklimits=WALD;
  baseline OUT = EXT_VALID_1
 COVARIATES = VALID_3 SURVIVAL=_ALL_  XBETA=y;

run;

proc phreg data=EXT_VALID_1 plots(overlay=individual)=roc rocoptions(at=5 12 17 26);;
title "COX model: ALL CYTOKINES";
	class TNF_A_BIN(ref="Low") IL_6_BIN(ref="Low") IL_8_BIN(ref="Low") IL_1b_BIN(ref="Low") 
	gender(ref="c. Male") age_grp(ref=">70") race_eth(ref="d. NH White")
	diabetes(ref="c. No") htn(ref="c. No") smoke(ref="d. Non-smoker") ckd(ref="c. No") 
	asthma(ref="c. No") copd(ref="c. No")  atrial_fibrillation(ref="c. No")
	chf(ref="c. No") cancer_flag(ref="c. No") bmi_3(ref="BMI<=30")
	 sleep_apnea(ref="c. No") /*severity_numeric(ref="1")*/
	/param=glm;
   model Time_from_ELLA_to_last_follow_up*died(0)= TNF_A_BIN IL_6_BIN IL_8_BIN IL_1b_BIN gender age_grp race_eth diabetes 
		htn smoke ckd asthma copd chf atrial_fibrillation cancer_flag sleep_apnea
		bmi_3 /*severity_numeric*/
		/*SYSTOL_BP_MAX O2SAT_MIN D_DIMER_log2 ALBUMIN CALCIUM CHLORIDE PLATELET*/
		/risklimits=WALD;
	roc 'Predicted' pred=Y;

run;

proc phreg data=EXT_VALID_1 plots(overlay=individual)=roc rocoptions(at=5 12 17 26);;
title "COX model: ALL CYTOKINES";
   model Time_from_ELLA_to_last_follow_up*died(0)= Y
		/risklimits=WALD;
	roc 'Predicted' pred=Y;

run;



proc phreg data=cohort_2 plots(overlay=individual)=roc rocoptions(at=2 4 6 9);
title "COX model: ALL CYTOKINES";
	class 
	TNF_a_bin(ref="Low") IL_6_bin(ref="Low") IL_8_bin(ref="Low") IL_1b_bin(ref="Low") 
	gender(ref="c. Male") age_grp(ref=">70") race_eth(ref="d. NH White")
	diabetes(ref="c. No") htn(ref="c. No") smoke(ref="d. Non-smoker") ckd(ref="c. No") 
	asthma(ref="c. No") copd(ref="c. No")  atrial_fibrillation(ref="c. No")
	chf(ref="c. No") cancer_flag(ref="c. No") bmi_3(ref="BMI<=30") sleep_apnea(ref="c. No")
	severity_numeric(ref="1")
	/param=glm;
   model Time_from_ELLA_to_last_follow_up*died(0)= tnf_a_bin IL_6_bin IL_8_bin IL_1b_bin
		gender age_grp race_eth diabetes 
		htn smoke ckd asthma chf atrial_fibrillation copd cancer_flag sleep_apnea bmi_3
		severity_numeric
		SYSTOL_BP_MAX
		O2SAT_MIN
		D_DIMER_log2
		ALBUMIN
		CALCIUM
		CHLORIDE
		PLATELET/risklimits=WALD;
  baseline OUT = EXT_VALID_2
 COVARIATES = VALID_4 SURVIVAL=_ALL_  XBETA=y;

run;

proc phreg data=EXT_VALID_2 plots(overlay=individual)=roc rocoptions(at=5 12 17 26);;
title "COX model: ALL CYTOKINES";
	class 
	TNF_a_bin(ref="Low") IL_6_bin(ref="Low") IL_8_bin(ref="Low") IL_1b_bin(ref="Low") 
	gender(ref="c. Male") age_grp(ref=">70") race_eth(ref="d. NH White")
	diabetes(ref="c. No") htn(ref="c. No") smoke(ref="d. Non-smoker") ckd(ref="c. No") 
	asthma(ref="c. No") copd(ref="c. No")  atrial_fibrillation(ref="c. No")
	chf(ref="c. No") cancer_flag(ref="c. No") bmi_3(ref="BMI<=30") sleep_apnea(ref="c. No")
	severity_numeric(ref="1")
	/param=glm;
   model Time_from_ELLA_to_last_follow_up*died(0)= tnf_a_bin IL_6_bin IL_8_bin IL_1b_bin
		gender age_grp race_eth diabetes 
		htn smoke ckd asthma chf atrial_fibrillation copd cancer_flag sleep_apnea bmi_3
		severity_numeric
		SYSTOL_BP_MAX
		O2SAT_MIN
		D_DIMER_log2
		ALBUMIN
		CALCIUM
		CHLORIDE
		PLATELET/risklimits=WALD;
	roc 'Predicted' pred=Y;

run;


proc phreg data=EXT_VALID_2 plots(overlay=individual)=roc rocoptions(at=5 12 17 26);;
title "COX model: ALL CYTOKINES";
   model Time_from_ELLA_to_last_follow_up*died(0)= Y/risklimits=WALD;

run;
ods pdf close;
ods html close;
ods html;
