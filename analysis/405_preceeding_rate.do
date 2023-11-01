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

*** combined all AEs from GP, hosp and A&E
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
egen pre_drugreaction = rmin(pre_severedrug_icd_prim pre_severedrug_sjs_icd_prim pre_severedrug_snomed pre_severedrug_ae pre_nonsevere_drug_snomed pre_nonsevere_drug_ae)
egen pre_ra = rmin(new_pre_ra_icd new_pre_ra_ae new_pre_ra_snomed )
egen pre_sle = rmin(new_pre_sle_icd new_pre_sle_ctv new_pre_sle_ae)
egen pre_psorasis = rmin(new_pre_psoriasis_icd new_pre_psoriasis_snomed  new_pre_psoriasis_ae)
egen pre_psa = rmin(new_pre_psa_icd new_pre_psa_ae new_pre_psa_snomed)
egen pre_axspa = rmin(new_pre_axspa_icd  new_pre_axspa_ae new_pre_axspa_ctv)
egen pre_ibd = rmin(new_pre_ibd_icd new_pre_ibd_ctv new_pre_ibd_ae)

*** combined serious AEs from hosp and A&E
egen pre_diverticulitis_serious = rmin(pre_diverticulitis_icd_prim)	 
egen pre_diarrhoea_serious = rmin(pre_diarrhoea_icd_prim pre_diarrhoeal_icd_prim)
egen pre_taste_serious = rmin(pre_taste_icd_prim)
egen pre_rash_serious = rmin(pre_rash_icd_prim)
egen pre_contactderm_serious = rmin(pre_contactderm_snomed pre_contactderm_icd_prim pre_contactderm_ae)
egen pre_dizziness_serious = rmin(pre_dizziness_icd_prim)
egen pre_nausea_vomit_serious = rmin(pre_nausea_vomit_icd_prim)
egen pre_headache_serious = rmin(pre_headache_icd_prim)
egen pre_anaphylaxis_serious = rmin(pre_anaphylaxis_icd_prim)
egen pre_drugreaction_serious = rmin(pre_severedrug_icd_prim pre_severedrug_sjs_icd_prim)
egen pre_ra_serious = rmin(new_pre_ra_icd)
egen pre_sle_serious = rmin(new_pre_sle_icd)
egen pre_psorasis_serious = rmin(new_pre_psoriasis_icd)
egen pre_psa_serious = rmin(new_pre_psa_icd)
egen pre_axspa_serious = rmin(new_pre_axspa_icd)
egen pre_ibd_serious = rmin(new_pre_ibd_icd)

*** combined AEs by spc, drug and imae				
egen pre_spc_all = rmin(pre_diverticulitis pre_diarrhoea pre_taste pre_rash pre_contactderm pre_bronchospasm pre_dizziness pre_nausea_vomit pre_headache pre_anaphylaxis pre_drugreaction)
egen pre_spc_serious = rmin(pre_diverticulitis_serious pre_diarrhoea_serious pre_taste_serious pre_rash_serious pre_contactderm_serious pre_dizziness_serious pre_nausea_vomit_serious pre_headache_serious)
egen pre_drug_all = rmin(pre_anaphylaxis pre_drugreaction)
egen pre_drug_serious = rmin(pre_anaphylaxis_serious pre_drugreaction_serious)
egen pre_imae_all = rmin(pre_ra pre_sle pre_psorasis pre_psa pre_ibd pre_axspa)
egen pre_imae_serious = rmin(pre_ra_serious pre_sle_serious pre_psorasis_serious pre_psa_serious pre_axspa_serious pre_ibd_serious)
egen pre_all = rmin(ae_spc_all ae_drug_all ae_imae_all )
egen pre_all_serious = rmin(ae_spc_serious ae_drug_serious ae_imae_serious)

global pre_ae_disease			pre_diverticulitis 				///
								pre_diarrhoea					///
								pre_taste 						///
								pre_rash 						///
								pre_bronchospasm				///
								pre_contactderm					///
								pre_dizziness					///
								pre_nausea_vomit				///
								pre_headache					///
								pre_anaphylaxis 				///
								pre_drugreaction				///
								pre_ra 							///
								pre_sle 						///
								pre_psorasis 					///
								pre_psa 						///
								pre_axspa	 					///
								pre_ibd 
global pre_ae_disease_serious	pre_diverticulitis_serious 		///
								pre_diarrhoea_serious			///
								pre_taste_serious				///
								pre_rash_serious 				///
								pre_contactderm_serious			///
								pre_dizziness_serious			///
								pre_nausea_vomit_serious		///
								pre_headache_serious			///
								pre_anaphylaxis_serious 		///
								pre_drugreaction_serious		///
								pre_ra_serious 					///
								pre_sle_serious 				///
								pre_psorasis_serious 			///
								pre_psa_serious 				///
								pre_axspa_serious	 			///
								pre_ibd_serious 							
global pre_ae_combined			pre_all							///
								pre_all_serious  				///
								pre_spc_all 					///
								pre_spc_serious					///
								pre_drug_all					///
								pre_drug_serious				///
								pre_imae_all					///	
								pre_imae_serious							

********************************************************
*	A. START DATE		*
********************************************************
gen start_comparator = start_date-1460
gen start_comparator_28 = start_date - 1431

