********************************************************************************
*
*	Do-file:			define covariates.do
*	Project:			Sotrovimab-Paxlovid-Molnupiravir
*   Date:  				15/2/23
*	Programmed by:		Katie Bechman
* 	Description:		data management, reformat variables, categorise variables, label variables 
*	Data used:			data in memory (from output/input.csv) 
*	Data created:		analysis main.dta  (main analysis dataset)
*	Other output:		logfiles, printed to folder $Logdir
*	User installed ado: (place .ado file(s) in analysis folder)

****************************************************************************************************************
**Set filepaths
//global projectdir "C:\Users\k1635179\OneDrive - King's College London\Katie\OpenSafely\Safety mAB and antivirals\Safety-Sotrovimab-Paxlovid-Molnupiravir"
global projectdir `c(pwd)'
di "$projectdir"
capture mkdir "$projectdir/output/data"
capture mkdir "$projectdir/output/figures"
capture mkdir "$projectdir/output/tables"
global logdir "$projectdir/logs"
di "$logdir"
* Open a log file
cap log close
log using "$logdir/cleaning_dataset.log", replace

* import dataset
import delimited "$projectdir/output/input.csv", clear

*Set Ado file path
adopath + "$projectdir/analysis/ado"

//describe
//codebook

*  Convert strings to dates  *
foreach var of varlist 	 covid_test_positive_date				///
						 covid_test_positive_date2 				///
						 covid_symptoms_snomed 					///	
						 prior_covid_date				    	///
						 sotrovimab								///
						 molnupiravir							/// 
						 paxlovid								///
						 remdesivir								///
						 casirivimab							///
						 sotrovimab_not_start					///
						 molnupiravir_not_start					///
						 paxlovid_not_start						///
						 casirivimab_not_start					///
						 remdesivir_not_start					///
						 sotrovimab_stopped						///
						 molnupiravir_stopped					///
						 paxlovid_stopped						///
						 casirivimab_stopped					///
						 remdesivir_stopped						///
						 date_treated							///
						 drugs_do_not_use						///
						 drugs_consider_risk					///
						 last_vaccination_date 					///
						 covid_test_positive_pre_date			///
						 death_date								///
						 dereg_date 							///
						 bmi_date_measured						///
						 creatinine_ctv3_date 					///
						 creatinine_snomed_date					///
						 creatinine_short_snomed_date			///
						 covid_discharge_date_primary			///
						 any_covid_hosp_discharge				///			
						 ae_diverticulitis_icd					///
						 ae_diverticulitis_snomed				///
					     ae_diarrhoea_snomed					///
						 ae_taste_snomed						///
						 ae_taste_icd							///
						 ae_anaphylaxis_icd						///
  						 ae_anaphylaxis_snomed					///
						 ae_rheumatoid_arthritis_snomed			///
						 ae_rheumatoid_arthritis_icd			///
						 ae_sle_ctv								///
						 ae_sle_icd								///
						 ae_psoriasis_snomed					///
						 ae_psoriatic_arthritis_snomed			///
						 ae_ankylosing_spondylitis_ctv			///
						 ae_ibd_snomed							///
						 rheumatoid_arthritis_nhsd_snomed		///
						 rheumatoid_arthritis_nhsd_icd10		///
						 sle_nhsd_ctv							///
						 sle_nhsd_icd10							///
						 psoriasis_nhsd							///
						 psoriatic_arthritis_nhsd				///
						 ankylosing_spondylitis_nhsd			///
						 ibd_ctv								///
						 all_hosp_date 							///
						 all_hosp_date0 						///
						 all_hosp_date1 						///
						 all_hosp_date2							///
						 hosp_discharge_date					///
						 hosp_discharge_date0 					///
						 hosp_discharge_date1 					///
						 hosp_discharge_date2					///
						 covid_hosp_date						///
						 covid_hosp_date_primary				///
						 covid_hosp_date0 						///
						 covid_hosp_date1 						///
						 covid_hosp_date2  						///						
						 covid_discharge_date0				  ///  						
						 covid_discharge_date1					/// 
						 covid_discharge_date2					/// 
						 covid_hosp_date_mabs					/// 
						 covid_hosp_date_mabs_not_primary		/// 
						 covid_hosp_date_mabs_day				///
						 died_date_ons							///
						 died_ons_covid	{					 
	capture confirm string variable `var'
	if _rc==0 {
	rename `var' a
	gen `var' = date(a, "YMD")
	drop a
	format %td `var'
 }
}

*check hosp/death event date range*
codebook covid_test_positive_date date_treated all_hosp_date died_date_ons


****************************
*	EXPOSURE		*
****************************
foreach var of varlist sotrovimab molnupiravir paxlovid remdesivir casirivimab{
    display "`var'"
	gen `var'_check = 1 if `var'>=covid_test_positive_date & `var'<=covid_test_positive_date+5 & `var'!=.
	replace `var'_check = 0 if (`var' < covid_test_positive_date | `var' > covid_test_positive_date + 5) & `var'!=.
	sum `var'
	tab `var'_check, m  // should be no 0s
	sum `var'_not_start // number prescribed but not started
	gen `var'_started = 1 if `var'_not_start==. & `var'_check==1
	tab `var'_started, m
	gen `var'_date_started = `var' if `var'==date_treated & `var'_started==1 
	sum `var'_date_started
}
gen drug=1 if sotrovimab==date_treated & sotrovimab_start==1 
replace drug=2 if paxlovid==date_treated & paxlovid_start==1
replace drug=3 if molnupiravir==date_treated & molnupiravir_start==1
replace drug=4 if (remdesivir==date_treated & remdesivir_start==1)  | (casirivimab==date_treated & casirivimab==1)
replace drug=0 if drug==.
label define drug 0 "control" 1 "sotrovimab" 2 "paxlovid" 3"molnupiravir" 4"other", replace
label values drug drug
tab drug, m
gen start_date=date_treated if drug>0 
format start_date %td
egen median_time = median(date_treated - covid_test_positive_date) if drug>0 & drug<4
egen median_max = max(median_time)
sum median_time
replace start_date = covid_test_positive_date + median_max if drug==0
bys drug: count if start_date==. // should be no 0s
*start and end date
gen study_end_date=mdy(06,01,2023)
gen start_date_29=start_date+28
format study_end_date start_date_29 %td

