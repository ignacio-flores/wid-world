/****Import UN series.***/

// Note: WPP population series are updated every two years (generally). Therefore,
// updates in even years /could be made using the global ${year}, while in odd 
// years, ${pasyear} should be used. To verify the current values of these globals,
//  please refer to the setup.do file.

*Import data from https://population.un.org/wpp/Download/Files/1_Indicator%20(Standard)/EXCEL_FILES/1_General/WPP2024_GEN_F01_DEMOGRAPHIC_INDICATORS_COMPACT.xlsx
import excel "$pop_un_data/wpp/WPP${year}_GEN_F01_DEMOGRAPHIC_INDICATORS_COMPACT.xlsx", ///
	cellrange(B17) firstrow case(lower) clear	

keep regionsubregioncountryorar notes iso2alphacode type parentcode totalpopulationasof1july year

// Adding estimated year - Medium Variant - 
*Import data from https://population.un.org/wpp/Download/Files/1_Indicator%20(Standard)/EXCEL_FILES/1_General/WPP2024_GEN_F01_DEMOGRAPHIC_INDICATORS_COMPACT.xlsx
preserve
		import excel "$pop_un_data/wpp/WPP${year}_GEN_F01_DEMOGRAPHIC_INDICATORS_COMPACT.xlsx", ///
			cellrange(B17) sheet("Medium variant") firstrow case(lower) clear		
	keep regionsubregioncountryorar notes iso2alphacode type parentcode totalpopulationasof1july year
	tempfile $year 
	save `$year'
	tab year
restore	

append using `$year'

// Identify countries
ren iso2alphacode iso
ren totalpopulationasof1july value
// Kosovo
replace iso = "KS" if iso == "XK"
drop if missing(iso)
 
destring value, replace force
drop if value >= .
replace value = 1e3*value

generate age = "all"
generate sex = "both"

tempfile unpop
save "`unpop'", replace

// Both sexes, age groups --------------------------------------------------- //
*Import data from https://population.un.org/wpp/Download/Files/1_Indicator%20(Standard)/EXCEL_FILES/2_Population/WPP2024_POP_F01_1_POPULATION_SINGLE_AGE_BOTH_SEXES.xlsx
import excel "$pop_un_data/wpp/WPP${year}_POP_F02_1_POPULATION_5-YEAR_AGE_GROUPS_BOTH_SEXES.xlsx", ///
	cellrange(B17) firstrow case(lower) clear

// Correct column names
foreach v of varlist l-af {
	destring `v', replace ignore("…")

	local age: var label `v'
	local age = subinstr("`age'", "-", "_", 1)
	local age = subinstr("`age'", "+", "", 1)
	if ("`age'" == "") {
		drop `v'
	}
	else {
		rename `v' value`age'
	}
}

// Adding estimated year - Medium Variant -
*Import data from https://population.un.org/wpp/Download/Files/1_Indicator%20(Standard)/EXCEL_FILES/2_Population/WPP2024_POP_F01_1_POPULATION_SINGLE_AGE_BOTH_SEXES.xlsx
preserve
import excel "$pop_un_data/wpp/WPP${year}_POP_F02_1_POPULATION_5-YEAR_AGE_GROUPS_BOTH_SEXES.xlsx", ///
			cellrange(B17) sheet("Medium variant") firstrow case(lower) clear
		// Correct column names
foreach v of varlist l-af {
		destring `v', replace ignore("…")

		local age: var label `v'
		local age = subinstr("`age'", "-", "_", 1)
		local age = subinstr("`age'", "+", "", 1)
		if ("`age'" == "") {
			drop `v'
		}
		else {
			rename `v' value`age'
		}
	}


	
	tempfile age_$year
	save `age_$year'
restore	

append using `age_$year'

// Identify countries
ren iso2alphacode iso
// Kosovo
replace iso = "KS" if iso == "XK"
drop variant regionsubregioncountryorar notes
destring value*, replace force

// Calculate value for 80+ when we only have the detail
generate value80 = value80_84 + value85_89 + value90_94 + value95_99 + value100 

