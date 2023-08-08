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
global adj 		i.drug age i.sex i.region_nhs paxlovid_contraindicated ///
			    downs_syndrome solid_cancer haem_disease renal_disease liver_disease imid_on_drug immunosupression hiv_aids organ_transplant rare_neuro  
global fulladj1 i.drug age i.sex i.region_nhs paxlovid_contraindicated ///
			    downs_syndrome solid_cancer haem_disease renal_disease liver_disease imid_on_drug immunosupression hiv_aids organ_transplant rare_neuro  ///
				vaccination_status imdq5 White 
global fulladj2 i.drug age i.sex i.region_nhs paxlovid_contraindicated ///
			    downs_syndrome solid_cancer haem_disease renal_disease liver_disease imid_on_drug immunosupression hiv_aids organ_transplant rare_neuro  ///
				vaccination_status imdq5 White 1b.bmi_group diabetes chronic_cardiac_disease chronic_respiratory_disease hypertension
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
			  
tempname coxoutput
postfile `coxoutput' str20(model) str20(failure) ///
	ptime_all events_all rate_all /// 
	ptime_control events_control rate_control /// 
	ptime_sot events_sot rate_sot ///
	ptime_pax events_pax rate_pax ///
	ptime_mol events_mol rate_mol ///
	hr_sot lc_sot uc_sot hr_pax lc_pax uc_pax hr_mol lc_mol uc_mol ///
	using "$projectdir/output/tables/cox_model_summary", replace	
						 
foreach fail in $ae_group $ae_disease {

	stset stop_`fail', id(patient_id) origin(time start_date) enter(time start_date) failure(fail_`fail'==1) 
						
	foreach model in crude agesex adj fulladj1 fulladj2{
				
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
		stptime 
					local rate_all = `r(rate)'
					local ptime_all = `r(ptime)'
					local events_all .
						if `r(failures)' == 0 | `r(failures)' > 7 local events_all `r(failures)'
		
		stptime if drug == 0
					local rate_control = `r(rate)'
					local ptime_control = `r(ptime)'
					local events_control .
						if `r(failures)' == 0 | `r(failures)' > 7 local events_control `r(failures)'
		display "no drug"

		stptime if drug == 1
					local rate_sot = `r(rate)'
					local ptime_sot = `r(ptime)'
					local events_sot .
						if `r(failures)' == 0 | `r(failures)' > 7 local events_sot `r(failures)'
		display "sotrovimab"
		
		stptime if drug == 2
					local rate_pax = `r(rate)'
					local ptime_pax = `r(ptime)'
					local events_pax .
						if `r(failures)' == 0 | `r(failures)' > 7 local events_pax `r(failures)'
		display "paxlovid"
		
		stptime if drug == 3
					local rate_mol = `r(rate)'
					local ptime_mol = `r(ptime)'
					local events_mol .
						if `r(failures)' == 0 | `r(failures)' > 7 local events_mol `r(failures)'
		display "molnupavir"
						
		post `coxoutput' ("`model'") ("`fail'") (`ptime_all') (`events_all') (`rate_all') ///
					(`ptime_control') (`events_control') (`rate_control') ///
					(`ptime_sot') (`events_sot') (`rate_sot') ///
					(`ptime_pax') (`events_pax') (`rate_pax') ///
					(`ptime_mol') (`events_mol') (`rate_mol') ///
					(`hr_sot') (`lc_sot') (`uc_sot') (`hr_pax') (`lc_pax') (`uc_pax') (`hr_mol') (`lc_mol') (`uc_mol')
					
}
}

postclose `coxoutput'


foreach fail in $ae_group {

	stset stop_`fail', id(patient_id) origin(time start_date) enter(time start_date) failure(fail_`fail'==1) 
								
			stcox i.drug 
			sts graph, by(drug) tmax(28) ylabel(0(0.25)1) ylabel(,format(%4.3f)) xlabel(0(7)28) ///
			risktable(,title(" ")order(1 "Control     " 2 "Sotrovimab     " 3 "Paxlovid     " 4 "Molnupiravir     ") ///
			size(small)justification(left) rowtitle(,size(small)justification(right))) ///
			legend(order(1 "Control" 2 "Sotrovimab" 3 "Paxlovid" 4 "Molnupiravir") symxsize(*0.4) size(small)) ///
			xtitle("Analysis time (years)") ylabel(,angle(horizontal)) plotregion(color(white)) graphregion(color(white)) ///
			ytitle("Survival Probability" ) xtitle("Time (Days)") saving("$projectdir/output/figures/survrisk_`fail'", replace)

			graph export "$projectdir/output/figures/survrisk_`fail'.svg", as(svg) replace
			
			stcurve, survival at1(drug=0) at2(drug=1) at3(drug=2) at4(drug=3) title("") ///
			range(0 28) xtitle("Analysis time (years)") ///
			legend(order(1 "Control" 2 "Sotrovimab" 3 "Paxlovid" 4 "Molnupiravir") symxsize(*0.4) size(small)) ///
			ylabel(,angle(horizontal)) plotregion(color(white)) graphregion(color(white)) ///
			ytitle("Survival Probability" ) xtitle("Time (Days)") saving("$projectdir/output/figures/survcurve_`fail'", replace)
	
			graph export "$projectdir/output/figures/survcur_`fail'.svg", as(svg) replace
}


/*foreach fail in $ae_group {

	stset stop_`fail', id(patient_id) origin(time start_date) enter(time start_date) failure(fail_`fail'==1) 
			stcox i.drug 	
			stcurve, haz kernel(epan2) at1(drug=0) at2(drug=1) at3(drug=2) at4(drug=3) ///
			title("") range(0 28) xtitle("Analysis time (years)") ///
			legend(order(1 "Control" 2 "Sotrovimab" 3 "Paxlovid" 4 "Molnupiravir") symxsize(*0.4) size(small)) ///
			ylabel(,angle(horizontal)) plotregion(color(white)) graphregion(color(white)) ///
			ytitle("Survival Probability" ) xtitle("Time (Days)") saving("$projectdir/output/figures/survhaz_`fail'", replace)
				
			graph export "$projectdir/output/figures/survhaz_`fail'.svg", as(svg) replace
			
}
*/


use "$projectdir/output/tables/cox_model_summary", replace
export delimited using "$projectdir/output/tables/cox_model_summary_csv.csv", replace

log close
			

	   
	   
	   
	   

		
		
	



