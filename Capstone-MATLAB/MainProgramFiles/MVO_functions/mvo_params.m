%This function is passed in the pricedata for ONE asset
function [ mu, Q, r_it ] = mvo_params(pricedata, end_pred)
%% DETERMINE EXPECTED RETURNS AND COVARIANCES FOR ASSETS
% Input a matrix of time series data for the desired assets, as well as 
% the number of days in the estimation horizon starting from day 1, and the
% function will return the expected returns and covariances calculated from
% the time series data from the estimation horizon.
%
% [expected returns, covariance matrix] = param_data(time series,
%                                                   estimation horizon)

r_it = (data(2:end_pred,:)./data(1:end_pred-1,:)) - 1;
[T, n] = size(r_it); %time periods, assets
mu = prod(1+r_it).^(1/T) - 1;
Q = cov(r_it);

end

