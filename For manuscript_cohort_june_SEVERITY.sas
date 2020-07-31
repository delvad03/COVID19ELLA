
/*After Backward selection*/
data cohort;
set out_data.cohort_june;
run;
*n=1,484;
/*
data cohort;
	set cohort;
	if age_grp=4 then age_grp=.;
	if htn=2 then htn=.;
	if ckd=2 then ckd=.;
	if asthma=2 then asthma=.;
	if chf=2 then chf=.;
	if atrial_fibrillation=2 then atrial_fibrillation=.;
	if diabetes=2 then diabetes=.;
	if sleep_apnea=2 then sleep_apnea=.;
	if copd=2 then copd=.;
	*if BMI_3=3 then bmi_3=.;
	if cancer_flag=2 then cancer_flag=.;
run;*/
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
*N=1128;
*for figure 3 only survival curves;
proc phreg data=cohort_2 plots(overlay cl)=survival;
title "COX model: TNF-a";
	class TNF_A_BIN(ref="Low") 
	gender(ref="c. Male") age_grp(ref="<50") race_eth(ref="d. NH White")
	diabetes(ref="c. No") htn(ref="c. No") smoke(ref="d. Non-smoker") ckd(ref="c. No") 
	asthma(ref="c. No") copd(ref="c. No")  atrial_fibrillation(ref="c. No")
	chf(ref="c. No") cancer_flag(ref="c. No") bmi_3(ref="BMI<=30")
	 sleep_apnea(ref="c. No") /*severity_numeric(ref="1")*/
	/param=glm;
   model Time_from_ELLA_to_last_follow_up*died(0)= TNF_A_BIN gender age_grp race_eth diabetes 
		htn smoke ckd asthma copd chf atrial_fibrillation cancer_flag sleep_apnea
		bmi_3 /*severity_numeric*/
		/*SYSTOL_BP_MAX O2SAT_MIN D_DIMER_log2 ALBUMIN CALCIUM CHLORIDE PLATELET*/
		/risklimits=WALD;
   baseline OUT = TNF_a_fig3 SURVIVAL = Surv_Prob L=LCL U=UCL
 COVARIATES = cohort_2 SURVIVAL=_ALL_/DIRADJ group=TNF_A_BIN;
   *lsmeans &ind_var gender age_grp race_eth htn smoke ckd asthma
	chf atrial_fibrillation SARS_PCR/diff exp cl ADJUST=BON;
run;

proc phreg data=cohort_2 plots(overlay cl)=survival;
title "COX model: IL-6";
	class IL_6_BIN(ref="Low") 
	gender(ref="c. Male") age_grp(ref="<50") race_eth(ref="d. NH White")
	diabetes(ref="c. No") htn(ref="c. No") smoke(ref="d. Non-smoker") ckd(ref="c. No") 
	asthma(ref="c. No") copd(ref="c. No")  atrial_fibrillation(ref="c. No")
	chf(ref="c. No") cancer_flag(ref="c. No") bmi_3(ref="BMI<=30")
	 sleep_apnea(ref="c. No") /*severity_numeric(ref="1")*/
	/param=glm;
   model Time_from_ELLA_to_last_follow_up*died(0)= IL_6_BIN gender age_grp race_eth diabetes 
		htn smoke ckd asthma copd chf atrial_fibrillation cancer_flag sleep_apnea
		bmi_3 /*severity_numeric*/
		/*SYSTOL_BP_MAX O2SAT_MIN D_DIMER_log2 ALBUMIN CALCIUM CHLORIDE PLATELET*/
		/risklimits=WALD;
   baseline OUT = IL_6_fig3 SURVIVAL = Surv_Prob L=LCL U=UCL
 COVARIATES = cohort_2 SURVIVAL=_ALL_/DIRADJ group=IL_6_BIN;
   *lsmeans &ind_var gender age_grp race_eth htn smoke ckd asthma
	chf atrial_fibrillation SARS_PCR/diff exp cl ADJUST=BON;
run;


proc phreg data=cohort_2 plots(overlay cl)=survival;
title "COX model: IL-8";
	class IL_8_BIN(ref="Low") 
	gender(ref="c. Male") age_grp(ref="<50") race_eth(ref="d. NH White")
	diabetes(ref="c. No") htn(ref="c. No") smoke(ref="d. Non-smoker") ckd(ref="c. No") 
	asthma(ref="c. No") copd(ref="c. No")  atrial_fibrillation(ref="c. No")
	chf(ref="c. No") cancer_flag(ref="c. No") bmi_3(ref="BMI<=30")
	 sleep_apnea(ref="c. No") /*severity_numeric(ref="1")*/
	/param=glm;
   model Time_from_ELLA_to_last_follow_up*died(0)= IL_8_BIN gender age_grp race_eth diabetes 
		htn smoke ckd asthma copd chf atrial_fibrillation cancer_flag sleep_apnea
		bmi_3 /*severity_numeric*/
		/*SYSTOL_BP_MAX O2SAT_MIN D_DIMER_log2 ALBUMIN CALCIUM CHLORIDE PLATELET*/
		/risklimits=WALD;
   baseline OUT = IL_8_fig3 SURVIVAL = Surv_Prob L=LCL U=UCL
 COVARIATES = cohort_2 SURVIVAL=_ALL_/DIRADJ group=IL_8_BIN;
   *lsmeans &ind_var gender age_grp race_eth htn smoke ckd asthma
	chf atrial_fibrillation SARS_PCR/diff exp cl ADJUST=BON;
run;


proc phreg data=cohort_2 plots(overlay cl)=survival;
title "COX model: IL-1b";
	class IL_1b_BIN(ref="Low") 
	gender(ref="c. Male") age_grp(ref="<50") race_eth(ref="d. NH White")
	diabetes(ref="c. No") htn(ref="c. No") smoke(ref="d. Non-smoker") ckd(ref="c. No") 
	asthma(ref="c. No") copd(ref="c. No")  atrial_fibrillation(ref="c. No")
	chf(ref="c. No") cancer_flag(ref="c. No") bmi_3(ref="BMI<=30")
	 sleep_apnea(ref="c. No") /*severity_numeric(ref="1")*/
	/param=glm;
   model Time_from_ELLA_to_last_follow_up*died(0)= IL_1b_BIN gender age_grp race_eth diabetes 
		htn smoke ckd asthma copd chf atrial_fibrillation cancer_flag sleep_apnea
		bmi_3 /*severity_numeric*/
		/*SYSTOL_BP_MAX O2SAT_MIN D_DIMER_log2 ALBUMIN CALCIUM CHLORIDE PLATELET*/
		/risklimits=WALD;
   baseline OUT = IL_1b_fig3 SURVIVAL = Surv_Prob L=LCL U=UCL
 COVARIATES = cohort_2 SURVIVAL=_ALL_/DIRADJ group=IL_1b_BIN;
   *lsmeans &ind_var gender age_grp race_eth htn smoke ckd asthma
	chf atrial_fibrillation SARS_PCR/diff exp cl ADJUST=BON;
