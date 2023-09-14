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
global adj 		age i.sex i.region_nhs i.imdq5 i.ethnicity 1b.bmi_group ///
				paxlovid_contraindicated i.vaccination_status diabetes chronic_cardiac_disease chronic_respiratory_disease hypertension ///
			    downs_syndrome solid_cancer haem_disease renal_disease liver_disease imid_on_drug immunosupression hiv_aids organ_transplant rare_neuro  
global adj2 	age i.sex i.region_nhs i.imdq5 i.ethnicity 1b.bmi_group 
global adj3 	age i.sex i.region_nhs i.imdq5 i.ethnicity 1b.bmi_group ///
				paxlovid_contraindicated i.vaccination_status diabetes chronic_cardiac_disease chronic_respiratory_disease hypertension 	

* Balance
global bal_agesex 	age sex
global bal_adj 		age sex region_nhs imdq5 ethnicity  bmi_group ///
					paxlovid_contraindicated vaccination_status diabetes chronic_cardiac_disease chronic_respiratory_disease hypertension ///
					downs_syndrome solid_cancer haem_disease renal_disease liver_disease imid_on_drug immunosupression hiv_aids organ_transplant rare_neuro  
global bal_adj2 	age sex region_nhs imdq5 ethnicity bmi_group 
global bal_adj3 	age sex region_nhs imdq5 ethnicity bmi_group ///
					paxlovid_contraindicated vaccination_status diabetes chronic_cardiac_disease chronic_respiratory_disease hypertension 	
					
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
	
// SOTROVIMAB //
tempname coxoutput_propensity_sot
postfile `coxoutput_propensity_sot' str20(model) str20(fail)  ///
									hr_sot lc_sot uc_sot ///
									using "$projectdir/output/tables/cox_propensity_sot", replace	
preserve
keep if drug==0 | drug==1

foreach model in agesex adj adj2 adj3 {
	logistic drug $`model'	 	
	predict p_drug_`model'	
	
	twoway 	(histogram p_drug_`model' if drug==1, color(green)) (histogram p_drug_`model' if drug==0, fcolor(none) lcolor(black)), ///
			legend(order(1 "No Drug" 2 "Sotrovimab")) name(histogram_sot_prop_`model', replace) saving("$projectdir/output/figures/histogram_sot_`model'", replace)
	graph export "$projectdir/output/figures/histogram_sot_`model'.svg", as(svg) replace
			
	gen iptw_`model' = 1/p_drug_`model' if drug==1
	replace iptw_`model'  = 1/(1-p_drug_`model') if drug==0
	
	foreach fail in $ae_group $ae_disease {
			stset stop_`fail' [pw=iptw_`model'], id(patient_id) origin(time start_date) enter(time start_date) failure(fail_`fail'==1) 
			stcox i.drug, vce(robust)
							matrix b = r(table)
							local hr_sot = b[1,2]
							local lc_sot = b[5,2]
							local uc_sot = b[6,2]
			post `coxoutput_propensity_sot' ("`fail'") ("`model'") (`hr_sot') (`lc_sot') (`uc_sot') 
}		
}

	pbalchk drug $bal_agesex  
	pbalchk drug $bal_agesex, wt(iptw_agesex) graph 
	graph save "$projectdir/output/figures/sot_match_agesex", replace
	graph export "$projectdir/output/figures/sot_match_agesex.svg", as(svg) replace
	
	pbalchk drug $bal_adj  
	pbalchk drug $bal_adj, wt(iptw_adj) graph 
	graph save "$projectdir/output/figures/sot_match_adj", replace
	graph export "$projectdir/output/figures/sot_match_adj.svg", as(svg) replace
	
	pbalchk drug $bal_adj2   
	pbalchk drug $bal_adj2, wt(iptw_adj2) graph 
	graph save "$projectdir/output/figures/sot_match_adj2", replace
	graph export "$projectdir/output/figures/sot_match_adj2.svg", as(svg) replace
	
	pbalchk drug $bal_adj3 
	pbalchk drug $bal_adj3, wt(iptw_adj3) graph 
	graph save "$projectdir/output/figures/sot_match_adj3", replace
	graph export "$projectdir/output/figures/sot_match_adj3.svg", as(svg) replace

