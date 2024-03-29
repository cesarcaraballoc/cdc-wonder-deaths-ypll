# ReadMe File: CDC WONDER Trends in Excess Mortality and Years of Potential Life Lost

We include here the codes and datasets used to estimate excess mortality rate and years of potential life lost (per 100K individuals) among Black individuals using data publicly available from CDC WONDER (https://wonder.cdc.gov/Deaths-by-Underlying-Cause.html) for years 1999 to 2020.

** Important note: Please see the files under '2023-04-19_revision' for the latest version of these codes.

The analysis has 2 main parts.

## Part 1: Temporal trends

### Codes: 
- a)  code_excessdeaths_part1_years.do 
- b)  code_excessypll_part1_years.do 
- c)  heat_map_death_rate.py
- d)  heat_map_ypll.py
### Datasets: 
- a)  export_age_adjusted_deaths_race_gender_year.txt
- b)  export_deaths_crude_race_gender_age_year.txt
- c) file_life_expectancy_1999_to_2020.dta

## Part 2: By age

### Codes: 
- a)  code_excessdeaths_part2_age.do 
- b)  code_excessypll_part2_age.do 
### Datasets: 
- a)  export_deaths_crude_race_gender_age.txt
- b)  export_deaths_crude_race_gender_age_year.txt
- c) file_life_expectancy_1999_to_2020.dta
