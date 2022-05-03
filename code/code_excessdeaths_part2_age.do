
/*
––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––

						Excess deaths among Black people

								Part 2: by age

––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––

Data is publicly available from: https://wonder.cdc.gov/controller/saved/D76/D288F831

Query Criteria:
Title:	deaths_crude_race_gender_age
Gender:	Female; Male
Hispanic Origin:	Not Hispanic or Latino
Race:	Black or African American; White
Group By:	Race; Gender; Single-Year Ages
Show Totals:	False
Show Zero Values:	False
Show Suppressed:	False
Calculate Rates Per:	100,000
Rate Options:	Default intercensal populations for years 2001-2009 (except Infant Age Groups)

Centers for Disease Control and Prevention, National Center for Health Statistics. Underlying Cause of Death 1999-2020 on CDC WONDER Online Database, released in 2021. Data are from the Multiple Cause of Death Files, 1999-2020, as compiled from data provided by the 57 vital statistics jurisdictions through the Vital Statistics Cooperative Program. Accessed at http://wonder.cdc.gov/ucd-icd10.html on Apr 26, 2022 6:28:31 PM

––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
*/



clear all

import delimited "export_deaths_crude_race_gender_age.txt"

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

drop racecode gendercode singleyearages notes

rename singleyearagescode age

replace age="" if age=="NS"

destring age,replace

drop if age>84 // no population for >85 y.o.

egen age_cat = cut(age), at(0,1,5,10,15,20,25,30,35,40,45,50,55,60,65,70,75,80,85) 

#delimit ;
label var age_cat "Age group (years)" ;
label define age_cat	0 "< 1" 1 "1-4" 5 "5-9" 
						10 "10-14" 15 "15-19" 20 "20-24" 
						25 "25-29" 30 "30-34" 35 "35-39"
						40 "40-44" 45 "45-49" 50 "50-54"
						55 "55-59" 60 "60-64" 65 "65-69"
						70 "70-74" 75 "75-79" 80 "80-84" 
						;

label value age_cat age_cat ;
#delimit cr

destring cruderate population,replace

collapse (sum) deaths (sum) population (mean) cruderate, by(race gender age_cat) 

save file_1,replace

********

u file_1,clear

keep if race==1
gen population_black=population 
gen cruderate_black=cruderate
gen deaths_black=deaths  

save file_2,replace

u file_1,clear

keep if race==3
gen population_white=population
gen cruderate_white=cruderate
gen deaths_white=deaths 

keep gender population_white deaths_white cruderate_white age_cat

save file_3,replace

u file_2,clear

merge 1:1 gender age_cat using file_3,update
drop if _merge==2
drop _merge

gen unadj_excess_deaths_number = (deaths_black) - (population_black*(deaths_white/population_white))


gen unadj_excess_deaths_rate = ((deaths_black/population_black)*100000) - ((deaths_white/population_white)*100000)

* above is equal to: gen unadj_excess_deaths_rate = cruderate_black - cruderate_white


save file_excess_deaths_age_figure,replace

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

**# Figure: excess mortality


u file_excess_deaths_age_figure,clear

#delimit ;

twoway 
	(connected unadj_excess_deaths_rate age_cat if gender==3, lpattern(solid) lcolor(maroon) msymbol(c) mcolor(maroon))
	(connected unadj_excess_deaths_rate age_cat if gender==1, lpattern(solid) lcolor(navy) msymbol(s) mcolor(navy)) 
	
	,
	 xtitle("Age group (years)", size(vsmall))
	xlabel(0(5)80, labsize(vsmall) angle(forty_five) valuelabel) 
	ylabel(-100(100)1400, angle(horizontal) labsize(vsmall)) 
	ymtick(##2)
	yline(0 -100, lstyle(grid))
	ytitle("Deaths per 100K", size(small))
	title("{fontface Merriweather Bold: Black People Mortality Rate Difference With White people}", size(small))
	subtitle("Cumulative from 1999 to 2020", size(small)) 
	legend(order(1 "Black Males" 2 "Black Females" )
		size(small) position(5) ring(0) 
		region(fcolor(white%30)) bmargin(small) 
		title("")) 
	xsize(5) ysize(4)
	scheme(plotplainblind) 
	;
	graph export figure_unadjusted_excess_deaths_over_age_by_sex_100k.jpg, as(jpg) name("Graph") quality(100) replace
	;
#delimit cr