run;

proc phreg data=cohort_2 plots(overlay cl)=survival;
title "COX model: ALL CYTOKINES";
	class TNF_A_BIN(ref="Low") IL_6_BIN(ref="Low") IL_8_BIN(ref="Low") IL_1b_BIN(ref="Low") 
	gender(ref="c. Male") age_grp(ref="<50") race_eth(ref="d. NH White")
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
  * baseline OUT = IL_1b_fig3 SURVIVAL = Surv_Prob L=LCL U=UCL
 COVARIATES = cohort_2 SURVIVAL=_ALL_/DIRADJ group=IL_1b_BIN;
   *lsmeans &ind_var gender age_grp race_eth htn smoke ckd asthma
	chf atrial_fibrillation SARS_PCR/diff exp cl ADJUST=BON;
run;


****************************************************************
*EXPORT TNF_A_FIG3 IL_6_FIG3 IL_8_FIG3 IL_1B_FIG3 FOR PLOTS    *
****************************************************************;
*for figure 3 only survival curves;

%macro surv_hr(data=, ind_var=);
data risk;
gender=1;
age_grp=3;
race_eth=0;
diabetes=0;
htn=0; 
smoke=0; 
ckd=0; 
asthma=0; 
chf=0; 
atrial_fibrillation=0; 
copd=0; 
sleep_apnea=0;
bmi_3=1;
cancer_flag=0;
*Severity_numeric=1; 
/*SYSTOL_BP_MAX=142.66;
O2SAT_MIN=90.72;
D_DIMER_log2=0.74;
ALBUMIN=3.01;
CALCIUM=8.45;
CHLORIDE=102.48;
PLATELET=244.43;*/
&ind_var=1; output;
&ind_var=0; output;

format gender sex_fmt. age_grp age_grp. race_eth race_eth. 
	htn copd diabetes cancer_flag ckd asthma chf atrial_fibrillation sleep_apnea bin_Fmt. 
	&ind_var hilo_fmt.
	bmi_3 bmi3_fmt.
	smoke smoke_fmt.;
run;


proc phreg data=&data;
title "COX model: &ind_var";
	class &ind_var(ref="Low") 
	gender(ref="c. Male") age_grp(ref="<50") race_eth(ref="d. NH White")
	diabetes(ref="c. No") htn(ref="c. No") smoke(ref="d. Non-smoker") ckd(ref="c. No") 
	asthma(ref="c. No") copd(ref="c. No")  atrial_fibrillation(ref="c. No")
	chf(ref="c. No") cancer_flag(ref="c. No") bmi_3(ref="BMI<=30")  sleep_apnea(ref="c. No")
	/*severity_numeric(ref="1")*/
	/param=glm;
   model Time_from_ELLA_to_last_follow_up*status(2)= &ind_var gender age_grp race_eth diabetes 
		htn smoke ckd asthma copd chf atrial_fibrillation cancer_flag sleep_apnea
		/*severity_numeric*/ bmi_3
		/*SYSTOL_BP_MAX O2SAT_MIN D_DIMER_log2 ALBUMIN CALCIUM CHLORIDE PLATELET*/
		/eventcode=1 risklimits=WALD;
   baseline OUT = &ind_var._CIF
 COVARIATES = risk CIF=_ALL_/group=&ind_var;
   *lsmeans &ind_var gender age_grp race_eth htn smoke ckd asthma
	chf atrial_fibrillation SARS_PCR/diff exp cl ADJUST=BON;
run;

data &ind_var._CIF;
	set &ind_var._CIF;
	keep &ind_var Time_from_ELLA_to_last_follow_up CIF lowerCIF upperCIF;
run;

%mend surv_hr;


%macro surv_hr_2(data=, ind_var=);
data risk;
crp_bin=0;
d_dimer_bin=0;
ferritin_bin=0;
gender=1;
age_grp=3;
race_eth=0;
diabetes=0;
htn=0; 
smoke=0; 
ckd=0; 
asthma=0; 
chf=0; 
atrial_fibrillation=0; 
copd=0; 
sleep_apnea=0;
bmi_3=1;
cancer_flag=0;
Severity_numeric=1; 
SYSTOL_BP_MAX=142.66;
O2SAT_MIN=90.72;
D_DIMER_log2=0.74;
ALBUMIN=3.01;
CALCIUM=8.45;
CHLORIDE=102.48;
PLATELET=244.43;
&ind_var=1; output;
&ind_var=0; output;

format gender sex_fmt. age_grp age_grp. race_eth race_eth. 
	htn copd diabetes cancer_flag ckd asthma chf atrial_fibrillation sleep_apnea bin_Fmt. 
	&ind_var crp_bin d_dimer_bin ferritin_bin hilo_fmt.
	bmi_3 bmi3_fmt.
	smoke smoke_fmt.;
run;



proc phreg data=&data plots(overlay cl)=survival;
title "COX model: &ind_var";
	class &ind_var(ref="Low") 
	CRP_bin(ref="Low") D_DIMER_BIN(ref="Low") FERRITIN_BIN(ref="Low")
	gender(ref="c. Male") age_grp(ref="<50") race_eth(ref="d. NH White")
	diabetes(ref="c. No") htn(ref="c. No") smoke(ref="d. Non-smoker") ckd(ref="c. No") 
	asthma(ref="c. No") copd(ref="c. No")  atrial_fibrillation(ref="c. No")
	chf(ref="c. No") cancer_flag(ref="c. No") bmi_3(ref="BMI<=30")
	 sleep_apnea(ref="c. No") severity_numeric(ref="1")
	/param=glm;
   model Time_from_ELLA_to_last_follow_up*died(0)= &ind_var 
   		crp_bin d_dimer_bin Ferritin_bin
		gender age_grp race_eth diabetes 
		htn smoke ckd asthma copd chf atrial_fibrillation cancer_flag sleep_apnea
		bmi_3 severity_numeric
		SYSTOL_BP_MAX O2SAT_MIN D_DIMER_log2 ALBUMIN CALCIUM CHLORIDE PLATELET
		/risklimits=WALD;
   baseline OUT = &ind_var._surv_2 SURVIVAL = Surv_Prob L=LCL U=UCL
 COVARIATES = &data SURVIVAL=_ALL_/DIRADJ group=&ind_var;
   *lsmeans &ind_var gender age_grp race_eth htn smoke ckd asthma
	chf atrial_fibrillation SARS_PCR/diff exp cl ADJUST=BON;
