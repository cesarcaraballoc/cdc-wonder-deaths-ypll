

u data_cod_2020, clear

sort excess_death_males

graph bar excess_death_males, over(cause_of_death, sort(1) descending) horizontal ytitle("Excess deaths per 100,000 Black individuals in 2020") yline(0, lcolor(black)) title("Black Males")
graph save "Graph" "figure_excessdeaths_cod_2020_males.gph", replace
graph export "figure_excessdeaths_cod_2020_males.jpg", as(jpg) name("Graph") quality(100) replace

graph bar excess_death_females, over(cause_of_death, sort(1) descending) horizontal ytitle("Excess deaths per 100,000 individuals  in 2020") yline(0, lcolor(black)) title("Black Females")
graph save "Graph" "figure_excessdeaths_cod_2020_females.gph", replace
graph export "figure_excessdeaths_cod_2020_females.jpg", as(jpg) name("Graph") quality(100) replace

graph bar excess_ypll_males, over(cause_of_death, sort(1) descending) horizontal ytitle("Excess YPLL per 100,000 Black individuals in 2020") yline(0, lcolor(black)) title("Black Males") 
graph save "Graph" "figure_excessypll_cod_2020_males.gph", replace
graph export "figure_excessypll_cod_2020_males.jpg", as(jpg) name("Graph") quality(100) replace

graph bar excess_ypll_females, over(cause_of_death, sort(1) descending) horizontal ytitle("Excess YPLL per 100,000 Black individuals in 2020") yline(0, lcolor(black)) title("Black Females")
graph save "Graph" "figure_excessypll_cod_2020_females.gph", replace
graph export "figure_excessypll_cod_2020_females.jpg", as(jpg) name("Graph") quality(100) replace
