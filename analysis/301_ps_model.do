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
log using "$logdir/ps_model.log", replace

*Set Ado file path
adopath + "$projectdir/analysis/ado"

* SET Index date 
global indexdate 			= "01/03/2020"

use "$projectdir/output/data/main", clear


* Models
global agesex 	age i.sex
global adj 		age i.sex i.region_nhs paxlovid_contraindicated ///
				downs_syndrome solid_cancer haem_disease renal_disease liver_disease imid_on_drug immunosupression hiv_aids organ_transplant rare_neuro  
global fulladj1 age i.sex i.region_nhs paxlovid_contraindicated ///
				downs_syndrome solid_cancer haem_disease renal_disease liver_disease imid_on_drug immunosupression hiv_aids organ_transplant rare_neuro  ///
				vaccination_status imdq5 White 
global fulladj2 age i.sex i.region_nhs paxlovid_contraindicated ///
				downs_syndrome solid_cancer haem_disease renal_disease liver_disease imid_on_drug immunosupression hiv_aids organ_transplant rare_neuro  ///
				vaccination_status imdq5 White 1b.bmi_group diabetes chronic_cardiac_disease chronic_respiratory_disease hypertension
											
* Failures
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

****************************************************************************************************************
*1. Individual drug V No Drug
									
tempname coxoutput_propensity

