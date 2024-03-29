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


use "$projectdir/output/data/sensitivity_analysis.dta", clear


* Models
global crude 	i.drug 
global agesex 	i.drug age i.sex
global adj 		i.drug age i.sex i.region_nhs i.imdq5 White 1b.bmi_group ///
				paxlovid_contraindicated i.vaccination_status diabetes chronic_cardiac_disease chronic_respiratory_disease hypertension ///
			    downs_syndrome solid_cancer haem_disease renal_disease liver_disease imid_on_drug immunosuppression hiv_aids organ_transplant rare_neuro  
global adj2 	i.drug age i.sex i.region_nhs i.imdq5 White 1b.bmi_group 
global adj3 	i.drug age i.sex i.region_nhs i.imdq5 White 1b.bmi_group ///
				paxlovid_contraindicated i.vaccination_status diabetes chronic_cardiac_disease chronic_respiratory_disease hypertension 
global adj4		paxlovid_contraindicated i.vaccination_status diabetes chronic_cardiac_disease chronic_respiratory_disease hypertension ///
			    downs_syndrome solid_cancer haem_disease renal_disease liver_disease imid_on_drug immunosuppression hiv_aids organ_transplant rare_neuro ///
				dementia care_home serious_mental_illness

* Outcome
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

***************************************************************************************************************************************************************
** MAIN ANALYSIS 1 = Treatment group start date = treat date. 
*					 Control group start date = delayed by median time between test and treat in treat group   	  *

use "$projectdir/output/data/sensitivity_analysis.dta", clear
tab pre_drug_test drug
drop if  covid_test_5d!=1 & drug >0
tab pre_drug_test drug
tab drug paxlovid_contraindicated

** Start day for treatment group is date treated & start date for control group is date test + 2 days
count if start_date!=covid_test_positive_date & drug==0
count if start_date!=date_treated & drug>0
tab median_delay_all
gen start_date_delay = start_date + median_delay_all if drug==0
replace start_date_delay = start_date if drug>0

