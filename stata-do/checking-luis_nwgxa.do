

use "$work_data/add-populations-output.dta", clear

keep if inlist(widcode, "mgdpro999i", "mnninc999i")
drop p currency 
reshape wide value, i(iso year) j(widcode) string

// merge 1:1 iso year using "$wid_dir/Country-Updates/Wealth/2022_September/wealth-aggregates.dta", nogen

merge 1:1 iso year using "$wid_dir/Country-Updates/Wealth/2023_December/wealth-aggregates-2023.dta", nogen
drop nwoff 
foreach var in nwnxa nwgxd nwgxa {
	replace `var' =. if year >= 1970
}

ds iso year valuemnninc999i valuemgdpro999i, not
foreach l in `r(varlist)' {
	replace `l' = . if inrange(year, 1990, 1994) & iso == "RU"
}

foreach x in `r(varlist)' {
	replace `x' = `x'*valuemnninc999i if !missing(valuemnninc999i) & !missing(`x')
	replace `x' = `x'/valuemgdpro999i
}
drop valuemnninc999i valuemgdpro999i

keep iso year pwfin cwfin gwfin pwdeb cwdeb cwdeq gwdeb

merge 1:1 iso year using "$input_data_dir/ewn-data/foreign-wealth-total-EWN_new.dta"

gen nwfin = pwfin + cwfin + gwfin 
gen nwdeb = pwdeb + cwdeb + cwdeq + gwdeb

gen luisnwnxa = nwfin - nwdeb 
gen nwnxa = nwgxa - nwgxd 

br iso year nwfin nwdeb luisnwnxa nwgxa nwgxd nwnxa

gen dif = luisnwnxa - nwnxa
keep if !mi(dif)

local countries "AU CA CN CZ DE DK ES FI FR GB IE IT JP KR MX NL NO NZ RU SE TW US"
local country_names "Australia Canada China Czechia Germany Denmark Spain Finland France UnitedKingdom Ireland Italy Japan SouthKorea Mexico Netherlands Norway NewZealand Russia Sweden Taiwan UnitedStates"
local colors "red blue green purple"
local i = 1

while `i' <= 22 {
    local iso1 : word `i' of `countries'
    local iso2 : word `=`i'+1' of `countries'
    local iso3 : word `=`i'+2' of `countries'
    local iso4 : word `=`i'+3' of `countries'
    
    local name1 : word `i' of `country_names'
    local name2 : word `=`i'+1' of `country_names'
    local name3 : word `=`i'+2' of `country_names'
    local name4 : word `=`i'+3' of `country_names'
    
    local color1 : word 1 of `colors'
    local color2 : word 2 of `colors'
    local color3 : word 3 of `colors'
    local color4 : word 4 of `colors'
    
    twoway ///
        (line nwnxa year if iso == "`iso1'", lpattern(solid) lcolor(`color1') ///
         title("Countries: `name1', `name2', `name3', `name4'")) ///
        (line luisnwnxa year if iso == "`iso1'", lpattern(dash) lcolor(`color1')) ///
        (line nwnxa year if iso == "`iso2'", lpattern(solid) lcolor(`color2')) ///
        (line luisnwnxa year if iso == "`iso2'", lpattern(dash) lcolor(`color2')) ///
        (line nwnxa year if iso == "`iso3'", lpattern(solid) lcolor(`color3')) ///
        (line luisnwnxa year if iso == "`iso3'", lpattern(dash) lcolor(`color3')) ///
        (line nwnxa year if iso == "`iso4'", lpattern(solid) lcolor(`color4')) ///
        (line luisnwnxa year if iso == "`iso4'", lpattern(dash) lcolor(`color4')), ///
        legend(order(1 "`name1' nwnxa" 2 "`name1' luisnwnxa" ///
                     3 "`name2' nwnxa" 4 "`name2' luisnwnxa" ///
                     5 "`name3' nwnxa" 6 "`name3' luisnwnxa" ///
                     7 "`name4' nwnxa" 8 "`name4' luisnwnxa")) ///
        ylabel(, grid) xlabel(, grid)
    
    graph export "C:\Users\g.nievas\Pictures\\line_graph_`iso1'_`iso2'_`iso3'_`iso4'.png", replace
    
    local i = `i' + 4
}




// we always match to netdomwealth
replace nwgxa = nwgxa + dif if dif > 0 & !mi(dif) & netdomwealth < 0 & nwnxa < 0
replace nwgxa = nwgxa + dif if dif > 0 & !mi(dif) & netdomwealth > 0 & nwnxa > 0
replace nwgxa = nwgxa + dif if dif > 0 & !mi(dif) & netdomwealth > 0 & nwnxa < 0

replace nwgxd = nwgxd - dif if dif < 0 & !mi(dif) & netdomwealth < 0 & nwnxa < 0
replace nwgxd = nwgxd - dif if dif < 0 & !mi(dif) & netdomwealth > 0 & nwnxa > 0
replace nwgxd = nwgxd - dif if dif < 0 & !mi(dif) & netdomwealth < 0 & nwnxa > 0

replace nwnxa = nwgxa - nwgxd 
gen dif2 = netdomwealth - nwnxa
assert dif2 < 0.0001 if !mi(dif)

keep iso year nwgxa nwgxd dif 
keep if !mi(dif)

ren (nwgxa nwgxd) (nwgxa2 nwgxd2)
sa "$work_data/aux-matc-foreign-domwealth.dta", replace