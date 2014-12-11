%function is called exp_inf2 because it is the recursion process
% for 2 states. The process differs for k=3 regims and their is a corresponding
% different function

%curr_regime is 0 or 1
function [inf_rate,tnodes,tnodeval] = exp_inf2(n,y0,curr_regime,c1,c2,ar1,ar2,p11,p12,p21,p22)

	tnodes=terminal_nodes(n);
	tnodeval=terminal_inflation(n,tnodes,c1,c2,ar1,ar2,y0);

	p= [p11 p12
	    p21 p22];

	inf_rate=0;
	for i=1:2^n
		currprod=tnodeval(i);
		cnode=tnodes{i};
		%for the n-1 transition probabilities
		for j=n:-1:2
			ind1=str2num(cnode(j))+1;
			ind2=str2num(cnode(j-1))+1;
			currprod=currprod*p(ind2,ind1);
		end
		%for the initial transition probability
		ind3=str2num(cnode(1))+1;
		currprod=currprod*p(curr_regime,ind3);
		
		inf_rate=inf_rate+currprod;

	end


end	