restore
postclose `coxoutput_propensity_sot'


// PAXLOVID //
tempname coxoutput_propensity_pax
postfile `coxoutput_propensity_pax' str20(model) str20(fail)  ///
									hr_pax lc_pax uc_pax ///
									using "$projectdir/output/tables/cox_propensity_pax", replace
preserve
keep if drug==0 | drug==2
replace drug=1 if drug==2
lab define drug 0 "Control" 1 "Paxlovid", replace
label values drug drug	
						
foreach model in agesex adj adj2 adj3 {
	logistic drug $`model'	 	
	predict p_drug_`model'	
	twoway 	(histogram p_drug_`model' if drug==1, color(green)) (histogram p_drug_`model' if drug==0, fcolor(none) lcolor(black)), ///
			legend(order(1 "No Drug" 2 "Paxlovid")) name(histogram_pax_`model', replace) saving("$projectdir/output/figures/histogram_pax_`model'", replace)
	graph export "$projectdir/output/figures/histogram_pax_`model'.svg", as(svg) replace
			
	gen iptw_`model' = 1/p_drug_`model' if drug==1
	replace iptw_`model'  = 1/(1-p_drug_`model') if drug==0

	foreach fail in $ae_group $ae_disease  {
			stset stop_`fail' [pw=iptw_`model'], id(patient_id) origin(time start_date) enter(time start_date) failure(fail_`fail'==1) 
			stcox i.drug, vce(robust)
							matrix b = r(table)
							local hr_pax = b[1,2]
							local lc_pax = b[5,2]
							local uc_pax = b[6,2]
			post `coxoutput_propensity_pax' ("`fail'") ("`model'") (`hr_pax') (`lc_pax') (`uc_pax') 
}			
}
	pbalchk drug $bal_agesex  
	pbalchk drug $bal_agesex, wt(iptw_agesex) graph 
	graph save "$projectdir/output/figures/pax_match_agesex", replace
	graph export "$projectdir/output/figures/pax_match_agesex.svg", as(svg) replace
	
	pbalchk drug $bal_adj  
	pbalchk drug $bal_adj, wt(iptw_adj) graph 
	graph save "$projectdir/output/figures/pax_match_adj", replace
	graph export "$projectdir/output/figures/pax_match_adj.svg", as(svg) replace
	
	pbalchk drug $bal_adj2   
	pbalchk drug $bal_adj2, wt(iptw_adj2) graph 
	graph save "$projectdir/output/figures/pax_match_adj2", replace
	graph export "$projectdir/output/figures/pax_match_adj2.svg", as(svg) replace
	
	pbalchk drug $bal_adj3 
	pbalchk drug $bal_adj3, wt(iptw_adj3) graph 
	graph save "$projectdir/output/figures/pax_match_adj3", replace
	graph export "$projectdir/output/figures/pax_match_adj3.svg", as(svg) replace
restore
postclose `coxoutput_propensity_pax'


// MOLNUPAVIR //
tempname coxoutput_propensity_mol
postfile `coxoutput_propensity_mol' str20(model) str20(fail)  ///
									hr_mol lc_mol uc_mol ///
									using "$projectdir/output/tables/cox_propensity_mol", replace	
preserve
keep if drug==0 | drug==3
replace drug=1 if drug==3
lab define drug 0 "Control" 1 "Molnupavir", replace
label values drug drug									
foreach model in agesex adj adj2 adj3{

	logistic drug $`model'	 	
	predict p_drug_`model'	
	
	twoway 	(histogram p_drug_`model' if drug==1, color(green)) (histogram p_drug_`model' if drug==0, fcolor(none) lcolor(black)), ///
			legend(order(1 "No Drug" 2 "Molnupavir")) name(histogram_mol_`model', replace) saving("$projectdir/output/figures/histogram_mol_`model'", replace)
	graph export "$projectdir/output/figures/histogram_mol_`model'.svg", as(svg) replace
			
	gen iptw_`model' = 1/p_drug_`model' if drug==1
	replace iptw_`model'  = 1/(1-p_drug_`model') if drug==0

	foreach fail in $ae_group $ae_disease  {
			stset stop_`fail' [pw=iptw_`model'], id(patient_id) origin(time start_date) enter(time start_date) failure(fail_`fail'==1) 
			stcox i.drug, vce(robust)
							matrix b = r(table)
							local hr_mol = b[1,2]
							local lc_mol = b[5,2]
							local uc_mol = b[6,2]
			post `coxoutput_propensity_mol' ("`fail'") ("`model'") (`hr_mol') (`lc_mol') (`uc_mol') 
}		
}
	pbalchk drug $bal_agesex 
	pbalchk drug $bal_agesex, wt(iptw_agesex) graph 
	graph save "$projectdir/output/figures/mol_match_agesex", replace
	graph export "$projectdir/output/figures/mol_match_agesex.svg", as(svg) replace
	
	pbalchk drug $bal_adj  
	pbalchk drug $bal_adj, wt(iptw_adj) graph 
	graph save "$projectdir/output/figures/mol_match_adj", replace
	graph export "$projectdir/output/figures/mol_match_adj.svg", as(svg) replace
	
	pbalchk drug $bal_adj2   
	pbalchk drug $bal_adj2, wt(iptw_adj2) graph 
	graph save "$projectdir/output/figures/mol_match_adj2", replace
	graph export "$projectdir/output/figures/mol_match_adj2.svg", as(svg) replace
	
	pbalchk drug $bal_adj3 
	pbalchk drug $bal_adj3, wt(iptw_adj3) graph 
	graph save "$projectdir/output/figures/mol_match_adj3", replace
	graph export "$projectdir/output/figures/mol_match_adj3.svg", as(svg) replace

restore
postclose `coxoutput_propensity_mol'





** Common Support					
****************************************************************************************************************
*1. Individual drug V No Drug
	
// SOTROVIMAB
tempname coxoutput_propensity_sot_common
postfile `coxoutput_propensity_sot_common' str20(model) str20(fail)  ///
									hr_sot lc_sot uc_sot ///
									using "$projectdir/output/tables/cox_propensity_sot_common", replace	
preserve
keep if drug==0 | drug==1
foreach model in agesex adj adj2 adj3{	
	logistic drug $`model'	 	
	predict p_drug_`model'
	
	summarize p_drug_`model' if drug == 0, detail
	gen min_p_control_`model' = r(min)
	gen max_p_control_`model' = r(max)
	summarize p_drug_`model' if drug ==1, detail
	gen min_p_drug_`model' = r(min)
	gen max_p_drug_`model' = r(max)
	gen common_min_`model' = max(min_p_control_`model' , min_p_drug_`model')
	gen common_max_`model' = min(max_p_control_`model', max_p_drug_`model')
	gen common_support_`model' = (p_drug_`model' >= common_min_`model' & p_drug_`model' <=common_max_`model')
	keep if common_support_`model'==1
	
	twoway 	(histogram p_drug_`model' if drug==1, color(green)) (histogram p_drug_`model' if drug==0, fcolor(none) lcolor(black)), ///
			legend(order(1 "No Drug" 2 "Sotrovimab")) name(histogram_sot_`model'_common, replace) ///
			saving("$projectdir/output/figures/histogram_sot_common_`model'", replace)
	graph export "$projectdir/output/figures/histogram_sot_common_`model'.svg", as(svg) replace
			
	gen iptw_`model' = 1/p_drug_`model' if drug==1
	replace iptw_`model'  = 1/(1-p_drug_`model') if drug==0
	
	foreach fail in $ae_group $ae_disease  {
			stset stop_`fail' [pw=iptw_`model'], id(patient_id) origin(time start_date) enter(time start_date) failure(fail_`fail'==1) 
			stcox i.drug, vce(robust)
							matrix b = r(table)
							local hr_sot = b[1,2]
							local lc_sot = b[5,2]
							local uc_sot = b[6,2]
			post `coxoutput_propensity_sot_common' ("`fail'") ("`model'") (`hr_sot') (`lc_sot') (`uc_sot') 
}		
}
	pbalchk drug $bal_agesex  
	pbalchk drug $bal_agesex, wt(iptw_agesex) graph 
	graph save "$projectdir/output/figures/sot_match_common_agesex", replace
	graph export "$projectdir/output/figures/sot_match_common_agesex.svg", as(svg) replace
	
	pbalchk drug $bal_adj  
	pbalchk drug $bal_adj, wt(iptw_adj) graph 
	graph save "$projectdir/output/figures/sot_match_common_adj", replace
	graph export "$projectdir/output/figures/sot_match_common_adj.svg", as(svg) replace
	
	pbalchk drug $bal_adj2   
	pbalchk drug $bal_adj2, wt(iptw_adj2) graph 
	graph save "$projectdir/output/figures/sot_match_common_adj2", replace
	graph export "$projectdir/output/figures/sot_match_common_adj2.svg", as(svg) replace
	
	pbalchk drug $bal_adj3 
	pbalchk drug $bal_adj3, wt(iptw_adj3) graph 
	graph save "$projectdir/output/figures/sot_match_common_adj3", replace
	graph export "$projectdir/output/figures/sot_match_common_adj3.svg", as(svg) replace

