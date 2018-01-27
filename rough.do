cd "F:\3rd year_UH\Development Econ\Proposal Memo 3\Organisation\Data\Varshney-Wilkinson Dataset\DS0001"
insheet using 04342-0001-Data.csv
save vw, replace
set more off
tab statecode
sort year
//Gujarat: 243, Maharashtra: 201, Uttar Pradesh 200//

//YEAR Year of Riot
//MONTH Month of Riot
//MONTH_BY_N Numerical Month of Riot (1-12)
//DAY Day on which Riot Began (if given)
//COUNTRY Country in which reported riot occurred
//STATE State in which reported riot occurred
//STATECODE Two letter Abbreviation for the State in which reported riot occurred
//KEY
//Two letter Abbreviation for the State in which reported riot occurred, followed by four number year
//and two number month code for the data on which the riot took place
//DISTRICT District in which the reported riot took place
//TOWN_CITY Town in which the reported riot took place
//VILLAGE Village in which the reported riot took place
//KILLED Reported number killed in the riot
//INJURED Reported number injured in the riot
//ARRESTS Reported number arrested in the riot
//DURATION_I Reported duration of the riot in days
//SOURCE Source of riot (Times of India (Bombay), for these data)
//SOURCE_DAT Date of Source
//REPORTED_C Reported cause of riot
//LOCAL_PREC Reported local event that precipitated riot
//LINK_MADE_ Was there a reported link to an outside event?
//OFFICIALS Officials stationed in area or mentioned in reports of the riot
//OFFICIALS_ Officials reported as having been suspended or transferred during and after riot
//POLICE_VS_ Reports of police vs single group during the riot
//DALIT_MUSL Reports of Dalit vs Muslim violence during the riot
//TYPE_OF_PO Type of police presence in the area
//CODING_QUE Coding Question
//PROBABLE_C Probability
//RELIABILIT Reliability
//NOTES Notes on riots from press, including information necessary to support codes

tab statecode if year<1970

  STATECODE |      Freq.     Percent        Cum.
------------+-----------------------------------
         AP |         11        3.58        3.58
         AS |          8        2.61        6.19
         BI |         17        5.54       11.73
         DE |          8        2.61       14.33
         GU |         27        8.79       23.13
         HA |          2        0.65       23.78
         JK |         21        6.84       30.62
         KA |          8        2.61       33.22
         KE |         10        3.26       36.48
         MA |         32       10.42       46.91
         MP |         32       10.42       57.33
         OR |         11        3.58       60.91
         PU |          2        0.65       61.56
         RA |          7        2.28       63.84
         UP |         65       21.17       85.02
         WB |         46       14.98      100.00
------------+-----------------------------------
      Total |        307      100.00


. tab statecode if year>1970

  STATECODE |      Freq.     Percent        Cum.
------------+-----------------------------------
         AP |         40        4.78        4.78
         AS |         10        1.20        5.98
         BI |         56        6.70       12.68
         DE |         25        2.99       15.67
         GU |        213       25.48       41.15
         HA |          2        0.24       41.39
         JK |         32        3.83       45.22
         KA |         67        8.01       53.23
         KE |          9        1.08       54.31
         MA |        151       18.06       72.37
         MN |          1        0.12       72.49
         MP |         29        3.47       75.96
         OR |          6        0.72       76.67
         RA |         19        2.27       78.95
         TN |         16        1.91       80.86
         TR |          3        0.36       81.22
         UP |        135       16.15       97.37
         WB |         22        2.63      100.00
------------+-----------------------------------
      Total |        836      100.00
//After period: 1970-2000
//Before period: 1950-1970
//Treatment: Punjab: PU, UP, Haryana:HA    Control: Rajasthan: RA, MP, Bihar:BI, Gujarat: GU

********************************************************************************************************************

//This set of code converts string variables to numeric and reorders and regroups them

********************************************************************************************************************
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
by year,sort: gen West_UP=count if district=="Meerut"|district=="Bulandshahr"|     //
                                   district=="Ghaziabad"|district=="Muzaffarnagar"|   //
								   district=="Moradabad"|district=="Rampur"|district=="Sambhal"|    // 
								   district=="Bareilly"| district=="Budaun"|district=="Pilibhit"|//
								   district=="Shahjahanpur"|district=="Agra"|district=="Aligarh"|
								   district=="Etah"
