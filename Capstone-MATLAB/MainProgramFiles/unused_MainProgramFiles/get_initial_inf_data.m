

% Note that inflation data matrix contains

%Note that there are 4 distinct integers
%Start Year(is 2014), Start month(which is usually 1), 
%End year(99 is 2013) & end month(which is usually 12)

%User choose the start and end year here
insert_start_year=1950;
insert_end_year=1970;


s_year=insert_start_year-1914;
e_year=insert_end_year-1914;
s_month=1;
e_month=12;

inf_data=csvread('inflation_excel_stuff.csv',...
					s_year,s_month,[s_year,s_month,e_year,e_month]);

inf_data=inf_data';
inf_data=inf_data(:); %Size of matrix is (no. of years * no. of months) x 1

%size of matrix is (no. of years) x 1
inf_data_avg=csvread('inflation_excel_stuff.csv',s_year,13,[s_year,13,e_year,13]);

timelength=length(inf_data);