restore
postclose `coxoutput_propensity_sot_common'

// PAXLOVID
tempname coxoutput_propensity_pax_common
postfile `coxoutput_propensity_pax_common' str20(model) str20(fail)  ///
									hr_pax lc_pax uc_pax ///
									using "$projectdir/output/tables/cox_propensity_pax_common", replace
preserve
keep if drug==0 | drug==2
replace drug=1 if drug==2
lab define drug 0 "Control" 1 "Paxlovid", replace
label values drug drug		
							
foreach model in agesex adj adj2 adj3 {
	logistic drug $`model'	 	
	predict p_drug_`model'	
	
	summarize p_drug_`model' if drug == 0, detail
	gen min_p_control_`model' = r(min)
	gen max_p_control_`model' = r(max)
	summarize p_drug_`model' if drug ==1, detail
	gen min_p_drug_`model' = r(min)
	gen max_p_drug_`model' = r(max)
	gen common_min_`model' = max(min_p_control_`model' , min_p_drug_`model')
	gen common_max_`model' = min(max_p_control_`model', max_p_drug_`model')
	gen common_support_`model' = (p_drug_`model' >= common_min_`model' & p_drug_`model' <=common_max_`model')
	keep if common_support_`model'==1
		
	twoway 	(histogram p_drug_`model' if drug==1, color(green)) (histogram p_drug_`model' if drug==0, fcolor(none) lcolor(black)), ///
			legend(order(1 "No Drug" 2 "Paxlovid")) name(histogram_pax_`model'_common, replace) saving("$projectdir/output/figures/histogram_pax_common_`model'", replace)
	graph export "$projectdir/output/figures/histogram_pax_common_`model'.svg", as(svg) replace
			
	gen iptw_`model' = 1/p_drug_`model' if drug==1
	replace iptw_`model'  = 1/(1-p_drug_`model') if drug==0
	
	foreach fail in $ae_group $ae_disease  {
			stset stop_`fail' [pw=iptw_`model'], id(patient_id) origin(time start_date) enter(time start_date) failure(fail_`fail'==1) 
			stcox i.drug, vce(robust)
							matrix b = r(table)
							local hr_pax = b[1,2]
							local lc_pax = b[5,2]
							local uc_pax = b[6,2]
			post `coxoutput_propensity_pax_common' ("`fail'") ("`model'") (`hr_pax') (`lc_pax') (`uc_pax') 
}		
}
	pbalchk drug $bal_agesex  
	pbalchk drug $bal_agesex, wt(iptw_agesex) graph 
	graph save "$projectdir/output/figures/pax_match_common_agesex", replace
	graph export "$projectdir/output/figures/pax_match_common_agesex.svg", as(svg) replace
	
	pbalchk drug $bal_adj  
	pbalchk drug $bal_adj, wt(iptw_adj) graph 
	graph save "$projectdir/output/figures/pax_match_common_adj", replace
	graph export "$projectdir/output/figures/pax_match_common_adj.svg", as(svg) replace
	
	pbalchk drug $bal_adj2   
	pbalchk drug $bal_adj2, wt(iptw_adj2) graph 
	graph save "$projectdir/output/figures/pax_match_common_adj2", replace
	graph export "$projectdir/output/figures/pax_match_common_adj2.svg", as(svg) replace
	
	pbalchk drug $bal_adj3 
	pbalchk drug $bal_adj3, wt(iptw_adj3) graph 
	graph save "$projectdir/output/figures/pax_match_common_adj3", replace
	graph export "$projectdir/output/figures/pax_match_common_adj3.svg", as(svg) replace

