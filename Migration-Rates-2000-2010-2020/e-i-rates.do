
*==============================================================================*
*=	 				 immigration and emigration rates    			   		  =*
*==============================================================================*

/*
Description: total emigration and immigration rates, gender and education specific
			 emigration and immigration rates 2000-2010-2020

Author: 
	-- 
	-- Code by Narcisse Cha'ngom for the WDR 2023
*/

*------------------------------------------------------------------------------*
*    			                   Setup									   *
*------------------------------------------------------------------------------*
clear all
  
global UPI = c(username)

*Set directory
global path "C:\Users\\${UPI}\WBG\WDR2023 - WB Group - WDR2023 Team - WDR2023 Team\Data Replication\WDR Data Files\Migration-rates-2000-2010-2020"
cd "$path"

*Locations
global export   	"$path"
global code   		"$path\OTHERS\dofile"
global data   		"$path\OTHERS\rawdata"
global intermediate "$path\OTHERS\intermediate_data"
global output 		"$path\OTHERS\output"	
global migration    "C:\Users\\${UPI}\WBG\WDR2023 - WB Group - WDR2023 Team - WDR2023 Team\Data Replication\WDR Data Files\WBGBMM-2000-2010-2020\OTHERS\2000-2010-2020\output"



*------------------------------------------------------------------------------*
*    			         1-     Education shares EULFS2010					   *
*------------------------------------------------------------------------------*
/*
	{
	do "$code\eu2010_HC.do"
	}
	for data privacy reasons, the access to raw eu-lfs data is not possible but 
	the related code can be found in the above indicated do-file.
	so, only the output is used here as: 
use "$intermediate\sh_eulfs_cid2010", clear 
*/
	


*------------------------------------------------------------------------------*
*    			              Education shares EULFS2020					   *
*------------------------------------------------------------------------------*
/*
	{
	do "$code\eu2020_HC.do"
	}
	for data privacy reasons, the access to raw eu-lfs data is not possible but 
	the related code can be found in the above indicated do-file.
	so, only the output is used here as: 
use "$intermediate\sh_eulfs_cid2020", clear 
*/



*------------------------------------------------------------------------------*
*    			  2-     Human capital from Wittgenstein Centre				   *
*------------------------------------------------------------------------------*


import delimited  "$data\wcde_data.csv",  clear 

keep if scenario== "SSP2DM"
ge age_15more=1
replace age_15more =0 if age == "0--4" | age == "5--9" |age == "10--14"

ge age_25more=1
replace age_25more =0 if age == "0--4" | age == "5--9" | age == "10--14"| age == "15--19" |age == "20--24"

*** Educational attainment by group and age 
ge edu_lfs=.
replace edu_lfs = 1 if education == "No Education" |  education == "Incomplete Primary" |  education == "Primary" |  education == "Lower Secondary" 
replace edu_lfs = 2 if education == "Upper Secondary" | education == "Short Post Secondary"
replace edu_lfs = 3 if education == "Bachelor" |  education == "Master and higher" | education == "Post Secondary"

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
sc Hr15m Hr15f


save "$intermediate\HumanCap1960_2020_WGE_SSP2DM", replace 




*------------------------------------------------------------------------------*
*    			    	3-		 covariates 								   *
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


	
*------------------------------------------------------------------------------*
*    			 5-  		Combining  Human capital data 						   *
*------------------------------------------------------------------------------*


