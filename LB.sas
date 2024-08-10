/*Establishing Library*/
LIBNAME MYSNIP '/home/u63305936/Internship Series/LB Dataset Development';
RUN;

/*Creating a unique key in the lab dataset called 'Subject' From for PNO column merging and changing 
the format to character and specifying the lenght*/
DATA Lab; 
	LENGTH Subject $8;
	SET mysnip.lab;
	Subject=STRIP(INPUT(PNO,$20.));
RUN;

/*Keeping the column that will be needed in the DM dataset before merging*/
DATA Dm  (KEEP=USUBJID SUBJID STUDYID RFSTDTC);
	SET MYSNIP.dm;
RUN;

/*Merging DM and LAB dataset*/
PROC SQL;
	CREATE TABLE DM_LB AS
	SELECT * 
	FROM LAB
	INNER JOIN DM
	ON Lab.Subject=Dm.SUBJID;
	QUIT;
RUN;
	
/*specifying LB domain*/
DATA LB1    (DROP=pno subject);
	LENGTH DOMAIN $4;
	SET DM_LB;
	DOMAIN='LB';
RUN;

/*Creating LBTEST and LBTESTCD*/
*Looking at the distinct values in the Param variable to specify LBTEST and LBTESTCD;
Proc sql;
Select distinct(param)
from lb1;
Quit;

DATA LB2;
	LENGTH LBTEST $40 LBTESTCD $8; 
	SET LB1;
	IF Param='B-HCG, QUAL' THEN DO;
	LBTEST='Choriogonadotropin Beta';
	LBTESTCD='HCG';
	END;
	
	IF Param='ALT' THEN DO;
	LBTEST='Alanine Aminotransferase; SGPT';
	LBTESTCD='ALT';
	END;
	
	IF Param='AST' THEN DO;
	LBTEST='Aspartate Aminotransferase; SGOT';
	LBTESTCD='ALT';
	END;
	
	IF Param='HEMOGLOBIN' THEN DO;
	LBTEST='HEMOGLOBIN';
	LBTESTCD='HGB';
	END;

	IF Param='BILIRUBIN DIRECT' THEN DO;
	LBTEST='Direct Bilirubin';
	LBTESTCD='BILDIR';
	END;

	IF Param='BILIRUBIN TOTAL' THEN DO;
	LBTEST='Bilirubin';
	LBTESTCD='BILI';
	END;
	
	IF Param='HEMATOCRIT' THEN DO;
	LBTEST='Hematocrit';
	LBTESTCD='HCT';
	END;
	
	IF Param='ALKALINE PHOSPHATASE' THEN DO;
	LBTEST='Alkaline Phosphatase';
	LBTESTCD='ALP';
	END;
	
	IF Param='ALBUMIN' THEN DO;
	LBTEST='Albumin; Microalbumin';
	LBTESTCD='ALB';
	END;	

	IF Param='ERYTHROCYTES' THEN DO;
	LBTEST='Erythrocytes';
	LBTESTCD='RBC';
	END;
	
	IF Param='LEUCOCYTES' THEN DO;
	LBTEST='Leukocytes';
	LBTESTCD='WBC';
	END;
	
	IF Param='CREATININE' THEN DO;
	LBTEST='Creatinine';
	LBTESTCD='CREAT';
	END;	
	
	IF Param='SODIUM' THEN DO;
	LBTEST='Sodium';
	LBTESTCD='SODIUM';
	END;
		
	IF Param='POTASSIUM' THEN DO;
	LBTEST='Potassium';
	LBTESTCD='K';
	END;
	
	IF Param='GLUCOSE' THEN DO;
	LBTEST='Glucose';
	LBTESTCD='GLUC';
	END;
	
	IF Param='PLATELETS' THEN DO;
	LBTEST='Platelets';
	LBTESTCD='PLAT';
	END;
	
	IF Param='UREA' THEN DO;
	LBTEST='Urea';
	LBTESTCD='UREA';
	END;
RUN;

/*Specify LBCAT */
DATA LB3_1;
	SET LB2;
	LCAT=SUBSTR(Labt_,3);
RUN;

PROC SQL;
	CREATE TABLE LB3 AS
	SELECT *,CASE
	WHEN lcat='URINE' THEN 'URINALYSIS'
	WHEN lcat='CLINICAL CHEMISTRY' THEN 'CHEMISTRY'
	ELSE 'HEMATOLOGY'
	END AS LBCAT
	FROM LB3_1;
	QUIT;
