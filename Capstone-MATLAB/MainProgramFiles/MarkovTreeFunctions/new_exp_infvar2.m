% THis function is used to compute the expected variance of the inflation rate
function [inf_var inf_var_node_val ] =...
	 new_exp_infvar2(n,start_regime,tnodeval,var1,var2,p11,p12,p21,p22)



	p= [p11 p12
		p21 p22];
	% For every terminal node, assign either variance of regime 1 or variance of regime 2
	% as its value
	for i=1:2^n
		if (mod(i,2)==0)
			initialvarval(i)=var1;
		elseif (mod(i,2)==1)
			initialvarval(i)=var2;
		end
	end

	
	infvar_node_val=initialvarval;

	% Iterate over every time period and call the recursive function new_infvar_nodeval
	% until you reach the initial time period
	for i=n:-1:1
		infvar_node_val=...
			new_infvar_nodeval(i,p,infvar_node_val,tnodeval(i,:),start_regime);
	end
	inf_var=infvar_node_val(1);

end