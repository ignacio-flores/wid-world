import excel using "$wtid_data/CFCNFIGDP_WID2024.xls", firstrow clear // Modif in UK dropping 1920a

reshape long GDP CFC NFI SCFC, i(TIME) j(iso) string

drop SCFC 
rename TIME year
sort iso year
rename GDP valuemgdpro999i
rename CFC valuemconfc999i
rename NFI valuemnnfin999i

// Old francs in France before 1949
replace valuemgdpro999i = valuemgdpro999i/(100*6.55957) if (iso == "FR") & (year <= 1948)
replace valuemconfc999i = valuemconfc999i/(100*6.55957) if (iso == "FR") & (year <= 1948)
replace valuemnnfin999i = valuemnnfin999i/(100*6.55957) if (iso == "FR") & (year <= 1948)

generate valuemnninc999i = valuemgdpro999i - valuemconfc999i + valuemnnfin999i

reshape long value, i(iso year) j(widcode) string
drop if value >= .

generate currency = "EUR" if inlist(iso, "DE", "ES", "FR", "IT")
replace currency = "AUD" if (iso == "AU")
replace currency = "CAD" if (iso == "CA")
replace currency = "GBP" if (iso == "GB")
replace currency = "JPY" if (iso == "JP")
replace currency = "SEK" if (iso == "SE")
replace currency = "USD" if (iso == "US")

generate p = "pall"

tempfile widna
save "`widna'"

use "$work_data/calculate-averages-output.dta", clear

generate new = 0
append using "`widna'"
replace new = 1 if (new >= .)

// Remove old observations when a new one exist (they may not be prefectly
// equal due to rounding).
duplicates tag iso year widcode p, generate(duplicate)
drop if (duplicate == 1) & (new == 0)
drop duplicate new

label data "Generated by add-macro-data-output.do"
save "$work_data/add-macro-data-output.dta", replace