postfile `coxoutput_propensity' str20(model) str20(fail)   ///
hr_sot lc_sot uc_sot hr_pax lc_pax uc_pax hr_mol lc_mol uc_mol ///
using "$projectdir/output/tables/cox_model_propensity", replace	
	

foreach model in agesex adj fulladj1 fulladj2  {	
	* control V all drug
	gen control = 1 if drug==0
	replace control = 0 if drug>0
	logistic control $`model'	
	predict p_control
	gen iptw`$model' = 1/p_control if drug==0
	* sot V control
	gen drug1 = 1 if drug==0
	replace drug1 = 0 if drug==1
	logistic drug1 $`model'	
	predict p_drug1
	replace iptw`$model' = 1/(1-p_drug1) if drug==1
	* pax V control
	gen drug2 = 1 if drug==0
	replace drug2 = 0 if drug==2
	logistic drug2 $`model'	
	predict p_drug2
	replace iptw`$model' = 1/(1-p_drug2) if drug==2
	* mol V control
	gen drug3 = 1 if drug==0
	replace drug3 = 0 if drug==3
	logistic drug3 $`model'	
	predict p_drug3
	replace iptw`$model' = 1/(1-p_drug3) if drug==3
	
	twoway 	(histogram p_control if drug==0, fcolor(none) lcolor(black)) ///
			(histogram p_drug1 if drug==1, color(green)), legend(order(1 "No Drug" 2 "Sotrovimab")) name(histogram_sot_`model', replace)
	twoway 	(histogram p_control if drug==0, fcolor(none) lcolor(black)) ///
			(histogram p_drug2 if drug==2, color(green)), legend(order(1 "No Drug" 2 "Paxlovid")) name(histogram_pax_`model', replace)	
	twoway 	(histogram p_control if drug==0, fcolor(none) lcolor(black)) ///
			(histogram p_drug3 if drug==3, color(green)), legend(order(1 "No Drug" 2 "Molnupiravir")) name(histogram_mol_`model', replace)
	graph combine histogram_sot_`model' histogram_pax_`model' histogram_mol_`model', name(histogram_`model', replace) ///
	saving("$projectdir/output/figures/histogram_`model'", replace)
	graph export "$projectdir/output/figures/histogram_`model'.svg", as(svg) replace
	
	foreach var of varlist drug1 drug2 drug3 {
		pbalchk `var' age sex region_nhs paxlovid_contraindicated downs_syndrome solid_cancer haem_disease renal_disease ///
		liver_disease imid_on_drug immunosupression hiv_aids organ_transplant rare_neuro vaccination_status imdq5 bmi_group ///
		diabetes chronic_cardiac_disease chronic_respiratory_disease hypertension	
		pbalchk `var' age sex region_nhs paxlovid_contraindicated downs_syndrome solid_cancer haem_disease renal_disease ///
		liver_disease imid_on_drug immunosupression hiv_aids organ_transplant rare_neuro vaccination_status imdq5 bmi_group ///
		diabetes chronic_cardiac_disease chronic_respiratory_disease hypertension, wt(iptw`$model') graph 
		graph save "$projectdir/output/figures/match_fulladj2_`var'", replace
		}
	graph export "$projectdir/output/figures/match_fulladj2_drug1.svg", as(svg) replace
	graph export "$projectdir/output/figures/match_fulladj2_drug2.svg", as(svg) replace
	graph export "$projectdir/output/figures/match_fulladj2_drug3.svg", as(svg) replace	
	
	foreach fail in $ae_group $ae_disease {
		stset stop_`fail' [pw=iptw`$model'], id(patient_id) origin(time start_date) enter(time start_date) failure(fail_`fail'==1) 
		stcox i.drug, vce(robust)
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
	post `coxoutput_propensity' ("`model'") ("`fail'") (`hr_sot') (`lc_sot') (`uc_sot') (`hr_pax') (`lc_pax') (`uc_pax') (`hr_mol') (`lc_mol') (`uc_mol')
}
	drop p_* drug1 drug2 drug3 control iptw
}

postclose `coxoutput_propensity'


*******************************************************************
tempname coxoutput_propensity_common

postfile `coxoutput_propensity_common' str20(model) str20(fail)   ///
hr_sot lc_sot uc_sot hr_pax lc_pax uc_pax hr_mol lc_mol uc_mol ///
using "$projectdir/output/tables/cox_model_propensity_common", replace
	
foreach model in fulladj2  {	
	* control V all drug
	gen control = 1 if drug==0
	replace control = 0 if drug>0
	logistic control $`model'	
	predict p_control
	gen iptw`$model' = 1/p_control if drug==0
	* sot V control
	gen drug1 = 1 if drug==0
	replace drug1 = 0 if drug==1
	logistic drug1 $`model'	
	predict p_drug1
	replace iptw`$model' = 1/(1-p_drug1) if drug==1
	* pax V control
	gen drug2 = 1 if drug==0
	replace drug2 = 0 if drug==2
	logistic drug2 $`model'	
	predict p_drug2
	replace iptw`$model' = 1/(1-p_drug2) if drug==2
	* mol V control
	gen drug3 = 1 if drug==0
	replace drug3 = 0 if drug==3
	logistic drug3 $`model'	
	predict p_drug3
	replace iptw`$model' = 1/(1-p_drug3) if drug==3
	gen p_all = p_control if drug==0
	replace p_all = p_drug1 if drug==1
	replace p_all = p_drug2 if drug==2
	replace p_all = p_drug3 if drug==3
	bys drug: sum p_all
	
	* common support
	summarize p_all if drug == 0, detail
	gen min_prop_ctrl = r(min)
	gen max_prop_ctrl = r(max)
	summarize p_all if drug > 0, detail
	gen min_prop_treat = r(min)
	gen max_prop_treat = r(max)
	gen common_min = max(min_prop_ctrl , min_prop_treat)
	gen common_max = min(max_prop_ctrl, max_prop_treat)
	gen common_support = (p_all >= common_min & p_all <=common_max)
	tab common_support
	egen common = sum(common_support)
	
	if common >0 {
				keep if common_support==1
				twoway 	(histogram p_control if drug==0, fcolor(none) lcolor(black)) ///
						(histogram p_drug1 if drug==1, color(green)), legend(order(1 "No Drug" 2 "Sotrovimab")) name(histogram_sot_`model', replace)
				twoway 	(histogram p_control if drug==0, fcolor(none) lcolor(black)) ///
						(histogram p_drug2 if drug==2, color(green)), legend(order(1 "No Drug" 2 "Paxlovid")) name(histogram_pax_`model', replace)	
				twoway 	(histogram p_control if drug==0, fcolor(none) lcolor(black)) ///
						(histogram p_drug3 if drug==3, color(green)), legend(order(1 "No Drug" 2 "Molnupiravir")) name(histogram_mol_`model', replace)
				graph combine histogram_sot_`model' histogram_pax_`model' histogram_mol_`model', name(histogram_combine_`model', replace) ///
				saving("$projectdir/output/figures/histogram_`model'_common", replace)
				graph export "$projectdir/output/figures/histogram_`model'_common.svg", as(svg) replace
				
				foreach var of varlist drug1 drug2 drug3 {
					pbalchk `var' age sex region_nhs paxlovid_contraindicated downs_syndrome solid_cancer haem_disease renal_disease ///
					liver_disease imid_on_drug immunosupression hiv_aids organ_transplant rare_neuro vaccination_status imdq5 bmi_group ///
					diabetes chronic_cardiac_disease chronic_respiratory_disease hypertension	
					pbalchk `var' age sex region_nhs paxlovid_contraindicated downs_syndrome solid_cancer haem_disease renal_disease ///
					liver_disease imid_on_drug immunosupression hiv_aids organ_transplant rare_neuro vaccination_status imdq5 bmi_group ///
					diabetes chronic_cardiac_disease chronic_respiratory_disease hypertension, wt(iptw`$model') graph 
					graph save "$projectdir/output/figures/pbalchk_`var'", replace
					}
				graph export "$projectdir/output/figures/match_fulladj2_drug1_common.svg", as(svg) replace
				graph export "$projectdir/output/figures/match_fulladj2_drug2_common.svg", as(svg) replace
				graph export "$projectdir/output/figures/match_fulladj2_drug3_common.svg", as(svg) replace	
				
				foreach fail in $ae_group $ae_disease {
					stset stop_`fail' [pw=iptw`$model'], id(patient_id) origin(time start_date) enter(time start_date) failure(fail_`fail'==1) 
					stcox i.drug, vce(robust)
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
				post `coxoutput_propensity_common' ("`model'") ("`fail'") (`hr_sot') (`lc_sot') (`uc_sot') (`hr_pax') (`lc_pax') (`uc_pax') (`hr_mol') (`lc_mol') (`uc_mol')
				}
		}
	drop p_* drug1 drug2 drug3 control iptw min_* max_* common*
}

postclose `coxoutput_propensity_common'


*******************************************************************************

use "$projectdir/output/tables/cox_model_propensity", replace
export delimited using "$projectdir/output/tables/cox_model_propensity.csv", replace
use "$projectdir/output/tables/cox_model_propensity_common", replace
export delimited using "$projectdir/output/tables/cox_model_propensity_common.csv", replace


log close


	