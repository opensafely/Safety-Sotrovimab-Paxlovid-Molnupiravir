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
log using "$logdir/cleaning_dataset_combine.log", replace

*Set Ado file path
adopath + "$projectdir/analysis/ado"

* 	Import control dataset
import delimited "$projectdir/output/input_control.csv", clear
gen control_dataset=1
*	Convert control strings to dates     * 
foreach var of varlist 	 covid_test_positive_date				///
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
						 last_vaccination_date 					///
						 death_date								///
						 dereg_date 							///
						 bmi_date_measured						///
						 creatinine_ctv3_date 					///
						 creatinine_snomed_date					///
						 creatinine_short_snomed_date			///
						 ae_diverticulitis_icd					///
						 ae_diverticulitis_snomed				///
						 ae_diarrhoea_snomed					///
						 ae_taste_snomed						///
						 ae_taste_icd							///
						 ae_rash_snomed							///
						 ae_anaphylaxis_icd						///
						 ae_anaphylaxis_snomed					///
						 ae_anaphlaxis_ae						///
						 ae_drugreact_ae						///
						 ae_allergic_ae							///
						 ae_rheumatoid_arthritis_snomed			///
						 ae_rheumatoid_arthritis_icd			///
						 ae_sle_ctv								///
						 ae_sle_icd								///
						 ae_psoriasis_snomed					///
						 ae_psoriatic_arthritis_snomed			///
						 ae_ankylosing_spondylitis_ctv			///
						 ae_ibd_snomed							///
						 ae_diverticulitis_ae					///
						 ae_rheumatoid_arthritis_ae				///
						 ae_sle_ae								///
						 ae_psoriasis_ae						///
						 ae_psoriatic_arthritis_ae				///
						 ae_ankylosing_spondylitis_ae			///
						 ae_ibd_ae								///
						 ae_diverticulitis_icd_prim				///	
						 ae_taste_icd_prim						///
						 ae_anaphylaxis_icd_prim				///
						 ae_rheumatoid_arthritis_icd_prim		///
						 ae_sle_icd_prim						///
						 pre_diverticulitis_icd_prim			///
						 pre_taste_icd_prim						///
						 pre_anaphylaxis_icd_prim				///
						 pre_sle_icd_prim						///
						 pre_rheumatoid_icd_prim				///
						 rheumatoid_arthritis_nhsd_snomed		///
						 rheumatoid_arthritis_nhsd_icd10		///
						 sle_nhsd_ctv							///
						 sle_nhsd_icd10							///
						 psoriasis_nhsd							///
						 psoriatic_arthritis_nhsd				///
						 ankylosing_spondylitis_nhsd			///
						 ibd_ctv								///
						 allcause_emerg_aande					///
						 all_hosp_date 							///
						 all_hosp_date0 						///
						 all_hosp_date1 						///
						 all_hosp_date2							///
						 hosp_discharge_date					///
						 hosp_discharge_date0 					///
						 hosp_discharge_date1 					///
						 hosp_discharge_date2					///
						 covid_hosp_date						///
						 covid_hosp_date0 						///
						 covid_hosp_date1 						///
						 covid_hosp_date2  						///						
						 covid_discharge_date					///
						 covid_discharge_date0				  	///  						
						 covid_discharge_date1					/// 
						 covid_discharge_date2					/// 
						 any_covid_hosp_discharge				///			
						 covid_hosp_date_mabs					/// 
						 covid_hosp_date_mabs_not_primary		/// 
						 died_date_ons							///
						 died_ons_covid							///
						 pre_diverticulitis_icd					///
						 pre_diverticulitis_snomed				///
						 pre_diverticulitis_ae					///
						 pre_diarrhoea_snomed 					///
						 pre_taste_snomed						///
						 pre_taste_icd							///
						 pre_rash_snomed						///
						 pre_anaphylaxis_icd					///
						 pre_anaphylaxis_snomed					///
						 pre_anaphlaxis_ae						///
						 pre_drugreact_ae						///
						 pre_allergic_ae						///
						 pre_anaphlaxis_ae						///
						 pre_rheumatoid_arthritis_ae			///
						 pre_rheumatoid_arthritis_snomed		///
						 pre_rheumatoid_arthritis_icd			///
						 pre_ankylosing_spondylitis_ctv			///
						 pre_ankylosing_spondylitis_ae			///
						 pre_psoriasis_snomed					///
						 pre_psoriasis_ae						///
						 pre_psoriatic_arthritis_ae				///
						 pre_psoriatic_arthritis_snomed			///
						 pre_sle_ctv							///
						 pre_sle_icd							///
						 pre_sle_ae								///
						 pre_ibd_ae								///
						 pre_ibd_snomed	{					 
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
//						 //				///

* import treatment dataset
import delimited "$projectdir/output/input_treatment.csv", clear
gen treatment_dataset=1
*	Convert control strings to dates     * 
foreach var of varlist 	 covid_test_positive_date				///
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
						 last_vaccination_date 					///
						 death_date								///
						 dereg_date 							///
						 bmi_date_measured						///
						 creatinine_ctv3_date 					///
						 creatinine_snomed_date					///
						 creatinine_short_snomed_date			///
						 ae_diverticulitis_icd					///
						 ae_diverticulitis_snomed				///
						 ae_diarrhoea_snomed					///
						 ae_taste_snomed						///
						 ae_taste_icd							///
						 ae_rash_snomed							///
						 ae_anaphylaxis_icd						///
						 ae_anaphylaxis_snomed					///
						 ae_anaphlaxis_ae						///
						 ae_drugreact_ae						///
						 ae_allergic_ae							///
						 ae_rheumatoid_arthritis_snomed			///
						 ae_rheumatoid_arthritis_icd			///
						 ae_sle_ctv								///
						 ae_sle_icd								///
						 ae_psoriasis_snomed					///
						 ae_psoriatic_arthritis_snomed			///
						 ae_ankylosing_spondylitis_ctv			///
						 ae_ibd_snomed							///
						 ae_diverticulitis_ae					///
						 ae_rheumatoid_arthritis_ae				///
						 ae_sle_ae								///
						 ae_psoriasis_ae						///
						 ae_psoriatic_arthritis_ae				///
						 ae_ankylosing_spondylitis_ae			///
						 ae_ibd_ae								///
						 ae_diverticulitis_icd_prim				///	
						 ae_taste_icd_prim						///
						 ae_anaphylaxis_icd_prim				///
						 ae_rheumatoid_arthritis_icd_pri		///
						 ae_sle_icd_prim						///
						 pre_diverticulitis_icd_prim			///
						 pre_taste_icd_prim						///
						 pre_anaphylaxis_icd_prim				///
						 pre_rheumatoid_icd_prim				///
						 pre_sle_icd_prim						///
						 rheumatoid_arthritis_nhsd_snomed		///
						 rheumatoid_arthritis_nhsd_icd10		///
						 sle_nhsd_ctv							///
						 sle_nhsd_icd10							///
						 psoriasis_nhsd							///
						 psoriatic_arthritis_nhsd				///
						 ankylosing_spondylitis_nhsd			///
						 ibd_ctv								///
						 allcause_emerg_aande					///
						 all_hosp_date 							///
						 all_hosp_date0 						///
						 all_hosp_date1 						///
						 all_hosp_date2							///
						 hosp_discharge_date					///
						 hosp_discharge_date0 					///
						 hosp_discharge_date1 					///
						 hosp_discharge_date2					///
						 covid_hosp_date						///
						 covid_hosp_date0 						///
						 covid_hosp_date1 						///
						 covid_hosp_date2  						///						
						 covid_discharge_date					///
						 covid_discharge_date0				  	///  						
						 covid_discharge_date1					/// 
						 covid_discharge_date2					/// 
						 any_covid_hosp_discharge				///			
						 covid_hosp_date_mabs					/// 
						 covid_hosp_date_mabs_not_primary		/// 
						 died_date_ons							///
						 died_ons_covid							///
						 pre_diverticulitis_icd					///
						 pre_diverticulitis_snomed				///
						 pre_diverticulitis_ae					///
						 pre_diarrhoea_snomed 					///
						 pre_taste_snomed						///
						 pre_taste_icd							///
						 pre_rash_snomed						///
						 pre_anaphylaxis_icd					///
						 pre_anaphylaxis_snomed					///
						 pre_anaphlaxis_ae						///
						 pre_drugreact_ae						///
						 pre_allergic_ae						///
						 pre_anaphlaxis_ae						///
						 pre_rheumatoid_arthritis_ae			///
						 pre_rheumatoid_arthritis_snomed		///
						 pre_rheumatoid_arthritis_icd			///
						 pre_ankylosing_spondylitis_ctv			///
						 pre_ankylosing_spondylitis_ae			///
						 pre_psoriasis_snomed					///
						 pre_psoriasis_ae						///
						 pre_psoriatic_arthritis_ae				///
						 pre_psoriatic_arthritis_snomed			///
						 pre_sle_ctv							///
						 pre_sle_icd							///
						 pre_sle_ae								///
						 pre_ibd_ae								///
						 pre_ibd_snomed	{					 
	capture confirm string variable `var'
	if _rc==0 {
	rename `var' a
	gen `var' = date(a, "YMD")
	drop a
	format %td `var'
 }
}
tab treatment_dataset
*********************************
*  Append control & treatment datasets     *
********************************* 
append using "$projectdir/output/data/control.dta"
duplicates tag patient_id, gen(duplicate_patient_id)
bys patient_id (treatment_dataset duplicate_patient_id): gen n=_n
tab n
drop if n>1  // drops duplicate patient id and in control group
tab control_dataset,m
tab treatment_dataset,m
count if start_date==.
count if start_date!=date_treated & treatment_dataset==1
count if start_date!=covid_test_positive_date & control_dataset==1
gen dataset = 0 if control_dataset==1
replace dataset= 1 if treatment_dataset==1
label define dataset 0 "control" 1 "drug" 
label values dataset dataset

