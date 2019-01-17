Given latitude and longitude determine the us state geo mapping;

    Two Solutions

         1. SAS proc ginside
         2. R maps package

github
https://tinyurl.com/yav3fh2j
https://github.com/rogerjdeangelis/utl-given-latitude-and-longitude-determine-the-us-state-mapping

SAS  Forum
https://communities.sas.com/t5/SAS-Procedures/mapping-state-byu-geo-location/m-p/527433

StackOverflow
https://tinyurl.com/ybqpt3el
https://stackoverflow.com/questions/8751497/latitude-longitude-coordinates-to-state-code-in-r/8751965#8751965

Robert Allison Profile  SAS
https://communities.sas.com/t5/user/viewprofilepage/user-id/13585

HAVB profile R
https://stackoverflow.com/users/3527951/havb

INPUT
=====

options validvarname=upcase;
libname sd1 "d:/sd1";
data sd1.have;
input y x ;
cards4;
41.0746 -123.787
44.1388 -90
44.0628 -120
;;;;
run;quit;


Up to 40 obs SD1.HAVE total obs=3

Obs       Y           X

 1     41.0746    -123.787
 2     44.1388     -90.000
 3     44.0628    -120.000


EXAMPLE OUTPUT SAS
------------------

 Obs       Y           X       STATE    STATECODE

  1     41.0746    -123.787       6        CA
  2     44.1388     -90.000      55        WI
  3     44.0628    -120.000      41        OR


EXAMPLE OUTPUT (from R)
-----------------------

WORK.OUTLST

 CAPTURE

 Simple feature collection with 3 features and 1 field
 geometry type:  POINT
 dimension:      XY
 bbox:           xmin: -123.787 ymin: 41.0746 xmax: -90 ymax: 44.1388
 epsg (SRID):    4326
 proj4string:    +proj=longlat +datum=WGS84 +no_defs
           ID                 geometry
 1 california POINT (-123.787 41.0746)
 2  wisconsin      POINT (-90 44.1388)
 3     oregon     POINT (-120 44.0628)

WORK.WANT_R total obs=3

  TEMP_ID

  california
  wisconsin
  oregon

=========
SOLUTIONS
=========

====================
 1. SAS proc ginside
=====================

 data my_map (rename=(lat=y long=x));
      set mapsgfk.us_states (drop = x y);
 run;

 proc ginside data=sd1.have map=my_map out=need;
 id state statecode;
 run;

 proc print data=need;
 var y x  state statecode;
 run;


==================================================================
 2. R maps package (most of the code is to get data in an out of R)
===================================================================

%utlfkil(d:/xpt/want.xpt);

%utl_submit_r64('
library(maps);
library(sf);
library(haven);
library(SASxport);
have<-read_sas("d:/sd1/have.sas7bdat");
US <- st_as_sf(map("state", plot = FALSE, fill = TRUE));
testPoints <- st_as_sf(have, coords = c("X", "Y"), crs = st_crs(US));
temp<-st_join(testPoints, US);
outlst<-as.data.frame(capture.output(temp));
outlst[]<-lapply(outlst, function(x) if(is.factor(x)) as.character(x) else x);
want<-as.data.frame(temp$ID);
want[]<-lapply(want, function(x) if(is.factor(x)) as.character(x) else x);
write.xport(want,outlst,file="d:/xpt/want.xpt");
');

libname xpt xport "d:/xpt/want.xpt";
proc contents data=xpt._all_;
run;quit;

data want_r;
  set xpt.want;
run;quit;

data want_rlst;
  set xpt.outlst;
run;quit;
libname xpt clear;




