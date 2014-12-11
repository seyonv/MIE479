

%----------------------------------------------------------------------------------------
% STEP 1: RETRIEVING HISTORICAL INFLATION RATES & ALL STOCK DATA AVAILABLE
% NOTE: THIS CAN BE PREPROCESSED

inflation_interval='monthly';
begcol=1;
if (strcmp(inflation_interval,'monthly'))
	inf_file='inflation_data_monthly.csv';
	endcol=12;
elseif (strcmp(inflation_interval,'quarterly'))
	inf_file='inflation_data_quarterly.csv'
	endcol=4;
elseif (strcmp(inflation_interval,'annual'))
	inf_file='inflation_data_annual.csv'
	endcol=1;

end


[MLEinf_data, inf_avg] =fetch_inflation_data(1920,1974,begcol,endcol,inf_file);
size(MLEinf_data)
run 'Symbols.m';
[month day year price fail_symbols success_symbols]=...
						all_stock_data(SP500_symb_csv,SP500_symb);

[infmonth infyear infprice ] = all_inflation_data('inflation_rate_1200.csv');
%----------------------------------------------------------------------------------------
% STEP 2: SOLVE FOR THE MLE PARAMETERS OF THE REGIME-SWITCHING MODEL
% AS WELL AS MATRIX OF ASSOCIATED REGIME FOR EACH TIME PERIOD

k=2 %DECLARE THE NUMBER OF REGIMES

[Spec_Out p11 p22 p12 p21 var1 var2 var3 ar1 ar2 ar3 c1 c2 c3]= ...
                                  RegimeSwitching_MLE(k,MLEinf_data);

timelength=length(MLEinf_data);

[whichregime, countregime] =regimecount(k,Spec_Out.smoothProb,timelength);

%Parameter 1 is the number of monthly time periods, 2 is the current inflation rate
curr_regime=whichregime(timelength);
curr_inf_rate=MLEinf_data(timelength);

%----------------------------------------------------------------------------------------
% STEP 3: CONSTRUCT MARKOV TREE FOR INFLATION TREE & FIND
%         THE EXPECTED INFLATION RATE
markov_periods=4; %this is chosen number of periods for markov tree(in months)

[expected_inf, tnodes]=exp_inf2(markov_periods,curr_inf_rate,curr_regime...
					 ,c1,c2,ar1,ar2,p11,p12,p21,p22);

[expected_inf_var] = ...
	exp_infvar2(markov_periods,curr_regime,c1,c2,var1,var2,p11,p12,p21,p22);

%[expected_inf_var] = exp_infvar2(2,1,3,2,0.5,1,0.95,0.05,0.03,0.97);

%----------------------------------------------------------------------------------------
% STEP 4 : RETRIEVE THE ASSET AND MARKET PRICES FOR THE DESIRED TIME PERIODS
[tcurrprices currpricenames2 market_prices num_assets2 catch_assets2 totalmonths] = ...
	SEC_fetch_stock_data('Sep',2010,'Dec',1990,month,day,year,price,success_symbols);
[inf_prices] = fetch_inflation_data2('SEP',2010,'DEC',1990,infmonth,infyear,infprice);

[beg_indices end_indices]=divide_interval(2,totalmonths);

asset_prices=cell2mat(tcurrprices);

%Parameters are first number of time divisions, then total months

currassetprices=asset_prices(beg_indices(1):end_indices(1),:);
currmarketprices=market_prices(beg_indices(1):end_indices(1));
currinfprices=inf_prices(beg_indices(1):end_indices(1));




% asset_prices=cell2mat(currprices2);
asset_prices_with_market=[currmarketprices currassetprices];
asset_prices_with_inf=[currinfprices currassetprices];

%----------------------------------------------------------------------------------------
% STEP 5: SOLVE FOR THE MVO PARAMETERS, THE MUS, Q'S AND R'S FOR ALL ASSETS AND 
% THE MARKET OVER THE SPECIFIED TIME PERIODS. ALSO SOLVE FOR THE CAPM BETAS OR 
% EACH ASSET

[asset_mu,asset_Q,asset_r]= solve_mvo_params(currassetprices,1,size(currassetprices,1));

%Solve for only the market
[Market_mu,Market_Q,Market_r]= solve_mvo_params(currmarketprices,1,size(currmarketprices,1));



[CAPM_Beta R2_CAPM] = solve_beta3(asset_prices_with_market,2);
[Inf_Beta R2_inf]   =solve_beta3(asset_prices_with_inf,1);

%----------------------------------------------------------------------------------------

currinfprices2=currinfprices(1:end-1);
xalloc=zeros(num_assets2,1);

[modelMVO_x modelMVO_var MVO_adjret_diagQ nom_ret] = main_MVO(currinfprices2,asset_r,expected_inf/100,expected_inf_var,...
							Inf_Beta',0.002,0.0001,xalloc);

% [modelMVO_x modelMVO_var temp_Q adj_ret nom_ret] = main_MVO(currinfprices,asset_r,1.8/100,0.04,...
% 							Inf_Beta',0.000002,0.0005,0.05,xalloc);

%-----------------------------------------------------------------------------------
% STEP 10. AT THE END OF THE LOOP, PLOT THE PORTFOLIO'S PERFORMANCE OVER TIME AND COMPARE IT TO
%    HOW THE STANDARD S&P500 INDEX DID (PLOT BOTH ON SAME GRAPH)

[benchMVO_x benchMVO] = benchmark_MVO(asset_mu', asset_Q, 0.005, 0.0001, xalloc);
%-----------------------------------------------------------------------------------



currassetprices=asset_prices(beg_indices(2):end_indices(2),:);
currmarketprices=market_prices(beg_indices(2):end_indices(2));
currinfprices=inf_prices(beg_indices(2):end_indices(2));





%----------------------------------------------------------------------------------------
% STEP 5: SOLVE FOR THE MVO PARAMETERS, THE MUS, Q'S AND R'S FOR ALL ASSETS AND 
% THE MARKET OVER THE SPECIFIED TIME PERIODS. ALSO SOLVE FOR THE CAPM BETAS OR 
% EACH ASSET

[asset_mu,asset_Q,asset_r]= solve_mvo_params(currassetprices,1,size(currassetprices,1));
[Market_mu,Market_Q,Market_r]= solve_mvo_params(currmarketprices,1,size(currmarketprices,1));
%Solve for only the market

MVO_comparison(benchMVO_x', modelMVO_x', asset_r,Market_r,currinfprices(1:end-1)/100 ...
	,1975,1980);

%----------------------------------------------------------------------------------------
% STEP 6: REBALANCING PORTFOLIOS FOR OPTIMIZED PERFORMANCE

% Let T_reb be the number of periods before rebalancing
% then for the first iteration of MVO comparison, only feed in information
% asset_r and market_r for the relevant time

% e.g. T_reb = T/4 = 1 year i.e. T_reb = 12 (months)
% MVO_comparison(benchMVO_x', modelMVO_x', asset_r(1:T_reb,:), ...
%   Market_r(1:T_reb,:),currinfprices(1:end-1)/100 ,1975,1980);





rmpath('m_Files');
rmpath('data_Files');    