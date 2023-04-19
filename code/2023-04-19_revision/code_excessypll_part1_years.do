


/*
––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––

			Excess Years of Potential Life Lost among Black people

							Part 1: by year

––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––

Data available from: https://wonder.cdc.gov/controller/saved/D76/D330F196 [reference]

Query Criteria:
Title:	age_deaths_race_gender_year_se
Gender:	Female; Male
Hispanic Origin:	Not Hispanic or Latino
Race:	Black or African American; White
Group By:	Race; Gender; Single-Year Ages; Year
Show Totals:	False
Show Zero Values:	False
Show Suppressed:	False
Calculate Rates Per:	100,000
Rate Options:	Default intercensal populations for years 2001-2009 (except Infant Age Groups)

Reference:
Centers for Disease Control and Prevention, National Center for Health Statistics. National Vital Statistics System, Mortality 1999-2020 on CDC WONDER Online Database, released in 2021. Data are from the Multiple Cause of Death Files, 1999-2020, as compiled from data provided by the 57 vital statistics jurisdictions through the Vital Statistics Cooperative Program. Accessed at http://wonder.cdc.gov/ucd-icd10.html on Mar 16, 2023 1:59:22 PM


––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––

Life expectancy among White Population was obtained from the following sources on March 16, 2022:

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

import delimited "export_age_deaths_race_gender_year_se.txt" // file from CDC site

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
rename cruderatelower95confidenceinterv cruderate_ci_lb
rename cruderateupper95confidenceinterv cruderate_ci_ub
rename cruderatestandarderror cruderate_se

replace age="" if age=="NS"

destring age,replace

drop if age>84 // no population for >85 y.o.


egen age_cat = cut(age), at(0,1,5,10,15,20,25,30,35,40,45,50,55,60,65,70,75,80,85) // creates categorical variable for age, using specific cutoff points.

destring cruderate* population,replace

collapse (sum) deaths (sum) population (mean) cruderate, by(race gender age_cat year) // to match the life expectancy estimates that are provided in 5-year groups

merge m:1 gender age_cat year using file_life_expectancy_1999_to_2020, keepusing(life_expectancy) // adding life expectancy column from file_life_expectancy_1999_to_2020 
drop if age>84 // no population for >85 y.o.
drop _merge

* variable life expectancy is the average remaining years people would have lived if didn't die:

gen yrs_lost=life_expectancy*((deaths/population)*100000) 

* Estimating yrs_lost SE. 
** 1584 is the number of observations
gen double yrs_lost_se2=.

forv i=1/1584 {
	cii prop population[`i'] deaths[`i'] 
	replace yrs_lost_se2 = (life_expectancy*r(se)*100000)^2 in `i'
		}
		
collapse (mean) yrs_lost (sum) population yrs_lost_se2 (count) n=yrs_lost_se2, by(race gender year)
gen yrs_lost_se = sqrt(yrs_lost_se2/n)

save file1,replace

u file1,clear
keep if race==1
rename yrs_lost yrs_lost_black 
rename yrs_lost_se yrs_lost_black_se
rename population population_black
save file2,replace

u file1,clear
keep if race==3
rename yrs_lost yrs_lost_white
rename yrs_lost_se yrs_lost_white_se
rename population population_white
save file3,replace

u file2,clear
merge 1:1 gender year using file3
drop _merge

local zcrit=invnorm(.975)

gen excess_yrs_lost = yrs_lost_black - yrs_lost_white
gen excess_yrs_lost_se = sqrt(yrs_lost_black_se^2 + yrs_lost_white_se^2)
gen excess_yrs_lost_lb = excess_yrs_lost - (excess_yrs_lost_se * `zcrit')
gen excess_yrs_lost_ub = excess_yrs_lost + (excess_yrs_lost_se * `zcrit')
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
* BREAK POINTS: 2012. Change from 2019 to 2020 analyzed separately.

u file_excess_ypll_year_figure,clear
keep if gender==1 

foreach K in 1999 2012 2019 2020 {
	
	list excess_yrs_lost excess_yrs_lost_lb excess_yrs_lost_ub if year==`K'

}

drop if year==2020

mkspline year1 2012 year2 = year
tsset year
arima excess_yrs_lost year1 year2, ar(1) nolog

predict predy1, xb
predict predy2_women, y
keep year gender predy2_women

save tempfile_women,replace

* Excess YPLL rate change from 2019 to 2020

u file_excess_ypll_year_figure,clear
keep if gender==1 
keep if inlist(year,2019,2020)
sort year

local zcrit=invnorm(.975)

qui {
    local diff_1 = yrs_lost_black[1] - yrs_lost_white[1]         
    local diff_2 = yrs_lost_black[2] - yrs_lost_white[2]          
    local did=`diff_2'-`diff_1'
    local SE_1= sqrt(yrs_lost_black_se[1]^2 + yrs_lost_white_se[1]^2) 
    local SE_2= sqrt(yrs_lost_black_se[2]^2 + yrs_lost_white_se[2]^2)
    local SE_did=sqrt(`SE_2'^2+`SE_1'^2)
    local lb=`did'-`zcrit'*`SE_did'
    local ub=`did'+`zcrit'*`SE_did'
    local Pval=2*(1-normal(abs(`did'/`SE_did')))
    local Pval=cond(`Pval'<0.001,"<0.001",string(`Pval',"%5.3f"))
    noi di "`R'" _col(20) %7.2f `did' _col(30) "(" %7.2f `lb' "," %7.2f `ub' ")" _col(50) "`Pval'"

}

**# TRENDS AMONG MEN
* BREAK POINTS: 2007, 2011. Change from 2019 to 2020 analyzed separately.

u file_excess_ypll_year_figure,clear
keep if gender==3

foreach K in 1999 2007 2011 2019 2020 {
	
	list excess_yrs_lost excess_yrs_lost_lb excess_yrs_lost_ub if year==`K'

}

drop if year==2020

mkspline year1 2007 year2 2011 year3 = year
tsset year
arima excess_yrs_lost year1 year2 year3, ar(1) nolog

predict predy1, xb
predict predy2_men, y
keep year gender predy2_men

save tempfile_men,replace

* Excess YPLL rate change from 2019 to 2020

u file_excess_ypll_year_figure,clear
keep if gender==3 
keep if inlist(year,2019,2020)
sort year

local zcrit=invnorm(.975)

qui {
    local diff_1 = yrs_lost_black[1] - yrs_lost_white[1]         
    local diff_2 = yrs_lost_black[2] - yrs_lost_white[2]          
    local did=`diff_2'-`diff_1'
    local SE_1= sqrt(yrs_lost_black_se[1]^2 + yrs_lost_white_se[1]^2) 
    local SE_2= sqrt(yrs_lost_black_se[2]^2 + yrs_lost_white_se[2]^2)
    local SE_did=sqrt(`SE_2'^2+`SE_1'^2)
    local lb=`did'-`zcrit'*`SE_did'
    local ub=`did'+`zcrit'*`SE_did'
    local Pval=2*(1-normal(abs(`did'/`SE_did')))
    local Pval=cond(`Pval'<0.001,"<0.001",string(`Pval',"%5.3f"))
    noi di "`R'" _col(20) %7.2f `did' _col(30) "(" %7.2f `lb' "," %7.2f `ub' ")" _col(50) "`Pval'"

}

**# cumulative number of YPLL and mean YPLL rate

u file_excess_ypll_year_figure,clear
collapse (sum) exc_ypll_number (mean) excess_yrs_lost (mean) yrs_lost_black (mean) yrs_lost_white, by(gender) 

**# combined number of YPLL by year

u file_excess_ypll_year_figure,clear
collapse (sum) exc_ypll_number , by(year) 

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


**# Excess YPLL rate by sex

u file_excess_ypll_year_figure,clear
merge 1:1 gender year using tempfile_women, keepusing(predy2_women)
drop _merge
merge 1:1 gender year using tempfile_men, keepusing(predy2_men)
drop _merge


#delimit ;

twoway 
	(scatter excess_yrs_lost year if gender==3 ,  msymbol(o) mcolor(maroon)) 
	(scatter excess_yrs_lost year if gender==1,  msymbol(s) mcolor(navy))
	(line predy2_women year, lpattern(solid) lcolor(navy%50))
	(line predy2_men year, lpattern(solid) lcolor(maroon%50))
	(connected excess_yrs_lost year if gender==3 & inrange(year,2019,2020), msymbol(o) mcolor(maroon) lpattern(dash) lcolor(maroon%50))
	(connected excess_yrs_lost year if gender==1 & inrange(year,2019,2020), msymbol(s) mcolor(navy) lpattern(dash) lcolor(navy%50))
	(scatteri 12264.56 2007 (2) "††"
			  9347.439 2011 (1) "‡‡"
			, msymbol(oh) msize(large) mcolor(maroon))
	(scatteri 6210.124 2012 (1) "¶¶"
			, msymbol(sh) msize(large) mcolor(navy))
	(scatteri 10805.75 1999 (1) "‖‖"
			  14964.2 1999 (2) "**"
			  9924.988 2019 (2) "§§"
			  6581.391 2019 (2) "ΔΔ"
			, msymbol(i))
	
	,
	xlabel(1999(1)2020) xtitle("Year", size(small))
	xlabel(, labsize(vsmall) angle(forty_five) valuelabel) 
	ylabel(-6000(2000)16000, angle(horizontal) labsize(vsmall)) 
	ymtick(##2)
	ytitle("Excess YPLL per 100K individuals", size(small))
	yline(0, lpattern(dash) lcolor(gray))
	
	title("{fontface Merriweather Bold: Estimated Excess Years of Potential Life Lost Rate Among the Black Population}", size(small))
	subtitle("", size(small)) 
	legend(order(1 "Black Males" 2 "Black Females" 7 "Knot" 8 "Knot")
		size(small) position(5) ring(0) col(2)
		region(fcolor(white%30)) bmargin(small) 
		title("")) 
	xsize(5) ysize(4)
	scheme(plotplainblind) 
	text(1000 1999 "↑ Higher rates relative to White Population", placement(e) justification(center) size(vsmall))
	text(-750 1999 "↓ Lower rates relative to White Population", placement(e) justification(center) size(vsmall))
	;
	graph export figure_excess_ypll_rate_by_year.jpg, as(jpg) name("Graph") quality(100) replace
	;
	graph export figure_excess_ypll_rate_by_year.eps, as(eps) name("Graph") preview(off) replace
	;
	graph export Figure1_RightPanel.eps, as(eps) name("Graph") preview(off) replace
	;
	graph export Figure1_RightPanel.pdf, as(pdf) name("Graph") replace
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
	text(1.05 2000 "↑ Higher rates relative to White Population", placement(e) justification(center) size(small))
	text(0.97 2000 "↓ Lower rates relative to White Population", placement(e) justification(center) size(small))
	xsize(5) ysize(4)
	scheme(plotplainblind) 
	;
	graph export figure_excess_ypll_rate_ratio_by_year.jpg, as(jpg) name("Graph") quality(100) replace
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
	
	title("{fontface Merriweather Bold: Estimated Excess Years of Potential Life Lost Among the Black Population}", size(small))
	subtitle("", size(small)) 
	legend(order(1 "Black Males" 2 "Black Females" )
		size(small) position(5) ring(0) 
		region(fcolor(white%30)) bmargin(small) 
		title("")) 
	xsize(5) ysize(4)
	scheme(plotplainblind) 
	;
	graph export figure_excess_ypll_rate_number_by_year.jpg, as(jpg) name("Graph") quality(100) replace
	;
	
#delimit cr


**# Figure: Cumulative YPLL number

u file_excess_ypll_year_figure,clear
bysort gender (year) : gen number_so_far = sum(exc_ypll_number)

replace number_so_far=number_so_far/1000000

#delimit ;

twoway 
	(connected number_so_far year if gender==3, lpattern(solid) lcolor(maroon) msymbol(c) mcolor(maroon))
	(connected number_so_far year if gender==1, lpattern(solid) lcolor(navy) msymbol(s) mcolor(navy)) 
	
	,
	xlabel(1999(1)2020) xtitle("Year", size(small))
	xlabel(, labsize(vsmall) angle(forty_five) valuelabel) 
	ylabel(0(5)50, angle(horizontal) labsiz(vsmall)) 
	ytitle("Excess Years of Potential Life Lost, millions", size(small))
	ymtick(##2)
	title("{fontface Merriweather Bold: Estimated Cumulative Excess Years of Potential Life Lost Among the Black Population}", size(small))
	subtitle("", size(small)) 
	legend(order(1 "Black Males" 2 "Black Females" )
		size(small) position(5) ring(0) 
		region(fcolor(white%30)) bmargin(small) 
		title("")) 
	xsize(5) ysize(4)
	scheme(plotplainblind) 
	;
	graph export figure_excess_ypll_cumul_number_by_year.jpg, as(jpg) name("Graph") quality(100) replace
	;
#delimit cr
**# Figure: Sex combined annual number of YPLL by year

u file_excess_ypll_year_figure,clear
collapse (sum) exc_ypll_number , by(year) 

#delimit ;

twoway 
	(connected exc_ypll_number year)
	
	,
	xlabel(1999(1)2020) xtitle("Year", size(small))
	xlabel(, labsize(vsmall) angle(forty_five) valuelabel) 
	ylabel(0(500000)5000000, angle(horizontal) labsize(vsmall)) 
	ymtick(##2)
	ytitle("YPLL", size(small))
	
	title("{fontface Merriweather Bold: Estimated Excess Years of Potential Life Lost Among the Black Population}", size(small))
	subtitle("{fontface Merriweather: Males and Females Combined}", size(small))
	legend(order(1 "Black population")
		size(small) position(5) ring(0) 
		region(fcolor(white%30)) bmargin(small) 
		title("")) 
	xsize(5) ysize(4)
	scheme(plotplainblind) 
	;
	graph export figure_excess_ypll_over_years_all.jpg, as(jpg) name("Graph") quality(100) replace
	;
	
#delimit cr

**# Figure: Sex combined cumulative number of YPLL by year

u file_excess_ypll_year_figure,clear
collapse (sum) exc_ypll_number , by(year) 
sort year
gen ind=1
bysort ind (year) : gen number_so_far = sum(exc_ypll_number)

replace number_so_far=number_so_far/1000000

#delimit ;

twoway 
	(connected number_so_far year)
	,
	xlabel(1999(1)2020) xtitle("Year", size(small))
	xlabel(, labsize(vsmall) angle(forty_five) valuelabel) 
	ylabel(0(5)90, angle(horizontal) labsiz(vsmall)) 
	ytitle("Excess Years of Potential Life Lost, millions", size(small))
	ymtick(##2)
	title("{fontface Merriweather Bold: Estimated Cumulative Excess Years of Potential Life Lost Among the Black Population}", size(small))
	subtitle("{fontface Merriweather: Males and Females Combined}", size(small))
	legend(order(1 "Black Males" 2 "Black Females" )
		size(small) position(5) ring(0) 
		region(fcolor(white%30)) bmargin(small) 
		title("")) 
	xsize(5) ysize(4)
	scheme(plotplainblind) 
	;
	graph export figure_cumulative_excess_ypll_over_years_all.jpg, as(jpg) name("Graph") quality(100) replace
	;
#delimit cr

**# Figure: YPLL rates by race, separately 

u file_excess_ypll_year_figure,clear

#delimit ;

twoway 
	(line yrs_lost_black year if gender==3, lpattern(solid) lcolor(maroon) msymbol(c) mcolor(maroon))
	(line yrs_lost_black year if gender==1, lpattern(solid) lcolor(navy) msymbol(c) mcolor(navy)) 
	(line yrs_lost_white year if gender==3, lpattern(dash) lcolor(maroon) msymbol(s) mcolor(maroon))
	(line yrs_lost_white year if gender==1, lpattern(dash) lcolor(navy) msymbol(s) mcolor(navy)) 	
	,
	xlabel(1999(1)2020) xtitle("Year", size(small))
	xlabel(, labsize(vsmall) angle(forty_five) valuelabel) 
	ylabel(0(5000)40000, angle(horizontal) labsize(vsmall)) 
	ymtick(##2)
	ytitle("YPLL per 100K individuals", size(small))
	
	title("{fontface Merriweather Bold: Estimated Years of Potential Life Lost}", size(small))
	subtitle("", size(small)) 
	legend(order(1 "Black Males" 2 "Black Females" 3 "White Males" 4 "White Females")
		size(small) position(5) ring(0) 
		region(fcolor(white%30)) bmargin(small) 
		title("")) 
	xsize(5) ysize(4)
	scheme(plotplainblind) 
	;
	graph export figure_ypll_per_100k_over_years_by_race_and_sex.jpg, as(jpg) name("Graph") quality(100) replace
	;
	
#delimit cr
