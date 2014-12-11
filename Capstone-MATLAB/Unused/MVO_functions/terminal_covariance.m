function [terminal_cov] = terminal_covariance(nominal_return, ...
                                       regime_beta, regime_mu, regime_var)
%{
Given the nominal return data, and regime parameters, return the terminal
covariance matrix for a given node

METHOD:

1. treat returns like a factor model at the terminal node
2. find the resulting returns for each of the assets by
   terminal_return = r_nominal + inflation contribution at terminal node
3. then based on that, and the mean and covariance calculated for inflation 
   for a given regime, use the method from single factor model to
   get the covariance matrix

NOTE: This is the model that I think I want to use

This function will extract these terminal variances.

Then, you can take the expectation using the markov chain variance formula

"expected" variance = P * R1_variance
                    + (1-P) * R2_variance + P(1-P)(r_R2 - r_R1)^2

to contrast:

"expected" return = P * r_R1 + (1-P) * r_R2

The key difference is the 3rd term which accounts for the difference in the
returns between the 2 means.

Of course, there is a vector form of this equation which we'll have to
implement for matlab, but for simplicity's sake I gave the 1 asset version.

%}
                                       
[T, n_assets] = size(nominal_return);                                       

for i = 1:2^n;
    if mod(i,2)
        beta = regime_beta(1);
        del_inf = regime_var(1);
        mu_inf = regime_mu(1);
    else
        beta = regime_beta(2);
        del_inf = regime_var(2);
        mu_inf = regime_mu(2);
    end
    
terminal_return = nominal_return + beta*terminal_inflation(i);

alpha = terminal_return(1:end)-beta*mu_inf;

% Single factor covariance 
for j = 1:n_assets;
    for k = 1:n_assets;
        if j==k
            terminal_Q(j,j)=beta(j)^2*del_inf;
        else
            terminal_Q(j,k)=beta(j)*beta(k)*del_inf;
        end
    end
end

terminal_cov(i) = terminal_Q;

end

