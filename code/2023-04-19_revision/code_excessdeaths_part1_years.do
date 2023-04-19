


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


Data available from: https://wonder.cdc.gov/controller/saved/D76/D330F175 [reference]

Query Criteria:
Title:	age_adjusted_deaths_race_gender_year_se
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

Reference: Centers for Disease Control and Prevention, National Center for Health Statistics. National Vital Statistics System, Mortality 1999-2020 on CDC WONDER Online Database, released in 2021. Data are from the Multiple Cause of Death Files, 1999-2020, as compiled from data provided by the 57 vital statistics jurisdictions through the Vital Statistics Cooperative Program. Accessed at http://wonder.cdc.gov/ucd-icd10.html on Mar 16, 2023 12:34:43 PM

––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
*/

**# Part 1: excess mortality RATES 


clear all
cd /Users/cesarcc/Documents/Research/CDC_Wonder/code/2023-02-17_R1


import delimited "export_age_adjusted_deaths_race_gender_year_se.txt" // file from the CDC site above

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


rename cruderatelower95confidenceinterv cruderate_ci_lb
rename cruderateupper95confidenceinterv cruderate_ci_ub
rename cruderatestandarderror cruderate_se
 
rename ageadjustedratelower95confidence ageadjustedrate_ci_lb
rename ageadjustedrateupper95confidence ageadjustedrate_ci_ub
rename ageadjustedratestandarderror ageadjustedrate_se

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
gen ageadj_deaths_black_ci_lb=ageadjustedrate_ci_lb
gen ageadj_deaths_black_ci_ub=ageadjustedrate_ci_ub
gen ageadj_deaths_black_se=ageadjustedrate_se

save file2,replace

u file1,clear

keep if race==3
gen population_white=population
gen cruderate_white=cruderate
gen deaths_white=deaths
gen ageadj_deaths_white=ageadjustedrate
gen ageadj_deaths_white_ci_lb=ageadjustedrate_ci_lb
gen ageadj_deaths_white_ci_ub=ageadjustedrate_ci_ub
gen ageadj_deaths_white_se=ageadjustedrate_se

keep gender population_white deaths_white cruderate_white ageadj_deaths_* year

save file3,replace

u file2,clear

merge 1:1 gender year using file3,update
drop if _merge==2
drop _merge