*------------------------------------------------------------------------------*
*    			   				1- EU-LFS 2010 & 2020 						   *
*------------------------------------------------------------------------------*

	use "$intermediate\sh_eulfs_cid2010", clear 
	ge year = 2010
	save "$intermediate\sh_eulfs_cid2010a", replace 
	
	
	use "$intermediate\sh_eulfs_cid2020", clear 
	recode cid (30=31)(29=30)(28=29)(27=28)(26=27)(25=26)(24=25)(23=24)(22=23) ///
			   (21=22)(20=21)(19=20)(18=19)(17=18)
	replace country= "Austria" if cid==1
	replace country= "Bulgaria" if cid==2
	replace country= "Belgium" if cid==3
	replace country= "Switzerland" if cid==4
	replace country= "Cyprius" if cid==5
	replace country= "Czek Rep." if cid==6
	replace country= "Germany" if cid==7
	replace country= "Denmark" if cid==8
	replace country= "Estonia" if cid==9
	replace country= "Spain" if cid==10
	replace country= "Finland" if cid==11
	replace country= "France" if cid==12
	replace country= "Greece" if cid==13
	replace country= "Croatia" if cid==14
	replace country= "Hungary" if cid==15
	replace country= "Ireland" if cid==16
	replace country= "Italy" if cid==18
	replace country= "Lituania" if cid==19
	replace country= "Luxembourg" if cid==20
	replace country= "Latvia" if cid==21
	replace country= "Malta" if cid==22
	replace country= "Netherland" if cid==23
	replace country= "Norway" if cid==24
	replace country= "Poland" if cid==25
	replace country= "Portugal" if cid==26
	replace country= "Romania" if cid==27
	replace country= "Sweden" if cid==28
	replace country= "Slovenia" if cid==29
	replace country= "Slovakia" if cid==30
	replace country= "United  Kingdom" if cid==31	
	append using "$intermediate\sh_eulfs_cid2010a"
	
	lab define cid 1 "AUT" 2 "BEL" 3 "BGR"  4 "CHE" 5 "CYP" 6 "CZE" 7 "DEU" 8 "DNK" ///
				   9 "EST" 10 "ESP" 11 "FIN" 12 "FRA" 13 "GRC" 14 "HRV" 15 "HUN" ///
				   16 "IRL" 17 "ISL" 18 "ITA" 19 "LTU" 20 "LUX" 21 "LVA" 22 "MLT" ///
				   23 "NLD" 24 "NOR" 25 "POL" 26 "PRT" 27 "ROM" 28 "SWE" 29 "SVN" ///
				   30 "SVK" 31 "GBR", modify 
	lab value cid cid	
	sort year cid
	ge iso3 = ""
	replace iso3 = "AUT" if cid==1
	replace iso3 = "BEL" if cid==2
	replace iso3 = "BGR" if cid==3
	replace iso3 = "CHE" if cid==4
	replace iso3 = "CYP" if cid==5
	replace iso3 = "CZE" if cid==6
	replace iso3 = "DEU" if cid==7
	replace iso3 = "DNK" if cid==8
	replace iso3 = "EST" if cid==9
	replace iso3 = "ESP" if cid==10
	replace iso3 = "FIN" if cid==11
	replace iso3 = "FRA" if cid==12
	replace iso3 = "GRC" if cid==13
	replace iso3 = "HRV" if cid==14
	replace iso3 = "HUN" if cid==15
	replace iso3 = "IRL" if cid==16
	replace iso3 = "ISL" if cid==17
	replace iso3 = "ITA" if cid==18
	replace iso3 = "LTU" if cid==19
	replace iso3 = "LUX" if cid==20
	replace iso3 = "LVA" if cid==21
	replace iso3 = "MLT" if cid==22
	replace iso3 = "NLD" if cid==23
	replace iso3 = "NOR" if cid==24
	replace iso3 = "POL" if cid==25
	replace iso3 = "PRT" if cid==26
	replace iso3 = "ROM" if cid==27
	replace iso3 = "SWE" if cid==28
	replace iso3 = "SVN" if cid==29
	replace iso3 = "SVK" if cid==30
	replace iso3 = "GBR" if cid==31
	
	order iso3 iso2 country year 
	save "$intermediate\HumCap_eulfs1020", replace
	

	
*------------------------------------------------------------------------------*
*    			   		2- Barro and Lee 2000 - 2010 - 2020					   *
*------------------------------------------------------------------------------*
	
/*
	Both sex
*/
	
	use "$data\BarroLee_MF1564", clear 
	
	keep if year==2000 | year==2010 | year== 2015
	
	keep BLcode country year sex lhc WBcode region_code pop
	rename WBcode iso3
	replace iso3 = "ZAR" if iso3 == "COD"
	replace iso3 = "MDA" if iso3 == "ROM"
	replace iso3 = "ROM" if iso3 == "ROU"
	replace country = "Serbia and Montenegro" if iso3 == "SER"
	replace iso3 = "YUG" if iso3 == "SER"
	ge lh_both = lhc/100
	keep country year lh_both iso3 region_code
	save "$intermediate\lh_both", replace 

	
/*
	Females
*/
	use "$data\BarroLee_F1564", clear 		
	
	keep if year==2000 | year==2010 | year== 2015
	
	keep BLcode country year sex lhc WBcode region_code pop
	rename WBcode iso3
	replace iso3 = "ZAR" if iso3 == "COD"
	replace iso3 = "MDA" if iso3 == "ROM"
	replace iso3 = "ROM" if iso3 == "ROU"
	replace country = "Serbia and Montenegro" if iso3 == "SER"
	replace iso3 = "YUG" if iso3 == "SER"
	ge lh_fem = lhc/100
	keep country year lh_fem iso3 region_code
	save "$intermediate\lh_fem", replace 

