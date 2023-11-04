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
// global projectdir "C:\Users\k1635179\OneDrive - King's College London\Katie\OpenSafely\Safety mAB and antivirals\Safety-Sotrovimab-Paxlovid-Molnupiravir"
global projectdir `c(pwd)'

di "$projectdir"
capture mkdir "$projectdir/output/data"
capture mkdir "$projectdir/output/figures"
capture mkdir "$projectdir/output/tables"
global logdir "$projectdir/logs"
di "$logdir"

* Open a log file
cap log close
log using "$logdir/cleaning_dataset_combine.log", replace

*Set Ado file path
adopath + "$projectdir/analysis/ado"


***********************************************************************************************************************
**			MAIN ANALYSIS			**
***********************************************************************************************************************
* 	Import control dataset
import delimited "$projectdir/output/input_control.csv", clear
gen control_dataset=1
drop variant_recorded
drop sgtf

*	Convert control strings to dates     * 
foreach var of varlist 	 pre_covid_hosp_date					///
						 pre_covid_hosp_discharge				///
						 covid_test_positive_date				///
						 covid_test_positive_date2 				///
						 covid_test_positive_date3 				///
						 prior_covid_date				    	///
						 sotrovimab								///
						 molnupiravir							/// 
						 paxlovid								///
						 remdesivir								///
						 casirivimab							///
						 sotrovimab_not_start					///
						 molnupiravir_not_start					///
						 paxlovid_not_start						///
						 date_treated							///
						 start_date								///
						 drugs_paxlovid_interaction				///
						 drugs_nirmatrelvir_interaction			///
						 drugs_paxlovid_contraindication		///
						 last_vaccination_date 					///
						 death_date								///
						 dereg_date 							///
						 bmi_date_measured						///
						 creatinine_ctv3_date 					///
						 creatinine_snomed_date					///
						 creatinine_short_snomed_date			///
						 ae_diverticulitis_icd					///
						 ae_diverticulitis_icd_prim				///
						 ae_diverticulitis_snomed				///
						 ae_diverticulitis_ae					///			 
						 ae_diarrhoea_snomed					///
						 ae_diarrhoea_icd						///
						 ae_diarrhoea_icd_prim					///
						 ae_diarrhoeal_icd						///
						 ae_diarrhoeal_icd_prim					///		 
						 ae_taste_snomed						///
						 ae_taste_icd							///
						 ae_taste_icd_prim						///
						 ae_rash_snomed							///
						 ae_rash_ae								///
						 ae_rash_icd							///
						 ae_rash_icd_prim						///		 
						 ae_bronchospasm_snomed					///
						 ae_contactderm_snomed					///
						 ae_contactderm_icd						///
						 ae_contactderm_icd_prim				///
						 ae_contactderm_ae						///
						 ae_dizziness_snomed					///
						 ae_dizziness_icd						///
						 ae_dizziness_icd_prim					///
						 ae_dizziness_ae						///
						 ae_nausea_vomit_snomed					///
						 ae_nausea_vomit_icd					///
						 ae_nausea_vomit_icd_prim				///
						 ae_headache_snomed						///
						 ae_headache_icd						///
						 ae_headache_icd_prim					///
						 ae_headache_ae							///
						 ae_anaphylaxis_icd						///
					     ae_anaphylaxis_icd_prim				///
					     ae_anaphylaxis_snomed					///
						 ae_anaphlaxis_ae						///
						 ae_severedrug_icd						///
						 ae_severedrug_icd_prim					///
						 ae_severedrug_sjs_icd					///
						 ae_severedrug_sjs_icd_prim				///
						 ae_severedrug_snomed					///
						 ae_severedrug_ae						///
						 ae_nonsevere_drug_snomed				///
						 ae_nonsevere_drug_ae					///
						 ae_rheumatoid_arthritis_icd			///
						 ae_rheumatoid_arthritis_icd_prim		///
						 ae_rheumatoid_arthritis_snomed			///
						 ae_rheumatoid_arthritis_ae				///
						 ae_sle_icd								///
						 ae_sle_icd_prim						///
						 ae_sle_ae								///
						 ae_sle_ctv								///
						 ae_psoriasis_icd						///
						 ae_psoriasis_icd_prim					///
						 ae_psoriasis_ae						///
						 ae_psoriasis_snomed					///
						 ae_psa_icd								///
						 ae_psa_icd_prim						///
						 ae_psa_snomed							///
						 ae_psa_ae								///
						 ae_psa_snomed							///
						 ae_axspa_icd							///
						 ae_axspa_icd_prim						///
						 ae_axspa_ctv							///
						 ae_axspa_ae							///
						 ae_ibd_icd								///
						 ae_ibd_icd_prim						///
						 ae_ibd_ctv								///
						 ae_ibd_ae								///
						 pre_diverticulitis_icd					///
						 pre_diverticulitis_icd_prim			///
						 pre_diverticulitis_snomed				///
						 pre_diverticulitis_ae					///
						 pre_diarrhoea_snomed 					///
						 pre_diarrhoea_icd						///
						 pre_diarrhoea_icd_prim					///
						 pre_diarrhoeal_icd						///
						 pre_diarrhoeal_icd_prim				///
						 pre_taste_icd							///
						 pre_taste_icd_prim						///
						 pre_taste_snomed						///
						 pre_rash_snomed						///
						 pre_rash_ae							///
						 pre_rash_icd							///
						 pre_rash_icd_prim 						///
						 pre_bronchospasm_snomed				///
						 pre_contactderm_snomed					///
						 pre_contactderm_icd					///
						 pre_contactderm_icd_prim				///
						 pre_contactderm_ae						///
						 pre_dizziness_snomed					///
						 pre_dizziness_icd						///
						 pre_dizziness_icd_prim					///
						 pre_dizziness_ae						///
						 pre_nausea_vomit_snomed				///
						 pre_nausea_vomit_icd					///
						 pre_nausea_vomit_icd_prim				///
						 pre_headache_snomed					///
						 pre_headache_icd						///
						 pre_headache_icd_prim					///
						 pre_headache_ae						///
						 pre_anaphylaxis_icd_prim				///
						 pre_anaphylaxis_icd					///
						 pre_anaphylaxis_snomed					///						 
						 pre_anaphlaxis_ae						///
						 pre_severedrug_icd						///
						 pre_severedrug_icd_prim				///
						 pre_severedrug_sjs_icd					///
						 pre_severedrug_sjs_icd_prim			///
						 pre_severedrug_snomed					///
						 pre_severedrug_ae						///
					     pre_nonsevere_drug_snomed				///
						 pre_nonsevere_drug_ae					///
						 pre_rheumatoid_icd_prim				///
						 pre_sle_icd_prim						///
						 pre_sle_ctv							///
						 pre_sle_icd							///
						 pre_sle_ae								///
						 pre_rheumatoid_arthritis_icd			///
						 pre_rheumatoid_icd_prim				///
						 pre_rheumatoid_arthritis_ae			///
						 pre_rheumatoid_arthritis_snomed		///
						 pre_psoriasis_icd						///
						 pre_psoriasis_icd_prim					///
						 pre_psoriasis_snomed					///
						 pre_psoriasis_ae						/// 
						 pre_psa_icd							/// 
						 pre_psa_icd_prim						/// 
						 pre_psa_ae								///
						 pre_psa_snomed							///						 
						 pre_axspa_icd							///	
						 pre_axspa_icd_prim						///	
						 pre_axspa_ctv							///
						 pre_axspa_ae							///
						 pre_ibd_ae								///
						 pre_ibd_ctv							///
						 pre_ibd_icd							///
						 pre_ibd_icd_prim						///
						 covid_hosp_discharge 					///
						 any_covid_hosp_discharge 				///
						 preg_36wks_date						///									 
{					 
	capture confirm string variable `var'
	if _rc==0 {
	rename `var' a
	gen `var' = date(a, "YMD")
	drop a
	format %td `var'
 }
}
tab control_dataset
save "$projectdir/output/data/control.dta", replace 

* import treatment dataset
import delimited "$projectdir/output/input_treatment.csv", clear
gen treatment_dataset=1
drop variant_recorded
drop sgtf
*	Convert control strings to dates     * 
foreach var of varlist 	 pre_covid_hosp_date					///
						 pre_covid_hosp_discharge				///
						 covid_test_positive_date				///
						 covid_test_positive_date2 				///
						 covid_test_positive_date3 				///
						 prior_covid_date				    	///
						 sotrovimab								///
						 molnupiravir							/// 
						 paxlovid								///
						 remdesivir								///
						 casirivimab							///
						 sotrovimab_not_start					///
						 molnupiravir_not_start					///
						 paxlovid_not_start						///
						 date_treated							///
						 start_date								///
						 drugs_paxlovid_interaction				///
						 drugs_nirmatrelvir_interaction			///
						 drugs_paxlovid_contraindication		///
						 last_vaccination_date 					///
						 death_date								///
						 dereg_date 							///
						 bmi_date_measured						///
						 creatinine_ctv3_date 					///
						 creatinine_snomed_date					///
						 creatinine_short_snomed_date			///
						 ae_diverticulitis_icd					///
						 ae_diverticulitis_icd_prim				///
						 ae_diverticulitis_snomed				///
						 ae_diverticulitis_ae					///			 
						 ae_diarrhoea_snomed					///
						 ae_diarrhoea_icd						///
						 ae_diarrhoea_icd_prim					///
						 ae_diarrhoeal_icd						///
						 ae_diarrhoeal_icd_prim					///		 
						 ae_taste_snomed						///
						 ae_taste_icd							///
						 ae_taste_icd_prim						///
						 ae_rash_snomed							///
						 ae_rash_ae								///
						 ae_rash_icd							///
						 ae_rash_icd_prim						///		 
						 ae_bronchospasm_snomed					///
						 ae_contactderm_snomed					///
						 ae_contactderm_icd						///
						 ae_contactderm_icd_prim				///
						 ae_contactderm_ae						///
						 ae_dizziness_snomed					///
						 ae_dizziness_icd						///
						 ae_dizziness_icd_prim					///
						 ae_dizziness_ae						///
						 ae_nausea_vomit_snomed					///
						 ae_nausea_vomit_icd					///
						 ae_nausea_vomit_icd_prim				///
						 ae_headache_snomed						///
						 ae_headache_icd						///
						 ae_headache_icd_prim					///
						 ae_headache_ae							///
						 ae_anaphylaxis_icd						///
					     ae_anaphylaxis_icd_prim				///
					     ae_anaphylaxis_snomed					///
						 ae_anaphlaxis_ae						///
						 ae_severedrug_icd						///
						 ae_severedrug_icd_prim					///
						 ae_severedrug_sjs_icd					///
						 ae_severedrug_sjs_icd_prim				///
						 ae_severedrug_snomed					///
						 ae_severedrug_ae						///
						 ae_nonsevere_drug_snomed				///
						 ae_nonsevere_drug_ae					///
						 ae_rheumatoid_arthritis_icd			///
						 ae_rheumatoid_arthritis_icd_prim		///
						 ae_rheumatoid_arthritis_snomed			///
						 ae_rheumatoid_arthritis_ae				///
						 ae_sle_icd								///
						 ae_sle_icd_prim						///
						 ae_sle_ae								///
						 ae_sle_ctv								///
						 ae_psoriasis_icd						///
						 ae_psoriasis_icd_prim					///
						 ae_psoriasis_ae						///
						 ae_psoriasis_snomed					///
						 ae_psa_icd								///
						 ae_psa_icd_prim						///
						 ae_psa_snomed							///
						 ae_psa_ae								///
						 ae_psa_snomed							///
						 ae_axspa_icd							///
						 ae_axspa_icd_prim						///
						 ae_axspa_ctv							///
						 ae_axspa_ae							///
						 ae_ibd_icd								///
						 ae_ibd_icd_prim						///
						 ae_ibd_ctv								///
						 ae_ibd_ae								///
						 pre_diverticulitis_icd					///
						 pre_diverticulitis_icd_prim			///
						 pre_diverticulitis_snomed				///
						 pre_diverticulitis_ae					///
						 pre_diarrhoea_snomed 					///
						 pre_diarrhoea_icd						///
						 pre_diarrhoea_icd_prim					///
						 pre_diarrhoeal_icd						///
						 pre_diarrhoeal_icd_prim				///
						 pre_taste_icd							///
						 pre_taste_icd_prim						///
						 pre_taste_snomed						///
						 pre_rash_snomed						///
						 pre_rash_ae							///
						 pre_rash_icd							///
						 pre_rash_icd_prim 						///
						 pre_bronchospasm_snomed				///
						 pre_contactderm_snomed					///
						 pre_contactderm_icd					///
						 pre_contactderm_icd_prim				///
						 pre_contactderm_ae						///
						 pre_dizziness_snomed					///
						 pre_dizziness_icd						///
						 pre_dizziness_icd_prim					///
						 pre_dizziness_ae						///
						 pre_nausea_vomit_snomed				///
						 pre_nausea_vomit_icd					///
						 pre_nausea_vomit_icd_prim				///
						 pre_headache_snomed					///
						 pre_headache_icd						///
						 pre_headache_icd_prim					///
						 pre_headache_ae						///
						 pre_anaphylaxis_icd_prim				///
						 pre_anaphylaxis_icd					///
						 pre_anaphylaxis_snomed					///						 
						 pre_anaphlaxis_ae						///
						 pre_severedrug_icd						///
						 pre_severedrug_icd_prim				///
						 pre_severedrug_sjs_icd					///
						 pre_severedrug_sjs_icd_prim			///
						 pre_severedrug_snomed					///
						 pre_severedrug_ae						///
					     pre_nonsevere_drug_snomed				///
						 pre_nonsevere_drug_ae					///
						 pre_rheumatoid_icd_prim				///
						 pre_sle_icd_prim						///
						 pre_sle_ctv							///
						 pre_sle_icd							///
						 pre_sle_ae								///
						 pre_rheumatoid_arthritis_icd			///
						 pre_rheumatoid_icd_prim				///
						 pre_rheumatoid_arthritis_ae			///
						 pre_rheumatoid_arthritis_snomed		///
						 pre_psoriasis_icd						///
						 pre_psoriasis_icd_prim					///
						 pre_psoriasis_snomed					///
						 pre_psoriasis_ae						/// 
						 pre_psa_icd							/// 
						 pre_psa_icd_prim						/// 
						 pre_psa_ae								///
						 pre_psa_snomed							///						 
						 pre_axspa_icd							///	
						 pre_axspa_icd_prim						///	
						 pre_axspa_ctv							///
						 pre_axspa_ae							///
						 pre_ibd_ae								///
						 pre_ibd_ctv							///
						 pre_ibd_icd							///
						 pre_ibd_icd_prim						///
						 covid_hosp_discharge 					///
						 any_covid_hosp_discharge 				///
						 preg_36wks_date						///
{					 
	capture confirm string variable `var'
	if _rc==0 {
	rename `var' a
	gen `var' = date(a, "YMD")
	drop a
	format %td `var'
 }
}
tab treatment_dataset
*****************************************************************
*  APPEND DATASETS     *
***************************************************************** 
append using "$projectdir/output/data/control.dta"
duplicates tag patient_id, gen(duplicate_patient_id)
bys patient_id (treatment_dataset duplicate_patient_id): gen n=_n
tab n // should be no one in both datasets
drop if n>1  // drops duplicate patient id and in control group
tab control_dataset,m
tab treatment_dataset,m
count if start_date==.
count if start_date!=covid_test_positive_date & treatment_dataset==1
count if start_date!=covid_test_positive_date & control_dataset==1
gen dataset = 0 if control_dataset==1
replace dataset= 1 if treatment_dataset==1
label define dataset 0 "control" 1 "drug" 
label values dataset dataset

*******************************************************************
*	START AND END DATES	*
*******************************************************************
gen campaign_start=mdy(12,16,2021)
gen study_end_date=mdy(06,26,2023)
gen start_date_29 = start_date + 29
gen study_end_date_29 = study_end_date + 29
format campaign_start study_end_date start_date_29  %td

****************************
*	OUTCOME		*
****************************
*** AESI, IMAE and some Drug reaction 
gen new_ae_ra_icd = ae_rheumatoid_arthritis_icd if rheumatoid_arthritis_nhsd_snomed==0 
gen new_ae_ra_icd_prim = ae_rheumatoid_arthritis_icd_prim if rheumatoid_arthritis_nhsd_snomed==0 
gen new_ae_ra_snomed = ae_rheumatoid_arthritis_snomed if rheumatoid_arthritis_nhsd_snomed==0 
gen new_ae_ra_ae = ae_rheumatoid_arthritis_ae if rheumatoid_arthritis_nhsd_snomed==0
count if rheumatoid_arthritis_nhsd_snomed!=0 
count if ae_rheumatoid_arthritis_icd!=. 
count if new_ae_ra_icd!=.
count if ae_rheumatoid_arthritis_icd_prim!=. 
count if new_ae_ra_icd_prim!=.
count if ae_rheumatoid_arthritis_snomed!=. 
count if new_ae_ra_snomed!=.
count if ae_rheumatoid_arthritis_ae!=. 
count if new_ae_ra_ae!=.
gen new_ae_sle_icd = ae_sle_icd if sle_nhsd_ctv==0 
gen new_ae_sle_icd_prim = ae_sle_icd_prim if sle_nhsd_ctv==0 
gen new_ae_sle_ctv = ae_sle_ctv if sle_nhsd_ctv==0 
gen new_ae_sle_ae = ae_sle_ae if sle_nhsd_ctv==0 
count if sle_nhsd_ctv!=0 
count if ae_sle_icd!=. 
count if new_ae_sle_icd!=.
count if ae_sle_icd_prim!=. 
count if new_ae_sle_icd_prim!=.
count if ae_sle_ctv!=. 
count if new_ae_sle_ctv!=.
count if ae_sle_ae!=. 
count if new_ae_sle_ae!=.
gen new_ae_psoriasis_icd = ae_psoriasis_icd if psoriasis_nhsd==0 
gen new_ae_psoriasis_icd_prim = ae_psoriasis_icd_prim if psoriasis_nhsd==0 
gen new_ae_psoriasis_snomed = ae_psoriasis_snomed if psoriasis_nhsd==0
gen new_ae_psoriasis_ae = ae_psoriasis_ae if psoriasis_nhsd==0
count if psoriasis_nhsd!=0 
count if ae_psoriasis_icd!=. 
count if new_ae_psoriasis_icd!=. 
count if ae_psoriasis_icd_prim!=. 
count if new_ae_psoriasis_icd_prim!=. 
count if ae_psoriasis_snomed!=. 
count if new_ae_psoriasis_snomed!=.
count if ae_psoriasis_ae!=. 
count if new_ae_psoriasis_ae!=.
gen new_ae_psa_icd = ae_psa_icd if psoriatic_arthritis_nhsd==0
gen new_ae_psa_icd_prim = ae_psa_icd_prim if psoriatic_arthritis_nhsd==0
gen new_ae_psa_snomed = ae_psa_snomed if psoriatic_arthritis_nhsd==0
gen new_ae_psa_ae = ae_psa_ae if psoriatic_arthritis_nhsd==0
count if psoriatic_arthritis_nhsd!=0 
count if ae_psa_icd!=. 
count if new_ae_psa_icd!=. 
count if ae_psa_icd_prim!=. 
count if new_ae_psa_icd_prim!=. 
count if ae_psa_snomed!=. 
count if new_ae_psa_snomed!=.
count if ae_psa_ae!=. 
count if new_ae_psa_ae!=.
gen new_ae_axspa_icd = ae_axspa_icd if ankylosing_spondylitis_nhsd==0
gen new_ae_axspa_icd_prim = ae_axspa_icd_prim if ankylosing_spondylitis_nhsd==0
gen new_ae_axspa_ctv = ae_axspa_ctv if ankylosing_spondylitis_nhsd==0
gen new_ae_axspa_ae = ae_axspa_ae if ankylosing_spondylitis_nhsd==0
count if ankylosing_spondylitis_nhsd!=0 
count if ae_axspa_icd!=. 
count if new_ae_axspa_icd!=.
count if ae_axspa_icd_prim!=. 
count if new_ae_axspa_icd_prim!=.
count if ae_axspa_ctv!=. 
count if new_ae_axspa_ctv!=.
count if ae_axspa_ae!=. 
count if new_ae_axspa_ae!=.
gen new_ae_ibd_icd = ae_ibd_icd if ibd_ctv==0
gen new_ae_ibd_icd_prim = ae_ibd_icd_prim if ibd_ctv==0
gen new_ae_ibd_ctv = ae_ibd_ctv if ibd_ctv==0
gen new_ae_ibd_ae = ae_ibd_ae if ibd_ctv==0
count if ibd_ctv!=0 
count if ae_ibd_icd!=. 
count if new_ae_ibd_icd!=.
count if ae_ibd_icd_prim!=. 
count if new_ae_ibd_icd_prim!=.
count if ae_ibd_ctv!=. 
count if new_ae_ibd_ctv!=.
count if ae_ibd_ae!=. 
count if new_ae_ibd_ae!=.
*** comparison of ICD admission primary diagnosis and all diagnoses
count if ae_diverticulitis_icd!=.
count if ae_diverticulitis_icd_prim!=.
count if ae_taste_icd!=.
count if ae_taste_icd_prim!=.
count if ae_rash_icd!=.
count if ae_rash_icd_prim!=.
count if ae_diarrhoea_icd!=.					
count if ae_diarrhoea_icd_prim!=.					
count if ae_diarrhoeal_icd!=.					
count if ae_diarrhoeal_icd_prim!=.
count if ae_contactderm_icd!=.	
count if ae_contactderm_icd_prim!=.
count if ae_dizziness_icd!=.
count if ae_dizziness_icd_prim!=.
count if ae_nausea_vomit_icd!=.
count if ae_nausea_vomit_icd_prim!=.
count if ae_headache_icd!=.
count if ae_headache_icd_prim!=.
count if ae_anaphylaxis_icd!=.
count if ae_anaphylaxis_icd_prim!=.
count if ae_severedrug_icd!=.
count if ae_severedrug_icd_prim!=.
count if ae_severedrug_sjs_icd!=.
count if ae_severedrug_sjs_icd_prim!=.

*** combined all AEs from GP, hosp and A&E
egen ae_diverticulitis = rmin(ae_diverticulitis_snomed ae_diverticulitis_ae ae_diverticulitis_icd_prim)
egen ae_diarrhoea = rmin(ae_diarrhoea_snomed ae_diarrhoea_icd_prim ae_diarrhoeal_icd_prim)
egen ae_taste = rmin(ae_taste_snomed ae_taste_icd_prim)
egen ae_rash = rmin(ae_rash_snomed ae_rash_ae ae_rash_icd_prim)
egen ae_bronchospasm = rmin(ae_bronchospasm_snomed)
egen ae_contactderm = rmin(ae_contactderm_snomed ae_contactderm_icd_prim ae_contactderm_ae)
egen ae_dizziness = rmin(ae_dizziness_snomed ae_dizziness_ae ae_dizziness_icd_prim)
egen ae_nausea_vomit = rmin(ae_nausea_vomit_snomed ae_nausea_vomit_icd_prim)
egen ae_headache = rmin(ae_headache_snomed ae_headache_ae ae_headache_icd_prim)
egen ae_anaphylaxis = rmin(ae_anaphylaxis_snomed ae_anaphlaxis_ae ae_anaphylaxis_icd_prim)
egen ae_drugreaction = rmin(ae_severedrug_icd_prim ae_severedrug_sjs_icd_prim ae_severedrug_snomed ae_severedrug_ae ae_nonsevere_drug_snomed ae_nonsevere_drug_ae)
egen ae_ra = rmin(new_ae_ra_snomed new_ae_ra_icd_prim new_ae_ra_ae)
egen ae_sle = rmin(new_ae_sle_ctv new_ae_sle_icd_prim new_ae_sle_ae)
egen ae_psorasis = rmin(new_ae_psoriasis_icd_prim new_ae_psoriasis_snomed new_ae_psoriasis_ae)
egen ae_psa = rmin(new_ae_psa_icd_prim new_ae_psa_snomed new_ae_psa_ae)
egen ae_axspa = rmin(new_ae_axspa_icd_prim new_ae_axspa_ctv new_ae_axspa_ae)
egen ae_ibd = rmin(new_ae_ibd_icd_prim new_ae_ibd_ctv new_ae_ibd_ae)

*** combined serious AEs from hosp and A&E
egen ae_diverticulitis_serious = rmin(ae_diverticulitis_icd_prim)
egen ae_diarrhoea_serious = rmin(ae_diarrhoea_icd_prim ae_diarrhoeal_icd_prim)
egen ae_taste_serious = rmin(ae_taste_icd_prim)
egen ae_rash_serious = rmin(ae_rash_icd_prim)
egen ae_contactderm_serious = rmin(ae_contactderm_icd_prim)
egen ae_dizziness_serious = rmin(ae_dizziness_icd_prim)
egen ae_nausea_vomit_serious = rmin(ae_nausea_vomit_icd_prim)
egen ae_headache_serious = rmin(ae_headache_icd_prim)
egen ae_anaphylaxis_serious = rmin(ae_anaphylaxis_icd_prim)
egen ae_drugreaction_serious = rmin(ae_severedrug_icd_prim ae_severedrug_sjs_icd_prim)
egen ae_ra_serious = rmin(new_ae_ra_icd_prim)
egen ae_sle_serious = rmin(new_ae_sle_icd_prim)
egen ae_psorasis_serious = rmin(new_ae_psoriasis_icd_prim)
egen ae_psa_serious = rmin(new_ae_psa_icd_prim)
egen ae_axspa_serious = rmin(new_ae_axspa_icd_prim)
egen ae_ibd_serious = rmin(new_ae_ibd_icd_prim)

*** combined AEs by spc, drug and imae				
egen ae_spc_all = rmin(ae_diverticulitis ae_diarrhoea ae_rash ae_taste ae_bronchospasm ae_contactderm ae_dizziness ae_nausea_vomit ae_headache)
egen ae_spc_serious = rmin(ae_diverticulitis_serious ae_diarrhoea_serious ae_taste_serious ae_rash_serious ae_contactderm_serious ae_dizziness_serious ae_nausea_vomit_serious ae_headache_serious)
egen ae_drug_all = rmin(ae_anaphylaxis ae_drugreaction)
egen ae_drug_serious = rmin(ae_anaphylaxis_serious ae_drugreaction_serious)
egen ae_imae_all = rmin(ae_ra ae_sle ae_psorasis ae_psa ae_axspa ae_ibd)
egen ae_imae_serious = rmin(ae_ra_serious ae_sle_serious ae_psorasis_serious ae_psa_serious ae_axspa_serious ae_ibd_serious)
egen ae_all = rmin(ae_spc_all ae_drug_all ae_imae_all)
egen ae_all_serious = rmin(ae_spc_serious ae_drug_serious ae_imae_serious)

*** global all ae
global ae_disease			ae_diverticulitis 				///
							ae_diarrhoea					///
							ae_taste 						///
							ae_rash 						///
							ae_bronchospasm					///
							ae_contactderm					///
							ae_dizziness					///
							ae_nausea_vomit					///
							ae_headache						///
							ae_anaphylaxis 					///
							ae_drugreaction					///
							ae_ra 							///
							ae_sle 							///
							ae_psorasis 					///
							ae_psa 							///
							ae_axspa 						///
							ae_ibd 						
global ae_disease_serious	ae_diverticulitis_serious 		///
							ae_diarrhoea_serious			///
							ae_taste_serious 				///
							ae_rash_serious 				///
							ae_contactderm_serious			///
							ae_dizziness_serious			///
							ae_nausea_vomit_serious			///
							ae_headache_serious				///
							ae_anaphylaxis_serious			///
							ae_drugreaction_serious			///
							ae_ra_serious 					///
							ae_sle_serious 					///
							ae_psorasis_serious 			///
							ae_psa_serious					///
							ae_axspa_serious				///
							ae_ibd_serious 						
global ae_combined			ae_all							///
							ae_all_serious  				///
							ae_spc_all 						///
							ae_spc_serious					///
							ae_drug_all						///
							ae_drug_serious					///
							ae_imae_all						///	
							ae_imae_serious	

****************************
*	COVARIATES		*
****************************
* Demographics*
* Age
sum age, det
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
tab sex
* Ethnicity
tab ethnicity,m
rename ethnicity ethnicity_str
encode  ethnicity_str, gen(ethnicity)
label list ethnicity
replace ethnicity=. if ethnicity==2 
tab ethnicity				
gen ethnicity_with_missing=ethnicity
replace ethnicity_with_missing=9 if ethnicity_with_missing==.
label define ethnicity_with_missing 1 "Black" 3 "Mixed" 4 "Other" 5 "South Asian" 6 "White" 9 "Missing", replace
label values ethnicity_with_missing ethnicity_with_missing
tab ethnicity_with_missing
gen White=1 if ethnicity==6
replace White=0 if ethnicity!=6&ethnicity!=.
tab White
gen White_with_missing=White
replace White_with_missing=9 if White==.
tab White_with_missing
* IMD
tab imdq5,m
replace imdq5="." if imdq5=="Unknown" 
replace imdq5="1" if imdq5=="1 (most deprived)" 
replace imdq5="5" if imdq5=="5 (least deprived)" 
destring imdq5, replace
recode imdq5 5 = 1 4 = 2 3 = 3 2 = 4 1 = 5 // Reverse the order (so 5 is more deprived)
label define imdq5 1 "1 least deprived" 2 "2" 3 "3" 4 "4" 5 "5 most deprived", replace
label values imdq5 imdq5
gen imd_with_missing=imdq5
replace imd_with_missing=9 if imdq5==.
tab imdq5,m
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
* Other comorbidites
tab autism,m
tab care_home,m
tab dementia_all,m
tab learning_disability,m
tab autism,m
tab serious_mental_illness,m
gen dementia = 1 if dementia_all==1 & age >39
recode dementia .=0 
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
* time between vaccine and covid positive test or treatment
gen days_vacc_covid=covid_test_positive_date - last_vaccination_date if (covid_test_positive_date>last_vaccination_date)
sum days_vacc_covid,de
gen days_vacc_treat=date_treated - last_vaccination_date if (date_treated>last_vaccination_date)
sum days_vacc_treat,de
gen month_vacc_covid=ceil(days_vacc_covid/30)
gen month_vacc_treat=ceil(days_vacc_treat/30)
tab month_vacc_covid,m
*Calendar time*
gen day_after_campaign=start_date-mdy(12,15,2021)
sum day_after_campaign,de
gen month_after_campaign=ceil((start_date-mdy(12,15,2021))/30)
tab month_after_campaign,m
tab start_date if month_after_campaign>100
//drop if month_after_campaign>100
* Prior infection / check Bang code
tab prior_covid, m
gen prior_covid_index=1 if prior_covid==1 & prior_covid_date<campaign_start
tab prior_covid_index,m
replace prior_covid_index=0 if prior_covid_index==.
* Calculating egfr: adapted from https://github.com/opensafely/COVID-19-vaccine-breakthrough/blob/updates-feb/analysis/data_process.R*
tabstat creatinine_ctv3, stat(mean p25 p50 p75 min max) 
replace creatinine_ctv3=. if !inrange(creatinine_ctv3, 20, 3000)|creatinine_ctv3_date>start_date
tabstat creatinine_ctv3, stat(mean p25 p50 p75 min max) 
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
gen egfr_60 = 1 if (egfr_creatinine_ctv3<60&creatinine_operator_ctv3!="<")|(egfr_creatinine_snomed<60&creatinine_operator_snomed!="<")|(egfr_record<60&egfr_record>0&egfr_operator!=">"&egfr_operator!=">=")|(egfr_short_record<60&egfr_short_record>0&egfr_short_operator!=">"&egfr_short_operator!=">=")
gen egfr_30 = 1 if (egfr_creatinine_ctv3<30&creatinine_operator_ctv3!="<")|(egfr_creatinine_snomed<30&creatinine_operator_snomed!="<")|(egfr_record<30&egfr_record>0&egfr_operator!=">"&egfr_operator!=">=")|(egfr_short_record<30&egfr_short_record>0&egfr_short_operator!=">"&egfr_short_operator!=">=")
count if egfr_60==1
count if egfr_30==1
*Paxlovid interactions*
count if drugs_paxlovid_contraindication<=start_date
count if drugs_paxlovid_contraindication<=start_date&drugs_paxlovid_contraindication>=(start_date-3*365.25)
count if drugs_paxlovid_contraindication<=start_date&drugs_paxlovid_contraindication>=(start_date-365.25)
count if drugs_paxlovid_contraindication<=start_date&drugs_paxlovid_contraindication>=(start_date-180)
gen drugs_paxlovid_cont=(drugs_paxlovid_contraindication<=start_date&drugs_paxlovid_contraindication>=(start_date-180))  
* Drug contraindicated 
gen paxlovid_contraindicated = 1 if egfr_30==1 | dialysis==1
replace paxlovid_contraindicated = 1 if liver_disease==1 
replace paxlovid_contraindicated = 1 if organ_transplant==1 
replace paxlovid_contraindicated = 1 if drugs_paxlovid_contraindication<=start_date&drugs_paxlovid_contraindication>=(start_date-180)
recode paxlovid_contraindicated . = 0
count if paxlovid_contraindicated==1

********************************************************
*	INCLUSION ONLY WITH POSITIVE COVID TEST	*
********************************************************
** inclusion criteria*
keep if age>=18 & age<110
keep if sex==0 | sex==1
keep if has_died==0
tab dataset

** exclusion criteria*
count if start_date!=.
count if start_date>dereg_date & start_date!=.
count if start_date>death_date & start_date!=.
//drop if start_date>death_date | start_date>dereg_date
//drop if start_date>study_end_date
tab dataset

** positive covid test
count if covid_test_positive_date!=.
count if covid_test_positive_date==.
keep if covid_test_positive_date!=.

** check covid positive and not repeat covid test after an infection within 30 days prior
tab covid_positive_previous_30_days 
drop if covid_positive_previous_30_days==1

********************************************************
*	EXPOSURE		*
********************************************************
** removing individuals who did not have a covid test within 5 days of treatment
tab dataset
gen pre_drug_test_time = date_treated-covid_test_positive_date if dataset==1
sum pre_drug_test_time, det 
gen pre_drug_test=0 if dataset==1 & pre_drug_test_time==0
replace pre_drug_test=1 if dataset==1 & pre_drug_test_time==1
replace pre_drug_test=2 if dataset==1 & pre_drug_test_time==2
replace pre_drug_test=3 if dataset==1 & pre_drug_test_time==3
replace pre_drug_test=4 if dataset==1 & pre_drug_test_time==4
replace pre_drug_test=5 if dataset==1 & pre_drug_test_time==5
replace pre_drug_test=6 if dataset==1 & pre_drug_test_time>=6 & pre_drug_test_time<=7
replace pre_drug_test=7 if dataset==1 & pre_drug_test_time>=7 & pre_drug_test_time<=21
replace pre_drug_test=8 if dataset==1 & pre_drug_test_time<0 | pre_drug_test_time>21
replace pre_drug_test=9 if dataset==1 & (covid_test_positive_date==. | date_treated==.) & dataset==1
label define pre_drug_test 0 "0 days" 1 "1 days" 2 "2 days" 3 "3 days" 4 "4 days" 5 "5 days" 6 "6-7 days" 7 ">7 days & <21 days" 8 ">21 or <0 days" 9 "no test/no treatment date", replace 
label values pre_drug_test pre_drug_test
tab pre_drug_test_time if pre_drug_test<=5
tab pre_drug_test dataset,m
count if dataset==1 & pre_drug_test>5
// drop if dataset==1 & pre_drug_test>5
sum pre_drug_test_time, det

**delay between covid test and treatment 
gen covid_test_5d = 1 if pre_drug_test<=5 & dataset==1
egen median_delay_treatment =  median(date_treated - covid_test_positive_date) if covid_test_5d==1
egen median_delay_all= max(median_delay_treatment)

** removing individuals who did not start therapy
tab treatment_dataset 
count if date_treated!=.
foreach var of varlist sotrovimab molnupiravir paxlovid {
    display "`var'"
	count if `var'!=.
	count if `var'==date_treated & `var'!=. & date_treated!=.
	count if `var'==date_treated & `var'!=. & date_treated!=. & `var'_not_start!=.
	gen `var'_start = 1 if `var'==date_treated & `var'!=. & date_treated!=. & `var'_not_start==.
	replace `var'_start = 0 if `var'==date_treated & `var'!=. & date_treated!=. & `var'_not_start!=.
	tab `var'_start, m  
}
* remove if had remdesivir or casirivimab
gen drug=7 if remdesivir==date_treated&remdesivir!=.&date_treated!=.
replace drug=8 if casirivimab==date_treated&casirivimab!=.&date_treated!=.
tab drug,m 
* patient who started sotrovimab, paxlovid, molnupiravir 
replace drug=1 if sotrovimab_start==1 
replace drug=2 if paxlovid_start==1
replace drug=3 if molnupiravir_start==1
tab drug,m 
* remove if didnt start sotrovimab, paxlovid, molnupiravir 
replace drug=4 if sotrovimab_start==0 
replace drug=5 if paxlovid_start==0
replace drug=6 if molnupiravir_start==0
tab drug,m 
* remove if had 2 treatment codes on start date
gen two_drugs= 1 if sotrovimab_start==1 & paxlovid_start==1
replace two_drugs=2 if sotrovimab_start==1 & molnupiravir_start==1
replace two_drugs=3 if paxlovid_start==1 & molnupiravir_start==1
replace two_drugs=4 if sotrovimab_start==1 & paxlovid_start==1 & molnupiravir_start==1
tab two_drug
replace drug=9 if two_drugs!=.
tab drug,m 
replace drug=0 if drug==.
label define drug 0 "control" 1 "sotrovimab" 2 "paxlovid" 3"molnupiravir" 4 "sotrovimab not started" 5 "paxlovid not started" 6 "molnupiravir not started" 7 "remdesivir" 8 "casirivimab" 9 "combination treatment", replace
label values drug drug
tab drug, m
* for flow sheet for treatment arm
bys dataset: tab drug,m  
drop if drug>0 & dataset==0
drop if drug==0 & dataset==1
bys dataset: tab drug,m  
* drop if i) treatment not started ii) combination treatment iii) remdesivir or casirivimab
drop if drug>3 & dataset==1
bys dataset: tab drug,m 

********************************************************
*	CONTROL		*
********************************************************
** cleaning eligibility criteria - ensure IMID on drug >4 pred scripts
tab high_risk_cohort_nhsd,m 
tab high_risk_cohort_nhsd drug
count if imid_on_drug==1 & imid_nhsd==1 & imid_drug==0 //should be 0
count if imid_on_drug==1 & imid_nhsd==0 & imid_drug==1 //should be 0
count if imid_on_drug==1 & imid_nhsd==1 & imid_drug==1 & downs_syndrome==0 &solid_cancer==0 &haem_disease==0 &renal_disease==0 &liver_disease==0 &immunosuppression==0 &hiv_aids==0 &organ_transplant==0 &rare_neuro==0
count if oral_steroid_drug_nhsd_6m_count<4 &oral_steroid_drugs_nhsd==1
count if oral_steroid_drug_nhsd_6m_count<4 &oral_steroid_drugs_nhsd==1 &immunosuppresant==0 &methotrexate==0 &ciclosporin==0 &mycophenolate==0 
count if oral_steroid_drug_nhsd_6m_count<4 &oral_steroid_drugs_nhsd==1 &immunosuppresant==0 &methotrexate==0 &ciclosporin==0 &mycophenolate==0 &imid_on_drug==1
count if oral_steroid_drug_nhsd_6m_count<4 &oral_steroid_drugs_nhsd==1 &immunosuppresant==0 &methotrexate==0 &ciclosporin==0 &mycophenolate==0 &imid_on_drug==1 &downs_syndrome==0 &solid_cancer==0 &haem_disease==0 &renal_disease==0 &liver_disease==0 &immunosuppression==0 &hiv_aids==0 &organ_transplant==0 &rare_neuro==0
count if oral_steroid_drug_nhsd_6m_count<4 &oral_steroid_drugs_nhsd==1 &immunosuppresant==0 &methotrexate==0 &ciclosporin==0 &mycophenolate==0 &imid_on_drug==1 &downs_syndrome==0 &solid_cancer==0 &haem_disease==0 &renal_disease==0 &liver_disease==0 &immunosuppression==0 &hiv_aids==0 &organ_transplant==0 &rare_neuro==0&dataset==0
replace imid_drug=0 if oral_steroid_drug_nhsd_6m_count<4 &oral_steroid_drugs_nhsd==1 &immunosuppresant==0 &methotrexate==0 &ciclosporin==0 &mycophenolate==0 &imid_on_drug==1 //ignore if steriods<4 scripts in 6m & not coded other imid drug 
replace oral_steroid_drugs_nhsd=0 if oral_steroid_drug_nhsd_6m_count<4 &oral_steroid_drugs_nhsd==1 //ignore if steriods<4 scripts in 6m
count if imid_on_drug==1 & imid_nhsd==1 & imid_drug==0 
replace imid_on_drug=0 if imid_nhsd==1 & imid_drug==0 //ignore if steriods<4 & not coded other imid drug 
replace imid_on_drug=0 if imid_nhsd==0 & imid_drug==1 
gen high_risk_cohort_codelist=((downs_syndrome + solid_cancer + haem_disease + renal_disease + liver_disease + imid_on_drug + immunosuppression + hiv_aids + organ_transplant + rare_neuro )>0)
tab high_risk_cohort_codelist dataset,m 
drop if high_risk_cohort_codelist==0 & dataset==0 //should be same number dropped as change above 
tab high_risk_cohort_codelist dataset

** cleaning ensure not hospitalised or discharge on day on covid test 
bys dataset: tab drug,m 
count if drug==0 & start_date==covid_test_positive_date
count if drug==0 & start_date!=covid_test_positive_date
** control patient ever hospitalised 
count if drug==0 & pre_covid_hosp_date!=. 
** control patient  hospitalised on day of positive test
count if drug==0 & covid_test_positive_date==pre_covid_hosp_date
** control patient hospitalised & still in hospital (not discharged)
count if drug==0 & pre_covid_hosp_date!=. & pre_covid_hosp_discharge==. 
count if drug==0 & pre_covid_hosp_date!=. & pre_covid_hosp_discharge==. & (start_date-pre_covid_hosp_date<29)
count if drug==0 & pre_covid_hosp_date!=. & pre_covid_hosp_discharge==. & (start_date-pre_covid_hosp_date<366)
** control patient, hospitalised & still in hospital (not discharged) - discharge date preceed admission
count if drug==0 & pre_covid_hosp_date>pre_covid_hosp_discharge & pre_covid_hosp_date!=. & pre_covid_hosp_discharge!=.
count if drug==0 & pre_covid_hosp_date>pre_covid_hosp_discharge & pre_covid_hosp_date!=. & pre_covid_hosp_discharge!=. & (start_date-pre_covid_hosp_date<29)
count if drug==0 & pre_covid_hosp_date>pre_covid_hosp_discharge & pre_covid_hosp_date!=. & pre_covid_hosp_discharge!=. & (start_date-pre_covid_hosp_date<366)
** control patient discharged on day of positive covid test 
count if drug==0 & covid_test_positive_date==pre_covid_hosp_discharge
** control patient's discharged 1 day before positive covid test 
count if drug==0 & (covid_test_positive_date-pre_covid_hosp_discharge<=1) & (covid_test_positive_date-pre_covid_hosp_discharge>=0)
* for flow sheet for treatment arm
** remove if hospitalised on day of positive test
drop if drug==0 & covid_test_positive_date==pre_covid_hosp_date
** remove if discharged on day of positive covid test 
drop if drug==0 & covid_test_positive_date==pre_covid_hosp_discharge
** remove if control patient's covid test is on discharge date
drop if drug==0 & (covid_test_positive_date-pre_covid_hosp_discharge<=1) & (covid_test_positive_date-pre_covid_hosp_discharge>=0)
bys dataset: tab drug,m 

** high risk cohort from blueteq therapeutics 
tab high_risk_cohort_therapeutics dataset,m 
gen downs_syndrome_therap= 1 if strpos(high_risk_cohort_therapeutics, "Downs syndrome")
gen solid_cancer_therap=1 if strpos(high_risk_cohort_therapeutics, "solid cancer")
gen haem_disease_therap=1 if strpos(high_risk_cohort_therapeutics, "haematological malignancies")
replace haem_disease_therap=1 if strpos(high_risk_cohort_therapeutics, "haematologic malignancy")
replace haem_disease_therap=1 if strpos(high_risk_cohort_therapeutics, "sickle cell disease")
replace haem_disease_therap=1 if strpos(high_risk_cohort_therapeutics, "haematological diseases")
replace haem_disease_therap=1 if strpos(high_risk_cohort_therapeutics, "stem cell transplant")
gen renal_disease_therap= 1 if strpos(high_risk_cohort_therapeutics, "renal disease")
gen liver_disease_therap= 1 if strpos(high_risk_cohort_therapeutics, "liver disease")
gen imid_on_drug_therap= 1 if strpos(high_risk_cohort_therapeutics, "IMID")
gen immunosuppression_therap= 1 if strpos(high_risk_cohort_therapeutics, "primary immune deficiencies")
gen hiv_aids_therap= 1 if strpos(high_risk_cohort_therapeutics, "HIV or AIDS")
gen organ_transplant_therap= 1 if strpos(high_risk_cohort_therapeutics, "solid organ recipients")
replace organ_transplant_therap= 1 if strpos(high_risk_cohort_therapeutics, "solid organ transplant")
gen rare_neuro_therap= 1 if strpos(high_risk_cohort_therapeutics, "rare neurological conditions")
count if high_risk_cohort_therapeutics!=""&high_risk_cohort_therapeutics!="other"& min(downs_syndrome_therap,solid_cancer_therap,haem_disease_therap,renal_disease_therap,liver_disease_therap,imid_on_drug_therap,immunosuppression_therap,hiv_aids_therap,organ_transplant_therap,rare_neuro_therap)==. //check if all diseases have been captured
tab high_risk_cohort_therapeutics if high_risk_cohort_therapeutics!=""&high_risk_cohort_therapeutics!="other"& min(downs_syndrome_therap,solid_cancer_therap,haem_disease_therap,renal_disease_therap,liver_disease_therap,imid_on_drug_therap,immunosuppression_therap,hiv_aids_therap,organ_transplant_therap,rare_neuro_therap)==.
gen high_risk_cohort_ther= 1 if high_risk_cohort_therapeutics!=""&high_risk_cohort_therapeutics!="other"
foreach var of varlist downs_syndrome_therap solid_cancer_therap haem_disease_therap renal_disease_therap liver_disease_therap imid_on_drug_therap immunosuppression_therap hiv_aids_therap organ_transplant_therap rare_neuro_therap{
	replace `var'=0 if `var'==. 
}
** combine two high risk cohorts into one 
foreach var of varlist downs_syndrome solid_cancer haem_disease renal_disease liver_disease imid_on_drug immunosuppression hiv_aids organ_transplant rare_neuro {
	gen `var'_comb = `var'
	replace `var'_comb = 1 if `var'_therap==1 
	tab `var' `var'_therap 
	tab dataset `var'_comb
}
gen eligible = 0 if downs_syndrome_comb==.&solid_cancer_comb==.& haem_disease_comb==.& renal_disease_comb==.& liver_disease_comb==.& imid_on_drug_comb==.& immunosuppression_comb==.& hiv_aids_comb==.& organ_transplant_comb==.& rare_neuro_comb==. 
recode eligible . = 1
tab drug eligible

********************************************************
* FINAL NUMBERS 		*
********************************************************
tab dataset
tab drug
tab drug paxlovid_contraindicated
tab drug pre_drug_test
tab drug eligible
bys drug: sum pre_drug_test_time, det
gen covid_test = 1 if pre_drug_test<=5
replace covid_test = 1 if drug==0 
replace covid_test = 0 if covid_test==.
tab drug covid_test

********************************************************
*	START DATE		*
********************************************************
** start date = covid test in control arm 
** start date = covid test in treatment arm 
count if start_date==.
count if start_date!=covid_test_positive_date & drug==0  
count if start_date!=covid_test_positive_date & drug>0 
foreach x in $ae_disease $ae_disease_serious $ae_combined {
				display "`x'"
				count if (`x' > start_date | `x' < start_date + 29) & `x'!=. 
				count if (`x' < start_date | `x' > start_date + 29) & `x'!=. & drug==0
				count if (`x' < start_date | `x' > start_date + 29) & `x'!=. & drug>0
}

********************************************************
*	COX MODEL		*
********************************************************
* Generate failure 
foreach x in  $ae_disease $ae_disease_serious $ae_combined{
	display "`x'"
	by drug, sort: count if `x'!=.
	by drug, sort: count if `x'>=start_date & `x'!=.
	by drug, sort: count if `x'>=start_date & `x'<start_date_29 &`x'!=.
	gen fail_`x'=(`x'!=.&`x'<= min(study_end_date_29, start_date_29, paxlovid, molnupiravir)) if drug==1
	replace fail_`x'=(`x'!=.&`x'<= min(study_end_date_29, start_date_29, sotrovimab, molnupiravir)) if drug==2
	replace fail_`x'=(`x'!=.&`x'<= min(study_end_date_29, start_date_29, sotrovimab, paxlovid)) if drug==3
	replace fail_`x'=(`x'!=.&`x'<= min(study_end_date_29, start_date_29, sotrovimab, paxlovid, molnupiravir)) if drug==0
	tab drug fail_`x', m
}
* Add half-day buffer if outcome on indexdate
foreach x in  $ae_disease $ae_disease_serious $ae_combined{
	display "`x'"
	replace `x'=`x'+0.75 if `x'==start_date
}
*Generate censor date
foreach x in  $ae_disease $ae_disease_serious $ae_combined{
	gen stop_`x'=`x' if fail_`x'==1
	replace stop_`x'=min(death_date,dereg_date,study_end_date_29,start_date_29,paxlovid,molnupiravir) if fail_`x'==0&drug==1
	replace stop_`x'=min(death_date,dereg_date,study_end_date_29,start_date_29,sotrovimab,molnupiravir) if fail_`x'==0&drug==2
	replace stop_`x'=min(death_date,dereg_date,study_end_date_29,start_date_29,sotrovimab,paxlovid) if fail_`x'==0&drug==3
	replace stop_`x'=min(death_date,dereg_date,study_end_date_29,start_date_29,sotrovimab,paxlovid,molnupiravir) if fail_`x'==0&drug==0
	format %td stop_`x'
}
* Follow-up time
foreach x in $ae_combined{
	stset stop_`x', id(patient_id) origin(time start_date) enter(time start_date) failure(fail_`x'==1) 
	tab _st  
	tab _t drug if fail_`x'==1 & stop_`x'==`x'
	tab _t drug if fail_`x'==0 &_t<28 & stop_`x'==death_date,m col
	tab _t drug if fail_`x'==0 &_t<28 & stop_`x'==dereg_date,m col
	tab _t drug if fail_`x'==0 &_t<28 & stop_`x'==min(paxlovid,molnupiravir) & drug==1,m col
	tab _t drug if fail_`x'==0 &_t<28 & stop_`x'==min(sotrovimab,molnupiravir) & drug==2,m col
	tab _t drug if fail_`x'==0 &_t<28 & stop_`x'==min(sotrovimab,paxlovid) & drug==3,m col
	tab _t drug if fail_`x'==0 &_t<28 & stop_`x'==min(sotrovimab,paxlovid,molnupiravir) &drug==0,m col
}
save "$projectdir/output/data/main.dta", replace