****************************
*	INCLUSION		*
****************************
***Inclusion criteria*
keep if age>=18 & age<110
keep if sex=="F"|sex=="M"
keep if has_died==0
*check covid positive, and not repeat covid test after an infection within 30 days prior
tab covid_test_positive covid_positive_previous_30_days, m
keep if covid_test_positive==1 & covid_positive_previous_30_days==0

***Exclusion criteria*
*capture and exclude if death or deregistration is on the start date 
count if start_date>=dereg_date & start_date!=.
count if start_date>=death_date & start_date!=.
drop if start_date>=death_date | start_date>=dereg_date


****************************
*	OUTCOME		*
****************************

*** Primary outcome - AESI
bys drug: count if ae_rheumatoid_arthritis_icd!=. & (rheumatoid_arthritis_nhsd_snomed==1 | rheumatoid_arthritis_nhsd_icd10==1)
gen new_ae_ra_icd = ae_rheumatoid_arthritis_icd if rheumatoid_arthritis_nhsd_snomed==0 & rheumatoid_arthritis_nhsd_icd10==0  
gen new_ae_ra_snomed = ae_rheumatoid_arthritis_snomed if rheumatoid_arthritis_nhsd_snomed==0 & rheumatoid_arthritis_nhsd_icd10==0  
gen new_ae_sle_icd = ae_sle_icd if sle_nhsd_ctv==0 & sle_nhsd_icd10==0
gen new_ae_sle_ctv = ae_sle_ctv if sle_nhsd_ctv==0 & sle_nhsd_icd10==0
gen new_ae_psoriasis_snomed = ae_psoriasis_snomed if psoriasis_nhsd==0
gen new_ae_psa_snomed = ae_psoriatic_arthritis_snomed if psoriatic_arthritis_nhsd==0
gen new_ae_ankspon_ctv = ae_ankylosing_spondylitis_ctv if ankylosing_spondylitis_nhsd==0
gen new_ae_ibd_snomed = ae_ibd_snomed if ibd_ctv==0
global ae_spc			ae_diverticulitis_snomed		///
						ae_diarrhoea_snomed				///
						ae_taste_snomed						
global ae_spc_icd		ae_diverticulitis_icd			///
						ae_taste_icd					
global ae_drug 			ae_anaphylaxis_snomed			
global ae_drug_icd		ae_anaphylaxis_icd
global ae_imae			new_ae_ra_snomed 				///
						new_ae_sle_ctv 					///
						new_ae_psoriasis_snomed 		///
						new_ae_psa_snomed 				///
						new_ae_ankspon_ctv				///
						new_ae_ibd	
global ae_imae_icd		new_ae_ra_icd 					///
						new_ae_sle_icd							
