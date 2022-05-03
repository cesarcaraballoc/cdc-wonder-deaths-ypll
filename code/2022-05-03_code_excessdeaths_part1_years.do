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


Data obtained from: https://wonder.cdc.gov/controller/saved/D76/D288F830

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

Centers for Disease Control and Prevention, National Center for Health Statistics. Underlying Cause of Death 1999-2020 on CDC WONDER Online Database, released in 2021. Data are from the Multiple Cause of Death Files, 1999-2020, as compiled from data provided by the 57 vital statistics jurisdictions through the Vital Statistics Cooperative Program. Accessed at http://wonder.cdc.gov/ucd-icd10.html on Apr 28, 2022 10:48:42 AM

––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
*/


clear all

import delimited "export_age_adjusted_deaths_race_gender_year.txt"

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

drop if notes !=""
drop notes *code

save file_1, replace

****

u file_1,clear

keep if race==1
gen population_black=population 
gen cruderate_black=cruderate
gen deaths_black=deaths  
gen ageadj_deaths_black=ageadjustedrate 

save file_2,replace

u file_1,clear

keep if race==3
gen population_white=population
gen cruderate_white=cruderate
gen deaths_white=deaths
gen ageadj_deaths_white=ageadjustedrate 

keep gender population_white deaths_white cruderate_white ageadj_deaths_white year

save file_3,replace

u file_2,clear

merge 1:1 gender year using file_3,update
drop if _merge==2
drop _merge

gen unadj_excess_deaths_number = (deaths_black) - (population_black*(deaths_white/population_white))

gen unadj_excess_deaths_rate = cruderate_black - cruderate_white

gen adj_excess_deaths_rate = ageadj_deaths_black - ageadj_deaths_white // per 100K

save file_excess_deaths_year_figure,replace

********************************************************************************
********************************************************************************
********************************************************************************

**# 								FIGURES

* These figures use Abel and Merriweather fonts
**** https://fonts.google.com/specimen/Abel
**** https://fonts.google.com/specimen/Merriweather

graph set window fontface Abel

********************************************************************************
********************************************************************************
********************************************************************************

**# Figure: Unadjusted mortality rate

u file_excess_deaths_year_figure,clear

collapse unadj_excess_deaths_rate, by (gender year) // mean because it is a rate??? confirm

#delimit ;

twoway 
	(connected unadj_excess_deaths_rate year if gender==3, lpattern(solid) lcolor(maroon) msymbol(c) mcolor(maroon))
	(connected unadj_excess_deaths_rate year if gender==1, lpattern(solid) lcolor(navy) msymbol(s) mcolor(navy)) 
	
	,
	xlabel(1999(1)2020) xtitle("Year", size(small))
	xlabel(, labsize(vsmall) angle(forty_five) valuelabel) 
	ylabel(-350(50)0, angle(horizontal) labsiz(vsmall)) ytitle("Deaths per 100K individuals", size(small))
	title("{fontface Merriweather Bold: Black People Unadjusted Mortality Rate Difference With White people}", size(small))
	subtitle("", size(small)) 
	legend(order(1 "Black Males" 2 "Black Females" )
		size(small) position(2) ring(0) 
		region(fcolor(white%30)) bmargin(small) 
		title("")) 
	xsize(5) ysize(4)
	scheme(plotplainblind) 
	;
	graph export figure_unadjusted_excess_deaths_over_years_by_sex_100k.jpg, as(jpg) name("Graph") quality(100) replace
	;
#delimit cr

**# Figure: Age-adjusted mortality rate

u file_excess_deaths_year_figure,clear

collapse adj_excess_deaths_rate, by (gender year)

#delimit ;

twoway 
	(connected adj_excess_deaths_rate year if gender==3, lpattern(solid) lcolor(maroon) msymbol(c) mcolor(maroon))
	(connected adj_excess_deaths_rate year if gender==1, lpattern(solid) lcolor(navy) msymbol(s) mcolor(navy)) 
	
	,
	xlabel(1999(1)2020) xtitle("Year", size(small))
	xlabel(, labsize(vsmall) angle(forty_five) valuelabel) 
	ylabel(0(50)450, angle(horizontal) labsiz(vsmall)) ytitle("Deaths per 100K individuals", size(small))
	title("{fontface Merriweather Bold: Black People Age-Adjusted Mortality Rate Difference With White People}", size(small))
	subtitle("", size(small)) 
	legend(order(1 "Black Males" 2 "Black Females" )
		size(small) position(5) ring(0) 
		region(fcolor(white%30)) bmargin(small) 
		title("")) 
	xsize(5) ysize(4)
	scheme(plotplainblind) 
	;
	graph export figure_ageadjusted_excess_deaths_over_years_by_sex_100k.jpg, as(jpg) name("Graph") quality(100) replace
	;
#delimit cr