***********************************************************************************************************************
**			SENSITIVITY ANALYSIS			**
***********************************************************************************************************************

* import treatment_sensitvity dataset - includes those without positive covid test 
import delimited "$projectdir/output/input_treatment_sensitivity.csv", clear
gen treatment_dataset=1
drop variant_recorded
drop sgtf

*	Convert control strings to dates     * 
foreach var of varlist 	 pre_covid_hosp_date					///
						 pre_covid_hosp_discharge				///
						 covid_test_positive_date				///
						 covid_test_positive_date2 				///
						 covid_test_positive_date3 				///
						 covid_test_positive_treat				///
						 prior_covid_date				    	///
						 sotrovimab								///
						 molnupiravir							/// 
						 paxlovid								///
						 remdesivir								///
						 casirivimab							///
						 sotrovimab_not_start					///
						 molnupiravir_not_start					///
						 paxlovid_not_start						///
						 date_treated							///
						 start_date								///
						 drugs_paxlovid_interaction				///
						 drugs_nirmatrelvir_interaction			///
						 drugs_paxlovid_contraindication		///
						 last_vaccination_date 					///
						 death_date								///
						 dereg_date 							///
						 bmi_date_measured						///
						 creatinine_ctv3_date 					///
						 creatinine_snomed_date					///
						 creatinine_short_snomed_date			///
						 ae_diverticulitis_icd					///
						 ae_diverticulitis_icd_prim				///
						 ae_diverticulitis_snomed				///
						 ae_diverticulitis_ae					///			 
						 ae_diarrhoea_snomed					///
						 ae_diarrhoea_icd						///
						 ae_diarrhoea_icd_prim					///
						 ae_diarrhoeal_icd						///
						 ae_diarrhoeal_icd_prim					///		 
						 ae_taste_snomed						///
						 ae_taste_icd							///
						 ae_taste_icd_prim						///
						 ae_rash_snomed							///
						 ae_rash_ae								///
						 ae_rash_icd							///
						 ae_rash_icd_prim						///		 
						 ae_bronchospasm_snomed					///
						 ae_contactderm_snomed					///
						 ae_contactderm_icd						///
						 ae_contactderm_icd_prim				///
						 ae_contactderm_ae						///
						 ae_dizziness_snomed					///
						 ae_dizziness_icd						///
						 ae_dizziness_icd_prim					///
						 ae_dizziness_ae						///
						 ae_nausea_vomit_snomed					///
						 ae_nausea_vomit_icd					///
						 ae_nausea_vomit_icd_prim				///
						 ae_headache_snomed						///
						 ae_headache_icd						///
						 ae_headache_icd_prim					///
						 ae_headache_ae							///
						 ae_anaphylaxis_icd						///
					     ae_anaphylaxis_icd_prim				///
					     ae_anaphylaxis_snomed					///
						 ae_anaphlaxis_ae						///
						 ae_severedrug_icd						///
						 ae_severedrug_icd_prim					///
						 ae_severedrug_sjs_icd					///
						 ae_severedrug_sjs_icd_prim				///
						 ae_severedrug_snomed					///
						 ae_severedrug_ae						///
						 ae_nonsevere_drug_snomed				///
						 ae_nonsevere_drug_ae					///
						 ae_rheumatoid_arthritis_icd			///
						 ae_rheumatoid_arthritis_icd_prim		///
						 ae_rheumatoid_arthritis_snomed			///
						 ae_rheumatoid_arthritis_ae				///
						 ae_sle_icd								///
						 ae_sle_icd_prim						///
						 ae_sle_ae								///
						 ae_sle_ctv								///
						 ae_psoriasis_icd						///
						 ae_psoriasis_icd_prim					///
						 ae_psoriasis_ae						///
						 ae_psoriasis_snomed					///
						 ae_psa_icd								///
						 ae_psa_icd_prim						///
						 ae_psa_snomed							///
						 ae_psa_ae								///
						 ae_psa_snomed							///
						 ae_axspa_icd							///
						 ae_axspa_icd_prim						///
						 ae_axspa_ctv							///
						 ae_axspa_ae							///
						 ae_ibd_icd								///
						 ae_ibd_icd_prim						///
						 ae_ibd_ctv								///
						 ae_ibd_ae								///
						 pre_diverticulitis_icd					///
						 pre_diverticulitis_icd_prim			///
						 pre_diverticulitis_snomed				///
						 pre_diverticulitis_ae					///
						 pre_diarrhoea_snomed 					///
						 pre_diarrhoea_icd						///
						 pre_diarrhoea_icd_prim					///
						 pre_diarrhoeal_icd						///
						 pre_diarrhoeal_icd_prim				///
						 pre_taste_icd							///
						 pre_taste_icd_prim						///
						 pre_taste_snomed						///
						 pre_rash_snomed						///
						 pre_rash_ae							///
						 pre_rash_icd							///
						 pre_rash_icd_prim 						///
						 pre_bronchospasm_snomed				///
						 pre_contactderm_snomed					///
						 pre_contactderm_icd					///
						 pre_contactderm_icd_prim				///
						 pre_contactderm_ae						///
						 pre_dizziness_snomed					///
						 pre_dizziness_icd						///
						 pre_dizziness_icd_prim					///
						 pre_dizziness_ae						///
						 pre_nausea_vomit_snomed				///
						 pre_nausea_vomit_icd					///
						 pre_nausea_vomit_icd_prim				///
						 pre_headache_snomed					///
						 pre_headache_icd						///
						 pre_headache_icd_prim					///
						 pre_headache_ae						///
						 pre_anaphylaxis_icd_prim				///
						 pre_anaphylaxis_icd					///
						 pre_anaphylaxis_snomed					///						 
						 pre_anaphlaxis_ae						///
						 pre_severedrug_icd						///
						 pre_severedrug_icd_prim				///
						 pre_severedrug_sjs_icd					///
						 pre_severedrug_sjs_icd_prim			///
						 pre_severedrug_snomed					///
						 pre_severedrug_ae						///
					     pre_nonsevere_drug_snomed				///
						 pre_nonsevere_drug_ae					///
						 pre_rheumatoid_icd_prim				///
						 pre_sle_icd_prim						///
						 pre_sle_ctv							///
						 pre_sle_icd							///
						 pre_sle_ae								///
						 pre_rheumatoid_arthritis_icd			///
						 pre_rheumatoid_icd_prim				///
						 pre_rheumatoid_arthritis_ae			///
						 pre_rheumatoid_arthritis_snomed		///
						 pre_psoriasis_icd						///
						 pre_psoriasis_icd_prim					///
						 pre_psoriasis_snomed					///
						 pre_psoriasis_ae						/// 
						 pre_psa_icd							/// 
						 pre_psa_icd_prim						/// 
						 pre_psa_ae								///
						 pre_psa_snomed							///						 
						 pre_axspa_icd							///	
						 pre_axspa_icd_prim						///	
						 pre_axspa_ctv							///
						 pre_axspa_ae							///
						 pre_ibd_ae								///
						 pre_ibd_ctv							///
						 pre_ibd_icd							///
						 pre_ibd_icd_prim						///
						 covid_hosp_discharge 					///
						 any_covid_hosp_discharge 				///
						 preg_36wks_date						///
{					 
	capture confirm string variable `var'
	if _rc==0 {
	rename `var' a
	gen `var' = date(a, "YMD")
	drop a
	format %td `var'
}
}
tab treatment_dataset

