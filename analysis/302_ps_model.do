********************************************************************************
*
*	Do-file:			propensity score cox model
*	Project:			Sotrovimab-Paxlovid-Molnupiravir
*   Date:  				24/4/23
*	Programmed by:		Katie Bechman
* 	Description:		create and run ps model
*	Data used:			main.dta
*	Data created:		psoutput
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
log using "$logdir/ps_model.log", replace

*Set Ado file path
adopath + "$projectdir/analysis/ado"

* SET Index date 
global indexdate 			= "01/03/2020"

use "$projectdir/output/data/main", clear


* Models
global agesex 	age i.sex
global adj 		age i.sex i.region_nhs i.imdq5 White 1b.bmi_group ///
				paxlovid_contraindicated i.vaccination_status diabetes chronic_cardiac_disease chronic_respiratory_disease hypertension ///
			    downs_syndrome solid_cancer haem_disease renal_disease liver_disease imid_on_drug immunosupression hiv_aids organ_transplant rare_neuro  
global adj2 	age i.sex i.region_nhs i.imdq5 White 1b.bmi_group 
global adj3 	age i.sex i.region_nhs i.imdq5 White 1b.bmi_group ///
				paxlovid_contraindicated i.vaccination_status diabetes chronic_cardiac_disease chronic_respiratory_disease hypertension 				
* Outcome
global ae_group			ae_spc_all 					///
						ae_drug_all					///		
						ae_imae_all 				///				
						ae_all						///
						allcause_emerg_aande 		///
						covid_hosp_date				///
						all_hosp_date				///
						died_date_ons
						
global ae_disease		ae_diverticulitis 				///
						ae_diarrhoea					///
						ae_taste 						///
						ae_rash 						///
						ae_bronchospasm					///
						ae_contactderm					///
						ae_dizziness					///
						ae_nausea_vomit					///
						ae_headache						///
						ae_anaphylaxis 					///
						ae_severe_drug 					///
						ae_nonsevere_drug				///
						ae_ra 							///
						ae_sle 							///
						ae_psorasis 					///
						ae_psa 							///
						ae_axspa 						///
						ae_ibd 									

** Hazard of events										
****************************************************************************************************************
*1. Individual drug V No Drug
	
