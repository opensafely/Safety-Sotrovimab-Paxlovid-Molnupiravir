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


*Predictors of drug use 
gen no_drug=1 if drug==0
replace no_drug=0 if drug >0
				
* Outcome								
tabstat age sex region_nhs, by(no_drug) statistics(n mean sd) column(statistics) nototal long
tabstat age sex region_nhs paxlovid_contraindicated downs_syndrome solid_cancer haem_disease renal_disease ///
		liver_disease imid_on_drug immunosupression hiv_aids organ_transplant rare_neuro, ///
		by(no_drug) statistics(n mean sd) column(statistics) nototal long
tabstat age sex region_nhs paxlovid_contraindicated downs_syndrome solid_cancer haem_disease renal_disease ///
		liver_disease imid_on_drug immunosupression hiv_aids organ_transplant rare_neuro ///
		vaccination_status imdq5 White, ///
		by(no_drug) statistics(n mean sd) column(statistics) nototal long
tabstat age sex region_nhs paxlovid_contraindicated downs_syndrome solid_cancer haem_disease renal_disease ///
		liver_disease imid_on_drug immunosupression hiv_aids organ_transplant rare_neuro ///
		vaccination_status imdq5 White bmi_group diabetes chronic_cardiac_disease chronic_respiratory_disease hypertension, ///
		by(no_drug) statistics(n mean sd) column(statistics) nototal long

tempname coxoutput_propensity

postfile `coxoutput_propensity' str20(model) str20(fail)   ///
	hr_sot lc_sot uc_sot hr_pax lc_pax uc_pax hr_mol lc_mol uc_mol ///
	using "$projectdir/output/tables/cox_model_propensity", replace						

* Models
global agesex 	age i.sex
global adj 		age i.sex i.region_nhs paxlovid_contraindicated ///
				downs_syndrome solid_cancer haem_disease renal_disease liver_disease imid_on_drug immunosupression hiv_aids organ_transplant rare_neuro  
global adj1 age i.sex i.region_nhs paxlovid_contraindicated ///
				downs_syndrome solid_cancer haem_disease renal_disease liver_disease imid_on_drug immunosupression hiv_aids organ_transplant rare_neuro  ///
				vaccination_status imdq5 White 
global adj2 age i.sex i.region_nhs paxlovid_contraindicated ///
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
						ae_rash							///
						ae_anaphylaxis 					///
						ae_severe_drug					///
						ae_nonsevere_drug				///
						ae_ra 							///
						ae_sle 							///
						ae_psorasis 					///
						ae_psa 							///
						ae_axspa 						///
						ae_ibd 														
	
foreach model in agesex adj fulladj1 fulladj2 {
		logistic no_drug $`model'
		predict p_`model'
		twoway 	(histogram p_`model' if no_drug==1, color(green)) ///
				(histogram p_`model' if no_drug==0, fcolor(none) lcolor(black)), ///
				legend(order(1 "No Drug" 2 "Drug")) name(histogram_`model', replace) ///
				saving("$projectdir/output/figures/histogram_`model'", replace)
		graph export "$projectdir/output/figures/histogram_`model'.svg", as(svg) replace
		gen iptw_`model' = 1/p_`model' if no_drug==1
		replace iptw_`model' = 1/(1-p_`model') if no_drug==0
		
		foreach fail in $ae_group $ae_disease{
		stset stop_`fail' [pw=iptw_`model'], id(patient_id) origin(time start_date) enter(time start_date) failure(fail_`fail'==1) 
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
}

postclose `coxoutput_propensity'

pbalchk no_drug age sex region_nhs
pbalchk no_drug age sex region_nhs, wt(iptw_agesex) graph
graph export "$projectdir/output/figures/match_agesex.svg", as(svg) replace

pbalchk no_drug age sex region_nhs paxlovid_contraindicated downs_syndrome solid_cancer haem_disease renal_disease liver_disease imid_on_drug immunosupression hiv_aids organ_transplant rare_neuro
pbalchk no_drug age sex region_nhs paxlovid_contraindicated downs_syndrome solid_cancer haem_disease renal_disease liver_disease imid_on_drug immunosupression hiv_aids organ_transplant rare_neuro, ///
wt(iptw_adj) graph
graph export "$projectdir/output/figures/match_adj.svg", as(svg) replace 

pbalchk no_drug age sex region_nhs paxlovid_contraindicated downs_syndrome solid_cancer haem_disease renal_disease liver_disease imid_on_drug immunosupression hiv_aids organ_transplant rare_neuro vaccination_status imdq5 
pbalchk no_drug age sex region_nhs paxlovid_contraindicated downs_syndrome solid_cancer haem_disease renal_disease liver_disease imid_on_drug immunosupression hiv_aids organ_transplant rare_neuro vaccination_status imdq5, ///
wt(iptw_fulladj1) graph
graph export "$projectdir/output/figures/match_adj1.svg", as(svg) replace

pbalchk no_drug age sex region_nhs paxlovid_contraindicated downs_syndrome solid_cancer haem_disease renal_disease liver_disease imid_on_drug immunosupression hiv_aids organ_transplant rare_neuro vaccination_status imdq5 ///
bmi_group diabetes chronic_cardiac_disease chronic_respiratory_disease hypertension	
pbalchk no_drug age sex region_nhs paxlovid_contraindicated downs_syndrome solid_cancer haem_disease renal_disease liver_disease imid_on_drug immunosupression hiv_aids organ_transplant rare_neuro vaccination_status imdq5 ///
bmi_group diabetes chronic_cardiac_disease chronic_respiratory_disease hypertension, ///
wt(iptw_fulladj2) graph
graph export "$projectdir/output/figures/match_adj2.svg", as(svg) replace

use "$projectdir/output/tables/cox_model_propensity", replace
export delimited using "$projectdir/output/tables/cox_model_propensity_csv.csv", replace

log close




