CDC Wonder Projects ReadMe file

Below are the codes and datasets used to estimate excess mortality and years of potential life lost (per 100K individuals) among Black individuals using data from CDC WONDER (https://wonder.cdc.gov/Deaths-by-Underlying-Cause.html) for years 1999 to 2020.

The analysis has 2 main parts, and each part is divided into 2 subsections.

Part 1: Excess mortality per 100K individuals


1.1 By years: 

•	Estimated as the annual difference between Black people and White people in the CDC-provided age-adjusted mortality rate rate.
•	Code: code_excessdeaths_part1_years.do 
•	Dataset: export_age_adjusted_deaths_race_gender_year.txt
•	Figure: figure_ageadjusted_excess_deaths_over_years_by_sex_100k.jpg


1.2 By age: 

•	Estimated using the crude mortality rate difference between Black people and White people for each age group. The CDC does not provide age-adjusted mortality rates for age groups of fewer than 10-years.
•	Code: code_excessdeaths_part2_age.do
•	Dataset: export_deaths_crude_race_gender_age.txt
•	Figure: figure_unadjusted_excess_deaths_over_age_by_sex_100k.jpg


Part 2: Excess years of potential life lost per 100K individuals


2.1 By years: 

•	Estimated as follows: 1) By race, estimated the crude mortality rate for each age group. 2) Multiplied each age group mortality rate by their respective age- and year-specific life expectancy. 3) Added years lost for all age groups of the same race for each year. 4) Excess defined as the annual years of life lost rate difference between Black and White people. 
•	Code: code_excessypll_part1_years.do
•	Dataset: export_deaths_crude_race_gender_age_year.txt 
•	Figure: figure_excess_ypll_per_100k_over_years_by_sex.jpg


2.2 By age

•	Estimated as follows: 1) By race, estimated the annual crude mortality rate for each age group. 2) Multiplied each age group mortality rate by their respective age- and year-specific life expectancy. 3) Added years lost for all years of the same race for each age group. 4) Excess defined as the annual years of life lost rate difference between Black and White people for each age group.
•	Code: code_excessypll_part2_age.do 
•	Dataset:  export_deaths_crude_race_gender_age_year.txt 
•	Figure: figure_excess_ypll_per_100k_over_age_by_sex.jpg


