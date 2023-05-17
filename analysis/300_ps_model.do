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

*Models
global agesex	  	age i.sex i.region_nhs
global adj 			age i.sex i.region_nhs drugs_consider_risk_contra ///
					downs_syndrome solid_cancer haem_disease renal_disease liver_disease imid_on_drug immunosupression hiv_aids solid_organ rare_neuro  
global fulladj1 	age i.sex i.region_nhs drugs_consider_risk_contra ///
					downs_syndrome solid_cancer haem_disease renal_disease liver_disease imid_on_drug immunosupression hiv_aids solid_organ rare_neuro  ///
					vaccination_status imd White 
global fulladj2 	age i.sex i.region_nhs drugs_consider_risk_contra ///
					downs_syndrome solid_cancer haem_disease renal_disease liver_disease imid_on_drug immunosupression hiv_aids solid_organ rare_neuro  ///
					vaccination_status imd White 1b.bmi_group diabetes chronic_cardiac_disease chronic_respiratory_disease hypertension		
					
					
tabstat age sex region_nhs, by(no_drug) statistics(n mean sd) column(statistics) nototal long
tabstat age sex region_nhs drugs_consider_risk_contra downs_syndrome solid_cancer haem_disease renal_disease liver_disease imid_on_drug immunosupression hiv_aids solid_organ rare_neuro, ///
		by(no_drug) statistics(n mean sd) column(statistics) nototal long
tabstat age sex region_nhs drugs_consider_risk_contra downs_syndrome solid_cancer haem_disease renal_disease liver_disease imid_on_drug immunosupression hiv_aids solid_organ rare_neuro ///
		vaccination_status imd White, ///
		by(no_drug) statistics(n mean sd) column(statistics) nototal long
tabstat age sex region_nhs drugs_consider_risk_contra downs_syndrome solid_cancer haem_disease renal_disease liver_disease imid_on_drug immunosupression hiv_aids solid_organ rare_neuro ///
		vaccination_status imd White bmi_group diabetes chronic_cardiac_disease chronic_respiratory_disease hypertension, ///
		by(no_drug) statistics(n mean sd) column(statistics) nototal long


tempname coxoutput_propensity
postfile `coxoutput_propensity' str20(model) ///
	hr_sot lc_sot uc_sot hr_pax lc_pax uc_pax hr_mol lc_mol uc_mol ///
	using "$projectdir/output/tables/cox_model_propensity", replace						
	
foreach model in agesex adj fulladj1 fulladj2{
	logistic no_drug $`model'
	predict p_`model'
	twoway (histogram p_`model' if no_drug==1, color(green)) (histogram p_`model' if no_drug==0, fcolor(none) lcolor(black)), legend(order(1 "No Drug" 2 "Drug")) name(histogram_`model', replace) ///
	saving("$projectdir/output/figures/histograms_`model'", replace)
	graph export "$projectdir/output/figures/histogramsp_`model'.svg", as(svg) replace
	gen iptw_`model' = 1/p_`model' if no_drug==1
	replace iptw_`model' = 1/(1-p_`model') if no_drug==0
	stset stop_ae_all [pw=iptw_`model'], id(patient_id) origin(time start_date) enter(time start_date) failure(fail_ae_all==1) 
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
	post `coxoutput_propensity' ("`model'") (`hr_sot') (`lc_sot') (`uc_sot') (`hr_pax') (`lc_pax') (`uc_pax') (`hr_mol') (`lc_mol') (`uc_mol')				
}

postclose `coxoutput_propensity'

pbalchk no_drug age sex region_nhs
pbalchk no_drug age sex region_nhs, wt(iptw_agesex) graph
graph export "$projectdir/output/figures/match_agesex.svg", as(svg) replace

pbalchk no_drug age sex region_nhs drugs_consider_risk_contra downs_syndrome solid_cancer haem_disease renal_disease liver_disease imid_on_drug immunosupression hiv_aids solid_organ rare_neuro
pbalchk no_drug age sex region_nhs drugs_consider_risk_contra downs_syndrome solid_cancer haem_disease renal_disease liver_disease imid_on_drug immunosupression hiv_aids solid_organ rare_neuro, ///
wt(iptw_adj) graph
graph export "$projectdir/output/figures/match_adj.svg", as(svg) replace 

pbalchk no_drug age sex region_nhs drugs_consider_risk_contra downs_syndrome solid_cancer haem_disease renal_disease liver_disease imid_on_drug immunosupression hiv_aids solid_organ rare_neuro vaccination_status imd White
pbalchk no_drug age sex region_nhs drugs_consider_risk_contra downs_syndrome solid_cancer haem_disease renal_disease liver_disease imid_on_drug immunosupression hiv_aids solid_organ rare_neuro vaccination_status imd White, ///
wt(iptw_fulladj1) graph
graph export "$projectdir/output/figures/match_fulladj1.svg", as(svg) replace

pbalchk no_drug age sex region_nhs drugs_consider_risk_contra downs_syndrome solid_cancer haem_disease renal_disease liver_disease imid_on_drug immunosupression hiv_aids solid_organ rare_neuro vaccination_status imd White ///
bmi_group diabetes chronic_cardiac_disease chronic_respiratory_disease hypertension	
pbalchk no_drug age sex region_nhs drugs_consider_risk_contra downs_syndrome solid_cancer haem_disease renal_disease liver_disease imid_on_drug immunosupression hiv_aids solid_organ rare_neuro vaccination_status imd White ///
bmi_group diabetes chronic_cardiac_disease chronic_respiratory_disease hypertension, ///
wt(iptw_fulladj2) graph
graph export "$projectdir/output/figures/match_fulladj2.svg", as(svg) replace

log close

/*Estimate probability of drug used as four groups with mlogit = balancing poor
foreach model in adj fulladj1 fulladj2{
	mlogit drug $`model'
	predict p_`model'
	histogram p_`model' if drug==0, name(control_`model', replace) nodraw xtitle("Probability of no drug")
	histogram p_`model' if drug==1, name(one_`model', replace) nodraw xtitle("Probability of sotrovimab")
	histogram p_`model' if drug==2, name(two_`model', replace) nodraw xtitle("Probability of paxlovid")
	histogram p_`model' if drug==3, name(three_`model', replace) nodraw xtitle("Probability of molnupavir")
	graph combine control_`model' one_`model' two_`model' three_`model', rows(2) name(histograms_`model', replace)    
	graph export "$projectdir/output/figures/histograms_`model'.svg", as(svg) replace
	gen iptw_`model' = 1/p_`model' if drug>0
	replace iptw_`model' = 1/(1-p_`model') if drug==0
	stset stop_ae_all [pw=iptw_`model'], id(patient_id) origin(time start_date) enter(time start_date) failure(fail_ae_all==1) 
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
	post `coxoutput_propensity' ("`model'") (`hr_sot') (`lc_sot') (`uc_sot') (`hr_pax') (`lc_pax') (`uc_pax') (`hr_mol') (`lc_mol') (`uc_mol')				
}
postclose `coxoutput_propensity'
pbalchk no_drug age sex region_nhs
pbalchk no_drug age sex region_nhs, wt(iptw_agesex) graph
*/




