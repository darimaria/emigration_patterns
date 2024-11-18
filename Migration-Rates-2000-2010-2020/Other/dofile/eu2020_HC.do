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
global eulfs20   	"C:\Users\\${UPI}\WBG\WDR2023 - WB Group - WDR2023 Team - WDR2023 Team\Data Replication\WDR Data Files\2020\EU-LFS\rawdata"
global intermediate "$path\intermediate_data"
global output 		"$path\output"	

*------------------------------------------------------------------------------*
*    			              Education shares EULFS2020					   *
*------------------------------------------------------------------------------*

	local cid = 1
	ge cid =.
	local csvfiles: dir "$eulfs20" files "*.csv"
foreach file of local csvfiles {
 preserve
 insheet using "$eulfs20/`file'", clear

		rename country iso2
 		keep if countryb == "000-OWN COUNTRY" 
		
	ge cid = `cid'

	
/*	
	age decomposition: [0-4], [5-9], [10-14], [15-19], 
	[20-24], [25-29], [30-34], [35-39], [40-44], [45-49],
	[50-54], ..., [95-99]
*/
	ge agegrp=.
	replace agegrp=1 if age<=12
	replace agegrp=2 if age>12 & age<=22
	replace agegrp=3 if age>22 & age<=32 
	replace agegrp=4 if age>32 & age<=42 
	replace agegrp=5 if age>42 & age<=52
	replace agegrp=6 if age>52 & age<=62
	replace agegrp=7 if age>62

/*
education decomposition based on variable "educlevl" variable
classified according  to the International Standard 
Classification of Education (ISCED)
*/
	ge educ=.
	replace educ = 1 if hat11lev >400 & hat11lev<900
	replace educ = 2 if hat11lev >=200 & hat11lev<=400
	replace educ = 3 if hat11lev == 100 
	replace educ = . if agegrp == 1

	ge pers = 1
	
	bys sex agegrp educ: egen number = total(pers)

    keep sex agegrp educ number cid iso2 
    quietly by sex agegrp educ:  gen dup = cond(_N==1,0,_n)
	drop if dup>1
	drop dup
	
		ge _014  = number if agegrp==1
		ge _014m = number if agegrp==1 & sex==1
		ge _014f = number if agegrp==1 & sex==2
		ge _1524 = number if agegrp==2
		ge _1524m= number if agegrp==2 & sex==1
		ge _1524f= number if agegrp==2 & sex==2	
		ge _2534 = number if agegrp==3
		ge _2534m= number if agegrp==3 & sex==1
		ge _2534f= number if agegrp==3 & sex==2		
		ge _3544 = number if agegrp==4
		ge _3544m= number if agegrp==4 & sex==1
		ge _3544f= number if agegrp==4 & sex==2	
		ge _4554 = number if agegrp==5
		ge _4554m= number if agegrp==5 & sex==1
		ge _4554f= number if agegrp==5 & sex==2	
		ge _5564 = number if agegrp==6
		ge _5564m= number if agegrp==6 & sex==1
		ge _5564f= number if agegrp==6 & sex==2	
		ge _65_  = number if agegrp==6
		ge _65_m = number if agegrp==6 & sex==1
		ge _65_f = number if agegrp==6 & sex==2	
		
		ge _15HS = number if educ==1
		ge _1524HS = number if agegrp==2 & educ==1
		ge _1524HSm= number if agegrp==2 & sex==1 & educ==1
		ge _1524HSf= number if agegrp==2 & sex==2 & educ==1	
		ge _2534HS = number if agegrp==3 & educ==1
		ge _2534HSm= number if agegrp==3 & sex==1 & educ==1
		ge _2534HSf= number if agegrp==3 & sex==2 & educ==1		
		ge _3544HS = number if agegrp==4 & educ==1
		ge _3544HSm= number if agegrp==4 & sex==1 & educ==1
		ge _3544HSf= number if agegrp==4 & sex==2 & educ==1	
		ge _4554HS = number if agegrp==5 & educ==1
		ge _4554HSm= number if agegrp==5 & sex==1 & educ==1
		ge _4554HSf= number if agegrp==5 & sex==2 & educ==1	
		ge _5564HS = number if agegrp==6 & educ==1
		ge _5564HSm= number if agegrp==6 & sex==1 & educ==1
		ge _5564HSf= number if agegrp==6 & sex==2 & educ==1	
		ge _65HS_  = number if agegrp==6 & educ==1
		ge _65HS_m = number if agegrp==6 & sex==1 & educ==1
		ge _65HS_f = number if agegrp==6 & sex==2 & educ==1		
			
		ge _1524MS = number if agegrp==2 & educ==2
		ge _1524MSm= number if agegrp==2 & sex==1 & educ==2
		ge _1524MSf= number if agegrp==2 & sex==2 & educ==2	
		ge _2534MS = number if agegrp==3 & educ==2
		ge _2534MSm= number if agegrp==3 & sex==1 & educ==2
		ge _2534MSf= number if agegrp==3 & sex==2 & educ==2		
		ge _3544MS = number if agegrp==4 & educ==2
		ge _3544MSm= number if agegrp==4 & sex==1 & educ==2
		ge _3544MSf= number if agegrp==4 & sex==2 & educ==2	
		ge _4554MS = number if agegrp==5 & educ==2
		ge _4554MSm= number if agegrp==5 & sex==1 & educ==2
		ge _4554MSf= number if agegrp==5 & sex==2 & educ==2	
		ge _5564MS = number if agegrp==6 & educ==2
		ge _5564MSm= number if agegrp==6 & sex==1 & educ==2
		ge _5564MSf= number if agegrp==6 & sex==2 & educ==2	
		ge _65MS_  = number if agegrp==6 & educ==2
		ge _65MS_m = number if agegrp==6 & sex==1 & educ==2
		ge _65MS_f = number if agegrp==6 & sex==2 & educ==2	
		
		ge _1524LS = number if agegrp==2 & educ==3
		ge _1524LSm= number if agegrp==2 & sex==1 & educ==3
		ge _1524LSf= number if agegrp==2 & sex==2 & educ==3	
		ge _2534LS = number if agegrp==3 & educ==3
		ge _2534LSm= number if agegrp==3 & sex==1 & educ==3
		ge _2534LSf= number if agegrp==3 & sex==2 & educ==3		
		ge _3544LS = number if agegrp==4 & educ==3
		ge _3544LSm= number if agegrp==4 & sex==1 & educ==3
		ge _3544LSf= number if agegrp==4 & sex==2 & educ==3	
		ge _4554LS = number if agegrp==5 & educ==3
		ge _4554LSm= number if agegrp==5 & sex==1 & educ==3
		ge _4554LSf= number if agegrp==5 & sex==2 & educ==3	
		ge _5564LS = number if agegrp==6 & educ==3
		ge _5564LSm= number if agegrp==6 & sex==1 & educ==3
		ge _5564LSf= number if agegrp==6 & sex==2 & educ==3	
		ge _65LS_  = number if agegrp==6 & educ==3
		ge _65LS_m = number if agegrp==6 & sex==1 & educ==3
		ge _65LS_f = number if agegrp==6 & sex==2 & educ==3
		
		
		foreach v of varlist _014-_65LS_f {
			bys cid: egen v`v' = total(`v')
		}
		keep cid v_*  iso2 
	   
		quietly by cid:  gen dup = cond(_N==1,0,_n)
		drop if dup>1
		drop dup
		rename (v_014 v_014m v_014f v_1524 v_1524m v_1524f v_2534 v_2534m v_2534f v_3544 v_3544m v_3544f v_4554 v_4554m v_4554f v_5564 v_5564m v_5564f v_65_ v_65_m v_65_f v_15HS v_1524HS v_1524HSm v_1524HSf v_2534HS v_2534HSm v_2534HSf v_3544HS v_3544HSm v_3544HSf v_4554HS v_4554HSm v_4554HSf v_5564HS v_5564HSm v_5564HSf v_65HS_ v_65HS_m v_65HS_f v_1524MS v_1524MSm v_1524MSf v_2534MS v_2534MSm v_2534MSf v_3544MS v_3544MSm v_3544MSf v_4554MS v_4554MSm v_4554MSf v_5564MS v_5564MSm v_5564MSf v_65MS_ v_65MS_m v_65MS_f v_1524LS v_1524LSm v_1524LSf v_2534LS v_2534LSm v_2534LSf v_3544LS v_3544LSm v_3544LSf v_4554LS v_4554LSm v_4554LSf v_5564LS v_5564LSm v_5564LSf v_65LS_ v_65LS_m v_65LS_f) (_014 _014m _014f _1524 _1524m _1524f _2534 _2534m _2534f _3544 _3544m _3544f _4554 _4554m _4554f _5564 _5564m _5564f _65_ _65_m _65_f _15HS _1524HS _1524HSm _1524HSf _2534HS _2534HSm _2534HSf _3544HS _3544HSm _3544HSf _4554HS _4554HSm _4554HSf _5564HS _5564HSm _5564HSf _65HS_ _65HS_m _65HS_f _1524MS _1524MSm _1524MSf _2534MS _2534MSm _2534MSf _3544MS _3544MSm _3544MSf _4554MS _4554MSm _4554MSf _5564MS _5564MSm _5564MSf _65MS_ _65MS_m _65MS_f _1524LS _1524LSm _1524LSf _2534LS _2534LSm _2534LSf _3544LS _3544LSm _3544LSf _4554LS _4554LSm _4554LSf _5564LS _5564LSm _5564LSf _65LS_ _65LS_m _65LS_f)
		
