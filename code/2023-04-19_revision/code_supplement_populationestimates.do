
/*

Population estimates

FILE 1:

https://wonder.cdc.gov/controller/saved/D76/D326F697

Query Criteria:
Title:	export_population_estimates
Hispanic Origin:	Not Hispanic or Latino
Race:	Black or African American; White
Group By:	Race; Gender; Year
Show Totals:	True
Show Zero Values:	True
Show Suppressed:	True
Standard Population:	2000 U.S. Std. Population
Calculate Rates Per:	100,000
Rate Options:	Default intercensal populations for years 2001-2009 (except Infant Age Groups)

FILE 2:

https://wonder.cdc.gov/controller/saved/D76/D326F699

Title:	export_population_estimates_all
Group By:	Gender; Year
Show Totals:	True
Show Zero Values:	True
Show Suppressed:	True
Standard Population:	2000 U.S. Std. Population
Calculate Rates Per:	100,000
Rate Options:	Default intercensal populations for years 2001-2009 (except Infant Age Groups
*/

clear all

import delimited "export_population_estimates.txt"

drop if notes !=""
drop if race==""

drop yearcode racecode gendercode notes oftotaldeaths

save temp_file1,replace

*******

clear all

import delimited "export_population_estimates_all.txt"

drop if notes !=""

drop yearcode gendercode notes oftotaldeaths

save temp_file2,replace


******
clear all

import delimited "export_population_estimates_all.txt"

replace gender="1" if gender=="Female"
replace gender="3" if gender=="Male"
destring gender,replace
label var gender "Gender"
label define gender_lbl 1 "Female" 3 "Male"
label values gender gender_lbl

drop if notes !=""

drop yearcode gendercode notes oftotaldeaths

rename deaths deaths_all
rename population population_all
rename cruderate cruderate_all
rename ageadjustedrate ageadjustedrate_all

save temp_file3,replace

****

u temp_file1,clear
append using temp_file2

replace gender="1" if gender=="Female"
replace gender="3" if gender=="Male"
destring gender,replace
label var gender "Gender"
label define gender_lbl 1 "Female" 3 "Male"
label values gender gender_lbl

replace race="1" if race=="Black or African American"
replace race="3" if race=="White"
replace race="5" if race==""
destring race,replace
label var race "Race"
label define race_lbl 1 "NH Black" 3 "NH White" 5 "All"
label values race race_lbl

merge m:m gender year using temp_file3
drop _merge

gen pop_percent=(population/population_all)*100
label var pop_percent "% of same gender total US population"

label var population "Population size, n"

label var year "Year"

label var population_all "Total same-gender US population, n"
 
sort year gender race 

order year gender race  population population_all pop_percent

keep year gender race  population pop_percent population_all

save table_population_size,replace

u table_population_size, clear
keep if gender==1 & race!=5
export excel using table_population_size_females.xlsx, firstrow(varlabels) replace

u table_population_size, clear
keep if gender==3 & race!=5
export excel using table_population_size_males.xlsx, firstrow(varlabels) replace



