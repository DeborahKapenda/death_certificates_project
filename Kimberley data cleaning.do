***Part I - Data cleaning
sysdir set PLUS "D:\Stata"
cd "C:\Users\marku\OneDrive\Dokumente\Uni\Göttingen\Stellenbosch\Economic History\Research paper"
clear
qui foreach i in 1895 1900 1905 1925 1930 1935 1940{
import excel Kimberley_data_`i'.xlsx, firstrow

*Renaming variables 
rename Dayofdeath death_day
rename Monthofdeath death_month
rename Yearofdeath death_year
rename Durationoflastillness illness_duration
 
*Changing ½ to .5 and ¼ to .25 
replace illness_duration = subinstr(illness_duration, "½", ".5", .)
replace illness_duration = subinstr(illness_duration, "¼", ".25", .)

*Changing "One" to 1, "half" to .5
replace illness_duration = subinstr(illness_duration, "One", "1", .)
replace illness_duration = subinstr(illness_duration, "Half an", ".5", .)
replace illness_duration = subinstr(illness_duration, "Half", ".5", .)
replace illness_duration = subinstr(illness_duration, " .5", ".5", .)


*Correcting a range of spelling mistakes 
replace illness_duration = subinstr(illness_duration, "2months", "2 months", .)
replace illness_duration = subinstr(illness_duration, "3months", "3 months", .)
replace illness_duration = subinstr(illness_duration, "3weeks", "3 Weeks", .)
replace illness_duration = subinstr(illness_duration, "1 month 6days", "1 month 6 days", .)
replace illness_duration = subinstr(illness_duration, "2 weeks; 24 hours", "2 weeks 24 hours", .)
replace illness_duration = subinstr(illness_duration, "3 Weeeks", "3 Weeks", .)

qui foreach h in Hospita; Hospitao Hosptal Hosptial Hosital Hospiital {
replace illness_duration = subinstr(illness_duration, "`h'", "Hospital", .)
}
replace illness_duration = subinstr(illness_duration, "Om Hospital", "In Hospital", .)
replace illness_duration = subinstr(illness_duration, "In  Hospital", "In Hospital", .)
replace illness_duration = subinstr(illness_duration, "Inhospital", "In Hospital", .)
replace illness_duration = subinstr(illness_duration, "Houers", "Hours", .)
replace illness_duration = subinstr(illness_duration, "Ddays", "Days", .)
replace illness_duration = subinstr(illness_duration, "Yeear", "Year", .)
replace illness_duration = subinstr(illness_duration, "Form", "From", .)
replace illness_duration = subinstr(illness_duration, "Fron", "From", .)
replace illness_duration = subinstr(illness_duration, "Atb", "Abt", .)

*Removing "In Hospital" and creating a dummy to flag it in the data 
gen dummy_hospital = 1 if strmatch(illness_duration, "*In Hospital*")
la var dummy_hospital "illness_duration was reported with 'In Hospital' after values" 
replace illness_duration = subinstr(illness_duration, "In Hospital", "", .) 

*Removing "Abt", "About", "Omtrent", "±" and creating a dummy to flag it in the data 
gen dummy_about = 1 if strmatch(illness_duration, "*About*")
replace illness_duration = subinstr(illness_duration, "About", "", .) 
la var dummy_about "illness_duration was reported with 'About' in front of values" 
gen dummy_abt = 1 if strmatch(illness_duration, "*Abt*")
la var dummy_abt "illness_duration was reported with 'Abt' in front of values" 
replace illness_duration = subinstr(illness_duration, "Abt", "", .) 
gen dummy_omt = 1 if strmatch(illness_duration, "*Omtrent*")
la var dummy_omt "illness_duration was reported with 'Omtrent' in front of values" 
replace illness_duration = subinstr(illness_duration, "Omtrent", "", .) 
gen dummy_plusminus = 1 if strmatch(illness_duration, "*±*")
la var dummy_plusminus "illness_duration was reported with '±' in front of values" 
replace illness_duration = subinstr(illness_duration, "±", "", .) 

*Separating duration values 
split illness_duration, gen(duration) 

