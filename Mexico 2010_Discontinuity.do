use "Mexico_2010_cleaned.dta"

* clean the dataset 
* drop if year != 2010
* sample 10, by(year)
tab yrschool, nolabel

*creat a dummy variable for the policy first effect generation cutoff
gen birthyr = year - age
gen cohort = (birthyr >= 1979)

* keep only adutls in the dataset 
drop if age <= 18

* drop observation with unknown datas 
drop if yrschool >=90

* generate the year variable that is exactly zero at the cuttoff year 1979
gen year79 = birthyr-1979

* generate binary variables for secondary school attainment and literacy
gen secattain=0
replace secattain=1 if edattain==3
gen literacy=0
replace literacy=1 if lit==2

*calculate the average years of education attained/average years of secondary school attained/literacy rate by sorts of each year 
bysort year79 : egen avg_school= mean (yrschool)
bysort year79 : egen avg_secattain= mean (secattain)
bysort year79 : egen avg_literacy= mean (literacy)

* add more detail to the scatterplot with the cuttoff specified and even year before and after the cuttoff adjusted 
  scatter avg_secattain year79 if year == 1979 & year79>=-5 & year79<=5 || lfit avg_secattain year79 if inrange(year79, -5,0),lcolor(blue%40) || lfit avg_secattain year79 if inrange(year79,0, 5), lcolor(red%40)
graph save educ_0

  scatter avg_literacy year79 if year == 1979 & year79>=-5 & year79<=5 || lfit avg_literacy year79 if inrange(year79, -5,0),lcolor(blue%40) || lfit avg_literacy year79 if inrange(year79,0, 5), lcolor(red%40)
graph save educ_lit

scatter avg_school year79 if year == 1979 & year79>=-5 & year79<=5 || lfit avg_school year79 if inrange(year79, -5,0),lcolor(blue%40) || lfit avg_school year79 if inrange(year79,0, 5), lcolor(red%40)
graph save educ_school

* change the cuttoff from exactly as year 0 to a later year at 5 to show discontiuity 
scatter avg_secattain year79 if year == 1979 & year79>=-5|| lfit avg_secattain year79 if inrange(year79, -5,5),lcolor(blue) || lfit avg_secattain year79 if inrange(year79, 6, 10), lcolor(red)
graph save educ_5

scatter avg_literacy year79 if year == 1979 & year79>=-5|| lfit avg_literacy year79 if inrange(year79, -5,5),lcolor(blue) || lfit avg_literacy year79 if inrange(year79, 6, 10), lcolor(red)
graph save educ_5lit

scatter avg_school year79 if year == 1979 & year79>=-5|| lfit avg_school year79 if inrange(year79, -5,5),lcolor(blue) || lfit avg_school year79 if inrange(year79, 6, 10), lcolor(red)
graph save educ_5school
	
* histogram for years of schooling distribution each year
local years 1977 1978 1979 1980 1981
foreach yr in `years' {
    histogram yrschool if birthyr == `yr', bin(30) frequency ///
        title("`yr'") ///
        xtitle("Years of Schooling") ///
        ytitle("Frequency") ///
        lcolor(blue) ///
        name(hist`yr', replace)
}	

* binscatter on Birth Year vs. Education Attainment 	
binscatter edattain birthyr, line(none) ///
    xtitle("Birth Year") ///
    ytitle("Education Attainment") ///
    title("Binscatter on Birth Year vs. Education Attainment") ///
    n(20)

