		use "$work_data/retropolate-gdp.dta", clear
merge 1:1 iso year using "$work_data/USS-exchange-rates.dta", nogen keepusing(exrate_usd) keep(master matched)
merge 1:1 iso year using "$work_data/price-index.dta", nogen keep(master matched)
gen gdp_idx = gdp*index
	gen gdp_usd = gdp_idx/exrate_usd
		keep iso year gdp_usd 
		
		ren gdp_usd gdp 

		keep if inrange(year, 1970, $pastyear )

		// Yugoslavia: shares applied to BA, HR, ME, MK, RS and SI. KS later applied to RS
		bys year: egen gdpYU = total(gdp) if inlist(iso, "BA", "HR", "ME", "MK", "RS", "SI", "KS")
		gen ratio_YU = gdp/gdpYU if inlist(iso, "BA", "HR", "ME", "MK", "RS", "SI", "KS")


		// Czechoslovakia
		bys year: egen gdpCS = total(gdp) if inlist(iso, "CZ", "SK")
		gen ratio_CS= gdp/gdpCS if inlist(iso, "CZ", "SK")
			
		// Serbia and Montenegro

		bys year: egen gdpRM = total(gdp) if inlist(iso, "RS", "ME", "KS")
		gen ratio_RM= gdp/gdpRM if inlist(iso, "RS", "ME", "KS")


		// Ex-soviet countriees , there is a year of GDP in 1973 we interpolate up to that year
		bys year: egen gdpSU = total(gdp) if inlist(iso, "AM", "AZ", "BY", "KG", "KZ", "TJ", "TM", "UZ") | inlist(iso, "EE", "LT", "LV", "MD", "GE", "UA", "RU")
		gen ratio_SU = gdp/gdpSU if inlist(iso, "AM", "AZ", "BY", "KG", "KZ", "TJ", "TM", "UZ") | inlist(iso, "EE", "LT", "LV", "MD", "GE", "UA", "RU")

		// Eriteria 1993 with Ethiopia
		bys year: egen gdpET = total(gdp) if inlist(iso, "ET", "ER") 
		gen ratio_ET = gdp/gdpET if iso == "ER"


		// Timor Leste with Indonesia
		bys year: egen gdpID = total(gdp) if inlist(iso, "ID", "TL") 
		gen ratio_ID = gdp/gdpID if iso == "TL" 
			
		// South Sudan and Sudan
		bys year: egen gdpSD = total(gdp) if inlist(iso, "SD", "SS")  
		gen ratio_SD = gdp/gdpSD if iso == "SS"

			
		// Zanzibar and Tanzania
		bys year: egen gdpTZ = total(gdp) if inlist(iso, "TZ", "ZZ")
		gen ratio_TZ = gdp/gdpTZ if iso == "ZZ"


		// Isle of Man and United Kingdom
		bys year: egen gdpGB1 = total(gdp) if inlist(iso, "GB", "IM") 
		gen ratioIM_GB = gdp/gdpGB1 if iso == "IM" 


		// Guernsey and United Kingdom
		bys year: egen gdpGB2 = total(gdp) if inlist(iso, "GB", "GG") 
		gen ratioGG_GB = gdp/gdpGB2 if iso == "GG" 
			

		// Jersey and United Kingdom
		bys year: egen gdpGB3 = total(gdp) if inlist(iso, "JE", "GB") 
		gen ratioJE_GB = gdp/gdpGB3 if iso == "JE"


		// Gibraltar and United Kingdom
		bys year: egen gdpGB4 = total(gdp) if inlist(iso, "GI", "GB") 
		gen ratioGI_GB = gdp/gdpGB4 if iso == "GI"

		// Netherlands Antilles, Curacao and Sint Marteen. MAYBE NEEDED FOR ARUBA?
		bys year: egen gdpAN = total(gdp) if inlist(iso, "CW", "SX")
		gen ratio_AN= gdp/gdpAN if inlist(iso, "CW", "SX")


		keep iso year ratio* 

		keep if inlist(iso, "BA", "HR", "ME", "MK", "RS", "SI", "KS") | inlist(iso, "CZ", "SK") | /// 
		inlist(iso, "AM", "AZ", "BY", "KG", "KZ", "TJ", "TM", "UZ") | inlist(iso, "EE", "LT", "LV", "MD", "GE", "UA", "RU") | ///
		inlist(iso, "ET", "ER", "ID", "TL", "SD", "SS", "TZ", "ZZ") | inlist(iso, "GB", "IM", "GG", "JE", "GI") | ///
		inlist(iso, "SD", "SS", "CW", "SX")
			 
		save "$work_data/ratios.dta", replace


