


/*
––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––

			Excess Years of Potential Life Lost among Black people

							Part 1: by year

––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––

Data available from: https://wonder.cdc.gov/controller/saved/D76/D288F925 [reference]

Query Criteria:
Title:	age_adjusted_deaths_race_gender_year
Gender:	Female; Male
Hispanic Origin:	Not Hispanic or Latino
Race:	Black or African American; White
Group By:	Race; Gender; Single-Year Ages; Year
Show Totals:	True
Show Zero Values:	False
Show Suppressed:	False
Calculate Rates Per:	100,000
Rate Options:	Default intercensal populations for years 2001-2009 (except Infant Age Groups)


Reference: Centers for Disease Control and Prevention, National Center for Health Statistics. Underlying Cause of Death 1999-2020 on CDC WONDER Online Database, released in 2021. Data are from the Multiple Cause of Death Files, 1999-2020, as compiled from data provided by the 57 vital statistics jurisdictions through the Vital Statistics Cooperative Program. Accessed at http://wonder.cdc.gov/ucd-icd10.html on Apr 27, 2022 12:49:58 PM

––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––

Life expectancy among White people was obtained from the following sources on March 16, 2022:

	- 2020: https://www.cdc.gov/nchs/data/vsrr/vsrr015-508.pdf
	- 2019: https://www.cdc.gov/nchs/data/nvsr/nvsr70/nvsr70-08-508.pdf
	- 2018: https://www.cdc.gov/nchs/data/nvsr/nvsr69/nvsr69-12-508.pdf
	- 2017: https://www.cdc.gov/nchs/data/nvsr/nvsr68/nvsr68_07-508.pdf
	- 2016: https://www.cdc.gov/nchs/data/nvsr/nvsr68/nvsr68_04-508.pdf
	- 2015: https://www.cdc.gov/nchs/data/nvsr/nvsr67/nvsr67_07-508.pdf
	- 2014: https://www.cdc.gov/nchs/data/nvsr/nvsr66/nvsr66_04.pdf
	- 2013: https://www.cdc.gov/nchs/data/nvsr/nvsr66/nvsr66_03.pdf
	- 2012: https://www.cdc.gov/nchs/data/nvsr/nvsr65/nvsr65_08.pdf
	- 2011: https://www.cdc.gov/nchs/data/nvsr/nvsr64/nvsr64_11.pdf
	- 2010: https://www.cdc.gov/nchs/data/nvsr/nvsr63/nvsr63_07.pdf
	- 2009: https://www.cdc.gov/nchs/data/nvsr/nvsr62/nvsr62_07.pdf
	- 2008: https://www.cdc.gov/nchs/data/nvsr/nvsr61/nvsr61_03.pdf
	- 2007: https://www.cdc.gov/nchs/data/nvsr/nvsr59/nvsr59_09.pdf
	- 2006: https://www.cdc.gov/nchs/data/nvsr/nvsr58/nvsr58_21.pdf
	- 2005: https://www.cdc.gov/nchs/data/nvsr/nvsr58/nvsr58_10.pdf
	- 2004: https://www.cdc.gov/nchs/data/nvsr/nvsr56/nvsr56_09.pdf
	- 2003: https://www.cdc.gov/nchs/data/nvsr/nvsr54/nvsr54_14.pdf
	- 2002: https://www.cdc.gov/nchs/data/nvsr/nvsr53/nvsr53_06.pdf
	- 2001: https://www.cdc.gov/nchs/data/nvsr/nvsr52/nvsr52_14.pdf
	- 2000: https://www.cdc.gov/nchs/data/nvsr/nvsr51/nvsr51_03.pdf
	- 1999: https://www.cdc.gov/nchs/data/nvsr/nvsr50/nvsr50_06.pdf
	
	See https://www.cdc.gov/nchs/products/life_tables.htm
	
	
––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
*/

clear all

import delimited "export_deaths_crude_race_gender_age_year.txt" // file from CDC site

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

drop if notes !="" // drops unnecessary and empty rows
drop if race==.

drop yearcode racecode gendercode singleyearages notes // drops unnecessary variables

rename singleyearagescode age

replace age="" if age=="NS"

destring age,replace

drop if age>84 // no population for >85 y.o.

egen age_cat = cut(age), at(0,1,5,10,15,20,25,30,35,40,45,50,55,60,65,70,75,80,85) // creates categorical variable for age, using specific cutoff points.

destring cruderate population,replace


collapse (sum) deaths (sum) population (mean) cruderate, by(race gender age_cat year) // to match the life expectancy estimates that are provided in 5-year groups

merge m:1 gender age_cat year using file_life_expectancy_1999_to_2020, keepusing(life_expectancy) // adding life expectancy column from file_life_expectancy_1999_to_2020 

drop _merge

* variable life expectancy is the average remaining years people would have lived if didn't die:

gen yrs_lost=life_expectancy*((deaths/population)*100000) 

collapse (mean) yrs_lost (sum) population , by(race gender year)

save file1,replace

u file1,clear
keep if race==1
rename yrs_lost yrs_lost_black 
rename population population_black
save file2,replace

u file1,clear
keep if race==3
rename yrs_lost yrs_lost_white
rename population population_white
save file3,replace

u file2,clear
merge 1:1 gender year using file3
drop _merge

gen excess_yrs_lost = yrs_lost_black - yrs_lost_white
gen ratio_excess_yrs_lost = yrs_lost_black / yrs_lost_white
gen exc_ypll_number = (excess_yrs_lost * population_black) / 100000