****************************
*	INCLUSION		*
****************************
** inclusion criteria*
keep if age>=18 & age<110
keep if sex=="F"|sex=="M"
keep if has_died==0
** exclusion criteria*
count if start_date>dereg_date & start_date!=.
count if start_date>death_date & start_date!=.
drop if start_date>death_date | start_date>dereg_date

** high risk cohort from blueteq therapeutics datafor drug arms
tab high_risk_cohort_therapeutics dataset,m //should be 0 in control group
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
gen immunosupression_therap= 1 if strpos(high_risk_cohort_therapeutics, "primary immune deficiencies")
gen hiv_aids_therap= 1 if strpos(high_risk_cohort_therapeutics, "HIV or AIDS")
gen organ_transplant_therap= 1 if strpos(high_risk_cohort_therapeutics, "solid organ recipients")
replace organ_transplant_therap= 1 if strpos(high_risk_cohort_therapeutics, "solid organ transplant")
gen rare_neuro_therap= 1 if strpos(high_risk_cohort_therapeutics, "rare neurological conditions")
count if high_risk_cohort_therapeutics!=""&high_risk_cohort_therapeutics!="other"& min(downs_syndrome_therap,solid_cancer_therap,haem_disease_therap,renal_disease_therap,liver_disease_therap,imid_on_drug_therap,immunosupression_therap,hiv_aids_therap,organ_transplant_therap,rare_neuro_therap)==. //check if all diseases have been captured
tab high_risk_cohort_therapeutics if high_risk_cohort_therapeutics!=""&high_risk_cohort_therapeutics!="other"& min(downs_syndrome_therap,solid_cancer_therap,haem_disease_therap,renal_disease_therap,liver_disease_therap,imid_on_drug_therap,immunosupression_therap,hiv_aids_therap,organ_transplant_therap,rare_neuro_therap)==.
gen high_risk_cohort_ther= 1 if high_risk_cohort_therapeutics!=""&high_risk_cohort_therapeutics!="other"
foreach var of varlist high_risk_cohort_ther downs_syndrome_therap solid_cancer_therap haem_disease_therap renal_disease_therap liver_disease_therap imid_on_drug_therap immunosupression_therap hiv_aids_therap organ_transplant_therap rare_neuro_therap{
	replace `var'=0 if `var'==. 
}
tab high_risk_cohort_ther
tab high_risk_cohort_ther dataset

