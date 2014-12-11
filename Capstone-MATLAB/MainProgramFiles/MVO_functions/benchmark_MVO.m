%% STANDARD MARKOWITZ MVO MODEL VIA QUADPROG
% Input the number of assets, the range of desired returns, the mean vector
% for the assets, and the covariance matrix. The function will return the 
% optimal portfolio weights in MVO_x, and the corresponding variance 
% function value in MVO_var.
%
% [optimal weights, corresponding optimal objective function] 
%   = sMVO(# of assets, range of desired returns, expected return vector, 
%           covariance matrix)

% Set quadprog parameters
function [ MVO_x MVO_var] = benchmark_MVO( mu, Q, return_range, transaction_cost, previous_portfolio)


	n= length(mu);

	c = [zeros(3*n,1);];
	Aeq = [ones(1,n) zeros(1,2*n)
	           eye(n) -eye(n) eye(n)];
	beq = [1; previous_portfolio];
	A=[-mu' transaction_cost*ones(1,2*n)];
	lb=zeros(3*n,1);
	ub=9999*ones(3*n,1);
	R = return_range;

	tempQ=Q;
	Q = [Q zeros(n,2*n); zeros(2*n, 3*n)];

	% Set quadprog options
	options = optimset('Algorithm', 'interior-point-convex', 'TolFun', 1/10^10, 'MaxIter', 1000, 'TolCon', 1/(10^10));


	%Solve MVO and store SD values for plotting

	%Modify this so that it works for variable length R (length>1)
	for i = 1:length(R);

	    b=[-R(i); ];
	    
	    [MVO_x(i,:), MVO_var(i,1)] = quadprog(Q, c, A, b,Aeq, beq, lb, ub, [], options);

	    %MVO_std = MVO_var.^.5;
	    MVO_x=MVO_x(i,1:n);
	end

	adjvector = [MVO_x' mu diag(tempQ)];
end