*remove event if occurred before start (including new start date for control)
foreach x in $ae_spc $ae_spc_icd $ae_drug $ae_drug_icd $ae_imae $ae_imae_icd{
				display "`x'"
				bys drug: count if (`x' < start_date | `x' > start_date + 28) & `x'!=.
				replace `x'=. if (`x' < start_date | `x' > start_date + 28) & `x'!=.
}
egen ae_spc_gp = rmin($ae_spc)
egen ae_spc_serious = rmin($ae_spc_icd)
egen ae_spc_all = rmin($ae_spc $ae_spc_icd)
egen ae_drug_gp = rmin($ae_drug)
egen ae_drug_serious = rmin($ae_drug_icd)
egen ae_drug_all = rmin($ae_drug $ae_drug_icd)
egen ae_imae_gp = rmin($ae_imae)	
egen ae_imae_serious = rmin($ae_imae_icd)
egen ae_imae_all = rmin($ae_imae $ae_imae_icd)	
egen ae_all = rmin($ae_spc $ae_spc_icd $ae_drug $ae_drug_icd $ae_imae $ae_imae_icd)
egen ae_all_serious = rmin($ae_spc_icd $ae_drug_icd $ae_imae_icd)
by drug, sort: count if ae_spc_all!=.
by drug, sort: count if ae_drug_all!=.
by drug, sort: count if ae_imae_all!=.
by drug, sort: count if ae_all!=.


*** Secondary outcome - SAEs hospitalisation or death including COVID-19 
*correcting COVID hosp events: admitted on day 0 or day 1 after treatment - to ignore sotro initiators with mab procedure codes*
by drug, sort: count if covid_hosp_date!=.
by drug, sort: count if covid_hosp_date0!=. // *nb: control group will not have covid_hosp_date0 - as do not have date_treated
// covid admission is the same date as date treated 
by drug, sort: count if covid_hosp_date0!=date_treated&covid_hosp_date0!=.&date_treated!=.
by drug, sort: count if covid_hosp_date1!=(date_treated+1) &covid_hosp_date1!=.&date_treated!=.
// covid admission is the same date as date treated and is a daycase
by drug, sort: count if covid_hosp_date0==covid_discharge_date0&covid_hosp_date0!=.
by drug, sort: count if covid_hosp_date1==covid_discharge_date1&covid_hosp_date1!=.
// covid admission is the same date as mab
by drug, sort: count if covid_hosp_date0==covid_hosp_date_mabs&covid_hosp_date_mabs!=.
by drug, sort: count if covid_hosp_date1==covid_hosp_date_mabs&covid_hosp_date_mabs!=.
// covid admission is the same date as mab and is a daycase, 1 day admission
by drug, sort: count if covid_hosp_date0==covid_hosp_date_mabs&covid_hosp_date0!=.&covid_hosp_date0==covid_discharge_date0
by drug, sort: count if covid_hosp_date1==covid_hosp_date_mabs&covid_hosp_date1!=.&covid_hosp_date1==covid_discharge_date1
by drug, sort: count if covid_hosp_date0==covid_hosp_date_mabs&covid_hosp_date0!=.&(covid_discharge_date0 - covid_hosp_date0)==1
by drug, sort: count if covid_hosp_date1==covid_hosp_date_mabs&covid_hosp_date1!=.&(covid_discharge_date1 - covid_hosp_date1)==1
// covid admission is PM but discharged in AM 
count if covid_hosp_date!=.&covid_discharge_date_primary==.
count if covid_hosp_date==.&covid_discharge_date_primary!=.
count if covid_hosp_date!=.&covid_discharge_date_primary!=.&covid_hosp_date==covid_discharge_date_primary
count if covid_hosp_date!=.&covid_discharge_date_primary!=.&covid_hosp_date<covid_discharge_date_primary
count if covid_hosp_date!=.&covid_discharge_date_primary!=.&covid_hosp_date>covid_discharge_date_primary
// REPLACE - ignore covid admission if admission is the day 0 or day 1 after treatment date treated AND a day case
replace covid_hosp_date=. if covid_hosp_date0==covid_discharge_date0&covid_hosp_date0!=.
replace covid_hosp_date=. if covid_hosp_date1==covid_discharge_date1&covid_hosp_date1!=.  // [? Bang is your code for this correct~line 135]
// REPLACE - ignore covid admission if admission is the day 0 or day 1 after treatment date AND a mab procedures for sotro 
replace covid_hosp_date=. if covid_hosp_date0==covid_hosp_date_mabs&covid_hosp_date_mabs!=.&drug==1
replace covid_hosp_date=. if covid_hosp_date1==covid_hosp_date_mabs&covid_hosp_date_mabs!=.&drug==1 

*correcting all hosp admission: admitted on day 0 or day 1 after treatment - to ignore sotro initiators with mab procedure codes*
by drug, sort: count if all_hosp_date!=.
by drug, sort: count if all_hosp_date0!=. // *nb: control group will not have covid_hosp_date0 - as do not have date_treated
// admission is the same date as date treated 
by drug, sort: count if all_hosp_date0!=date_treated&all_hosp_date0!=.&date_treated!=.
by drug, sort: count if all_hosp_date1!=(date_treated+1) &all_hosp_date1!=.&date_treated!=.
// admission is the same date as date treated and is a daycase
by drug, sort: count if all_hosp_date0==hosp_discharge_date0&all_hosp_date0!=.
by drug, sort: count if all_hosp_date1==hosp_discharge_date1&all_hosp_date1!=.
//  admission is the same date as mab
by drug, sort: count if all_hosp_date0==covid_hosp_date_mabs&covid_hosp_date_mabs!=.
by drug, sort: count if all_hosp_date1==covid_hosp_date_mabs&covid_hosp_date_mabs!=.
//  admission is the same date as mab and is a daycase, 1 day admission
by drug, sort: count if all_hosp_date0==covid_hosp_date_mabs&all_hosp_date0!=.&all_hosp_date0==hosp_discharge_date0
by drug, sort: count if all_hosp_date1==covid_hosp_date_mabs&all_hosp_date1!=.&all_hosp_date1==hosp_discharge_date1
by drug, sort: count if all_hosp_date0==covid_hosp_date_mabs&all_hosp_date0!=.&(hosp_discharge_date0-all_hosp_date0)==1
by drug, sort: count if all_hosp_date1==covid_hosp_date_mabs&all_hosp_date1!=.&(hosp_discharge_date1-all_hosp_date1)==1
//  admission is PM but discharged in AM 
count if all_hosp_date!=.&hosp_discharge_date==.
count if all_hosp_date==.&hosp_discharge_date!=.
count if all_hosp_date!=.&hosp_discharge_date!=.&all_hosp_date==hosp_discharge_date
count if all_hosp_date!=.&hosp_discharge_date!=.&all_hosp_date<hosp_discharge_date
count if all_hosp_date!=.&hosp_discharge_date!=.&all_hosp_date>hosp_discharge_date
// REPLACE - ignore admission if admission it is the day 0 or day 1 after treatment date AND a mab procedures for sotro 
replace all_hosp_date=. if all_hosp_date0==covid_hosp_date_mabs&covid_hosp_date_mabs!=.&drug==1
replace all_hosp_date=. if all_hosp_date1==covid_hosp_date_mabs&covid_hosp_date_mabs!=.&drug==1 
// Decision not to REPLACE admission if admission is the day 0 or day 1 after treatment date treated AND a day case

foreach var of varlist covid_hosp_date all_hosp_date died_date_ons{
				display "`var'"
				bys drug: count if (`var' < start_date | `var' > start_date + 28) & `var'!=.				
				replace `var'=. if (`var' < start_date | `var' > start_date + 28) & `var'!=.
}

*** Secondary outcome - severe drug reactions (including DRESS, SJS, TEN, anaphylaxis) 

****************************
*	COVARIATES		*
****************************
by drug,sort: tab high_risk_cohort_covid_therapeut,m
gen downs_syndrome_therapeutics= 1 if strpos(high_risk_cohort_covid_therapeut, "Downs syndrome")
gen solid_cancer_therapeutics=1 if strpos(high_risk_cohort_covid_therapeut, "solid cancer")
gen haem_disease_therapeutics=1 if strpos(high_risk_cohort_covid_therapeut, "haematological malignancies")
replace haem_disease_therapeutics=1 if strpos(high_risk_cohort_covid_therapeut, "sickle cell disease")
replace haem_disease_therapeutics=1 if strpos(high_risk_cohort_covid_therapeut, "haematological diseases")
replace haem_disease_therapeutics=1 if strpos(high_risk_cohort_covid_therapeut, "stem cell transplant")
gen renal_disease_therapeutics= 1 if strpos(high_risk_cohort_covid_therapeut, "renal disease")
gen liver_disease_therapeutics= 1 if strpos(high_risk_cohort_covid_therapeut, "liver disease")
gen imid_on_drug_therapeutics= 1 if strpos(high_risk_cohort_covid_therapeut, "IMID")
gen immunosupression_therapeutics= 1 if strpos(high_risk_cohort_covid_therapeut, "primary immune deficiencies")
gen hiv_aids_therapeutics= 1 if strpos(high_risk_cohort_covid_therapeut, "HIV or AIDS")
gen solid_organ_therapeutics= 1 if strpos(high_risk_cohort_covid_therapeut, "solid organ recipients")
replace solid_organ_therapeutics= 1 if strpos(high_risk_cohort_covid_therapeut, "solid organ transplant")
gen rare_neuro_therapeutics= 1 if strpos(high_risk_cohort_covid_therapeut, "rare neurological conditions")
*check if all diseases have been captured*
by drug,sort: count if high_risk_cohort_covid_therapeut!=""&high_risk_cohort_covid_therapeut!="other"& min(downs_syndrome_therapeutics,solid_cancer_therapeutics,haem_disease_therapeutics,renal_disease_therapeutics,liver_disease_therapeutics,imid_on_drug_therapeutics,immunosupression_therapeutics,hiv_aids_therapeutics,solid_organ_therapeutics,rare_neuro_therapeutics)==.
tab high_risk_cohort_covid_therapeut if high_risk_cohort_covid_therapeut!=""&high_risk_cohort_covid_therapeut!="other"& min(downs_syndrome_therapeutics,solid_cancer_therapeutics,haem_disease_therapeutics,renal_disease_therapeutics,liver_disease_therapeutics,imid_on_drug_therapeutics,immunosupression_therapeutics,hiv_aids_therapeutics,solid_organ_therapeutics,rare_neuro_therapeutics)==.

*clean eligible
count if oral_steroid_drug_nhsd_6m_count<4 &oral_steroid_drugs_nhsd==1
count if oral_steroid_drug_nhsd_6m_count<4 &oral_steroid_drugs_nhsd==1 &immunosuppresant==0 &methotrexate==0 &ciclosporin==0 &mycophenolate==0 &imid_drug_hcd==0
count if oral_steroid_drug_nhsd_6m_count<4 &oral_steroid_drugs_nhsd==1 &immunosuppresant==0 &methotrexate==0 &ciclosporin==0 &mycophenolate==0 &imid_drug_hcd==0 &imid_on_drug==1
count if oral_steroid_drug_nhsd_6m_count<4 &oral_steroid_drugs_nhsd==1 &immunosuppresant==0 &methotrexate==0 &ciclosporin==0 &mycophenolate==0 &imid_drug_hcd==0 &imid_on_drug==1 &downs_syndrome==0 &solid_cancer==0 &haem_disease==0 &renal_disease==0 &liver_disease==0 &immunosupression==0 &hiv_aids==0 &solid_organ_transplant==0 &rare_neuro==0
count if imid_on_drug==1 & imid_nhsd==1 & imid_drug==0 & imid_drug_hcd==0 
// REPLACE - ignore eligible steriods<4 scripts in last 6m
replace oral_steroid_drugs_nhsd=0 if oral_steroid_drug_nhsd_6m_count<4 &oral_steroid_drugs_nhsd==1
replace imid_drug_all=0 if oral_steroid_drug_nhsd_6m_count<4 &oral_steroid_drugs_nhsd==1 &immunosuppresant==0 &methotrexate==0 &ciclosporin==0 &mycophenolate==0 &imid_drug_hcd==0
// REPLACE - ignore eligible if not coded for imid AND (imid_drug or drug_HCD) & if <4 scripts steriod
replace imid_on_drug=0 if imid_on_drug==1 & imid_nhsd==1 & imid_drug==0 & imid_drug_hcd==0 
gen eligible_clean=((downs_syndrome + solid_cancer + haem_disease + renal_disease + liver_disease + imid_on_drug + immunosupression + hiv_aids + solid_organ_transplant + rare_neuro )>0)
rename solid_organ_transplant solid_organ
tab eligible_clean eligible
count if high_risk_cohort_covid_therapeut=="" & eligible_clean==1
count if high_risk_cohort_covid_therapeut!="" & eligible_clean==0

foreach var of varlist downs_syndrome solid_cancer haem_disease renal_disease liver_disease imid_on_drug immunosupression hiv_aids solid_organ rare_neuro {
	replace `var'_therapeutics=0 if `var'_therapeutics==.
	display `var'
	tab `var'_therapeutics `var'
	gen `var'_all = 1 if `var'==1 | `var'_therapeutics==1
}
// decision to use primary care variable for identification of high risk rather than CMU as not present for ocontrol group