save file_excess_ypll_year_figure,replace

********************************************************************************
********************************************************************************
********************************************************************************

**# 						TRENDS ANALYSIS

********************************************************************************
********************************************************************************
********************************************************************************

**# TRENDS AMONG WOMEN
* BREAK POINTS: 2012, 2019

u file_excess_ypll_year_figure,clear
keep if gender==1
mkspline year1 2012 year2 2019 year3 = year
tsset year
arima excess_yrs_lost year1 year2 year3, ar(1) nolog

**# TRENDS AMONG MEN
* BREAK POINTS: 2011, 2019

u file_excess_ypll_year_figure,clear
keep if gender==3
mkspline year1 2011 year2 2019 year3 = year
tsset year
arima excess_yrs_lost year1 year2 year3, ar(1) nolog

**# cumulative number of YPLL

u file_excess_ypll_year_figure,clear
collapse (sum) exc_ypll_number, by(gender) 

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


**# Excess YPLL rate by age and sex

u file_excess_ypll_year_figure,clear

#delimit ;

twoway 
	(connected excess_yrs_lost year if gender==3 , lpattern(solid) lcolor(maroon) msymbol(o) mcolor(maroon)) 
	(connected excess_yrs_lost year if gender==1, lpattern(solid) lcolor(navy) msymbol(s) mcolor(navy))
	
	,
	xlabel(1999(1)2020) xtitle("Year", size(small))
	xlabel(, labsize(vsmall) angle(forty_five) valuelabel) 
	ylabel(-6000(2000)16000, angle(horizontal) labsize(vsmall)) 
	ymtick(##2)
	ytitle("Excess YPLL per 100K individuals", size(small))
	yline(0, lpattern(dash) lcolor(gray))
	
	title("{fontface Merriweather Bold: Estimated Excess Years of Potential Life Lost Rate Among Black People}", size(small))
	subtitle("", size(small)) 
	legend(order(1 "Black Males" 2 "Black Females" )
		size(small) position(5) ring(0) 
		region(fcolor(white%30)) bmargin(small) 
		title("")) 
	text(1000 2000 "↑ Higher rates relative to White people", placement(e) justification(center) size(small))
	text(-750 2000 "↓ Lower rates relative to White people", placement(e) justification(center) size(small))
	xsize(5) ysize(4)
	scheme(plotplainblind) 
	;
	graph export figure_excess_ypll_per_100k_over_years_by_sex.jpg, as(jpg) name("Graph") quality(100) replace
	;
	
#delimit cr




**# Excess YPLL rate RATIO by age and sex

u file_excess_ypll_year_figure,clear

#delimit ;

twoway 
	(connected ratio_excess_yrs_lost year if gender==3 , lpattern(solid) lcolor(maroon) msymbol(o) mcolor(maroon)) 
	(connected ratio_excess_yrs_lost year if gender==1, lpattern(solid) lcolor(navy) msymbol(s) mcolor(navy))
	
	,
	xlabel(1999(1)2020) xtitle("Year", size(small))
	xlabel(, labsize(vsmall) angle(forty_five) valuelabel) 
	ylabel(0.7(0.1)1.8, angle(horizontal) labsize(vsmall)) 
	ymtick(##2)
	ytitle("YPLL rate ratio", size(small))
	yline(1, lpattern(dash) lcolor(gray))
	
	title("{fontface Merriweather Bold: Black-White Years of Potential Life Lost Rate Ratio}", size(small))
	subtitle("", size(small)) 
	legend(order(1 "Males" 2 "Females" )
		size(small) position(5) ring(0) 
		region(fcolor(white%30)) bmargin(small) 
		title("")) 
	text(1.05 2000 "↑ Higher rates relative to White people", placement(e) justification(center) size(small))
	text(0.97 2000 "↓ Lower rates relative to White people", placement(e) justification(center) size(small))
	xsize(5) ysize(4)
	scheme(plotplainblind) 
	;
	graph export figure_ratio_excess_ypll_over_years_by_sex.jpg, as(jpg) name("Graph") quality(100) replace
	;
	
#delimit cr

**# Excess YPLL NUMBER by age and sex

u file_excess_ypll_year_figure,clear

#delimit ;

twoway 
	(connected exc_ypll_number year if gender==3 , lpattern(solid) lcolor(maroon) msymbol(s) mcolor(maroon)) 
	(connected exc_ypll_number year if gender==1, lpattern(solid) lcolor(navy) msymbol(c) mcolor(navy))
	
	,
	xlabel(1999(1)2020) xtitle("Year", size(small))
	xlabel(, labsize(vsmall) angle(forty_five) valuelabel) 
	ylabel(0(250000)3000000, angle(horizontal) labsize(vsmall)) 
	ymtick(##2)
	ytitle("YPLL", size(small))
	
	title("{fontface Merriweather Bold: Estimated Excess Years of Potential Life Lost Among Black People}", size(small))
	subtitle("", size(small)) 
	legend(order(1 "Black Males" 2 "Black Females" )
		size(small) position(5) ring(0) 
		region(fcolor(white%30)) bmargin(small) 
		title("")) 
	xsize(5) ysize(4)
	scheme(plotplainblind) 
	;
	graph export figure_excess_ypll_over_years_by_sex.jpg, as(jpg) name("Graph") quality(100) replace
	;
	
#delimit cr
