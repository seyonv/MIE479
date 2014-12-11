function [nodeval] = infvar_node_val(n,p,var1,var2,mudiff,start_regime)

	if (n==0)
		if (start_regime==1)
			prob=p(1,1);
			nodeval(1)=prob*var1+(1-prob)*var2+prob*(1-prob)*mudiff;
		elseif(start_regime==2)
			prob=p(2,1);
			nodeval(1)=prob*var1+(1-prob)*var2+prob*(1-prob)*mudiff;

		end
	else
		for i=1:2^n
			if mod(i,2) == 0
				prob=p(1,1);
			else
				prob=p(2,1);
			end
			nodeval(i)=prob*var1+(1-prob)*var2+prob*(1-prob)*mudiff;
		end
	end

end