/*
	Males
*/
	use "$data\BarroLee_M1564", clear 
	
	keep if year==2000 | year==2010 | year== 2015
	
	keep BLcode country year sex lhc WBcode region_code pop
	rename WBcode iso3
	replace iso3 = "ZAR" if iso3 == "COD"
	replace iso3 = "MDA" if iso3 == "ROM"
	replace iso3 = "ROM" if iso3 == "ROU"
	replace country = "Serbia and Montenegro" if iso3 == "SER"
	replace iso3 = "YUG" if iso3 == "SER"
	ge lh_mal = lhc/100
	keep country year lh_mal iso3 region_code
	save "$intermediate\lh_mal", replace 	
 

	use "$intermediate\lh_both", clear 
	merge 1:1 iso3 year using "$intermediate\lh_fem" 
	drop _merge 
	merge 1:1 iso3 year using "$intermediate\lh_mal" 
	drop _merge 
	sort region_code year iso3
	save "$intermediate\educ_structure_BL", replace 



/*
	Prepare iso3 codes
*/	
	
	use "$data\BIL_MIG_EDU2020_WDR.dta", clear 
	sort isoo
	quietly by isoo: ge dup = cond(_N==1,0,_n)
	drop if dup>1
	keep isoo
	rename isoo iso3
	save "$intermediate\iso3_197", replace
	
	use "$intermediate\educ_structure_BL", clear
	merge m:1 iso3 using "$intermediate\iso3_197"
	drop if _merge==1
	br if _merge==2
	replace year=2020 if year==2015
	drop if _merge==2
	drop _merge region_code

	save "$intermediate\HumCap_intermediate", replace

*------------------------------------------------------------------------------*
*    			   		3- Lutz WGE 2000 - 2010 - 2020						   *
*------------------------------------------------------------------------------*
	
	use "$intermediate\covariates_full", clear 
	
	ge Lab15hsf = pop15f*Hr15f 
	ge Lab15hsm = pop15m*Hr15m 
	ge Lab15lmsf= pop15f*(1-Hr15f)
	ge Lab15lmsm= pop15m*(1-Hr15m)
	egen Lab15 = rowtotal(Lab15hsf Lab15hsm Lab15lmsf Lab15lmsm)
	egen Lab15f = rowtotal(Lab15hsf Lab15lmsf)
	egen Lab15m = rowtotal(Lab15hsm Lab15lmsm)
	keep iso3 country year Lab15hsf Lab15hsm Lab15lmsf Lab15lmsm Lab15 ///
		 Lab15f Lab15m popf popm popm014 popf014 isoo Hr15 Hr15f Hr15m ///
		 gdppc_cst gdppc_cstppp
	ge Hr_wge = Hr15 
	ge Hrf_wge= Hr15f  
	ge Hrm_wge= Hr15m 
	
/*
	ge Lab15hsf = pop15f*Hr15f 
	ge Lab15hsm = pop15m*Hr15m 
	ge Lab15lmsf= pop15f*(1-Hr15f)
	ge Lab15lmsm= pop15m*(1-Hr15m)
	egen Lab15 = rowtotal(Lab15hsf Lab15hsm Lab15lmsf Lab15lmsm)
	egen Lab15f = rowtotal(Lab15hsf Lab15lmsf)
	egen Lab15m = rowtotal(Lab15hsm Lab15lmsm)
	keep iso3 country year Lab15hsf Lab15hsm Lab15lmsf Lab15lmsm Lab15 ///
		 Lab15f Lab15m popf popm popm014 popf014 isoo Hr15 Hr15f Hr15m ///
		 gdppc_cst gdppc_cstppp
	ge Hr_wge = Hr15 
	ge Hrf_wge= Hr15f  
	ge Hrm_wge= Hr15m 
*/
	keep iso3 country isoo year Hr_wge Hrf_wge Hrm_wge popf popm popm014 popf014 ///
		 gdppc_cst gdppc_cstppp
	merge 1:1 iso3 year using "$intermediate\HumCap_intermediate"
	rename(Hr_wge Hrf_wge Hrm_wge)(Hr_lutz Hrf_lutz Hrm_lutz)
	rename(lh_both lh_fem lh_mal)(Hr_barrolee Hrf_barrolee Hrm_barrolee)
	drop _merge 
	merge 1:1 iso3 year using "$intermediate\HumCap_eulfs1020"
	rename(sh_15HS sh_15HSf sh_15HSm)(Hr_eulfs Hrf_eulfs Hrm_eulfs)
	drop cid _merge iso2 
	drop if iso3== "PRI"
	
	save "$intermediate\Human_Cap_bl_wge", replace

	