local zcrit=invnorm(.975)

     gen diff_black = (ageadj_deaths_black - ageadj_deaths_white)     
     gen diff_black_SE = sqrt(ageadj_deaths_black_se^2 + ageadj_deaths_white_se^2)
     gen diff_black_lb = diff_black - (diff_black_SE * `zcrit')
     gen diff_black_ub = diff_black + (diff_black_SE * `zcrit')
	 
gen adj_excess_deaths_rate = ageadj_deaths_black - ageadj_deaths_white // variable used for figures only
gen ratio_adj_excess_deaths_rate = ageadj_deaths_black / ageadj_deaths_white // variable used for figures only
					
save file_excess_deaths_year_figure,replace


********************************************************************************
********************************************************************************
********************************************************************************

**# 						TRENDS ANALYSIS

********************************************************************************
********************************************************************************
********************************************************************************

**# TRENDS AMONG WOMEN
* BREAK POINTS: 2015. Change from 2019 to 2020 analyzed separately.

u file_excess_deaths_year_figure,clear
keep if gender==1 

foreach K in 1999 2015 2019 2020 {
	
	list diff_black diff_black_lb diff_black_ub if year==`K'

}

drop if year==2020

mkspline year1 2015 year2  = year
tsset year
arima diff_black year1 year2, ar(1) nolog

predict predy1, xb
predict predy2_women, y
keep year gender predy2_women

save tempfile_women,replace

* Excess Age-adjusted rate change from 2019 to 2020
u file_excess_deaths_year_figure,clear
keep if gender==1 
keep if inlist(year,2019,2020)
sort year

local zcrit=invnorm(.975)

qui {
    local diff_1 = ageadj_deaths_black[1] - ageadj_deaths_white[1]         
    local diff_2 = ageadj_deaths_black[2] - ageadj_deaths_white[2]          
    local did=`diff_2'-`diff_1'
    local SE_1= sqrt(ageadj_deaths_black_se[1]^2 + ageadj_deaths_white_se[1]^2) 
    local SE_2= sqrt(ageadj_deaths_black_se[2]^2 + ageadj_deaths_white_se[2]^2)
    local SE_did=sqrt(`SE_2'^2+`SE_1'^2)
    local lb=`did'-`zcrit'*`SE_did'
    local ub=`did'+`zcrit'*`SE_did'
    local Pval=2*(1-normal(abs(`did'/`SE_did')))
    local Pval=cond(`Pval'<0.001,"<0.001",string(`Pval',"%5.3f"))
    noi di "`R'" _col(20) %7.2f `did' _col(30) "(" %7.2f `lb' "," %7.2f `ub' ")" _col(50) "`Pval'"

}


**# TRENDS AMONG MEN
* BREAK POINTS: 2007, 2011. Change from 2019 to 2020 analyzed separately.

u file_excess_deaths_year_figure,clear
keep if gender==3

foreach K in 1999 2007 2011 2019 2020 {
	
	list diff_black diff_black_lb diff_black_ub if year==`K'

}

drop if year==2020

mkspline year1 2007 year2 2011 year3 = year
tsset year
arima diff_black year1 year2 year3 , ar(1) nolog

predict predy1, xb
predict predy2_men, y
keep year gender predy2_men

save tempfile_men,replace

* change from 2019 to 2020

u file_excess_deaths_year_figure,clear
keep if gender==3

keep if inlist(year,2019,2020)
sort year

local zcrit=invnorm(.975)

qui {
    local diff_1 = ageadj_deaths_black[1] - ageadj_deaths_white[1]         
    local diff_2 = ageadj_deaths_black[2] - ageadj_deaths_white[2]          
    local did=`diff_2'-`diff_1'
    local SE_1= sqrt(ageadj_deaths_black_se[1]^2 + ageadj_deaths_white_se[1]^2) 
    local SE_2= sqrt(ageadj_deaths_black_se[2]^2 + ageadj_deaths_white_se[2]^2)
    local SE_did=sqrt(`SE_2'^2+`SE_1'^2)
    local lb=`did'-`zcrit'*`SE_did'
    local ub=`did'+`zcrit'*`SE_did'
    local Pval=2*(1-normal(abs(`did'/`SE_did')))
    local Pval=cond(`Pval'<0.001,"<0.001",string(`Pval',"%5.3f"))
    noi di "`R'" _col(20) %7.2f `did' _col(30) "(" %7.2f `lb' "," %7.2f `ub' ")" _col(50) "`Pval'"

}

**# Mean mortality rates

u file_excess_deaths_year_figure,clear

collapse (mean) diff_black (mean) ageadj_deaths_black (mean) ageadj_deaths_white, by(gender)
list


********************************************************************************
********************************************************************************
********************************************************************************
********************************************************************************
********************************************************************************

**# PART 2: Excess mortality in NUMBER of deaths

/*

––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––

					Excess Mortality Among Black people in NUMBER OF DEATHS

							Part 1: by year
							
 CALCULATION METHOD BASED ON https://doi.org/10.2105/AJPH.98.Supplement_1.S26

––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––



Data available from: https://wonder.cdc.gov/controller/saved/D76/D326F962

Title:	export_deaths_race_gender_age_year
Gender:	Female; Male
Hispanic Origin:	Not Hispanic or Latino
Race:	Black or African American; White
Group By:	Race; Gender; Ten-Year Age Groups; Year
Show Totals:	False
Show Zero Values:	True
Show Suppressed:	True
Calculate Rates Per:	100,000
Rate Options:	Default intercensal populations for years 2001-2009 (except Infant Age Groups))

––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
*/


clear all

import delimited "export_deaths_race_gender_age_year.txt" // file from the CDC site above

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

rename tenyearagegroups agegroup
drop if agegroup=="Not Stated"
drop if population=="Not Applicable"

destring deaths population cruderate,replace

drop if notes !="" // drops "total" and other empty rows
drop notes *code 	// drop unnecesary variables

save file1, replace

****

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

keep gender population_white deaths_white cruderate_white year agegroup

save file3,replace

u file2,clear

merge 1:1 gender year agegroup using file3,update
drop if _merge==2
drop _merge



gen expected_deaths_black = (population_black*(deaths_white/population_white)) // number of deaths had the crude mortality rate among Black people been the same than that of White population

gen age_specific_rate_ratio = (cruderate_black/cruderate_white)

collapse (sum) expected_deaths_black (sum) population_black (sum) deaths_black (sum) population_white (sum) deaths_white (mean) age_specific_rate_ratio, by(gender year)

gen observed_rate_black = (deaths_black/population_black) * 100000

gen observed_rate_white = (deaths_white/population_white) * 100000

gen expected_rate_black = (expected_deaths_black / population_black) * 100000

gen excess_rate_black = (observed_rate_black - expected_rate_black)

gen excess_deaths_black = (excess_rate * population_black) / 100000

gen observed_vs_expected_rate_ratio = (observed_rate_black/expected_rate_black)

save file_excess_deaths_year_figure_newmethod,replace

********************************************************************************
********************************************************************************
********************************************************************************


**# Total number of excess deaths_black

u file_excess_deaths_year_figure_newmethod,clear
collapse (sum) excess_deaths_black, by(gender) 

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
merge 1:1 gender year using tempfile_women, keepusing(predy2_women)
drop _merge
merge 1:1 gender year using tempfile_men, keepusing(predy2_men)
drop _merge

#delimit ;

twoway 
	(scatter adj_excess_deaths_rate year if gender==3 ,  msymbol(o) mcolor(maroon)) 
	(scatter adj_excess_deaths_rate year if gender==1,  msymbol(s) mcolor(navy))
	(line predy2_women year, lpattern(solid) lcolor(navy%50))
	(line predy2_men year, lpattern(solid) lcolor(maroon%50))
	(connected adj_excess_deaths_rate year if gender==3 & inrange(year,2019,2020), msymbol(o) mcolor(maroon) lpattern(dash) lcolor(maroon%50))
	(connected adj_excess_deaths_rate year if gender==1 & inrange(year,2019,2020), msymbol(s) mcolor(navy) lpattern(dash) lcolor(navy%50))
	(scatteri 314.7999 2007 (2) "†"
			  211.1 2011 (1) "‡"
			, msymbol(oh) msize(large) mcolor(maroon))
	(scatteri 86.90002 2015 (1) "¶"
			, msymbol(sh) msize(large) mcolor(navy))
	(scatteri 223.7 1999 (1) "‖"
			  403.9 1999 (2) "*"
			  209.7999 2019 (2) "§"
			  90.40002 2019 (2) "Δ"
			, msymbol(i))
	
	,
	
	xlabel(1999(1)2020) xtitle("Year", size(small))
	xlabel(, labsize(vsmall) angle(forty_five) valuelabel) 
	ylabel(-150(50)450, angle(horizontal) labsiz(vsmall)) 
	ytitle("Excess deaths per 100K individuals", size(small))
	ymtick(##2)
	yline(0, lpattern(dash) lcolor(gray))
	
	title("{fontface Merriweather Bold: Estimated Excess Adjusted Mortality Rate Among the Black Population}", size(small))
	subtitle("", size(small)) 
	legend(order(1 "Black Males" 2 "Black Females" 7 "Knot" 8 "Knot")
		size(small) position(5) ring(0) col(2)
		region(fcolor(white%30)) bmargin(small) 
		title(""))
	xsize(5) ysize(4)
	scheme(plotplainblind) 

	text(20 1999 "↑ Higher rates relative to White population", placement(e) justification(center) size(vsmall))
	text(-15 1999 "↓ Lower rates relative to White population", placement(e) justification(center) size(vsmall))
	;
	graph export figure_ageadjusted_excess_deaths_rate_by_year.jpg, as(jpg) name("Graph") quality(100) replace
	;
	graph export figure_ageadjusted_excess_deaths_rate_by_year.eps, as(eps) name("Graph") preview(off) replace
	;
	graph export Figure1_LeftPanel.eps, as(eps) name("Graph") preview(off) replace
	;
	graph export Figure1_LeftPanel.pdf, as(pdf) name("Graph") replace
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
	text(1.025 2000 "↑ Higher rates relative to White population", placement(e) justification(center) size(small))
	text(0.982 2000 "↓ Lower rates relative to White population", placement(e) justification(center) size(small))
	xsize(5) ysize(4)
	scheme(plotplainblind) 
	;
	graph export figure_ratio_excess_deaths_over_years_by_sex_100k.jpg, as(jpg) name("Graph") quality(100) replace
	;
#delimit cr

**# Figure: Age-adjusted deaths by race and sex, separately


u file_excess_deaths_year_figure,clear

#delimit ;

twoway 
	(line ageadj_deaths_black year if gender==3, lpattern(solid) lcolor(maroon) msymbol(o) mcolor(maroon))
	(line ageadj_deaths_black year if gender==1, lpattern(solid) lcolor(navy) msymbol(s) mcolor(navy))
	(line ageadj_deaths_white year if gender==3, lpattern(dash) lcolor(maroon) msymbol(o) mcolor(maroon))
	(line ageadj_deaths_white year if gender==1, lpattern(dash) lcolor(navy) msymbol(s) mcolor(navy)) 
	
	,
	xlabel(1999(1)2020) xtitle("Year", size(small))
	xlabel(, labsize(vsmall) angle(forty_five) valuelabel) 
	ylabel(0(200)1600, angle(horizontal) labsiz(vsmall)) 
	ytitle("Mortality rate, per 100K individuals", size(small))
	ymtick(##2)
	title("{fontface Merriweather Bold: Estimated Age-Adjusted Mortality Rate}", size(small))
	subtitle("", size(small)) 
	legend(order(1 "Black Males" 2 "Black Females" 3 "White Males" 4 "White Females" )
		size(small) position(5) ring(0) 
		region(fcolor(white%30)) bmargin(small) 
		title(""))
	xsize(5) ysize(4)
	scheme(plotplainblind) 
	;
	graph export figure_ageadjusted_deaths_over_years_by_race_and_sex_100k.jpg, as(jpg) name("Graph") quality(100) replace
	;
#delimit cr


**# Figure: mortality number

u file_excess_deaths_year_figure_newmethod,clear


#delimit ;

twoway 
	(connected excess_deaths_black year if gender==3, lpattern(solid) lcolor(maroon) msymbol(c) mcolor(maroon))
	(connected excess_deaths_black year if gender==1, lpattern(solid) lcolor(navy) msymbol(s) mcolor(navy)) 
	
	,
	xlabel(1999(1)2020) xtitle("Year", size(small))
	xlabel(, labsize(vsmall) angle(forty_five) valuelabel) 
	ylabel(0(10000)100000, angle(horizontal) labsiz(vsmall)) 
	ytitle("Number of Deaths", size(small))
	ymtick(##2)
	title("{fontface Merriweather Bold: Estimated Excess Deaths Among the Black Population}", size(small))
	subtitle("", size(small)) 
	legend(order(1 "Black Males" 2 "Black Females" )
		size(small) position(5) ring(0) 
		region(fcolor(white%30)) bmargin(small) 
		title("")) 
	xsize(5) ysize(4)
	scheme(plotplainblind) 
	;
	graph export figure_excess_deaths_over_years_by_sex.jpg, as(jpg) name("Graph") quality(100) replace
	;
#delimit cr

**# Figure: Cumulative mortality number

u file_excess_deaths_year_figure_newmethod,clear
 
bysort gender (year) : gen number_so_far = sum(excess_deaths_black)

replace number_so_far = number_so_far/1000

#delimit ;

twoway 
	(connected number_so_far year if gender==3, lpattern(solid) lcolor(maroon) msymbol(c) mcolor(maroon))
	(connected number_so_far year if gender==1, lpattern(solid) lcolor(navy) msymbol(s) mcolor(navy)) 

	,
	xlabel(1999(1)2020) xtitle("Year", size(small))
	xlabel(, labsize(vsmall) angle(forty_five) valuelabel) 
	ylabel(0(100)1200, angle(horizontal) labsiz(vsmall)) 
	ytitle("Excess Number of Deaths, thousands", size(small))
	ymtick(##2)
	title("{fontface Merriweather Bold: Estimated Cumulative Number of Excess Deaths Among the Black Population}", size(small))
	subtitle("", size(small)) 
	legend(order(1 "Black Males" 2 "Black Females" )
		size(small) position(5) ring(0) 
		region(fcolor(white%30)) bmargin(small) 
		title("")) 
	xsize(5) ysize(4)
	scheme(plotplainblind) 
	;
	graph export figure_cumulative_excess_deaths_over_years_by_sex.jpg, as(jpg) name("Graph") quality(100) replace
	;
#delimit cr

**# Figure: Sex combined annual number of deaths by year

u file_excess_deaths_year_figure_newmethod,clear
collapse (sum) excess_deaths_black , by(year) 

#delimit ;

twoway 
	(connected excess_deaths_black year)
	,
	xlabel(1999(1)2020) xtitle("Year", size(small))
	xlabel(, labsize(vsmall) angle(forty_five) valuelabel) 
	ylabel(0(10000)150000, angle(horizontal) labsiz(vsmall)) 
	ytitle("Number of Deaths", size(small))
	ymtick(##2)
	title("{fontface Merriweather Bold: Estimated Excess Deaths Among the Black Population}", size(vsmall))
	subtitle("{fontface Merriweather: Males and Females Combined}", size(vsmall))
	xsize(5) ysize(4)
	scheme(plotplainblind) 
	;
	graph export figure_excess_deaths_over_years_all.jpg, as(jpg) name("Graph") quality(100) replace
	;
#delimit cr

**# Figure: Sex combined cumulative number of deaths by year

u file_excess_deaths_year_figure_newmethod,clear
collapse (sum) excess_deaths_black , by(year) 
sort year
gen ind=1
bysort ind (year) : gen number_so_far = sum(excess_deaths_black)

replace number_so_far=number_so_far/1000

#delimit ;

twoway 
	(connected number_so_far year)

	,
	xlabel(1999(1)2020) xtitle("Year", size(small))
	xlabel(, labsize(vsmall) angle(forty_five) valuelabel) 
	ylabel(0(100)1800, angle(horizontal) labsiz(vsmall)) 
	ytitle("Excess Number of Deaths, thousands", size(small))
	ymtick(##2)
	title("{fontface Merriweather Bold: Estimated Cumulative Number of Excess Deaths Among the Black Population}", size(vsmall))
	subtitle("{fontface Merriweather: Males and Females Combined}", size(vsmall))
	xsize(5) ysize(4)
	scheme(plotplainblind) 
	;
	graph export figure_cumulative_excess_deaths_over_years_all.jpg, as(jpg) name("Graph") quality(100) replace
	;
#delimit cr



**# DISTRIBUTION OF EXCESS DEATHS BY AGE


clear all

import delimited "export_deaths_race_gender_age_year.txt" // file from the CDC site above

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

rename tenyearagegroups agegroup
drop if agegroup=="Not Stated"
drop if population=="Not Applicable"

replace agegroup="0" if agegroup=="< 1 year"
replace agegroup="1" if agegroup=="1-4 years"
replace agegroup="2" if agegroup=="5-14 years"
replace agegroup="3" if agegroup=="15-24 years"
replace agegroup="4" if agegroup=="25-34 years"
replace agegroup="5" if agegroup=="35-44 years"
replace agegroup="6" if agegroup=="45-54 years"
replace agegroup="7" if agegroup=="55-64 years"
replace agegroup="8" if agegroup=="65-74 years"
replace agegroup="9" if agegroup=="75-84 years"
replace agegroup="10" if agegroup=="85+ years"
destring agegroup, replace
label var agegroup "Ten-Year Age Groups"
label define agegroup_lbl 0 "< 1 year" 1 "1-4 years" 2 "5-14 years" 3 "15-24 years" 4 "25-34 years" 5 "35-44 years" 6 "45-54 years" 7 "55-64 years" 8 "65-74 years" 9 "75-84 years" 10 "85+ years"
label values agegroup agegroup_lbl


destring deaths population cruderate,replace

drop if notes !="" // drops "total" and other empty rows
drop notes *code 	// drop unnecesary variables

save file1, replace

****

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

keep gender population_white deaths_white cruderate_white year agegroup

save file3,replace

u file2,clear

merge 1:1 gender year agegroup using file3,update
drop if _merge==2
drop _merge

gen expected_deaths_black = (population_black*(deaths_white/population_white)) 

gen age_specific_rate_ratio = (cruderate_black/cruderate_white)

gen observed_rate_black = (deaths_black/population_black)* 100000

gen observed_rate_white = (deaths_white/population_white)* 100000

gen expected_rate_black = (expected_deaths_black / population_black) * 100000

gen excess_rate_black = (observed_rate_black - expected_rate_black)

gen excess_deaths_black = (excess_rate * population_black) / 100000

gen observed_vs_expected_rate_ratio = (observed_rate_black/expected_rate_black)

collapse (sum) excess_deaths_black (sum) expected_deaths_black (sum) population_black (sum) deaths_black (sum) population_white (sum) deaths_white (mean) age_specific_rate_ratio (mean) observed_rate_black (mean) observed_rate_white, by(gender agegroup)


twoway dropline excess_deaths_black agegroup, by(gender) scheme(plottig) ytitle("Excess deaths, number") ylabel(-75000(25000)275000) xlabel(0(1)10, valuelabel angle(45)) yline(0, lcolor(black))
graph save "Graph" "figure_distribution_deaths_Age.gph", replace
graph export "figure_distribution_deaths_Age.jpg", as(jpg) name("Graph") quality(100) replace

gen percent=.
replace percent=(excess_deaths_black/628464)*100 if gender==1
replace percent=(excess_deaths_black/997623)*100 if gender==3
label var percent "Percent of total excess deaths"

twoway dropline percent agegroup, by(gender) scheme(plottig) ytitle("Excess deaths, percent of total") ylabel(-15(5)30) xlabel(0(1)10, valuelabel angle(45)) yline(0, lcolor(black))
graph save "Graph" "figure_distribution_deaths_Age_percent.gph", replace
graph export "figure_distribution_deaths_Age_percent.jpg", as(jpg) name("Graph") quality(100) replace