run;


proc phreg data=&data;
title "COX model: &ind_var";
	class &ind_var(ref="Low") 
	CRP_bin(ref="Low") D_DIMER_BIN(ref="Low") FERRITIN_BIN(ref="Low")
	gender(ref="c. Male") age_grp(ref="<50") race_eth(ref="d. NH White")
	diabetes(ref="c. No") htn(ref="c. No") smoke(ref="d. Non-smoker") ckd(ref="c. No") 
	asthma(ref="c. No") copd(ref="c. No")  atrial_fibrillation(ref="c. No")
	chf(ref="c. No") cancer_flag(ref="c. No") bmi_3(ref="BMI<=30")  sleep_apnea(ref="c. No")
	severity_numeric(ref="1")
	/param=glm;
   model Time_from_ELLA_to_last_follow_up*status(2)= &ind_var 
		crp_bin d_dimer_bin ferritin_bin
		gender age_grp race_eth diabetes 
		htn smoke ckd asthma copd chf atrial_fibrillation cancer_flag sleep_apnea
		severity_numeric bmi_3
		SYSTOL_BP_MAX O2SAT_MIN D_DIMER_log2 ALBUMIN CALCIUM CHLORIDE PLATELET
		/eventcode=1 risklimits=WALD;
   baseline OUT = &ind_var._CIF_2
 COVARIATES = risk CIF=_ALL_/group=&ind_var;
   *lsmeans &ind_var gender age_grp race_eth htn smoke ckd asthma
	chf atrial_fibrillation SARS_PCR/diff exp cl ADJUST=BON;
run;

data &ind_var._CIF_2;
	set &ind_var._CIF_2;
	keep &ind_var Time_from_ELLA_to_last_follow_up CIF lowerCIF upperCIF;
run;

%mend surv_hr_2;

*Stratifications;
%macro surv_strata(data=, ind_var=, strata=);
proc sort data=&data;
	by &strata;
run;

proc phreg data=&data;
title "COX model: &ind_var stratified by &strata";
strata &strata;
	class &ind_var(ref="Low") 
	gender(ref="c. Male") age_grp(ref="<50") race_eth(ref="d. NH White")
	diabetes(ref="c. No") htn(ref="c. No") smoke(ref="d. Non-smoker") ckd(ref="c. No") 
	asthma(ref="c. No") copd(ref="c. No")  atrial_fibrillation(ref="c. No")
	chf(ref="c. No") cancer_flag(ref="c. No") bmi_3(ref="BMI<=30") sleep_apnea(ref="c. No")
	severity_numeric(ref="1")
	/param=glm;
   model Time_from_ELLA_to_last_follow_up*status(2)= &ind_var gender age_grp race_eth diabetes 
		htn smoke ckd asthma chf atrial_fibrillation copd cancer_flag sleep_apnea
		severity_numeric 
		SYSTOL_BP_MAX D_DIMER_log2 ALBUMIN CALCIUM CHLORIDE PLATELET
	/eventcode=1 risklimits=WALD;
   baseline OUT = &ind_var._&strata._str SURVIVAL = Surv_Prob L=LCL U=UCL
  SURVIVAL=_ALL_/DIRADJ rowid=&strata group=&ind_var;
   *lsmeans &ind_var gender age_grp race_eth htn diabetes smoke ckd asthma 
		chf SARS_PCR/diff exp cl ADJUST=BON;
run;

%mend surv_strata;

ods _all_ close; 
ods pdf file="&doc.Results_for_manuscript_COHORT_JUNE_SEVERITY_%sysfunc(date(),date9.).pdf";
ods html path= "&doc." (url=none) file="Results_for_manuscript_COHORT_JUNE_SEVERITY_%sysfunc(date(),date9.).xls";


proc phreg data=cohort_2 plots(overlay cl)=survival;
title "COX model: all cytokines";
	class TNF_a_bin(ref="Low") IL_6_bin(ref="Low") IL_8_bin(ref="Low") IL_1b_bin(ref="Low") 
	gender(ref="c. Male") age_grp(ref="<50") race_eth(ref="d. NH White")
	diabetes(ref="c. No") htn(ref="c. No") smoke(ref="d. Non-smoker") ckd(ref="c. No") 
	asthma(ref="c. No") copd(ref="c. No")  atrial_fibrillation(ref="c. No")
	chf(ref="c. No") cancer_flag(ref="c. No") bmi_3(ref="BMI<=30")
	 sleep_apnea(ref="c. No") 
	/param=glm;
   model Time_from_ELLA_to_last_follow_up*died(0)= TNF_a_bin IL_6_bin IL_8_bin IL_1b_bin
		gender age_grp race_eth diabetes 
		htn smoke ckd asthma copd chf atrial_fibrillation cancer_flag sleep_apnea
		bmi_3
		/*SYSTOL_BP_MAX O2SAT_MIN D_DIMER_log2 ALBUMIN CALCIUM CHLORIDE PLATELET*/
		/risklimits=WALD;
   *baseline OUT = &ind_var._surv SURVIVAL = Surv_Prob L=LCL U=UCL
 COVARIATES = &data SURVIVAL=_ALL_/DIRADJ group=&ind_var;
   *lsmeans &ind_var gender age_grp race_eth htn smoke ckd asthma
	chf atrial_fibrillation SARS_PCR/diff exp cl ADJUST=BON;
run;


proc phreg data=cohort_2;
title "Competing risk model: All cytokines";
	class TNF_a_bin(ref="Low") IL_6_bin(ref="Low") IL_8_bin(ref="Low") IL_1b_bin(ref="Low") 
	gender(ref="c. Male") age_grp(ref="<50") race_eth(ref="d. NH White")
	diabetes(ref="c. No") htn(ref="c. No") smoke(ref="d. Non-smoker") ckd(ref="c. No") 
	asthma(ref="c. No") copd(ref="c. No")  atrial_fibrillation(ref="c. No")
	chf(ref="c. No") cancer_flag(ref="c. No") bmi_3(ref="BMI<=30")  sleep_apnea(ref="c. No")
	
	/param=glm;
   model Time_from_ELLA_to_last_follow_up*status(2)= TNF_a_bin IL_6_bin IL_8_bin IL_1b_bin
		gender age_grp race_eth diabetes 
		htn smoke ckd asthma copd chf atrial_fibrillation cancer_flag sleep_apnea
		bmi_3 
		/*SYSTOL_BP_MAX O2SAT_MIN D_DIMER_log2 ALBUMIN CALCIUM CHLORIDE PLATELET*/
		/eventcode=1 risklimits=WALD;
  *baseline OUT = &ind_var._CIF
 COVARIATES = risk CIF=_ALL_/group=&ind_var;
   *lsmeans &ind_var gender age_grp race_eth htn smoke ckd asthma
	chf atrial_fibrillation SARS_PCR/diff exp cl ADJUST=BON;
