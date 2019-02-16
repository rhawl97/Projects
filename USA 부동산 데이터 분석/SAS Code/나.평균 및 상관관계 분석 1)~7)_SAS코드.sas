proc import 
datafile = 'C:\Users\Kim Yuum\Desktop\real-estate-db.csv'  out = realestate dbms = csv replace;
run;
/*데이터 필터링*/
DATA realestate  ;
set realestate ;
keep state rent_mean family_mean family_samples rent_samples hc_mean debt  divorced;
run; 
/*1. State별 gross rent 평균 비교*/
DATA realestate;
set realestate;
family_total = family_mean*family_samples;
rent_total = rent_mean*rent_samples;
run;

PROC SORT DATA= realestate;
BY state;
run;
PROC UNIVARIATE DATA=realestate;
BY state;
VAR family_total rent_total family_samples rent_samples;
OUTPUT OUT= please SUM=family_sum rent_sum family_samples_sum rent_samples_sum;
run;

proc print data=please;
run;

DATA realestate_please;
set please ;
family_real_mean = family_sum/family_samples_sum;
rent_real_mean = rent_sum/rent_samples_sum;
run;

proc print data= realestate_please;
var state family_real_mean rent_real_mean;
title "Family Income and Rent";
run;

PROC SGPLOT;
	VBAR state/ RESPONSE = rent_real_mean;
	TITLE "Distribution of Rent_Mean by State";
RUN;

/*2. State별 gross family income 평균 비교*/
PROC SGPLOT;
	VBAR state/RESPONSE = family_real_mean;
	TITLE "Distribution of Gross Income by State";
run;

/*3. gross family income 상위 4개 주와 최하위 주의 소득 분포*/
DATA realestate1;
set realestate;
if state = 'Distri' or state= 'Connec' or state = 'Maryla' or state = 'New Je' or state = 'Puerto';
run;

PROC BOXPLOT DATA=realestate1;
	PLOT family_mean*state / BOXSTYLE = SKELETAL BOXWIDTH = 5;
	TITLE ;
RUN;

/*4. 주 별 학력 비교 */
PROC SGPLOT;
	VBAR state/ RESPONSE = hs_degree STAT = MEAN  BARWIDTH = 1;
	TITLE "Distribution of High School Degree by State";
RUN;

/*5. 미국 총 소득에 대한 이혼율, 학력과의 상관관계 분석*/
DATA realestate_dg  ;
set realestate ;
keep state family_total hs_degree divorced debt;
run; 

PROC CORR;
	VAR hs_degree divorced debt;
	WITH family_total;
	TITLE 'Correlations for Gross Income';
	TITLE2 'With Level of Education and Divorce Rate';
RUN;

PROC CORR DATA = realestate_dg PLOTS(MAXPOINTS = NONE) = (SCATTER MATRIX) ;
	VAR hs_degree divorced;
	WITH family_total;
	TITLE 'Correlation Plots for Gross Income';
	TITLE2 'With Level of Education and Divorce Rate';
RUN;