restore
postclose `coxoutput_propensity_pax_common'


// MOLNUPAVIR
tempname coxoutput_propensity_mol_common
postfile `coxoutput_propensity_mol_common' str20(model) str20(fail)  ///
									hr_mol lc_mol uc_mol ///
									using "$projectdir/output/tables/cox_propensity_mol_common", replace	
preserve
keep if drug==0 | drug==3
replace drug=1 if drug==3
lab define drug 0 "Control" 1 "Molnupavir", replace
label values drug drug	
								
foreach model in agesex adj adj2 adj3{
	logistic drug $`model'	 	
	predict p_drug_`model'	
	
	summarize p_drug_`model' if drug == 0, detail
	gen min_p_control_`model' = r(min)
	gen max_p_control_`model' = r(max)
	summarize p_drug_`model' if drug ==1, detail
	gen min_p_drug_`model' = r(min)
	gen max_p_drug_`model' = r(max)
	gen common_min_`model' = max(min_p_control_`model' , min_p_drug_`model')
	gen common_max_`model' = min(max_p_control_`model', max_p_drug_`model')
	gen common_support_`model' = (p_drug_`model' >= common_min_`model' & p_drug_`model' <=common_max_`model')
	keep if common_support_`model'==1
	
	twoway 	(histogram p_drug_`model' if drug==1, color(green)) (histogram p_drug_`model' if drug==0, fcolor(none) lcolor(black)), ///
			legend(order(1 "No Drug" 2 "Molnupavir")) name(histogram_mol_`model'_common, replace) saving("$projectdir/output/figures/histogram_mol_common_`model'", replace)
	graph export "$projectdir/output/figures/histogram_mol_common_`model'.svg", as(svg) replace
			
	gen iptw_`model' = 1/p_drug_`model' if drug==1
	replace iptw_`model'  = 1/(1-p_drug_`model') if drug==0

	foreach fail in $ae_group $ae_disease  {
			stset stop_`fail' [pw=iptw_`model'], id(patient_id) origin(time start_date) enter(time start_date) failure(fail_`fail'==1) 
			stcox i.drug, vce(robust)
							matrix b = r(table)
							local hr_mol = b[1,2]
							local lc_mol = b[5,2]
							local uc_mol = b[6,2]
			post `coxoutput_propensity_mol_common' ("`fail'") ("`model'") (`hr_mol') (`lc_mol') (`uc_mol') 
	
}		
}
	pbalchk drug $bal_agesex 
	pbalchk drug $bal_agesex, wt(iptw_agesex) graph 
	graph save "$projectdir/output/figures/mol_match_common_agesex", replace
	graph export "$projectdir/output/figures/mol_match_common_agesex.svg", as(svg) replace
	
	pbalchk drug $bal_adj  
	pbalchk drug $bal_adj, wt(iptw_adj) graph 
	graph save "$projectdir/output/figures/mol_match_common_adj", replace
	graph export "$projectdir/output/figures/mol_match_common_adj.svg", as(svg) replace
	
	pbalchk drug $bal_adj2   
	pbalchk drug $bal_adj2, wt(iptw_adj2) graph 
	graph save "$projectdir/output/figures/mol_match_common_adj2", replace
	graph export "$projectdir/output/figures/mol_match_common_adj2.svg", as(svg) replace
	
	pbalchk drug $bal_adj3 
	pbalchk drug $bal_adj3, wt(iptw_adj3) graph 
	graph save "$projectdir/output/figures/mol_match_common_adj3", replace
	graph export "$projectdir/output/figures/mol_match_common_adj3.svg", as(svg) replace
restore
postclose `coxoutput_propensity_mol_common'

*******************************************************************************
use "$projectdir/output/tables/cox_propensity_sot", clear
merge 1:1 model fail using "$projectdir/output/tables/cox_propensity_pax", nogenerate 
merge 1:1 model fail using "$projectdir/output/tables/cox_propensity_mol", nogenerate
foreach var of varlist hr* lc* uc* {
	format `var' %3.2f			
}	
save "$projectdir/output/tables/cox_propensity", replace
export delimited using "$projectdir/output/tables/cox_propensity.csv", replace

use "$projectdir/output/tables/cox_propensity_sot_common", clear
merge 1:1 model fail using "$projectdir/output/tables/cox_propensity_pax_common", nogenerate 
merge 1:1 model fail using "$projectdir/output/tables/cox_propensity_mol_common", nogenerate
foreach var of varlist hr* lc* uc* {
	format `var' %3.2f			
}	
save "$projectdir/output/tables/cox_propensity_common", replace
export delimited using "$projectdir/output/tables/cox_propensity_common.csv", replace


log close


	