u "$current_account/Gravity_V202211", clear
keep if year >= 1970
drop if year > 2020

drop if inlist(iso3_o, "VDR", "YMD") | inlist(iso3_d, "VDR", "YMD")

kountry iso3_o, from(iso3c) to(iso2c)
ren _ISO2C_ iso_o 
replace iso_o ="BQ" if iso3_o=="BES"
replace iso_o ="CS" if iso3_o=="CSK"
replace iso_o ="CW" if iso3_o=="CUW"
replace iso_o ="DD" if iso3_o=="DDR"
replace iso_o ="IO" if iso3_o=="IOT"
replace iso_o ="MP" if iso3_o=="MNP"
replace iso_o ="NF" if iso3_o=="NFK"
replace iso_o ="PN" if iso3_o=="PCN"
replace iso_o ="RM" if iso3_o=="SCG"
replace iso_o ="SS" if iso3_o=="SSD"
replace iso_o ="SU" if iso3_o=="SUN"
replace iso_o ="SX" if iso3_o=="SXM"
replace iso_o ="VN" if iso3_o=="VDR"
replace iso_o ="YE" if iso3_o=="YMD"
replace iso_o ="YU" if iso3_o=="YUG"
replace iso_o ="TK" if iso3_o=="TKL"

kountry iso3_d, from(iso3c) to(iso2c)
ren _ISO2C_ iso_d 
replace iso_d ="BQ" if iso3_d=="BES"
replace iso_d ="CS" if iso3_d=="CSK"
replace iso_d ="CW" if iso3_d=="CUW"
replace iso_d ="DD" if iso3_d=="DDR"
replace iso_d ="IO" if iso3_d=="IOT"
replace iso_d ="MP" if iso3_d=="MNP"
replace iso_d ="NF" if iso3_d=="NFK"
replace iso_d ="PN" if iso3_d=="PCN"
replace iso_d ="RM" if iso3_d=="SCG"
replace iso_d ="SS" if iso3_d=="SSD"
replace iso_d ="SU" if iso3_d=="SUN"
replace iso_d ="SX" if iso3_d=="SXM"
replace iso_d ="VN" if iso3_d=="VDR"
replace iso_d ="YE" if iso3_d=="YMD"
replace iso_d ="YU" if iso3_d=="YUG"
replace iso_d ="TK" if iso3_d=="TKL"

collapse (sum) tradeflow_comtrade_o tradeflow_comtrade_d tradeflow_baci manuf_tradeflow_baci tradeflow_imf_o tradeflow_imf_d, by(iso_o iso_d year)

append using "$current_account/Gravity_update"

foreach var in tradeflow_comtrade_o tradeflow_comtrade_d tradeflow_baci manuf_tradeflow_baci tradeflow_imf_o tradeflow_imf_d {
	replace `var' =. if `var' == 0 
}

gen exports = tradeflow_imf_d
replace exports = tradeflow_comtrade_d if missing(exports)
replace exports = tradeflow_imf_o if missing(exports)
replace exports = tradeflow_comtrade_o if missing(exports)
replace exports = tradeflow_baci if missing(exports)
replace exports = exports*1000
label var exports "Exports in USD. first IMF_d COMTRADE_d I_o C_o and BACI" 

gen pairid = cond(iso_o <= iso_d, iso_o, iso_d) + cond(iso_o >= iso_d, iso_o, iso_d) 
label var pairid "Pair ID"

