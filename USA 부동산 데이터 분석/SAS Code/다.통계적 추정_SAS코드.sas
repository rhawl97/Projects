PROC IMPORT OUT= WORK.mortgage 
            DATAFILE= "C:\Users\yunj\OneDrive\바탕 화면\real_estate_db.
csv" 
            DBMS=CSV REPLACE;
     GETNAMES=YES;
     DATAROW=2; 
RUN;

proc sql;
create table Sasuser.state as select state, pop, hs_degree, rent_mean, family_mean, hc_mortgage_mean, debt
from Sasuser.mortgage;
quit;

data Sasuser.state;
set Sasuser.state;
hc_mortgage_mean=hc_mortgage_mean*1;
run;

*모평균 추론;

proc means data=sasuser.state missing;
var hs_degree rent_mean family_mean debt; 
title "summary statistics of the main variables";
run;

proc univariate data=sasuser.state cibasic alpha=0.05;
var hs_degree rent_mean family_mean debt ;
run;

*통계량별 단일표본 t검정;

%macro ttest (var=,null=);

proc ttest data=sasuser.state h0=&null;
var &var;
title "ttest for &var. and H0=&null";
run;

proc univariate data=sasuser.state mu0=&null cibasic alpha=0.05;
var &var;
run;
%mend ttest;

%ttest (var=hs_degree, null=0.9);
%ttest (var=hs_degree, null=0.85);
%ttest (var=rent_mean, null=1000);
%ttest (var=family_mean, null=79000);
%ttest (var=debt, null=0.6);
%ttest (var=debt, null=0.63);
%ttest (var=debt, null=0.629);


*State별 독립표본 t 검정;

%macro ttest_by_states (state1=, state2=, var=);

data Sasuser.compare;
set Sasuser.state;
if state=&state1 or state=&state2;
run;

proc ttest data=Sasuser.compare cochran;
class state;
var &var;
title "Independet Sample T-Test";
run;

%mend ttest_by_states;

%ttest_by_states(state1="Hawaii",state2="Distri",var=rent_mean)
%ttest_by_states(state1="Califo",state2="Maryla",var=rent_mean)
%ttest_by_states(state1="Distri",state2="Connec",var=family_mean)
%ttest_by_states(state1="Maryla",state2="New Je",var=family_mean)

*기준변수의 비율에 따른 반응변수의 평균 차이 검정;

%macro ttest_by_ratio (criteria=, ratio=, var=);

data sasuser.compareratio;
set sasuser.Mortgage;
if &criteria > &ratio then compare="over";
else compare="under";
run;

proc ttest data=Sasuser.compareratio cochran;
class compare;
var &var;
title1 "Independet Sample T-Test by Ratio";
title2 "T-Test of &var. by &criteria., ratio=&ratio";
run;

%mend ttest_by_ratio;

%ttest_by_ratio(criteria=hs_degree,ratio=0.85,var=family_mean)
%ttest_by_ratio(criteria=hs_degree,ratio=0.85,var=debt)
%ttest_by_ratio(criteria=hs_degree,ratio=0.85,var=rent_mean)
%ttest_by_ratio(criteria=divorced,ratio=0.1,var=family_mean)
%ttest_by_ratio(criteria=divorced,ratio=0.1,var=debt)
%ttest_by_ratio(criteria=divorced,ratio=0.1,var=rent_mean)
