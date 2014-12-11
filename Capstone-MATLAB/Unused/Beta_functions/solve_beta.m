%The formula for beta is the covariance of the asset to the market
%divided by the variance of the market
%can either plug in the market index data or the inflation rate data
% to find the standard CAPM beta or the inflation beta respectively
function [del_M Beta] = solve_beta(n_assets,r_it,r_M,mu,mu_M,T)

	disp(n_assets);
	[T,n]=size(r_it);
	disp(n);
  	del_M=sum((r_M(:,1) - mu_M(1)).^2)/T; % Factor variance
  	disp(del_M)
    Beta=(sum(r_it(:,1:end).*repmat(r_M(:,1),1,n_assets))/...
    	T-mean(r_it(:,1:end)*mean(r_M(:,1)))/del_M); 
    alpha = mu(1:end)-Beta*mu_M;

    %Noise Vector
    for i=1:n_assets
    	epsi(:,i)=r_it(:,i)-(alpha(i)+Beta(i)*r_M(:,1));
	end
	del_epsi=diag(cov(epsi));

	% Single factor covariance 
	for i = 1:n_assets;
	    for j = 1:n_assets;
	        if i==j
	            nominal_Q(i,i)=Beta(i)^2*del_M+del_epsi(i);
	        else
	            nominal_Q(i,j)=Beta(i)*Beta(j)*del_M;
	        end
	    end
	end

end