** high risk cohort from open codelist from control group
tab high_risk_cohort_nhsd,m 
count if downs_syndrome==1
count if solid_cancer==1
count if haem_disease==1
count if renal_disease==1
count if liver_disease==1
count if imid_on_drug==1
count if hiv_aids==1
count if organ_transplant==1
count if rare_neuro==1
count if imid_on_drug==1 & imid_nhsd==1 & imid_drug==0 //should be 0
count if imid_on_drug==1 & imid_nhsd==0 & imid_drug==1 //should be 0
count if imid_on_drug==1 & imid_nhsd==1 & imid_drug==1 & downs_syndrome==0 &solid_cancer==0 &haem_disease==0 &renal_disease==0 &liver_disease==0 &immunosupression==0 &hiv_aids==0 &organ_transplant==0 &rare_neuro==0
count if oral_steroid_drug_nhsd_6m_count<4 &oral_steroid_drugs_nhsd==1
count if oral_steroid_drug_nhsd_6m_count<4 &oral_steroid_drugs_nhsd==1 &immunosuppresant==0 &methotrexate==0 &ciclosporin==0 &mycophenolate==0 
count if oral_steroid_drug_nhsd_6m_count<4 &oral_steroid_drugs_nhsd==1 &immunosuppresant==0 &methotrexate==0 &ciclosporin==0 &mycophenolate==0 &imid_on_drug==1
count if oral_steroid_drug_nhsd_6m_count<4 &oral_steroid_drugs_nhsd==1 &immunosuppresant==0 &methotrexate==0 &ciclosporin==0 &mycophenolate==0 &imid_on_drug==1 &downs_syndrome==0 &solid_cancer==0 &haem_disease==0 &renal_disease==0 &liver_disease==0 &immunosupression==0 &hiv_aids==0 &organ_transplant==0 &rare_neuro==0
replace imid_drug=0 if oral_steroid_drug_nhsd_6m_count<4 &oral_steroid_drugs_nhsd==1 &immunosuppresant==0 &methotrexate==0 &ciclosporin==0 &mycophenolate==0 &imid_on_drug==1 //ignore if steriods<4 scripts in 6m & not coded other imid drug 
replace oral_steroid_drugs_nhsd=0 if oral_steroid_drug_nhsd_6m_count<4 &oral_steroid_drugs_nhsd==1 //ignore if steriods<4 scripts in 6m
count if imid_on_drug==1 & imid_nhsd==1 & imid_drug==0 
replace imid_on_drug=0 if imid_nhsd==1 & imid_drug==0 //ignore if steriods<4 & not coded other imid drug 
replace imid_on_drug=0 if imid_nhsd==0 & imid_drug==1 
gen high_risk_cohort_codelist=((downs_syndrome + solid_cancer + haem_disease + renal_disease + liver_disease + imid_on_drug + immunosupression + hiv_aids + organ_transplant + rare_neuro )>0)
tab high_risk_cohort_codelist dataset,m 
drop if high_risk_cohort_codelist==. & dataset==0 //should be same number dropped as change above 
tab high_risk_cohort_codelist dataset
bys dataset:count if high_risk_cohort_codelist==. & high_risk_cohort_ther==.

