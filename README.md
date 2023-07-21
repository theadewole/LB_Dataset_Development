# LB Dataset Development
- Program Developer : Adewole Ogunade
- Date: 10-05-2023
- Project Title: LB Dataset Development  
- Description: Development of SDTM dataset (LB) by using raw datasets
## Inputs
	DM.SAS7bdat (Demographics SDTM dataset) 
	LAB.SAS7bdat (Raw Dataset)
## Tasks
	Explained in the Requirement Specification (RSD)

|Variable Name 	|Variable Label |Type 	|Algorithm|
|---------------|---------------|-------|----------|
|STUDYID|Study|Identifier |Char|DM.STUDYID|
|DOMAIN |Domain Abbreviation |Char| "LB"|
|USUBJID |Unique Subject Identifier| Char| DM.USUBJID|
|LBSEQ |Sequence Number| Num |If first.usubjid then LBSEQ=1; else LBSEQ+1;|
|LBTESTCD |Lab Test or Examination Short Name|Char |Lab.PARAMCD|
|LBTEST |Lab Test or Examination Name |Char| Lab.PARAM|
|LBCAT |Category for Lab Test| Char| Lab.LABT_|
|LBORRES |Result or Finding in Original Units| Char |Lab.LB_VALUE|
|LBORRESU |Original Units |Char |Lab.LB_UNIT|
|LBORNRLO |Reference Range Lower Limit in Orig Unit |Char |Lab.NORL_INV|
|LBORNRHI| Reference Range Upper Limit in Orig Unit |Char| Lab.NORH_INV|
|LBORNRHI |Reference Range Upper Limit in Orig Unit |Char| Lab.NORH_INV|
|LBSTRESN |Numeric Result/Finding in Standard Units |Num |Used for continuous or numeric results or findings in standard format; copied in numericformat from LBSTRESC.|
|LBSTRESU| Standard Units |Char| Lab.SI_UNIT|
|LBSTNRLO |Reference Range Lower Limit-Std Units| Num| Lab.SHIFT_L|
|LBSTNRHI| Reference Range Upper Limit-Std Units| Num |Lab.SHIFT_H|
|LBNRIND |Reference Range Indicator |Char|  if lbcat not in(‘URINALYSIS) and lborres not  in(‘ ‘) then do;	If .<lbstresn<lbstnrlo then lbnrind='LOW' else if lbstnrlo<=lbstresn<=lbstnrhi then lbnrind='Normal' else if lbstresn>lbstrnhi then lbnrind='HIGH'End;	Else if lbcat not in (‘HEMATOLOGY’,’CHEMISTRY’) and lborres not in (‘ ‘) then do;	If flag in ('H') then lbnrind='HIGH' else If flag in ('L') then lbnrind='LOW' else If flag in (' ') then lbnrind='NORMAL'	End;|
|LBNAM| Vendor Name |Char|   |
|LBBLFL |Baseline Flag |Char |LBBLFL=’Y’ when last non-missing assessment on or before start of study medication.|
|LBDRVFL| Derived Flag |Char| if lbtestcd in('ALP' 'ALT' 'AST' 'BILDIR' 'BILI' 'BILIND' 'HCT' 'HGB') then lbtestcd='T' || lbtestcd;	if substr(lbtestcd,1,1)='T' then lbdrvfl=’Y'|
|VISITNUM |Visit Number| Num |if first.subjid or first.lbtestcd then visitnum = 1; else visitnum + 1;|
|VISIT |Visit Name |Char|if visitd eq "SCREENING" then visit="SCREENING"; 	else if visitd eq "SCREENING_R.1" then visit=" SCREENING (DAY -28 TO DAY -1):	UNSCHEDULED 1"; 	else if visitd eq "SCREENING_R.2" then visit="Screening (Day -28 To Day -1): Unscheduled 2";	else if visitd eq "WEEK 2" then visit="VISIT 2 (WEEK 2)";	else if visitd eq "MONTH 1" then visit="VISIT 2 (MONTH 1)";	else if visitd eq "MONTH 1_R.1" then visit="VISIT 2 (MONTH 1): UNSCHEDULED 1"; ……|
|LBDTC| Date/Time of Specimen Collection |Char |(ISO8601 format)|
|LBDY| Study Day of Specimen Collection|Num |if LBDTC >= RFDTC then LBDY = LBDT-RFSTDT|

## Output 	
- [Programs](https://github.com/theadewole/LB_Dataset_Development/blob/main/LB.sas)
- [Spreadsheet File of the Final Dataset](https://docs.google.com/spreadsheets/d/1ruB-mbZYnjm60qy-rXbb-9KeiKL9lmns/edit?usp=sharing&ouid=117399581833546938372&rtpof=true&sd=true) 