*****************************************************************
*  SENSITIVITY APPEND DATASETS     *
***************************************************************** 
append using "$projectdir/output/data/control.dta"
duplicates tag patient_id, gen(duplicate_patient_id)
bys patient_id (treatment_dataset duplicate_patient_id): gen n=_n
tab n // should be no one in both datasets
drop if n>1  // drops duplicate patient id and in control group
tab control_dataset,m
tab treatment_dataset,m
count if start_date==.
count if start_date!=covid_test_positive_date & treatment_dataset==1
count if start_date!=covid_test_positive_date & control_dataset==1
gen dataset = 0 if control_dataset==1
replace dataset= 1 if treatment_dataset==1
label define dataset 0 "control" 1 "drug" 
label values dataset dataset

*******************************************************************
*	SENSITIVITY START AND END DATES	*
*******************************************************************
gen campaign_start=mdy(12,16,2021)
gen study_end_date=mdy(06,26,2023)
gen start_date_29 = start_date + 29
gen study_end_date_29 = study_end_date + 29
format campaign_start study_end_date start_date_29  %td

****************************
*	SENSITIVITY OUTCOME		*
****************************
*** AESI, IMAE and some Drug reaction 
gen new_ae_ra_icd = ae_rheumatoid_arthritis_icd if rheumatoid_arthritis_nhsd_snomed==0 
gen new_ae_ra_icd_prim = ae_rheumatoid_arthritis_icd_prim if rheumatoid_arthritis_nhsd_snomed==0 
gen new_ae_ra_snomed = ae_rheumatoid_arthritis_snomed if rheumatoid_arthritis_nhsd_snomed==0 
gen new_ae_ra_ae = ae_rheumatoid_arthritis_ae if rheumatoid_arthritis_nhsd_snomed==0
count if rheumatoid_arthritis_nhsd_snomed!=0 
count if ae_rheumatoid_arthritis_icd!=. 
count if new_ae_ra_icd!=.
count if ae_rheumatoid_arthritis_icd_prim!=. 
count if new_ae_ra_icd_prim!=.
count if ae_rheumatoid_arthritis_snomed!=. 
count if new_ae_ra_snomed!=.
count if ae_rheumatoid_arthritis_ae!=. 
count if new_ae_ra_ae!=.
gen new_ae_sle_icd = ae_sle_icd if sle_nhsd_ctv==0 
gen new_ae_sle_icd_prim = ae_sle_icd_prim if sle_nhsd_ctv==0 
gen new_ae_sle_ctv = ae_sle_ctv if sle_nhsd_ctv==0 
gen new_ae_sle_ae = ae_sle_ae if sle_nhsd_ctv==0 
count if sle_nhsd_ctv!=0 
count if ae_sle_icd!=. 
count if new_ae_sle_icd!=.
count if ae_sle_icd_prim!=. 
count if new_ae_sle_icd_prim!=.
count if ae_sle_ctv!=. 
count if new_ae_sle_ctv!=.
count if ae_sle_ae!=. 
count if new_ae_sle_ae!=.
gen new_ae_psoriasis_icd = ae_psoriasis_icd if psoriasis_nhsd==0 
gen new_ae_psoriasis_icd_prim = ae_psoriasis_icd_prim if psoriasis_nhsd==0 
gen new_ae_psoriasis_snomed = ae_psoriasis_snomed if psoriasis_nhsd==0
gen new_ae_psoriasis_ae = ae_psoriasis_ae if psoriasis_nhsd==0
count if psoriasis_nhsd!=0 
count if ae_psoriasis_icd!=. 
count if new_ae_psoriasis_icd!=. 
count if ae_psoriasis_icd_prim!=. 
count if new_ae_psoriasis_icd_prim!=. 
count if ae_psoriasis_snomed!=. 
count if new_ae_psoriasis_snomed!=.
count if ae_psoriasis_ae!=. 
count if new_ae_psoriasis_ae!=.
gen new_ae_psa_icd = ae_psa_icd if psoriatic_arthritis_nhsd==0
gen new_ae_psa_icd_prim = ae_psa_icd_prim if psoriatic_arthritis_nhsd==0
gen new_ae_psa_snomed = ae_psa_snomed if psoriatic_arthritis_nhsd==0
gen new_ae_psa_ae = ae_psa_ae if psoriatic_arthritis_nhsd==0
count if psoriatic_arthritis_nhsd!=0 
count if ae_psa_icd!=. 
count if new_ae_psa_icd!=. 
count if ae_psa_icd_prim!=. 
count if new_ae_psa_icd_prim!=. 
count if ae_psa_snomed!=. 
count if new_ae_psa_snomed!=.
count if ae_psa_ae!=. 
count if new_ae_psa_ae!=.
gen new_ae_axspa_icd = ae_axspa_icd if ankylosing_spondylitis_nhsd==0
gen new_ae_axspa_icd_prim = ae_axspa_icd_prim if ankylosing_spondylitis_nhsd==0
gen new_ae_axspa_ctv = ae_axspa_ctv if ankylosing_spondylitis_nhsd==0
gen new_ae_axspa_ae = ae_axspa_ae if ankylosing_spondylitis_nhsd==0
count if ankylosing_spondylitis_nhsd!=0 
count if ae_axspa_icd!=. 
count if new_ae_axspa_icd!=.
count if ae_axspa_icd_prim!=. 
count if new_ae_axspa_icd_prim!=.
count if ae_axspa_ctv!=. 
count if new_ae_axspa_ctv!=.
count if ae_axspa_ae!=. 
count if new_ae_axspa_ae!=.
gen new_ae_ibd_icd = ae_ibd_icd if ibd_ctv==0
gen new_ae_ibd_icd_prim = ae_ibd_icd_prim if ibd_ctv==0
gen new_ae_ibd_ctv = ae_ibd_ctv if ibd_ctv==0
gen new_ae_ibd_ae = ae_ibd_ae if ibd_ctv==0
count if ibd_ctv!=0 
count if ae_ibd_icd!=. 
count if new_ae_ibd_icd!=.
count if ae_ibd_icd_prim!=. 
count if new_ae_ibd_icd_prim!=.
count if ae_ibd_ctv!=. 
count if new_ae_ibd_ctv!=.
count if ae_ibd_ae!=. 
count if new_ae_ibd_ae!=.
*** comparison of ICD admission primary diagnosis and all diagnoses
count if ae_diverticulitis_icd!=.
count if ae_diverticulitis_icd_prim!=.
count if ae_taste_icd!=.
count if ae_taste_icd_prim!=.
count if ae_rash_icd!=.
count if ae_rash_icd_prim!=.
count if ae_diarrhoea_icd!=.					
count if ae_diarrhoea_icd_prim!=.					
count if ae_diarrhoeal_icd!=.					
count if ae_diarrhoeal_icd_prim!=.
count if ae_contactderm_icd!=.	
count if ae_contactderm_icd_prim!=.
count if ae_dizziness_icd!=.
count if ae_dizziness_icd_prim!=.
count if ae_nausea_vomit_icd!=.
count if ae_nausea_vomit_icd_prim!=.
count if ae_headache_icd!=.
count if ae_headache_icd_prim!=.
count if ae_anaphylaxis_icd!=.
count if ae_anaphylaxis_icd_prim!=.
count if ae_severedrug_icd!=.
count if ae_severedrug_icd_prim!=.
count if ae_severedrug_sjs_icd!=.
count if ae_severedrug_sjs_icd_prim!=.