*Time between positive test and treatment*
gen postest_treat=start_date-covid_test_positive_date
tab postest_treat,m
by drug, sort: tab postest_treat 
replace postest_treat=. if postest_treat<0|postest_treat>7
gen postest_treat_cat=(postest_treat>=3) if postest_treat<=5
replace postest_treat_cat=9 if postest_treat_cat==. 
label define postest_treat_cat 0 "<3 days" 1 "3-5 days"  9 "missing", replace 

* Demographics*
* Age
sum age
gen age_group=(age>=40)+(age>=60)
label define age_group 0 "18-39" 1 "40-59" 2 ">=60" 
label values age_group age_group
egen age_5y_band=cut(age), at(18,25,30,35,40,45,50,55,60,65,70,75,80,85,110) label
tab age_group,m
tab age_5y_band,m
* Sex
gen male = 1 if sex == "M"
replace male = 0 if sex == "F"
rename sex sex_str
gen sex=0 if sex_str=="M"
replace sex=1 if sex_str=="F"
label define sex 0 "Male" 1 "Female"
label values sex sex
* Ethnicity
tab ethnicity,m
rename ethnicity ethnicity_str
encode  ethnicity_str, gen(ethnicity)
label list ethnicity				
gen ethnicity_with_missing=ethnicity
replace ethnicity_with_missing=9 if ethnicity_with_missing==.
gen White=1 if ethnicity==5
replace White=0 if ethnicity!=5&ethnicity!=.
gen White_with_missing=White
replace White_with_missing=9 if White==.
* IMD
tab imd,m
replace imd=. if imd==0
recode imd 5 = 1 4 = 2 3 = 3 2 = 4 1 = 5 // Reverse the order (so high is more deprived)
label define imd 1 "1 least deprived" 2 "2" 3 "3" 4 "4" 5 "5 most deprived", replace
label values imd imd
gen imd_with_missing=imd
replace imd_with_missing=9 if imd==.
tab imd
* Region
tab region_nhs,m
rename region_nhs region_nhs_str 
encode  region_nhs_str, gen(region_nhs)
label list region_nhs
tab region_covid_therapeutics,m
rename region_covid_therapeutics region_covid_therapeutics_str
encode region_covid_therapeutics_str, gen(region_covid_therapeutics)
label list region_covid_therapeutics
tab stp,m
rename stp stp_str
encode  stp_str,gen(stp)
label list stp
label values stp stp
by stp, sort: gen stp_N=_N if stp!=. //combine stps with low N (<100) as "Other"
replace stp=99 if stp_N<100
tab stp,m
* BMI
tabstat bmi, stat(mean p25 p50 p75 min max) 
replace bmi=. if bmi<10|bmi>60
gen bmi_10y=bmi if bmi_date_measured!=. & bmi_date_measured>=start_date-365*10 & (age+((bmi_date_measured-start_date)/365)>=18)
gen bmi_5y=bmi if bmi_date_measured!=. & bmi_date_measured>=start_date-365*5 & (age+((bmi_date_measured-start_date)/365)>=18)
gen bmi_2y=bmi if bmi_date_measured!=. & bmi_date_measured>=start_date-365*2 & (age+((bmi_date_measured-start_date)/365)>=18)
gen bmi_group=(bmi>=18.5)+(bmi>=25.0)+(bmi>=30.0) if bmi!=.
label define bmi_group 0 "underweight" 1 "normal" 2 "overweight" 3 "obese"
label values bmi_group bmi_group
gen bmi_group_with_missing=bmi_group
replace bmi_group_with_missing=9 if bmi_group==.
gen bmi_25=(bmi>=25) if bmi!=.
gen bmi_30=(bmi>=30) if bmi!=.
* Comorbidities
tab diabetes,m
tab chronic_cardiac_disease,m
tab hypertension,m
tab chronic_respiratory_disease,m
* Vaccination 
tab vaccination_status,m
rename vaccination_status vaccination_status_group
gen vaccination_status=0 if vaccination_status_g=="Un-vaccinated"|vaccination_status_g=="Un-vaccinated (declined)"
replace vaccination_status=1 if vaccination_status_g=="One vaccination"
replace vaccination_status=2 if vaccination_status_g=="Two vaccinations"
replace vaccination_status=3 if vaccination_status_g=="Three vaccinations"
replace vaccination_status=4 if vaccination_status_g=="Four or more vaccinations"
label define vaccination_status 0 "Un-vaccinated" 1 "One vaccination" 2 "Two vaccinations" 3 "Three vaccinations" 4 "Four or more vaccinations"
label values vaccination_status vaccination_status
gen vaccination_3_plus=1 if vaccination_status==3|vaccination_status==4
replace vaccination_3_plus=0 if vaccination_status<3
gen days_vacc_covid=covid_test_positive_date - last_vaccination_date
sum days_vacc_covid,de
gen month_vacc_covid=ceil(days_vacc_covid/30)
tab month_vacc_covid,m
*Calendar time*
gen day_after_campaign=start_date-mdy(12,15,2021)
sum day_after_campaign,de
gen month_after_campaign=ceil((start_date-mdy(12,15,2021))/30)
tab month_after_campaign,m
mkspline calendar_day_spline = day_after_campaign, cubic nknots(4)
* Variant
tab sgtf,m
tab sgtf_new, m
label define sgtf_new 0 "S gene detected" 1 "confirmed SGTF" 9 "NA"
label values sgtf_new sgtf_new
tab variant_recorded,m
tab sgtf_new variant_recorded ,m
* Prior infection
gen prior_infection=(covid_test_positive_pre_date<=(covid_test_positive_date-30) & covid_test_positive_pre_date >mdy(1,1,2020) & covid_test_positive_pre_date!=.)
tab prior_infection,m
*Contraindications for Pax*
tab drug if solid_organ==1
tab drug if liver_disease_nhsd_icd10==1
tab drug if renal_disease==1
* Calculating egfr: adapted from https://github.com/opensafely/COVID-19-vaccine-breakthrough/blob/updates-feb/analysis/data_process.R*
tab creatinine_operator_ctv3,m
tabstat creatinine_ctv3, stat(mean p25 p50 p75 min max) 
replace creatinine_ctv3=. if !inrange(creatinine_ctv3, 20, 3000)|creatinine_ctv3_date>start_date
tabstat creatinine_ctv3, stat(mean p25 p50 p75 min max) 
tab creatinine_operator_ctv3 if creatinine_ctv3!=.,m
replace creatinine_ctv3 = creatinine_ctv3/88.4
gen min_creatinine_ctv3=.
replace min_creatinine_ctv3 = (creatinine_ctv3/0.7)^-0.329 if sex==1
replace min_creatinine_ctv3 = (creatinine_ctv3/0.9)^-0.411 if sex==0
replace min_creatinine_ctv3 = 1 if min_creatinine_ctv3<1
gen max_creatinine_ctv3=.
replace max_creatinine_ctv3 = (creatinine_ctv3/0.7)^-1.209 if sex==1
replace max_creatinine_ctv3 = (creatinine_ctv3/0.9)^-1.209 if sex==0
replace max_creatinine_ctv3 = 1 if max_creatinine_ctv3>1
gen egfr_creatinine_ctv3 = min_creatinine_ctv3*max_creatinine_ctv3*141*(0.993^age_creatinine_ctv3) if age_creatinine_ctv3>0&age_creatinine_ctv3<=120
replace egfr_creatinine_ctv3 = egfr_creatinine_ctv3*1.018 if sex==1
tab creatinine_operator_snomed,m
tab creatinine_operator_snomed if creatinine_snomed!=.,m
tabstat creatinine_snomed, stat(mean p25 p50 p75 min max) 
replace creatinine_snomed = . if !inrange(creatinine_snomed, 20, 3000)| creatinine_snomed_date>start_date
replace creatinine_snomed_date = creatinine_short_snomed_date if missing(creatinine_snomed)
replace creatinine_operator_snomed = creatinine_operator_short_snomed if missing(creatinine_snomed)
replace age_creatinine_snomed = age_creatinine_short_snomed if missing(creatinine_snomed)
replace creatinine_snomed = creatinine_short_snomed if missing(creatinine_snomed)
replace creatinine_snomed = . if !inrange(creatinine_snomed, 20, 3000)| creatinine_snomed_date>start_date
replace creatinine_snomed = creatinine_snomed/88.4
gen min_creatinine_snomed=.
replace min_creatinine_snomed = (creatinine_snomed/0.7)^-0.329 if sex==1
replace min_creatinine_snomed = (creatinine_snomed/0.9)^-0.411 if sex==0
replace min_creatinine_snomed = 1 if min_creatinine_snomed<1
gen max_creatinine_snomed=.
replace max_creatinine_snomed = (creatinine_snomed/0.7)^-1.209 if sex==1
replace max_creatinine_snomed = (creatinine_snomed/0.9)^-1.209 if sex==0
replace max_creatinine_snomed = 1 if max_creatinine_snomed>1
gen egfr_creatinine_snomed = min_creatinine_snomed*max_creatinine_snomed*141*(0.993^age_creatinine_snomed) if age_creatinine_snomed>0&age_creatinine_snomed<=120
replace egfr_creatinine_snomed = egfr_creatinine_snomed*1.018 if sex==1
tab egfr_operator if egfr_record!=.,m
tab egfr_short_operator if egfr_short_record!=.,m
gen egfr_60 = 1 if (egfr_creatinine_ctv3<60&creatinine_operator_ctv3!="<")|(egfr_creatinine_snomed<60&creatinine_operator_snomed!="<")|(egfr_record<60&egfr_record>0&egfr_operator!=">"&egfr_operator!=">=")|(egfr_short_record<60&egfr_short_record>0&egfr_short_operator!=">"&egfr_short_operator!=">=")
gen egfr_30 = 1 if (egfr_creatinine_ctv3<30&creatinine_operator_ctv3!="<")|(egfr_creatinine_snomed<30&creatinine_operator_snomed!="<")|(egfr_record<30&egfr_record>0&egfr_operator!=">"&egfr_operator!=">=")|(egfr_short_record<30&egfr_short_record>0&egfr_short_operator!=">"&egfr_short_operator!=">=")
tab drug if egfr_60==1
tab drug if egfr_30==1
*drug interactions*
tab drug if drugs_do_not_use<=start_date
tab drug if drugs_do_not_use<=start_date&drugs_do_not_use>=(start_date-3*365.25)
tab drug if drugs_do_not_use<=start_date&drugs_do_not_use>=(start_date-365.25)
tab drug if drugs_do_not_use<=start_date&drugs_do_not_use>=(start_date-180)
tab drug if drugs_consider_risk<=start_date
tab drug if drugs_consider_risk<=start_date&drugs_consider_risk>=(start_date-3*365.25)
tab drug if drugs_consider_risk<=start_date&drugs_consider_risk>=(start_date-365.25)
tab drug if drugs_consider_risk<=start_date&drugs_consider_risk>=(start_date-180)
gen drugs_do_not_use_contra=(drugs_do_not_use<=start_date&drugs_do_not_use>=(start_date-180))  // Are these CI drug for paxlovid only??
gen drugs_consider_risk_contra=(drugs_consider_risk<=start_date&drugs_consider_risk>=(start_date-180))
* Drug contraindicated 
gen paxlovid_contra = 1 if egfr_30==1 | dialysis==1
replace paxlovid_contra = 1 if liver_disease==1 
replace paxlovid_contra = 1 if solid_organ==1 
replace paxlovid_contra = 1 if drugs_do_not_use<=start_date&drugs_do_not_use>=(start_date-180)
recode paxlovid_contra . = 0
by drug, sort: count if paxlovid_contra==1