*------------------------------------------------------------------------------*
*    			   4- Human cap as a combination of the three data			   *
*------------------------------------------------------------------------------*
	
/*
 1st best: eulfs
 2nd best: Barro and Lee
 3rd best: Lutz 
*/
	ge Hr  = Hr_eulfs
	ge Hrf = Hrf_eulfs 
	ge Hrm = Hrm_eulfs
	
	replace Hr = Hr_barrolee if Hr==.
	replace Hrf = Hrf_barrolee if Hrf==.
	replace Hrm = Hrm_barrolee if Hrm==.
	
	replace Hr = Hr_lutz if Hr==.	
	replace Hrf = Hrf_lutz if Hrf==.
	replace Hrm = Hrm_lutz if Hrm==.
	keep iso3 country year popf popm popm014 popf014 isoo Hr Hrf Hrm  ///
		 gdppc_cst gdppc_cstppp
	ge Lab15f = popf-popf014 
	ge Lab15m = popm-popm014 
	egen Lab15  = rowtotal(Lab15f Lab15m)
	ge Lab15hs  = round(Lab15*Hr) 
	ge Lab15ls  = round(Lab15*(1-Hr))
	ge Lab15hsf = round(Lab15f*Hrf) 
	ge Lab15lsf = round(Lab15f*(1-Hrf))
	ge Lab15hsm = round(Lab15m*Hrm) 
	ge Lab15lsm = round(Lab15m*(1-Hrm))
	
	keep iso3 isoo country year popf popm Hr Hrf Hrm Lab15f Lab15m Lab15 ///
		 Lab15hs Lab15ls Lab15hsf Lab15lsf Lab15hsm Lab15lsm ///
		 gdppc_cst gdppc_cstppp popm014 popf014
		 
		 foreach a of varlist Lab15f-Lab15lsm {
		 	replace `a' = . if `a'==0
		 }
		 
	save "$intermediate\HumCap_WDR", replace 
	

	
	use "$intermediate\Human_Cap_bl_wge", clear 
	clonevar Hr = Hr_barrolee
	clonevar Hrf = Hrf_barrolee
	clonevar Hrm = Hrm_barrolee
	replace Hr = Hr_lutz if Hr_barrolee==. & Hr_lutz!=.
	replace Hrf = Hrf_lutz if Hrf_barrolee==. & Hrf_lutz!=.
	replace Hrm = Hrm_lutz if Hrm_barrolee==. & Hrm_lutz!=.
	
	lab var Hr "% of educated residents (combination)"
	lab var Hrf "% of educated female residents (combination)"
	lab var Hrm "% of educated male residents (combination)"
	
	export excel using "$intermediate\Combimation-BarroL-Lutz.xlsx", sheetmodify firstrow(variables)	
	keep iso3 isoo country year popm popf popm014 popf014 Hr Hrf Hrm ///
		 gdppc_cst gdppc_cstppp popm014 popf014
	rename (Hr Hrf Hrm)(HrNew HrfNew HrmNew)
	ge pop15f = popf-popf014
	ge pop15m = popm-popm014 
	ge pop15 = pop15f+pop15m
	keep iso3 isoo country year HrNew HrfNew HrmNew ///
		 pop15f pop15m pop15 gdppc_cst gdppc_cstppp popm014 popf014
	save "$intermediate\HumanCap_New", replace
	




*------------------------------------------------------------------------------*
*    			                   Migration data 							   *
*------------------------------------------------------------------------------*

	use "$migration\BIL_MIG_SEX_EDU_2000_2010_2020", clear 

	keep isoo isod ODid sex year mig15hs mig15lms mig15 mig014 country region10_ori

{
	preserve 
	keep if sex==1
	
	foreach var of varlist mig15hs mig15lms mig15 mig014 {
	    bys isoo year: egen E`var' = total(`var')
	}
	sort isoo year 
	quietly by isoo year: gen dup = cond(_N==1,0,_n)
	drop if dup>1 
	keep  country isoo region10_ori E* year 
	rename(Emig15hs Emig15lms Emig15 Emig014)(Emig15hsm Emig15lsm Emig15m Emig014m)
	save "$intermediate\Emen", replace 
	restore
}

