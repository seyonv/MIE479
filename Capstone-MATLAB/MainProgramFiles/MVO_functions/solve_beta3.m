% This function is used to compute the inflation Beta, but it can also
% compute the CAPM beta if desired. The second parameter passed in can either be 
% inflation rate date or market data
function [solved_beta R_squared] = solve_beta3(tprice,inf_or_market)

    %MARKET - CAPM 
	if (inf_or_market==2)
		r_it=tprice(2:end,:)./tprice(1:end-1,:)-1;
    %MARKET - INFLATION 
	elseif (inf_or_market==1)
		r_it=tprice(2:end,2:end)./tprice(1:end-1,2:end)-1;
		[T n] = size(r_it)
        disp(size(tprice(:,1)))
		r_it=[tprice(1:T,1) r_it];
	end

	[T, n]=size(r_it);                                  %number of time period T and asset n
	mu=prod(1+r_it).^(1/T)-1;                           %Geometric mean for factor and assets
	del_M=sum((r_it(:,1)-mu(1)).^2)/T;                  %variance of factor under geometric mean

	%Calculate the Beta coefficient
    
    if inf_or_market==1
	for i = 2:n
        p = polyfit(r_it(:,1)./100,r_it(:,i),1);
        solved_beta(i - 1) = p(1);
        
        yfit = polyval(p,r_it(:,1)./100);
        y = r_it(:,i);
        yresid = y - yfit;
        SSresid = sum(yresid.^2);
        SStotal = (length(y)-1) * var(y);
        R_squared(i - 1) = 1 - SSresid/SStotal;
    end
    
    else
    for i = 2:n
        p = polyfit(r_it(:,1),r_it(:,i),1);
        solved_beta(i - 1) = p(1);
        
        yfit = polyval(p,r_it(:,1));
        y = r_it(:,i);
        yresid = y - yfit;
        SSresid = sum(yresid.^2);
        SStotal = (length(y)-1) * var(y);
        R_squared(i - 1) = 1 - SSresid/SStotal;
    end
    
   
end