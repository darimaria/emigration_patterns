*------------------------------------------------------------------------------*
*    			                   Setup									   *
*------------------------------------------------------------------------------*
clear all
  
global UPI = c(username)

*Set directory
global path "C:\Users\\${UPI}\WBG\WDR2023 - WB Group - WDR2023 Team - WDR2023 Team\Data Replication\WDR Data Files\Migration-rates-2000-2010-2020"
cd "$path"

*Locations
global code   		"$path\dofile"
global data   		"$path\rawdata"
global intermediate "$path\intermediate_data"
global output 		"$path\output"	

*------------------------------------------------------------------------------*
*    			       Human capital from Wittgenstein Centre				   *
*------------------------------------------------------------------------------*


import delimited  "$data\wcde_data.csv",  clear 


keep if scenario== "SSP2DM"
ge age_15more=1
replace age_15more =0 if inlist(age,"0--4","5--9","10--14") 

ge age_25more=1
replace age_25more =0 if inlist(age,"0--4","5--9","10--14","20--24")

*** Educational attainment by group and age 
ge edu_lfs=.
replace edu_lfs = 1 if inlist(education,"No Education","Incomplete Primary","Primary","Lower Secondary")
replace edu_lfs = 2 if inlist(education,"Upper Secondary","Short Post Secondary")
replace edu_lfs = 3 if inlist(education,"Bachelor","Master and higher","Primary","Post Secondary")


*** Population breakdown by education and gender for 15+ and 25+ 
bys area edu_lfs sex age_15more year: egen Nat15 = total(population)
bys area edu_lfs sex age_25more year: egen Nat25 = total(population)

ge Nat_f15_HS = Nat15 if sex== "Female" & age_15more== 1  & edu_lfs == 3
ge Nat_f25_HS = Nat25 if sex== "Female" & age_25more== 1  & edu_lfs == 3
ge Nat_m15_HS = Nat15 if sex== "Male" & age_15more== 1  & edu_lfs == 3 
ge Nat_m25_HS = Nat25 if sex== "Male" & age_25more== 1  & edu_lfs == 3

ge Nat_f15_MS = Nat15 if sex== "Female" & age_15more== 1  & edu_lfs == 2
ge Nat_f25_MS = Nat25 if sex== "Female" & age_25more== 1  & edu_lfs == 2
ge Nat_m15_MS = Nat15 if sex== "Male" & age_15more== 1  & edu_lfs == 2 
ge Nat_m25_MS = Nat25 if sex== "Male" & age_25more== 1  & edu_lfs == 2

ge Nat_f15_LS = Nat15 if sex== "Female" & age_15more== 1  & edu_lfs == 1
ge Nat_f25_LS = Nat25 if sex== "Female" & age_25more== 1  & edu_lfs == 1
ge Nat_m15_LS = Nat15 if sex== "Male" & age_15more== 1  & edu_lfs == 1 
ge Nat_m25_LS = Nat25 if sex== "Male" & age_25more== 1  & edu_lfs == 1


foreach x of varlist Nat_f15_HS - Nat_m25_LS {
	bys area year: egen `x'_ = max(`x')
}

drop Nat_f15_HS - Nat_m25_LS
rename (Nat_f15_HS_ Nat_f15_HS_ Nat_f25_HS_ Nat_m15_HS_ Nat_m25_HS_ Nat_f15_MS_ Nat_f25_MS_ Nat_m15_MS_ Nat_m25_MS_ Nat_f15_LS_ Nat_f25_LS_ Nat_m15_LS_ Nat_m25_LS_)(Nat_f15_HS Nat_f15_HS Nat_f25_HS Nat_m15_HS Nat_m25_HS Nat_f15_MS Nat_f25_MS Nat_m15_MS Nat_m25_MS Nat_f15_LS Nat_f25_LS Nat_m15_LS Nat_m25_LS)

sort area year 
 quietly by area year:  gen dup = cond(_N==1,0,_n)
	drop if dup>1
	drop dup age sex education population age_15more age_25more edu_lfs Nat15 Nat25
		
*** Gender specific human capital 
egen pop15_ = rowtotal(Nat_f15_HS Nat_m15_HS Nat_f15_MS Nat_m15_MS Nat_f15_LS Nat_m15_LS)
egen pop25_ = rowtotal(Nat_f25_HS Nat_m25_HS Nat_f25_MS Nat_m25_MS Nat_f25_LS Nat_m25_LS)
egen pop15_f = rowtotal(Nat_f15_HS Nat_f15_MS Nat_f15_LS)
egen pop15_m = rowtotal(Nat_m15_HS Nat_m15_MS Nat_m15_LS)
egen pop25_f = rowtotal(Nat_f25_HS Nat_f25_MS Nat_f25_LS)
egen pop25_m = rowtotal(Nat_m25_HS Nat_m25_MS Nat_m25_LS)

ge Hr15 = (Nat_f15_HS + Nat_m15_HS)/(pop15_)
ge Hr25 = (Nat_f25_HS + Nat_m25_HS)/(pop25_)
ge Hr15f = (Nat_f15_HS)/(pop15_f)
ge Hr25f = (Nat_f25_HS)/(pop25_f)
ge Hr15m = (Nat_m15_HS)/(pop15_m)
ge Hr25m = (Nat_m25_HS)/(pop25_m)

save "$intermediate\HumanCap1960_2020_WGE_SSP2DM", replace 
 