// Calculate other population categories
generate valuechildren = value0_4 + value5_9 + value10_14 + value15_19
generate valueadults = value20_24 + value25_29 + value30_34 + value35_39 + value40_44 + value45_49 + value50_54 + value55_59 + value60_64 + value65_69 + value70_74 + value75_79 + value80
generate value20_39 = value20_24 + value25_29 + value30_34 + value35_39
generate value40_59 = value40_44 + value45_49 + value50_54 + value55_59
generate value60 = value60_64 + value65_69 + value70_74 + value75_79 + value80
generate value20_64 = value20_24 + value25_29 + value30_34 + value35_39 + value40_44 + value45_49 + value50_54 + value55_59 + value60_64
generate value65 = value65_69 + value70_74 + value75_79 + value80

cap rename referencedateasof1july year
duplicates drop iso year, force
reshape long value, i(iso year) j(age) string
drop if value >= .
replace value = 1e3*value

generate sex = "both"
	
append using "`unpop'"
save "`unpop'", replace

// Men, age groups ---------------------------------------------------------- //

*Import data from https://population.un.org/wpp/Download/Files/1_Indicator%20(Standard)/EXCEL_FILES/2_Population/WPP2024_POP_F02_2_POPULATION_5-YEAR_AGE_GROUPS_MALE.xlsx
import excel "$pop_un_data/wpp/WPP${year}_POP_F02_2_POPULATION_5-YEAR_AGE_GROUPS_MALE.xlsx", ///
	cellrange(B17) firstrow case(lower) clear

// Correct column names
foreach v of varlist l-af {
	destring `v', replace ignore("…")

	local age: var label `v'
	local age = subinstr("`age'", "-", "_", 1)
	local age = subinstr("`age'", "+", "", 1)
	if ("`age'" == "") {
		drop `v'
	}
	else {
		rename `v' value`age'
	}
}

// Adding estimated year - Medium Variant - 
*Import data from https://population.un.org/wpp/Download/Files/1_Indicator%20(Standard)/EXCEL_FILES/2_Population/WPP2024_POP_F02_2_POPULATION_5-YEAR_AGE_GROUPS_MALE.xlsx
preserve
import excel "$pop_un_data/wpp/WPP${year}_POP_F02_2_POPULATION_5-YEAR_AGE_GROUPS_MALE.xlsx", ///
		cellrange(B17) sheet("Medium variant") firstrow case(lower) clear		
		// Correct column names
	foreach v of varlist l-af {
		destring `v', replace ignore("…")

		local age: var label `v'
		local age = subinstr("`age'", "-", "_", 1)
		local age = subinstr("`age'", "+", "", 1)
		if ("`age'" == "") {
			drop `v'
		}
		else {
			rename `v' value`age'
		}
	}

	
	tempfile male_$year
	save `male_$year'
restore	

append using `male_$year'

// Identify countries
ren iso2alphacode iso
// Kosovo
replace iso = "KS" if iso == "XK"
drop variant regionsubregioncountryorar notes
destring value*, replace force

// Calculate value for 80+ when we only have the detail
gen value80 = value80_84 + value85_89 + value90_94 + value95_99 + value100

// Calculate other population categories
generate valuechildren = value0_4 + value5_9 + value10_14 + value15_19
generate valueadults = value20_24 + value25_29 + value30_34 + value35_39 + value40_44 + value45_49 + value50_54 + value55_59 + value60_64 + value65_69 + value70_74 + value75_79 + value80
generate value20_39 = value20_24 + value25_29 + value30_34 + value35_39
generate value40_59 = value40_44 + value45_49 + value50_54 + value55_59
generate value60 = value60_64 + value65_69 + value70_74 + value75_79 + value80
generate value20_64 = value20_24 + value25_29 + value30_34 + value35_39 + value40_44 + value45_49 + value50_54 + value55_59 + value60_64
generate value65 = value65_69 + value70_74 + value75_79 + value80
generate value20_29 = value20_24 + value25_29
generate value30_39 = value30_34 + value35_39
generate value40_49 = value40_44 + value45_49
generate value50_59 = value50_54 + value55_59
generate value60_69 = value60_64 + value65_69
generate value70_79 = value70_74 + value75_79
generate value80_89 = value80_84 + value85_89
generate value90_99 = value90_94 + value95_99

