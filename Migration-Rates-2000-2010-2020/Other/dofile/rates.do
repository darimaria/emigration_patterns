
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
global code   		"$path\dofile"
global data   		"$path\rawdata"
global intermediate "$path\intermediate_data"
global output 		"$path\output"	
global migration    "C:\Users\\${UPI}\WBG\WDR2023 - WB Group - WDR2023 Team - WDR2023 Team\Data Replication\WDR Data Files\2000-2010-2020\output"


*------------------------------------------------------------------------------*
*    			                   Migration data 							   *
*------------------------------------------------------------------------------*

	use "$migration\BIL_MIG_SEX_EDU_2000_2010_2020", clear 

	keep isoo isod ODid sex year mig15hs mig15lms mig15 country region10_ori

{
	preserve 
	keep if sex==1
	
	foreach var of varlist mig15hs mig15lms mig15 {
	    bys isoo year: egen E`var' = total(`var')
	}
	sort isoo year 
	quietly by isoo year: gen dup = cond(_N==1,0,_n)
	drop if dup>1 
	keep  country isoo region10_ori E* year 
	rename(Emig15hs Emig15lms Emig15)(Emig15hsm Emig15lsm Emig15m)
	save "$intermediate\Emen", replace 
	restore
}

{	
	preserve 
	keep if sex==2
	
	foreach var of varlist mig15hs mig15lms mig15 {
	    bys isoo year: egen E`var' = total(`var')
	}
	sort isoo year 
	quietly by isoo year: gen dup = cond(_N==1,0,_n)
	drop if dup>1 
	keep  country isoo region10_ori E* year 
	rename(Emig15hs Emig15lms Emig15)(Emig15hsf Emig15lsf Emig15f)
	save "$intermediate\Ewomen", replace 
	restore
}

{	
	preserve 
	keep if sex==1
	
	foreach var of varlist mig15hs mig15lms mig15 {
	    bys isod year: egen I`var' = total(`var')
	}
	sort isod year 
	quietly by isod year: gen dup = cond(_N==1,0,_n)
	drop if dup>1 
	keep isod region10_ori I* year 
	rename(Imig15hs Imig15lms Imig15)(Imig15hsm Imig15lsm Imig15m)
	save "$intermediate\Imen", replace 
	restore
}

{	
	preserve 
	keep if sex==2
	
	foreach var of varlist mig15hs mig15lms mig15 {
	    bys isod year: egen I`var' = total(`var')
	}
	sort isod year 
	quietly by isod year: gen dup = cond(_N==1,0,_n)
	drop if dup>1 
	keep isod region10_ori I* year 
	rename(Imig15hs Imig15lms Imig15)(Imig15hsf Imig15lsf Imig15f)
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
	 mrateHSf mrateLSf mratef mrateHSm mrateLSm mratem irate iratef iratem
	
export excel using "$output\e-i-migration-rates_.xlsx", sheet("rates-both", ///
					replace) firstrow(variables) keepcellfmt	   
	
	

	
	