run;

%surv_hr(data=cohort_2, ind_var=TNF_a_bin);
%surv_hr(data=cohort_2, ind_var=IL_6_bin);
%surv_hr(data=cohort_2, ind_var=IL_8_bin);
%surv_hr(data=cohort_2, ind_var=IL_1b_bin);


proc phreg data=cohort_2 plots(overlay cl)=survival;
title "COX model: all cytokines+CRP D-dimer ferritin";
	class TNF_a_bin(ref="Low") IL_6_bin(ref="Low") IL_8_bin(ref="Low") IL_1b_bin(ref="Low") 
	CRP_bin(ref="Low") D_DIMER_BIN(ref="Low") FERRITIN_BIN(ref="Low")
	gender(ref="c. Male") age_grp(ref="<50") race_eth(ref="d. NH White")
	diabetes(ref="c. No") htn(ref="c. No") smoke(ref="d. Non-smoker") ckd(ref="c. No") 
	asthma(ref="c. No") copd(ref="c. No")  atrial_fibrillation(ref="c. No")
	chf(ref="c. No") cancer_flag(ref="c. No") bmi_3(ref="BMI<=30")
	 sleep_apnea(ref="c. No") 
	/param=glm;
   model Time_from_ELLA_to_last_follow_up*died(0)= TNF_a_bin IL_6_bin IL_8_bin IL_1b_bin
   		CRP_BIN D_DIMER_BIN FERRITIN_BIN
		gender age_grp race_eth diabetes 
		htn smoke ckd asthma copd chf atrial_fibrillation cancer_flag sleep_apnea
		bmi_3
		/*SYSTOL_BP_MAX O2SAT_MIN D_DIMER_log2 ALBUMIN CALCIUM CHLORIDE PLATELET*/
		/risklimits=WALD;
   *baseline OUT = &ind_var._surv SURVIVAL = Surv_Prob L=LCL U=UCL
 COVARIATES = &data SURVIVAL=_ALL_/DIRADJ group=&ind_var;
   *lsmeans &ind_var gender age_grp race_eth htn smoke ckd asthma
	chf atrial_fibrillation SARS_PCR/diff exp cl ADJUST=BON;
run;


proc phreg data=cohort_2;
title "Competing risk model: All cytokines+CRP D-dimer FERRITIN";
	class TNF_a_bin(ref="Low") IL_6_bin(ref="Low") IL_8_bin(ref="Low") IL_1b_bin(ref="Low") 
	CRP_bin(ref="Low") D_DIMER_BIN(ref="Low") FERRITIN_BIN(ref="Low")
	gender(ref="c. Male") age_grp(ref="<50") race_eth(ref="d. NH White")
	diabetes(ref="c. No") htn(ref="c. No") smoke(ref="d. Non-smoker") ckd(ref="c. No") 
	asthma(ref="c. No") copd(ref="c. No")  atrial_fibrillation(ref="c. No")
	chf(ref="c. No") cancer_flag(ref="c. No") bmi_3(ref="BMI<=30")  sleep_apnea(ref="c. No")
	
	/param=glm;
   model Time_from_ELLA_to_last_follow_up*status(2)= TNF_a_bin IL_6_bin IL_8_bin IL_1b_bin
		CRP_BIN D_DIMER_BIN FERRITIN_BIN
		gender age_grp race_eth diabetes 
		htn smoke ckd asthma copd chf atrial_fibrillation cancer_flag sleep_apnea
		bmi_3 
		/*SYSTOL_BP_MAX O2SAT_MIN D_DIMER_log2 ALBUMIN CALCIUM CHLORIDE PLATELET*/
		/eventcode=1 risklimits=WALD;
  *baseline OUT = &ind_var._CIF
 COVARIATES = risk CIF=_ALL_/group=&ind_var;
   *lsmeans &ind_var gender age_grp race_eth htn smoke ckd asthma
	chf atrial_fibrillation SARS_PCR/diff exp cl ADJUST=BON;
run;

%surv_hr_2(data=cohort_2, ind_var=TNF_a_bin);
%surv_hr_2(data=cohort_2, ind_var=IL_6_bin);
%surv_hr_2(data=cohort_2, ind_var=IL_8_bin);
%surv_hr_2(data=cohort_2, ind_var=IL_1b_bin);

proc phreg data=cohort_2 plots(overlay cl)=survival;
title "COX model: all cytokines+CRP D-dimer ferritin severity scores";
	class TNF_a_bin(ref="Low") IL_6_bin(ref="Low") IL_8_bin(ref="Low") IL_1b_bin(ref="Low") 
	CRP_bin(ref="Low") D_DIMER_BIN(ref="Low") FERRITIN_BIN(ref="Low")
	gender(ref="c. Male") age_grp(ref="<50") race_eth(ref="d. NH White")
	diabetes(ref="c. No") htn(ref="c. No") smoke(ref="d. Non-smoker") ckd(ref="c. No") 
	asthma(ref="c. No") copd(ref="c. No")  atrial_fibrillation(ref="c. No")
	chf(ref="c. No") cancer_flag(ref="c. No") bmi_3(ref="BMI<=30")
	 sleep_apnea(ref="c. No") Severity_numeric(ref='1')
	/param=glm;
   model Time_from_ELLA_to_last_follow_up*died(0)= TNF_a_bin IL_6_bin IL_8_bin IL_1b_bin
   		CRP_BIN D_DIMER_BIN FERRITIN_BIN
		gender age_grp race_eth diabetes 
		htn smoke ckd asthma copd chf atrial_fibrillation cancer_flag sleep_apnea
		bmi_3 severity_numeric
		/*SYSTOL_BP_MAX O2SAT_MIN D_DIMER_log2 ALBUMIN CALCIUM CHLORIDE PLATELET*/
		/risklimits=WALD;
   *baseline OUT = &ind_var._surv SURVIVAL = Surv_Prob L=LCL U=UCL
 COVARIATES = &data SURVIVAL=_ALL_/DIRADJ group=&ind_var;
   *lsmeans &ind_var gender age_grp race_eth htn smoke ckd asthma
	chf atrial_fibrillation SARS_PCR/diff exp cl ADJUST=BON;
run;


