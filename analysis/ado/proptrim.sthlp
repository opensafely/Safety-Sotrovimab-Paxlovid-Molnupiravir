{smcl}
{hline}
help for {hi:proptrim}
{hline}

{title:Propensity score trimming}

{p 4 8 2}
{cmdab:proptrim}
{it:treatvar}
{it:matchvar}
[{cmd:if} {it:exp}]
[{cmd:in} {it:range}]
[{cmd:,}
  {opt keep(varname)}
  {opt pctiles(numlist)}
  ]

{title:Description}

{pstd}
The command {cmd:proptrim} creates indicator variables to select which
subjects are included in a propensity analysis. By default, all
treated subjects ({it:treatvar} = 1) with propensity scores
({it:propvar}) higher than the highest propensity score in the
untreated, and all untreated subjects with a propensity score lower
than the lowest propensity score in the treated subjects. An {it:x}%
trimming will remove all subjects with propensity scores higher than
the (100-{it:x})th centile the {it:untreated}, and all subjects with a
propensity score lower than the {it:x}th centile in the {it:treated}
subjects. This may remove far more than 2{it:x}% of the sample, if
there is little overlap between treated and untreated subjects.

{title:Options}

{phang}
{opt pctiles(numlist)} A list of numbers representing the centiles at which
trimming will occur. For each {it:x} in the list, A variable called
{cmd:keep_}{it:x} will be created, containing 1 for those subjects with
propensity scores between the {it:x}th centile in the treated and the
(100-{it:x})th centile in the untreated.

{phang}
{opt keep(varname)} If this option is given, {cmd:proptrim} will generate
new variables called {it:varname_x}, rather than {cmd:keep_}{it:x}.

{title:Remarks}

{pstd}
Numbers containing decimal points can be passed to {opt pctiles}: the points
will be changed to underscores in the new variables created.

{title:Analytics}

{pstd}
In order to demonstrate to the University and our funders that the time
spent working on this program was worthwhile, we would like to
track of the number of installations and the number of times it is
used. To achieve this, you will be asked, the first time you run
{cmd:proptrim}, if you mind sending some usage information to Google
Analytics. If you agree, we will be informed that an installation has
taken place, and that {cmd:proptrim} has been run. 

{pstd}
Each time {cmd:proptrim} runs, it checks if you have agreed to send
data to google, and if you have then it will record the fact that the
program has been run. We will also receive some information about the
rough geographical area in which it was run, and if you have agreed to
this, the options with which it was run (but not the variable names,
since that could be viewed as potentially confidential information). 

{pstd}
{bf Opting out:} It would help us greatly to dedicate time to this program 
if we could show that it was widely used, but {cmd:proptrim} will respect your
desire for privacy if you request it. If you agree initially to
sending analytics information and then change your mind, you can set
the top line of {cmd:propensity.conf} in your ado file directory from
"analytics : 1" to "analytics : 0" and no further data will be
sent. Alternatively, the command {cmd:trackuse propensity} will enable
you to change any of the tracking options without needing to edit any
files (for more information see {help trackuse:trackuse for users}). 

{title:Author}

{p 4 4 2}
Mark Lunt, Arthritis Research UK Epidemiology Unit

{p 4 4 2}
The University of Manchester

{p 4 4 2}
Please email {browse "mailto:mark.lunt@manchester.ac.uk":mark.lunt@manchester.ac.uk} if you encounter problems with this program

