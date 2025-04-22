* download municipality data in 2010 from https://www.citypopulation.de/en/mexico/cities/

* organize in excel, fill out for 695650 rows in order to append in Mexico_2010_cleaned.dta

* Step 1: Define value labels for SortOrder(col name in excel) using mig2_5_mx (same as row number)
levelsof SortOrder, local(sort_levels)
foreach level of local sort_levels {
    local city : label (mig2_5_mx) `level'
    label define SortOrder_label `level' "`=mig2_5_mx[`level']'", modify
}

* Step 2: Assign the value labels to SortOrder
label values SortOrder SortOrder_label

* Step 3: Verify the labels
list

drop mig2_5_mx

drop Population

* Count the current number of rows
quietly count
local rows = r(N)

* Desired number of rows
local target = 695650

* Calculate the required expansion factor
local factor = ceil(`target' / `rows')

* Expand the dataset by the calculated factor
expand `factor'

* Trim any excess rows to get exactly 695,650 rows
gen __id = _n
keep if __id <= `target'
drop __id

* Verify the extended dataset
count

* copy sorted municipality and mig2_5_mx into excel, use vlookup to correpsond mig2_5_mx to its sorted rank, then generate cohorts corresponds to sizemx

merge 1:1 _n using "ranking.dta"

* generate size cohorts that corresponds to sizemx
*1	Less than 2,500 inhabitants	       x>=2082
*2	2,500 to 14,999 inhabitants	 1103<=x<2082
*3	15,000 to 99,999 inhabitants  188<=x<1103
*4	100,000 or more inhabitants	     0<x<188

gen ranking_cohort = cond(ranking >= 2082, 1, ///
             cond(ranking >= 1103 & ranking < 2082, 2, ///
             cond(ranking >= 188 & ranking < 1103, 3, ///
             cond(ranking > 0 & ranking < 188, 4, .))))
replace ranking_cohort=0 if missing(ranking_cohort)

* generate vars for different migration levels 
gen mig1_4=1 if sizemx==1 & ranking_cohort==4
replace mig1_4 = 0 if missing(mig1_4)
.
.
.
gen mig4_1=1 if sizemx==4 & ranking_cohort==1
replace mig4_1 = 0 if missing(mig4_1)

* age range for migration data
*			 2005          2010
*             -5            0										
*lower: 15>=age>=10  20>=age>=15 
*upper: 18>=age>=13  23>=age>=18  

* Compare lower/upper secondary attainment by migrate status within age range
graph bar (count) low_secattain if age18_20 == 1 & low_secattain == 1, over(migrate, gap(200)) ///
    ytitle("Count of Low Secondary Attainment (age 18-20)") ///
    title("Lower Secondary Attainment by Migrate Status (age 18-20)") ///
    bar(1, color(blue)) bar(2, color(blue)) name(g1, replace)	
	
graph bar (count) upper_secattain if age18_23 == 1 & upper_secattain == 1, over(migrate, gap(200)) ///
    ytitle("Count of Upper Secondary Attainment (age 18-23)") ///
    title("Upper Secondary Attainment by Migrate Status (age 18-23)") ///
    bar(1, color(orange)) bar(2, color(orange)) name(g2, replace)

* Compare lower/upper secondary attainment by migrate status and gender 
graph bar (count) low_secattain if female==1 & low_secattain == 1, over(migrate, gap(200)) ///
    ytitle("Count of Lower Secondary Attainment (women)") ///
    title("Lower Secondary Attainment by Migrate Status (women)") ///
    bar(1, color(blue)) bar(2, color(blue)) name(g1, replace)	
	
graph bar (count) low_secattain if female==0 & low_secattain == 1, over(migrate, gap(200)) ///
    ytitle("Count of Lower Secondary Attainment (men)") ///
    title("Lower Secondary Attainment by Migrate Status (men)") ///
    bar(1, color(orange)) bar(2, color(orange)) name(g2, replace)
		
graph bar (count) upper_secattain if female==1 & upper_secattain == 1, over(migrate, gap(200)) ///
    ytitle("Count of Upper Secondary Attainment (women)") ///
    title("Upper Secondary Attainment by Migrate Status (women)") ///
    bar(1, color(blue)) bar(2, color(blue)) name(g1, replace)	
	
graph bar (count) upper_secattain if female==0 & upper_secattain == 1, over(migrate, gap(200)) ///
    ytitle("Count of Upper Secondary Attainment (men)") ///
    title("Upper Secondary Attainment by Migrate Status (men)") ///
    bar(1, color(orange)) bar(2, color(orange)) name(g2, replace)
	
	

	  


