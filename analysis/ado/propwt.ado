program propwt, rclass byable(onecall)

*! $Revision: 2.0.0
*! Author:    Mark Lunt & Ariel Linden
*! Date:      September 29, 2017 @ 15:58:11

version 8.2

syntax varlist [if] [in], [IPT ATT ATC ALT SMR OVErlap MATching ALL gen(string) noSCaled  ///
			LP ]

   foreach opt in ipt att atc alt smr overlap matching all gen scaled lp {
		if "``opt''" != "" {
			local tuoptions `tuoptions'`opt',
		}
	}
	
  capture trackuse , progname("propwt") av("2.0.0") aid("NA") package("propensity")  ///
     options("`tuoptions'")
   if _rc != 0 {
      // trackuse failed: install latest version and retry
      capture net install ga_fragment, force replace from("http://personalpages.manchester.ac.uk/staff/mark.lunt")
      if _rc == 0 {
         capture trackuse , progname("propwt") av("2.0.0") aid("NA") package("propensity")  ///
           options("`tuoptions'")
      }
   }

   local by "`_byvars'"

	tokenize `varlist'
	local treat `1'
	macro shift
	local prop `1'

   if "`all'" != "" {
      local ipt ipt
      local att att
      local atc atc
      local alt alt
      local smr smr
      local overlap overlap
      local matching matching
   }
	if "`ipt'`att'`atc'`alt'`smr'`overlap'`matching'" == "" {
		local ipt ipt
	}
	
	if "`gen'" == "" {
		local gen _wt
	}

	marksample touse
	
	if "`lp'" ~= "" {
		tempvar p
		qui gen `p' = exp(`prop')/(1+exp(`prop')) if `touse'
		local prop `p'
	}


//	tab `treat' `mult'
// Check that given variables are sensible

//	qui tab `treat' if `touse'
	capture which isvar
	if (_rc == 111) {
		noi di as error "This command needs {cmd:isvar} to be installed"
		noi di as error `"Click {net "describe isvar, from(http://fmwww.bc.edu/RePEc/bocode/i)": here} to install it"'
	  exit 111
  }

	if "`ipt'" != "" {
		qui isvar ipt`gen'
		if "ipt`gen'" == "`r(varlist)'" {
			noi di in red "The variable ipt`gen' already exists: unable to proceed."
			exit 100
		}
		else {
			qui gen ipt`gen' = 1/`prop'  if `touse'
			qui replace ipt`gen' = 1/(1-`prop') if `treat' == 0 & `touse'
		}
	}

	if "`smr'" != "" {
		qui isvar smr`gen'
		if "smr`gen'" == "`r(varlist)'" {
			noi di in red "The variable smr`gen' already exists: unable to proceed."
			exit 100
		}
		else {
			qui gen smr`gen' = 1*`prop'/(1-`prop') if `touse'
			qui replace smr`gen' = 1 if `treat' == 1 & `touse'
		}
	}

	if "`att'" != "" {
		qui isvar att`gen'
		if "att`gen'" == "`r(varlist)'" {
			noi di in red "The variable att`gen' already exists: unable to proceed."
			exit 100
		}
		else {
			qui gen att`gen' = 1*`prop'/(1-`prop') if `touse'
			qui replace att`gen' = 1 if `treat' == 1 & `touse'
		}
	}

// gen atc =cond(tr,(1- propscore)/ propscore,1)

	if "`atc'" != "" {
		qui isvar atc`gen'
		if "atc`gen'" == "`r(varlist)'" {
			noi di in red "The variable atc`gen' already exists: unable to proceed."
			exit 100
		}
		else {
			qui gen atc`gen' = 1 if `touse'
			qui replace atc`gen' = (1-`prop')/`prop' if `treat' == 1 & `touse'
		}
	}

// gen alt =cond(tr,(1- propscore), propscore)

	if "`alt'" != "" {
		qui isvar alt`gen'
		if "alt`gen'" == "`r(varlist)'" {
			noi di in red "The variable alt`gen' already exists: unable to proceed."
			exit 100
		}
		else {
			qui gen alt`gen' = 1*`prop' if `touse'
			qui replace alt`gen' = 1-`prop' if `treat' == 1 & `touse'
		}
	}

	if "`overlap'" != "" {
		qui isvar overlap`gen'
		if "overlap`gen'" == "`r(varlist)'" {
			noi di in red "The variable overlap`gen' already exists: unable to proceed."
			exit 100
		}
		else {
			qui gen overlap`gen' = 1*(1-`prop') if `touse'
			qui replace overlap`gen' = 1*(`prop') if `treat' == 0 & `touse'
		}
	}

   if "`matching'" != "" {
		qui isvar matching`gen'
		if "matching`gen'" == "`r(varlist)'" {
			noi di in red "The variable matching`gen' already exists: unable to proceed."
			exit 100
		}
		else {
			qui gen matching`gen' = min(`prop', 1-`prop')/`prop'  if `touse'
			qui replace matching`gen' = min(`prop', 1-`prop')/(1-`prop') if `treat' == 0 & `touse'
		}
      
   }

	if "`scaled'" == "" {
      foreach pre in `ipt' `att' `atc' `alt' `smr' `overlap' `matching' {
         tempvar mean`pre'
         bys `by' `treat': egen `mean`pre'' = mean(`pre'`gen')
         qui replace `pre'`gen' = `pre'`gen'/`mean`pre''
      }	
	}


	noi di as text _n "The following variables were generated:" _cont
	foreach wt in `smr' `ipt' `att' `atc' `alt' `overlap' `matching' {
		noi di as result " `wt'`gen'" _cont
	}
	noi di as text "." _n

end