*** Share of differents groups
	** age and gender groups 
		ge sh_014 = _014/(_014 + _1524 + _2534 + _3544 + _4554 + _5564 + _65_)
		ge sh_014m = _014m/(_014m + _1524m + _2534m + _3544m + _4554m + _5564m + _65_m)	
		ge sh_014f = _014f/(_014f + _1524f + _2534f + _3544f + _4554f + _5564f + _65_f)
		
		ge sh_1524 = _1524/(_014 + _1524 + _2534 + _3544 + _4554 + _5564 + _65_)
		ge sh_1524m = _1524m/(_014m + _1524m + _2534m + _3544m + _4554m + _5564m + _65_m)	
		ge sh_1524f = _1524f/(_014f + _1524f + _2534f + _3544f + _4554f + _5564f + _65_f)		
		
		ge sh_2534 = _2534/(_014 + _1524 + _2534 + _3544 + _4554 + _5564 + _65_)
		ge sh_2534m = _2534m/(_014m + _1524m + _2534m + _3544m + _4554m + _5564m + _65_m)	
		ge sh_2534f = _2534f/(_014f + _1524f + _2534f + _3544f + _4554f + _5564f + _65_f)
		
		ge sh_3544 = _3544/(_014 + _1524 + _2534 + _3544 + _4554 + _5564 + _65_)
		ge sh_3544m = _3544m/(_014m + _1524m + _2534m + _3544m + _4554m + _5564m + _65_m)	
		ge sh_3544f = _3544f/(_014f + _1524f + _2534f + _3544f + _4554f + _5564f + _65_f)

		ge sh_4554 = _4554/(_014 + _1524 + _2534 + _3544 + _4554 + _5564 + _65_)
		ge sh_4554m = _4554m/(_014m + _1524m + _2534m + _3544m + _4554m + _5564m + _65_m)	
		ge sh_4554f = _4554f/(_014f + _1524f + _2534f + _3544f + _4554f + _5564f + _65_f)
		
		ge sh_5564 = _5564/(_014 + _1524 + _2534 + _3544 + _4554 + _5564 + _65_)
		ge sh_5564m = _5564m/(_014m + _1524m + _2534m + _3544m + _4554m + _5564m + _65_m)	
		ge sh_5564f = _5564f/(_014f + _1524f + _2534f + _3544f + _4554f + _5564f + _65_f)

		ge sh_65_ = _65_/(_014 + _1524 + _2534 + _3544 + _4554 + _5564 + _65_)
		ge sh_65_m = _65_m/(_014m + _1524m + _2534m + _3544m + _4554m + _5564m + _65_m)	
		ge sh_65_f = _65_f/(_014f + _1524f + _2534f + _3544f + _4554f + _5564f + _65_f)
		
	** skills 
	 *HS
		egen _15tot = rowtotal(_1524 _2534 _3544 _4554 _5564 _65_)
		egen _15HSf = rowtotal(_1524HSf _2534HSf _3544HSf _4554HSf _5564HSf _65HS_f)
		egen _15HSm = rowtotal(_1524HSm _2534HSm _3544HSm _4554HSm _5564HSm _65HS_m)
		egen _15f = rowtotal(_1524f _2534f _3544f _4554f _5564f _65_f)
		egen _15m = rowtotal(_1524m _2534m _3544m _4554m _5564m _65_m)
		
		ge sh_15HS = _15HS/(_15tot) 
		ge sh_15HSf = _15HSf/(_15f)
		ge sh_15HSm = _15HSm/(_15m)
		
		keep cid sh_15HS sh_15HSf sh_15HSm iso2
		
 save "$intermediate\tempcid", replace
 restore
 local cid = `cid' + 1
 dis `cid'
 append using "$intermediate\tempcid"
}
rm "$intermediate\tempcid.dta" 

	lab define cid 1 "AUT" 2 "BGR" 3 "BEL" 4 "CHE" 5 "CYP" 6 "CZE" 7 "DEU" 8 "DNK" 9 "EST" 10 "ESP" 11 "FIN" 12 "FRA" 13 "GRC" 14 "HRV" 15 "HUN" 16 "IRL" 17 "ITA" 18 "LTU" 19 "LUX" 20 "LVA" 21 "MLT" 22 "NLD" 23 "NOR" 24 "POL" 25 "PRT" 26 "ROM" 27 "SWE" 28 "SVN" 29 "SVK" 30 "GBR", modify
	lab value cid cid	
	ge country= ""
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
	replace country= "Italy" if cid==17
	replace country= "Lituania" if cid==18
	replace country= "Luxembourg" if cid==19
	replace country= "Latvia" if cid==20
	replace country= "Malta" if cid==21
	replace country= "Netherland" if cid==22
	replace country= "Norway" if cid==23
	replace country= "Poland" if cid==24
	replace country= "Portugal" if cid==25
	replace country= "Romania" if cid==26
	replace country= "Sweden" if cid==27
	replace country= "Slovenia" if cid==28
	replace country= "Slovakia" if cid==29
	replace country= "United  Kingdom" if cid==30

	
	order cid country iso2 

	gen year= 2020
save "$intermediate\sh_eulfs_cid2020", replace