// SOTROVIMAB
tempname coxoutput_propensity_sot
postfile `coxoutput_propensity_sot' str20(model) str20(fail)  ///
									hr_sot lc_sot uc_sot ///
									using "$projectdir/output/tables/cox_propensity_sot", replace	

foreach model in agesex adj{
	preserve
	keep if drug==0 | drug==1
	logistic drug $`model'	 	
	predict p_drug_`model'	
	
	twoway 	(histogram p_drug_`model' if drug==1, color(green)) (histogram p_drug_`model' if drug==0, fcolor(none) lcolor(black)), ///
			legend(order(1 "No Drug" 2 "Sotrovimab")) name(histogram_sot_prop_`model', replace)
			
	gen iptw_`model' = 1/p_drug_`model' if drug==1
	replace iptw_`model'  = 1/(1-p_drug_`model') if drug==0
	
	pbalchk drug age sex region_nhs paxlovid_contraindicated downs_syndrome solid_cancer haem_disease renal_disease ///
	liver_disease imid_on_drug immunosupression hiv_aids organ_transplant rare_neuro vaccination_status imdq5 bmi_group ///
	diabetes chronic_cardiac_disease chronic_respiratory_disease hypertension	
	pbalchk drug age sex region_nhs paxlovid_contraindicated downs_syndrome solid_cancer haem_disease renal_disease ///
	liver_disease imid_on_drug immunosupression hiv_aids organ_transplant rare_neuro vaccination_status imdq5 bmi_group ///
	diabetes chronic_cardiac_disease chronic_respiratory_disease hypertension, wt(iptw`$model') graph 
	graph save "$projectdir/output/figures/sot_match_adj", replace
	
	foreach fail in $ae_group $ae_disease {
			stset stop_`fail' [pw=iptw_`model'], id(patient_id) origin(time start_date) enter(time start_date) failure(fail_`fail'==1) 
			stcox i.drug, vce(robust)
							matrix b = r(table)
							local hr_sot = b[1,2]
							local lc_sot = b[5,2]
							local uc_sot = b[6,2]
			post `coxoutput_propensity_sot' ("`fail'") ("`model'") (`hr_sot') (`lc_sot') (`uc_sot') 
}
restore		
}

postclose `coxoutput_propensity_sot'

// PAXLOVID
tempname coxoutput_propensity_pax
postfile `coxoutput_propensity_pax' str20(model) str20(fail)  ///
									hr_pax lc_pax uc_pax ///
									using "$projectdir/output/tables/cox_propensity_pax", replace									
foreach model in agesex adj {
	preserve
	keep if drug==0 | drug==2
	replace drug=1 if drug==2
	lab define drug 0 "Control" 1 "Paxlovid", replace
	label values drug drug
	logistic drug $`model'	 	
	predict p_drug_`model'	
	
	twoway 	(histogram p_drug_`model' if drug==1, color(green)) (histogram p_drug_`model' if drug==0, fcolor(none) lcolor(black)), ///
			legend(order(1 "No Drug" 2 "Paxlovid")) name(histogram_pax_`model', replace)
			
	gen iptw_`model' = 1/p_drug_`model' if drug==1
	replace iptw_`model'  = 1/(1-p_drug_`model') if drug==0

	pbalchk drug age sex region_nhs paxlovid_contraindicated downs_syndrome solid_cancer haem_disease renal_disease ///
	liver_disease imid_on_drug immunosupression hiv_aids organ_transplant rare_neuro vaccination_status imdq5 bmi_group ///
	diabetes chronic_cardiac_disease chronic_respiratory_disease hypertension	
	pbalchk drug age sex region_nhs paxlovid_contraindicated downs_syndrome solid_cancer haem_disease renal_disease ///
	liver_disease imid_on_drug immunosupression hiv_aids organ_transplant rare_neuro vaccination_status imdq5 bmi_group ///
	diabetes chronic_cardiac_disease chronic_respiratory_disease hypertension, wt(iptw`$model') graph 
	graph save "$projectdir/output/figures/pax_match_adj", replace
	
	foreach fail in $ae_group $ae_disease {
			stset stop_`fail' [pw=iptw_`model'], id(patient_id) origin(time start_date) enter(time start_date) failure(fail_`fail'==1) 
			stcox i.drug, vce(robust)
							matrix b = r(table)
							local hr_pax = b[1,2]
							local lc_pax = b[5,2]
							local uc_pax = b[6,2]
			post `coxoutput_propensity_pax' ("`fail'") ("`model'") (`hr_pax') (`lc_pax') (`uc_pax') 
}		
	restore
}
postclose `coxoutput_propensity_pax'


// MOLNUPAVIR
tempname coxoutput_propensity_mol
postfile `coxoutput_propensity_mol' str20(model) str20(fail)  ///
									hr_mol lc_mol uc_mol ///
									using "$projectdir/output/tables/cox_propensity_mol", replace									
foreach model in agesex adj {
	preserve
	keep if drug==0 | drug==3
	replace drug=1 if drug==3
	lab define drug 0 "Control" 1 "Molnupavir", replace
	label values drug drug
	logistic drug $`model'	 	
	predict p_drug_`model'	
	
	twoway 	(histogram p_drug_`model' if drug==1, color(green)) (histogram p_drug_`model' if drug==0, fcolor(none) lcolor(black)), ///
			legend(order(1 "No Drug" 2 "Molnupavir")) name(histogram_mol_`model', replace)
			
	gen iptw_`model' = 1/p_drug_`model' if drug==1
	replace iptw_`model'  = 1/(1-p_drug_`model') if drug==0

	pbalchk drug age sex region_nhs paxlovid_contraindicated downs_syndrome solid_cancer haem_disease renal_disease ///
	liver_disease imid_on_drug immunosupression hiv_aids organ_transplant rare_neuro vaccination_status imdq5 bmi_group ///
	diabetes chronic_cardiac_disease chronic_respiratory_disease hypertension	
	pbalchk drug age sex region_nhs paxlovid_contraindicated downs_syndrome solid_cancer haem_disease renal_disease ///
	liver_disease imid_on_drug immunosupression hiv_aids organ_transplant rare_neuro vaccination_status imdq5 bmi_group ///
	diabetes chronic_cardiac_disease chronic_respiratory_disease hypertension, wt(iptw`$model') graph 
	graph save "$projectdir/output/figures/mol_match_adj", replace
	
	foreach fail in $ae_group $ae_disease {
			stset stop_`fail' [pw=iptw_`model'], id(patient_id) origin(time start_date) enter(time start_date) failure(fail_`fail'==1) 
			stcox i.drug, vce(robust)
							matrix b = r(table)
							local hr_mol = b[1,2]
							local lc_mol = b[5,2]
							local uc_mol = b[6,2]
			post `coxoutput_propensity_mol' ("`fail'") ("`model'") (`hr_mol') (`lc_mol') (`uc_mol') 
}		
	restore
}
postclose `coxoutput_propensity_mol'


*******************************************************************************
use "$projectdir/output/tables/cox_propensity_sot", clear
merge 1:1 model fail using "$projectdir/output/tables/cox_propensity_pax", nogenerate 
merge 1:1 model fail using "$projectdir/output/tables/cox_propensity_mol", nogenerate
foreach var of varlist hr* lc* uc* {
	format `var' %3.2f			
}	
save "$projectdir/output/tables/cox_propensity", replace
export delimited using "$projectdir/output/tables/cox_propensity.csv", replace

log close


	