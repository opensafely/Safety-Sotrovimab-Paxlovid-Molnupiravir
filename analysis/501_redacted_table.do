********************************************************************************
*
*	Do-file:			redacted_table.do
*	Project:			Sotrovimab-Paxlovid-Molnupiravir
*   Date:  				25/07/23
*	Programmed by:		Katie Bechman
* 	Description:		data management, reformat variables, categorise variables, label variables 
*	Data used:			data in memory (from output/input.csv) 
*	Data created:		analysis main.dta  (main analysis dataset)
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
log using "$logdir/redacted_table.log", replace

*Set Ado file path
adopath + "$projectdir/analysis/ado"


*******************************************************************************************************************
** Main analysis  
**Baseline table redacted and rounded 
clear *
save "$projectdir/output/tables/baseline_table_redact_all.dta", replace emptyok
use "$projectdir/output/data/main", clear
set type double

** labeling 
foreach var of varlist downs_syndrome_comb solid_cancer_comb haem_disease_comb liver_disease_comb renal_disease_comb imid_on_drug_comb immunosuppression_comb hiv_aids_comb organ_transplant_comb rare_neuro_comb eligible dementia serious_mental_illness care_home diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease prior_covid paxlovid_contraindicated {
	recode `var' . = 0
	label define `var'  1 "yes" 0 "no", replace
	label values `var'  `var' 
}

foreach var of varlist pre_drug_test downs_syndrome_comb solid_cancer_comb haem_disease_comb liver_disease_comb renal_disease_comb imid_on_drug_comb immunosuppression_comb hiv_aids_comb organ_transplant_comb rare_neuro_comb eligible dementia serious_mental_illness care_home diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease prior_covid paxlovid_contraindicated prior_covid vaccination_status region_nhs imdq5 bmi_group  ethnicity sex age_group{ 
	preserve
	contract `var'	
	gen variable = `"`var'"'
	label variable `var' "`var'"	
	decode `var', gen(categories)
	gen count_mid_all  = (ceil(_freq/6)*6) - (floor(6/2) * (_freq!=0))
	egen total_mid_all = total(count)
	egen non_missing=sum(count) if categories!=""
	drop if categories==""
	gen percent_mid_all = round((count/non_missing)*100, 0.1)
	gen missing_mid_all=(total-non_missing)
	list variable `var' count percent total missing
	keep variable categories count percent total missing
	order variable categories count percent total missing
	append using "$projectdir/output/tables/baseline_table_redact_all.dta"
	save "$projectdir/output/tables/baseline_table_redact_all.dta", replace
	restore
}

use "$projectdir/output/tables/baseline_table_redact_all.dta", clear
export excel "$projectdir/output/tables/baseline_table_redact_bydrug.xls", replace sheet("overall") keepcellfmt firstrow(variables)

