********************************************************************************
*
*	Do-file:			cox model
*	Project:			Sotrovimab-Paxlovid-Molnupiravir
*   Date:  				06/4/23
*	Programmed by:		Katie Bechman
* 	Description:		run cox models
*	Data used:			main.dta
*	Data created:		coxoutput
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
log using "$logdir/cox_model.log", replace

*Set Ado file path
adopath + "$projectdir/analysis/ado"

* SET Index date 
global indexdate 			= "01/03/2020"

use "$projectdir/output/data/main", clear

/* ===========================================================*/

* Models
global crude 	i.drug 
global agesex 	i.drug age i.sex
global adj 		i.drug age i.sex i.region_nhs i.imdq5 White 1b.bmi_group ///
				paxlovid_contraindicated i.vaccination_status diabetes chronic_cardiac_disease chronic_respiratory_disease hypertension ///
			    downs_syndrome solid_cancer haem_disease renal_disease liver_disease imid_on_drug immunosupression hiv_aids organ_transplant rare_neuro  
global adj2 	i.drug age i.sex i.region_nhs i.imdq5 White 1b.bmi_group 
global adj3 	i.drug age i.sex i.region_nhs i.imdq5 White 1b.bmi_group ///
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

*** Graphs - Survival Risk & Survival Curve
foreach fail in $ae_group $ae_disease {

	stset stop_`fail', id(patient_id) origin(time start_date) enter(time start_date) failure(fail_`fail'==1) 
			tab _st					
			stcox i.drug 
			sts graph, by(drug) tmax(28) ylabel(0(0.25)1) ylabel(,format(%4.3f)) xlabel(0(7)28) ///
			risktable(,title(" ")order(1 "Control     " 2 "Sotrovimab     " 3 "Paxlovid     " 4 "Molnupiravir     ") ///
			size(small)justification(left) rowtitle(,size(small)justification(right))) ///
			legend(order(1 "Control" 2 "Sotrovimab" 3 "Paxlovid" 4 "Molnupiravir") symxsize(*0.4) size(small)) ///
			xtitle("Analysis time (years)")  ylabel(0.9(.025)1) ylabel(,angle(horizontal)) plotregion(color(white)) graphregion(color(white)) ///
			ytitle("Survival Probability" ) xtitle("Time (Days)") saving("$projectdir/output/figures/survrisk_`fail'", replace)

			graph export "$projectdir/output/figures/survrisk_`fail'.svg", as(svg) replace

			
			stcurve, survival at1(drug=0) at2(drug=1) at3(drug=2) at4(drug=3) title("") ///
			range(0 28) xtitle("Analysis time (years)") ///
			legend(order(1 "Control" 2 "Sotrovimab" 3 "Paxlovid" 4 "Molnupiravir") symxsize(*0.4) size(small)) ///
			ylabel(,angle(horizontal)) plotregion(color(white)) graphregion(color(white)) ///
			ytitle("Survival Probability" ) xtitle("Time (Days)") saving("$projectdir/output/figures/survcurve_`fail'", replace)
	
			graph export "$projectdir/output/figures/survcur_`fail'.svg", as(svg) replace
}		

						
** Hazard of events						
tempname cox_model_summary
postfile `cox_model_summary' str20(model) str20(failure) ///
	hr_sot lc_sot uc_sot hr_pax lc_pax uc_pax hr_mol lc_mol uc_mol ///
	using "$projectdir/output/tables/cox_model_summary", replace							 
foreach fail in $ae_group {
	stset stop_`fail', id(patient_id) origin(time start_date) enter(time start_date) failure(fail_`fail'==1) 
	foreach model in crude agesex adj adj2 adj3 {
		stcox $`model', vce(robust)
					matrix b = r(table)
					local hr_sot = b[1,2]
					local lc_sot = b[5,2]
					local uc_sot = b[6,2]
					local hr_pax = b[1,3]
					local lc_pax = b[5,3]
					local uc_pax = b[6,3]
					local hr_mol = b[1,4]
					local lc_mol = b[5,4]
					local uc_mol = b[6,4]			
		post `cox_model_summary' ("`model'") ("`fail'") (`hr_sot') (`lc_sot') (`uc_sot') (`hr_pax') (`lc_pax') (`uc_pax') (`hr_mol') (`lc_mol') (`uc_mol')				
}
}
postclose `cox_model_summary'

tempname cox_model_disease
postfile `cox_model_disease' str20(model) str20(failure) ///
	hr_sot lc_sot uc_sot hr_pax lc_pax uc_pax hr_mol lc_mol uc_mol ///
	using "$projectdir/output/tables/cox_model_disease", replace							 
foreach fail in $ae_disease {
	stset stop_`fail', id(patient_id) origin(time start_date) enter(time start_date) failure(fail_`fail'==1) 
	foreach model in crude agesex adj adj2 adj3 {
		stcox $`model', vce(robust)
					matrix b = r(table)
					local hr_sot = b[1,2]
					local lc_sot = b[5,2]
					local uc_sot = b[6,2]
					local hr_pax = b[1,3]
					local lc_pax = b[5,3]
					local uc_pax = b[6,3]
					local hr_mol = b[1,4]
					local lc_mol = b[5,4]
					local uc_mol = b[6,4]			
		post `cox_model_disease' ("`model'") ("`fail'") (`hr_sot') (`lc_sot') (`uc_sot') (`hr_pax') (`lc_pax') (`uc_pax') (`hr_mol') (`lc_mol') (`uc_mol')				
}
}
postclose `cox_model_disease'


** Rates of events 
tempname coxoutput_rates
postfile `coxoutput_rates' str20(failure) ///
		all_ptime all_events all_rate all_lci all_uci ///
		control_ptime control_events control_rate control_lci_ control_uci ///
		sot_ptime sot_events sot_rate sot_lci sot_uci ///
		pax_ptime pax_events pax_rate pax_lci pax_uci ///
		mol_ptime mol_events mol_rate mol_lci mol_uci ///
		using "$projectdir/output/tables/cox_model_rates", replace							 
foreach fail in $ae_group $ae_disease {
	stset stop_`fail', id(patient_id) origin(time start_date) enter(time start_date) failure(fail_`fail'==1) 			
		stptime 
					local all_rate = `r(rate)'
					local all_ptime = `r(ptime)'
					local all_lci =  `r(lb)'
					local all_uci = `r(ub)'
					local all_events = `r(failures)'						
						
		stptime if drug == 0
					local control_rate = `r(rate)'
					local control_ptime = `r(ptime)'
					local control_lci =  `r(lb)'
					local control_uci = `r(ub)'
					local control_events = `r(failures)' 
		display "no drug"
		
		stptime if drug == 1
					local sot_rate = `r(rate)'
					local sot_ptime = `r(ptime)'
					local sot_lci =  `r(lb)'
					local sot_uci = `r(ub)'
					local sot_events = `r(failures)' 
		display "sotrovimab"
		stptime if drug == 2
					local pax_rate = `r(rate)'
					local pax_ptime = `r(ptime)'
					local pax_lci =  `r(lb)'
					local pax_uci = `r(ub)'
					local pax_events = `r(failures)' 
		display "paxlovid"
		stptime if drug == 3
					local mol_rate = `r(rate)'
					local mol_ptime = `r(ptime)'
					local mol_lci =  `r(lb)'
					local mol_uci = `r(ub)'
					local mol_events = `r(failures)' 
		display "molnupavir"			
		post `coxoutput_rates' ("`fail'") (`all_ptime') (`all_events') (`all_rate') (`all_lci') (`all_uci') ///
					(`control_ptime') (`control_events') (`control_rate') (`control_lci') (`control_uci') ///
					(`sot_ptime') (`sot_events') (`sot_rate') (`sot_lci') (`sot_uci') ///
					(`pax_ptime') (`pax_events') (`pax_rate') (`pax_lci') (`pax_uci') ///
					(`mol_ptime') (`mol_events') (`mol_rate') (`mol_lci') (`mol_uci') 					
}
postclose `coxoutput_rates'

** Hazard of events	
use "$projectdir/output/tables/cox_model_summary", clear
save "$projectdir/output/tables/cox_model_summary", replace
export delimited using "$projectdir/output/tables/cox_model_summary.csv", replace

use "$projectdir/output/tables/cox_model_disease", clear
save "$projectdir/output/tables/cox_model_disease", replace
export delimited using "$projectdir/output/tables/cox_model_disease.csv", replace

** Redact and round rates
clear *
save "$projectdir/output/tables/cox_model_rates_round.dta", replace emptyok
use "$projectdir/output/tables/cox_model_rates", clear
foreach var of varlist *events *ptime  {
gen `var'_round = round(`var', 5)	
} 
gen all_rate_round = .
gen all_lci_round = .
gen all_uci_round = .
gen control_rate_round = .
gen control_lci_round = .
gen control_uci_round = .
gen sot_rate_round = .
gen sot_lci_round = .
gen sot_uci_round = .
gen pax_rate_round = .
gen pax_lci_round = .
gen pax_uci_round = .
gen mol_rate_round = .
gen mol_lci_round = .
gen mol_uci_round = .
levelsof failure, local(levels)
foreach i of local levels {
	
	di "`i'"
	preserve
	keep if failure=="`i'" 
	
	local all_p`i' = all_ptime_round
	local all_e`i' = all_events_round
    cii means `all_p`i'' `all_e`i'', poisson level(95)
	replace all_rate_round = r(mean)*1000 if all_rate_round== .
	replace all_lci_round = r(lb)*1000 if all_lci_round== .
    replace all_uci_round =  r(ub)*1000 if all_uci_round== .
	
	local con_p`i' = control_ptime_round
	local con_e`i' = control_events_round
    cii means `con_p`i'' `con_e`i'', poisson level(95)
	replace control_rate_round = r(mean)*1000 if control_rate_round== .
	replace control_lci_round = r(lb)*1000 if control_lci_round== .
    replace control_uci_round =  r(ub)*1000 if control_uci_round== .
	
	local sot_p`i' = sot_ptime_round
	local sot_e`i' = sot_events_round
    cii means `sot_p`i'' `sot_e`i'', poisson level(95)
	replace sot_rate_round = r(mean)*1000 if sot_rate_round== .
	replace sot_lci_round = r(lb)*1000 if sot_lci_round== .
    replace sot_uci_round =  r(ub)*1000 if sot_uci_round== .
	
	local pax_p`i' = pax_ptime_round
	local pax_e`i' = pax_events_round
    cii means `pax_p`i'' `pax_e`i'', poisson level(95)
	replace pax_rate_round = r(mean)*1000 if pax_rate_round== .
	replace pax_lci_round = r(lb)*1000 if pax_lci_round== .
    replace pax_uci_round =  r(ub)*1000 if pax_uci_round== .
	
	local mol_p`i' = mol_ptime_round
	local mol_e`i' = mol_events_round
    cii means `mol_p`i'' `mol_e`i'', poisson level(95)
	replace mol_rate_round = r(mean)*1000 if mol_rate_round== .
	replace mol_lci_round = r(lb)*1000 if mol_lci_round== .
    replace mol_uci_round =  r(ub)*1000 if mol_uci_round== .
	
	append using "$projectdir/output/tables/cox_model_rates_round.dta"
	save "$projectdir/output/tables/cox_model_rates_round.dta", replace
	restore
}
use "$projectdir/output/tables/cox_model_rates_round", clear
keep failure *round
foreach var of varlist all_rate all_lci all_uci all_events{
replace `var'=. if all_events==5
}
foreach var of varlist control_rate control_lci control_uci control_events{
replace `var'=. if control_events==5
}
foreach var of varlist sot_rate sot_lci sot_uci sot_events{
replace `var'=. if sot_events==5
}
foreach var of varlist pax_rate pax_lci pax_uci pax_events{
replace `var'=. if pax_events==5
}
foreach var of varlist mol_rate mol_lci mol_uci mol_events{
replace `var'=. if mol_events==5
}
order  	failure all* control* sot* pax* mol* 
save "$projectdir/output/tables/cox_model_rates_round", replace
export delimited using "$projectdir/output/tables/cox_model_rates_round.csv", replace

use "$projectdir/output/tables/cox_model_rates", clear
foreach var of varlist *rate *lci *uci {
gen `var'_per = `var'*1000	
drop `var'	
rename 	`var'_per `var'				
}
order failure all* control* sot* pax* mol* 
save "$projectdir/output/tables/cox_model_rates", replace
export delimited using "$projectdir/output/tables/cox_model_rates.csv", replace

log close
			
	   
	   

	



