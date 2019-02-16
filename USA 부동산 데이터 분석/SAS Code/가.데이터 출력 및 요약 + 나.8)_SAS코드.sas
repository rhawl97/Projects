%let location=C:\Users\user\Desktop\����ڷ�ó���׽ǽ�;
libname class "&location";
proc import datafile="&location.\real_estate_db.csv" dbms=csv
out=class.rs replace;
run;

data rs2;
set class.rs;
run;
proc sort data=rs2;
by state; /*���� ���� ���� �� First.state ������ ����� ���Ͽ� Proc sort statement�� �̿��Ͽ� ����*/
run;
data rs2;
set rs2;
by state;
retain cumpop; /*Retain statement�� ����Ͽ� �������� ���Ѵ�.*/
if first.state=1 then cumpop=0;
cumpop=cumpop+pop;
run;
data state_pop;
set rs2;
by state;
if last.state=1 then output; /*�׷캰 ������ ����ġ�� �ֺ� �α� ������ ���Ǿ� �ִٴ� ���� �̿��Ѵ�.*/
run;
proc print data=rs2;
where rent_median>3000; /*�����ͼ��� �ùٸ��� �����Ǿ����� Ȯ���ϱ� ���Ͽ� ���ǻ� ������ �־�*/
var state city place pop rent_mean rent_median rent_stdev pct_own cumpop; /*�����ͼ��� ����Ѵ�.*/
format rent_mean rent_median rent_stdev 5.3 pct_own percent5.3;
run;
proc means data=state_pop;
var cumpop; /*state_pop�� ���ؼ��� Ȯ���Ѵ�.*/
run;

proc format;
value iit 0-10000="1 quantile" /*�ҵ� ������ ���� Format�� iit�� �����Ѵ�.*/
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
family_m=family_mean; /*family_mean�� ��ġ�� ���� ����ϱ� ���Ͽ� �� ���� �����Ͽ� family_m Į���� �����Ѵ�.*/
format family_mean iit.; /*family_mean�� iit Format�� �����Ѵ�.*/
hc_mortgage_mean=hc_mortgage_mean*1; /*hc_mortgage_mean�� ������ ������ ����������Ƿ� �̸� ��ġ�� ������ ��ȯ�Ѵ�.*/
rename family_mean=Income_quantile;
proc freq data=rs2;
table Income_quantile; /*�ҵ� ������ ���ؼ� �󵵺м�*/
run;
proc sgplot data=rs2;
hbar Income_quantile; /*�׷����� �׷� �м�*/
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