RUN;

/*Standardizing some of the column to SDTM*/
DATA LB4;
	LENGTH LBCAT $40 LBORRES $40 LBORRESU $8 LBORNRLO $8 LBORNRHI $8 LBSTRESC $8 
	LBSTRESN 8 LBSTRESU $8 LBSTNRLO 8 LBSTNRHI 8;
	SET LB3;	
	LBORRES=LB_VALUE;
	LBORRESU=LB_UNIT;
	LBORNRLO=NORL_INV;
	LBORNRHI=NORH_INV;
	LBSTRESC=LBORRES;
	LBSTRESN=INPUT(COMPRESS(LBSTRESC,"ABCDEFGHIJKLMNOPQRSTUVWXYZ"),Comma8.);
	LBSTRESU=SI_UNIT;
	LBSTNRLO=SHIFT_L;
	LBSTNRHI=SHIFT_H;
RUN;

/*Specifying LBNRIND*/
DATA LB5;
	LENGTH LBNRIND $40;
	SET LB4;
	IF LBCAT NE 'URINALYSIS' AND LBSTRESN NE ' '  THEN DO;
	IF .<LBSTRESN<LBSTNRLO THEN LBNRIND ='LOW';
	ELSE IF LBSTNRLO<=LBSTRESN<=LBSTNRHI THEN lbnrind='Normal';
	ELSE IF LBSTRESN>LBSTNRHI THEN LBNRIND ='HIGH';
	END;
	ELSE IF LBCAT IN ('HEMATOLOGY','CHEMISTRY') AND LBSTRESN
	NE '' THEN DO;
	IF FLAG='H' THEN LBNRIND ='HIGH' ;
	ELSE IF FLAG='L' THEN LBNRIND ='LOW' ;
	ELSE IF FLAG=' ' THEN LBNRIND ='NORMAL' ;
	END;
RUN;

/*Specifying derived flag and vendor name*/
DATA LB6 (DROP=Visit);
	LENGTH LBNAM $12;
	SET LB5;
	LBNAM='Whiteboard';
	IF LBTESTCD in ('ALP' 'ALT' 'AST' 'BILDIR' 'BILI' 'BILIND' 'HCT' 'HGB') THEN LBTESTCD='T'||LBTESTCD;
	IF SUBSTR(LBTESTCD,1,1)='T' THEN LBDRVFL='Y';
RUN; 



/*Specifying Visit*/
		/*Creating Formats to resolve visit*/