label define order2 1"India" 0" "
encode West_UP, gen(WestUP) label(order2)
drop West_UP


//Drop if missing observations in killed and injured, number and arrests
drop if killed==.
drop if injured==.
drop if number==.
drop if arrests==.

//Drop if year=1965, famine year. 1966(GR year)
drop if year==1965
keep if year<1985


//Generate treatment variable for wheat and rice
gen treat=0
replace treat=1 if statecode==1|statecode==2& WestUP==1|statecode==3  //GR wheat and rice states//
replace treat=2 if statecode==4|statecode==5|statecode==6 //wheat control states
replace treat=3 if statecode==7|statecode==8|statecode==9 //rice control states
replace treat=-1 if statecode==10

//Summary Statistics Table
//tabstat number duration_i killed injured arrests, by(statecode) stat(mean sd min max n) col(stat) long nototal
//tabstat number duration_i killed injured arrests, by(treat) stat(mean sd min max n) col(stat) long nototal 

//Graphs
collapse number duration_i killed injured arrests, by(year treat)  //duration is in number of days//
twoway (line duration_i year if treat ==2) (line duration_i year if treat ==1, lpattern(dash)), xtitle(year) legend(on)
twoway (line number year if treat ==2) (line number year if treat ==1, lpattern(dash)), xtitle(year) legend(on)
twoway (line duration_i year if treat ==3) (line duration_i year if treat ==1, lpattern(dash)), xtitle(year) legend(on)
twoway (line number year if treat ==3) (line number year if treat ==1, lpattern(dash)), xtitle(year) legend(on)

//Tab districts


. tab district if treat==1 //treatment districts

                               DISTRICT |      Freq.     Percent        Cum.
----------------------------------------+-----------------------------------
                                Aligarh |          9       47.37       47.37
                               Bareilly |          3       15.79       63.16
                                 Budaun |          1        5.26       68.42
                                 Meerut |          2       10.53       78.95
                              Moradabad |          3       15.79       94.74
                            Yamunanagar |          1        5.26      100.00
----------------------------------------+-----------------------------------
                                  Total |         19      100.00

 tab district if treat==2 //wheat control districts

                               DISTRICT |      Freq.     Percent        Cum.
----------------------------------------+-----------------------------------
                              Ahmadabad |          5       19.23       19.23
                                Buldana |          1        3.85       23.08
                                  Damoh |          1        3.85       26.92
                                  Domoh |          1        3.85       30.77
                                Gwalior |          2        7.69       38.46
                                 Indore |          1        3.85       42.31
                               Jabalpur |          1        3.85       46.15
                                  Kheda |          1        3.85       50.00
                            Narsinghpur |          1        3.85       53.85
                            Panchmahals |          1        3.85       57.69
                                Raigarh |          1        3.85       61.54
                                 Saugor |          1        3.85       65.38
                                 Ujjain |          3       11.54       76.92
                      Vadodara (Baroda) |          6       23.08      100.00
----------------------------------------+-----------------------------------
                                  Total |         26      100.00

tab district if treat==3 //rice control districts

                   DISTRICT |      Freq.     Percent        Cum.
----------------------------------------+-----------------------------------
                     Aurangabad (Bihar) |          1        6.25        6.25
                               Calcutta |          5       31.25       37.50
                               Chaibasa |          1        6.25       43.75
                                  Haora |          1        6.25       50.00
                              Hazaribag |          1        6.25       56.25
                                  Malda |          2       12.50       68.75
                                Monghyr |          1        6.25       75.00
                            Muzaffarpur |          1        6.25       81.25
                                Nalanda |          1        6.25       87.50
                       Santhal Parganas |          1        6.25       93.75
                          West Dinajpur |          1        6.25      100.00
----------------------------------------+-----------------------------------
                                  Total |         16      100.00

//Next step: find out the wheat and rice districts under the GR in UP and Punjab
//Similarly, find wheat and rice districts in control group too