**Catergorical table by drug subdiagnoses - tagged to above excel
use "$projectdir/output/data/main", clear
decode drug, gen(drug_str)
local index=0
levelsof drug_str, local(levels)
foreach i of local levels {
	clear *
	save "$projectdir/output/tables/baseline_table_redact_`i'.dta", replace emptyok
	di `index'
	if `index'==0 {
		local col = word("`c(ALPHA)'", `index'+7)
	}
	else if `index'>0 & `index'<=22 {
	    local col = word("`c(ALPHA)'", `index'+5)
	}
	di "`col'"
	if `index'==0 {
		local `index++'
		local `index++'
		local `index++'
		local `index++'
		local `index++'
		local `index++'
	}
	else {
	    local `index++'
		local `index++'
		local `index++'
		local `index++'
	}
	di `index'

use "$projectdir/output/data/main", clear
decode drug, gen(drug_str)
foreach var of varlist downs_syndrome_comb solid_cancer_comb haem_disease_comb liver_disease_comb renal_disease_comb imid_on_drug_comb immunosuppression_comb hiv_aids_comb organ_transplant_comb rare_neuro_comb eligible dementia serious_mental_illness care_home diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease prior_covid paxlovid_contraindicated {
	recode `var' . = 0
	label define `var'  1 "yes" 0 "no", replace
	label values `var'  `var' 
}
foreach var of varlist pre_drug_test downs_syndrome_comb solid_cancer_comb haem_disease_comb liver_disease_comb renal_disease_comb imid_on_drug_comb immunosuppression_comb hiv_aids_comb organ_transplant_comb rare_neuro_comb eligible dementia serious_mental_illness care_home diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease prior_covid paxlovid_contraindicated  prior_covid vaccination_status region_nhs imdq5 bmi_group  ethnicity sex age_group{ 
	preserve
	keep if drug_str=="`i'"
	contract `var'	
	gen variable = `"`var'"'
	label variable `var' "`var'"	
	decode `var', gen(categories)
	gen count_mid_`i'  = (ceil(_freq/6)*6) - (floor(6/2) * (_freq!=0))
	egen total_mid_`i' = total(count)
	egen non_missing=sum(count) if categories!=""
	drop if categories==""
	gen percent_mid_`i' = round((count/non_missing)*100, 0.1)
	gen missing_mid_`i'=(total-non_missing)
	list `var' count percent total missing
	keep count percent total missing
	order(count), first
	append using "$projectdir/output/tables/baseline_table_redact_`i'.dta"
	save "$projectdir/output/tables/baseline_table_redact_`i'.dta", replace
	restore
}
display `index'
display "`col'"
use "$projectdir/output/tables/baseline_table_redact_`i'.dta", clear
export excel "$projectdir/output/tables/baseline_table_redact_bydrug.xls", sheet("Overall", modify) cell("`col'1") keepcellfmt firstrow(variables)
}
	
*Output tables as CSVs	
import excel "$projectdir/output/tables/baseline_table_redact_bydrug.xls", clear
export delimited using "$projectdir/output/tables/baseline_table_redact_bydrug.csv" , replace		
	
**2. Continous variables
clear *
save "$projectdir/output/tables/baseline_table_redact_mean.dta", replace emptyok
use "$projectdir/output/data/main", clear
decode drug, gen(drug_str)
foreach var of varlist age bmi {
	preserve
	collapse (count) "`var'_count"=`var' (mean) mean=`var' (sd) stdev=`var' (median) median=`var' (p25) p25=`var' (p75) p75=`var', by(drug_str)
	gen variable = "`var'"
	rename *count freq
	gen count_mid  = (ceil(freq/6)*6) - (floor(6/2) * (freq!=0))
	drop freq
    order variable drug_str count mean stdev median p25 p75
	list variable drug_str count mean stdev median p25 p75
	append using "$projectdir/output/tables/baseline_table_redact_mean.dta"
	save "$projectdir/output/tables/baseline_table_redact_mean.dta", replace
	restore
	preserve
	collapse (count) "`var'_count"=`var' (mean) mean=`var' (sd) stdev=`var' (median) median=`var' (p25) p25=`var' (p75) p75=`var'
	gen variable = "`var'"
	rename *count freq
	gen count_mid  = (ceil(freq/6)*6) - (floor(6/2) * (freq!=0))
	drop freq
	gen drug_str = "all"
    order variable drug_str count mean stdev median p25 p75
	list variable drug_str count mean stdev median p25 p75
	append using "$projectdir/output/tables/baseline_table_redact_mean.dta"
	save "$projectdir/output/tables/baseline_table_redact_mean.dta", replace
	restore
}	
use "$projectdir/output/tables/baseline_table_redact_mean.dta", clear
save "$projectdir/output/tables/baseline_table_redact_mean.dta", replace
export delimited using "$projectdir/output/tables/baseline_table_redact_mean.csv", replace		


*******************************************************************************************************************
** Sensitivity analysis  
**Baseline table redacted and rounded 
clear *
save "$projectdir/output/tables/baseline_table_redact_all_sens.dta", replace emptyok
use "$projectdir/output/data/sensitivity_analysis", clear
set type double
tab pre_drug_test drug
drop if  covid_test_5d!=1 & drug >0
tab pre_drug_test drug

** labeling 
foreach var of varlist downs_syndrome_comb solid_cancer_comb haem_disease_comb liver_disease_comb renal_disease_comb imid_on_drug_comb immunosuppression_comb hiv_aids_comb organ_transplant_comb rare_neuro_comb eligible dementia serious_mental_illness care_home diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease prior_covid paxlovid_contraindicated {
	recode `var' . = 0
	label define `var'  1 "yes" 0 "no", replace
	label values `var'  `var' 
}

foreach var of varlist pre_drug_test downs_syndrome_comb solid_cancer_comb haem_disease_comb liver_disease_comb renal_disease_comb imid_on_drug_comb immunosuppression_comb hiv_aids_comb organ_transplant_comb rare_neuro_comb eligible dementia serious_mental_illness care_home diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease prior_covid paxlovid_contraindicated prior_covid vaccination_status region_nhs imdq5 bmi_group  ethnicity sex age_group{ 
	preserve
	contract `var'	
	gen variable = `"`var'"'
	label variable `var' "`var'"	
	decode `var', gen(categories)
	gen count_mid_all  = (ceil(_freq/6)*6) - (floor(6/2) * (_freq!=0))
	egen total_mid_all = total(count)
	egen non_missing=sum(count) if categories!=""
	drop if categories==""
	gen percent_mid_all = round((count/non_missing)*100, 0.1)
	gen missing_mid_all=(total-non_missing)
	list variable `var' count percent total missing
	keep variable categories count percent total missing
	order variable categories count percent total missing
	append using "$projectdir/output/tables/baseline_table_redact_all_sens.dta"
	save "$projectdir/output/tables/baseline_table_redact_all_sens.dta", replace
	restore
}

use "$projectdir/output/tables/baseline_table_redact_all_sens.dta", clear
export excel "$projectdir/output/tables/baseline_table_redact_bydrug_sens.xls", replace sheet("overall") keepcellfmt firstrow(variables)

**Catergorical table by drug subdiagnoses - tagged to above excel
use "$projectdir/output/data/sensitivity_analysis", clear
tab pre_drug_test drug
drop if  covid_test_5d!=1 & drug >0
tab pre_drug_test drug
decode drug, gen(drug_str)
local index=0
levelsof drug_str, local(levels)
foreach i of local levels {
	clear *
	save "$projectdir/output/tables/baseline_table_redact_sens_`i'.dta", replace emptyok
	di `index'
	if `index'==0 {
		local col = word("`c(ALPHA)'", `index'+7)
	}
	else if `index'>0 & `index'<=22 {
	    local col = word("`c(ALPHA)'", `index'+5)
	}
	di "`col'"
	if `index'==0 {
		local `index++'
		local `index++'
		local `index++'
		local `index++'
		local `index++'
		local `index++'
	}
	else {
	    local `index++'
		local `index++'
		local `index++'
		local `index++'
	}
	di `index'

use "$projectdir/output/data/sensitivity_analysis", clear
tab pre_drug_test drug
drop if  covid_test_5d!=1 & drug >0
tab pre_drug_test drug
decode drug, gen(drug_str)
foreach var of varlist downs_syndrome_comb solid_cancer_comb haem_disease_comb liver_disease_comb renal_disease_comb imid_on_drug_comb immunosuppression_comb hiv_aids_comb organ_transplant_comb rare_neuro_comb eligible dementia serious_mental_illness care_home diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease prior_covid paxlovid_contraindicated {
	recode `var' . = 0
	label define `var'  1 "yes" 0 "no", replace
	label values `var'  `var' 
}
foreach var of varlist pre_drug_test downs_syndrome_comb solid_cancer_comb haem_disease_comb liver_disease_comb renal_disease_comb imid_on_drug_comb immunosuppression_comb hiv_aids_comb organ_transplant_comb rare_neuro_comb eligible dementia serious_mental_illness care_home diabetes chronic_cardiac_disease hypertension chronic_respiratory_disease prior_covid paxlovid_contraindicated prior_covid vaccination_status region_nhs imdq5 bmi_group  ethnicity sex age_group{ 
	preserve
	keep if drug_str=="`i'"
	contract `var'	
	gen variable = `"`var'"'
	label variable `var' "`var'"	
	decode `var', gen(categories)
	gen count_mid_`i'  = (ceil(_freq/6)*6) - (floor(6/2) * (_freq!=0))
	egen total_mid_`i' = total(count)
	egen non_missing=sum(count) if categories!=""
	drop if categories==""
	gen percent_mid_`i' = round((count/non_missing)*100, 0.1)
	gen missing_mid_`i'=(total-non_missing)
	list `var' count percent total missing
	keep count percent total missing
	order(count), first
	append using "$projectdir/output/tables/baseline_table_redact_sens_`i'.dta"
	save "$projectdir/output/tables/baseline_table_redact_sens_`i'.dta", replace
	restore
}
display `index'
display "`col'"
use "$projectdir/output/tables/baseline_table_redact_sens_`i'.dta", clear
export excel "$projectdir/output/tables/baseline_table_redact_bydrug_sens.xls", sheet("Overall", modify) cell("`col'1") keepcellfmt firstrow(variables)
}
	
*Output tables as CSVs	
import excel "$projectdir/output/tables/baseline_table_redact_bydrug_sens.xls", clear
export delimited using "$projectdir/output/tables/baseline_table_redact_bydrug_sens.csv" , replace		
	
**2. Continous variables
clear *
save "$projectdir/output/tables/baseline_table_redact_mean_sens.dta", replace emptyok
use "$projectdir/output/data/main", clear
decode drug, gen(drug_str)
foreach var of varlist age bmi {
	preserve
	collapse (count) "`var'_count"=`var' (mean) mean=`var' (sd) stdev=`var' (median) median=`var' (p25) p25=`var' (p75) p75=`var', by(drug_str)
	gen variable = "`var'"
	rename *count freq
	gen count_mid  = (ceil(freq/6)*6) - (floor(6/2) * (freq!=0))
	drop freq
    order variable drug_str count mean stdev median p25 p75
	list variable drug_str count mean stdev median p25 p75
	append using "$projectdir/output/tables/baseline_table_redact_mean_sens.dta"
	save "$projectdir/output/tables/baseline_table_redact_mean_sens.dta", replace
	restore
	preserve
	collapse (count) "`var'_count"=`var' (mean) mean=`var' (sd) stdev=`var' (median) median=`var' (p25) p25=`var' (p75) p75=`var'
	gen variable = "`var'"
	rename *count freq
	gen count_mid  = (ceil(freq/6)*6) - (floor(6/2) * (freq!=0))
	drop freq
	gen drug_str = "all"
    order variable drug_str count mean stdev median p25 p75
	list variable drug_str count mean stdev median p25 p75
	append using "$projectdir/output/tables/baseline_table_redact_mean_sens.dta"
	save "$projectdir/output/tables/baseline_table_redact_mean_sens.dta", replace
	restore
}	
use "$projectdir/output/tables/baseline_table_redact_mean_sens.dta", clear
save "$projectdir/output/tables/baseline_table_redact_mean_sens.dta", replace
export delimited using "$projectdir/output/tables/baseline_table_redact_mean_sens.csv", replace	



log close







