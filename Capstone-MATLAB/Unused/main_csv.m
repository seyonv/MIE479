%Read in values for CSV files of each S&P500 Asset
run 'Symbols.m';
clear M;
clear prices;
clear price_names;

%this For Loop calls csvread on every element of the SP500_symb_csv array
%which is of the form "X.csv" where X is the ticker symbol for the stock
%it saves the respective prices in another cell array

%Calling fetch_stock_data fetches the stock prices for the desired time period
[prices price_names marketprice num_assets] = ...
						fetch_stock_data(0,200,SP500_symb,SP500_symb_csv);

%go from asset 1 to asset 5
prices=cell2mat(prices);
n_beg=1;
n_end=10;
[mu,Q,r_it]= solve_mvo_params(prices,num_assets,n_beg,n_end);

%Solve for only the market
[Mmu,MQ,r_M]= solve_mvo_params(marketprice,1,n_beg,n_end);
%NOw use the MVO params solved for in order to solve for the betas
[Beta] = solve_beta_1(num_assets,r_it,r_M,mu,Mmu,n_end-n_beg);

