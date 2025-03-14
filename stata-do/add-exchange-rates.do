use "$work_data/exchange-rates.dta", clear
cap drop _fillin titlename shortname region1 region2 region3 region4 region5 corecountry TH
append using "$work_data/add-ppp-output.dta"

// Add Chinese exchange rates to urban and rural China
drop if inlist(iso, "CN-UR", "CN-RU") & substr(widcode, 1, 3) == "xlc"

expand 2 if (iso == "CN") & substr(widcode, 1, 3) == "xlc", generate(newobs)
replace iso = "CN-UR" if newobs
drop newobs

expand 2 if (iso == "CN") & substr(widcode, 1, 3) == "xlc", generate(newobs)
replace iso = "CN-RU" if newobs
drop newobs

compress
label data "Generated by add-exchange-rates.do"
save "$work_data/add-exchange-rates-output.dta", replace