proc phreg data=cohort_2;
title "Competing risk model: All cytokines+CRP D-dimer FERRITIN severity score";
	class TNF_a_bin(ref="Low") IL_6_bin(ref="Low") IL_8_bin(ref="Low") IL_1b_bin(ref="Low") 
	CRP_bin(ref="Low") D_DIMER_BIN(ref="Low") FERRITIN_BIN(ref="Low")
	gender(ref="c. Male") age_grp(ref="<50") race_eth(ref="d. NH White")
	diabetes(ref="c. No") htn(ref="c. No") smoke(ref="d. Non-smoker") ckd(ref="c. No") 
	asthma(ref="c. No") copd(ref="c. No")  atrial_fibrillation(ref="c. No")
	chf(ref="c. No") cancer_flag(ref="c. No") bmi_3(ref="BMI<=30")  sleep_apnea(ref="c. No")
	severity_numeric(ref='1')
	/param=glm;
   model Time_from_ELLA_to_last_follow_up*status(2)= TNF_a_bin IL_6_bin IL_8_bin IL_1b_bin
		CRP_BIN D_DIMER_BIN FERRITIN_BIN
		gender age_grp race_eth diabetes 
		htn smoke ckd asthma copd chf atrial_fibrillation cancer_flag sleep_apnea
		bmi_3 severity_numeric
		/*SYSTOL_BP_MAX O2SAT_MIN D_DIMER_log2 ALBUMIN CALCIUM CHLORIDE PLATELET*/
		/eventcode=1 risklimits=WALD;
  *baseline OUT = &ind_var._CIF
 COVARIATES = risk CIF=_ALL_/group=&ind_var;
   *lsmeans &ind_var gender age_grp race_eth htn smoke ckd asthma
	chf atrial_fibrillation SARS_PCR/diff exp cl ADJUST=BON;
run;

proc phreg data=cohort_2;
title "After Backward Model selection";
	class 
		gender(ref="c. Male") age_grp(ref="<50") race_eth(ref="d. NH White")
	diabetes(ref="c. No") htn(ref="c. No") smoke(ref="d. Non-smoker") ckd(ref="c. No") 
	asthma(ref="c. No") copd(ref="c. No")  atrial_fibrillation(ref="c. No")
	chf(ref="c. No") cancer_flag(ref="c. No") bmi_3(ref="BMI<=30") sleep_apnea(ref="c. No")
	severity_numeric(ref="1")
	/param=glm;
   model Time_from_ELLA_to_last_follow_up*died(0)= tnf_a IL_6 IL_8 IL_1b
		gender age_grp race_eth diabetes 
		htn smoke ckd asthma chf atrial_fibrillation copd cancer_flag sleep_apnea bmi_3
		severity_numeric
		SYSTOL_BP_MAX
		O2SAT_MIN
		D_DIMER_log2
		ALBUMIN
		CALCIUM
		CHLORIDE
		PLATELET

		/risklimits=WALD;
   *lsmeans  tnf_a_bin IL_6_bin IL_8_bin IL_1b_bin
		gender age_grp race_eth htn smoke ckd asthma
		chf atrial_fibrillation SARS_PCR/diff exp cl ADJUST=BON;
run;


proc phreg data=cohort_2;
title "After Backward Model selection_TNF_a";
	class 
		gender(ref="c. Male") age_grp(ref="<50") race_eth(ref="d. NH White")
	diabetes(ref="c. No") htn(ref="c. No") smoke(ref="d. Non-smoker") ckd(ref="c. No") 
	asthma(ref="c. No") copd(ref="c. No")  atrial_fibrillation(ref="c. No")
	chf(ref="c. No") cancer_flag(ref="c. No") bmi_3(ref="BMI<=30") sleep_apnea(ref="c. No")
	severity_numeric(ref="1")
	/param=glm;
   model Time_from_ELLA_to_last_follow_up*died(0)= tnf_a
		gender age_grp race_eth diabetes 
		htn smoke ckd asthma chf atrial_fibrillation copd cancer_flag sleep_apnea bmi_3
		severity_numeric
		SYSTOL_BP_MAX
		O2SAT_MIN
		D_DIMER_log2
		ALBUMIN
		CALCIUM
		CHLORIDE
		PLATELET

		/risklimits=WALD;
   *lsmeans  tnf_a_bin IL_6_bin IL_8_bin IL_1b_bin
		gender age_grp race_eth htn smoke ckd asthma
		chf atrial_fibrillation SARS_PCR/diff exp cl ADJUST=BON;
run;


proc phreg data=cohort_2;
title "After Backward Model selection";
	class 
		gender(ref="c. Male") age_grp(ref="<50") race_eth(ref="d. NH White")
	diabetes(ref="c. No") htn(ref="c. No") smoke(ref="d. Non-smoker") ckd(ref="c. No") 
	asthma(ref="c. No") copd(ref="c. No")  atrial_fibrillation(ref="c. No")
	chf(ref="c. No") cancer_flag(ref="c. No") bmi_3(ref="BMI<=30") sleep_apnea(ref="c. No")
	severity_numeric(ref="1")
	/param=glm;
   model Time_from_ELLA_to_last_follow_up*died(0)= IL_6
		gender age_grp race_eth diabetes 
		htn smoke ckd asthma chf atrial_fibrillation copd cancer_flag sleep_apnea bmi_3
		severity_numeric
		SYSTOL_BP_MAX
		O2SAT_MIN
		D_DIMER_log2
		ALBUMIN
		CALCIUM
		CHLORIDE
		PLATELET

		/risklimits=WALD;
   *lsmeans  tnf_a_bin IL_6_bin IL_8_bin IL_1b_bin
		gender age_grp race_eth htn smoke ckd asthma
		chf atrial_fibrillation SARS_PCR/diff exp cl ADJUST=BON;
run;


proc phreg data=cohort_2;
title "After Backward Model selection";
	class 
		gender(ref="c. Male") age_grp(ref="<50") race_eth(ref="d. NH White")
	diabetes(ref="c. No") htn(ref="c. No") smoke(ref="d. Non-smoker") ckd(ref="c. No") 
	asthma(ref="c. No") copd(ref="c. No")  atrial_fibrillation(ref="c. No")
	chf(ref="c. No") cancer_flag(ref="c. No") bmi_3(ref="BMI<=30") sleep_apnea(ref="c. No")
	severity_numeric(ref="1")
	/param=glm;
   model Time_from_ELLA_to_last_follow_up*died(0)= IL_8
		gender age_grp race_eth diabetes 
		htn smoke ckd asthma chf atrial_fibrillation copd cancer_flag sleep_apnea bmi_3
		severity_numeric
		SYSTOL_BP_MAX
		O2SAT_MIN
		D_DIMER_log2
		ALBUMIN
		CALCIUM
		CHLORIDE
		PLATELET

		/risklimits=WALD;
   *lsmeans  tnf_a_bin IL_6_bin IL_8_bin IL_1b_bin
		gender age_grp race_eth htn smoke ckd asthma
		chf atrial_fibrillation SARS_PCR/diff exp cl ADJUST=BON;
run;


