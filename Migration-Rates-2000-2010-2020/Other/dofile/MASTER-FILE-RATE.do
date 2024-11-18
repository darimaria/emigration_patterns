
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


	{
	do "$code\eu2010_HC.do"
	}

	{
	do "$code\eu2020_HC.do"
	}

	{
	do "$code\WittgensteinCentre.do" 
	}

	{
	do "$code\covariates.do" 
	}

	{
	do "$code\HumCap.do"  
	}

	{
	do "$code\rates.do"   
	}
	
	