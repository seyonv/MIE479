%clear t_price,t_pricenames,t_marketprice,t_nassets;
[t_price t_pricenames t_marketprice t_nassets] = ...
	fetch_stock_data(1,8000,SP500_symb,SP500_symb_csv);