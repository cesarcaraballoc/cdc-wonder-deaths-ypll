


/*
––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––

			Excess Years of Potential Life Lost among Black people

							Part 1: by year

––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––

https://wonder.cdc.gov/controller/saved/D76/D288F925

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


Centers for Disease Control and Prevention, National Center for Health Statistics. Underlying Cause of Death 1999-2020 on CDC WONDER Online Database, released in 2021. Data are from the Multiple Cause of Death Files, 1999-2020, as compiled from data provided by the 57 vital statistics jurisdictions through the Vital Statistics Cooperative Program. Accessed at http://wonder.cdc.gov/ucd-icd10.html on Apr 27, 2022 12:49:58 PM

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
	
Please note that race categories changed in 2007 to include Hispanic ethnicity
	
––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
*/

clear all

import delimited "export_deaths_crude_race_gender_age_year.txt"

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
drop if race==.

drop yearcode racecode gendercode singleyearages notes

rename singleyearagescode age

replace age="" if age=="NS"

destring age,replace

drop if age>84 // no population for >85 y.o.

egen age_cat = cut(age), at(0,1,5,10,15,20,25,30,35,40,45,50,55,60,65,70,75,80,85) 

destring cruderate population,replace


collapse (sum) deaths (sum) population (mean) cruderate, by(race gender age_cat year) // to match the life expectancy estimates that are provided in 5-year groups

merge m:1 gender age_cat year using file_life_expectancy_1999_to_2020, keepusing(life_expectancy) // adding life expectancy column


drop _merge

* variable life expectancy is the average remaining years people would have lived if didn't die:

gen yrs_lost=life_expectancy*((deaths/population)*100000) // equal to multiplying life expectancy by cruderate

collapse (mean) yrs_lost , by(race gender year) // yrs_lost is a rate, then age_cat mean

save file_1,replace

u file_1,clear
keep if race==1
rename yrs_lost yrs_lost_black
save file_2,replace

u file_1,clear
keep if race==3
rename yrs_lost yrs_lost_white
save file_3,replace

u file_2,clear
merge 1:1 gender year using file_3
drop _merge

gen excess_yrs_lost = yrs_lost_black - yrs_lost_white


save file_excess_ypll_year_figure,replace

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


**# Excess YPLL by age and sex

u file_excess_ypll_year_figure,clear

#delimit ;

twoway 
	(connected excess_yrs_lost year if gender==3 , lpattern(solid) lcolor(maroon) msymbol(s) mcolor(maroon)) 
	(connected excess_yrs_lost year if gender==1, lpattern(solid) lcolor(navy) msymbol(c) mcolor(navy))
	
	,
	xlabel(1999(1)2020) xtitle("Year", size(small))
	xlabel(, labsize(vsmall) angle(forty_five) valuelabel) 
	ylabel(0(2000)16000, angle(horizontal) labsize(vsmall)) 
	ymtick(##2)
	ytitle("YPLL per 100K individuals", size(small))
	
	title("{fontface Merriweather Bold: Black People Years of Potential Life Lost Difference With White people}", size(small))
	subtitle("", size(small)) 
	legend(order(1 "Black Males" 2 "Black Females" )
		size(small) position(5) ring(0) 
		region(fcolor(white%30)) bmargin(small) 
		title("")) 
	xsize(5) ysize(4)
	scheme(plotplainblind) 
	;
	graph export figure_excess_ypll_per_100k_over_years_by_sex.jpg, as(jpg) name("Graph") quality(100) replace
	;
	
#delimit cr