// Generate entire men population
generate valueall = value0_4 + value5_9 + value10_14 + value15_19 + value20_24 + value25_29 + value30_34 + value35_39 + value40_44 + value45_49 + value50_54 + value55_59 + value60_64 + value65_69 + value70_74 + value75_79 + value80

cap rename referencedateasof1july year
duplicates drop iso year, force
reshape long value, i(iso year) j(age) string
drop if value >= .
replace value = 1e3*value
generate sex = "men"
	
append using "`unpop'"
save "`unpop'", replace

// Women, age groups -------------------------------------------------------- //
*Import data from https://population.un.org/wpp/Download/Files/1_Indicator%20(Standard)/EXCEL_FILES/2_Population/WPP2024_POP_F02_3_POPULATION_5-YEAR_AGE_GROUPS_FEMALE.xlsx
	import excel "$pop_un_data/wpp/WPP${year}_POP_F02_3_POPULATION_5-YEAR_AGE_GROUPS_FEMALE.xlsx", ///
	cellrange(B17) firstrow case(lower) clear

// Correct column names
foreach v of varlist l-af {
	destring `v', replace ignore("…")

	local age: var label `v'
	local age = subinstr("`age'", "-", "_", 1)
	local age = subinstr("`age'", "+", "", 1)
	if ("`age'" == "") {
		drop `v'
	}
	else {
		rename `v' value`age'
	}
}

// Adding estimated year - Medium Variant - 
preserve
*Import data from https://population.un.org/wpp/Download/Files/1_Indicator%20(Standard)/EXCEL_FILES/2_Population/WPP2024_POP_F02_3_POPULATION_5-YEAR_AGE_GROUPS_FEMALE.xlsx
import excel "$pop_un_data/wpp/WPP${year}_POP_F02_3_POPULATION_5-YEAR_AGE_GROUPS_FEMALE.xlsx", ///
		cellrange(B17) sheet("Medium variant") firstrow case(lower) clear		
		// Correct column names
	foreach v of varlist l-af {
		destring `v', replace ignore("…")

		local age: var label `v'
		local age = subinstr("`age'", "-", "_", 1)
		local age = subinstr("`age'", "+", "", 1)
		if ("`age'" == "") {
			drop `v'
		}
		else {
			rename `v' value`age'
		}
	}

// 	keep if year == $year | year == $pastyear
	
	tempfile female_$year
	save `female_$year'
restore	

append using `female_$year'

// Identify countries
ren iso2alphacode iso
// Kosovo
replace iso = "KS" if iso == "XK"
drop variant regionsubregioncountryorar notes
destring value*, replace force

// Calculate value for 80+ when we only have the detail
gen value80 = value80_84 + value85_89 + value90_94 + value95_99 + value100

// Calculate other population categories
generate valuechildren = value0_4 + value5_9 + value10_14 + value15_19
generate valueadults = value20_24 + value25_29 + value30_34 + value35_39 + value40_44 + value45_49 + value50_54 + value55_59 + value60_64 + value65_69 + value70_74 + value75_79 + value80
generate value20_39 = value20_24 + value25_29 + value30_34 + value35_39
generate value40_59 = value40_44 + value45_49 + value50_54 + value55_59
generate value60 = value60_64 + value65_69 + value70_74 + value75_79 + value80
generate value20_64 = value20_24 + value25_29 + value30_34 + value35_39 + value40_44 + value45_49 + value50_54 + value55_59 + value60_64
generate value65 = value65_69 + value70_74 + value75_79 + value80
generate value20_29 = value20_24 + value25_29
generate value30_39 = value30_34 + value35_39
generate value40_49 = value40_44 + value45_49
generate value50_59 = value50_54 + value55_59
generate value60_69 = value60_64 + value65_69
generate value70_79 = value70_74 + value75_79
generate value80_89 = value80_84 + value85_89
generate value90_99 = value90_94 + value95_99