*** combined all AEs from GP, hosp and A&E
egen ae_diverticulitis = rmin(ae_diverticulitis_snomed ae_diverticulitis_ae ae_diverticulitis_icd_prim)
egen ae_diarrhoea = rmin(ae_diarrhoea_snomed ae_diarrhoea_icd_prim ae_diarrhoeal_icd_prim)
egen ae_taste = rmin(ae_taste_snomed ae_taste_icd_prim)
egen ae_rash = rmin(ae_rash_snomed ae_rash_ae ae_rash_icd_prim)
egen ae_bronchospasm = rmin(ae_bronchospasm_snomed)
egen ae_contactderm = rmin(ae_contactderm_snomed ae_contactderm_icd_prim ae_contactderm_ae)
egen ae_dizziness = rmin(ae_dizziness_snomed ae_dizziness_ae ae_dizziness_icd_prim)
egen ae_nausea_vomit = rmin(ae_nausea_vomit_snomed ae_nausea_vomit_icd_prim)
egen ae_headache = rmin(ae_headache_snomed ae_headache_ae ae_headache_icd_prim)
egen ae_anaphylaxis = rmin(ae_anaphylaxis_snomed ae_anaphlaxis_ae ae_anaphylaxis_icd_prim)
egen ae_drugreaction = rmin(ae_severedrug_icd_prim ae_severedrug_sjs_icd_prim ae_severedrug_snomed ae_severedrug_ae ae_nonsevere_drug_snomed ae_nonsevere_drug_ae)
egen ae_ra = rmin(new_ae_ra_snomed new_ae_ra_icd_prim new_ae_ra_ae)
egen ae_sle = rmin(new_ae_sle_ctv new_ae_sle_icd_prim new_ae_sle_ae)
egen ae_psorasis = rmin(new_ae_psoriasis_icd_prim new_ae_psoriasis_snomed new_ae_psoriasis_ae)
egen ae_psa = rmin(new_ae_psa_icd_prim new_ae_psa_snomed new_ae_psa_ae)
egen ae_axspa = rmin(new_ae_axspa_icd_prim new_ae_axspa_ctv new_ae_axspa_ae)
egen ae_ibd = rmin(new_ae_ibd_icd_prim new_ae_ibd_ctv new_ae_ibd_ae)