proc phreg data=cohort_2;
title "After Backward Model selection";
	class 
		gender(ref="c. Male") age_grp(ref="<50") race_eth(ref="d. NH White")
	diabetes(ref="c. No") htn(ref="c. No") smoke(ref="d. Non-smoker") ckd(ref="c. No") 
	asthma(ref="c. No") copd(ref="c. No")  atrial_fibrillation(ref="c. No")
	chf(ref="c. No") cancer_flag(ref="c. No") bmi_3(ref="BMI<=30") sleep_apnea(ref="c. No")
	severity_numeric(ref="1")
	/param=glm;
   model Time_from_ELLA_to_last_follow_up*died(0)= IL_1b
		gender age_grp race_eth diabetes 
		htn smoke ckd asthma chf atrial_fibrillation copd cancer_flag sleep_apnea bmi_3
		severity_numeric
		SYSTOL_BP_MAX
		O2SAT_MIN
		D_DIMER_log2
		ALBUMIN
		CALCIUM
		CHLORIDE
		PLATELET

		/risklimits=WALD;
   *lsmeans  tnf_a_bin IL_6_bin IL_8_bin IL_1b_bin
		gender age_grp race_eth htn smoke ckd asthma
		chf atrial_fibrillation SARS_PCR/diff exp cl ADJUST=BON;
run;


proc phreg data=cohort_2;
title "After Backward Model selection";
	class 
		gender(ref="c. Male") age_grp(ref="<50") race_eth(ref="d. NH White")
	diabetes(ref="c. No") htn(ref="c. No") smoke(ref="d. Non-smoker") ckd(ref="c. No") 
	asthma(ref="c. No") copd(ref="c. No")  atrial_fibrillation(ref="c. No")
	chf(ref="c. No") cancer_flag(ref="c. No") bmi_3(ref="BMI<=30") sleep_apnea(ref="c. No")
	severity_numeric(ref="1")
	/param=glm;
   model Time_from_ELLA_to_last_follow_up*status(2)= tnf_a IL_6 IL_8 IL_1b
		gender age_grp race_eth diabetes 
		htn smoke ckd asthma chf atrial_fibrillation copd cancer_flag sleep_apnea bmi_3
		severity_numeric
		SYSTOL_BP_MAX
		O2SAT_MIN
		D_DIMER_log2
		ALBUMIN
		CALCIUM
		CHLORIDE
		PLATELET

		/eventcode=1 risklimits=WALD;
   *lsmeans  tnf_a_bin IL_6_bin IL_8_bin IL_1b_bin
		gender age_grp race_eth htn smoke ckd asthma
		chf atrial_fibrillation SARS_PCR/diff exp cl ADJUST=BON;
run;


proc phreg data=cohort_2;
title "After Backward Model selection";
	class 
		gender(ref="c. Male") age_grp(ref="<50") race_eth(ref="d. NH White")
	diabetes(ref="c. No") htn(ref="c. No") smoke(ref="d. Non-smoker") ckd(ref="c. No") 
	asthma(ref="c. No") copd(ref="c. No")  atrial_fibrillation(ref="c. No")
	chf(ref="c. No") cancer_flag(ref="c. No") bmi_3(ref="BMI<=30") sleep_apnea(ref="c. No")
	severity_numeric(ref="1")
	/param=glm;
   model Time_from_ELLA_to_last_follow_up*status(2)= tnf_a
		gender age_grp race_eth diabetes 
		htn smoke ckd asthma chf atrial_fibrillation copd cancer_flag sleep_apnea bmi_3
		severity_numeric
		SYSTOL_BP_MAX
		O2SAT_MIN
		D_DIMER_log2
		ALBUMIN
		CALCIUM
		CHLORIDE
		PLATELET

		/eventcode=1 risklimits=WALD;
   *lsmeans  tnf_a_bin IL_6_bin IL_8_bin IL_1b_bin
		gender age_grp race_eth htn smoke ckd asthma
		chf atrial_fibrillation SARS_PCR/diff exp cl ADJUST=BON;
run;


proc phreg data=cohort_2;
title "After Backward Model selection";
	class 
		gender(ref="c. Male") age_grp(ref="<50") race_eth(ref="d. NH White")
	diabetes(ref="c. No") htn(ref="c. No") smoke(ref="d. Non-smoker") ckd(ref="c. No") 
	asthma(ref="c. No") copd(ref="c. No")  atrial_fibrillation(ref="c. No")
	chf(ref="c. No") cancer_flag(ref="c. No") bmi_3(ref="BMI<=30") sleep_apnea(ref="c. No")
	severity_numeric(ref="1")
	/param=glm;
   model Time_from_ELLA_to_last_follow_up*status(2)=  IL_6
		gender age_grp race_eth diabetes 
		htn smoke ckd asthma chf atrial_fibrillation copd cancer_flag sleep_apnea bmi_3
		severity_numeric
		SYSTOL_BP_MAX
		O2SAT_MIN
		D_DIMER_log2
		ALBUMIN
		CALCIUM
		CHLORIDE
		PLATELET

		/eventcode=1 risklimits=WALD;
   *lsmeans  tnf_a_bin IL_6_bin IL_8_bin IL_1b_bin
		gender age_grp race_eth htn smoke ckd asthma
		chf atrial_fibrillation SARS_PCR/diff exp cl ADJUST=BON;
run;


proc phreg data=cohort_2;
title "After Backward Model selection";
	class 
		gender(ref="c. Male") age_grp(ref="<50") race_eth(ref="d. NH White")
	diabetes(ref="c. No") htn(ref="c. No") smoke(ref="d. Non-smoker") ckd(ref="c. No") 
	asthma(ref="c. No") copd(ref="c. No")  atrial_fibrillation(ref="c. No")
	chf(ref="c. No") cancer_flag(ref="c. No") bmi_3(ref="BMI<=30") sleep_apnea(ref="c. No")
	severity_numeric(ref="1")
	/param=glm;
   model Time_from_ELLA_to_last_follow_up*status(2)= IL_8
		gender age_grp race_eth diabetes 
		htn smoke ckd asthma chf atrial_fibrillation copd cancer_flag sleep_apnea bmi_3
		severity_numeric
		SYSTOL_BP_MAX
		O2SAT_MIN
		D_DIMER_log2
		ALBUMIN
		CALCIUM
		CHLORIDE
		PLATELET

		/eventcode=1 risklimits=WALD;
   *lsmeans  tnf_a_bin IL_6_bin IL_8_bin IL_1b_bin
		gender age_grp race_eth htn smoke ckd asthma
		chf atrial_fibrillation SARS_PCR/diff exp cl ADJUST=BON;
run;


