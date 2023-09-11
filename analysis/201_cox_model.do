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
		ptime_all events_all rate_all lci_all uci_all ///
		ptime_control events_control rate_control lci_control uci_control ///
		ptime_sot events_sot rate_sot lci_sot uci_sot ///
		ptime_pax events_pax rate_pax lci_pax uci_pax ///
		ptime_mol events_mol rate_mol lci_mol uci_mol ///
		using "$projectdir/output/tables/cox_model_rates", replace							 
foreach fail in $ae_group $ae_disease {
	stset stop_`fail', id(patient_id) origin(time start_date) enter(time start_date) failure(fail_`fail'==1) 			
		stptime 
					local rate_all = .
					local ptime_all = `r(ptime)'
					local lci_all = .
					local uci_all = .
					local events_all .
						if `r(failures)' == 0 | `r(failures)' > 7 local events_all `r(failures)'
						if `r(failures)' == 0 | `r(failures)' > 7 local rate_all `r(rate)'
						if `r(failures)' == 0 | `r(failures)' > 7 local lci_all `r(lb)'
						if `r(failures)' == 0 | `r(failures)' > 7 local uci_all `r(ub)'
		stptime if drug == 0
					local rate_control = .
					local ptime_control = `r(ptime)'
					local lci_control = .
					local uci_control = .
					local events_control .
						if `r(failures)' == 0 | `r(failures)' > 7 local events_control `r(failures)'
						if `r(failures)' == 0 | `r(failures)' > 7 local rate_control `r(rate)'
						if `r(failures)' == 0 | `r(failures)' > 7 local lci_control `r(lb)'
						if `r(failures)' == 0 | `r(failures)' > 7 local uci_control `r(ub)'
		display "no drug"
		stptime if drug == 1
					local rate_sot = .
					local ptime_sot = `r(ptime)'
					local lci_sot = .
					local uci_sot = .
					local events_sot .
						if `r(failures)' == 0 | `r(failures)' > 7 local events_sot `r(failures)'
						if `r(failures)' == 0 | `r(failures)' > 7 local rate_sot `r(rate)'
						if `r(failures)' == 0 | `r(failures)' > 7 local lci_sot `r(lb)'
						if `r(failures)' == 0 | `r(failures)' > 7 local uci_sot `r(ub)'		
		display "sotrovimab"
		stptime if drug == 2
					local rate_pax = .
					local ptime_pax = `r(ptime)'
					local lci_pax = .
					local uci_pax = .
					local events_pax .
						if `r(failures)' == 0 | `r(failures)' > 7 local events_pax `r(failures)'
						if `r(failures)' == 0 | `r(failures)' > 7 local rate_pax `r(rate)'
						if `r(failures)' == 0 | `r(failures)' > 7 local lci_pax `r(lb)'
						if `r(failures)' == 0 | `r(failures)' > 7 local uci_pax `r(ub)'	
		display "paxlovid"
		stptime if drug == 3
					local rate_mol = .
					local ptime_mol = `r(ptime)'
					local lci_mol = . 
					local uci_mol = .
					local events_mol .
						if `r(failures)' == 0 | `r(failures)' > 7 local events_mol `r(failures)'
						if `r(failures)' == 0 | `r(failures)' > 7 local rate_mol `r(rate)'
						if `r(failures)' == 0 | `r(failures)' > 7 local lci_mol `r(lb)'
						if `r(failures)' == 0 | `r(failures)' > 7 local uci_mol `r(ub)'	
		display "molnupavir"			
		post `coxoutput_rates' ("`fail'") (`ptime_all') (`events_all') (`rate_all') (`lci_all') (`uci_all') ///
					(`ptime_control') (`events_control') (`rate_control') (`lci_control') (`uci_control') ///
					(`ptime_sot') (`events_sot') (`rate_sot') (`lci_sot') (`uci_sot') ///
					(`ptime_pax') (`events_pax') (`rate_pax') (`lci_pax') (`uci_pax') ///
					(`ptime_mol') (`events_mol') (`rate_mol') (`lci_mol') (`uci_mol') ///
					
}
postclose `coxoutput_rates'


use "$projectdir/output/tables/cox_model_summary", clear
foreach var of varlist hr* lc* uc* {
	format `var' %3.2f	
}	
save "$projectdir/output/tables/cox_model_summary", replace
export delimited using "$projectdir/output/tables/cox_model_summary.csv", replace

use "$projectdir/output/tables/cox_model_disease", clear
foreach var of varlist hr* lc* uc* {
	format `var' %3.2f			
}	
save "$projectdir/output/tables/cox_model_disease", replace
export delimited using "$projectdir/output/tables/cox_model_disease.csv", replace

use "$projectdir/output/tables/cox_model_rates", clear
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
save "$projectdir/output/tables/cox_model_rates", replace
export delimited using "$projectdir/output/tables/cox_model_rates.csv", replace

log close
			
	   
	   

	



