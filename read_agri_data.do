
cd "C:\Users\Shreya\Desktop\Spring 2018\Third Year Paper\Proposal Memo 3\Organisation\Data\WB_India_Agric_Data\txt\DTA files"

set trace on
set more off
*****This code reads in all the text files into Stata. The output from this code are the dta files of agro climatic***** 
*****data for India from 1950-85, excluding years from 1951-56. There was an error while opening the 1956 dataset.*****

//Define local for different year datasets
local years 50 56 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 

foreach y in `years' {
clear all
infile ID YEAR AGGDPDF CODE POPDEN PRSEED HYVWHEAT HYVRICE HYVMAIZE HYVBAJRA HYVJOWAR AGLABOR CULTIVAT WAGE NCA GCA NIA GIA YWHEAT YRICE YSUGAR YMAIZE YPOTATO YGNUT YBARLEY YTOBAC YGRAM	YTUR YRAGI YSESAMUM	YRMSEED	YBAJRA YCOTTON	YJOWAR YOPULS YJUTE	YSOY YSUNFLWR ROADS	LITERACY FEBXT	FEBNT DMS01	DMS02 DMS03	DMS04 DMS05	DMS06 DMS07	DMS08 DMS09	DMS10 DMS11	DMS12 DMS13	DMS14 DMS15	DMS16 DMS17	DMS18 DMS19	DMS20 DMS21	DMAQ3 DMAQ2	DMAQ1 DMSLP4 DMSLP567 DMPH4	DMPH5 DMPH6	DMPH7 DMPH8	DMSLP1 DMSLP2 DMSLP3 COSTAGLB COSTCULT COSTBULL	COSTTRAC COSTNITR COSTP2O5 COSTK2O DMTS1 DMTS2 DMTS3 DMTS4 DMTS5 QSUGAR DAYS STATE DISTRICT	QBULLOCK QTRACTOR PTRACTOR PUPBULL PBULLOCK	QLABOR QNITRO QP2O5 QK2O PNITRO	PP2O5 PK2O QLAND ROPUMP	RPWPUMP	UOPUMP UEPUMP UPWPUMP PHYVWHT PHYVRICE PHYVJOWR PHYVBAJR PHYVMAIZ IROADS AWHEAT QWHEAT	ARICE QRICE	ASUGAR AMAIZE QMAIZE APOTATO QPOTATO AGNUT QGNUT ABARLEY QBARLEY ATOBAC	QTOBAC AGRAM QGRAM ATUR	QTUR ARAGI QRAGI ASESAMUM QSESAMUM ARMSEED QRMSEED PWHEAT PRICE	PSUGAR PMAIZE PPOTATO PGNUT PBARLEY PTOBAC PGRAM PTUR PRAGI	PSESAMUM PRMSEED ABAJRA	QBAJRA ACOTTON QCOTTON AJOWAR QJOWAR PJOWAR	PBAJRA PCOTTON AOPULS QOPULS POPULS	AJUTE QJUTE	PJUTE ASOY QSOY	ASUNFLWR QSUNFLWR PSOY PSUNFLWR	str30 DISTNAME ALT str30 STATENAM DSEA LON LAT RNJAN RNFEB RNMAR RNAPR RNMAY RNJUN RNJUL RNAUG RNSEP RNOCT RNNOV RNDEC TNJAN TNFEB TNMAR TNAPR TNMAY TNJUN TNJUL TNAUG TNSEP TNOCT TNNOV TNDEC DMSTS1 DMSTS2 DMSTS3	DMSTS4 DMSTS5 TOTAREA AHYV QBULLHA QTRACHA DMXS01 DMSX01 DMXS02	DMSX02 DMXS03 DMXS04 DMXS05	DMXS06 DMXS07 DMXTS1 DMSXT1	DMXTS2 DMXTS3 using "F:\3rd year_UH\Development Econ\Proposal Memo 3\Organisation\Data\WB_India_Agric_Data\txt\india`y'.txt"

//Save all the dta files together in one folder
	save "DTA files\india`y'.dta", replace

}



****This code will append all the datasets together to form the full panel****

//Append all the years together
use india50,clear
local years 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 
 
foreach y of `years'   {
     append using india`y'

}


save india_agro_climate.dta, replace

//Make a local for the folder to be used
local foldername "C:\Users\Shreya\Desktop\Spring 2018\Third Year Paper\Proposal Memo 3\Organisation\Data\WB_India_Agric_Data\txt\DTA files"
cap mkdir foldername
cd "`foldername'"
clear

//Local for all the files
local india : dir . files "india*"
di `india'

//Local for the first year
local year1 50 
di `year1' 

//Local for the 1950 file
local india50: dir .files "india`year1'"
di `india50'

//Open the file for 1950
use india50, clear

//Make the append loop
local years 57 58 59 60 61 62 63 64 65 66 67 68 69 70 71 72 73 74 75 76 77 78 79 80 81 82 83 84 85 
di `years'
foreach y in `years' {
append using india`y'


}


//Make a local for all the datasets except for india50
local all_datafiles_withoutindia50 : list india - india50
di `all_datafiles_withoutindia50'

**** Open it
use "`first_datafile'", clear

**** Generate variable that shows the source
gen source = "`first_datafile'"

****
local all_datafiles_withoutfirst : list allbutthebeer_datafiles_all - first_datafile
**** Loop over all the other files
foreach datafile of local all_datafiles_withoutfirst {
	display "." _continue
	append using `datafile'
	replace source = "`datafile'" if missing(source)
}