proc phreg data=cohort_2;
title "After Backward Model selection";
	class 
		gender(ref="c. Male") age_grp(ref="<50") race_eth(ref="d. NH White")
	diabetes(ref="c. No") htn(ref="c. No") smoke(ref="d. Non-smoker") ckd(ref="c. No") 
	asthma(ref="c. No") copd(ref="c. No")  atrial_fibrillation(ref="c. No")
	chf(ref="c. No") cancer_flag(ref="c. No") bmi_3(ref="BMI<=30") sleep_apnea(ref="c. No")
	severity_numeric(ref="1")
	/param=glm;
   model Time_from_ELLA_to_last_follow_up*status(2)= IL_1b
		gender age_grp race_eth diabetes 
		htn smoke ckd asthma chf atrial_fibrillation copd cancer_flag sleep_apnea bmi_3
		severity_numeric
		SYSTOL_BP_MAX
		O2SAT_MIN
		D_DIMER_log2
		ALBUMIN
		CALCIUM
		CHLORIDE
		PLATELET

		/eventcode=1 risklimits=WALD;
   *lsmeans  tnf_a_bin IL_6_bin IL_8_bin IL_1b_bin
		gender age_grp race_eth htn smoke ckd asthma
		chf atrial_fibrillation SARS_PCR/diff exp cl ADJUST=BON;
run;


%surv_strata(data=cohort_2, ind_var=TNF_a_bin, strata=O2sat_3);
%surv_strata(data=cohort_2, ind_var=IL_6_bin, strata=O2sat_3);
%surv_strata(data=cohort_2, ind_var=IL_8_bin, strata=O2sat_3);
%surv_strata(data=cohort_2, ind_var=IL_1b_bin, strata=O2sat_3);
%surv_strata(data=cohort_2, ind_var=TNF_a_bin, strata=age_grp);
%surv_strata(data=cohort_2, ind_var=IL_6_bin, strata=age_grp);
%surv_strata(data=cohort_2, ind_var=IL_8_bin, strata=age_grp);
%surv_strata(data=cohort_2, ind_var=IL_1b_bin, strata=age_grp);
%surv_strata(data=cohort_2, ind_var=TNF_a_bin, strata=severity_numeric);
%surv_strata(data=cohort_2, ind_var=IL_6_bin, strata=severity_numeric);
%surv_strata(data=cohort_2, ind_var=IL_8_bin, strata=severity_numeric);
%surv_strata(data=cohort_2, ind_var=IL_1b_bin, strata=severity_numeric);


data risk;
gender=1;
age_grp=3;
race_eth=0;
diabetes=0;
htn=0; 
smoke=0; 
ckd=0; 
asthma=0; 
chf=0; 
atrial_fibrillation=0; 
copd=0; 
sleep_apnea=0;
bmi_3=1;
cancer_flag=0;
Severity_numeric=1; 
SYSTOL_BP_MAX=142.66;
O2SAT_MIN=90.72;
D_DIMER_log2=0.74;
ALBUMIN=3.01;
CALCIUM=8.45;
CHLORIDE=102.48;
PLATELET=244.43;
IL_6_bin=0;
IL_8_bin=0;
IL_1b_bin=0;
TNF_a_bin=1; output;
TNF_a_bin=0; output;

format gender sex_fmt. age_grp age_grp. race_eth race_eth. 
	htn copd diabetes cancer_flag ckd asthma chf atrial_fibrillation sleep_apnea bin_Fmt. 
	TNF_a_bin IL_6_bin IL_8_bin IL_1b_bin hilo_fmt.
	bmi_3 bmi3_fmt.
	smoke smoke_fmt.;
run;

proc phreg data=cohort_2;
title "After Backward Model selection";
	class 
	TNF_a_bin(ref="Low") IL_6_bin(ref="Low") IL_8_bin(ref="Low") IL_1b_bin(ref="Low") 
	gender(ref="c. Male") age_grp(ref="<50") race_eth(ref="d. NH White")
	diabetes(ref="c. No") htn(ref="c. No") smoke(ref="d. Non-smoker") ckd(ref="c. No") 
	asthma(ref="c. No") copd(ref="c. No")  atrial_fibrillation(ref="c. No")
	chf(ref="c. No") cancer_flag(ref="c. No") bmi_3(ref="BMI<=30") sleep_apnea(ref="c. No")
	severity_numeric(ref="1")
	/param=glm;
   model Time_from_ELLA_to_last_follow_up*status(2)= tnf_a_bin IL_6_bin IL_8_bin IL_1b_bin
		gender age_grp race_eth diabetes 
		htn smoke ckd asthma chf atrial_fibrillation copd cancer_flag sleep_apnea bmi_3
		severity_numeric
		SYSTOL_BP_MAX
		O2SAT_MIN
		D_DIMER_log2
		ALBUMIN
		CALCIUM
		CHLORIDE
		PLATELET

		/eventcode=1 risklimits=WALD;
    baseline OUT = tnf_a_CIF_fig4
 COVARIATES = risk CIF=_ALL_/group=TNF_a_bin;
run;

data TNF_a_CIF_fig4;
	set tnf_a_CIF_fig4;
	keep TNF_a_bin Time_from_ELLA_to_last_follow_up CIF lowerCIF upperCIF;
run;



data risk;
gender=1;
age_grp=3;
race_eth=0;
diabetes=0;
htn=0; 
smoke=0; 
ckd=0; 
asthma=0; 
chf=0; 
atrial_fibrillation=0; 
copd=0; 
sleep_apnea=0;
bmi_3=1;
cancer_flag=0;
Severity_numeric=1; 
SYSTOL_BP_MAX=142.66;
O2SAT_MIN=90.72;
D_DIMER_log2=0.74;
ALBUMIN=3.01;
CALCIUM=8.45;
CHLORIDE=102.48;
PLATELET=244.43;
TNF_a_bin=0;
IL_8_bin=0;
IL_1b_bin=0;
IL_6_bin=1; output;
IL_6_bin=0; output;

format gender sex_fmt. age_grp age_grp. race_eth race_eth. 
	htn copd diabetes cancer_flag ckd asthma chf atrial_fibrillation sleep_apnea bin_Fmt. 
	TNF_a_bin IL_6_bin IL_8_bin IL_1b_bin hilo_fmt.
	bmi_3 bmi3_fmt.
	smoke smoke_fmt.;
run;

