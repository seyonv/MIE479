%This function takes in a matrix of asset prices,

function [mu, Q, r_it] = solve_mvo_params(asset_prices,beg_pred,end_pred)

	data=asset_prices;
	r_it = (data((beg_pred+1):end_pred,:)./data(beg_pred:end_pred-1,:)) - 1;
	[T, n] = size(r_it);
	mu = prod(1+r_it).^(1/T) - 1;
	Q = cov(r_it);

end