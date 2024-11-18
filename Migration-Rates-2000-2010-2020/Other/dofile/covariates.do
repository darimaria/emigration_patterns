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
*    			    					   covariates 						   *
*------------------------------------------------------------------------------*


	import excel "$data\Covariates.xlsx", sheet("covariates") firstrow case(lower) clear
	keep if filter==1
	rename countryzare countrycode
	rename(countryname countrycode time timecode populationfemale populationmale populationages014male populationages014female fertilityratetotalbirthspe lifeexpectancyatbirthtotal lifeexpectancyatbirthmale lifeexpectancyatbirthfemale gdppercapitaconstant2015us gdppercapitapppconstant20)(country iso3 year yearcode popf popm popm014 popf014 fertility life_expect lifef_expect lifem_expect gdppc_cst gdppc_cstppp)
	
	keep if year == 2000 | year== 2010 | year == 2020
	save "$intermediate\covariates00_20", replace 
	
/*{
	Next step Human capital from Wittgeinstein Centre 2000, 2010, 2020
}*/

	
	import excel "$data\wge_isoo.xlsx", sheet("Sheet1") firstrow case(lower) clear
	merge 1:m area using "$intermediate\HumanCap1960_2020_WGE_SSP2DM"
	keep scenario area iso3 filter year Nat_f15_HS Nat_m15_HS Nat_m15_MS Nat_f15_MS Nat_f15_LS Nat_m15_LS pop15_ pop15_f pop15_m Hr15 Hr15f Hr15m
	egen NatLMS_f = rowtotal(Nat_f15_MS Nat_f15_LS)
	egen NatLMS_m = rowtotal(Nat_m15_MS Nat_m15_LS)
	rename (Nat_f15_HS Nat_m15_HS NatLMS_f NatLMS_m)(Lab15HS_f Lab15HS_m Lab15LMS_f Lab15LMS_m)
	
	keep scenario area iso3 filter year pop15_ pop15_f ///
		 pop15_m Lab15HS_f Lab15HS_m Lab15LMS_f Lab15LMS_m Hr15 Hr15f Hr15m
	keep if year == 2000 | year== 2010 | year == 2020
	keep if filter==1
	drop filter  
	merge n:n iso3 year using "$intermediate\covariates00_20"
	drop if _merge==1
	drop _merge filter 
	rename (Lab15HS_f Lab15HS_m Lab15LMS_f Lab15LMS_m)(Lab15HS_f0 Lab15HS_m0 Lab15LMS_f0 Lab15LMS_m0)
	ge pop15f = popf-popf014 
	ge pop15m = popm-popm014 
	replace pop15f = pop15_f*1000 if pop15f==. & pop15_f !=.
	replace pop15m = pop15_m*1000 if pop15m==. & pop15_m !=.
	ge Lab15HS_f  = pop15f*Hr15f
	ge Lab15HS_m  = pop15m*Hr15m
	ge Lab15LMS_f = pop15f*(1-Hr15f)
	ge Lab15LMS_m = pop15m*(1-Hr15m)
	drop Lab15HS_f0 Lab15HS_m0 Lab15LMS_f0 Lab15LMS_m0
	lab var Lab15HS_f "High Sk. female 15+"
	lab var Lab15HS_m "High Sk. male 15+"
	lab var Lab15LMS_f "Low-Med. Sk. female 15+"
	lab var Lab15LMS_m "Low-Med. Sk. male 15+"
	lab var pop15_f "pop 15+ female wge"
	lab var pop15_m "pop 15+ male wge"
	lab var pop15_ "pop 15+ wge"
	drop yearcode area 
	
	order  iso3 country scenario year  Lab15HS_f Lab15HS_m Lab15LMS_f Lab15LMS_m pop15_ pop15_f pop15_m popf popm popm014 popf014 fertility life_expect lifef_expect lifem_expect gdppc_cst gdppc_cstppp
	rename (Lab15HS_f Lab15HS_m Lab15LMS_f Lab15LMS_m) (Lab15hs_f Lab15hs_m Lab15lms_f Lab15lms_m)
	clonevar isoo = iso3
	rename lifef_expect x 
	rename lifem_expect lifef_expect 
	rename x lifem_expect
	save "$intermediate\covariates_full", replace 