*** combined serious AEs from hosp and A&E
egen ae_diverticulitis_serious = rmin(ae_diverticulitis_icd_prim)
egen ae_diarrhoea_serious = rmin(ae_diarrhoea_icd_prim ae_diarrhoeal_icd_prim)
egen ae_taste_serious = rmin(ae_taste_icd_prim)
egen ae_rash_serious = rmin(ae_rash_icd_prim)
egen ae_contactderm_serious = rmin(ae_contactderm_icd_prim)
egen ae_dizziness_serious = rmin(ae_dizziness_icd_prim)
egen ae_nausea_vomit_serious = rmin(ae_nausea_vomit_icd_prim)
egen ae_headache_serious = rmin(ae_headache_icd_prim)
egen ae_anaphylaxis_serious = rmin(ae_anaphylaxis_icd_prim)
egen ae_drugreaction_serious = rmin(ae_severedrug_icd_prim ae_severedrug_sjs_icd_prim)
egen ae_ra_serious = rmin(new_ae_ra_icd_prim)
egen ae_sle_serious = rmin(new_ae_sle_icd_prim)
egen ae_psorasis_serious = rmin(new_ae_psoriasis_icd_prim)
egen ae_psa_serious = rmin(new_ae_psa_icd_prim)
egen ae_axspa_serious = rmin(new_ae_axspa_icd_prim)
egen ae_ibd_serious = rmin(new_ae_ibd_icd_prim)

