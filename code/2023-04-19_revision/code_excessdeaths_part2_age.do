

**# Part 2: by age only
/*
––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––

						Excess deaths among Black population

								Part 2: by age

––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––

Data is publicly available from: https://wonder.cdc.gov/controller/saved/D76/D288F831 [reference]

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

Reference: Centers for Disease Control and Prevention, National Center for Health Statistics. Underlying Cause of Death 1999-2020 on CDC WONDER Online Database, released in 2021. Data are from the Multiple Cause of Death Files, 1999-2020, as compiled from data provided by the 57 vital statistics jurisdictions through the Vital Statistics Cooperative Program. Accessed at http://wonder.cdc.gov/ucd-icd10.html on Apr 26, 2022 6:28:31 PM

––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
*/

clear all

import delimited "export_deaths_crude_race_gender_age.txt" // file from CDC site above

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

drop if notes !="" // drops unnecesary and empty rows
drop if race==. 

drop racecode gendercode singleyearages notes // unnecesary variables

rename singleyearagescode age

replace age="" if age=="NS"

destring age, replace // converting age to numeric

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

save file1,replace

********

u file1,clear

keep if race==1
gen population_black=population 
gen cruderate_black=cruderate
gen deaths_black=deaths  

save file2,replace

u file1,clear

keep if race==3
gen population_white=population
gen cruderate_white=cruderate
gen deaths_white=deaths 

keep gender population_white deaths_white cruderate_white age_cat

save file3,replace

u file2,clear

merge 1:1 gender age_cat using file3,update
drop if _merge==2
drop _merge

gen unadj_excess_deaths_number = (deaths_black) - (population_black*(deaths_white/population_white))
gen unadj_excess_deaths_rate = ((deaths_black/population_black)*100000) - ((deaths_white/population_white)*100000)
gen ratio_unadj_excess_deaths_rate = ((deaths_black/population_black)*100000) / ((deaths_white/population_white)*100000)


save file_excess_deaths_age_figure,replace




**# Part 2.1: by age and year group
/*
––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––

						Excess deaths among Black people

								Part 2.1: by age and year group

––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––

Group 1: 1999-2003


https://wonder.cdc.gov/controller/saved/D76/D326F896

Title:	deaths_crude_race_gender_age_99-03
Gender:	Female; Male
Hispanic Origin:	Not Hispanic or Latino
Race:	Black or African American; White
Year/Month:	1999; 2000; 2001; 2002; 2003
Group By:	Race; Gender; Single-Year Ages
Show Totals:	False
Show Zero Values:	False
Show Suppressed:	False
Calculate Rates Per:	100,000
Rate Options:	Default intercensal populations for years 2001-2009 (except Infant Age Groups)

****

Group 2: 2004-2008

https://wonder.cdc.gov/controller/saved/D76/D326F897

Title:	deaths_crude_race_gender_age_04-08
Gender:	Female; Male
Hispanic Origin:	Not Hispanic or Latino
Race:	Black or African American; White
Year/Month:	2004; 2005; 2006; 2007; 2008
Group By:	Race; Gender; Single-Year Ages
Show Totals:	False
Show Zero Values:	False
Show Suppressed:	False
Calculate Rates Per:	100,000
Rate Options:	Default intercensal populations for years 2001-2009 (except Infant Age Groups)

****

Group 3: 2009-2013

https://wonder.cdc.gov/controller/saved/D76/D326F898

Title:	deaths_crude_race_gender_age_09-13
Gender:	Female; Male
Hispanic Origin:	Not Hispanic or Latino
Race:	Black or African American; White
Year/Month:	2009; 2010; 2011; 2012; 2013
Group By:	Race; Gender; Single-Year Ages
Show Totals:	False
Show Zero Values:	False
Show Suppressed:	False
Calculate Rates Per:	100,000
Rate Options:	Default intercensal populations for years 2001-2009 (except Infant Age Groups)

****

Group 4: 2014-2018

https://wonder.cdc.gov/controller/saved/D76/D326F899

Title:	deaths_crude_race_gender_age_14-18
Gender:	Female; Male
Hispanic Origin:	Not Hispanic or Latino
Race:	Black or African American; White
Year/Month:	2014; 2015; 2016; 2017; 2018
Group By:	Race; Gender; Single-Year Ages
Show Totals:	False
Show Zero Values:	False
Show Suppressed:	False
Calculate Rates Per:	100,000
Rate Options:	Default intercensal populations for years 2001-2009 (except Infant Age Groups)

*** 

Group 5: 2019-2020

https://wonder.cdc.gov/controller/saved/D76/D326F900

Title:	deaths_crude_race_gender_age_19-20
Gender:	Female; Male
Hispanic Origin:	Not Hispanic or Latino
Race:	Black or African American; White
Year/Month:	2019; 2020
Group By:	Race; Gender; Single-Year Ages
Show Totals:	False
Show Zero Values:	False
Show Suppressed:	False
Calculate Rates Per:	100,000
Rate Options:	Default intercensal populations for years 2001-2009 (except Infant Age Groups)


––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
*/