****************************
*	COX MODEL		*
****************************
drop if drug==4 // removing those on casirivimab or remdesivir as first drug after covid test
rename covid_hosp_date covid_hosp
rename all_hosp_date all_hosp
rename died_date_ons died

* Generate failure 
foreach var of varlist ae_spc* ae_imae* ae_all* ae_diverticulitis_snomed ae_diarrhoea_snomed ae_taste_snomed ae_diverticulitis_icd ///
					   ae_taste_icd ae_anaphylaxis_icd ae_anaphylaxis_snomed new_ae_ra_snomed new_ae_sle_ctv new_ae_psoriasis_snomed ///
					   new_ae_psa_snomed new_ae_ankspon_ctv new_ae_ibd new_ae_ra_icd new_ae_sle_icd covid_hosp all_hosp died{
	display "`var'"
	by drug, sort: count if `var'!=.
	by drug, sort: count if `var'<start_date & `var' 
	replace `var'=. if `var'<start_date & `var'!=.
	gen fail_`var'=(`var'!=.&`var'<= min(study_end_date, start_date_29, paxlovid_d, molnupiravir_d, remdesivir_d, casirivimab_d)) if drug==1
	replace fail_`var'=(`var'!=.&`var'<= min(study_end_date, start_date_29, sotrovimab_d, molnupiravir_d, remdesivir_d, casirivimab_d)) if drug==2
	replace fail_`var'=(`var'!=.&`var'<= min(study_end_date, start_date_29, sotrovimab_d, paxlovid_d, remdesivir_d, casirivimab_d)) if drug==3
	replace fail_`var'=(`var'!=.&`var'<= min(study_end_date, start_date_29, sotrovimab_d, paxlovid_d, molnupiravir_d, remdesivir_d, casirivimab_d)) if drug==0
	tab drug fail_`var', m
}
* Add half-day buffer if outcome on indexdate
foreach var of varlist ae_spc* ae_imae* ae_all* ae_diverticulitis_snomed ae_diarrhoea_snomed ae_taste_snomed ae_diverticulitis_icd ///
					   ae_taste_icd ae_anaphylaxis_icd ae_anaphylaxis_snomed new_ae_ra_snomed new_ae_sle_ctv new_ae_psoriasis_snomed ///
					   new_ae_psa_snomed new_ae_ankspon_ctv new_ae_ibd new_ae_ra_icd new_ae_sle_icd covid_hosp all_hosp died{
	display "`var'"
	replace `var'=`var'+0.5 if `var'==start_date
}
*Generate censor date
foreach var of varlist ae_spc* ae_imae* ae_all* ae_diverticulitis_snomed ae_diarrhoea_snomed ae_taste_snomed ae_diverticulitis_icd ///
					   ae_taste_icd ae_anaphylaxis_icd ae_anaphylaxis_snomed new_ae_ra_snomed new_ae_sle_ctv new_ae_psoriasis_snomed ///
					   new_ae_psa_snomed new_ae_ankspon_ctv new_ae_ibd new_ae_ra_icd new_ae_sle_icd covid_hosp all_hosp died{
	gen stop_`var'=`var' if fail_`var'==1
	replace stop_`var'=min(death_date,dereg_date,study_end_date,start_date_29,paxlovid_d,molnupiravir_d,remdesivir_d,casirivimab_d) if fail_`var'==0&drug==1
	replace stop_`var'=min(death_date,dereg_date,study_end_date,start_date_29,sotrovimab_d,remdesivir_d,casirivimab_d) if fail_`var'==0&drug==2
	replace stop_`var'=min(death_date,dereg_date,study_end_date,start_date_29,sotrovimab_d,paxlovid_d,remdesivir_d,casirivimab_d) if fail_`var'==0&drug==3
	replace stop_`var'=min(death_date,dereg_date,study_end_date,start_date_29,sotrovimab_d,paxlovid_d,molnupiravir_d,remdesivir_d,casirivimab_d) if fail_`var'==0&drug==0
	format %td stop_`var'
}

* Follow-up time
stset stop_ae_all, id(patient_id) origin(time start_date) enter(time start_date) failure(fail_ae_all==1) 
*count censored due to second therapy*
count if fail_ae_all==0&drug==0&min(sotrovimab_d,paxlovid_d,molnupiravir_d,remdesivir_d,casirivimab_d)==stop_ae_all
count if fail_ae_all==0&drug==1&min(paxlovid_d,molnupiravir_d,remdesivir_d,casirivimab_d)==stop_ae_all
count if fail_ae_all==0&drug==2&min(sotrovimab_d,molnupiravir_d,remdesivir_d,casirivimab_d)==stop_ae_all
count if fail_ae_all==0&drug==3&min(sotrovimab_d,paxlovid_d,remdesivir_d,casirivimab_d)==stop_ae_all
// keep if _st==1 -> observations end on or before enter -> should be 0 in actual dataset
tab _t,m
tab _t drug,m col
tab _t drug if fail_ae_all==1,m col
tab _t drug if fail_ae_all==1&stop_ae_all==ae_all
tab fail_ae_all drug,m col
*check censor reasons*
tab _t drug if fail_ae_all==0&_t<28&stop_ae_all==ae_all,m col
tab _t drug if fail_ae_all==0&_t<28&stop_ae_all==death_date,m col
tab _t drug if fail_ae_all==0&_t<28&stop_ae_all==dereg_date,m col
tab _t drug if fail_ae_all==0&_t<28&stop_ae_all==min(paxlovid_d,molnupiravir_d,remdesivir_d,casirivimab_d)&drug==1,m col
tab _t drug if fail_ae_all==0&_t<28&stop_ae_all==min(sotrovimab_d,molnupiravir_d,remdesivir_d,casirivimab_d)&drug==2,m col
tab _t drug if fail_ae_all==0&_t<28&stop_ae_all==min(sotrovimab_d,paxlovid_d,remdesivir_d,casirivimab_d)&drug==3,m col
tab _t drug if fail_ae_all==0&_t<28&stop_ae_all==min(sotrovimab_d,paxlovid_d,molnupiravir_d,remdesivir_d,casirivimab_d)&drug==0,m col

save "$projectdir/output/data/main.dta", replace

log close





































