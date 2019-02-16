libname hw "C:\Users\uos\Desktop\SAS 과제";
proc import datafile="C:\Users\uos\Desktop\SAS 과제\real_estate_db.csv" out=hw.estate dbms=CSV replace;
run;
/*필요없는 열 지우기*/
data hw.estate1;
set hw.estate;
drop blockID hi_mean	hi_median	hi_stdev	hi_sample_weight	 hs_degree_male	hs_degree_female male_age_median	male_age_stdev	male_age_sample_weight	male_age_samples
female_age_median 	female_age_stdev	female_age_sample_weight	female_age_samples;
run;

data hw.reg1;
set hw.estate1;
if state_ab IN("NY","OH");
dummy_state=0; if state_ab="NY" then dummy_state=1; *가변수(dummy_state) 만들기;
hc_mortgage_mean1=input(hc_mortgage_mean,4.); *숫자형 변수로 변환,소수점 자리제외;
run;
/*box plot 그리기*/
proc sort data= hw.reg1;
by dummy_state;
run;
proc univariate data=hw.reg1 plot;
by dummy_state;
var rent_mean;
run;

/*회귀분석 하기*/
proc reg data=hw.reg1;
model rent_mean=hc_mortgage_mean1 dummy_state;
title "평균 임대료와 월 평균 융자금, 주별간의 관계";
run;

/*2번째 회귀분석*/
proc reg data=hw.estate1;
model rent_mean= family_mean;
title "임대료평균(반응변수)와 가족소득(설명변수)간의 단순회귀분석";
run;

/*기타 회귀분석*/
proc reg data=hw.estate1;
model rent_mean=divorced;
title "임대료평균(반응변수)와 이혼율(설명변수)간의 단순회귀분석";
run;
proc reg data=hw.estate1;
model rent_mean=hs_degree;
title "임대료평균(반응변수)와 고등교육자(설명변수)간의 단순회귀분석";
run;
proc reg data=hw.estate1;
model rent_mean=debt;
title"임대료평균(반응변수)와 채무(설명변수)간의 단순회귀분석";
run;