// Generate entire women population
generate valueall = value0_4 + value5_9 + value10_14 + value15_19 + value20_24 + value25_29 + value30_34 + value35_39 + value40_44 + value45_49 + value50_54 + value55_59 + value60_64 + value65_69 + value70_74 + value75_79 + value80

cap rename referencedateasof1july year
duplicates drop iso year, force
reshape long value, i(iso year) j(age) string
drop if value >= .
replace value = 1e3*value
generate sex = "women"

append using "`unpop'"
save "`unpop'", replace

drop locationcode iso3alphacode sdmxcode regionsubregioncountryorar notes
drop if missing(iso)

drop if year>$pastyear

label data "Generated by import-un-populations.do"
save "$work_data/un-population.dta", replace




/*
// Add previsions for current year that are missing ----------------------------------------------------- //

import excel "$un_data/populations/wpp/WPP${year}_DB04_Population_By_Age_Annual.xlsx", ///
	sheet("Sheet1") case(lower) firstrow clear

*june 2018: estimates of the other files only go until 2015 still, so I keep pastpastyear (2017) and pastpastyear - 1 (2016) 
keep if time==$pastpastyear | time == ($pastpastyear - 1)

// Identify countries
countrycode location, generate(iso) from("wpp")
drop location locid varid variant midperiod sexid

// Calculate population for 80+
replace pop_80_100 = pop_80_84 + pop_85_89 + pop_90_94 + pop_95_99 + pop_100 if mi(pop_80_100)
rename pop_80_100 pop_80

// Calculate other population categories
generate pop_children = pop_0_4 + pop_5_9 + pop_10_14 + pop_15_19
generate pop_adults = pop_20_24 + pop_25_29 + pop_30_34 + pop_35_39 + ///
	pop_40_44 + pop_45_49 + pop_50_54 + pop_55_59 + pop_60_64 + ///
	pop_65_69 + pop_70_74 + pop_75_79 + pop_80
generate pop_20_39 = pop_20_24 + pop_25_29 + pop_30_34 + pop_35_39
generate pop_40_59 = pop_40_44 + pop_45_49 + pop_50_54 + pop_55_59
generate pop_60 = pop_60_64 + pop_65_69 + pop_70_74 + pop_75_79 + pop_80
generate pop_20_64 = pop_20_24 + pop_25_29 + pop_30_34 + pop_35_39 + ///
	pop_40_44 + pop_45_49 + pop_50_54 + pop_55_59 + pop_60_64
generate pop_65 = pop_65_69 + pop_70_74 + pop_75_79 + pop_80
generate pop_20_29 = pop_20_24 + pop_25_29
generate pop_30_39 = pop_30_34 + pop_35_39
generate pop_40_49 = pop_40_44 + pop_45_49
generate pop_50_59 = pop_50_54 + pop_55_59
generate pop_60_69 = pop_60_64 + pop_65_69
generate pop_70_79 = pop_70_74 + pop_75_79
generate pop_80_89 = pop_80_84 + pop_85_89
generate pop_90_99 = pop_90_94 + pop_95_99

// Generate entire population
generate pop_all = pop_0_4 + pop_5_9 + pop_10_14 + pop_15_19 + pop_20_24 ///
	+ pop_25_29 + pop_30_34 + pop_35_39 + pop_40_44 + pop_45_49 + pop_50_54 ///
	+ pop_55_59 + pop_60_64 + pop_65_69 + pop_70_74 + pop_75_79 + pop_80

reshape long pop_, i(time sex iso) j(age) string
rename pop_ value
drop if mi(value)
replace value = 1e3*value

// One should have 38 age decompositions
qui tab age
assert `r(r)'==38

// Recode and rename
rename time year
replace sex="both" if sex=="Both"
replace sex="women" if sex=="Female"
replace sex="men" if sex=="Male"

append using "`unpop'"
duplicates drop
*/


