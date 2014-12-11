function [ nominal_return, nominal_Q] = nominal_parameters(asset_data, market_data)
% take in the relevant time series data for assets and market 
% and return the nominal return and covariances for assets

% Model: Single factor CAPM



r_it = (asset_data(2:end,:)./asset_data(1:end-1,:)) - 1;
r_M = (market_data(2:end,:)./market_data(1:end-1,:)) - 1;

[T, n_assets] = size(r_it);

nominal_return = prod(1+r_it).^(1/T) - 1;
mu_M = prod(1+r_M).^(1/T) - 1;

del_M=sum((r_M(:,1) - mu_M(1)).^2)/T; % Factor variance
beta=(sum(r_it(:,1:end).*repmat(r_M(:,1),1,n_assets))/T-mean(r_it(:,1:end)*...
    mean(r_M(:,1)))/del_M); 
alpha = nominal_return(1:end)-beta*mu_M;

%Noise vector
for i=1:n_assets
    epsi(:,i)=r_it(:,i)-(alpha(i)+beta(i)*r_M(:,1));
end
del_epsi=diag(cov(epsi));

% Single factor covariance 
for i = 1:n_assets;
    for j = 1:n_assets;
        if i==j
            nominal_Q(i,i)=beta(i)^2*del_M+del_epsi(i);
        else
            nominal_Q(i,j)=beta(i)*beta(j)*del_M;
        end
    end
end
end

