% Function for estimating a general Markov Regime Switching regression with tvtp
%
%   Input:  dep     - Dependent Variable (vector (univariate model) or matrix (multivariate) )
%           indep   - Independent variables (explanatory variables), should
%                     be cell array in the case of multivariate model (see examples).
%           px      - macro/state variables for time varying transition probability. It is a (k-1, k) cell array.
%           k       - Number of states (integer higher or equal to 2)
%           S       - This variable controls for where to include a Markov Switching effect.
%                     See pdf file for details.
%           advOpt  - A structure with advanced options for algorithm.
%                     See pdf file for details.
%
%   Output: Spec_Output - A structure with all information regarding the
%                         model estimated from the data (see pdf for details).
%
%   Author: Marcelo Perlin (UFRGS/BR) for the constant transition probability version.  
%   Contact:  marceloperlin@gmail.com
%
%   Author: Zhuanxin Ding for the time varying transition probability version.
%
%   Modified by Zhuanxin Ding based on the original code by Marcelo Perlin to incorporate the 
%   time-varying transition probability matrix that depends on state variables, June 12,2012.
%   (see paper by Gabriel Perez-Quiros and Allan Timmermann, Journal of Finance, June 2000)
%
%   Please see the following paper for explanation of the code
%   http://papers.ssrn.com/sol3/papers.cfm?abstract_id=2083332
%

function [Spec_Output]=MS_Regress_Fit_tvtp(dep,indep,px,k,S,advOpt)

% Error checking lines

checkInputs_tvtp(); % checking if inputs variables are OK

% building constCoeff for the cases when it is not specified

build_constCoeff_tvtp();

% checking if all fields are specified and make sense

check_constCoeff_tvtp();

% checking sizes of fields in constCoeff

checkSize_constCoeff_tvtp();

% Pre calculations before calling the optimizer

preCalc_MSModel_tvtp();

% Initialization of optimization algorithm

warning('off');
param0=param0';     % changing notation for param0
dispOut=advOpt.printIter;

% Call to optimization function

if strcmp(advOpt.optimizer,'fmincon')==1 | isfield(advOpt,'optimizer')==0
    
    options=optimset('fmincon');
    options=optimset(options,'display','off');

    % [param]=fmincon(@(param)MS_Regress_Lik(dep,indep_nS,indep_S,param,k,S,advOpt,dispOut),param0, ...
    %     A,b,Aeq,beq,lB,uB,[],options);

    [param]=fmincon(@(param)MS_Regress_Lik_tvtp(dep,indep_nS,indep_S,px,param,k,S,advOpt,dispOut),param0, ...
        [],[],[],[],lB,uB,[],options);

else
    if strcmp(advOpt.optimizer,'fminunc')==1
    
        options=optimset('fminunc');
        options=optimset(options,'display','off');
        % options=optimset(options,'MaxFunEvals',1000);
        % options=optimset(options,'MaxIter',10000);
        % options=optimset(options,'TolFun',1.000000000000000e-07);
        % options=optimset(options,'TolX',1.000000000000000e-7);

        % [param]=fminunc(@(param)MS_Regress_Lik_tvtp(dep,indep_nS,indep_S,px,param,k,S,advOpt,dispOut),param0,options);
        [param,fval,exitflag,output]=fminunc(@(param)MS_Regress_Lik_tvtp(dep,indep_nS,indep_S,px,param,k,S,advOpt,dispOut),param0,options);
        
    else        % use Tomlab optimization instead;
        
        Prob = conAssign(@(param)MS_Regress_Lik_tvtp(dep,indep_nS,indep_S,px,param,k,S,advOpt,dispOut), [], [], [], lB, uB, 'Name',param0);
        Result = tomRun('snopt',Prob,2);
        param = Result.x_k;
        
    end
    
end

% param

% Calculation of Error Covariance Matrix

[V]=getvarMatrix_MS_Regress_tvtp(dep,indep_nS,indep_S,px,param,k,S,std_method,advOpt);

param_std=sqrt(diag((V)));

% Controls for covariance matrix. If found imaginary number for variance, replace with Inf. 
% This will then be showed at output.

param_std(isinf(param_std))=0;
param_pvalues=2*(1-tcdf(abs(param./param_std),nr-numel(param)));

if ~isreal(param_std)
    for i=1:numel(param)
        if ~isreal(param_std(i))
            param_std(i)=Inf;
        end
    end
end

typeCall='se_calculation';

[Coeff_SE]=param2spec_tvtp(param_std,Coeff_Tag,constCoeff,typeCall);
[Coeff_pValues]=param2spec_tvtp(param_pvalues,Coeff_Tag,constCoeff,typeCall);

% After finding param, filter it to the data to get estimated output

[sumlik,Spec_Output]=MS_Regress_Lik_tvtp(dep,indep_nS,indep_S,px,param,k,S,advOpt,0);

% calculating smoothed probabilities

Prob_t_1=zeros(nr,k);	% This is the matrix with probability of s(t)=j conditional on the information in t-1
 
Prob_t_1(1,1:k)=repmat(1/k,1,k)*Spec_Output.p(:,:,1)';
for t=2:nr
    Prob_t_1(t,1:k)=Spec_Output.filtProb(t-1,1:k)*Spec_Output.p(:,:,t)';
end

% filtProb is the probability of s(t)=j conditional on the information in t; 
filtProb=Spec_Output.filtProb;
smoothProb=zeros(nr,k);
smoothProb(nr,1:k)=Spec_Output.filtProb(nr,:);  % last observation for starting filter

for t=nr-1:-1:1     % work backwards in time for smoothed probs
    smoothProb(t,:)=filtProb(t,:).*((smoothProb(t+1,:)./Prob_t_1(t+1,:))*Spec_Output.p(:,:,t+1));
    % see p694 of Hamilton's book for formula (22.4.14), the above formula is transposed;
end
 
% Calculating Expected Duration of regimes
 
stateDur=1./(1-diag(mean(Spec_Output.p,3)));
Spec_Output.stateDur=stateDur;

% passing values to output structure

Spec_Output.smoothProb=smoothProb;
Spec_Output.nObs=size(Spec_Output.filtProb,1);
Spec_Output.Number_Parameters=numel(param);
Spec_Output.advOpt.distrib=distrib;
Spec_Output.advOpt.std_method=std_method;
Spec_Output.Coeff_SE=Coeff_SE;
Spec_Output.Coeff_pValues=Coeff_pValues;
Spec_Output.AIC=2*numel(param)-2*Spec_Output.LL;
Spec_Output.BIC=-2*Spec_Output.LL+numel(param)*log(Spec_Output.nObs*nEq);

% ploting probabilities

if advOpt.doPlots

    if isfield(advOpt,'YYYYMM')==1
        tsPlots_tvtp();
    else
        doPlots_tvtp();
    end

end

% Sending output to matlab's screen

disp(' ');
if advOpt.printOut
    doOutScreen_tvtp()
end
