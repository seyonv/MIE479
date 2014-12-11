
%% SECTION I - Retrieving data and assigning parameters
tic
load('assets_SP500');
%Add the relevant paths

%n_assets=length(assets);


%market_name = '^GSPTSE'; %S&P/TSX Capped Composite
%etf_name = 'XIC.TO'; %tracks the S&P/TSX Capped Composite Index

start_date = '12-August-1990';
end_date = '12-April-1994';


%retrieve data function takes in array of stock symbols, an index and a timeline and 
%returns asset data, market data and a vairable called min days (defined above)

%This function takes in as parameters: the names of the assets/market/etf, and the start shand end date
%It returns: daily returns, numbers of the assets with market caps, the market caps
%            of those respective assets, returns of the etf and min_days
[asset_data min_days] = retrieve_SP500_data(assets_SP500, start_date,end_date);

toc