PROC FORMAT;
	VALUE $ Visit
	"SCREENING_R.1" ="SCREENING (DAY -28 TO DAY -1): UNSCHEDULED 1"
	"SCREENING_R.2" ="SCREENING (DAY -28 TO DAY -1): UNSCHEDULED 2"
	"WEEK 2" ="VISIT 2 (WEEK 2)"
	"MONTH 1" = "VISIT 2 (MONTH 1)"
	"MONTH 2" = "VISIT 2 (MONTH 2)"
	"MONTH 3" = "VISIT 2 (MONTH 3)"
	"MONTH 4" = "VISIT 2 (MONTH 4)"
	"MONTH 5" = "VISIT 2 (MONTH 5)"
	"MONTH 6" = "VISIT 2 (MONTH 6)"
	"MONTH 7" = "VISIT 2 (MONTH 7)"
	"MONTH 8" = "VISIT 2 (MONTH 8)"
	"MONTH 9" = "VISIT 2 (MONTH 9)"
	"MONTH 10" = "VISIT 2 (MONTH 10)"
	"MONTH 11" = "VISIT 2 (MONTH 11)"
	"MONTH 12" = "VISIT 2 (MONTH 12)"
	"MONTH 13" = "VISIT 2 (MONTH 13)"
	"MONTH 14" = "VISIT 2 (MONTH 14)"
	"MONTH 15" = "VISIT 2 (MONTH 15)"
	"MONTH 16" = "VISIT 2 (MONTH 16)"
	"MONTH 17" = "VISIT 2 (MONTH 17)"
	"MONTH 18" = "VISIT 2 (MONTH 18)"
	"MONTH 19" = "VISIT 2 (MONTH 19)"
	"MONTH 20" = "VISIT 2 (MONTH 20)"
	"MONTH 21" = "VISIT 2 (MONTH 21)"
	"MONTH 22" = "VISIT 2 (MONTH 22)"
	"MONTH 23" = "VISIT 2 (MONTH 23)"
	"MONTH 24" = "VISIT 2 (MONTH 24)"
	"MONTH 25" = "VISIT 2 (MONTH 25)"
	"MONTH 26" = "VISIT 2 (MONTH 26)"
	"MONTH 27" = "VISIT 2 (MONTH 27)"
	"MONTH 28" = "VISIT 2 (MONTH 28)"
	"MONTH 29" = "VISIT 2 (MONTH 29)"
	"MONTH 30" = "VISIT 2 (MONTH 30)"
	"MONTH 31" = "VISIT 2 (MONTH 31)"
	"MONTH 32" = "VISIT 2 (MONTH 32)"
	"MONTH 33" = "VISIT 2 (MONTH 33)"
	"MONTH 34" = "VISIT 2 (MONTH 34)"
	"MONTH 35" = "VISIT 2 (MONTH 35)"
	"MONTH 36" = "VISIT 2 (MONTH 36)"
	"MONTH 37" = "VISIT 2 (MONTH 37)"
	"MONTH 38" = "VISIT 2 (MONTH 38)"
	"MONTH 39" = "VISIT 2 (MONTH 39)"
	"MONTH 40" = "VISIT 2 (MONTH 40)"
	"MONTH 41" = "VISIT 2 (MONTH 41)"
	"MONTH 42" = "VISIT 2 (MONTH 42)"
	"MONTH 43" = "VISIT 2 (MONTH 43)"
	"MONTH 1_R.1" = "VISIT 2 (MONTH 1)UNSCHEDULED 1"
	"MONTH 2_R.1" = "VISIT 2 (MONTH 2) UNSCHEDULED 2"
	"MONTH 3_R.1" = "VISIT 2 (MONTH 3) UNSCHEDULED 3"
	"MONTH 4_R.1" = "VISIT 2 (MONTH 4) UNSCHEDULED 4"
	"MONTH 5_R.1" = "VISIT 2 (MONTH 5) UNSCHEDULED 5"
	"MONTH 6_R.1" = "VISIT 2 (MONTH 6)UNSCHEDULED 6"
	"MONTH 7_R.1" = "VISIT 2 (MONTH 7)UNSCHEDULED 7"
	"MONTH 8_R.1" = "VISIT 2 (MONTH 8)UNSCHEDULED 8"
	"MONTH 9_R.1" = "VISIT 2 (MONTH 9)UNSCHEDULED 9"
	"MONTH 10_R.1" = "VISIT 2 (MONTH 10)UNSCHEDULED 10"
	"MONTH 11_R.1" = "VISIT 2 (MONTH 11)UNSCHEDULED 11"
	"MONTH 12_R.1" = "VISIT 2 (MONTH 12)UNSCHEDULED 12"
	"MONTH 13_R.1" = "VISIT 2 (MONTH 13)UNSCHEDULED 13"
	"MONTH 14_R.1" = "VISIT 2 (MONTH 14)UNSCHEDULED 14"
	"MONTH 15_R.1" = "VISIT 2 (MONTH 15)UNSCHEDULED 15"
	"MONTH 16_R.1" = "VISIT 2 (MONTH 16)UNSCHEDULED 16"
	"MONTH 17_R.1" = "VISIT 2 (MONTH 17)UNSCHEDULED 17"
	"MONTH 18_R.1" = "VISIT 2 (MONTH 18)UNSCHEDULED 18"
	"MONTH 19_R.1" = "VISIT 2 (MONTH 19)UNSCHEDULED 19"
	"MONTH 20_R.1" = "VISIT 2 (MONTH 20)UNSCHEDULED 20"
	"MONTH 21_R.1" = "VISIT 2 (MONTH 21)UNSCHEDULED 21"
	"MONTH 22_R.1" = "VISIT 2 (MONTH 22)UNSCHEDULED 22"
	"MONTH 23_R.1" = "VISIT 2 (MONTH 23)UNSCHEDULED 23"
	"MONTH 24_R.1" = "VISIT 2 (MONTH 24)UNSCHEDULED 24"
	"MONTH 25_R.1" = "VISIT 2 (MONTH 25)UNSCHEDULED 25"
	"MONTH 26_R.1" = "VISIT 2 (MONTH 26)UNSCHEDULED 26"
	"MONTH 27_R.1" = "VISIT 2 (MONTH 27)UNSCHEDULED 27"
	"MONTH 28_R.1" = "VISIT 2 (MONTH 28)UNSCHEDULED 28"
	"MONTH 29_R.1" = "VISIT 2 (MONTH 29)UNSCHEDULED 29"
	"MONTH 30_R.1" = "VISIT 2 (MONTH 30)UNSCHEDULED 30"
	"MONTH 31_R.1" = "VISIT 2 (MONTH 1)UNSCHEDULED 31"
	"MONTH 32_R.1" = "VISIT 2 (MONTH 1)UNSCHEDULED 32"
	"MONTH 33_R.1" = "VISIT 2 (MONTH 1)UNSCHEDULED 33"
	"MONTH 34_R.1" = "VISIT 2 (MONTH 1) UNSCHEDULED 34"
	"MONTH 35_R.1" = "VISIT 2 (MONTH 35)UNSCHEDULED 35"
	"MONTH 36_R.1" = "VISIT 2 (MONTH 36) UNSCHEDULED 36"
	"MONTH 40_R.1" = "VISIT 2 (MONTH 40)UNSCHEDULED 40"
	"END OF TREAT_R.1" = "END OF TREAT (DAY -28 TO DAY -1): UNSCHEDULED 1"
	"END OF TREAT_R.2" = "END OF TREAT (DAY -28 TO DAY -1): UNSCHEDULED 2"
	"EVENT_R.1" = "EVENT (DAY -28 TO DAY -1): UNSCHEDULED 1"
	"EVENT_R.2" = "EVENT (DAY -28 TO DAY -1): UNSCHEDULED 2"
	"FOLLOW UP_R.1" = "FOLLOW UP_R.1 (DAY -28 TO DAY -1): UNSCHEDULED 1"
	"FOLLOW UP_R.2" = "FOLLOW UP_R.2 (DAY -28 TO DAY -1): UNSCHEDULED 2"
	"Local Lab - Page 001a" = "Local Lab (DAY -28 TO DAY -1): UNSCHEDULED 1a"
	"Local Lab - Page 001b" = "Local Lab (DAY -28 TO DAY -1): UNSCHEDULED 1b"
	"Local Lab - Page 001c" = "Local Lab  (DAY -28 TO DAY -1): UNSCHEDULED 1c"
	"RETEST 1" = "VISIT 2 (RETEST 1)"
	"RETEST 2" = "VISIT 2 (RETEST 2)"
	"RETEST 3" = "VISIT 2 (RETEST 3)"
	"RETEST 4" = "VISIT 2 (RETEST 4)"
	"RETEST 5" = "VISIT 2 (RETEST 5)"
	"RETEST 6" = "VISIT 2 (RETEST 6)"
	"RETEST 7" = "VISIT 2 (RETEST 7)"
	"RETEST 8" = "VISIT 2 (RETEST 8)"
	"RETEST 9" = "VISIT 2 (RETEST 9)"
	"RETEST 10" = "VISIT 2 (RETEST 10)"
	"RETEST 11" = "VISIT 2 (RETEST 11)"
	"RETEST 12" = "VISIT 2 (RETEST 12)"
	"RETEST 13" = "VISIT 2 (RETEST 13)"
	"RETEST 14" = "VISIT 2 (RETEST 14)"
	"RETEST 15" = "VISIT 2 (RETEST 15)"
	"RETEST 1_R.1" = "VISIT 2 (RETEST 1)UNSCHEDULED 1"
	"RETEST 2_R.1" = "VISIT 2 (RETEST 2) UNSCHEDULED 2"
	"RETEST 3_R.1" = "VISIT 2 (RETEST 3) UNSCHEDULED 3"
	"RETEST 5_R.1" = "VISIT 2 (RETEST 5) UNSCHEDULED 5"
	"RETEST 6_R.1" = "VISIT 2 (RETEST 6)UNSCHEDULED 6"
	"RETEST 7_R.1" = "VISIT 2 (RETEST 7)UNSCHEDULED 7"
	"RETEST 8_R.1" = "VISIT 2 (RETEST 8)UNSCHEDULED 8"
	"RETEST 9_R.1" = "VISIT 2 (RETEST 9)UNSCHEDULED 9"
	"RETEST 10_R.1" = "VISIT 2 (RETEST 10)UNSCHEDULED 10"
	"RETEST 11_R.1" = "VISIT 2 (RETEST 11)UNSCHEDULED 11"
	"RETEST 12_R.1" = "VISIT 2 (RETEST 12)UNSCHEDULED 12"
	"RETEST 13_R.1" = "VISIT 2 (RETEST 13)UNSCHEDULED 13"
	"RETEST 14_R.1" = "VISIT 2 (RETEST 14)UNSCHEDULED 14"
	"RETEST 15_R.1" = "VISIT 2 (RETEST 15)UNSCHEDULED 15"
	"RETEST 16_R.1" = "VISIT 2 (RETEST 15)UNSCHEDULED 16"
	;
