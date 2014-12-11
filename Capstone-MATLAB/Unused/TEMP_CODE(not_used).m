%*******************************************************************
%GUIDE TO TEMP CODE
%1 - Retrive needed stock information using csvread
%2 - Code for determining regime for each time period
%3 - Full program outline
%4 -
%5 -
%6 -
%7 -
%8 -
%9 -
%10 -
%11 -
%12 -
%13 -
%*******************************************************************
%1 - Retrieve needed stock information using csvread
%{
%count index is used to ensure there are no empty matrix elements
count=1;
%This function call retrieves the needed Stock Information

for i = 1:length(SP500_symb_csv)-1
	%symb_matrix{i}=SP500_symb_csv{i};
	try
		prices{count}=csvread(char(SP500_symb_csv(i)),0,1,[0 1 40 1]);
		price_names{count}=SP500_symb(count);	
		count=count+1;	
	catch 
		disp(SP500_symb_csv(i))
		disp(',');
		%disp('catch block reached');
	end
end
num_assets=count-1; % add 1 for the market index
marketprice=csvread(char(SP500_symb_csv(length(SP500_symb_csv))),0,1,[0 1 40 1]);
marketname=SP500_symb(length(SP500_symb_csv));
%}
%Now add the market index as the last element of the prices array

%---------------------------------------------------------------------------

%Previous code for determining the regime for each time period

% r1_prob=Spec_Out.filtProb(:,1);
% r2_prob=Spec_Out.filtProb(:,2);

% countregime_1=0;
% countregime_2=0;

% initial_timelength=length(inf_data); %this line is outside the big For loop to be added
% timelength=initial_timelength;
% for i=1:timelength
% 	r_prob(i)
% 	if (r1_prob(i)>r2_prob(i))
% 		whichregime(i)=1;
% 		countregime_1=countregime_1+1;
% 	else
% 		whichregime(i)=2;
% 		countregime_2=countregime_2+1;
% 	end
% end
		

% %Parameter 1 is the number of monthly time periods, 2 is the current inflation rate
% curr_regime=whichregime(timelength);
% curr_inf_rate=inf_data(timelength);

%----------------------------------------------------------------------------
%{ 
*******************PROGRAM OUTLINE*********************
STEPS

1. RETRIEVE THE HISTORICAL INFLATION RATES
2. SOLVE FOR THE MLE PARAMETERS FOR THE REGIME-SWITCHING EQUATION
   AND MAINTAIN RECORD OF THE CURRENT REGIME
3. RECURSE BACKWARDS TO DETERMINE THE EXPECTED INFLATION RATE BY USING THE 
   TRANSTIION PROBABILITIES(FROM STEP 2) TO FIND A PROBABILITY WEIGHTED
   AVERAGE OF THE INFLATION RATES FROM THE TWO REGIMES
4. RETRIEVE THE STOCK & MARKET PRICES FOR THE DESIRED TIME PERIODS
5. SOLVE FOR THE DEFAULT CAPM EQUATION TO GET NOMINAL RETURNS OF EACH ASSET
   (NOTE THAT THIS INCLUDES THE EXPECTED RETURN MATRIX, COVARIANCE MATRIX AND 
    THE BETA OF EACH ASSET WITH RESPECT TO THE S&P 500 INDEX)

6. SOLVE FOR THE INFLATION BETAS OF EACH ASSET
7. ADD THE CAPM EXPECTED RETURNS TO THE PRODUCT OF THE INFLATION BETA AND THE 
   EXPECTED INFLATION RATE IN ORDER TO GET INLFATION-ADJUSTED EXPECTED RETURNS


9. GIVEN 
    -THE EXPECTED RETURN MATRIX FOR EACH ASSET, 
    -THE CURRENT ASSET ALLOCATION (STORED SOMEWHERE AFTER THE FIRST PERIOD),
    -THE COVARIANCE MATRIX OF EACH ASSET WRT TO EACH OTHER
    -THE VARIANCE OF THE INFLATION RATE IN EACH REGIME
    -THE CURRENT REGIME WE'RE IN 
    -THE TRANSACTION COST (TURNOVER CONSTRAINT)
    -THE MINIMUM DESIRED RETURN(FOR THE LHS OF THE RETURN CONSTRAINT)

    FORM THE MVO AND SOLVE USING QUADPROG. THE RESULT SHOULD BE THE DESIRED ASSET
    ALLOCATION FOR THE PERIOD
10. AT THE END OF THE LOOP, PLOT THE PORTFOLIO'S PERFORMANCE OVER TIME AND COMPARE IT TO
   HOW THE STANDARD S&P500 INDEX DID (PLOT BOTH ON SAME GRAPH)
%}



%Markov Switching Model for Inflation using AR(1) model with 2 regimes and an intercept.
%The regimes solved for are