*** combined AEs by spc, drug and imae				
egen ae_spc_all = rmin(ae_diverticulitis ae_diarrhoea ae_rash ae_taste ae_bronchospasm ae_contactderm ae_dizziness ae_nausea_vomit ae_headache)
egen ae_spc_serious = rmin(ae_diverticulitis_serious ae_diarrhoea_serious ae_taste_serious ae_rash_serious ae_contactderm_serious ae_dizziness_serious ae_nausea_vomit_serious ae_headache_serious)
egen ae_drug_all = rmin(ae_anaphylaxis ae_drugreaction)
egen ae_drug_serious = rmin(ae_anaphylaxis_serious ae_drugreaction_serious)
egen ae_imae_all = rmin(ae_ra ae_sle ae_psorasis ae_psa ae_axspa ae_ibd)
egen ae_imae_serious = rmin(ae_ra_serious ae_sle_serious ae_psorasis_serious ae_psa_serious ae_axspa_serious ae_ibd_serious)
egen ae_all = rmin(ae_spc_all ae_drug_all ae_imae_all)
egen ae_all_serious = rmin(ae_spc_serious ae_drug_serious ae_imae_serious)

*** global all ae
global ae_disease			ae_diverticulitis 				///
							ae_diarrhoea					///
							ae_taste 						///
							ae_rash 						///
							ae_bronchospasm					///
							ae_contactderm					///
							ae_dizziness					///
							ae_nausea_vomit					///
							ae_headache						///
							ae_anaphylaxis 					///
							ae_drugreaction					///
							ae_ra 							///
							ae_sle 							///
							ae_psorasis 					///
							ae_psa 							///
							ae_axspa 						///
							ae_ibd 						
global ae_disease_serious	ae_diverticulitis_serious 		///
							ae_diarrhoea_serious			///
							ae_taste_serious 				///
							ae_rash_serious 				///
							ae_contactderm_serious			///
							ae_dizziness_serious			///
							ae_nausea_vomit_serious			///
							ae_headache_serious				///
							ae_anaphylaxis_serious			///
							ae_drugreaction_serious			///
							ae_ra_serious 					///
							ae_sle_serious 					///
							ae_psorasis_serious 			///
							ae_psa_serious					///
							ae_axspa_serious				///
							ae_ibd_serious 						
