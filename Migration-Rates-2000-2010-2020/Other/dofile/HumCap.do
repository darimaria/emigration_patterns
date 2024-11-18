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
*    			   				    Human capital data 						   *
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
		 Lab15f Lab15m popf popm popm014 popf014 isoo Hr15 Hr15f Hr15m
	ge Hr_wge = Hr15 
	ge Hrf_wge= Hr15f  
	ge Hrm_wge= Hr15m 

	keep iso3 country isoo year Hr_wge Hrf_wge Hrm_wge popf popm popm014 popf014
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
	keep iso3 country year popf popm popm014 popf014 isoo Hr Hrf Hrm
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
		 Lab15hs Lab15ls Lab15hsf Lab15lsf Lab15hsm Lab15lsm
		 
		 foreach a of varlist Lab15f-Lab15lsm {
		 	replace `a' = . if `a'==0
		 }
		 
	save "$intermediate\HumCap_WDR", replace 
/*	
	rm sh_eulfs_cid2010a.dta
	rm HumCap_eulfs1020.dta
	rm iso3_197.dta 
	rm HumCap_intermediate.dta 
*/	
	
******* export table for Matthew 	
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
	keep iso3 isoo country year popm popf popm014 popf014 Hr Hrf Hrm
	rename (Hr Hrf Hrm)(HrNew HrfNew HrmNew)
	ge pop15f = popf-popf014
	ge pop15m = popm-popm014 
	ge pop15 = pop15f+pop15m
	keep iso3 isoo country year HrNew HrfNew HrmNew ///
		 pop15f pop15m pop15
	save "$intermediate\HumanCap_New", replace
	