proc phreg data=cohort_2;
title "After Backward Model selection";
	class 
	TNF_a_bin(ref="Low") IL_6_bin(ref="Low") IL_8_bin(ref="Low") IL_1b_bin(ref="Low") 
	gender(ref="c. Male") age_grp(ref="<50") race_eth(ref="d. NH White")
	diabetes(ref="c. No") htn(ref="c. No") smoke(ref="d. Non-smoker") ckd(ref="c. No") 
	asthma(ref="c. No") copd(ref="c. No")  atrial_fibrillation(ref="c. No")
	chf(ref="c. No") cancer_flag(ref="c. No") bmi_3(ref="BMI<=30") sleep_apnea(ref="c. No")
	severity_numeric(ref="1")
	/param=glm;
   model Time_from_ELLA_to_last_follow_up*status(2)= tnf_a_bin IL_6_bin IL_8_bin IL_1b_bin
		gender age_grp race_eth diabetes 
		htn smoke ckd asthma chf atrial_fibrillation copd cancer_flag sleep_apnea bmi_3
		severity_numeric
		SYSTOL_BP_MAX
		O2SAT_MIN
		D_DIMER_log2
		ALBUMIN
		CALCIUM
		CHLORIDE
		PLATELET

		/eventcode=1 risklimits=WALD;
    baseline OUT = IL_6_CIF_fig4
 COVARIATES = risk CIF=_ALL_/group=IL_6_bin;
run;

data IL_6_CIF_fig4;
	set IL_6_CIF_fig4;
	keep IL_6_bin Time_from_ELLA_to_last_follow_up CIF lowerCIF upperCIF;
run;


data risk;
gender=1;
age_grp=3;
race_eth=0;
diabetes=0;
htn=0; 
smoke=0; 
ckd=0; 
asthma=0; 
chf=0; 
atrial_fibrillation=0; 
copd=0; 
sleep_apnea=0;
bmi_3=1;
cancer_flag=0;
Severity_numeric=1; 
SYSTOL_BP_MAX=142.66;
O2SAT_MIN=90.72;
D_DIMER_log2=0.74;
ALBUMIN=3.01;
CALCIUM=8.45;
CHLORIDE=102.48;
PLATELET=244.43;
TNF_a_bin=0;
IL_6_bin=0;
IL_1b_bin=0;
IL_8_bin=1; output;
IL_8_bin=0; output;

format gender sex_fmt. age_grp age_grp. race_eth race_eth. 
	htn copd diabetes cancer_flag ckd asthma chf atrial_fibrillation sleep_apnea bin_Fmt. 
	TNF_a_bin IL_6_bin IL_8_bin IL_1b_bin hilo_fmt.
	bmi_3 bmi3_fmt.
	smoke smoke_fmt.;
run;

proc phreg data=cohort_2;
title "After Backward Model selection";
	class 
	TNF_a_bin(ref="Low") IL_6_bin(ref="Low") IL_8_bin(ref="Low") IL_1b_bin(ref="Low") 
	gender(ref="c. Male") age_grp(ref="<50") race_eth(ref="d. NH White")
	diabetes(ref="c. No") htn(ref="c. No") smoke(ref="d. Non-smoker") ckd(ref="c. No") 
	asthma(ref="c. No") copd(ref="c. No")  atrial_fibrillation(ref="c. No")
	chf(ref="c. No") cancer_flag(ref="c. No") bmi_3(ref="BMI<=30") sleep_apnea(ref="c. No")
	severity_numeric(ref="1")
	/param=glm;
   model Time_from_ELLA_to_last_follow_up*status(2)= tnf_a_bin IL_6_bin IL_8_bin IL_1b_bin
		gender age_grp race_eth diabetes 
		htn smoke ckd asthma chf atrial_fibrillation copd cancer_flag sleep_apnea bmi_3
		severity_numeric
		SYSTOL_BP_MAX
		O2SAT_MIN
		D_DIMER_log2
		ALBUMIN
		CALCIUM
		CHLORIDE
		PLATELET

		/eventcode=1 risklimits=WALD;
    baseline OUT = IL_8_CIF_fig4
 COVARIATES = risk CIF=_ALL_/group=IL_8_bin;
run;

data IL_8_CIF_fig4;
	set IL_8_CIF_fig4;
	keep IL_8_bin Time_from_ELLA_to_last_follow_up CIF lowerCIF upperCIF;
run;


data risk;
gender=1;
age_grp=3;
race_eth=0;
diabetes=0;
htn=0; 
smoke=0; 
ckd=0; 
asthma=0; 
chf=0; 
atrial_fibrillation=0; 
copd=0; 
sleep_apnea=0;
bmi_3=1;
cancer_flag=0;
Severity_numeric=1; 
SYSTOL_BP_MAX=142.66;
O2SAT_MIN=90.72;
D_DIMER_log2=0.74;
ALBUMIN=3.01;
CALCIUM=8.45;
CHLORIDE=102.48;
PLATELET=244.43;
TNF_a_bin=0;
IL_6_bin=0;
IL_8_bin=0;
IL_1b_bin=1; output;
IL_1b_bin=0; output;

format gender sex_fmt. age_grp age_grp. race_eth race_eth. 
	htn copd diabetes cancer_flag ckd asthma chf atrial_fibrillation sleep_apnea bin_Fmt. 
	TNF_a_bin IL_6_bin IL_8_bin IL_1b_bin hilo_fmt.
	bmi_3 bmi3_fmt.
	smoke smoke_fmt.;
run;

proc phreg data=cohort_2;
title "After Backward Model selection";
	class 
	TNF_a_bin(ref="Low") IL_6_bin(ref="Low") IL_8_bin(ref="Low") IL_1b_bin(ref="Low") 
	gender(ref="c. Male") age_grp(ref="<50") race_eth(ref="d. NH White")
	diabetes(ref="c. No") htn(ref="c. No") smoke(ref="d. Non-smoker") ckd(ref="c. No") 
	asthma(ref="c. No") copd(ref="c. No")  atrial_fibrillation(ref="c. No")
	chf(ref="c. No") cancer_flag(ref="c. No") bmi_3(ref="BMI<=30") sleep_apnea(ref="c. No")
	severity_numeric(ref="1")
	/param=glm;
   model Time_from_ELLA_to_last_follow_up*status(2)= tnf_a_bin IL_6_bin IL_8_bin IL_1b_bin
		gender age_grp race_eth diabetes 
		htn smoke ckd asthma chf atrial_fibrillation copd cancer_flag sleep_apnea bmi_3
		severity_numeric
		SYSTOL_BP_MAX
		O2SAT_MIN
		D_DIMER_log2
		ALBUMIN
		CALCIUM
		CHLORIDE
		PLATELET

		/eventcode=1 risklimits=WALD;
    baseline OUT = IL_1b_CIF_fig4
 COVARIATES = risk CIF=_ALL_/group=IL_8_bin;
run;

data IL_1b_CIF_fig4;
	set IL_1b_CIF_fig4;
	keep IL_1b_bin Time_from_ELLA_to_last_follow_up CIF lowerCIF upperCIF;
run;

ods pdf close;
ods html close;
ods html;