RUN;
/*Applying the format*/
DATA LB7;
	LENGTH VISIT $40;
	SET LB6;
	VISIT=PUT(Visitd,Visit.);
RUN;


/*Specifying Date/Time of Specimen  Collection in ISO format*/
DATA LB8;
	SET LB7;
	LB=INPUT(date,anydtdte32.);
	FORMAT lb mmddyy10.;
	LBDTC=PUT(LB,IS8601da.);
RUN;

/*Converting the character date column variable to numeric and specifying LBDY*/
DATA LB9;
	SET LB8;
	LBDT=INPUT(LBDTC,anydtdte32.);
	RFDTC=INPUT(RFSTDTC,yymmdd10.);
	IF LBDT >= RFDTC THEN LBDY =(LBDT-RFDTC)+1;
	ELSE IF LBDT < RFDTC THEN LBDY =LBDT-RFDTC;
RUN;

/*Specifying Baseline Flag*/
DATA LB10;
	SET LB9;
	IF LBDT NE . AND RFDTC NE . AND LBDT LE RFDTC AND LBSTRESN NE . THEN LBBLFL='Y';
RUN;

/*Specifying Visit Number*/
PROC SORT DATA=LB10  OUT=LB10_1;
	BY SUBJID LBTESTCD LBDT Visitd;
