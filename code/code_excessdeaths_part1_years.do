
/*

––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––

					Excess Mortality Among Black people

							Part 1: by year

––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––

Important note:  age-adjusted mortality rates were used for this calculation. 
For other calculations (age-specific excess deaths and years of potential life 
lost), crude rates were used instead.


Data available from: https://wonder.cdc.gov/controller/saved/D76/D288F830 [reference]

Query Criteria:
Title:	age_adjusted_deaths_race_gender_year
Gender:	Female; Male
Hispanic Origin:	Not Hispanic or Latino
Race:	Black or African American; White
Group By:	Race; Gender; Year
Show Totals:	False
Show Zero Values:	False
Show Suppressed:	False
Standard Population:	2000 U.S. Std. Population
Calculate Rates Per:	100,000
Rate Options:	Default intercensal populations for years 2001-2009 (except Infant Age Groups)

Reference: Centers for Disease Control and Prevention, National Center for Health Statistics. Underlying Cause of Death 1999-2020 on CDC WONDER Online Database, released in 2021. Data are from the Multiple Cause of Death Files, 1999-2020, as compiled from data provided by the 57 vital statistics jurisdictions through the Vital Statistics Cooperative Program. Accessed at http://wonder.cdc.gov/ucd-icd10.html on Apr 28, 2022 10:48:42 AM

––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
*/


clear all

import delimited "export_age_adjusted_deaths_race_gender_year.txt" // file from the CDC site above

replace gender="1" if gender=="Female"
replace gender="3" if gender=="Male"
destring gender,replace
label var gender "Gender"
label define gender_lbl 1 "Female" 3 "Male"
label values gender gender_lbl

replace race="1" if race=="Black or African American"
replace race="3" if race=="White"
destring race,replace
label var race "Race"
label define race_lbl 1 "Black" 3 "White"
label values race race_lbl

drop if notes !="" // drops "total" and other empty rows
drop notes *code 	// drop unnecesary variables

save file1, replace

****

u file1,clear

keep if race==1
gen population_black=population 
gen cruderate_black=cruderate
gen deaths_black=deaths  
gen ageadj_deaths_black=ageadjustedrate 

save file2,replace

u file1,clear

keep if race==3
gen population_white=population
gen cruderate_white=cruderate
gen deaths_white=deaths
gen ageadj_deaths_white=ageadjustedrate 

keep gender population_white deaths_white cruderate_white ageadj_deaths_white year

save file3,replace

u file2,clear

merge 1:1 gender year using file3,update
drop if _merge==2
drop _merge

gen unadj_excess_deaths_number = (deaths_black) - (population_black*(deaths_white/population_white)) // number of deaths had the crude mortality rate among Black people been the same than that of White people

gen unadj_excess_deaths_rate = cruderate_black - cruderate_white // crude mortality rate difference
gen adj_excess_deaths_rate = ageadj_deaths_black - ageadj_deaths_white // difference in excess adjusted mortality per 100K
gen ratio_adj_excess_deaths_rate = ageadj_deaths_black / ageadj_deaths_white 
gen adj_excess_deaths_number = (adj_excess_deaths_rate * population_black) / 100000

save file_excess_deaths_year_figure,replace



********************************************************************************
********************************************************************************
********************************************************************************

**# 						TRENDS ANALYSIS

********************************************************************************
********************************************************************************
********************************************************************************

**# TRENDS AMONG WOMEN
* BREAK POINTS: 2015, 2019

u file_excess_deaths_year_figure,clear
keep if gender==1
mkspline year1 2015 year2 2019 year3 = year
tsset year
arima adj_excess_deaths_rate year1 year2 year3, ar(1) nolog

**# TRENDS AMONG MEN
* BREAK POINTS: 2011, 2019

u file_excess_deaths_year_figure,clear
keep if gender==3
mkspline year1 2011 year2 2019 year3 = year
tsset year
arima adj_excess_deaths_rate year1 year2 year3, ar(1) nolog


**# Total number of excess deaths_black

u file_excess_deaths_year_figure,clear
collapse (sum) adj_excess_deaths_number, by(gender) 


********************************************************************************
********************************************************************************
********************************************************************************

**# 								FIGURES

* code below is to produce figures only

* These figures use Abel and Merriweather fonts
**** https://fonts.google.com/specimen/Abel
**** https://fonts.google.com/specimen/Merriweather

ssc install blindschemes 			// specific color schemes
graph set window fontface Abel		// font style

