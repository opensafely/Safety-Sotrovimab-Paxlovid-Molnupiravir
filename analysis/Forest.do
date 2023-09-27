********************************************************************************
*
*	Do-file:			cox model forest 
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
global projectdir "C:\Users\k1635179\OneDrive - King's College London\Katie\OpenSafely\Safety mAB and antivirals\Safety-Sotrovimab-Paxlovid-Molnupiravir" 
// global projectdir `c(pwd)'
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


use "$projectdir/output/tables/cox_model_summary.dta", clear
gen hr_control = 0
gen lc_control = .
gen uc_control = .
keep if model=="adj"
reshape long hr_ uc_ lc_, i(failure model) j(drug) string
encode drug, generate(drug_num)
keep if failure=="ae_all"

twoway  (scatter drug_num hr_ if drug_num==4, mcolor(vermillion%70) msym(O)) /// 
		(rcap lc_ uc_ drug_num if drug_num==4, hor color(vermillion%70)) ///
		(scatter drug_num hr_ if drug_num==3, mcolor(green) msym(O)) /// 
		(rcap lc_ uc_ drug_num if drug_num==3, hor color(green%70)) ///
		(scatter drug_num hr_ if drug_num==2, mcolor(navy%70) msym(O)) /// 
		(rcap lc_ uc_ drug_num if drug_num==2, hor color(navy%70)) ///
		(scatter drug_num hr_ if drug_num==1, mcolor(gs10%70) msym(O)), ///
		ytitle("") ylab(1 "Control" 2 "Sotrovimab" 3 "Paxlovid" 4 "Molnupavir") xtitle(Hazard Ratio) xline(1) legend(off) 

		