********************************************************
*	A. COX MODEL		*
********************************************************
* Generate failure 
foreach x in $pre_ae_disease $pre_ae_disease_serious $pre_ae_combined{
		display "`x'"
		count if `x'!=. 
		count if (`x'<start_comparator | `x'>start_comparator_28) & `x'!=.  // event outside windown - should be 0 
		count if (`x'>start_comparator & `x'<start_comparator_28) & `x'!=.  // event 4-3 years prior to start
		gen fail_`x'=1 if `x'!=.
		tab drug fail_`x', m
}

* Add half-day buffer if outcome on indexdate
foreach x in $pre_ae_disease $pre_ae_disease_serious $pre_ae_combined{
		display "`x'"
		replace `x'=`x'+0.75 if `x'==start_comparator
}

*Generate censor date
foreach x in $pre_ae_disease $pre_ae_disease_serious $pre_ae_combined{
		gen stop_`x'=`x' if fail_`x'==1
		replace stop_`x'= start_comparator_28 if fail_`x'==.
		tab drug fail_`x' if stop_`x'!=.
		format %td stop_`x'
}

* Follow-up time
foreach x in $pre_ae_combined{
		stset stop_`x', id(patient_id) origin(time start_comparator) enter(time start_comparator) exit(time start_comparator_28) failure(fail_`x'==1) 
		tab _st  
		tab _t drug if fail_`x'==1 & stop_`x'==`x'
		count if start_comparator>=stop_`x' & _st==0
		count if start_comparator==stop_`x' & _st==0
}

********************************************************
*	RATES OF EVENTS		*
********************************************************
tempname comparator_rates
postfile `comparator_rates' str20(failure) ///
		all_ptime all_events all_rate all_lci all_uci ///
		control_ptime control_events control_rate control_lci_ control_uci ///
		sot_ptime sot_events sot_rate sot_lci sot_uci ///
		pax_ptime pax_events pax_rate pax_lci pax_uci ///
		mol_ptime mol_events mol_rate mol_lci mol_uci ///
		using "$projectdir/output/tables/comparator_rates", replace	
	
foreach fail in $pre_ae_disease $pre_ae_disease_serious $pre_ae_combined{
	stset stop_`fail', id(patient_id) origin(time start_comparator) enter(time start_comparator) exit(time start_comparator_28) failure(fail_`fail'==1) 			
		stptime 
					local all_rate = `r(rate)'
					local all_ptime = `r(ptime)'
					local all_lci = `r(lb)'
					local all_uci = `r(ub)'
					local all_events = `r(failures)'					
		stptime if drug == 0
					local control_rate = `r(rate)'
					local control_ptime = `r(ptime)'
					local control_lci = `r(lb)'
					local control_uci = `r(ub)'
					local control_events = `r(failures)'
		display "no drug"
		stptime if drug == 1
					local sot_rate = `r(rate)'
					local sot_ptime = `r(ptime)'
					local sot_lci = `r(lb)'
					local sot_uci = `r(ub)'
					local sot_events = `r(failures)'
		display "sotrovimab"
		stptime if drug == 2
					local pax_rate = `r(rate)'
					local pax_ptime = `r(ptime)'
					local pax_lci = `r(lb)'
					local pax_uci = `r(ub)'
					local pax_events = `r(failures)'		
		display "paxlovid"
		stptime if drug == 3
					local mol_rate = `r(rate)'
					local mol_ptime = `r(ptime)'
					local mol_lci = `r(lb)'
					local mol_uci = `r(ub)'
					local mol_events = `r(failures)'		
		display "molnupavir"			
		post `comparator_rates' ("`fail'")	(`all_ptime') (`all_events') (`all_rate') (`all_lci') (`all_uci') ///
					(`control_ptime') (`control_events') (`control_rate') (`control_lci') (`control_uci') ///
					(`sot_ptime') (`sot_events') (`sot_rate') (`sot_lci') (`sot_uci') ///
					(`pax_ptime') (`pax_events') (`pax_rate') (`pax_lci') (`pax_uci') ///
					(`mol_ptime') (`mol_events') (`mol_rate') (`mol_lci') (`mol_uci') 	
					
}
postclose `comparator_rates'
use "$projectdir/output/tables/comparator_rates", clear
order failure all* control* sot* pax* mol* 
save "$projectdir/output/tables/comparator_rates", replace
export delimited using "$projectdir/output/tables/comparator_rates.csv", replace

** Redact and round rates
use "$projectdir/output/tables/comparator_rates", clear
foreach var of varlist *events *ptime  {
gen `var'_midpoint = (ceil(`var'/6)*6) - (floor(6/2) * (`var'!=0))
}
foreach var in all control sot pax mol {
gen `var'_rate_midpoint = (`var'_events_midpoint/`var'_ptime_midpoint)*1000
gen `var'_lci_midpoint = (invpoisson(`var'_events_midpoint,.975)/`var'_ptime_midpoint)*1000
gen `var'_uci_midpoint = (invpoisson(`var'_events_midpoint,.025)/`var'_ptime_midpoint)*1000
}  
keep failure *_midpoint
order  	failure all* control* sot* pax* mol* 
save "$projectdir/output/tables/comparator_rates_round", replace
export delimited using "$projectdir/output/tables/comparator_rates_round.csv", replace


log close






