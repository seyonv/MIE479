% input parameters are the Start month(string)/year(int), End month(string)/year(int)
function [prices price_names price_dates marketprice num_assets] = ...
      monthly_stock_data(sMonth,sYear,eMonth,eYear,SP500_symb,SP500_symb_csv)



	month={};
	day={};
	year={};
	price={};
	fail_symbols={};
	success_symbols={};
	fc=0;
	sc=0;
	for i=1:length(SP500_symb_csv)
		try
			curr_csv=char(SP500_symb_csv(i));
			curr_symb=char(SP500_symb(i));

			[tempmonth{i} tempday{i} tempyear{i} tempprice{i}] = ...
			 textread(curr_csv ,'%s %d %d %f','delimiter',',: ')
			 
			 sc=sc+1;
			 success_symbols{sc}=curr_symb;
		catch
			curr_symb=char(SP500_symb(i));
			fc=fc+1;
			fail_symbols{fc}=curr_symb;
		end
	end



currmonth='Jan';
for (i=1:100)
	if (~isempty(strfind(currmonth,r1(i,1)))
		disp(r1(i,2));
		break;
	end
end














end