** combine two high risk cohorts into one 
foreach var of varlist downs_syndrome solid_cancer haem_disease renal_disease liver_disease imid_on_drug immunosupression hiv_aids organ_transplant rare_neuro {
	gen `var'_comb = `var'
	replace `var'_comb = 1 if `var'_therap==1 
	tab `var' `var'_therap 
	tab dataset `var'_comb 
}

****************************
*	EXPOSURE		*
****************************
** removing individuals who did not start therapy
foreach var of varlist sotrovimab molnupiravir paxlovid {
    display "`var'"
	count if `var'!=.
	count if `var'==date_treated & `var'!=. & date_treated!=.
	count if `var'==date_treated & `var'!=. & date_treated!=. & `var'_not_start!=.
	gen `var'_start = 1 if `var'==date_treated & `var'!=. & date_treated!=. & `var'_not_start==.
	replace `var'_start = 0 if `var'==date_treated & `var'!=. & date_treated!=. & `var'_not_start!=.
	tab `var'_start, m  //number on treatment, first drug given, and drug was started
}
gen drug=7 if remdesivir==date_treated&remdesivir!=.&date_treated!=.
replace drug=8 if casirivimab==date_treated&casirivimab!=.&date_treated!=.
tab drug,m 
replace drug=1 if sotrovimab_start==1 
replace drug=2 if paxlovid_start==1
replace drug=3 if molnupiravir_start==1
tab drug,m 
replace drug=4 if sotrovimab==date_treated & sotrovimab_start==0 
replace drug=5 if paxlovid==date_treated & paxlovid_start==0 
replace drug=6 if molnupiravir==date_treated & molnupiravir_start==0 
tab drug,m 
bys dataset: tab drug,m
replace drug=0 if drug==.
label define drug 0 "control" 1 "sotrovimab" 2 "paxlovid" 3"molnupiravir", replace
label values drug drug
tab drug, m
drop if drug>3

** start date is date treatment for treatment arms and date of covid test for control arm 
count if start_date==. //should be 0
count if start_date!=covid_test_positive_date & drug==0  //should be 0
count if start_date!=date_treated & drug>0 //should be 0

** check number of positive covid tests prior to drug in treatment arms
bys drug:count if covid_test_positive_date==. // should be 0 in control arm
bys drug:count if covid_test_positive_date!=. 
bys drug:count if covid_test_positive_date!=.&date_treated!=.& date_treated>covid_test_positive_date //test prior to treatment
bys drug:count if covid_test_positive_date!=.&date_treated!=.& (date_treated-covid_test_positive_date>0)&(date_treated-covid_test_positive_date<=5) //test <5d
bys drug:count if covid_test_positive_date2!=.&date_treated!=.& date_treated>covid_test_positive_date2 //2nd covid episode prior to treatment 
bys drug:count if covid_test_positive_date2!=.&date_treated!=.& (date_treated-covid_test_positive_date2>0)&(date_treated-covid_test_positive_date2<=5) //test <5d
bys drug:count if covid_test_positive_date3!=.&date_treated!=.& date_treated>covid_test_positive_date3 //3rd covid episode prior to treatment 
bys drug:count if covid_test_positive_date3!=.&date_treated!=.& (date_treated-covid_test_positive_date3>0)&(date_treated-covid_test_positive_date3<=5) //test <5d
** check in control group that covid positive, and not repeat covid test after an infection within 30 days prior
tab covid_test_positive covid_positive_previous_30_days if drug==0
drop if drug==0 & covid_test_positive==1 & covid_positive_previous_30_days==1
** gen study start and study end date
gen campaign_start=mdy(12,16,2021)
gen study_end_date=mdy(09,01,2023)
gen start_date_29=start_date + 29
format campaign_start study_end_date start_date_29 %td



****************************
*	OUTCOME		*
****************************
*** AESI, IMAE and some Drug reaction (need to add further IMAE and DRESS, SJS, TEN) 
gen new_ae_ra_icd = ae_rheumatoid_arthritis_icd if rheumatoid_arthritis_nhsd_snomed==0 & rheumatoid_arthritis_nhsd_icd10==0  
gen new_ae_ra_icd_prim = ae_rheumatoid_arthritis_icd_prim if rheumatoid_arthritis_nhsd_snomed==0 & rheumatoid_arthritis_nhsd_icd10==0  
gen new_ae_ra_snomed = ae_rheumatoid_arthritis_snomed if rheumatoid_arthritis_nhsd_snomed==0 & rheumatoid_arthritis_nhsd_icd10==0
gen new_ae_ra_ae = ae_rheumatoid_arthritis_ae if rheumatoid_arthritis_nhsd_snomed==0 & rheumatoid_arthritis_nhsd_icd10==0  
count if rheumatoid_arthritis_nhsd_snomed!=0 | rheumatoid_arthritis_nhsd_icd10!=0
count if ae_rheumatoid_arthritis_icd!=. 
count if new_ae_ra_icd!=.
count if ae_rheumatoid_arthritis_icd_prim!=. 
count if new_ae_ra_icd_prim!=.
count if ae_rheumatoid_arthritis_snomed!=. 
count if new_ae_ra_snomed!=.
count if ae_rheumatoid_arthritis_ae!=. 
count if new_ae_ra_ae!=.
gen new_ae_sle_icd = ae_sle_icd if sle_nhsd_ctv==0 & sle_nhsd_icd10==0
gen new_ae_sle_icd_prim = ae_sle_icd_prim if sle_nhsd_ctv==0 & sle_nhsd_icd10==0
gen new_ae_sle_ctv = ae_sle_ctv if sle_nhsd_ctv==0 & sle_nhsd_icd10==0
gen new_ae_sle_ae = ae_sle_ae if sle_nhsd_ctv==0 & sle_nhsd_icd10==0
count if sle_nhsd_ctv!=0 | sle_nhsd_icd10!=0
count if ae_sle_icd!=. 
count if new_ae_sle_icd!=.
count if ae_sle_icd_prim!=. 
count if new_ae_sle_icd_prim!=.
count if ae_sle_ctv!=. 
count if new_ae_sle_ctv!=.
count if ae_sle_ae!=. 
count if new_ae_sle_ae!=.
gen new_ae_psoriasis_snomed = ae_psoriasis_snomed if psoriasis_nhsd==0
gen new_ae_psoriasis_ae = ae_psoriasis_ae if psoriasis_nhsd==0
count if psoriasis_nhsd!=0 
count if ae_psoriasis_snomed!=. 
count if new_ae_psoriasis_snomed!=.
count if ae_psoriasis_ae!=. 
count if new_ae_psoriasis_ae!=.
gen new_ae_psa_snomed = ae_psoriatic_arthritis_snomed if psoriatic_arthritis_nhsd==0
gen new_ae_psa_ae = ae_psoriatic_arthritis_ae if psoriatic_arthritis_nhsd==0
count if psoriatic_arthritis_nhsd!=0 
count if ae_psoriatic_arthritis_snomed!=. 
count if new_ae_psa_snomed!=.
count if ae_psoriatic_arthritis_ae!=. 
count if new_ae_psa_ae!=.
gen new_ae_ankspon_ctv = ae_ankylosing_spondylitis_ctv if ankylosing_spondylitis_nhsd==0
gen new_ae_ankspon_ae = ae_ankylosing_spondylitis_ae if ankylosing_spondylitis_nhsd==0
count if ankylosing_spondylitis_nhsd!=0 
count if ae_ankylosing_spondylitis_ctv!=. 
count if new_ae_ankspon_ctv!=.
count if ae_ankylosing_spondylitis_ae!=. 
count if new_ae_ankspon_ae!=.
gen new_ae_ibd_snomed = ae_ibd_snomed if ibd_ctv==0
gen new_ae_ibd_ae = ae_ibd_ae if ibd_ctv==0
count if ibd_ctv!=0 
count if ae_ibd_snomed!=. 
count if new_ae_ibd_snomed!=.
count if ae_ibd_ae!=. 
count if new_ae_ibd_ae!=.

*** comparison of ICD admission primary diagnosis and all diagnoses
count if ae_diverticulitis_icd!=.
count if ae_diverticulitis_icd_prim!=.
count if ae_taste_icd!=.
count if ae_taste_icd_prim!=.
count if ae_anaphylaxis_icd!=.
count if ae_anaphylaxis_icd_prim!=.

*** combined ae from GP, hosp and A&E
egen ae_diverticulitis = rmin(ae_diverticulitis_snomed ae_diverticulitis_icd_prim ae_diverticulitis_ae)
egen ae_diarrhoea = rmin(ae_diarrhoea_snomed)
egen ae_taste = rmin(ae_taste_snomed ae_taste_icd_prim)
egen ae_anaphylaxis = rmin(ae_anaphylaxis_snomed ae_anaphlaxis_ae ae_anaphylaxis_icd_prim)
egen ae_rash = rmin(ae_rash_snomed)
egen ae_drug = rmin(ae_drugreact_ae)
egen ae_allergic = rmin(ae_allergic_ae)
egen ae_ra = rmin(new_ae_ra_snomed new_ae_ra_icd_prim new_ae_ra_ae)
egen ae_sle = rmin(new_ae_sle_ctv new_ae_sle_icd_prim new_ae_sle_ae)
egen ae_psorasis = rmin(new_ae_psoriasis_snomed new_ae_psoriasis_ae)
egen ae_psa = rmin(new_ae_psa_snomed new_ae_psa_ae)
egen ae_ankspon = rmin(new_ae_ankspon_ctv new_ae_ankspon_ae)
egen ae_ibd = rmin(new_ae_ibd_snomed new_ae_ibd_ae)

*** global all ae
global ae_spc			ae_diverticulitis_snomed		///
						ae_diarrhoea_snomed				///
						ae_taste_snomed						
global ae_spc_icd		ae_diverticulitis_icd_prim		///
						ae_taste_icd_prim					
global ae_spc_emerg		ae_diverticulitis_ae									
global ae_drug 			ae_anaphylaxis_snomed			///	
						ae_rash_snomed	
global ae_drug_emerg	ae_anaphlaxis_ae				///
						ae_drugreact_ae					///
						ae_allergic_ae											    
global ae_drug_icd		ae_anaphylaxis_icd_prim
global ae_imae			new_ae_ra_snomed 				///
						new_ae_sle_ctv 					///
						new_ae_psoriasis_snomed 		///
						new_ae_psa_snomed 				///
						new_ae_ankspon_ctv				///
						new_ae_ibd_snomed	
global ae_imae_icd		new_ae_ra_icd_prim 				///
						new_ae_sle_icd_prim		
global ae_imae_emerg	new_ae_ra_ae					///
						new_ae_sle_ae					///
						new_ae_psoriasis_ae				///
						new_ae_psa_ae					///
						new_ae_ankspon_ae				///
						new_ae_ibd_ae	
global ae_disease		ae_diverticulitis 				///
						ae_diarrhoea					///
						ae_taste 						///
						ae_anaphylaxis 					///
						ae_rash 						///
						ae_drug 						///
						ae_allergic 					///
						ae_ra 							///
						ae_sle 							///
						ae_psorasis 					///
						ae_psa 							///
						ae_ankspon 						///
						ae_ibd 					
									
*remove event if occurred before start
foreach x in $ae_spc $ae_spc_icd $ae_spc_emerg $ae_drug $ae_drug_icd $ae_drug_emerg $ae_imae $ae_imae_icd $ae_imae_emerg $ae_disease{
				display "`x'"
				count if (`x' > start_date | `x' < start_date + 28) & `x'!=. 
				count if (`x' < start_date | `x' > start_date + 28) & `x'!=. & drug==0
				count if (`x' < start_date | `x' > start_date + 28) & `x'!=. & drug>0
}
egen ae_spc_gp = rmin($ae_spc)
egen ae_spc_serious = rmin($ae_spc_icd)
egen ae_spc_emerg = rmin($ae_spc_emerg)
egen ae_spc_all = rmin($ae_spc $ae_spc_icd $ae_spc_emerg)
egen ae_drug_gp = rmin($ae_drug)
egen ae_drug_serious = rmin($ae_drug_icd)
egen ae_drug_emerg = rmin($ae_drug_emerg)
egen ae_drug_all = rmin($ae_drug $ae_drug_icd $ae_drug_emerg)
egen ae_imae_gp = rmin($ae_imae)
egen ae_imae_serious = rmin($ae_imae_icd)
egen ae_imae_emerg = rmin($ae_imae_emerg)
egen ae_imae_all = rmin($ae_imae $ae_imae_icd $ae_imae_emerg)	
egen ae_all = rmin($ae_spc $ae_spc_icd $ae_spc_emerg $ae_drug $ae_drug_icd $ae_drug_emerg $ae_imae $ae_imae_icd $ae_imae_emerg)
egen ae_all_serious = rmin($ae_spc_icd $ae_spc_emerg $ae_drug_icd $ae_drug_emerg $ae_imae_icd $ae_imae_emerg)

by drug, sort: count if ae_spc_all!=.
by drug, sort: count if ae_drug_all!=.
by drug, sort: count if ae_imae_all!=.
by drug, sort: count if ae_all!=.

*** Secondary outcome - SAEs hospitalisation or death including COVID-19 
* death
bys drug: count if died_date_ons!=.

* a&e all admission
bys drug: count if allcause_emerg_aande!=.

*covid admission
// checking admission and discharge date; missing admission, missing dischagre, or dischagre preceed admission 
count if covid_hosp_date!=.&covid_discharge_date==.
count if covid_hosp_date==.&covid_discharge_date!=.
count if covid_hosp_date!=.&covid_discharge_date!=.&covid_hosp_date==covid_discharge_date
count if covid_hosp_date!=.&covid_discharge_date!=.&covid_hosp_date<covid_discharge_date
count if covid_hosp_date!=.&covid_discharge_date!=.&covid_hosp_date>covid_discharge_date
// all covid hospitalisation
bys drug: count if covid_hosp_date!=. 
// covid admission on treatment date (control group will not have covid_hosp_date0)
bys drug: count if covid_hosp_date0!=. 
//  covid admission is the same as date treated 
bys drug: count if covid_hosp_date0==date_treated&covid_hosp_date0!=.&date_treated!=.
bys drug: count if covid_hosp_date1==(date_treated+1) &covid_hosp_date1!=.&date_treated!=.
// covid admission is the same  as date treated and is a daycase
bys drug: count if covid_hosp_date0==covid_discharge_date0&covid_hosp_date0!=.
bys drug: count if covid_hosp_date1==covid_discharge_date1&covid_hosp_date1!=.
// covid admission is the same date as mab
bys drug: count if covid_hosp_date0==covid_hosp_date_mabs&covid_hosp_date_mabs!=.
bys drug: count if covid_hosp_date1==covid_hosp_date_mabs&covid_hosp_date_mabs!=.
// covid admission is the same date as mab and is a daycase or 24 hour admission
bys drug: count if covid_hosp_date0==covid_hosp_date_mabs&covid_hosp_date0!=.&covid_hosp_date0==covid_discharge_date0
bys drug: count if covid_hosp_date1==covid_hosp_date_mabs&covid_hosp_date1!=.&covid_hosp_date1==covid_discharge_date1
bys drug: count if covid_hosp_date0==covid_hosp_date_mabs&covid_hosp_date0!=.&(covid_discharge_date0 - covid_hosp_date0)==1
bys drug: count if covid_hosp_date1==covid_hosp_date_mabs&covid_hosp_date1!=.&(covid_discharge_date1 - covid_hosp_date1)==1
// REPLACE - ignore covid admission if admission is the day 0 or day 1 after treatment date treated AND a day case
replace covid_hosp_date=. if covid_hosp_date0==covid_discharge_date0&covid_hosp_date0!=.
replace covid_hosp_date=. if covid_hosp_date1==covid_discharge_date1&covid_hosp_date1!=.  
// REPLACE - ignore covid admission if admission is the day 0 or day 1 after treatment date AND a mab procedures 
replace covid_hosp_date=. if covid_hosp_date0==covid_hosp_date_mabs&covid_hosp_date0!=.&covid_hosp_date0==covid_discharge_date0
replace covid_hosp_date=. if covid_hosp_date1==covid_hosp_date_mabs&covid_hosp_date1!=.&covid_hosp_date1==covid_discharge_date1
replace covid_hosp_date=. if covid_hosp_date0==covid_hosp_date_mabs&covid_hosp_date0!=.&(covid_discharge_date0 - covid_hosp_date0)==1
replace covid_hosp_date=. if covid_hosp_date1==covid_hosp_date_mabs&covid_hosp_date1!=.&(covid_discharge_date1 - covid_hosp_date1)==1

*hosp admission
// checking admission and discharge date; missing admission, missing dischagre, or dischagre preceed admission 
count if all_hosp_date!=.&hosp_discharge_date==.
count if all_hosp_date==.&hosp_discharge_date!=.
count if all_hosp_date!=.&hosp_discharge_date!=.&all_hosp_date==hosp_discharge_date
count if all_hosp_date!=.&hosp_discharge_date!=.&all_hosp_date<hosp_discharge_date
count if all_hosp_date!=.&hosp_discharge_date!=.&all_hosp_date>hosp_discharge_date
// all hospitalisation
bys drug: count if all_hosp_date!=.
// admission on treatment date (control group will not have hosp_date0)
bys drug: count if all_hosp_date0!=. 
// admission is the same date as date treated 
bys drug: count if all_hosp_date0==date_treated&all_hosp_date0!=.&date_treated!=.
bys drug: count if all_hosp_date1==(date_treated+1) &all_hosp_date1!=.&date_treated!=.
// admission is the same date as date treated and is a daycase
bys drug: count if all_hosp_date0==hosp_discharge_date0&all_hosp_date0!=.
bys drug: count if all_hosp_date1==hosp_discharge_date1&all_hosp_date1!=.
// admission is for Covid and is the same date as date treated and is a daycase
bys drug: count if all_hosp_date0==covid_hosp_date0  & all_hosp_date0==hosp_discharge_date0&all_hosp_date0!=.
bys drug: count if all_hosp_date1==covid_hosp_date1 & all_hosp_date1==hosp_discharge_date1&all_hosp_date1!=.
//  admission is the same date as mab
bys drug: count if all_hosp_date0==covid_hosp_date_mabs&covid_hosp_date_mabs!=.
bys drug: count if all_hosp_date1==covid_hosp_date_mabs&covid_hosp_date_mabs!=.
//  admission is the same date as mab and is a daycase, 1 day admission
bys drug: count if all_hosp_date0==covid_hosp_date_mabs&all_hosp_date0!=.&all_hosp_date0==hosp_discharge_date0
bys drug: count if all_hosp_date1==covid_hosp_date_mabs&all_hosp_date1!=.&all_hosp_date1==hosp_discharge_date1
bys drug: count if all_hosp_date0==covid_hosp_date_mabs&all_hosp_date0!=.&(hosp_discharge_date0-all_hosp_date0)==1
bys drug: count if all_hosp_date1==covid_hosp_date_mabs&all_hosp_date1!=.&(hosp_discharge_date1-all_hosp_date1)==1
//  admission is is for Covid and the same date as mab and is a daycase, 1 day admission
bys drug: count if all_hosp_date0==covid_hosp_date0 & all_hosp_date0==covid_hosp_date_mabs&all_hosp_date0!=.&all_hosp_date0==hosp_discharge_date0
bys drug: count if all_hosp_date1==covid_hosp_date1 & all_hosp_date1==covid_hosp_date_mabs&all_hosp_date1!=.&all_hosp_date1==hosp_discharge_date1
bys drug: count if all_hosp_date0==covid_hosp_date0 & all_hosp_date0==covid_hosp_date_mabs&all_hosp_date0!=.&(hosp_discharge_date0-all_hosp_date0)==1
bys drug: count if all_hosp_date1==covid_hosp_date1 & all_hosp_date1==covid_hosp_date_mabs&all_hosp_date1!=.&(hosp_discharge_date1-all_hosp_date1)==1
// REPLACE - ignore covid admission if admission is for covid AND day 0 or day 1 after treatment AND daycase
replace all_hosp_date=. if all_hosp_date0==covid_hosp_date0 & all_hosp_date0==hosp_discharge_date0 & all_hosp_date0!=.
replace all_hosp_date=. if all_hosp_date1==covid_hosp_date1 & all_hosp_date1==hosp_discharge_date1 & all_hosp_date1!=.
// REPLACE - ignore admission if admission is for covid AND day 0 or day 1 after treatment 
replace all_hosp_date=. if all_hosp_date0==covid_hosp_date0 & all_hosp_date0==covid_hosp_date_mabs&all_hosp_date0!=.&all_hosp_date0==hosp_discharge_date0
replace all_hosp_date=. if all_hosp_date1==covid_hosp_date1 & all_hosp_date1==covid_hosp_date_mabs&all_hosp_date1!=.&all_hosp_date1==hosp_discharge_date1
replace all_hosp_date=. if all_hosp_date0==covid_hosp_date0 & all_hosp_date0==covid_hosp_date_mabs&all_hosp_date0!=.&(hosp_discharge_date0 - all_hosp_date0)==1
replace all_hosp_date=. if all_hosp_date1==covid_hosp_date1 & all_hosp_date1==covid_hosp_date_mabs&all_hosp_date1!=.&(hosp_discharge_date1 - all_hosp_date1)==1

foreach var of varlist allcause_emerg_aande covid_hosp_date all_hosp_date died_date_ons{
				display "`var'"
				bys drug: count if (`var' >= start_date & `var' <= start_date + 28) & `var'!=.				
				bys drug: count if (`var' < start_date | `var' > start_date + 28) & `var'!=.				
}

****************************
*	COVARIATES		*
****************************
*Time between 1st positive covid test and treatment*
gen pre_drug_test=3 if drug>0 & covid_test_positive_date!=. &(date_treated-covid_test_positive_date>0)&(date_treated-covid_test_positive_date<21)
replace pre_drug_test=2 if drug>0 & covid_test_positive_date!=. &(date_treated-covid_test_positive_date>0)&(date_treated-covid_test_positive_date<=7)
replace pre_drug_test=1 if drug>0 & covid_test_positive_date!=. &(date_treated-covid_test_positive_date>0)&(date_treated-covid_test_positive_date<=5)
replace pre_drug_test=0 if drug>0 & covid_test_positive_date!=. &(date_treated-covid_test_positive_date>=0)&(date_treated-covid_test_positive_date<=3)
replace pre_drug_test=4 if drug>0 & (date_treated-covid_test_positive_date<0) & (date_treated-covid_test_positive_date>-7)
replace pre_drug_test=5 if drug>0 & (covid_test_positive_date==. | (date_treated-covid_test_positive_date<=-7) | (date_treated-covid_test_positive_date>=21)) 
label define pre_drug_test 0 "<3 days" 1 "3-5 days"  2 "5-7 days" 3 ">7 days & <21 days" 4 "treatment proceeds test <7 days" 5 "no test", replace 
label values pre_drug_test pre_drug_test
tab pre_drug_test drug,m

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
tab drug region_nhs
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
* time between vaccine and covid positive test or treatment
gen days_vacc_covid=covid_test_positive_date - last_vaccination_date if (covid_test_positive_date>last_vaccination_date & drug==0)
sum days_vacc_covid,de
gen days_vacc_treat=date_treated - last_vaccination_date if (date_treated>last_vaccination_date & drug>0)
sum days_vacc_treat,de
gen days_vacc_treat_test = days_vacc_covid if drug==0
replace days_vacc_treat_test = days_vacc_treat if drug>0
sum days_vacc_treat_test,de
gen month_vacc_covid=ceil(days_vacc_treat_test/30)
tab month_vacc_covid,m
*Calendar time*
gen day_after_campaign=start_date-mdy(12,15,2021)
sum day_after_campaign,de
gen month_after_campaign=ceil((start_date-mdy(12,15,2021))/30)
tab month_after_campaign,m
tab start_date if month_after_campaign>100
drop if month_after_campaign>100
* Variant
label define sgtf_new 0 "S gene detected" 1 "confirmed SGTF" 9 "NA"
label values sgtf_new sgtf_new
* Prior infection / check Bang code
tab prior_covid, m
gen prior_covid_index=1 if prior_covid==1 & prior_covid_date<campaign_start
tab prior_covid_index,m
replace prior_covid_index=0 if prior_covid_index==.
*Contraindications for Pax*
tab drug if organ_transplant==1
tab drug if liver_disease_nhsd_icd10==1
tab drug if renal_disease==1
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
tab drug if egfr_60==1
tab drug if egfr_30==1
*drug interactions*
tab drug if drugs_paxlovid_interaction<=start_date
tab drug if drugs_paxlovid_interaction<=start_date&drugs_paxlovid_interaction>=(start_date-3*365.25)
tab drug if drugs_paxlovid_interaction<=start_date&drugs_paxlovid_interaction>=(start_date-365.25)
tab drug if drugs_paxlovid_interaction<=start_date&drugs_paxlovid_interaction>=(start_date-180)
tab drug if drugs_nirmatrelvir_interaction<=start_date
tab drug if drugs_nirmatrelvir_interaction<=start_date&drugs_nirmatrelvir_interaction>=(start_date-3*365.25)
tab drug if drugs_nirmatrelvir_interaction<=start_date&drugs_nirmatrelvir_interaction>=(start_date-365.25)
tab drug if drugs_nirmatrelvir_interaction<=start_date&drugs_nirmatrelvir_interaction>=(start_date-180)
gen paxlovid_interaction=(drugs_paxlovid_interaction<=start_date&drugs_paxlovid_interaction>=(start_date-180))  
gen nirmatrelvir_interaction=(drugs_nirmatrelvir_interaction<=start_date&drugs_nirmatrelvir_interaction>=(start_date-180))
* Drug contraindicated 
gen paxlovid_contraindicated = 1 if egfr_30==1 | dialysis==1
replace paxlovid_contraindicated = 1 if liver_disease==1 
replace paxlovid_contraindicated = 1 if organ_transplant==1 
replace paxlovid_contraindicated = 1 if drugs_paxlovid_interaction<=start_date&drugs_paxlovid_interaction>=(start_date-180)
recode paxlovid_contraindicated . = 0
by drug, sort: count if paxlovid_contraindicated==1

****************************
*	COX MODEL		*
****************************
global ae		ae_spc_all 				///
				ae_drug_all				///		
				ae_imae_all 			///				
				ae_all					///
				allcause_emerg_aande 	///
				covid_hosp_date			///
				all_hosp_date			///
				died_date_ons

* Generate failure 
foreach x in	$ae $ae_disease ///
				$ae_spc $ae_spc_icd $ae_spc_emerg ///
				$ae_drug $ae_drug_icd $ae_drug_emerg ///
				$ae_imae $ae_imae_icd $ae_imae_emerg ///
				{
	display "`x'"
	by drug, sort: count if `x'!=.
	by drug, sort: count if `x'>=start_date & `x'!=.
	by drug, sort: count if `x'>=start_date & `x'<start_date_29 &`x'!=.
	gen fail_`x'=(`x'!=.&`x'<= min(study_end_date, start_date_29, paxlovid, molnupiravir)) if drug==1
	replace fail_`x'=(`x'!=.&`x'<= min(study_end_date, start_date_29, sotrovimab, molnupiravir)) if drug==2
	replace fail_`x'=(`x'!=.&`x'<= min(study_end_date, start_date_29, sotrovimab, paxlovid)) if drug==3
	replace fail_`x'=(`x'!=.&`x'<= min(study_end_date, start_date_29, sotrovimab, paxlovid, molnupiravir)) if drug==0
	tab drug fail_`x', m
}

* Add half-day buffer if outcome on indexdate
foreach x in	$ae $ae_disease ///
				$ae_spc $ae_spc_icd $ae_spc_emerg ///
				$ae_drug $ae_drug_icd $ae_drug_emerg ///
				$ae_imae $ae_imae_icd $ae_imae_emerg ///
				{
	display "`x'"
	replace `x'=`x'+0.5 if `x'==start_date
}

*Generate censor date
foreach x in	$ae $ae_disease ///
				$ae_spc $ae_spc_icd $ae_spc_emerg ///
				$ae_drug $ae_drug_icd $ae_drug_emerg ///
				$ae_imae $ae_imae_icd $ae_imae_emerg ///
				{
	gen stop_`x'=`x' if fail_`x'==1
	replace stop_`x'=min(death_date,dereg_date,study_end_date,start_date_29,paxlovid,molnupiravir) if fail_`x'==0&drug==1
	replace stop_`x'=min(death_date,dereg_date,study_end_date,start_date_29,sotrovimab,molnupiravir) if fail_`x'==0&drug==2
	replace stop_`x'=min(death_date,dereg_date,study_end_date,start_date_29,sotrovimab,paxlovid) if fail_`x'==0&drug==3
	replace stop_`x'=min(death_date,dereg_date,study_end_date,start_date_29,sotrovimab,paxlovid,molnupiravir) if fail_`x'==0&drug==0
	format %td stop_`x'
}

* Follow-up time
stset stop_ae_all, id(patient_id) origin(time start_date) enter(time start_date) failure(fail_ae_all==1) 
*count censored due to second therapy*
count if fail_ae_all==0&drug==1&min(paxlovid,molnupiravir)==stop_ae_all
count if fail_ae_all==0&drug==2&min(sotrovimab,molnupiravir)==stop_ae_all
count if fail_ae_all==0&drug==3&min(sotrovimab,paxlovid)==stop_ae_all
count if fail_ae_all==0&drug==0&min(sotrovimab,paxlovid,molnupiravir)==stop_ae_all
tab _st  // keep if _st==1 -> removes observations that end on or before enter 
count if start_date>=stop_ae_all & _st==0
count if start_date==stop_ae_all & _st==0
tab _t,m
tab _t drug,m col
tab _t drug if fail_ae_all==1,m col
tab _t drug if fail_ae_all==1&stop_ae_all==ae_all
tab fail_ae_all drug,m col
*check censor reasons*
tab _t drug if fail_ae_all==0&_t<28&stop_ae_all==ae_all,m col
tab _t drug if fail_ae_all==0&_t<28&stop_ae_all==death_date,m col
tab _t drug if fail_ae_all==0&_t<28&stop_ae_all==dereg_date,m col
tab _t drug if fail_ae_all==0&_t<28&stop_ae_all==min(paxlovid,molnupiravir)&drug==1,m col
tab _t drug if fail_ae_all==0&_t<28&stop_ae_all==min(sotrovimab,molnupiravir)&drug==2,m col
tab _t drug if fail_ae_all==0&_t<28&stop_ae_all==min(sotrovimab,paxlovid)&drug==3,m col
tab _t drug if fail_ae_all==0&_t<28&stop_ae_all==min(sotrovimab,paxlovid,molnupiravir)&drug==0,m col


save "$projectdir/output/data/main.dta", replace

log close
