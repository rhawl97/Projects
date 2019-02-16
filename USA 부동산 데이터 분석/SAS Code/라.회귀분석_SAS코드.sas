libname hw "C:\Users\uos\Desktop\SAS ����";
proc import datafile="C:\Users\uos\Desktop\SAS ����\real_estate_db.csv" out=hw.estate dbms=CSV replace;
run;
/*�ʿ���� �� �����*/
data hw.estate1;
set hw.estate;
drop blockID hi_mean	hi_median	hi_stdev	hi_sample_weight	 hs_degree_male	hs_degree_female male_age_median	male_age_stdev	male_age_sample_weight	male_age_samples
female_age_median 	female_age_stdev	female_age_sample_weight	female_age_samples;
run;

data hw.reg1;
set hw.estate1;
if state_ab IN("NY","OH");
dummy_state=0; if state_ab="NY" then dummy_state=1; *������(dummy_state) �����;
hc_mortgage_mean1=input(hc_mortgage_mean,4.); *������ ������ ��ȯ,�Ҽ��� �ڸ�����;
run;
/*box plot �׸���*/
proc sort data= hw.reg1;
by dummy_state;
run;
proc univariate data=hw.reg1 plot;
by dummy_state;
var rent_mean;
run;

/*ȸ�ͺм� �ϱ�*/
proc reg data=hw.reg1;
model rent_mean=hc_mortgage_mean1 dummy_state;
title "��� �Ӵ��� �� ��� ���ڱ�, �ֺ����� ����";
run;

/*2��° ȸ�ͺм�*/
proc reg data=hw.estate1;
model rent_mean= family_mean;
title "�Ӵ�����(��������)�� �����ҵ�(������)���� �ܼ�ȸ�ͺм�";
run;

/*��Ÿ ȸ�ͺм�*/
proc reg data=hw.estate1;
model rent_mean=divorced;
title "�Ӵ�����(��������)�� ��ȥ��(������)���� �ܼ�ȸ�ͺм�";
run;
proc reg data=hw.estate1;
model rent_mean=hs_degree;
title "�Ӵ�����(��������)�� ������(������)���� �ܼ�ȸ�ͺм�";
run;
proc reg data=hw.estate1;
model rent_mean=debt;
title"�Ӵ�����(��������)�� ä��(������)���� �ܼ�ȸ�ͺм�";
run;