{	
	preserve 
	keep if sex==2
	
	foreach var of varlist mig15hs mig15lms mig15 mig014{
	    bys isoo year: egen E`var' = total(`var')
	}
	sort isoo year 
	quietly by isoo year: gen dup = cond(_N==1,0,_n)
	drop if dup>1 
	keep  country isoo region10_ori E* year 
	rename(Emig15hs Emig15lms Emig15 Emig014)(Emig15hsf Emig15lsf Emig15f Emig014f)
	save "$intermediate\Ewomen", replace 
	restore
}

{	
	preserve 
	keep if sex==1
	
	foreach var of varlist mig15hs mig15lms mig15 mig014 {
	    bys isod year: egen I`var' = total(`var')
	}
	sort isod year 
	quietly by isod year: gen dup = cond(_N==1,0,_n)
	drop if dup>1 
	keep isod region10_ori I* year 
	rename(Imig15hs Imig15lms Imig15 Imig014)(Imig15hsm Imig15lsm Imig15m Imig014m)
	save "$intermediate\Imen", replace 
	restore
}

{	
	preserve 
	keep if sex==2
	
	foreach var of varlist mig15hs mig15lms mig15 mig014{
	    bys isod year: egen I`var' = total(`var')
	}
	sort isod year 
	quietly by isod year: gen dup = cond(_N==1,0,_n)
	drop if dup>1 
	keep isod region10_ori I* year 
	rename(Imig15hs Imig15lms Imig15 Imig014)(Imig15hsf Imig15lsf Imig15f Imig014f)
	save "$intermediate\Iwomen", replace 
	restore
}

*------------------------------------------------------------------------------*
*    			 Combine aggregate data and call HC in						   *
*------------------------------------------------------------------------------*
{	
	use "$intermediate\Emen", clear 
	merge 1:1 isoo year using "$intermediate\Ewomen" 
	drop _merge 
	rename isoo isod
	merge 1:1 isod year using "$intermediate\Imen"
	drop _merge 
	merge 1:1 isod year using "$intermediate\Iwomen"
	drop _merge 
	rename isod isoo 
	drop if isoo== "OTH"
	rename isoo isoo
	merge 1:1 isoo year using "$intermediate\HumanCap_New"

	drop if _merge==2
	drop _merge 
	rm "$intermediate\Emen.dta" 
	rm "$intermediate\Ewomen.dta" 
	rm "$intermediate\Imen.dta" 
	rm "$intermediate\Iwomen.dta" 
	
	save "$intermediate\rawdata_e-i-rates", replace 
}	


*------------------------------------------------------------------------------*
*    			 Prompt migration rates calculations						   *
*------------------------------------------------------------------------------*	

{
	use "$intermediate\rawdata_e-i-rates", clear 
	rename (HrNew HrfNew HrmNew)(Hr Hrf Hrm)
	gen  Mi = Emig15m + Emig15f
	gen IMi = Imig15m + Imig15f 
	gen Mih = Emig15hsm + Emig15hsf
	gen Mil = Emig15lsm + Emig15lsf
	gen IMih = Imig15hsm + Imig15hsf
	gen IMil = Imig15lsm + Imig15lsf
	
	ge Lab15hs = pop15*Hr
	ge Lab15ls = pop15-Lab15hs 
	ge Lab15hsf= pop15f*Hrf 
	ge Lab15lsf= pop15f-Lab15hsf 
	ge Lab15hsm= pop15m*Hrm 
	ge Lab15lsm= pop15m-Lab15hsm
	
	ge Nat = pop15+Mi
	ge Nath= Lab15hs+Mih
	ge Natl= Nat-Nath  
	ge Natf= pop15f+Emig15f
	ge Natm= pop15m+Emig15m 
	ge Nathf= Lab15hsf+Emig15hsf 
	ge Nathm= Lab15hsm+Emig15hsm 
	
	ge Hn = Nath/Nat 
	ge Hnf= Nathf/Natf 
	ge Hnm= Nathm/Natm 
	
	ge mrateHS = Mih/Nath
	ge mrateLS = Mil/Natl 
	ge mrate   = Mi/Nat 

	ge mrateHSf = Emig15hsf/Nathf
	ge mrateLSf = Emig15lsf/(Natl-Nathf) 
	ge mratef   = Emig15f/Natl
	
	ge mrateHSm = Emig15hsm/Nathm
	ge mrateLSm = Emig15lsm/(Natm-Nathm)  
	ge mratem   = Emig15m/Natm 
	qui sum mrateHSm
	local maxhsm = r(max)
	replace mrateHSf = `maxhsm' if mrateHSf==1 	
	ge irateHS = IMih/Lab15hs
	ge irateLS = IMil/Lab15ls 
	ge irate   = IMi/pop15 
	
	ge irateHSf = Imig15hsf/Lab15hsf
	ge irateLSf = Imig15lsf/Lab15lsf 
	gen iratef   = Imig15f/pop15f

	ge irateHSm = Imig15hsm/Lab15hsm
	ge irateLSm = Imig15lsm/Lab15lsm 
	ge iratem   = Imig15m/pop15m
	qui sum iratem 
	local maxm = r(max)
	replace iratef = `maxm' if iratef>=1 & iratef!=.
	rename pop15 Li
	rename (Emig15hsm Emig15lsm Emig15m Emig15hsf Emig15lsf Emig15f) ///
		   (Mihm Milm Mim Mihf Milf Mif)
	rename (Imig15hsm Imig15lsm Imig15m Imig15hsf Imig15lsf Imig15f) ///
		   (IMMihm IMMilm IMMim IMMihf IMMilf IMMif)		
}


