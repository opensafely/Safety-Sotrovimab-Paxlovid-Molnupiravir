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
global projectdir "C:\Users\k1635179\OneDrive - King's College London\Katie\OpenSafely\Safety mAB and antivirals\Safety-Sotrovimab-Paxlovid-Molnupiravir"
//global projectdir `c(pwd)'
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

*********************************
*	Convert strings to dates     *
********************************* 
foreach var of varlist 	 covid_test_positive_date				///
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
						 drugs_do_not_use						///
						 drugs_consider_risk					///
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
						 covid_hosp_date0 						///
						 covid_hosp_date1 						///
						 covid_hosp_date2  						///						
						 covid_discharge_date0				  	///  						
						 covid_discharge_date1					/// 
						 covid_discharge_date2					/// 
						 any_covid_hosp_discharge				///			
						 covid_hosp_date_mabs					/// 
						 covid_hosp_date_mabs_not_primary		/// 
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

****************************
*	EXPOSURE		*
****************************
** removing individuals who did not start therapy
foreach var of varlist sotrovimab molnupiravir paxlovid {
    display "`var'"
	count if `var'!=.
	count if `var'==date_treated & `var'!=. & date_treated!=.
	gen `var'_start = 1 if `var'==date_treated & `var'!=. & date_treated!=. & `var'_not_start==.
	replace `var'_start = 0 if `var'==date_treated & `var'!=. & date_treated!=. & `var'_not_start!=.
	tab `var'_start, m  //number on treatment, first drug given, and drug was started
}
gen drug=1 if sotrovimab==date_treated & sotrovimab_start==1 
replace drug=2 if paxlovid==date_treated & paxlovid_start==1
replace drug=3 if molnupiravir==date_treated & molnupiravir_start==1
replace drug=4 if sotrovimab==date_treated & sotrovimab_start==0 
replace drug=5 if paxlovid==date_treated & paxlovid_start==0 
replace drug=6 if molnupiravir==date_treated & molnupiravir_start==0 
replace drug=7 if remdesivir==date_treated&remdesivir!=.&date_treated!=.
replace drug=8 if casirivimab==date_treated&casirivimab!=.&date_treated!=.
replace drug=0 if drug==.
label define drug 0 "control" 1 "sotrovimab" 2 "paxlovid" 3"molnupiravir", replace
label values drug drug
tab drug, m
drop if drug>3
** start date is date treatment for treatment arms and date of covid test for control arm 
count if start_date==. //should be 0
count if start_date!=covid_test_positive_date & drug==0
count if start_date!=date_treated & drug>0
replace start_date=covid_test_positive_date if drug==0 
replace start_date=date_treated if drug>0
** check number of positive covid tests prior to drug in treatment arms
bys drug:count if covid_test_positive_date==. // should be 0 in control arm
bys drug:count if covid_test_positive_date!=. 
bys drug:count if covid_test_positive_date!=.&date_treated!=.& date_treated>covid_test_positive_date //test prior to treatment
bys drug:count if covid_test_positive_date!=.&date_treated!=.& (date_treated-covid_test_positive_date>0)&(date_treated-covid_test_positive_date<=5) //test <5d
bys drug:count if covid_test_positive_date2!=.&date_treated!=.& date_treated<covid_test_positive_date2 //2nd covid episode prior to treatment 
bys drug:count if covid_test_positive_date2!=.&date_treated!=.& (date_treated-covid_test_positive_date2>0)&(date_treated-covid_test_positive_date2<=5) //test <5d
bys drug:count if covid_test_positive_date3!=.&date_treated!=.& date_treated<covid_test_positive_date3 //3rd covid episode prior to treatment 
bys drug:count if covid_test_positive_date3!=.&date_treated!=.& (date_treated-covid_test_positive_date3>0)&(date_treated-covid_test_positive_date3<=5) //test <5d
** check in control group that covid positive, and not repeat covid test after an infection within 30 days prior
tab covid_test_positive covid_positive_previous_30_days if drug==0
drop if drug==0 & covid_test_positive==1 & covid_positive_previous_30_days==1
** gen study start and study end date
gen campaign_start=mdy(12,16,2021)
gen study_end_date=mdy(06,01,2023)
gen start_date_29=date_treated+28
format campaign_start study_end_date start_date_29 %td

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
tab high_risk_cohort_therapeutics drug,m //should be 0 in control group
gen downs_syndrome_therap= 1 if strpos(high_risk_cohort_therapeutics, "Downs syndrome")
gen solid_cancer_therap=1 if strpos(high_risk_cohort_therapeutics, "solid cancer")
gen haem_disease_therap=1 if strpos(high_risk_cohort_therapeutics, "haematological malignancies")
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
bys drug: count if high_risk_cohort_therapeutics!=""&high_risk_cohort_therapeutics!="other"& min(downs_syndrome_therap,solid_cancer_therap,haem_disease_therap,renal_disease_therap,liver_disease_therap,imid_on_drug_therap,immunosupression_therap,hiv_aids_therap,organ_transplant_therap,rare_neuro_therap)==. //check if all diseases have been captured
tab drug high_risk_cohort_therapeutics if high_risk_cohort_therapeutics!=""&high_risk_cohort_therapeutics!="other"& min(downs_syndrome_therap,solid_cancer_therap,haem_disease_therap,renal_disease_therap,liver_disease_therap,imid_on_drug_therap,immunosupression_therap,hiv_aids_therap,organ_transplant_therap,rare_neuro_therap)==.
foreach var of varlist downs_syndrome_therap solid_cancer_therap haem_disease_therap renal_disease_therap liver_disease_therap imid_on_drug_therap immunosupression_therap hiv_aids_therap organ_transplant_therap rare_neuro_therap{
	replace `var'=0 if `var'==. 
}

