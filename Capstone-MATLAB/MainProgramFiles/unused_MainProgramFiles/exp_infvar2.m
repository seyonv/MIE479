function [inf_var ] = exp_infvar2(n,curr_regime,c1,c2,var1,var2,p11,p12,p21,p22)

	nodeval=initial_terminal_inflation_var(n,var1,var2);

	p= [p11 p12
		p21 p22];

	mudiff=(c1-c2)^2;
	for i=(n-1):-1:0
		nodeval=infvar_node_val(i,p,nodeval(2),nodeval(1),mudiff,curr_regime);
	end
	inf_var=nodeval(1);

end