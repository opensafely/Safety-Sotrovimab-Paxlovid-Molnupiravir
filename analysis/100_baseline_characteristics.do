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
log using "$logdir/baseline_characterisitcs.log", replace

*Set Ado file path
adopath + "$projectdir/analysis/ado"

* SET Index date 
global indexdate 			= "01/03/2020"

use "$projectdir/output/data/main", clear

/*Tables=====================================================================================*/
table1_mc, by(drug) total(before) onecol iqrmiddle(",")  ///
		vars(age contn %5.1f \ ///
			age_group cat %5.1f \ ///	
			bmi contn %5.1f \	///		
			bmi_group cat %5.1f \ ///	
		    sex cat %5.1f \ ///
			ethnicity cat %5.1f \ ///
			ethnicity_with_missing cat %5.1f \ ///
			imdq5 cat %5.1f \ ///
			region_nhs cat %5.1f \ ///
			region_covid_therapeutics cat %5.1f \ ///
			pre_drug_test cat %5.1f \	///	
			downs_syndrome_comb bin %5.1f \ ///
			solid_cancer_comb bin %5.1f \ ///
			haem_disease_comb bin %5.1f \ ///
			renal_disease_comb bin %5.1f \ ///
			liver_disease_comb bin %5.1f \ ///	
			imid_on_drug_comb bin %5.1f \ ///
			immunosupression_comb bin %5.1f \ ///
			hiv_aids_comb bin %5.1f \ ///
			organ_transplant_comb bin %5.1f \ ///
			rare_neuro_comb bin %5.1f \ ///
			diabetes bin %5.1f \ ///
			chronic_cardiac_disease bin %5.1f \ ///
			hypertension bin %5.1f \ ///
			chronic_respiratory_disease bin %5.1f \ ///
			vaccination_status cat %5.1f \ ///
			prior_covid  bin %5.1f \ ///
			egfr_30 bin %5.1f \ ///
			paxlovid_contraindicated bin %5.1f)  saving("$projectdir/output/tables/baseline_allpts.xls", replace)
		 
import excel "$projectdir/output/tables/baseline_allpts.xls", clear
outsheet * using "$projectdir/output/tables/baseline_allpts.csv" , comma nonames replace





log close