** high risk cohort from open codelist from control group
tab high_risk_cohort_nhsd drug,m //should be no 0s in control group
count if imid_on_drug==1 & imid_nhsd==1 & imid_drug==0 //should be 0
count if imid_on_drug==1 & imid_nhsd==1 & imid_drug==0 & downs_syndrome==0 &solid_cancer==0 &haem_disease==0 &renal_disease==0 &liver_disease==0 &immunosupression==0 &hiv_aids==0 &organ_transplant==0 &rare_neuro==0
count if imid_on_drug==1 & imid_nhsd==0 & imid_drug==1 //should be 0
count if imid_on_drug==1 & imid_nhsd==0 & imid_drug==1 & downs_syndrome==0 &solid_cancer==0 &haem_disease==0 &renal_disease==0 &liver_disease==0 &immunosupression==0 &hiv_aids==0 &organ_transplant==0 &rare_neuro==0
count if oral_steroid_drug_nhsd_6m_count<4 &oral_steroid_drugs_nhsd==1
count if oral_steroid_drug_nhsd_6m_count<4 &oral_steroid_drugs_nhsd==1 &immunosuppresant==0 &methotrexate==0 &ciclosporin==0 &mycophenolate==0 
count if oral_steroid_drug_nhsd_6m_count<4 &oral_steroid_drugs_nhsd==1 &immunosuppresant==0 &methotrexate==0 &ciclosporin==0 &mycophenolate==0 &imid_on_drug==1
count if oral_steroid_drug_nhsd_6m_count<4 &oral_steroid_drugs_nhsd==1 &immunosuppresant==0 &methotrexate==0 &ciclosporin==0 &mycophenolate==0 &imid_on_drug==1 &downs_syndrome==0 &solid_cancer==0 &haem_disease==0 &renal_disease==0 &liver_disease==0 &immunosupression==0 &hiv_aids==0 &organ_transplant==0 &rare_neuro==0
replace imid_on_drug=0 if oral_steroid_drug_nhsd_6m_count<4 &oral_steroid_drugs_nhsd==1 &immunosuppresant==0 &methotrexate==0 &ciclosporin==0 &mycophenolate==0 &imid_on_drug==1 //ignore if steriods<4 scripts in 6m & not coded other imid drug 
replace oral_steroid_drugs_nhsd=0 if oral_steroid_drug_nhsd_6m_count<4 &oral_steroid_drugs_nhsd==1 //ignore if steriods<4 scripts in 6m
count if imid_on_drug==1 & imid_nhsd==1 & imid_drug==0 //should be same number as those dropped above 
replace imid_on_drug=0 if imid_nhsd==1 & imid_drug==0 
replace imid_on_drug=0 if imid_nhsd==0 & imid_drug==1 
gen high_risk_cohort_codelist=((downs_syndrome + solid_cancer + haem_disease + renal_disease + liver_disease + imid_on_drug + immunosupression + hiv_aids + organ_transplant + rare_neuro )>0)
tab high_risk_cohort_nhsd high_risk_cohort_codelist