global ae_combined			ae_all							///
							ae_all_serious  				///
							ae_spc_all 						///
							ae_spc_serious					///
							ae_drug_all						///
							ae_drug_serious					///
							ae_imae_all						///	
							ae_imae_serious	

****************************
*	SENSITIVITY COVARIATES		*
****************************
* Demographics*
* Age
sum age, det
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
tab sex
* Ethnicity
tab ethnicity,m
rename ethnicity ethnicity_str
encode  ethnicity_str, gen(ethnicity)
label list ethnicity
replace ethnicity=. if ethnicity==2 
tab ethnicity				
gen ethnicity_with_missing=ethnicity
replace ethnicity_with_missing=9 if ethnicity_with_missing==.
label define ethnicity_with_missing 1 "Black" 3 "Mixed" 4 "Other" 5 "South Asian" 6 "White" 9 "Missing", replace
label values ethnicity_with_missing ethnicity_with_missing
tab ethnicity_with_missing
gen White=1 if ethnicity==6
replace White=0 if ethnicity!=6&ethnicity!=.
tab White
gen White_with_missing=White
replace White_with_missing=9 if White==.
tab White_with_missing
* IMD
tab imdq5,m
replace imdq5="." if imdq5=="Unknown" 
replace imdq5="1" if imdq5=="1 (most deprived)" 
replace imdq5="5" if imdq5=="5 (least deprived)" 
destring imdq5, replace
recode imdq5 5 = 1 4 = 2 3 = 3 2 = 4 1 = 5 // Reverse the order (so 5 is more deprived)
label define imdq5 1 "1 least deprived" 2 "2" 3 "3" 4 "4" 5 "5 most deprived", replace
label values imdq5 imdq5
gen imd_with_missing=imdq5
replace imd_with_missing=9 if imdq5==.
tab imdq5,m
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
* Other comorbidites
tab autism,m
tab care_home,m
tab dementia_all,m
tab learning_disability,m
tab autism,m
tab serious_mental_illness,m
gen dementia = 1 if dementia_all==1 & age >39
recode dementia .=0 
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
* time between vaccine and covid positive test or treatment
gen days_vacc_covid=covid_test_positive_date - last_vaccination_date if (covid_test_positive_date>last_vaccination_date)
sum days_vacc_covid,de
gen days_vacc_treat=date_treated - last_vaccination_date if (date_treated>last_vaccination_date)
sum days_vacc_treat,de
gen month_vacc_covid=ceil(days_vacc_covid/30)
gen month_vacc_treat=ceil(days_vacc_treat/30)
tab month_vacc_covid,m
*Calendar time*
gen day_after_campaign=start_date-mdy(12,15,2021)
sum day_after_campaign,de
gen month_after_campaign=ceil((start_date-mdy(12,15,2021))/30)
tab month_after_campaign,m
tab start_date if month_after_campaign>100
//drop if month_after_campaign>100
* Prior infection / check Bang code
tab prior_covid, m
gen prior_covid_index=1 if prior_covid==1 & prior_covid_date<campaign_start
tab prior_covid_index,m
replace prior_covid_index=0 if prior_covid_index==.
* Calculating egfr: adapted from https://github.com/opensafely/COVID-19-vaccine-breakthrough/blob/updates-feb/analysis/data_process.R*
tabstat creatinine_ctv3, stat(mean p25 p50 p75 min max) 
replace creatinine_ctv3=. if !inrange(creatinine_ctv3, 20, 3000)|creatinine_ctv3_date>start_date
tabstat creatinine_ctv3, stat(mean p25 p50 p75 min max) 
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
gen egfr_60 = 1 if (egfr_creatinine_ctv3<60&creatinine_operator_ctv3!="<")|(egfr_creatinine_snomed<60&creatinine_operator_snomed!="<")|(egfr_record<60&egfr_record>0&egfr_operator!=">"&egfr_operator!=">=")|(egfr_short_record<60&egfr_short_record>0&egfr_short_operator!=">"&egfr_short_operator!=">=")
gen egfr_30 = 1 if (egfr_creatinine_ctv3<30&creatinine_operator_ctv3!="<")|(egfr_creatinine_snomed<30&creatinine_operator_snomed!="<")|(egfr_record<30&egfr_record>0&egfr_operator!=">"&egfr_operator!=">=")|(egfr_short_record<30&egfr_short_record>0&egfr_short_operator!=">"&egfr_short_operator!=">=")
count if egfr_60==1
count if egfr_30==1
*Paxlovid interactions*
count if drugs_paxlovid_contraindication<=start_date
count if drugs_paxlovid_contraindication<=start_date&drugs_paxlovid_contraindication>=(start_date-3*365.25)
count if drugs_paxlovid_contraindication<=start_date&drugs_paxlovid_contraindication>=(start_date-365.25)
count if drugs_paxlovid_contraindication<=start_date&drugs_paxlovid_contraindication>=(start_date-180)
gen drugs_paxlovid_cont=(drugs_paxlovid_contraindication<=start_date&drugs_paxlovid_contraindication>=(start_date-180))  
* Drug contraindicated 
gen paxlovid_contraindicated = 1 if egfr_30==1 | dialysis==1
replace paxlovid_contraindicated = 1 if liver_disease==1 
replace paxlovid_contraindicated = 1 if organ_transplant==1 
replace paxlovid_contraindicated = 1 if drugs_paxlovid_contraindication<=start_date&drugs_paxlovid_contraindication>=(start_date-180)
recode paxlovid_contraindicated . = 0
count if paxlovid_contraindicated==1

********************************************************
*	SENSITIVITY INCLUSION WITH & WITHOUT POSITIVE COVID TEST	*
********************************************************
** inclusion criteria*
keep if age>=18 & age<110
keep if sex==0 | sex==1
keep if has_died==0
tab dataset

** exclusion criteria*
count if start_date!=.
count if start_date>dereg_date & start_date!=.
count if start_date>death_date & start_date!=.
//drop if start_date>death_date | start_date>dereg_date
//drop if start_date>study_end_date
tab dataset

** positive covid test
count if covid_test_positive_date!=.
count if covid_test_positive_date==.
// keep if covid_test_positive_date!=.

** check covid positive and not repeat covid test after an infection within 30 days prior
tab covid_positive_previous_30_days 
drop if covid_positive_previous_30_days==1

********************************************************
*	SENSITIVITY EXPOSURE		*
********************************************************
** NOT removing individuals who did not have a covid test within 5 days of treatment
tab dataset
gen pre_drug_test_time = date_treated-covid_test_positive_date if dataset==1
sum pre_drug_test_time, det 
gen pre_drug_test=0 if dataset==1 & pre_drug_test_time==0
replace pre_drug_test=1 if dataset==1 & pre_drug_test_time==1
replace pre_drug_test=2 if dataset==1 & pre_drug_test_time==2
replace pre_drug_test=3 if dataset==1 & pre_drug_test_time==3
replace pre_drug_test=4 if dataset==1 & pre_drug_test_time==4
replace pre_drug_test=5 if dataset==1 & pre_drug_test_time==5
replace pre_drug_test=6 if dataset==1 & pre_drug_test_time>=6 & pre_drug_test_time<=7
replace pre_drug_test=7 if dataset==1 & pre_drug_test_time>=7 & pre_drug_test_time<=21
replace pre_drug_test=8 if dataset==1 & pre_drug_test_time<0 | pre_drug_test_time>21
replace pre_drug_test=9 if dataset==1 & (covid_test_positive_date==. | date_treated==.) & dataset==1
label define pre_drug_test 0 "0 days" 1 "1 days" 2 "2 days" 3 "3 days" 4 "4 days" 5 "5 days" 6 "6-7 days" 7 ">7 days & <21 days" 8 "treatment >21 day or <0" 9 "no test date / no treatment date", replace 
label values pre_drug_test pre_drug_test
tab pre_drug_test_time if pre_drug_test<=5
tab pre_drug_test dataset,m
// drop if dataset==1 & pre_drug_test>=5
sum pre_drug_test_time, det

**delay between covid test and treatment 
gen covid_test_5d = 1 if pre_drug_test<=5 & dataset==1
egen median_delay_treatment =  median(date_treated - covid_test_positive_date) if covid_test_5d==1
egen median_delay_all= max(median_delay_treatment)

