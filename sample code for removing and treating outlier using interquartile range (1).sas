data Employees;
    input id salaries;
    datalines;
    1   150
    2   155
    3   160
    4   165
    5   170
    6   180
    7   185
    8   190
    9   195
    10  3000        /* Outlier */
    11  200
    12  202
    13  201
    14  203
    15  204
    16  206
    17  5000        /* Outlier */
    18  207
    19  208
    20  209
    21 -10000
    22 191919
    23 126162
    ;
run;



%macro abc(dt1,var1);
data  aa;
set &dt1.;
run;

proc univariate data=aa ;
var &var1.;
output out=stats pctlpts=25 75 pctlpre=Q;
run;

data stats;
set stats;
IQR=Q75-Q25;
LOWER=Q25-1.5*IQR;
UPPER=Q75+1.5*IQR;
RUN;

data one;
if _n_=1 then set stats;
set aa;
if &var1. >= lower and &var1. <= upper then new_value=&var1.;
else new_value= .;
run;

proc means data=one;
var new_value;
output out=value mean=mean_value;
run;

data final;
if _n_=1 then set value;
set one;
without_outlier=coalesce(new_value,mean_value);
drop new_value _type_ _freq_ mean_value q25 q75 iqr lower upper ;
run;

proc means data=final;
var &var1. without_outlier ;
run;

proc print data=final;
title "outlier removed";
run;
%mend;

%abc(dt1=Employees,var1=salaries);