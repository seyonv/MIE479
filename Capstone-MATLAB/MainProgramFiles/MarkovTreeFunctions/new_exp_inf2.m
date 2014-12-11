% This function generates the markov tree and comptues the expected inflation raet

%curr_regime is 0 or 1
function [inf_rate,tnodes,tnodeval3] = new_exp_inf2(n,y0,curr_regime,c1,c2,ar1,ar2,p11,p12,p21,p22)

	% Compute an associated binary value for each termianl node which represents
	% the unique pathe taken to get to that node
	tnodes=terminal_nodes(n);

	% compute that actual terminal inflation values conditional on the path taken
	tnodeval=terminal_inflation(n,tnodes,c1,c2,ar1,ar2,y0);
	tnodeval2{n}=tnodeval;
	maxelements=2^n;
	
	% iterate over every time period and compute the values for each node
	for i=n:-1:1
		tnodes2=terminal_nodes(i);
		a=terminal_inflation(i,tnodes2,c1,c2,ar1,ar2,y0);
		% disp(i);
		% disp(a);
		tnodeval3(i,:)=[a zeros(1,maxelements-2^i)];
	end


	% transition probability matrix
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