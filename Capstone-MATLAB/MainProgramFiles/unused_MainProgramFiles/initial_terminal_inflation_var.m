function [tnodeval] = initial_terminal_inflation_var(n,var1,var2)

	tnodeval=[];
	for i=1:2^n
		if mod(i,2) == 0
			tnodeval(i)=var1;
		else
			tnodeval(i)=var2;
		end
	end
end