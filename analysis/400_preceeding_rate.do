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
gen new_pre_ra_icd = pre_rheumatoid_icd_prim if pre_ra_snomed_new==0 
gen new_pre_ra_ae = pre_rheumatoid_arthritis_ae if pre_ra_snomed_new==0 
gen new_pre_ra_snomed = pre_rheumatoid_arthritis_snomed if pre_ra_snomed_new==0 
gen new_pre_sle_ctv = pre_sle_ctv if pre_sle_ctv_new==0 
gen new_pre_sle_icd = pre_sle_icd_prim if pre_sle_ctv_new==0 
gen new_pre_sle_ae = pre_sle_ae if pre_sle_ctv_new==0 
gen new_pre_psoriasis_icd = pre_psoriasis_icd_prim if pre_psoriasis_snomed_new==0 
gen new_pre_psoriasis_snomed = pre_psoriasis_snomed if pre_psoriasis_snomed_new==0 
gen new_pre_psoriasis_ae = pre_psoriasis_ae if pre_psoriasis_snomed_new==0
gen new_pre_psa_icd = pre_psa_icd_prim if pre_psa_snomed_new==0
gen new_pre_psa_ae = pre_psa_ae if pre_psa_snomed_new==0 
gen new_pre_psa_snomed = pre_psa_snomed	if pre_psa_snomed_new==0 
gen new_pre_axspa_icd = pre_axspa_icd_prim if pre_axspa_ctv_new==0
gen new_pre_axspa_ctv = pre_axspa_ctv if pre_axspa_ctv_new==0 
gen new_pre_axspa_ae = pre_axspa_ae if pre_axspa_ctv_new==0
gen new_pre_ibd_icd = pre_ibd_icd_prim if pre_ibd_ctv_new==0
gen new_pre_ibd_ctv = pre_ibd_ctv if pre_ibd_ctv_new==0
gen new_pre_ibd_ae = pre_ibd_ae if pre_ibd_ctv_new==0

*** combined ae from GP, hosp and A&E
egen pre_diverticulitis = rmin(pre_diverticulitis_icd_prim pre_diverticulitis_snomed pre_diverticulitis_ae)	 
egen pre_diarrhoea = rmin(pre_diarrhoea_icd_prim pre_diarrhoea_snomed  pre_diarrhoeal_icd_prim)
egen pre_taste = rmin(pre_taste_icd_prim pre_taste_snomed )
egen pre_rash = rmin(pre_rash_icd_prim pre_rash_snomed pre_rash_ae)
egen pre_bronchospasm = rmin(pre_bronchospasm_snomed)
egen pre_contactderm = rmin(pre_contactderm_snomed pre_contactderm_icd_prim pre_contactderm_ae)
egen pre_dizziness = rmin(pre_dizziness_snomed pre_dizziness_ae pre_dizziness_icd_prim)
egen pre_nausea_vomit = rmin(pre_nausea_vomit_snomed pre_nausea_vomit_icd_prim)
egen pre_headache = rmin(pre_headache_snomed pre_headache_ae pre_headache_icd_prim)
egen pre_anaphylaxis = rmin(pre_anaphylaxis_icd_prim pre_anaphylaxis_snomed	pre_anaphlaxis_ae)
egen pre_severe_drug = rmin(pre_severedrug_icd_prim pre_severedrug_sjs_icd_prim pre_severedrug_snomed pre_severedrug_ae)
egen pre_nonsevere_drug = rmin(pre_nonsevere_drug_snomed pre_nonsevere_drug_ae)
egen pre_ra = rmin(new_pre_ra_icd new_pre_ra_ae new_pre_ra_snomed )
egen pre_sle = rmin(new_pre_sle_icd new_pre_sle_ctv new_pre_sle_ae)
egen pre_psorasis = rmin(new_pre_psoriasis_icd new_pre_psoriasis_snomed  new_pre_psoriasis_ae)
egen pre_psa = rmin(new_pre_psa_icd new_pre_psa_ae new_pre_psa_snomed)
egen pre_axspa = rmin(new_pre_axspa_icd  new_pre_axspa_ae new_pre_axspa_ctv)
egen pre_ibd = rmin(new_pre_ibd_icd new_pre_ibd_ctv new_pre_ibd_ae)
egen pre_spc_all = rmin(pre_diverticulitis pre_diarrhoea pre_taste) 
egen pre_drug_all = rmin(pre_anaphylaxis pre_severe_drug pre_nonsevere_drug)
egen pre_imae_all = rmin(pre_ra pre_sle pre_psorasis pre_psa pre_axspa pre_ibd)	
egen pre_ae_all = rmin(pre_spc_all pre_drug_all pre_imae_all)

global pre_ae_group			pre_spc_all 					///
							pre_drug_all					///		
							pre_imae_all 					///				
							pre_ae_all
global pre_ae_disease		pre_diverticulitis 				///
							pre_diarrhoea					///
							pre_taste 						///
							pre_rash 						///
							pre_bronchospasm				///
							pre_contactderm					///
							pre_dizziness					///
							pre_nausea_vomit				///
							pre_headache					///
							pre_anaphylaxis 				///
							pre_severe_drug					///
							pre_nonsevere_drug				///
							pre_ra 							///
							pre_sle 						///
							pre_psorasis 					///
							pre_psa 						///
							pre_axspa	 					///
							pre_ibd 		