%---------------------------------------------------------------------------
% CODE FOR FETCHING PRICE DATA USING THE CSVREAD FUNCTION

%{
      %This loop returns the price matrix which stores
    % the prices of the 477 or so assets and the associated
    % time series data for the inputted time periods
    %{
    for i = 1:length(SP500_symb_csv)-1
      %symb_matrix{i}=SP500_symb_csv{i};
      try
      prices{count}=csvread(...
          char(SP500_symb_csv(i)),beg_ind,1,[beg_ind 1 end_ind 1]);
      price_names{count}=SP500_symb(count); 
      count=count+1;  
      %disp(SP500_symb_csv(i))
      %----------------------
      
    catch 
      catch_assets=catch_assets+1;
    end
  end
%}
%---------------------------------------------------------------------------
% GENERAL CODE FOR OPENING FILES AND READING USING TEXTREAD

%{
fid = fopen('RDC.csv');  
rdc = fread(fid, '*char')'; 
fclose(fid);
entries = regexp(rdc, ',', 'split');

[RDC1 RDC2]= textread('RDC.csv', '%s %s', 'delimiter', ',')

[RDC1 RDC2 RDC3 RDC4]= textread('RDC.csv', '%s %d %d %f', 'delimiter', ',: ')

%}

%-------------------------------------------------------------------------
%CODE INITIALIZATION FOR THE PRICE DATA MATRIX
%{
  month={};
  day={};
  year={};
  price={};
  %}

  %fail_symbols={};
  %success_symbols={};

  %stands for failcount and successcount

%-------------------------------------------------------------------------
%MORE CODE FOR FETCHING PRICE DATA USING CSVREAD
%{
  for i = 1:length(success_symbols)-1
    %symb_matrix{i}=SP500_symb_csv{i};
    try
      prices(count)=data{count}(beg_ind:end_ind)
      price_names{count}=success_symbols(i);  
      count=count+1;  
      %disp(SP500_symb_csv(i))
    catch 
      catch_assets=catch_assets+1;
    end
  end
  num_assets=count-1; % add 1 for the market index
  
  %retrieve time series price information for the marketprice
  try
    marketprice=data{length(success_symbols)}(beg_ind:end_ind)
    marketname=success_symbols(end);
  catch
  end
%}
%-------------------------------------------------------------------------
%FULL PROGRAM STEPS
%{
  

%----------------------------------------------------------------------------------------
% STEP 1: RETRIEVING HISTORICAL INFLATION RATES & ALL STOCK DATA AVAILABLE
% NOTE: THIS CAN BE PREPROCESSED
%Choose the inflation_interval used to generate the regimes
%get_initial_inf_data by choosing the start year, end year, start month and end month

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


[MLEinf_data, inf_avg] =fetch_inflation_data(1920,2013,begcol,endcol,inf_file);
size(MLEinf_data)
run 'thirdSymbols.m';
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

%{
%Calling fetch_stock_data fetches the stock prices for the desired time period

  [currprices currpricenames marketprice num_assets catch_assets] = ...
        fetch_stock_data(1,20,month,day,year,price,success_symbols)
%} 

%fetching the data by inputting the start month/year and end month/year




[currprices2 currpricenames2 marketprice2 num_assets2 catch_assets2] = ...
  SEC_fetch_stock_data('Sep',2014,'Dec',2013,month,day,year,price,success_symbols);

%One month less of inflation data used
[currinfprices] = fetch_inflation_data2('SEP',2014,'DEC',2013,infmonth,infyear,infprice);



asset_prices=cell2mat(currprices2);
asset_prices_with_market=[marketprice2 asset_prices];
asset_prices_with_inf=[currinfprices asset_prices];
market_price_with_inf=[currinfprices marketprice2];
%Ensure that same time periods for asset and market prices and that inflation
% has one less time period
if ((size(asset_prices,1)==size(marketprice2,1)) && (size(asset_prices,1)==size(currinfprices,1)))
  disp('WORKS - data points of asset prices, market price and infprices have same no. of points')
else
  disp('SIZE MISMATCH');
  disp('Size of asset price');
  disp(size(asset_prices,1));
  disp('Size of market price');
  disp(size(marketprice2,1));
  disp('Size of inflation price');
  disp(size(currinfprices,1));
end
%----------------------------------------------------------------------------------------
% STEP 5: SOLVE FOR THE MVO PARAMETERS, THE MUS, Q'S AND R'S FOR ALL ASSETS AND 
% THE MARKET OVER THE SPECIFIED TIME PERIODS. ALSO SOLVE FOR THE CAPM BETAS OR 
% EACH ASSET

market_price=marketprice2;

[asset_mu,asset_Q,asset_r]= solve_mvo_params(asset_prices,1,size(asset_prices,1));

%Solve for only the market
[Market_mu,Market_Q,Market_r]= solve_mvo_params(market_price,1,size(marketprice2,1));



[CAPM_Beta R2_CAPM] = solve_beta3(asset_prices_with_market,2);
[Inf_Beta R2_inf]   =solve_beta3(asset_prices_with_inf,1);

%----------------------------------------------------------------------------------------

% STEP 6: SOLVE FOR THE INFLATION BETAS OF EACH ASSET
% Note: initially solving for only ONE inflation beta for each asset
% this will likely change to represent an inflation beta per asset per regime

%First find the inflation rates just previous to the period to be optimized
%[curr_inf_data, inf_avg] = fetch_inflation_data(1969,1970,1,12,'inflation_data_monthly.csv');

% Now solve for the geometric returns, mean returns and covariance of hte 
% inflation rate
%[inf_mu, inf_Q,inf_r] =solve_mvo_params(currinfprices,1,size(currinfprices,1));

%Now find the corresponding inflation Betas by using the asset prices and 
% inflation rates 
% inf_data_for_beta=fetch_inflation_d

%NOTE HAVE TO SOMEHOW RECOONCILE THE FACT THAT INFLATION RATE DATA IS MONTHLY
% WHILE ASSET PRICE DATA IS DAILY (& ALSO FAIRLY SPORADIC AT THAT AS THERE
% ARE WEEKNDS, HOLIDAYS, ETC. THAT MUST BE STANDARDIZED
% [inf_Beta] = solve_beta(num_assets2,asset_r,inf_r,asset_mu,inf_mu,n_end-n_beg);
%[inf_Beta] = solve_beta(num_assets2,asset_r,currinfprices,asset_mu,expected_inf,n_end-n_beg);

%[inf_del_M inf_Beta] = solve_beta2(asset_prices_with_inf,2);
%-----------------------------------------------------------------------------------
% STEP 7. ADD THE CAPM EXPECTED RETURNS TO THE PRODUCT OF THE INFLATION BETA AND THE 
%          EXPECTED INFLATION RATE IN ORDER TO GET INLFATION-ADJUSTED EXPECTED RETURNS


%-----------------------------------------------------------------------------------
% STEP 8. HAVE A SIMPLISTIC MODEL THAT DETERMINES WHETHER IT IS BENEFICIAL TO REOPTIMIZE OR NOT
%    (PROBABLY BY JUST COMPARING THE EXPECTED INFLATION RATES AND SEEING IF THERE 
%     IS A MINIMUM PERCENT DIFFERENCE, IN ADDITION TO PERHAPS USING THE MARKET INDEX
%     TO SEE IF THE BULL/BEAR MARKET DIFFERENCE HAS DRAMATICALLY CHANGED OR NOT

%   IF REOPTIMIZATION IS DECIDED UPON, GO TO STEP 9, OTHERWISE REDO THE LOOP



%-----------------------------------------------------------------------------------
% STEP 9. GIVEN 
%     -THE EXPECTED RETURN MATRIX FOR EACH ASSET, 
%     -THE CURRENT ASSET ALLOCATION (STORED SOMEWHERE AFTER THE FIRST PERIOD),
%     -THE COVARIANCE MATRIX OF EACH ASSET WRT TO EACH OTHER
%     -THE VARIANCE OF THE INFLATION RATE IN EACH REGIME
%     -THE CURRENT REGIME WE'RE IN 
%     -THE TRANSACTION COST (TURNOVER CONSTRAINT)
%     -THE MINIMUM DESIRED RETURN(FOR THE LHS OF THE RETURN CONSTRAINT)

%     FORM THE MVO AND SOLVE USING QUADPROG. THE RESULT SHOULD BE THE DESIRED ASSET
%     ALLOCATION FOR THE PERIOD
currinfprices=currinfprices(1:end-1);
xalloc=zeros(num_assets2,1);

[MVO_x MVO_var temp_Q adj_ret nom_ret] = main_MVO(currinfprices,asset_r,expected_inf/100,expected_inf_var,...
              inf_Beta',0.02,0.0005,0.05,xalloc);

%-----------------------------------------------------------------------------------
% STEP 10. AT THE END OF THE LOOP, PLOT THE PORTFOLIO'S PERFORMANCE OVER TIME AND COMPARE IT TO
%    HOW THE STANDARD S&P500 INDEX DID (PLOT BOTH ON SAME GRAPH)


%-----------------------------------------------------------------------------------




rmpath('m_Files');
rmpath('data_Files');    




%}
%-------------------------------------------------------------------------
%
%{
  




%}%-------------------------------------------------------------------------
%
%{
  




%}%-------------------------------------------------------------------------
%
%{
  




%}%-------------------------------------------------------------------------
%
%{
  




%}%-------------------------------------------------------------------------
%
%{
  




%}%-------------------------------------------------------------------------
%
%{
  




%}