foreach K in 99-03 04-08 09-13 14-18 19-20 {
	
clear all

import delimited deaths_crude_race_gender_age_`K'.txt // file from CDC site above

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

drop if notes !="" // drops unnecesary and empty rows
drop if race==. 

drop racecode gendercode singleyearages notes // unnecesary variables

rename singleyearagescode age

replace age="" if age=="NS"

destring age, replace // converting age to numeric

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

save file1,replace

********

u file1,clear

keep if race==1
gen population_black=population 
gen cruderate_black=cruderate
gen deaths_black=deaths  

save file2,replace

u file1,clear

keep if race==3
gen population_white=population
gen cruderate_white=cruderate
gen deaths_white=deaths 

keep gender population_white deaths_white cruderate_white age_cat

save file3,replace

u file2,clear

merge 1:1 gender age_cat using file3,update
drop if _merge==2
drop _merge

gen unadj_excess_deaths_number = (deaths_black) - (population_black*(deaths_white/population_white))
gen unadj_excess_deaths_rate = ((deaths_black/population_black)*100000) - ((deaths_white/population_white)*100000)
gen ratio_unadj_excess_deaths_rate = ((deaths_black/population_black)*100000) / ((deaths_white/population_white)*100000)

gen group="`K'"

save file_excess_deaths_age_figure_`K',replace
}

u  file_excess_deaths_age_figure_99-03,clear
append using file_excess_deaths_age_figure_04-08
append using file_excess_deaths_age_figure_09-13
append using file_excess_deaths_age_figure_14-18
append using file_excess_deaths_age_figure_19-20
save file_excess_deaths_age_by_yeargroup_figure, replace



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

**# Figure: excess mortality by age


u file_excess_deaths_age_figure,clear

#delimit ;

twoway 
	(connected unadj_excess_deaths_rate age_cat if gender==3, lpattern(solid) lcolor(maroon) msymbol(o) mcolor(maroon))
	(connected unadj_excess_deaths_rate age_cat if gender==1, lpattern(solid) lcolor(navy) msymbol(s) mcolor(navy)) 
	
	,
	 xtitle("Age group (years)", size(vsmall))
	xlabel(0(5)80, labsize(vsmall) angle(forty_five) valuelabel) 
	ylabel(-300(100)1400, angle(horizontal) labsize(vsmall)) 
	ymtick(##2)
	yline(0, lpattern(dash) lcolor(gray))
	ytitle("Excess deaths per 100K individuals", size(small))
	title("{fontface Merriweather Bold: Excess Mortality Rate Among the Black Population by Age}", size(small))
	legend(order(1 "Black Males" 2 "Black Females" )
		size(small) position(11) ring(0) 
		region(fcolor(white%30)) bmargin(small) 
		title("")) 
	text(50 50 "↑ Higher rates relative to White population", placement(e) justification(center) size(vsmall))
	text(-30 50 "↓ Lower rates relative to White population", placement(e) justification(center) size(vsmall))
	xsize(5) ysize(4)
	scheme(plotplainblind) 
	;
	graph export figure_excess_mortality_rate_by_age.jpg, as(jpg) name("Graph") quality(100) replace
	;
	graph export figure_excess_mortality_rate_by_age.eps, as(eps) name("Graph") preview(off) replace
	;
	graph export Figure3_LeftPanel.eps, as(eps) name("Graph") preview(off) replace
	;
#delimit cr


**# Figure: mortality rate ratio by age

u file_excess_deaths_age_figure,clear

#delimit ;

twoway 
	(connected ratio_unadj_excess_deaths_rate age_cat if gender==3, lpattern(solid) lcolor(maroon) msymbol(c) mcolor(maroon))
	(connected ratio_unadj_excess_deaths_rate age_cat if gender==1, lpattern(solid) lcolor(navy) msymbol(s) mcolor(navy)) 
	
	,
	 xtitle("Age group (years)", size(vsmall))
	xlabel(0(5)80, labsize(vsmall) angle(forty_five) valuelabel) 
	ylabel(0.7(0.1)2.5, angle(horizontal) labsize(vsmall)) 
	ymtick(##2)
	yline(1, lpattern(dash) lcolor(gray))
	ytitle("Mortality rate ratio", size(small))
	title("{fontface Merriweather Bold: Black-White Mortality Rate Ratio by Age}", size(small))
	legend(order(1 "Males" 2 "Females" )
		size(small) position(2) ring(0) 
		region(fcolor(white%30)) bmargin(small) 
		title("")) 
	text(1.05 50 "↑ Higher rates relative to White population", placement(e) justification(center) size(vsmall))
	text(0.97 50 "↓ Lower rates relative to White population", placement(e) justification(center) size(vsmall))
	xsize(5) ysize(4)
	scheme(plotplainblind) 
	;
	graph export figure_excess_mortality_rate_ratio_by_age.jpg, as(jpg) name("Graph") quality(100) replace	;
#delimit cr

**# Figure: excess mortality by age and 5-year period


u file_excess_deaths_age_by_yeargroup_figure,clear

keep if gender==3

#delimit ;

twoway 
	(connected unadj_excess_deaths_rate age_cat if group=="99-03", msymbol(O))
	(connected unadj_excess_deaths_rate age_cat if group=="04-08", msymbol(D)) 
	(connected unadj_excess_deaths_rate age_cat if group=="09-13", msymbol(T)) 
	(connected unadj_excess_deaths_rate age_cat if group=="14-18", msymbol(S)) 
	(connected unadj_excess_deaths_rate age_cat if group=="19-20", msymbol(Oh)) 
	
	,
	 xtitle("Age group (years)", size(vsmall))
	xlabel(0(5)80, labsize(vsmall) angle(forty_five) valuelabel) 
	ylabel(-300(100)1800, angle(horizontal) labsize(vsmall)) 
	ymtick(##2)
	yline(0, lpattern(dash) lcolor(gray))
	ytitle("Excess deaths per 100K individuals", size(small))
	title("{fontface Merriweather Bold: Excess Mortality Rate Among Black Males by Age}", size(small))
	legend(order(1 "1999-2003" 2 "2004-2008" 3 "2009-2013" 4 "2014-2018" 5 "2019-2020")
		size(small) position(11) ring(0) 
		region(fcolor(white%90)) bmargin(small) 
		title("")) 
	text(50 50 "↑ Higher rates relative to White population", placement(e) justification(center) size(vsmall))
	text(-30 50 "↓ Lower rates relative to White population", placement(e) justification(center) size(vsmall))
	xsize(5) ysize(4)
	scheme(plottig) 
	;
	graph export figure_excess_mortality_rate_by_age_and_years_males.jpg, as(jpg) name("Graph") quality(100) replace
	;
	graph export figure_excess_mortality_rate_by_age_and_years_males.eps, as(eps) name("Graph") preview(off) replace
	;
#delimit cr

******

u file_excess_deaths_age_by_yeargroup_figure,clear

keep if gender==1

#delimit ;

twoway 
	(connected unadj_excess_deaths_rate age_cat if group=="99-03", msymbol(O))
	(connected unadj_excess_deaths_rate age_cat if group=="04-08", msymbol(D)) 
	(connected unadj_excess_deaths_rate age_cat if group=="09-13", msymbol(T)) 
	(connected unadj_excess_deaths_rate age_cat if group=="14-18", msymbol(S)) 
	(connected unadj_excess_deaths_rate age_cat if group=="19-20", msymbol(Oh))
	
	,
	 xtitle("Age group (years)", size(vsmall))
	xlabel(0(5)80, labsize(vsmall) angle(forty_five) valuelabel) 
	ylabel(-300(100)1800, angle(horizontal) labsize(vsmall)) 
	ymtick(##2)
	yline(0, lpattern(dash) lcolor(gray))
	ytitle("Excess deaths per 100K individuals", size(small))
	title("{fontface Merriweather Bold: Excess Mortality Rate Among Black Females by Age}", size(small))
	legend(order(1 "1999-2003" 2 "2004-2008" 3 "2009-2013" 4 "2014-2018" 5 "2019-2020")
		size(small) position(11) ring(0) 
		region(fcolor(white%90)) bmargin(small) 
		title("")) 
	text(50 50 "↑ Higher rates relative to White population", placement(e) justification(center) size(vsmall))
	text(-30 50 "↓ Lower rates relative to White population", placement(e) justification(center) size(vsmall))
	xsize(5) ysize(4)
	scheme(plottig) 
	;
	graph export figure_excess_mortality_rate_by_age_and_years_females.jpg, as(jpg) name("Graph") quality(100) replace
	;
	graph export figure_excess_mortality_rate_by_age_and_years_females.eps, as(eps) name("Graph") preview(off) replace
	;
#delimit cr
