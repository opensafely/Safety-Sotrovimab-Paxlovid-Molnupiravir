********************************************************************************
*
*	Do-file:			preceeding rate
*	Project:			Sotrovimab-Paxlovid-Molnupiravir
*   Date:  				06/4/23
*	Programmed by:		Katie Bechman
* 	Description:		run cox models
*	Data used:			main.dta
*	Data created:		preceeding rate
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
log using "$logdir/preceed_rate.log", replace

*Set Ado file path
adopath + "$projectdir/analysis/ado"

* SET Index date 
global indexdate 			= "01/03/2020"

use "$projectdir/output/data/main", clear

/* 
===========================================================*/

*	COMPARATOR RATE		
****************************
**generate rate for adverse outcome in year 3-4 prior to start date for comparative rate by person years 
*ensure not established diagnosis for some of the condition 4 year prior
gen new_pre_ra_ae = pre_rheumatoid_arthritis_ae if pre_ra_snomed_new==0 & pre_ra_icd_new==0  
gen new_pre_ra_snomed = pre_rheumatoid_arthritis_snomed if pre_ra_snomed_new==0 & pre_ra_icd_new==0
gen new_pre_ra_icd = pre_rheumatoid_arthritis_icd if pre_ra_snomed_new==0 & pre_ra_icd_new==0  
gen new_pre_ankspon_ctv = pre_ankylosing_spondylitis_ctv if pre_ankspon_ctv_new==0 
gen new_pre_ankspon_ae = pre_ankylosing_spondylitis_ae if pre_ankspon_ctv_new==0
gen new_pre_psoriasis_snomed = pre_psoriasis_snomed if pre_psoriasis_snomed_new==0 
gen new_pre_psoriasis_ae = pre_psoriasis_ae if pre_psoriasis_snomed_new==0
gen new_pre_psa_ae = pre_psoriatic_arthritis_ae if pre_psa_snomed_new==0 
gen new_pre_psa_snomed = pre_psoriatic_arthritis_snomed	if pre_psa_snomed_new==0 							 				
gen new_pre_sle_ctv = pre_sle_ctv if pre_sle_ctv_new==0 & pre_sle_icd_new==0  
gen new_pre_sle_icd = pre_sle_icd if pre_sle_ctv_new==0 & pre_sle_icd_new==0
gen new_pre_sle_ae = pre_sle_ae if pre_sle_ctv_new==0 & pre_sle_icd_new==0  

global preceeding_ae    new_pre_ra_ae 				///
						new_pre_ra_snomed 			///
						new_pre_ra_icd 				///
						new_pre_ankspon_ctv			///
						new_pre_ankspon_ae 			///
						new_pre_psoriasis_snomed	///
						new_pre_psoriasis_ae 		///
						new_pre_psa_ae 				///
						new_pre_sle_ctv 			///
						new_pre_psa_snomed 			///
						new_pre_sle_icd 			///
						new_pre_sle_ae				///
						pre_diverticulitis_icd		///
						pre_diverticulitis_snomed	///
						pre_diverticulitis_ae		///
						pre_diarrhoea_snomed 		///
						pre_taste_snomed			///
						pre_taste_icd				///
						pre_rash_snomed				///
						pre_anaphylaxis_icd			///
						pre_anaphylaxis_snomed		///
						pre_anaphlaxis_ae			///
						pre_drugreact_ae			///
						pre_allergic_ae			
  

*gen start date for comparator rate
gen start_comparator = start_date-1460
gen start_comparator_29 = start_date - 1431
*remove if occurred outside of window, gen failure and stop date: 
foreach x in $preceeding_ae {
		display "`x'"
		sum `x', f 
		count if (`x'<start_comparator | `x'>start_comparator_29) & `x'!=.  // event outside windown - should be 0 
		count if (`x'>start_comparator & `x'<start_comparator_29) & `x'!=.  // event 4-3 years prior to start
		gen fail_`x'=1 if `x'!=.
		tab drug fail_`x', m
		gen stop_`x'=`x' if fail_`x'==1
		replace stop_`x'= start_comparator_29 if fail_`x'==.
		tab drug fail_`x' if stop_`x'!=.
		format %td stop_`x'
}

tempname comparator
postfile `comparator' str20(failure) ///
	ptime_all events_all rate_all /// 
	ptime_control events_control rate_control /// 
	ptime_sot events_sot rate_sot ///
	ptime_pax events_pax rate_pax ///
	ptime_mol events_mol rate_mol ///
	using "$projectdir/output/tables/comparator_rate_summary", replace	
						 
* Failures over 1 years - convert into 29 day rate
foreach fail in $preceeding_ae {
							 
	stset stop_`fail', id(patient_id) origin(time start_comparator) enter(time start_comparator) failure(fail_`fail'==1)	
		stptime 
					local rate_all = `r(rate)'
					local ptime_all = `r(ptime)'
					local events_all .
						if `r(failures)' == 0 | `r(failures)' > 5 local events_all `r(failures)'
		
		stptime if drug == 0
					local rate_control = `r(rate)'
					local ptime_control = `r(ptime)'
					local events_control .
						if `r(failures)' == 0 | `r(failures)' > 5 local events_control `r(failures)'
		display "no drug"

		stptime if drug == 1
					local rate_sot = `r(rate)'
					local ptime_sot = `r(ptime)'
					local events_sot .
						if `r(failures)' == 0 | `r(failures)' > 5 local events_sot `r(failures)'
		display "sotrovimab"
		
		stptime if drug == 2
					local rate_pax = `r(rate)'
					local ptime_pax = `r(ptime)'
					local events_pax .
						if `r(failures)' == 0 | `r(failures)' > 5 local events_pax `r(failures)'
		display "paxlovid"
		
		stptime if drug == 3
					local rate_mol = `r(rate)'
					local ptime_mol = `r(ptime)'
					local events_mol .
						if `r(failures)' == 0 | `r(failures)' > 5 local events_mol `r(failures)'
		display "molnupavir"
						
		post `comparator' ("`fail'") (`ptime_all') (`events_all') (`rate_all') ///
					(`ptime_control') (`events_control') (`rate_control') ///
					(`ptime_sot') (`events_sot') (`rate_sot') ///
					(`ptime_pax') (`events_pax') (`rate_pax') ///
					(`ptime_mol') (`events_mol') (`rate_mol') 
					
}

postclose `comparator'

log close




