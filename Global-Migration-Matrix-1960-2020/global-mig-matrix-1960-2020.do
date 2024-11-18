
*------------------------------------------------------------------------------*
*    			                   Setup									   *
*------------------------------------------------------------------------------*
clear all
  
global UPI = c(username)

*Set directory
global path "C:\Users\\${UPI}\WBG\WDR2023 - WB Group - WDR2023 Team - WDR2023 Team\Data Replication\Migration-data\Global Migration Matrix 1960-2020"

cd "$path"

*Locations
global url_wbg "https://datacatalog.worldbank.org/search/dataset/0039577"
global data   		"$path\OTHERS"
global output 		"$path"
global migration "C:\Users\\${UPI}\WBG\WDR2023 - WB Group - WDR2023 Team - WDR2023 Team\Data Replication\Migration-data\WBGBMM-2000-2010-2020"


*------------------------------------------------------------------------------*
*    			             Upload	1960-1990								   *
*------------------------------------------------------------------------------*

import excel "$data\Global_Bilateral_MigrationWBG.xlsx", sheet("Data (2)") firstrow clear 

rename(G H I J K)(mig1960 mig1970 mig1980 mig1990 mig2000)
rename(CountryOriginName CountryOriginCode MigrationbyGenderName ///
	   MigrationbyGenderCode CountryDestName CountryDestCode) ///
	   (country_o isoo gender sex country_d isod)
	   
	   drop if sex == "TOT"
	   drop gender
	   local mig mig1960 mig1970 mig1980 mig1990 mig2000
	   foreach var in `mig' {
	   	replace `var' = 0 if `var' ==.
	   }
	   egen ij = concat(isoo isod)
	   drop  if ij==""
	   reshape long mig, i(ij sex) j(year)
	   drop if isoo== "zzz" // this removes refugees
	   
*------------------------------------------------------------------------------*
* 	       grouping occupied/overseas territories with homeland countries      *
*------------------------------------------------------------------------------*
		
	replace isoo = "USA" if inlist(isoo,"ASM","GUM","MNP","PRI","VIR")
	replace isoo = "DNK" if inlist(isoo,"FRO","GRL")
	replace isoo = "FRA" if inlist(isoo,"GUF","GLP","MTQ","MYT","PYF","SPM","WLF")
	replace isoo = "FRA" if inlist(isoo,"NCL","REU")
	replace isoo = "NLD" if inlist(isoo,"BES","ABW","CUW","SXM")
	replace isoo = "GBR" if inlist(isoo,"AIA","BMU","VGB","CYM","FLK","GIB")
	replace isoo = "GBR" if inlist(isoo,"MSR","SHN","CHA","TCA","IMN")	
	replace isoo = "NZL" if inlist(isoo,"COK","TKL")	

	replace isod = "USA" if inlist(isod,"ASM","GUM","MNP","PRI","VIR")
	replace isod = "DNK" if inlist(isod,"FRO","GRL")
	replace isod = "FRA" if inlist(isod,"GUF","GLP","MTQ","MYT","PYF","SPM","WLF")
	replace isod = "FRA" if inlist(isod,"NCL","REU")
	replace isod = "NLD" if inlist(isod,"BES","ABW","CUW","SXM")
	replace isod = "GBR" if inlist(isod,"AIA","BMU","VGB","CYM","FLK","GIB")
	replace isod = "GBR" if inlist(isod,"MSR","SHN","CHA","TCA","IMN")	
	replace isod = "NZL" if inlist(isod,"COK","TKL")
	
	
	**** iso3 consistent across datasets (UN and E-DIOC)
	replace isoo = "ZAR" if isoo== "COD"
	replace isoo = "ROM" if isoo== "ROU"
	replace isoo = "YUG" if isoo== "SCG"
	replace isoo = "YUG" if isoo== "SRB"
	replace isoo = "TMP" if isoo== "TLS"
	replace isoo = "YUG" if isoo== "MNE"
	
	replace isod = "ZAR" if isod== "COD"
	replace isod = "ROM" if isod== "ROU"
	replace isod = "YUG" if isod== "SCG"
	replace isod = "YUG" if isod== "SRB"
	replace isod = "TMP" if isod== "TLS"
	replace isod = "YUG" if isod== "MNE"
	drop if isoo == "VAT"
	
	drop ij 
	
	egen ij= concat(isoo isod)

	bys ij sex year: egen  New_mig = total(mig)
		

	keep  isoo isod ij year sex New_mig 
	
	sort ij year sex
    quietly by ij year sex:  gen dup = cond(_N==1,0,_n)
	drop if dup>1
	drop dup
	drop if isoo == isod 
	replace sex = "male" if sex == "MAL"
	replace sex = "female" if sex == "FEM"
	rename New_mig mig 
	drop if year == 2000
	save "$data\world1960-1990", replace 
	
	
*------------------------------------------------------------------------------*
*    			             Upload	2000-2010-2020							   *
*------------------------------------------------------------------------------*
	
import excel "$migration\WBGBMM_2000_2010_2020.xlsx", sheet("Data") firstrow clear 
egen mig = rowtotal(mig15hs mig15lms mig014)

preserve
keep CtryName_origin region10_ori isoo oecd_ori
sort isoo 
quietly by isoo: ge dup = cond(_N==1,0,_n)
drop if dup>1
drop dup 
save "$data\isoo197", replace
rename (CtryName_origin region10_ori isoo oecd_ori)(CtryName_destination region10_des isod oecd_des)
save "$data\isod197", replace
restore 

keep isoo isod year sex mig 
egen ij = concat(isoo isod)

append using "$data\world1960-1990"
merge n:1 isoo using "$data\isoo197"
drop if _merge == 1 // this removes ANT, CHI, NFK, TWN, XKX
drop _merge 
merge n:1 isod using "$data\isod197"
drop if _merge == 1 // this removes ANT, CHI, NFK, TWN, XKX
drop if _merge == 2
drop _merge 

order isoo CtryName_origin isod CtryName_destination sex region10_ori region10_des ij
sort year 
drop ij

export excel using "$output\WBMM_1960_2020.xlsx", sheet("Data") sheetmodify firstrow(variables)

*==============================================================================*
*									  Metadata  							   *
*==============================================================================*	
		putexcel set "$output\WBMM_1960_2020.xlsx", sheet("Metadata") modify 
		putexcel A1 = "The World Bilateral migration matrix (WBMM) is an extension of the World Bank Global Bilateral Migration 1960-2000. The the new WBMM extends this bilateral migration split by gender to have a longer time series ranging from 1960 to 2020 with 10 years interval. It consists of 197 x 197 origin-destination country pairs."
		putexcel A2 = "Variable"
		putexcel A3 = "mig"
		putexcel B3 = "Number of people born in origin isoo and residing in destination isod"
	