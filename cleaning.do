//Cleaning data
cd "F:\3rd year_UH\Development Econ\Proposal Memo 3\Organisation\Data\Varshney-Wilkinson Dataset\DS0001"
insheet using 04342-0001-Data.csv
save vw, replace
set more off
tab statecode
sort year
rename statecode states
replace states= "Punjab" 		if states=="PU" 
replace states = "Uttar Pradesh"   		if states=="UP"    //treatment states(1-3)
replace states = "Haryana"   if states=="HA" 

replace states= "Rajasthan" if states == "RA"
replace states="Madhya Pradesh" if states=="MP"  
replace states="Gujarat" if states=="GU"        //wheat control states(4-6)

replace states="Bihar" if states=="BI"
replace states="West Bengal" if states=="WB"    //rice control states(7-9)
replace states="Orissa" if states=="OR" 

replace states= "Others" if states=="AP"|states=="AS" | ///
                            states=="DE" |states=="JK" | ///
			    states=="KA" |states=="KE"|///
			    states=="MN" |states=="TR"|///
			    states=="TN"|states=="MA"

								   
label define order1  1 "Punjab" 2 "Uttar Pradesh" ///
                     3 "Haryana"   4 "Rajasthan"///
		     5 "Madhya Pradesh"   6 "Gujarat"///
		     7 "Bihar"   8 "West Bengal"  9 "Orissa"///
		    10 "Others"///
encode states, gen(state_code) label(order1)
drop states
rename state_code statecode

//Number of riots
by year state, sort: egen number=sum(statecode)

//Split UP into eastern and western UP							
by year,sort: gen West_UP=sum(number) if district=="Meerut"|district=="Bulandshahr"|     //
                                   district=="Ghaziabad"|district=="Muzaffarnagar"|   //
								   district=="Moradabad"|district=="Rampur"|district=="Sambhal"|    // 
								   district=="Bareilly"| district=="Budaun"|district=="Pilibhit"|//
								   district=="Shahjahanpur"|district=="Agra"|district=="Aligarh"|
								   district=="Etah"
gen WestUP=0
replace WestUP=1 if West_UP!=.

//Drop if missing observations in killed and injured, number and arrests
drop if killed==.
drop if injured==.
drop if number==.
drop if arrests==.

//Drop if year=1965, famine year. 1966(GR year)
drop if year==1965
keep if year<1985

//Form treatment and control groups
gen treat=0
replace treat=1 if statecode==1|statecode==2& WestUP==1|statecode==3  //GR wheat and rice states//
replace treat=2 if statecode==4|statecode==5|statecode==6 //wheat control states
replace treat=3 if statecode==7|statecode==8|statecode==9 //rice control states
replace treat=-1 if statecode==10

//Keep only treatment and control 
drop if treat==-1

//

