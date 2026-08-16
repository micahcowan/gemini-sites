/*1:*/
#line 5 "hwtime.w"

/*3:*/
#line 31 "hwtime.w"

#include <stdio.h> 

/*:3*//*7:*/
#line 81 "hwtime.w"

#include <time.h> 

/*:7*/
#line 6 "hwtime.w"

/*9:*/
#line 111 "hwtime.w"

char*day_name[]= {"Sunday","Monday","Tuesday",
"Wednesday","Thursday","Friday","Saturday"};
char*month_name[]= {"January","February","March",
"April","May","June","July","August","September",
"October","November","December"};

/*:9*/
#line 7 "hwtime.w"

/*8:*/
#line 98 "hwtime.w"

print_date(clk)
time_t clk;
{
struct tm*t;
t= localtime(&clk);
printf("%s, %s %d, %d",
day_name[t->tm_wday],
month_name[t->tm_mon],
t->tm_mday,
t->tm_year+1900);
}

/*:8*//*10:*/
#line 126 "hwtime.w"

print_time(clk)
time_t clk;
{
struct tm*t;
t= localtime(&clk);
/*11:*/
#line 142 "hwtime.w"

printf("%d:%02d",
((t->tm_hour+11)%12)+1,
t->tm_min);

/*:11*/
#line 132 "hwtime.w"
;
/*12:*/
#line 151 "hwtime.w"

if(t->tm_min==0&&(t->tm_hour%12)==0)
printf("%s",t->tm_hour==0?"midnight":"noon");
else printf("%s",t->tm_hour<12?"am":"pm");

/*:12*/
#line 133 "hwtime.w"
;
printf(", %s",t->tm_zone);
}

/*:10*/
#line 8 "hwtime.w"

main()
{
/*5:*/
#line 61 "hwtime.w"

time_t current_time;

/*:5*/
#line 11 "hwtime.w"
;
/*2:*/
#line 22 "hwtime.w"

printf("Greetings ... to\n");
printf(" `the stage, ");
printf("where every man must play a part'.\n");

/*:2*/
#line 12 "hwtime.w"
;
/*4:*/
#line 38 "hwtime.w"

current_time= time(0);
printf("Today is ");
print_date(current_time);
printf(",\n and the time is ");
print_time(current_time);
printf(".\n");

/*:4*/
#line 13 "hwtime.w"
;
/*6:*/
#line 67 "hwtime.w"

printf("Ten million minutes ago it was\n ");
print_date(current_time-600000000);
printf(", at ");
print_time(current_time-600000000);
printf(".\n");

/*:6*/
#line 15 "hwtime.w"
;
}

/*:1*/