*gen start date for comparator rate
gen start_comparator = start_date-1460
gen start_comparator_28 = start_date - 1431
*remove if occurred outside of window, gen failure and stop date: 
foreach x in $pre_ae_group $pre_ae_disease {
		display "`x'"
		count if `x'!=. 
		count if (`x'<start_comparator | `x'>start_comparator_28) & `x'!=.  // event outside windown - should be 0 
		count if (`x'>start_comparator & `x'<start_comparator_28) & `x'!=.  // event 4-3 years prior to start
		gen fail_`x'=1 if `x'!=.
		tab drug fail_`x', m
		gen stop_`x'=`x' if fail_`x'==1
		replace `x'=`x'+0.75 if `x'==start_date
		replace stop_`x'= start_comparator_28 if fail_`x'==.
		tab drug fail_`x' if stop_`x'!=.
		format %td stop_`x'
}

* Follow-up time
stset stop_pre_ae_all, id(patient_id) origin(time start_comparator) enter(time start_comparator) exit(time start_comparator_28) failure(fail_pre_ae_all==1) 
tab _st  // keep if _st==1 -> removes observations that end on or before enter 
count if start_comparator>=stop_pre_ae_all & _st==0
count if start_comparator==stop_pre_ae_all & _st==0
tab _t,m


** Rates of events 
tempname comparator_rates
postfile `comparator_rates' str20(failure) ///
		ptime_all events_all rate_all lci_all uci_all ///
		ptime_control events_control rate_control lci_control uci_control ///
		ptime_sot events_sot rate_sot lci_sot uci_sot ///
		ptime_pax events_pax rate_pax lci_pax uci_pax ///
		ptime_mol events_mol rate_mol lci_mol uci_mol ///
		using "$projectdir/output/tables/comparator_rates", replace							 
foreach fail in $ae_group $ae_disease {
	stset stop_`fail', id(patient_id) origin(time start_date) enter(time start_date) failure(fail_`fail'==1) 			
		stptime 
					local rate_all = `r(rate)'
					local ptime_all = `r(ptime)'
					local lci_all = `r(lb)'
					local uci_all = `r(ub)'
					local events_all .
						if `r(failures)' == 0 | `r(failures)' > 7 local events_all `r(failures)'
		stptime if drug == 0
					local rate_control = `r(rate)'
					local ptime_control = `r(ptime)'
					local lci_control = `r(lb)'
					local uci_control = `r(ub)'
					local events_control .
						if `r(failures)' == 0 | `r(failures)' > 7 local events_control `r(failures)'
		display "no drug"
		stptime if drug == 1
					local rate_sot = `r(rate)'
					local ptime_sot = `r(ptime)'
					local lci_sot = `r(lb)'
					local uci_sot = `r(ub)'
					local events_sot .
						if `r(failures)' == 0 | `r(failures)' > 7 local events_sot `r(failures)'
		display "sotrovimab"
		stptime if drug == 2
					local rate_pax = `r(rate)'
					local ptime_pax = `r(ptime)'
					local lci_pax = `r(lb)'
					local uci_pax = `r(ub)'
					local events_pax .
						if `r(failures)' == 0 | `r(failures)' > 7 local events_pax `r(failures)'
		display "paxlovid"
		stptime if drug == 3
					local rate_mol = `r(rate)'
					local ptime_mol = `r(ptime)'
					local lci_mol = `r(lb)'
					local uci_mol = `r(ub)'
					local events_mol .
						if `r(failures)' == 0 | `r(failures)' > 7 local events_mol `r(failures)'
		display "molnupavir"			
		post `comparator_rates' ("`fail'") (`ptime_all') (`events_all') (`rate_all') (`lci_all') (`uci_all') ///
					(`ptime_control') (`events_control') (`rate_control') (`lci_control') (`uci_control') ///
					(`ptime_sot') (`events_sot') (`rate_sot') (`lci_sot') (`uci_sot') ///
					(`ptime_pax') (`events_pax') (`rate_pax') (`lci_pax') (`uci_pax') ///
					(`ptime_mol') (`events_mol') (`rate_mol') (`lci_mol') (`uci_mol') ///
					
}
postclose `comparator_rates'

use "$projectdir/output/tables/comparator_rates", clear	
foreach var of varlist rate* lci* uci* {
	
gen `var'_per = `var'*1000	
format `var'_per %3.2f
drop `var'	
rename 	`var'_per `var'				
}
order  	failure ptime_all events_all rate_all lci_all uci_all ///
		ptime_control events_control rate_control lci_control uci_control ///
		ptime_sot events_sot rate_sot lci_sot uci_sot ///
		ptime_pax events_pax rate_pax lci_pax uci_pax ///
		ptime_mol events_mol rate_mol lci_mol uci_mol
save "$projectdir/output/tables/comparator_rates", replace

use "$projectdir/output/tables/comparator_rates", replace
export delimited using "$projectdir/output/tables/comparator_rates.csv", replace

log close