*------------------------------------------------------------------------------*
*    			 Export the sheet to be posted online						   *
*------------------------------------------------------------------------------*
keep country isoo year region10_ori Mihm Milm Mim Mihf Milf Mif IMMihm IMMilm ///
	 IMMim IMMihf IMMilf IMMif iso3 Hr Hrf Hrm Hn Hnf Hnm mrateHS mrateLS mrate ///
	 mrateHSf mrateLSf mratef mrateHSm mrateLSm mratem irate iratef iratem ///
	 pop15f pop15m Li Lab15hs Lab15ls Lab15hsf Lab15lsf Lab15hsm Lab15lsm ///
		 gdppc_cst gdppc_cstppp popm014 popf014 Emig014m Emig014f Imig014m Imig014f
	 
	 egen Emigrants_total = rowtotal(Mim Mif)
	 egen Immigrants_total = rowtotal(IMMim IMMif)
	 egen Emigrants_HS_total = rowtotal(Mihm Mihf)
	 egen Emigrants_LS_total = rowtotal(Milm Milf)
	 egen Immigrants_HS_total= rowtotal(IMMihm IMMihf)
	 egen Immigrants_LS_total= rowtotal(IMMilm IMMilf) 
	 rename (Mihm Milm Mim)(Emigrants_males_HS Emigrants_males_LS Emigrants_males)
	 rename (Mihf Milf Mif)(Emigrants_females_HS Emigrants_females_LS Emigrants_females)
	 rename (IMMihm IMMilm IMMim)(Immigrants_males_HS Immigrants_males_LS Immigrants_males)
	 rename (IMMihf IMMilf IMMif)(Immigrants_females_HS Immigrants_females_LS Immigrants_females)
	 rename (Hrf Hrm Hr) ( Share_HS_females Share_HS_males Share_HS)
	 rename (pop15f pop15m Li)(Labor_females Labor_males Labor)
	 rename (Lab15hs Lab15ls)(Labor_HS Labor_LS)
	 rename (Lab15hsf Lab15lsf)(Labor_females_HS Labor_females_LS)	 
	 rename (Lab15hsm Lab15lsm)(Labor_males_HS Labor_males_LS)
	 rename (mrateHS mrateLS mrate)(mig_rate_HS mig_rate_LS mig_rate)
	 rename (mrateHSf mrateLSf mratef)(mig_rate_HS_female mig_rate_LS_female mig_rate_female)
	 rename (mrateHSm mrateLSm mratem)(mig_rate_HS_male mig_rate_LS_male mig_rate_male)	 
	 rename (irate iratef iratem)(immig_rate immig_rate_female immig_rate_male)
	 rename (Emig014m Emig014f Imig014m Imig014f)(Emigrants_014_male Emigrants_014_female Immigrants_014_male Immigrants_014_female)
	 egen Emigrants_014_total = rowtotal(Emigrants_014_male Emigrants_014_female)
	 egen Immigrants_014_total = rowtotal(Immigrants_014_male Immigrants_014_female)
	 order country isoo year region10_ori iso3
	 
		rename (Share_HS Share_HS_females Share_HS_males)(Share_tertiary_educated Share_tertiary_educated_females Share_tertiary_educated_males)
		
		rename(mig_rate_HS mig_rate_LS mig_rate mig_rate_HS_female mig_rate_LS_female ///
				mig_rate_female mig_rate_HS_male mig_rate_LS_male mig_rate_male) ///
				(emig_rate_HS emig_rate_LS emig_rate emig_rate_HS_female emig_rate_LS_female ///
				emig_rate_female emig_rate_HS_male emig_rate_LS_male emig_rate_male)
		 
		rename(Hn Hnf Hnm)(Share_educated_Nat Share_educated_Nat_females Share_educated_Nat_males)
		
