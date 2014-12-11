function [month day year price fail_symbols success_symbols] = ...
	all_stock_data(SP500_symb_csv,SP500_symb)



	
	[month,day,year,price,fail_symbols,success_symbols]=deal(cell(1,1));
	
	fc=0;
	sc=1;
	for i=1:length(SP500_symb_csv)
		try
			curr_csv=char(SP500_symb_csv(i));
			curr_symb=char(SP500_symb(i));
			success_symbols{sc}=curr_symb;

			[month{sc} day{sc} year{sc} price{sc}] = ...
			 textread(curr_csv ,'%s %d %d %f','delimiter',',: ');
			
			sc=sc+1;
			

		catch
			curr_symb=char(SP500_symb(i));
			fc=fc+1;
			fail_symbols{fc}=curr_symb;
		end
	end	
	%BY THE END OF THIS LOOP WE HAVE DAILY TIME SERIES DATA
	%NOW ITERATE THROUGH MONTH VECTOR AND DELETE EVERY ELEMENT
	% WHICH HAS THE SAME MONTH

	% price_names=[];

	% for (i=1:length(success_symbols))
	% 	price_names=[price_names; success_symbols(i)];
	% end

	% success_symbols=price_names;







end