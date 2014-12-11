function [Spec_Out p11 p22 p12 p21 var1 var2 var3 ar1 ar2 ar3 c1 c2 c3] = ...
		 RegimeSwitching_MLE(k,inf_data)

		disp('Computing Parameters of Regime Switching Model');
		addpath('../../MS_Regress_FEX_1.08/m_Files'); % add 'm_Files' folder to the search path
		addpath('../../MS_Regress_FEX_1.08/data_Files');

		logRet=inf_data;  % load some Data.

		% Defining dependent variables in system (solving for two dependent variables)
		dep=logRet(:,1);                 	
		nLag=1;                             % Number of lags in system
		k=k;								% Number of States
		doIntercept=1;                      % add intercept to eqsuations
		%%
		advOpt.diagCovMat=0					%if this value is 1, then only the elements on the diagonal(the variances) are estimated
		%%
		advOpt.distrib='Normal';            % The Distribution assumption (only 'Normal' for MS VAR models) )this is the default avlue
		advOpt.std_method=1;                % Defining the method for calculation of standard errors. See pdf file for more details

		Spec_Out=MS_VAR_Fit(dep,nLag,k,doIntercept,advOpt);
		disp('COMPLETED MS_VAR_FIT function');

		% make the transition probabilites easier to call
		% where pij is probability of going to regime j from regime i
		p11=Spec_Out.Coeff.p(1,1);
		p22=Spec_Out.Coeff.p(2,2);
		p12=Spec_Out.Coeff.p(2,1); 
		p21=Spec_Out.Coeff.p(1,2);
		
		% The variances associated with each regime
		var1=cell2mat(Spec_Out.Coeff.covMat(1,1));
		var2=cell2mat(Spec_Out.Coeff.covMat(1,2));
		
		%autoregressive terms for each regime
		%Have to use two lines to properly index values
		ar1=Spec_Out.Coeff.S_Param(1,1);
		ar1=ar1{1}(2,1);

		ar2=Spec_Out.Coeff.S_Param(1,1);
		ar2=ar2{1}(2,2);

		%intercepts for each regime (These are the mean inflation rates for the regime)
		c1=Spec_Out.Coeff.S_Param(1,1);
		c1=c1{1}(1,1);

		c2=Spec_Out.Coeff.S_Param(1,1);
		c2=c2{1}(1,2);

		%Different return values depending on whether there are 2 or 3 regimes
		if (k==2)
			t=num2cell(zeros(1,8));
			[p13,p23,p33,p32,p31,var3,ar3,c3]=deal(t{:});
			
		elseif (k==3)
			p13=1-p11-p12;
			p23=1-p22-p21;
			p33=Spec_Out.Coeff.p(3,3);
			p32=Spec_Out.Coeff.p(2,3);
			p31=Spec_Out.Coeff.p(1,3);
			var3=cell2mat(Spec_Out.Coeff.covMat(1,3));
			ar3=Spec_Out.Coeff.S_Param(1,1);
			ar3=ar2{1}(2,3);
			c3=Spec_Out.Coeff.S_Param(1,1);
			c3=c3{1}(1,3);
		end

end