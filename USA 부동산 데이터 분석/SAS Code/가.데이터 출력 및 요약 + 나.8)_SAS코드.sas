%let location=C:\Users\user\Desktop\통계자료처리및실습;
libname class "&location";
proc import datafile="&location.\real_estate_db.csv" dbms=csv
out=class.rs replace;
run;

data rs2;
set class.rs;
run;
proc sort data=rs2;
by state; /*누적 합을 구할 때 First.state 형식의 사용을 위하여 Proc sort statement를 이용하여 정렬*/
run;
data rs2;
set rs2;
by state;
retain cumpop; /*Retain statement를 사용하여 누적합을 구한다.*/
if first.state=1 then cumpop=0;
cumpop=cumpop+pop;
run;
data state_pop;
set rs2;
by state;
if last.state=1 then output; /*그룹별 마지막 관측치에 주별 인구 총합이 계산되어 있다는 점을 이용한다.*/
run;
proc print data=rs2;
where rent_median>3000; /*데이터셋이 올바르게 생성되었는지 확인하기 위하여 편의상 조건을 주어*/
var state city place pop rent_mean rent_median rent_stdev pct_own cumpop; /*데이터셋을 출력한다.*/
format rent_mean rent_median rent_stdev 5.3 pct_own percent5.3;
run;
proc means data=state_pop;
var cumpop; /*state_pop에 대해서도 확인한다.*/
run;

proc format;
value iit 0-10000="1 quantile" /*소득 분위에 대한 Format인 iit를 생성한다.*/
10000-<15000="2 quantile"
15000-<20000="3 quantile"
20000-<25000="4 quantile"
25000-<30000="5 quantile"
30000-<35000="6 quantile"
35000-<40000="7 quantile"
40000-<45000="8 quantile"
45000-<50000="9 quantile"
50000-<55000="10 quantile"
55000-<60000="11 quantile"
60000-<75000="12 quantile"
75000-<100000="13 quantile"
100000-<125000="14 quantile"
125000-<150000="15 quantile"
150000-<200000="16 quantile"
200000-HIGH="17 quantile";

data rs2;
set rs2;
family_m=family_mean; /*family_mean의 수치형 값을 사용하기 위하여 그 값을 복사하여 family_m 칼럼에 생성한다.*/
format family_mean iit.; /*family_mean에 iit Format을 적용한다.*/
hc_mortgage_mean=hc_mortgage_mean*1; /*hc_mortgage_mean가 문자형 변수로 저장되있으므로 이를 수치형 변수로 변환한다.*/
rename family_mean=Income_quantile;
proc freq data=rs2;
table Income_quantile; /*소득 분위에 대해서 빈도분석*/
run;
proc sgplot data=rs2;
hbar Income_quantile; /*그래프를 그려 분석*/
run;
proc univariate data=rs2;
var family_m;
run;

title Report #2;
proc tabulate data=rs2 missing;
class income_quantile;
var rent_mean rent_gt_30 hc_mortgage_mean home_equity_second_mortgage pop;
table income_quantile all, mean=''*rent_mean*format=dollar5.0 mean=''*rent_gt_30 
mean=''*hc_mortgage_mean*format=dollar5.0 mean=''*home_equity_second_mortgage 
sum=''*pop
/box='Summary Report' misstext='none' row=float;
run;

proc corr data=rs2;
var rent_gt_30 rent_gt_50;
with Income_quantile;
run;
proc sgplot;
scatter x=Income_quantile y=rent_gt_30;
run;
proc sgplot;
scatter x=Income_quantile y=rent_gt_50;
run;

proc corr data=rs2;
var hc_mortgage_mean home_equity_second_mortgage;
proc sgplot;
scatter x= hc_mortgage_mean y=home_equity_second_mortgage;
run;