*** Graphs - Schoenfeld Residual & log-log plot
foreach fail in $ae_combined {
	stset stop_`fail', id(patient_id) origin(time start_date_delay) enter(time start_date_delay) failure(fail_`fail'==1) 
			stcox i.drug 
			estat phtest,de
			estat phtest, plot(1.drug) ytitle("Scaled Schoenfeld Residual, Sotrovimab", size(small)) name(schoenfeld_sot_`fail', replace)
			estat phtest, plot(2.drug) ytitle("Scaled Schoenfeld Residual, Paxlovid",size(small)) name(schoenfeld_pax_`fail', replace)
			estat phtest, plot(3.drug) ytitle("Scaled Schoenfeld Residual, Molnupiravir",size(small)) name(schoenfeld_mol_`fail', replace)
			graph combine schoenfeld_sot_`fail' schoenfeld_pax_`fail' schoenfeld_mol_`fail', title("Schoenfeld Residual `fail'") saving("$projectdir/output/figures/schoenfeld_`fail'", replace)
			graph export "$projectdir/output/figures/schoenfeld_`fail'.svg", as(svg) replace
			stphplot, by(drug) legend(order(1 "Control" 2 "Sotrovimab" 3 "Paxlovid" 4 "Molnupiravir") size(small)) title ("log-log plot `fail'") saving("$projectdir/output/figures/loglog_plot_`fail'", replace) 	
			graph export "$projectdir/output/figures/loglog_plot_`fail'.svg", as(svg) replace
}

*** Hazard of events						
tempname cox_model_summary
postfile `cox_model_summary' str20(model) str20(failure) ///
	hr_sot lc_sot uc_sot hr_pax lc_pax uc_pax hr_mol lc_mol uc_mol ///
	using "$projectdir/output/tables/cox_model_summary", replace							 
foreach fail in $ae_combined {
	stset stop_`fail', id(patient_id) origin(time start_date_delay) enter(time start_date_delay) failure(fail_`fail'==1) 
	foreach model in crude agesex adj {
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
foreach fail in $ae_diseaseae_ $ae_disease_serious {
	stset stop_`fail', id(patient_id) origin(time start_date_delay) enter(time start_date_delay) failure(fail_`fail'==1) 
	foreach model in crude agesex adj {
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


*** Rates of events 
tempname coxoutput_rates
postfile `coxoutput_rates' str20(failure) ///
		all_ptime all_events all_rate all_lci all_uci ///
		control_ptime control_events control_rate control_lci_ control_uci ///
		sot_ptime sot_events sot_rate sot_lci sot_uci ///
		pax_ptime pax_events pax_rate pax_lci pax_uci ///
		mol_ptime mol_events mol_rate mol_lci mol_uci ///
		using "$projectdir/output/tables/cox_model_rates", replace	
foreach fail in $ae_disease $ae_disease_serious $ae_combined {
	stset stop_`fail', id(patient_id) origin(time start_date_delay) enter(time start_date_delay) failure(fail_`fail'==1) 		
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
		post `coxoutput_rates' ("`fail'")	(`all_ptime') (`all_events') (`all_rate') (`all_lci') (`all_uci') ///
					(`control_ptime') (`control_events') (`control_rate') (`control_lci') (`control_uci') ///
					(`sot_ptime') (`sot_events') (`sot_rate') (`sot_lci') (`sot_uci') ///
					(`pax_ptime') (`pax_events') (`pax_rate') (`pax_lci') (`pax_uci') ///
					(`mol_ptime') (`mol_events') (`mol_rate') (`mol_lci') (`mol_uci') 	
					
}
postclose `coxoutput_rates'

*** Redact and save 
use "$projectdir/output/tables/cox_model_summary", clear
save "$projectdir/output/tables/cox_model_summary", replace
export delimited using "$projectdir/output/tables/cox_model_summary.csv", replace

use "$projectdir/output/tables/cox_model_disease", clear
save "$projectdir/output/tables/cox_model_disease", replace
export delimited using "$projectdir/output/tables/cox_model_disease.csv", replace

use "$projectdir/output/tables/cox_model_rates", clear
order failure all* control* sot* pax* mol* 
save "$projectdir/output/tables/cox_model_rates", replace
export delimited using "$projectdir/output/tables/cox_model_rates.csv", replace

use "$projectdir/output/tables/cox_model_rates", clear
foreach var of varlist *events *ptime  {
gen `var'_midpoint = (ceil(`var'/6)*6) - (floor(6/2) * (`var'!=0))
}
foreach var in all control sot pax mol {
gen `var'_rate_midpoint = (`var'_events_midpoint/`var'_ptime_midpoint)*1000
gen `var'_lci_midpoint = (invpoisson(`var'_events_midpoint,.975)/`var'_ptime_midpoint)*1000
gen `var'_uci_midpoint = (invpoisson(`var'_events_midpoint,.025)/`var'_ptime_midpoint)*1000
}  
keep failure *midpoint
order  	failure all* control* sot* pax* mol* 
save "$projectdir/output/tables/cox_model_rates_round", replace
export delimited using "$projectdir/output/tables/cox_model_rates_round.csv", replace

**************************************************************************************************************************************************************************************************************************************
** SENSITIVITY ANALYSIS 1 = Treatment group start date = covid test  	 *
*					 		Control group start date = covid test   	 *
use "$projectdir/output/data/main.dta", clear
tab drug covid_test
tab drug pre_drug_test
tab drug paxlovid_contraindicated

** Start day 
count if start_date!=covid_test_positive_date & drug==0
count if start_date!=covid_test_positive_date & drug>0
						
*** Hazard of events						
tempname cox_model_summary_sens_1
postfile `cox_model_summary_sens_1' str20(model) str20(failure) ///
	hr_sot lc_sot uc_sot hr_pax lc_pax uc_pax hr_mol lc_mol uc_mol ///
	using "$projectdir/output/tables/cox_model_summary_sens_1", replace							 
foreach fail in $ae_combined {
	stset stop_`fail', id(patient_id) origin(time start_date) enter(time start_date) failure(fail_`fail'==1) 
	foreach model in crude agesex adj {
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
		
		post `cox_model_summary_sens_1' ("`model'") ("`fail'") (`hr_sot') (`lc_sot') (`uc_sot') (`hr_pax') (`lc_pax') (`uc_pax') (`hr_mol') (`lc_mol') (`uc_mol')				
}
}
postclose `cox_model_summary_sens_1'

tempname cox_model_disease_sens_1
postfile `cox_model_disease_sens_1' str20(model) str20(failure) ///
	hr_sot lc_sot uc_sot hr_pax lc_pax uc_pax hr_mol lc_mol uc_mol ///
	using "$projectdir/output/tables/cox_model_disease_sens_1", replace							 
foreach fail in $ae_diseaseae_ $ae_disease_serious {
	stset stop_`fail', id(patient_id) origin(time start_date) enter(time start_date) failure(fail_`fail'==1) 
	foreach model in crude agesex adj {
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
		post `cox_model_disease_sens_1' ("`model'") ("`fail'") (`hr_sot') (`lc_sot') (`uc_sot') (`hr_pax') (`lc_pax') (`uc_pax') (`hr_mol') (`lc_mol') (`uc_mol')				
}
}
postclose `cox_model_disease_sens_1'


*** Rates of events 
tempname coxoutput_rates_sens_1
postfile `coxoutput_rates_sens_1' str20(failure) ///
		all_ptime all_events all_rate all_lci all_uci ///
		control_ptime control_events control_rate control_lci_ control_uci ///
		sot_ptime sot_events sot_rate sot_lci sot_uci ///
		pax_ptime pax_events pax_rate pax_lci pax_uci ///
		mol_ptime mol_events mol_rate mol_lci mol_uci ///
		using "$projectdir/output/tables/cox_model_rates_sens_1", replace	
foreach fail in $ae_disease $ae_disease_serious $ae_combined {
	stset stop_`fail', id(patient_id) origin(time start_date) enter(time start_date) failure(fail_`fail'==1) 		
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
		post `coxoutput_rates_sens_1' ("`fail'")	(`all_ptime') (`all_events') (`all_rate') (`all_lci') (`all_uci') ///
					(`control_ptime') (`control_events') (`control_rate') (`control_lci') (`control_uci') ///
					(`sot_ptime') (`sot_events') (`sot_rate') (`sot_lci') (`sot_uci') ///
					(`pax_ptime') (`pax_events') (`pax_rate') (`pax_lci') (`pax_uci') ///
					(`mol_ptime') (`mol_events') (`mol_rate') (`mol_lci') (`mol_uci') 	
					
}
postclose `coxoutput_rates_sens_1'

*** Redact and save 
use "$projectdir/output/tables/cox_model_summary_sens_1", clear
save "$projectdir/output/tables/cox_model_summary_sens_1", replace
export delimited using "$projectdir/output/tables/cox_model_summary_sens_1.csv", replace

use "$projectdir/output/tables/cox_model_disease_sens_1", clear
save "$projectdir/output/tables/cox_model_disease_sens_1", replace
export delimited using "$projectdir/output/tables/cox_model_disease_sens_1.csv", replace

use "$projectdir/output/tables/cox_model_rates_sens_1", clear
order failure all* control* sot* pax* mol* 
save "$projectdir/output/tables/cox_model_rates_sens_1", replace
export delimited using "$projectdir/output/tables/cox_model_rates_sens_1.csv", replace

use "$projectdir/output/tables/cox_model_rates_sens_1", clear
foreach var of varlist *events *ptime  {
gen `var'_midpoint = (ceil(`var'/6)*6) - (floor(6/2) * (`var'!=0))
}
foreach var in all control sot pax mol {
gen `var'_rate_midpoint = (`var'_events_midpoint/`var'_ptime_midpoint)*1000
gen `var'_lci_midpoint = (invpoisson(`var'_events_midpoint,.975)/`var'_ptime_midpoint)*1000
gen `var'_uci_midpoint = (invpoisson(`var'_events_midpoint,.025)/`var'_ptime_midpoint)*1000
}  
keep failure *midpoint
order  	failure all* control* sot* pax* mol* 
save "$projectdir/output/tables/cox_model_rates_round_sens_1", replace
export delimited using "$projectdir/output/tables/cox_model_rates_round_sens_1.csv", replace

*******************************************************************************************************************
** SENSITIVITY ANALYSIS 2 = Treatment group start date = treatment date. 
*					 		Control group start date = covid test	  *

use "$projectdir/output/data/sensitivity_analysis.dta", clear
tab drug pre_drug_test
drop if  covid_test_5d!=1 & drug >0
tab drug pre_drug_test
tab drug paxlovid_contraindicated

** Start day 
count if start_date!=covid_test_positive_date & drug==0
count if start_date!=date_treated & drug>0
						
*** Hazard of events						
tempname cox_model_summary_sens_2
postfile `cox_model_summary_sens_2' str20(model) str20(failure) ///
	hr_sot lc_sot uc_sot hr_pax lc_pax uc_pax hr_mol lc_mol uc_mol ///
	using "$projectdir/output/tables/cox_model_summary_sens_2", replace							 
foreach fail in $ae_combined {
	stset stop_`fail', id(patient_id) origin(time start_date) enter(time start_date) failure(fail_`fail'==1) 
	foreach model in crude agesex adj {
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
		
		post `cox_model_summary_sens_2' ("`model'") ("`fail'") (`hr_sot') (`lc_sot') (`uc_sot') (`hr_pax') (`lc_pax') (`uc_pax') (`hr_mol') (`lc_mol') (`uc_mol')				
}
}
postclose `cox_model_summary_sens_2'

*** Rates of events 
tempname coxoutput_rates_sens_2
postfile `coxoutput_rates_sens_2' str20(failure) ///
		all_ptime all_events all_rate all_lci all_uci ///
		control_ptime control_events control_rate control_lci_ control_uci ///
		sot_ptime sot_events sot_rate sot_lci sot_uci ///
		pax_ptime pax_events pax_rate pax_lci pax_uci ///
		mol_ptime mol_events mol_rate mol_lci mol_uci ///
		using "$projectdir/output/tables/cox_model_rates_sens_2", replace	
foreach fail in $ae_disease $ae_disease_serious $ae_combined {
	stset stop_`fail', id(patient_id) origin(time start_date) enter(time start_date) failure(fail_`fail'==1) 		
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
		post `coxoutput_rates_sens_2' ("`fail'")	(`all_ptime') (`all_events') (`all_rate') (`all_lci') (`all_uci') ///
					(`control_ptime') (`control_events') (`control_rate') (`control_lci') (`control_uci') ///
					(`sot_ptime') (`sot_events') (`sot_rate') (`sot_lci') (`sot_uci') ///
					(`pax_ptime') (`pax_events') (`pax_rate') (`pax_lci') (`pax_uci') ///
					(`mol_ptime') (`mol_events') (`mol_rate') (`mol_lci') (`mol_uci') 	
					
}
postclose `coxoutput_rates_sens_2'

*** Redact and save 
use "$projectdir/output/tables/cox_model_summary_sens_2", clear
save "$projectdir/output/tables/cox_model_summary_sens_2", replace
export delimited using "$projectdir/output/tables/cox_model_summary_sens_2.csv", replace

use "$projectdir/output/tables/cox_model_rates_sens_2", clear
order failure all* control* sot* pax* mol* 
save "$projectdir/output/tables/cox_model_rates_sens_2", replace
export delimited using "$projectdir/output/tables/cox_model_rates_sens_2.csv", replace

use "$projectdir/output/tables/cox_model_rates_sens_2", clear
foreach var of varlist *events *ptime  {
gen `var'_midpoint = (ceil(`var'/6)*6) - (floor(6/2) * (`var'!=0))
}
foreach var in all control sot pax mol {
gen `var'_rate_midpoint = (`var'_events_midpoint/`var'_ptime_midpoint)*1000
gen `var'_lci_midpoint = (invpoisson(`var'_events_midpoint,.975)/`var'_ptime_midpoint)*1000
gen `var'_uci_midpoint = (invpoisson(`var'_events_midpoint,.025)/`var'_ptime_midpoint)*1000
}  
keep failure *midpoint
order  	failure all* control* sot* pax* mol* 
save "$projectdir/output/tables/cox_model_rates_round_sens_2", replace
export delimited using "$projectdir/output/tables/cox_model_rates_round_sens_2.csv", replace

**************************************************************************************************************************************************************************************************************************************
** SENSITIVITY ANALYSIS 3 = start date is covid test + time lag or tvc for everyone  **
use "$projectdir/output/data/main.dta", clear
tab drug covid_test
tab drug pre_drug_test
tab drug paxlovid_contraindicated

** Start day 
count if start_date!=covid_test_positive_date & drug==0
count if start_date!=covid_test_positive_date & drug>0

** Hazard of events using stsplit 
** patients contributed person-time to untreated between positive test & treatment initiation and then to treated after treatment initiation								 			
tempname cox_model_summary_sens_3a
postfile `cox_model_summary_sens_3a' str20(model) str20(failure) ///
	hr_sot lc_sot uc_sot hr_pax lc_pax uc_pax hr_mol lc_mol uc_mol ///
	using "$projectdir/output/tables/cox_model_summary_sens_3a", replace	
 
foreach fail in $ae_combined {
	preserve
	stset stop_`fail', id(patient_id) origin(time start_date) enter(time start_date) failure(fail_`fail'==1) 
	stsplit time_time_`fail', at(0(1)5)  after(time=start_date)
	tab _t _t0
	replace drug=-1 if _t0==0 & (date_treated-covid_test_positive_date>0) & drug>0
	replace drug=-1 if _t0==1 & (date_treated-covid_test_positive_date>1) & drug>0
	replace drug=-1 if _t0==2 & (date_treated-covid_test_positive_date>2) & drug>0
	replace drug=-1 if _t0==3 & (date_treated-covid_test_positive_date>3) & drug>0
	replace drug=-1 if _t0==4 & (date_treated-covid_test_positive_date>4) & drug>0
	tab drug
	replace drug=0 if drug==-1
	foreach model in crude agesex adj {
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
	post `cox_model_summary_sens_3a' ("`model'") ("`fail'") (`hr_sot') (`lc_sot') (`uc_sot') (`hr_pax') (`lc_pax') (`uc_pax') (`hr_mol') (`lc_mol') (`uc_mol')	
}
	restore
}
postclose `cox_model_summary_sens_3a'

						
** Hazard of events	with 1 day lag					
tempname cox_model_summary_sens_3b
postfile `cox_model_summary_sens_3b' str20(model) str20(failure) ///
	hr_sot lc_sot uc_sot hr_pax lc_pax uc_pax hr_mol lc_mol uc_mol ///
	using "$projectdir/output/tables/cox_model_summary_sens_3b", replace						 
foreach fail in $ae_combined {
	stset stop_`fail', id(patient_id) origin(time start_date) enter(time start_date) failure(fail_`fail'==1) 
	foreach model in crude agesex adj {
		stcox $`model' if _t>=2, vce(robust)
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
		post `cox_model_summary_sens_3b' ("`model'") ("`fail'") (`hr_sot') (`lc_sot') (`uc_sot') (`hr_pax') (`lc_pax') (`uc_pax') (`hr_mol') (`lc_mol') (`uc_mol')				

}
}
postclose `cox_model_summary_sens_3b'

** Hazard of events	with 2 day lag					
tempname cox_model_summary_sens_3c
postfile `cox_model_summary_sens_3c' str20(model) str20(failure) ///
	hr_sot lc_sot uc_sot hr_pax lc_pax uc_pax hr_mol lc_mol uc_mol ///
	using "$projectdir/output/tables/cox_model_summary_sens_3c", replace						 
foreach fail in $ae_combined {
	stset stop_`fail', id(patient_id) origin(time start_date) enter(time start_date) failure(fail_`fail'==1) 
	foreach model in crude agesex adj {
		stcox $`model' if _t>=3, vce(robust)
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
		post `cox_model_summary_sens_3c' ("`model'") ("`fail'") (`hr_sot') (`lc_sot') (`uc_sot') (`hr_pax') (`lc_pax') (`uc_pax') (`hr_mol') (`lc_mol') (`uc_mol')				
}
}
postclose `cox_model_summary_sens_3c'


*** Redact and save 
use "$projectdir/output/tables/cox_model_summary_sens_3a", clear
gen tvc = "tvc"
append using "$projectdir/output/tables/cox_model_summary_sens_3b"
replace tvc ="daylag1" if tvc==""
append using "$projectdir/output/tables/cox_model_summary_sens_3c"
replace tvc ="daylag2" if tvc==""
save "$projectdir/output/tables/cox_model_summary_sens_3", replace
export delimited using "$projectdir/output/tables/cox_model_summary_sens_3.csv", replace


*********************************************************************************************************************************************************************************************
** SENSITIVITY ANALYSIS  4 == Treatment group start date = treat date
*					 		  Control group start date = delayed by median time between test and treat in treat group   	  			*
*							  Restrict to pax contraindicated 	

use "$projectdir/output/data/sensitivity_analysis.dta", clear
tab pre_drug_test drug
drop if covid_test_5d!=1 & drug >0
tab pre_drug_test drug
tab drug paxlovid_contraindicated

** Start day for treatment group is date treated & start date for control group is date test + 2 days
count if start_date!=covid_test_positive_date & drug==0
count if start_date!=date_treated & drug>0
tab median_delay_all
gen start_date_delay = start_date + median_delay_all if drug==0
replace start_date_delay = start_date if drug>0

*** Hazard of events						
tempname cox_model_summary_sens_4
postfile `cox_model_summary_sens_4' str20(model) str20(failure) ///
	hr_sot lc_sot uc_sot hr_pax lc_pax uc_pax hr_mol lc_mol uc_mol ///
	using "$projectdir/output/tables/cox_model_summary_sens_4", replace							 
foreach fail in $ae_combined {
	stset stop_`fail' if paxlovid_contraindicated==0, id(patient_id) origin(time start_date_delay) enter(time start_date_delay) failure(fail_`fail'==1) 
	foreach model in crude agesex adj {
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
		
		post `cox_model_summary_sens_4' ("`model'") ("`fail'") (`hr_sot') (`lc_sot') (`uc_sot') (`hr_pax') (`lc_pax') (`uc_pax') (`hr_mol') (`lc_mol') (`uc_mol')				
}
}

postclose `cox_model_summary_sens_4'


**** Rates of events 
tempname coxoutput_rates_sens_4
postfile `coxoutput_rates_sens_4' str20(failure) ///
		all_ptime all_events all_rate all_lci all_uci ///
		control_ptime control_events control_rate control_lci_ control_uci ///
		sot_ptime sot_events sot_rate sot_lci sot_uci ///
		pax_ptime pax_events pax_rate pax_lci pax_uci ///
		mol_ptime mol_events mol_rate mol_lci mol_uci ///
		using "$projectdir/output/tables/cox_model_rates_sens_4", replace	
foreach fail in $ae_disease $ae_disease_serious $ae_combined  {
	stset stop_`fail' if paxlovid_contraindicated==0, id(patient_id) origin(time start_date_delay) enter(time start_date_delay) failure(fail_`fail'==1) 		
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
		post `coxoutput_rates_sens_4' ("`fail'")	(`all_ptime') (`all_events') (`all_rate') (`all_lci') (`all_uci') ///
					(`control_ptime') (`control_events') (`control_rate') (`control_lci') (`control_uci') ///
					(`sot_ptime') (`sot_events') (`sot_rate') (`sot_lci') (`sot_uci') ///
					(`pax_ptime') (`pax_events') (`pax_rate') (`pax_lci') (`pax_uci') ///
					(`mol_ptime') (`mol_events') (`mol_rate') (`mol_lci') (`mol_uci') 	
					
}
postclose `coxoutput_rates_sens_4'

*** Redact and save 
use "$projectdir/output/tables/cox_model_summary_sens_4", clear
save "$projectdir/output/tables/cox_model_summary_sens_4", replace
export delimited using "$projectdir/output/tables/cox_model_summary_sens_4.csv", replace

use "$projectdir/output/tables/cox_model_rates_sens_4", clear
order failure all* control* sot* pax* mol* 
save "$projectdir/output/tables/cox_model_rates_sens_4", replace
export delimited using "$projectdir/output/tables/cox_model_rates_sens_4.csv", replace

use "$projectdir/output/tables/cox_model_rates_sens_4", clear
foreach var of varlist *events *ptime  {
gen `var'_midpoint = (ceil(`var'/6)*6) - (floor(6/2) * (`var'!=0))
}
foreach var in all control sot pax mol {
gen `var'_rate_midpoint = (`var'_events_midpoint/`var'_ptime_midpoint)*1000
gen `var'_lci_midpoint = (invpoisson(`var'_events_midpoint,.975)/`var'_ptime_midpoint)*1000
gen `var'_uci_midpoint = (invpoisson(`var'_events_midpoint,.025)/`var'_ptime_midpoint)*1000
}  
keep failure *midpoint
order  	failure all* control* sot* pax* mol* 
save "$projectdir/output/tables/cox_model_rates_round_sens_4", replace
export delimited using "$projectdir/output/tables/cox_model_rates_round_sens_4.csv", replace  

*******************************************************************************************************************
** SENSITIVITY ANALYSIS  5 == Treatment group start date on treatment date		* 
*					 		  Control group start date delayed by median delay between test and treat in treat group 	  			*
*							  No restriction to positive covid test 	

use "$projectdir/output/data/sensitivity_analysis.dta", clear
tab drug pre_drug_test
tab drug paxlovid_contraindicated

** Start day for treatment group is date treated & start date for control group is date test + 2 days
count if start_date!=covid_test_positive_date & drug==0
count if start_date!=date_treated & drug>0
tab median_delay_all
gen start_date_delay = start_date + median_delay_all if drug==0
replace start_date_delay = start_date if drug>0
			
*** Hazard of events						
tempname cox_model_summary_sens_5
postfile `cox_model_summary_sens_5' str20(model) str20(failure) ///
	hr_sot lc_sot uc_sot hr_pax lc_pax uc_pax hr_mol lc_mol uc_mol ///
	using "$projectdir/output/tables/cox_model_summary_sens_5", replace							 
foreach fail in $ae_combined {
	stset stop_`fail', id(patient_id) origin(time start_date_delay) enter(time start_date_delay) failure(fail_`fail'==1) 
	foreach model in crude agesex adj {
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
		
		post `cox_model_summary_sens_5' ("`model'") ("`fail'") (`hr_sot') (`lc_sot') (`uc_sot') (`hr_pax') (`lc_pax') (`uc_pax') (`hr_mol') (`lc_mol') (`uc_mol')				
}
}
postclose `cox_model_summary_sens_5'

*** Redact and save 
use "$projectdir/output/tables/cox_model_summary_sens_5", clear
save "$projectdir/output/tables/cox_model_summary_sens_5", replace
export delimited using "$projectdir/output/tables/cox_model_summary_sens_5.csv", replace

**************************************************************************************************************************************************************************************************************************************
** SENSITIVITY ANALYSIS 6 =  Start date is covid test for both control and treatment  **
*							 Restrict to eligible on EHR - i.e high_risk_cohort_codelist==1 					  *

use "$projectdir/output/data/sensitivity_analysis.dta", clear
tab pre_drug_test drug
drop if  covid_test_5d!=1 & drug >0
tab pre_drug_test drug
tab drug paxlovid_contraindicated
tab drug high_risk_cohort_codelist

** Start day for treatment group is date treated & start date for control group is date test + 2 days
count if start_date!=covid_test_positive_date & drug==0
count if start_date!=date_treated & drug>0
tab median_delay_all
gen start_date_delay = start_date + median_delay_all if drug==0
replace start_date_delay = start_date if drug>0

*** Hazard of events						
tempname cox_model_summary_sens_6
postfile `cox_model_summary_sens_6' str20(model) str20(failure) ///
	hr_sot lc_sot uc_sot hr_pax lc_pax uc_pax hr_mol lc_mol uc_mol ///
	using "$projectdir/output/tables/cox_model_summary_sens_6", replace							 
foreach fail in $ae_combined {
	stset stop_`fail' if high_risk_cohort_codelist==1, id(patient_id) origin(time start_date) enter(time start_date) failure(fail_`fail'==1) 
	foreach model in crude agesex adj {
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
		
		post `cox_model_summary_sens_6' ("`model'") ("`fail'") (`hr_sot') (`lc_sot') (`uc_sot') (`hr_pax') (`lc_pax') (`uc_pax') (`hr_mol') (`lc_mol') (`uc_mol')				
}
}
postclose `cox_model_summary_sens_6'

**** Rates of events 
tempname coxoutput_rates_sens_6
postfile `coxoutput_rates_sens_6' str20(failure) ///
		all_ptime all_events all_rate all_lci all_uci ///
		control_ptime control_events control_rate control_lci_ control_uci ///
		sot_ptime sot_events sot_rate sot_lci sot_uci ///
		pax_ptime pax_events pax_rate pax_lci pax_uci ///
		mol_ptime mol_events mol_rate mol_lci mol_uci ///
		using "$projectdir/output/tables/cox_model_rates_sens_6", replace	
foreach fail in $ae_disease $ae_disease_serious $ae_combined  {
	stset stop_`fail' if high_risk_cohort_codelist==1, id(patient_id) origin(time start_date_delay) enter(time start_date_delay) failure(fail_`fail'==1) 		
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
		post `coxoutput_rates_sens_6' ("`fail'")	(`all_ptime') (`all_events') (`all_rate') (`all_lci') (`all_uci') ///
					(`control_ptime') (`control_events') (`control_rate') (`control_lci') (`control_uci') ///
					(`sot_ptime') (`sot_events') (`sot_rate') (`sot_lci') (`sot_uci') ///
					(`pax_ptime') (`pax_events') (`pax_rate') (`pax_lci') (`pax_uci') ///
					(`mol_ptime') (`mol_events') (`mol_rate') (`mol_lci') (`mol_uci') 	
					
}
postclose `coxoutput_rates_sens_6'

*** Redact and save 
use "$projectdir/output/tables/cox_model_summary_sens_6", clear
save "$projectdir/output/tables/cox_model_summary_sens_6", replace
export delimited using "$projectdir/output/tables/cox_model_summary_sens_6.csv", replace

use "$projectdir/output/tables/cox_model_rates_sens_6", clear
order failure all* control* sot* pax* mol* 
save "$projectdir/output/tables/cox_model_rates_sens_6", replace
export delimited using "$projectdir/output/tables/cox_model_rates_sens_6.csv", replace

use "$projectdir/output/tables/cox_model_rates_sens_6", clear
foreach var of varlist *events *ptime  {
gen `var'_midpoint = (ceil(`var'/6)*6) - (floor(6/2) * (`var'!=0))
}
foreach var in all control sot pax mol {
gen `var'_rate_midpoint = (`var'_events_midpoint/`var'_ptime_midpoint)*1000
gen `var'_lci_midpoint = (invpoisson(`var'_events_midpoint,.975)/`var'_ptime_midpoint)*1000
gen `var'_uci_midpoint = (invpoisson(`var'_events_midpoint,.025)/`var'_ptime_midpoint)*1000
}  
keep failure *midpoint
order  	failure all* control* sot* pax* mol* 
save "$projectdir/output/tables/cox_model_rates_round_sens_6", replace
export delimited using "$projectdir/output/tables/cox_model_rates_round_sens_6.csv", replace  
	
	
	
	
	
log close



