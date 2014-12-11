%INPUT PARAMETERS
% month, day, year, price represent all the time series data
% succes_symbols represents the assets that succesfully
% FOR NOW ASSUME ROW 3000 IS THE SAME DATE FOR EVERY ASSET
function [prices price_names marketprice num_assets catch_assets] = ...
	 fetch_stock_data(beg_ind,end_ind,month,day,year,data,success_symbols)

	count=1;
	%beg_ind=beg_ind-1;
	%end_ind=end_ind-1;
	catch_assets=1;
	%The last element

	for i = 1:(length(success_symbols)-1)
		%symb_matrix{i}=SP500_symb_csv{i};
		try
			disp('entered try block')
			prices{count}=data{i}(beg_ind:end_ind);
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
		marketprice=data{end}(beg_ind:end_ind);
		marketname=success_symbols(end);
	catch
	end
end