** removing individuals who did not start therapy
tab treatment_dataset 
count if date_treated!=.
foreach var of varlist sotrovimab molnupiravir paxlovid {
    display "`var'"
	count if `var'!=.
	count if `var'==date_treated & `var'!=. & date_treated!=.
	count if `var'==date_treated & `var'!=. & date_treated!=. & `var'_not_start!=.
	gen `var'_start = 1 if `var'==date_treated & `var'!=. & date_treated!=. & `var'_not_start==.
	replace `var'_start = 0 if `var'==date_treated & `var'!=. & date_treated!=. & `var'_not_start!=.
	tab `var'_start, m  
}
* remove if had remdesivir or casirivimab
gen drug=7 if remdesivir==date_treated&remdesivir!=.&date_treated!=.
replace drug=8 if casirivimab==date_treated&casirivimab!=.&date_treated!=.
tab drug,m 
* patient who started sotrovimab, paxlovid, molnupiravir 
replace drug=1 if sotrovimab_start==1 
replace drug=2 if paxlovid_start==1
replace drug=3 if molnupiravir_start==1
tab drug,m 
* remove if didnt start sotrovimab, paxlovid, molnupiravir 
replace drug=4 if sotrovimab_start==0 
replace drug=5 if paxlovid_start==0
replace drug=6 if molnupiravir_start==0
tab drug,m 
* remove if had 2 treatment codes on start date
gen two_drugs= 1 if sotrovimab_start==1 & paxlovid_start==1
replace two_drugs=2 if sotrovimab_start==1 & molnupiravir_start==1
replace two_drugs=3 if paxlovid_start==1 & molnupiravir_start==1
replace two_drugs=4 if sotrovimab_start==1 & paxlovid_start==1 & molnupiravir_start==1
tab two_drug
replace drug=9 if two_drugs!=.
tab drug,m 
replace drug=0 if drug==.
label define drug 0 "control" 1 "sotrovimab" 2 "paxlovid" 3"molnupiravir" 4 "sotrovimab not started" 5 "paxlovid not started" 6 "molnupiravir not started" 7 "remdesivir" 8 "casirivimab" 9 "combination treatment", replace
label values drug drug
tab drug, m
* for flow sheet for treatment arm
bys dataset: tab drug,m  
drop if drug>0 & dataset==0
drop if drug==0 & dataset==1
bys dataset: tab drug,m  
* drop if i) treatment not started ii) combination treatment iii) remdesivir or casirivimab
drop if drug>3 & dataset==1
bys dataset: tab drug,m 

********************************************************
*	SENSITIVITY CONTROL		*
********************************************************
** cleaning eligibility criteria - ensure IMID on drug >4 pred scripts
tab high_risk_cohort_nhsd,m 
tab high_risk_cohort_nhsd drug
count if imid_on_drug==1 & imid_nhsd==1 & imid_drug==0 //should be 0
count if imid_on_drug==1 & imid_nhsd==0 & imid_drug==1 //should be 0
count if imid_on_drug==1 & imid_nhsd==1 & imid_drug==1 & downs_syndrome==0 &solid_cancer==0 &haem_disease==0 &renal_disease==0 &liver_disease==0 &immunosuppression==0 &hiv_aids==0 &organ_transplant==0 &rare_neuro==0
count if oral_steroid_drug_nhsd_6m_count<4 &oral_steroid_drugs_nhsd==1
count if oral_steroid_drug_nhsd_6m_count<4 &oral_steroid_drugs_nhsd==1 &immunosuppresant==0 &methotrexate==0 &ciclosporin==0 &mycophenolate==0 
count if oral_steroid_drug_nhsd_6m_count<4 &oral_steroid_drugs_nhsd==1 &immunosuppresant==0 &methotrexate==0 &ciclosporin==0 &mycophenolate==0 &imid_on_drug==1
count if oral_steroid_drug_nhsd_6m_count<4 &oral_steroid_drugs_nhsd==1 &immunosuppresant==0 &methotrexate==0 &ciclosporin==0 &mycophenolate==0 &imid_on_drug==1 &downs_syndrome==0 &solid_cancer==0 &haem_disease==0 &renal_disease==0 &liver_disease==0 &immunosuppression==0 &hiv_aids==0 &organ_transplant==0 &rare_neuro==0
count if oral_steroid_drug_nhsd_6m_count<4 &oral_steroid_drugs_nhsd==1 &immunosuppresant==0 &methotrexate==0 &ciclosporin==0 &mycophenolate==0 &imid_on_drug==1 &downs_syndrome==0 &solid_cancer==0 &haem_disease==0 &renal_disease==0 &liver_disease==0 &immunosuppression==0 &hiv_aids==0 &organ_transplant==0 &rare_neuro==0&dataset==0
replace imid_drug=0 if oral_steroid_drug_nhsd_6m_count<4 &oral_steroid_drugs_nhsd==1 &immunosuppresant==0 &methotrexate==0 &ciclosporin==0 &mycophenolate==0 &imid_on_drug==1 //ignore if steriods<4 scripts in 6m & not coded other imid drug 
replace oral_steroid_drugs_nhsd=0 if oral_steroid_drug_nhsd_6m_count<4 &oral_steroid_drugs_nhsd==1 //ignore if steriods<4 scripts in 6m
count if imid_on_drug==1 & imid_nhsd==1 & imid_drug==0 
replace imid_on_drug=0 if imid_nhsd==1 & imid_drug==0 //ignore if steriods<4 & not coded other imid drug 
replace imid_on_drug=0 if imid_nhsd==0 & imid_drug==1 
gen high_risk_cohort_codelist=((downs_syndrome + solid_cancer + haem_disease + renal_disease + liver_disease + imid_on_drug + immunosuppression + hiv_aids + organ_transplant + rare_neuro )>0)
tab high_risk_cohort_codelist dataset,m 
drop if high_risk_cohort_codelist==0 & dataset==0 //should be same number dropped as change above 
tab high_risk_cohort_codelist dataset

** cleaning ensure not hospitalised or discharge on day on covid test 
bys dataset: tab drug,m 
count if drug==0 & start_date==covid_test_positive_date
count if drug==0 & start_date!=covid_test_positive_date
** control patient ever hospitalised 
count if drug==0 & pre_covid_hosp_date!=. 
** control patient  hospitalised on day of positive test
count if drug==0 & covid_test_positive_date==pre_covid_hosp_date
** control patient hospitalised & still in hospital (not discharged)
count if drug==0 & pre_covid_hosp_date!=. & pre_covid_hosp_discharge==. 
count if drug==0 & pre_covid_hosp_date!=. & pre_covid_hosp_discharge==. & (start_date-pre_covid_hosp_date<29)
count if drug==0 & pre_covid_hosp_date!=. & pre_covid_hosp_discharge==. & (start_date-pre_covid_hosp_date<366)
** control patient, hospitalised & still in hospital (not discharged) - discharge date preceed admission
count if drug==0 & pre_covid_hosp_date>pre_covid_hosp_discharge & pre_covid_hosp_date!=. & pre_covid_hosp_discharge!=.
count if drug==0 & pre_covid_hosp_date>pre_covid_hosp_discharge & pre_covid_hosp_date!=. & pre_covid_hosp_discharge!=. & (start_date-pre_covid_hosp_date<29)
count if drug==0 & pre_covid_hosp_date>pre_covid_hosp_discharge & pre_covid_hosp_date!=. & pre_covid_hosp_discharge!=. & (start_date-pre_covid_hosp_date<366)
** control patient discharged on day of positive covid test 
count if drug==0 & covid_test_positive_date==pre_covid_hosp_discharge
** control patient's discharged 1 day before positive covid test 
count if drug==0 & (covid_test_positive_date-pre_covid_hosp_discharge<=1) & (covid_test_positive_date-pre_covid_hosp_discharge>=0)
* for flow sheet for treatment arm
** remove if hospitalised on day of positive test
drop if drug==0 & covid_test_positive_date==pre_covid_hosp_date
** remove if discharged on day of positive covid test 
drop if drug==0 & covid_test_positive_date==pre_covid_hosp_discharge
** remove if control patient's covid test is on discharge date
drop if drug==0 & (covid_test_positive_date-pre_covid_hosp_discharge<=1) & (covid_test_positive_date-pre_covid_hosp_discharge>=0)
bys dataset: tab drug,m 

** high risk cohort from blueteq therapeutics 
tab high_risk_cohort_therapeutics dataset,m 
gen downs_syndrome_therap= 1 if strpos(high_risk_cohort_therapeutics, "Downs syndrome")
gen solid_cancer_therap=1 if strpos(high_risk_cohort_therapeutics, "solid cancer")
gen haem_disease_therap=1 if strpos(high_risk_cohort_therapeutics, "haematological malignancies")
replace haem_disease_therap=1 if strpos(high_risk_cohort_therapeutics, "haematologic malignancy")
replace haem_disease_therap=1 if strpos(high_risk_cohort_therapeutics, "sickle cell disease")
replace haem_disease_therap=1 if strpos(high_risk_cohort_therapeutics, "haematological diseases")
replace haem_disease_therap=1 if strpos(high_risk_cohort_therapeutics, "stem cell transplant")
gen renal_disease_therap= 1 if strpos(high_risk_cohort_therapeutics, "renal disease")
gen liver_disease_therap= 1 if strpos(high_risk_cohort_therapeutics, "liver disease")
gen imid_on_drug_therap= 1 if strpos(high_risk_cohort_therapeutics, "IMID")
gen immunosuppression_therap= 1 if strpos(high_risk_cohort_therapeutics, "primary immune deficiencies")
gen hiv_aids_therap= 1 if strpos(high_risk_cohort_therapeutics, "HIV or AIDS")
gen organ_transplant_therap= 1 if strpos(high_risk_cohort_therapeutics, "solid organ recipients")
replace organ_transplant_therap= 1 if strpos(high_risk_cohort_therapeutics, "solid organ transplant")
gen rare_neuro_therap= 1 if strpos(high_risk_cohort_therapeutics, "rare neurological conditions")
count if high_risk_cohort_therapeutics!=""&high_risk_cohort_therapeutics!="other"& min(downs_syndrome_therap,solid_cancer_therap,haem_disease_therap,renal_disease_therap,liver_disease_therap,imid_on_drug_therap,immunosuppression_therap,hiv_aids_therap,organ_transplant_therap,rare_neuro_therap)==. //check if all diseases have been captured
tab high_risk_cohort_therapeutics if high_risk_cohort_therapeutics!=""&high_risk_cohort_therapeutics!="other"& min(downs_syndrome_therap,solid_cancer_therap,haem_disease_therap,renal_disease_therap,liver_disease_therap,imid_on_drug_therap,immunosuppression_therap,hiv_aids_therap,organ_transplant_therap,rare_neuro_therap)==.
gen high_risk_cohort_ther= 1 if high_risk_cohort_therapeutics!=""&high_risk_cohort_therapeutics!="other"
foreach var of varlist downs_syndrome_therap solid_cancer_therap haem_disease_therap renal_disease_therap liver_disease_therap imid_on_drug_therap immunosuppression_therap hiv_aids_therap organ_transplant_therap rare_neuro_therap{
	replace `var'=0 if `var'==. 
}
** combine two high risk cohorts into one 
foreach var of varlist downs_syndrome solid_cancer haem_disease renal_disease liver_disease imid_on_drug immunosuppression hiv_aids organ_transplant rare_neuro {
	gen `var'_comb = `var'
	replace `var'_comb = 1 if `var'_therap==1 
	tab `var' `var'_therap 
	tab dataset `var'_comb
}
gen eligible = 0 if downs_syndrome_comb==.&solid_cancer_comb==.& haem_disease_comb==.& renal_disease_comb==.& liver_disease_comb==.& imid_on_drug_comb==.& immunosuppression_comb==.& hiv_aids_comb==.& organ_transplant_comb==.& rare_neuro_comb==. 
recode eligible . = 1
tab drug eligible
********************************************************
*	SENSITIVITY FINAL NUMBERS 		*
********************************************************
tab dataset
tab drug
tab drug paxlovid_contraindicated
bys drug: sum pre_drug_test_time, det
tab drug pre_drug_test
tab drug if pre_drug_test<=5  // should match main analysis numbers
tab drug eligible
gen covid_test = 1 if pre_drug_test<2
replace covid_test = 1 if drug==0 
replace covid_test = 0 if covid_test==.
tab drug covid_test
********************************************************
*	SENSITIVITY START DATE		*
********************************************************
** start date = covid test in control arm 
** start date = date treated in treatment arm 
count if start_date==.
count if start_date!=covid_test_positive_date & drug==0  
count if start_date!=date_treated & drug>0 
foreach x in $ae_disease $ae_disease_serious $ae_combined {
				display "`x'"
				count if (`x' > start_date | `x' < start_date + 29) & `x'!=. 
				count if (`x' < start_date | `x' > start_date + 29) & `x'!=. & drug==0
				count if (`x' < start_date | `x' > start_date + 29) & `x'!=. & drug>0
}

********************************************************
*	SENSITIVITY COX MODEL		*
********************************************************
* Generate failure 
foreach x in  $ae_disease $ae_disease_serious $ae_combined{
	display "`x'"
	by drug, sort: count if `x'!=.
	by drug, sort: count if `x'>=start_date & `x'!=.
	by drug, sort: count if `x'>=start_date & `x'<start_date_29 &`x'!=.
	gen fail_`x'=(`x'!=.&`x'<= min(study_end_date_29, start_date_29, paxlovid, molnupiravir)) if drug==1
	replace fail_`x'=(`x'!=.&`x'<= min(study_end_date_29, start_date_29, sotrovimab, molnupiravir)) if drug==2
	replace fail_`x'=(`x'!=.&`x'<= min(study_end_date_29, start_date_29, sotrovimab, paxlovid)) if drug==3
	replace fail_`x'=(`x'!=.&`x'<= min(study_end_date_29, start_date_29, sotrovimab, paxlovid, molnupiravir)) if drug==0
	tab drug fail_`x', m
}
* Add half-day buffer if outcome on indexdate
foreach x in  $ae_disease $ae_disease_serious $ae_combined{
	display "`x'"
	replace `x'=`x'+0.75 if `x'==start_date
}
*Generate censor date
foreach x in  $ae_disease $ae_disease_serious $ae_combined{
	gen stop_`x'=`x' if fail_`x'==1
	replace stop_`x'=min(death_date,dereg_date,study_end_date_29,start_date_29,paxlovid,molnupiravir) if fail_`x'==0&drug==1
	replace stop_`x'=min(death_date,dereg_date,study_end_date_29,start_date_29,sotrovimab,molnupiravir) if fail_`x'==0&drug==2
	replace stop_`x'=min(death_date,dereg_date,study_end_date_29,start_date_29,sotrovimab,paxlovid) if fail_`x'==0&drug==3
	replace stop_`x'=min(death_date,dereg_date,study_end_date_29,start_date_29,sotrovimab,paxlovid,molnupiravir) if fail_`x'==0&drug==0
	format %td stop_`x'
}
* Follow-up time
foreach x in $ae_combined{
	stset stop_`x', id(patient_id) origin(time start_date) enter(time start_date) failure(fail_`x'==1) 
	tab _st  
	tab _t drug if fail_`x'==1 & stop_`x'==`x'
	tab _t drug if fail_`x'==0 &_t<28 & stop_`x'==death_date,m col
	tab _t drug if fail_`x'==0 &_t<28 & stop_`x'==dereg_date,m col
	tab _t drug if fail_`x'==0 &_t<28 & stop_`x'==min(paxlovid,molnupiravir) & drug==1,m col
	tab _t drug if fail_`x'==0 &_t<28 & stop_`x'==min(sotrovimab,molnupiravir) & drug==2,m col
	tab _t drug if fail_`x'==0 &_t<28 & stop_`x'==min(sotrovimab,paxlovid) & drug==3,m col
	tab _t drug if fail_`x'==0 &_t<28 & stop_`x'==min(sotrovimab,paxlovid,molnupiravir) &drug==0,m col
}


save "$projectdir/output/data/sensitivity_analysis.dta", replace
log close