*export excel using "$export\emigration-immigration-rates.xlsx", sheet("Data", ///
*					replace) firstrow(variables) keepcellfmt
					
	local Lab Labor_females Labor_males Labor Labor_HS Labor_LS ///
			  Labor_females_HS Labor_females_LS Labor_males_HS Labor_males_LS	
			  
	foreach var in `Lab' {
		replace `var' = round(`var')
	}
		
export excel using "$export\emigration-immigration-rates.xlsx", sheet("Data", ///
					replace) firstrow(variables) keepcellfmt
					
		
	
*==============================================================================*
*									  Metadata  							   *
*==============================================================================*	
		putexcel set "$export\emigration-immigration-rates.xlsx", sheet("Metadata") modify 
		putexcel A1 = "This dataset compiles at country level immigration and emigration rates. Emigration rates are then computed by education level (High Skilled and Low skilled)"
		putexcel A2 = "Variables"
		putexcel A3 = "region10_ori"
		putexcel B3 = "regional split with development level decomposition"	
		putexcel A4 = "Emigrants_males_HS"
		putexcel B4 = "Tertiary educated men emigrants"
		putexcel A5 ="Emigrants_males_LS"
		putexcel B5 = "Non tertiary educated men emigrants"		
		putexcel A6 ="Emigrants_males"
		putexcel B6 = "Total number of emigrants men"	
		putexcel A7 ="Emigrants_females_HS"
		putexcel B7 = "Tertiary educated women emigrants"
		putexcel A8 ="Emigrants_females_LS"
		putexcel B8 = "Non tertiary educated women emigrants"
		putexcel A9 ="Emigrants_females"
		putexcel B9 = "Total number of emigrants women"		
		putexcel A10 = "Immigrants_males_HS"
		putexcel B10 = "Tertiary educated men immigrants"
		putexcel A11 ="Immigrants_males_LS"
		putexcel B11 = "Non tertiary educated men immigrants"		
		putexcel A12 ="Immigrants_males"
		putexcel B12 = "Total number of immigrants men"	
		putexcel A13 ="Immigrants_females_HS"
		putexcel B13 = "Tertiary educated women immigrants"
		putexcel A14 ="Immigrants_females_LS"
		putexcel B14 = "Non tertiary educated women immigrants"
		putexcel A15 ="Immigrants_females"
		putexcel B15 = "Total number of immigrants women"			
		putexcel A16 ="Share_tertiary_educated"
		putexcel B16 = "Proportion of tertiary educated labor among residents"
		putexcel A17 ="Share_tertiary_educated_females"
		putexcel B17 = "proportion of tertiary educated women among residents"	
		putexcel A18 ="Share_tertiary_educated_males"
		putexcel B18 = "proportion of tertiary educated men among residents"
		putexcel A19 ="immig_rate"
		putexcel B19 = "immigration rate"	
		putexcel A20 ="emig_rate"
		putexcel B20 = "emigration rates"			
		putexcel A21 ="gdppc_cst"
		putexcel B21 = "GDP per capita (constant 2015 US$)"	
		putexcel A22 =" gdppc_cstppp"
		putexcel B22 = "GDP per capita, PPP (constant 2017 international $)"			
		putexcel A23 ="popm014"
		putexcel B23 = "Polulation aged 0-14 males"	
		putexcel A24 =" popf014"
		putexcel B24 = "Polulation aged 0-14 females"					
		putexcel A25 ="Labor_females"
		putexcel B25 = "Population aged 15+ females"	
		putexcel A26 =" Labor_males"
		putexcel B26 = "Population aged 15+ males"			
		putexcel A27 ="Labor"
		putexcel B27 = "Total population aged 15+"		
		putexcel A28 ="Labor_HS"
		putexcel B28 = "Population aged 15+ with tertiary education"	
		putexcel A29 =" Labor_LS"
		putexcel B29 = "Population aged 15+ without tertiary education"					
		putexcel A30 ="Labor_females_HS"
		putexcel B30 = "Population aged 15+ with tertiary education females"	
		putexcel A31 =" Labor_females_LS"
		putexcel B31 = "Population aged 15+ without tertiary education females"			
		putexcel A32 ="Labor_males_HS"
		putexcel B32 = "Population aged 15+ with tertiary education males"	
		putexcel A33 =" Labor_males_LS"
		putexcel B33 = "Population aged 15+ without tertiary education males"		
		putexcel A34 ="emig_rate_HS"
		putexcel B34 = "Proportion of tertiary educated emigrants population aged 15+"	
		putexcel A35 ="emig_rate_LS"
		putexcel B35 = "Proportion of non tertiary educated emigrants population aged 15+"			
		putexcel A36 ="emig_rate_HS_female"
		putexcel B36 = "Proportion of tertiary educated female emigrants population aged 15+"	
		putexcel A37 =" emig_rate_LS_female"
		putexcel B37 = "Proportion of non-tertiary educated female emigrants population aged 15+"		
		putexcel A38 =" emig_rate_female"
		putexcel B38 = "Proportion of female emigrants population aged 15+"			
		putexcel A39 ="emig_rate_HS_male"
		putexcel B39 = "Proportion of tertiary educated male emigrants population aged 15+"	
		putexcel A40 =" emig_rate_LS_male"
		putexcel B40 = "Proportion of non-tertiary educated male emigrants population aged 15+"		
		putexcel A41 =" emig_rate_male"
		putexcel B41 = "Proportion of male emigrants population aged 15+"			
		putexcel A42 =" Emigrants_total"
		putexcel B42 = "Total numbers of emigrants aged 15+"
		putexcel A43 =" Immigrants_total"
		putexcel B43 = "Total numbers of immigrants aged 15+"				
		putexcel A44 =" Emigrants_HS_total"
		putexcel B44 = "Numbers of tertiary educated emigrants aged 15+"		
		putexcel A45 =" Emigrants_LS_total"
		putexcel B45 = "Numbers of non-tertiary educated emigrants aged 15+"		 
		putexcel A46 =" Immigrants_HS_total"
		putexcel B46 = "Numbers of tertiary educated immigrants aged 15+"
		putexcel A47 =" Immigrants_LS_total"
		putexcel B47 = "Numbers of non tertiary educated immigrants aged 15+"				 
		putexcel A48 ="Share_educated_Nat"
		putexcel B48 = "Proportion of tertiary educated labor natives"
		putexcel A49 ="Share_educated_Nat_females"
		putexcel B49 = "proportion of tertiary educated women natives"	
		putexcel A50 ="Share_educated_Nat_males"
		putexcel B50 = "proportion of tertiary educated men natives"    
		putexcel A51 =" Emigrants_014_male"
		putexcel B51 = "Numbers of emigrants aged 0-14 males"				 
		putexcel A52 ="Emigrants_014_female"
		putexcel B52 = "Numbers of emigrants aged 0-14 females"
		putexcel A53 ="Immigrants_014_male"
		putexcel B53 = "Numbers of immigrants aged 0-14 males"	
		putexcel A54 ="Immigrants_014_female"
		putexcel B54 = "Numbers of immigrants aged 0-14 females"
		putexcel A55 ="Emigrants_014_total"
		putexcel B55 = "Total numbers of emigrants aged 0-14"	
		putexcel A56 ="Immigrants_014_total"
		putexcel B56 = "Total numbers of immigrants aged 0-14"
			
		putexcel F2 = "Regional breakdown"
		putexcel F3 = "EAP-HIC"
		putexcel G3 = "High Income East Asia and Pacific"	
		putexcel F4 = "EAP-OTH"
		putexcel G4 = "Non High Income East Asia and Pacific"
		putexcel F5 ="ECA-HIC"
		putexcel G5 = "High Income Europe and Central Asia"		
		putexcel F6 ="ECA-OTH"
		putexcel G6 = "Non High Income East Asia and Pacific"	
		putexcel F7 ="GCC"
		putexcel G7 = "Gulf Cooperation Council"
		putexcel F8 ="LAC"
		putexcel G8 = "Latin America and the Caribbeans"
		putexcel F9 ="MENA-OTH"
		putexcel G9 = "Non High Income Middle East and North Africa"		
		putexcel F10 = "NOAM"
		putexcel G10 = "North America"
		putexcel F11 ="SA"
		putexcel G11 = "South Asia"		
		putexcel F12 ="SSA"
		putexcel G12 = "Sub-Saharan Africa"	
		