** combine two high risk cohorts into one 
foreach var of varlist downs_syndrome solid_cancer haem_disease renal_disease liver_disease imid_on_drug immunosupression hiv_aids organ_transplant rare_neuro {
	gen `var'_comb = `var'
	replace `var'_comb = 1 if `var'_therap==1 
	tab `var' `var'_therap 
	tab `var'_comb
}

****************************
*	OUTCOME		*
****************************
*** Primary outcome - AESI
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
global ae_drug 			ae_anaphylaxis_snomed			///	
						ae_rash_snomed	
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
				count if (`x' > start_date | `x' < start_date + 28) & `x'!=. 
				count if (`x' < start_date | `x' > start_date + 28) & `x'!=. & drug==0
				count if (`x' < start_date | `x' > start_date + 28) & `x'!=. & drug>0
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
bys drug: count if covid_hosp_date!=. // all hospitalisation
bys drug: count if covid_hosp_date0!=. // *nb: control group will not have covid_hosp_date0 - as do not have date_treated
// covid admission is the same date as date treated 
bys drug: count if covid_hosp_date0!=date_treated&covid_hosp_date0!=.&date_treated!=.
bys drug: count if covid_hosp_date1!=(date_treated+1) &covid_hosp_date1!=.&date_treated!=.
// covid admission is the same date as date treated and is a daycase
bys drug:count if covid_hosp_date0==covid_discharge_date0&covid_hosp_date0!=.
bys drug: count if covid_hosp_date1==covid_discharge_date1&covid_hosp_date1!=.
// covid admission is the same date as mab
bys drug: count if covid_hosp_date0==covid_hosp_date_mabs&covid_hosp_date_mabs!=.
bys drug: count if covid_hosp_date1==covid_hosp_date_mabs&covid_hosp_date_mabs!=.
// covid admission is the same date as mab and is a daycase, 1 day admission
bys drug: count if covid_hosp_date0==covid_hosp_date_mabs&covid_hosp_date0!=.&covid_hosp_date0==covid_discharge_date0
bys drug: count if covid_hosp_date1==covid_hosp_date_mabs&covid_hosp_date1!=.&covid_hosp_date1==covid_discharge_date1
bys drug: count if covid_hosp_date0==covid_hosp_date_mabs&covid_hosp_date0!=.&(covid_discharge_date0 - covid_hosp_date0)==1
bys drug: count if covid_hosp_date1==covid_hosp_date_mabs&covid_hosp_date1!=.&(covid_discharge_date1 - covid_hosp_date1)==1
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
*Time between positive test and treatment*
gen pre_drug_test=9 if drug>0 & covid_test_positive_date==. 
replace pre_drug_test=99 if drug>0 & (date_treated-covid_test_positive_date<0)
replace pre_drug_test=2 if drug>0 & covid_test_positive_date!=. &(date_treated-covid_test_positive_date>0)&(date_treated-covid_test_positive_date<=7)
replace pre_drug_test=1 if drug>0 & covid_test_positive_date!=. &(date_treated-covid_test_positive_date>0)&(date_treated-covid_test_positive_date<=5)
replace pre_drug_test=0 if drug>0 & covid_test_positive_date!=. &(date_treated-covid_test_positive_date>0)&(date_treated-covid_test_positive_date<=3)
label define pre_drug_test 0 "<3 days" 1 "3-5 days"  2 "5-7 days" 9 "more than 7 days" 99"treatment proceeds test", replace 
label values pre_drug_test pre_drug_test
tab pre_drug_test drug,mlavel

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
replace imd=. if imd=="DEFAULT" //changed to DEFAULT not 0 - may need to destring no
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
tab prior_covid, m
gen prior_covid_index=1 if prior_covid==1 & prior_covid_date<campaign_start
tab prior_covid_index,m
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





































