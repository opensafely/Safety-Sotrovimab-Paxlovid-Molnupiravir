********************************************************************************
*
*	Do-file:			baseline characteristics.do
*	Project:			Sotrovimab-Paxlovid-Molnupiravir
*   Date:  				11/4/23
*	Programmed by:		Katie Bechman
* 	Description:		baseline tables
*	Data used:			data in memory (from output/input.csv) 
*	Data created:		analysis main.dta  (main analysis dataset)
*	Other output:		logfiles, printed to folder $Logdir
*	User installed ado: (place .ado file(s) in analysis folder)

****************************************************************************************************************
**Set filepaths
global projectdir "C:\Users\k1635179\OneDrive - King's College London\Katie\OpenSafely\Safety mAB and antivirals\Safety-Sotrovimab-Paxlovid-Molnupiravir"
//global projectdir `c(pwd)'
di "$projectdir"
capture mkdir "$projectdir/output/data"
capture mkdir "$projectdir/output/figures"
capture mkdir "$projectdir/output/tables"
global logdir "$projectdir/logs"
di "$logdir"
* Open a log file
cap log close
log using "$logdir/baseline_characterisitcs.log", replace

*Set Ado file path
adopath + "$projectdir/analysis/extra_ados"

* SET Index date 
global indexdate 			= "01/03/2020"

use "$projectdir/output/data/main", clear

/*Tables=====================================================================================*/
*Table 1a - 
table1_mc, by(drug) total(before) onecol iqrmiddle(",")  ///
		vars(age contn %5.1f \ ///
			age_group cat %5.1f \ ///	
			bmi contn %5.1f \	///		
			bmi_group cat %5.1f \ ///	
			bmi_30 bin %5.1f \ ///
		    sex bin %5.1f \ ///
			ethnicity cat %5.1f \ ///
			imd cat %5.1f \ ///
			region_nhs cat %5.1f \ ///
			region_covid_therapeutics cat %5.1f \ ///
			stp cat %5.1f \ ///
			postest_treat conts %5.1f \	///	
			downs_syndrome bin %5.1f \ ///
			solid_cancer bin %5.1f \ ///
			haem_disease bin %5.1f \ ///
			renal_disease bin %5.1f \ ///
			liver_disease bin %5.1f \ ///
			imid_on_drug bin %5.1f \ ///
			immunosupression bin %5.1f \ ///
			hiv_aids bin %5.1f \ ///
			solid_organ bin %5.1f \ ///
			rare_neuro bin %5.1f \ ///
			diabetes bin %5.1f \ ///
			chronic_cardiac_disease bin %5.1f \ ///
			hypertension bin %5.1f \ ///
			chronic_respiratory_disease bin %5.1f \ ///
			vaccination_status cat %5.1f \ ///
			month_vacc_covid conts %5.1f \ ///
			prior_infection  bin %5.1f \ ///
			drugs_do_not_use_contra bin %5.1f \ ///
			drugs_consider_risk_contra bin %5.1f \ ///
			paxlovid_contra bin %5.1f)


*check treatment status*
count if drug==1&sotrovimab==sotrovimab_not_start
count if drug==1&sotrovimab==sotrovimab_stopped
count if drug==2&paxlovid==paxlovid_not_start
count if drug==2&paxlovid==paxlovid_stopped
count if drug==3&molnupiravir==molnupiravir_not_start
count if drug==3&molnupiravir==molnupiravir_stopped


log close