foreach iso in YU CS RM SU ET ID TZ GB SD AN {
	gen aux = exports if iso_o == "`iso'"
	bys year iso_d : egen exports`iso' = mode(aux)
	gen aux2 = exports if iso_d == "`iso'"
	bys year iso_o : egen imports`iso' = mode(aux2)
	drop aux*
}

ren iso_o iso
merge m:1 iso year using "$work_data/ratios.dta"
drop _m 
ren iso iso_o 
renvars ratio*, prefix(exp)
ren iso_d iso 
merge m:1 iso year using "$work_data/ratios.dta"
drop _m 
ren iso iso_d 
renvars ratio*, prefix(imp)

// fillin in the database
fillin iso_o iso_d year
drop if iso_o == iso_d 
drop if mi(iso_o) | mi(iso_d)

foreach x in exports { //imports
//Yugloslavia 
foreach c in BA HR ME MK RS SI KS {
 replace `x' = `x'YU*expratio_YU if iso_o == "`c'" & missing(`x')
 replace `x' = importsYU*impratio_YU if iso_d == "`c'" & missing(`x')
}

// Serbia and Montenegro
foreach c in RS ME KS {
 replace `x' = `x'RM*expratio_RM if iso_o == "`c'" & missing(`x')
 replace `x' = importsRM*impratio_RM if iso_d == "`c'" & missing(`x')
}

// Czechoslovakia
foreach c in CZ SK  {
 replace `x' = `x'CS*expratio_CS if iso_o == "`c'" & missing(`x')
 replace `x' = importsCS*impratio_CS if iso_d == "`c'" & missing(`x')
}

// Ex-soviet countries
foreach c in AM AZ BY KG KZ GE TJ MD TM UA UZ EE LT LV RU { 
 replace `x' = `x'SU*expratio_SU if iso_o == "`c'" & missing(`x')
 replace `x' = importsSU*impratio_SU if iso_d == "`c'" & missing(`x')
}

// Eriteria 1993 with Ethiopia
replace `x' = `x'ET*expratio_ET if iso_o == "ER" & missing(`x')
gen aux = `x' if iso_o=="ER"
bys year iso_d : egen `x'ER = mode(aux)
replace `x' = `x' - `x'ER if iso_o=="ET" & year<1993
drop aux 

replace `x' = importsET*impratio_ET if iso_d == "ER" & missing(`x')
gen aux = `x' if iso_d=="ER"
bys year iso_o : egen importsER = mode(aux)
replace `x' = `x' - importsER if iso_d=="ET" & year<1993
drop aux 

// Timor Leste with Indonesia
replace `x' = `x'ID*expratio_ID if iso_o == "TL" & missing(`x')
gen aux = `x' if iso_o=="TL"
bys year iso_d : egen `x'TL = mode(aux)
replace `x' = `x' - `x'TL if iso_o=="ID" & year<2002
drop aux 

replace `x' = importsID*impratio_ID if iso_d == "TL" & missing(`x')
gen aux = `x' if iso_d=="TL"
bys year iso_o : egen importsTL = mode(aux)
replace `x' = `x' - importsTL if iso_d=="ID" & year<2002
drop aux 

// South Sudan and Sudan
replace `x' = `x'SD*expratio_SD if iso_o == "SS" & missing(`x')
gen aux = `x' if iso_o=="SS"
bys year iso_d : egen `x'SS = mode(aux)
replace `x' = `x' - `x'SS if iso_o=="SD" & year<2011
drop aux 

replace `x' = importsSD*impratio_SD if iso_d == "SS" & missing(`x')
gen aux = `x' if iso_d=="SS"
bys year iso_o : egen importsSS = mode(aux)
replace `x' = `x' - importsTL if iso_d=="SD" & year<2011
drop aux 

// Zanzibar and Tanzania
replace `x' = `x'TZ*expratio_TZ if iso_o == "ZZ" & missing(`x')
replace `x' = importsTZ*impratio_TZ if iso_d == "ZZ" & missing(`x')

/*we don't do this for TZ and ZZ
gen aux = tradebalance if iso=="ZZ"
bys year: egen tradebalanceZZ = mode(aux)
replace tradebalance = tradebalance - tradebalanceZZ if iso=="TZ" & year<2011
drop aux 
*/

