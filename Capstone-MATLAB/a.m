% INFLATION_INTERVAL is 'monthly','quarterly' or 'annually'
% and is used to computer the regime history

% ------------------------------------------------------------------------------
% SYMBOLFILE specifies which file to fetch symbols from. A list of the files
% available are given below

% -Symbols_SP.m has the full S&P500 Stocks. It is important to note that only some
% of these have aviable price history that dates back to 1974.
% -SecondSymbols has a small subset and is used for testing
% -ThirdSYmbols is an even smaller subset, having only 3 stocks.
% -Symbols_NYSE has a full list of all NYSE stocks. However at this time,
%  only a subset of these 3300+ stocks have local csv files avaiable for fetching
% -Symbols_NYSE2 has a list of the NYSE stocks that have local csv files
% -Symbols_NYSE_SP has a list of NYSE stocks AND S&P500 stocks. ALl of these
% are avaiable for fetching. It is the recommended file to use because it has 
% the most data avaiable which is important for early years where most stocks
% dont have time series data
% ------------------------------------------------------------------------------
% SYEAR/EYEAR is the start/end year of optimization for the regeims
% ------------------------------------------------------------------------------
% NUM_OF_TIME_PERIODS is the number of divisions in the time interval
% note that the in sample period to get data is 
% (syear-eyear)/num_of_time_periods.

% **ensure that syear-eyear is divisble by num_of_time_periods
% ------------------------------------------------------------------------------
% NUM_OF_REOP is the number of times the portfolio is reoptimized.
% note that this is a specified amount and there is no submodel to determine
% whether or not to reoptimize because the transcation cost constraint
% prevents drastic changes in asset allocation
% ------------------------------------------------------------------------------
% DESIRED_R IS THE minimum monthly return constraint. Converting this 
% to an annual return is (1+desired_R)^12-1
% ------------------------------------------------------------------------------
% DESIRED_TRANSACTION is the the user-specified fixed transaction cost


inflation_interval='monthly';
SymbolFile='''Symbols_NYSE_SP.m''';
startyear=1981;
endyear=1991;
num_of_time_divisions=5;
num_of_reoptimization_periods=2;
minimum_return=0.005;
transaction_cost=0.0001;


 create_inflation_hedged_portfolio...
 	(inflation_interval,SymbolFile,startyear,endyear, num_of_time_divisions,...
	  num_of_reoptimization_periods, minimum_return, transaction_cost);

%Commment all the lines above and Uncomment the line below if you want to 
% see all the workspace variables

% run create_inflation_hedged_portfolio.m;