********************************************************************************
********************************************************************************
********************************************************************************


**# Figure: Age-adjusted mortality rate

u file_excess_deaths_year_figure,clear

#delimit ;

twoway 
	(connected adj_excess_deaths_rate year if gender==3, lpattern(solid) lcolor(maroon) msymbol(o) mcolor(maroon))
	(connected adj_excess_deaths_rate year if gender==1, lpattern(solid) lcolor(navy) msymbol(s) mcolor(navy)) 
	
	,
	xlabel(1999(1)2020) xtitle("Year", size(small))
	xlabel(, labsize(vsmall) angle(forty_five) valuelabel) 
	ylabel(-150(50)450, angle(horizontal) labsiz(vsmall)) 
	ytitle("Excess deaths per 100K individuals", size(small))
	ymtick(##2)
	yline(0, lpattern(dash) lcolor(gray))
	title("{fontface Merriweather Bold: Estimated Excess Adjusted Mortality Rate Among Black People}", size(small))
	subtitle("", size(small)) 
	legend(order(1 "Black Males" 2 "Black Females" )
		size(small) position(5) ring(0) 
		region(fcolor(white%30)) bmargin(small) 
		title(""))
	text(20 2000 "↑ Higher rates relative to White people", placement(e) justification(center) size(small))
	text(-15 2000 "↓ Lower rates relative to White people", placement(e) justification(center) size(small))
	xsize(5) ysize(4)
	scheme(plotplainblind) 
	;
	graph export figure_ageadjusted_excess_deaths_over_years_by_sex_100k.jpg, as(jpg) name("Graph") quality(100) replace
	;
#delimit cr


**# Figure: Age-adjusted mortality rate RATIO

u file_excess_deaths_year_figure,clear

#delimit ;

twoway 
	(connected ratio_adj_excess_deaths_rate year if gender==3, lpattern(solid) lcolor(maroon) msymbol(o) mcolor(maroon))
	(connected ratio_adj_excess_deaths_rate year if gender==1, lpattern(solid) lcolor(navy) msymbol(s) mcolor(navy)) 
	
	,
	xlabel(1999(1)2020) xtitle("Year", size(small))
	xlabel(, labsize(vsmall) angle(forty_five) valuelabel) 
	ylabel(0.85(0.05)1.5, angle(horizontal) labsiz(vsmall)) 
	ytitle("Mortality rate ratio", size(small))
	ymtick(##2)
	yline(1, lpattern(dash) lcolor(gray))
	title("{fontface Merriweather Bold: Black-White Age-Adjusted Mortality Rate Ratio}", size(small))
	subtitle("", size(small)) 
	legend(order(1 "Males" 2 "Females" )
		size(small) position(5) ring(0) 
		region(fcolor(white%30)) bmargin(small) 
		title("")) 
	text(1.025 2000 "↑ Higher rates relative to White people", placement(e) justification(center) size(small))
	text(0.982 2000 "↓ Lower rates relative to White people", placement(e) justification(center) size(small))
	xsize(5) ysize(4)
	scheme(plotplainblind) 
	;
	graph export figure_ratio_excess_deaths_over_years_by_sex_100k.jpg, as(jpg) name("Graph") quality(100) replace
	;
#delimit cr


**# Figure: Age-adjusted mortality number

u file_excess_deaths_year_figure,clear


#delimit ;

twoway 
	(connected adj_excess_deaths_number year if gender==3, lpattern(solid) lcolor(maroon) msymbol(c) mcolor(maroon))
	(connected adj_excess_deaths_number year if gender==1, lpattern(solid) lcolor(navy) msymbol(s) mcolor(navy)) 
	
	,
	xlabel(1999(1)2020) xtitle("Year", size(small))
	xlabel(, labsize(vsmall) angle(forty_five) valuelabel) 
	ylabel(0(10000)100000, angle(horizontal) labsiz(vsmall)) 
	ytitle("Number of Deaths", size(small))
	ymtick(##2)
	title("{fontface Merriweather Bold: Estimated Excess Deaths Among Black People}", size(small))
	subtitle("", size(small)) 
	legend(order(1 "Black Males" 2 "Black Females" )
		size(small) position(5) ring(0) 
		region(fcolor(white%30)) bmargin(small) 
		title("")) 
	xsize(5) ysize(4)
	scheme(plotplainblind) 
	;
	graph export figure_ageadjusted_excess_deaths_over_years_by_sex.jpg, as(jpg) name("Graph") quality(100) replace
	;
#delimit cr