*Creating numeric duration variables with units in days and asserting values reported in other units ///
* --> duration_day = variable of interest!
*Creating dummy to indicate what unit illness_duration was originally reported in 
gen duration_day = real(duration1) if strmatch(duration2, "*day*") & strmatch(duration3, "")
la var duration_day "Duration of last illness reported in days and converted from other units"  
replace duration_day = real(duration1) if strmatch(duration2, "*Dag*")& strmatch(duration3, "")
replace duration_day = real(duration1) if strmatch(duration2, "*Dae*")& strmatch(duration3, "")
replace duration_day = real(duration1) if strmatch(duration2, "*Day*")& strmatch(duration3, "")
gen dummy_days =1 if inlist(duration2, "day", "days", "Dag", "Dae", "Day", "Days") & strmatch(duration3, "")
la var dummy_days "'illness_duration' was originally reported in days" 
*Years --> Days
replace duration_day = real(duration1)*365 if strmatch(duration2, "*Year*")& strmatch(duration3, "")
replace duration_day = real(duration1)*365 if strmatch(duration2, "*year*")& strmatch(duration3, "")
replace duration_day = real(duration1)*365 if strmatch(duration2, "*Jaar*")& strmatch(duration3, "")
gen dummy_years =1 if inlist(duration2, "Year", "year", "Years", "years", "Jaar", "jaar") & strmatch(duration3, "")
la var dummy_years "'illness_duration' was originally reported in years" 
*Months --> Days
replace duration_day = real(duration1)*30 if strmatch(duration2, "*Month*")& strmatch(duration3, "") 
replace duration_day = real(duration1)*30 if strmatch(duration2, "*month*")& strmatch(duration3, "") 
replace duration_day = real(duration1)*30 if strmatch(duration2, "*Maand*")& strmatch(duration3, "") 
gen dummy_months =1 if inlist(duration2, "Month", "month", "Months", "months", "Maand") & strmatch(duration3, "")
la var dummy_months "'illness_duration' was originally reported in months" 
*Weeks --> Days
replace duration_day = real(duration1)*7 if strmatch(duration2, "*Week*")& strmatch(duration3, "") 
replace duration_day = real(duration1)*7 if strmatch(duration2, "*Weke*")& strmatch(duration3, "") 
replace duration_day = real(duration1)*7 if strmatch(duration2, "*week*")& strmatch(duration3, "") 
gen dummy_weeks =1 if inlist(duration2, "Week", "week", "Weeks", "weeks", "Weke") & strmatch(duration3, "")
la var dummy_weeks "'illness_duration' was originally reported in weeks" 
*Hours --> Days
replace duration_day = real(duration1)/24 if strmatch(duration2, "*Hour*")& strmatch(duration3, "") 
replace duration_day = real(duration1)/24 if strmatch(duration2, "*hour*")& strmatch(duration3, "") 
gen dummy_hours =1 if inlist(duration2, "Hour", "hour", "Hours", "hours") & strmatch(duration3, "")
la var dummy_hours "'illness_duration' was originally reported in hours" 
*Minutes --> Days
replace duration_day = real(duration1)/1440 if strmatch(duration2, "*Minute*")& strmatch(duration3, "")
replace duration_day = real(duration1)/1440 if strmatch(duration2, "*minute*")& strmatch(duration3, "")
gen dummy_minutes =1 if inlist(duration2, "Minute", "minute", "Minutes", "minutes") & strmatch(duration3, "")
la var dummy_minutes "'illness_duration' was originally reported in minutes" 