*not done for TH
// Isle of Man and United Kingdom
replace `x' = `x'GB*expratioIM_GB if iso_o == "IM" & missing(`x')
replace `x' = importsGB*impratioIM_GB if iso_d == "IM" & missing(`x')

// Guernsey and United Kingdom
replace `x' = `x'GB*expratioGG_GB if iso_o == "GG" & missing(`x')
replace `x' = importsGB*impratioGG_GB if iso_d == "GG" & missing(`x')

// Jersey and United Kingdom
replace `x' = `x'GB*expratioJE_GB if iso_o == "JE" & missing(`x')
replace `x' = importsGB*impratioJE_GB if iso_d == "JE" & missing(`x')

// Gibraltar and United Kingdom
replace `x' = `x'GB*expratioGI_GB if iso_o == "GI" & missing(`x')
replace `x' = importsGB*impratioGI_GB if iso_d == "GI" & missing(`x')

*Netherlands Antilles
foreach c in CW SX {
replace `x' = `x'AN*expratio_AN if iso_o == "`c'" & missing(`x')
replace `x' = importsAN*impratio_AN if iso_d == "`c'" & missing(`x')
	}

}


ren iso_o iso 
merge m:1 iso year using "$work_data/country-codes-list-core-year.dta", keepusing(corecountry) nogen
ren corecountry core_o 
*replace core_o = 1 if inlist(iso, "YU", "CS", "RM", "SU", "ET", "ID", "TZ", "SD") & year >= 1970
ren iso iso_o 

ren iso_d iso 
merge m:1 iso year using "$work_data/country-codes-list-core-year.dta", keepusing(corecountry) nogen
ren corecountry core_d 
*replace core_d = 1 if inlist(iso, "YU", "CS", "RM", "SU", "ET", "ID", "TZ", "SD") & year >= 1970
ren iso iso_d 

// dropping non-corecountry counterparts 
drop if core_d != 1 | core_o != 1

// NA value in 2018 is weird
replace exports = . if iso_o == "NA" & year == 2018
replace exports = . if iso_d == "NA" & year == 2018

********************************************************************************
// completing missing values
// for countries where only some years are not in the data we carryforward exports/gdp by partner
preserve 
	collapse (sum) exports, by(iso_o year)
	replace exports =. if exports == 0
	bys iso_o : egen flag1 = max(exports)
	replace flag1 = 0 if !mi(flag1)
	replace flag1 = 1 if mi(flag1)
	gen aux = 1 if mi(exports) & flag1 == 0
	bys iso_o : egen flag2 = max(aux)
	replace flag2 = 0 if mi(flag2)
	bys iso_o : egen aux2 = min(year) if !mi(exports)
	bys iso_o : egen aux3 = max(year) if !mi(exports)
	bys iso_o : egen minyear = max(aux2)
	bys iso_o : egen maxyear = max(aux3)
	keep iso_o year flag1 flag2 minyear maxyear 
	drop year 
	duplicates drop 
	gen iso_d = iso_o
	tempfile flag
	sa "$work_data/flagetemp", replace
restore 

merge m:1 iso_o using "$work_data/flagetemp", keepusing(flag1 flag2 minyear maxyear)
drop _m 

sa "$work_data/tradetemp", replace 

u "$work_data/tradetemp", clear  
//	bring GDP in usd
ren iso_o iso  
merge m:1 iso year using "$work_data/retropolate-gdp.dta", nogenerate keepusing(gdp) keep(master matched)
merge m:1 iso year using "$work_data/USS-exchange-rates.dta", nogen keepusing(exrate_usd) keep(master matched)
merge m:1 iso year using "$work_data/price-index.dta", nogen keep(master matched)

gen gdp_idx = gdp*index
	gen gdp_usd = gdp_idx/exrate_usd
drop gdp exrate_usd	 index
ren iso iso_o 

// exports as a share of gdp
replace exports = exports/gdp_usd 

