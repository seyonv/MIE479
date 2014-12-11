% This is the recursive function that commputes the expected inflation variance
% associated with each node
function [nodeval] = new_infvar_nodeval(n,p,varval,muinfval,start_regime)

	n=n-1;

	% Determines the two hcild nodes of a node and uses those values to get
	% the variances used in the expectation formula
	for i=1:2^n
			var2(i)=varval(2*i-1);
			var1(i)=varval(2*i);
			mudiff(i)=(muinfval(2*i-1)-muinfval(2*i))^2;
	end

	% This is the base case and you use either p(1,1) and p(1,2) or
	% p(2,1) and p(2,2) depending on the starting regime
	if n==0
		if (start_regime==1)
			prob=p(1,1);

			
		elseif (start_regime==2)
			prob=p(2,1);
		end
		nodeval(i)=prob*var1(i)+(1-prob)*var2(i)+prob*(1-prob)*mudiff(i);
	
	else
		% This is the recursive case but the node value can still be computed
		% at that point.
		for i=1:2^n
			if mod(i,2) == 0
				prob=p(1,1);
			else
				prob=p(2,1);
			end
			nodeval(i)=prob*var1(i)+(1-prob)*var2(i)+prob*(1-prob)*mudiff(i);
		end
		% end
	end
end         