*Years Months
replace duration_day =(real(duration1)*365 + real(duration3)*30) if strmatch(duration2, "*Year*") & strmatch(duration4, "*Month*") & strmatch(duration5, "")  
replace duration_day =(real(duration1)*365 + real(duration3)*30) if strmatch(duration2, "*year*") & strmatch(duration4, "*month*") & strmatch(duration5, "")    
*Years Weeks
replace duration_day =(real(duration1)*365 + real(duration3)*7) if strmatch(duration2, "*Year*") & strmatch(duration4, "*Week*")  & strmatch(duration5, "")  
replace duration_day =(real(duration1)*365 + real(duration3)*7) if strmatch(duration2, "*year*") & strmatch(duration4, "*week*")  & strmatch(duration5, "")  
*Years Days
replace duration_day =(real(duration1)*365 + real(duration3)) if strmatch(duration2, "*Year*") & strmatch(duration4, "*Day*") & strmatch(duration5, "")    
replace duration_day =(real(duration1)*365 + real(duration3)) if strmatch(duration2, "*year*") & strmatch(duration4, "*day*") & strmatch(duration5, "")    
*Months Weeks
replace duration_day =(real(duration1)*30 + real(duration3)*7) if strmatch(duration2, "*Month*") & strmatch(duration4, "*Week*") & strmatch(duration5, "")    
replace duration_day =(real(duration1)*30 + real(duration3)*7) if strmatch(duration2, "*month*") & strmatch(duration4, "*week*") & strmatch(duration5, "")    
*Months Days
replace duration_day =(real(duration1)*30 + real(duration3)) if strmatch(duration2, "*Month*") & strmatch(duration4, "*Day*") & strmatch(duration5, "")  
replace duration_day =(real(duration1)*30 + real(duration3)) if strmatch(duration2, "*month*") & strmatch(duration4, "*day*") & strmatch(duration5, "")    
*Weeks Days
replace duration_day =(real(duration1)*7 + real(duration3)) if (strmatch(duration2, "*Week*") & strmatch(duration4, "*Day*")) & strmatch(duration5, "")  
replace duration_day =(real(duration1)*7 + real(duration3)) if (strmatch(duration2, "*week*") & strmatch(duration4, "*day*")) & strmatch(duration5, "")  
*Weeks Hours
replace duration_day =(real(duration1)*7 + real(duration3)/24) if (strmatch(duration2, "*Week*") & strmatch(duration4, "*Hour*")) & strmatch(duration5, "")  
replace duration_day =(real(duration1)*7 + real(duration3)/24) if (strmatch(duration2, "*week*") & strmatch(duration4, "*hour*")) & strmatch(duration5, "")  
*Days Hours
replace duration_day =(real(duration1) + real(duration3)/24) if strmatch(duration2, "*Day*") & strmatch(duration4, "*Hour*") & strmatch(duration5, "")    
replace duration_day =(real(duration1) + real(duration3)/24) if strmatch(duration2, "*day*") & strmatch(duration4, "*hour*") & strmatch(duration5, "")    
*Weeks + Days
replace duration_day =(real(duration1)*7 + real(duration4)) if (strmatch(duration2, "*Week*") & strmatch(duration5, "*Day*")) & strmatch(duration6, "")    
replace duration_day =(real(duration1)*7 + real(duration4)) if (strmatch(duration2, "*week*") & strmatch(duration5, "*day*")) & strmatch(duration6, "")    
*Months + Weeks
replace duration_day =(real(duration1)*30 + real(duration4)*7) if strmatch(duration2, "*Month*") & strmatch(duration5, "*Week*") & strmatch(duration6, "")   
replace duration_day =(real(duration1)*30 + real(duration4)*7) if strmatch(duration2, "*month*") & strmatch(duration5, "*week*") & strmatch(duration6, "")  

*Creating Date of Death variable
egen death_date = concat(death_day death_month death_year), punct(".")
la var death_date "Date of death as string variable"
gen death_date2 = date(death_date, "DMY", 1999)
la var death_date2 "Date of death" 
gen illness_date =date(duration2, "DMY", 1999) if strmatch(duration1, "*From*") 
la var illness_date "'illness_duration'reported as date"
replace illness_date = date(duration4, "DMY", 1999) if strmatch(duration3, "*From*") 
format death_date2 %td
format illness_date %td

*Creating dummy if duration was reported as a date instead of a number ///
*and calculating the difference between date of death and duration_date
gen dummy_from = 1 if strmatch(duration1, "*From*") | strmatch(duration3, "*From*")
la var dummy_from "illness_duration was reported as 'From *date*'" 
replace duration_day = (death_date2 - illness_date) if dummy_from==1

save Kimberley_data_`i'.dta, replace
clear
}

*Importing and appending datasets
use Kimberley_data_1895.dta, clear 
qui foreach i in 1900 1905 1925 1930 1935 1940 {
append using Kimberley_data_`i', force
}

*1935 has missing Year because of string variable --> replace 
replace Year = 1935 if Year ==. 

save Kimberley_alldatasets.dta, replace

*Dropping missing or incorrect values 
drop if duration_day ==. | duration_day <0.0000001 | duration_day > 10000
drop if Year == 1935 & strmatch(Town, "")
local missing "Single Helena Years B. Illegible ."
qui foreach v of local missing {
drop if strmatch(Race, "*`v'") 
}

*Creating a numeric race variable: 1 = Black; 2 = Colored; 3 = White
*Blacks
gen race = 1 if strmatch(Race, "*Native*") | strmatch(Race, "*Kaffir*") 
la var race "Numeric race variable: 1 = Black; 2 = Colored; 3 = White" 
la define race 1 "Black" 2 "Colored" 3 "White"
label values race race
*Coloreds
local Colored "Mixed mixed Colored Coloured Couloured German India Asia China Chinese Malay Syrian Hindoo Hindoe Afgan" 
qui foreach a of local Colored{
replace race = 2 if strmatch(Race, "*`a'*")
} 
*Whites
local White "White English Dutch Scotch European Portuguese Portugees British Britsh Irish Jew Greek "
foreach b of local White{
replace race = 3 if strmatch(Race, "*`b'*")   
}  
*Dropping missing values 
replace race = 999 if strmatch(Race, "*Bastard*") 
replace race = 1 if race ==.
drop if race ==999
replace Year = 1925 if Year == 1926
*Years and Days as illness_duration is judged to be not reliable information
drop if strmatch(duration2, "*Year*") & strmatch(duration4, "*Days*") 
save Kimberley_alldatasets.dta, replace 