foreach level in undet un {
	kountry iso_o, from(iso2c) geo(`level')

replace GEO = "Western Asia" 	if iso_o == "AE" & "`level'" == "undet"
replace GEO = "Caribbean" 		if iso_o == "CW" & "`level'" == "undet"
replace GEO = "Caribbean"		if iso_o == "SX" & "`level'" == "undet"
replace GEO = "Caribbean" 		if iso_o == "BQ" & "`level'" == "undet"
replace GEO = "Southern Europe" if iso_o == "KS" & "`level'" == "undet"
replace GEO = "Southern Europe" if iso_o == "ME" & "`level'" == "undet"
replace GEO = "Eastern Asia" 	if iso_o == "TW" & "`level'" == "undet"
replace GEO = "Northern Europe" if iso_o == "GG" & "`level'" == "undet"
replace GEO = "Northern Europe" if iso_o == "JE" & "`level'" == "undet"
replace GEO = "Northern Europe" if iso_o == "IM" & "`level'" == "undet"

replace GEO = "Asia" if inlist(iso_o, "AE", "TW") & "`level'" == "un"
replace GEO = "Americas" if inlist(iso_o, "CW", "SX", "BQ") & "`level'" == "un"
replace GEO = "Europe" if inlist(iso_o, "KS", "ME", "GG", "JE", "IM") & "`level'" == "un"
ren GEO geo`level'
drop NAMES_STD 
}

// fixing crazy values
replace flag1 = 0 if (iso_o == "GW" | iso_d == "GW") & inlist(year, 2003, 2004)
replace flag2 = 0 if (iso_o == "GW" | iso_d == "GW") & inlist(year, 2003, 2004)
replace flag1 = 0 if (iso_o == "SN" | iso_d == "SN") & inlist(year, 1987)
replace flag2 = 0 if (iso_o == "SN" | iso_d == "SN") & inlist(year, 1987)
replace flag1 = 0 if (iso_o == "LR" | iso_d == "LR") & year >= 1989
replace flag2 = 0 if (iso_o == "LR" | iso_d == "LR") & year >= 1989
replace flag1 = 0 if (iso_o == "ST" | iso_d == "ST") & year >= 2015 
replace flag2 = 0 if (iso_o == "ST" | iso_d == "ST") & year >= 2015
replace flag1 = 0 if (iso_o == "LS" | iso_d == "LS") & year >= 2019
replace flag2 = 0 if (iso_o == "LS" | iso_d == "LS") & year >= 2019

//Fill missing with regional averages for those that never have data 
foreach v in exports { 
	
 foreach level in undet un {
		
  bys geo`level' iso_d year : egen av`level'`v' = mean(`v')

  }
replace `v' = avundet`v' if missing(`v') & flag1 == 1
replace `v' = avun`v' if missing(`v') & flag1 == 1
}
drop av*

// carryforward for flag2 
sort iso_o iso_d year 
by iso_o iso_d : carryforward exports if flag2 == 1 & year > maxyear, replace 

gsort iso_o iso_d -year 
by iso_o iso_d : carryforward exports if flag2 == 1 & year < minyear, replace 

// fixing NA 2018
sort iso_o iso_d year 
by iso_o iso_d : carryforward exports if flag2 == 1 & year == 2018 & iso_o == "NA", replace 
by iso_o iso_d : carryforward exports if year == 2018 & iso_d == "NA", replace 

// exports in nominals
replace exports = exports*gdp_usd 
drop gdp*

// now for imports
//	bring GDP in usd
ren iso_d iso  
merge m:1 iso year using "$work_data/retropolate-gdp.dta", nogenerate keepusing(gdp) keep(master matched)
merge m:1 iso year using "$work_data/USS-exchange-rates.dta", nogen keepusing(exrate_usd) keep(master matched)
merge m:1 iso year using "$work_data/price-index.dta", nogen keep(master matched)

gen gdp_idx = gdp*index
	gen gdp_usd = gdp_idx/exrate_usd
drop gdp exrate_usd	index
ren iso iso_d 

// exports as a share of gdp
replace exports = exports/gdp_usd 

drop geo* flag* minyear maxyear 
merge m:1 iso_d using "$work_data/flagetemp", keepusing(flag1 flag2 minyear maxyear)
drop _m 

