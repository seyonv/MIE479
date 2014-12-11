function [del_M Beta] = solve_beta2(tprice,inf_or_market)

	if (inf_or_market==2)
		r_it=tprice(2:end,:)./tprice(1:end-1,:)-1;
	elseif (inf_or_market==1)
		r_it=tprice(2:end,2:end)./tprice(1:end-1,2:end)-1;
		disp(size(r_it));
		disp(size(tprice(:,1)));
		r_it=[tprice(:,1) r_it];
	end

	[T, n]=size(r_it);                                  %number of time period T and asset n
	mu=prod(1+r_it).^(1/T)-1;                           %Geometric mean for factor and assets
	del_M=sum((r_it(:,1)-mu(1)).^2)/T;                  %variance of factor under geometric mean

	%Calculate the Beta coefficient
	Beta= (sum(r_it(:,2:end).*repmat(r_it(:,1),1,n-1))/T-mean(r_it(:,2:end))*mean(r_it(:,1)))/del_M 
	

   
end