RUN;

DATA LB11;
	SET LB10_1;
	BY SUBJID LBTESTCD LBDT Visitd;
	IF First.SUBJID OR FIRST.LBTESTCD then VISITNUM = .;
	VISITNUM + 1;
RUN;

/*Specifying LBSEQ*/
PROC SORT DATA=LB11    OUT=LB11_1;
	BY USUBJID LBTESTCD LBDT Visitd;
RUN;

DATA LB12;
	SET LB11_1;
	BY USUBJID LBTESTCD LBDT Visitd;
	IF FIRST.USUBJID THEN LBSEQ=1; 
	ELSE LBSEQ+1;
RUN;

/*Creating the Final LB Dataset*/	
PROC SQL ;
	CREATE TABLE LB AS 
	SELECT
	STUDYID "Study Identifier",
	DOMAIN "Domain Abbreviation",
	USUBJID "Unique Subject Identifier",
	LBSEQ	"Sequence Number",
	LBTESTCD "Lab Test or Examination Short Name",
	LBTEST "Lab Test or Examination Name",
	LBCAT "Category for Lab Test ",
	LBORRES "Result or Finding in Original Units",
	LBORRESU "Original Units",
	LBORNRLO "Reference Range Lower Limit in Original Unit",
	LBORNRHI "Reference Range Upper Limit in Original Unit",
	LBSTRESC "Character Result/Finding in Standard Format",
	LBSTRESN "Numeric Result/Finding in Standard Units",
	LBSTRESU "Standard Units",
	LBSTNRLO "Reference Range Lower Limit-Standard Units",
	LBSTNRHI "Reference Range Upper Limit-Standard Units",
	LBNRIND "Reference Range Indicator",
	LBNAM "Vendor Name",
	LBBLFL "Baseline Flag ",
	LBDRVFL "Derived Flag",
	VISITNUM "Visit Number",
	VISIT "Visit Name",
	LBDTC "Date/Time of Specimen Collection",
	LBDY "Study Day of Specimen Collection"
	FROM LB12;
	QUIT;
RUN;


/*Creating  The final dataset in sas7bdat format*/
PROC COPY IN=work OUT=mysnip; 
	SELECT LB; 
RUN;


/*Exporting Final Dataset to Spreadsheet Format*/
PROC EXPORT DATA=work.LB OUTFILE="/home/u63305936/LB_Dataset.xlsx"
	DBMS=XlSX
	REPLACE;
	SHEET="LB";
RUN;

