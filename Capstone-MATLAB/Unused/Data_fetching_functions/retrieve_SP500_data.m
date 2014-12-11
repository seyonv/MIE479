function [asset_data min_days] = retrieve_SP500_data(assets, start_date, end_date);

	%% ACQUIRE DATA FROM YAHOO FINANCE
	% Collect relevant asset data from Yahoo Finance
	Connect = yahoo;

	min_days = intmax;


	%This for loop does two things
	%1. It retrieves Market Capitalization information for all stocks in the TSX
	%   and converts it to a number.
	%2. It keeps track of min_days of data available for any asset 
	%	This ensures that we only cover data for assets that have it available
	for i = 2:length(assets)
	  	data{i}=getStockInformation({assets{i}});
		%disp(data{i});    
	   	try 
	  		temp{i} = fetch(Connect, assets{i}, 'Close',start_date,end_date,'m');
	  		disp('Entered try block & completed fetch statement')
	  	catch (exception)
	  		disp('Entered catch block')
	  	end
	    disp(i);
	    min_days = min(size(temp{i},1), min_days);    
	end

	%count represents current position in the asset_data array
	%that we should assign to (as we may skip elements)

	count=1;

	for i = 1:8
	    asset_data(:,count) = temp{i}(1:min_days,2);
	    date_data(:,count) = cellstr(datestr(temp{i}(1:min_days,1))); 
	    count=count+1;
	end

    asset_data = flipud(asset_data);
    date_data = flipud(date_data);



end