foreach level in undet un {
	kountry iso_d, from(iso2c) geo(`level')

replace GEO = "Western Asia" 	if iso_d == "AE" & "`level'" == "undet"
replace GEO = "Caribbean" 		if iso_d == "CW" & "`level'" == "undet"
replace GEO = "Caribbean"		if iso_d == "SX" & "`level'" == "undet"
replace GEO = "Caribbean" 		if iso_d == "BQ" & "`level'" == "undet"
replace GEO = "Southern Europe" if iso_d == "KS" & "`level'" == "undet"
replace GEO = "Southern Europe" if iso_d == "ME" & "`level'" == "undet"
replace GEO = "Eastern Asia" 	if iso_d == "TW" & "`level'" == "undet"
replace GEO = "Northern Europe" if iso_d == "GG" & "`level'" == "undet"
replace GEO = "Northern Europe" if iso_d == "JE" & "`level'" == "undet"
replace GEO = "Northern Europe" if iso_d == "IM" & "`level'" == "undet"

replace GEO = "Asia" if inlist(iso_d, "AE", "TW") & "`level'" == "un"
replace GEO = "Americas" if inlist(iso_d, "CW", "SX", "BQ") & "`level'" == "un"
replace GEO = "Europe" if inlist(iso_d, "KS", "ME", "GG", "JE", "IM") & "`level'" == "un"
ren GEO geo`level'
drop NAMES_STD 
}

// fixing crazy values
replace flag1 = 0 if (iso_o == "GW" | iso_d == "GW") & inlist(year, 2003, 2004)
replace flag2 = 0 if (iso_o == "GW" | iso_d == "GW") & inlist(year, 2003, 2004)
replace flag1 = 0 if (iso_o == "SN" | iso_d == "SN") & inlist(year, 1987)
replace flag2 = 0 if (iso_o == "SN" | iso_d == "SN") & inlist(year, 1987)
replace flag1 = 0 if (iso_o == "LR" | iso_d == "LR") & year >= 1989
replace flag2 = 0 if (iso_o == "LR" | iso_d == "LR") & year >= 1989
replace flag1 = 0 if (iso_o == "ST" | iso_d == "ST") & year >= 2015 
replace flag2 = 0 if (iso_o == "ST" | iso_d == "ST") & year >= 2015
replace flag1 = 0 if (iso_o == "LS" | iso_d == "LS") & year >= 2019
replace flag2 = 0 if (iso_o == "LS" | iso_d == "LS") & year >= 2019

//Fill missing with regional averages for countries where we never have data
foreach v in exports { 
	
 foreach level in undet un {
		
  bys geo`level' iso_o year : egen av`level'`v' = mean(`v')

  }
replace `v' = avundet`v' if missing(`v') & flag1 == 1
replace `v' = avun`v' if missing(`v') & flag1 == 1
}
drop av*

// carryforward for flag2 
sort iso_o iso_d year 
by iso_o iso_d : carryforward exports if flag2 == 1 & year > maxyear, replace

gsort iso_o iso_d -year 
by iso_o iso_d : carryforward exports if flag2 == 1 & year < minyear, replace

// exports in nominals
replace exports = exports*gdp_usd 
drop gdp*

********************************************************************************
// mirroring imports
preserve
keep iso_o iso_d year exports pairid
ren (exports) (imports)
ren iso_o aux2
ren iso_d iso_o
ren aux2 iso_d
label var imports "Imports in USD. first IMF_d COMTRADE_d I_o C_o and BACI" 
tempfile flowimports
sa `flowimports', replace
restore

merge 1:1 iso_o iso_d year using `flowimports'
drop _m 

// collapsing
collapse (sum) exports imports, by(iso_o year)

foreach var in exports imports {
	replace `var' =. if `var' == 0 
}

bys year : egen totexp = total(exports)
bys year : egen totimp = total(imports)
gen check = totexp - totimp
assert check == 0 

gen tradebalance = exports - imports
so iso year
by iso : carryforward exports imports tradebalance if year == $pastyear , replace 
assert !mi(tradebalance)

drop tot* check* // exports imports

ren iso_o iso
sa "$current_account/tradebalances.dta", replace
