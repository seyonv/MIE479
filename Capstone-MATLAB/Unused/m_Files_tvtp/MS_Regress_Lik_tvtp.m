% Likelihood Function for MS(k) Regression
%
% Modified by Zhuanxin Ding based on the original code by Marcelo Perlin to incorporate tvtp. 
%

function [sumlik,Output,logLikVec]=MS_Regress_Lik_tvtp(dep,indep_nS,indep_S,px,param,k,S,advOpt,disp_out)                                                     

useMex=advOpt.useMex;
distrib=advOpt.distrib;
Coeff_Tag=advOpt.Coeff_Tag;
constCoeff=advOpt.constCoeff;

% Calculation of some preliminary variables

nr=length(dep);
nEq=size(dep,2);

for iEq=1:nEq
    
    switch distrib
        case 'Normal'
            n_dist_param=1;             % Number of distributional parameters
            S_Var{iEq}=S{iEq}(end);     % if model switches in variance
        case 't'
            n_dist_param=2;             % Number of distributional parameters
            S_Var{iEq}=S{iEq}(end-1);
            S_df{iEq}=S{iEq}(end);      % if model is switching in degrees of freedom
        case 'GED'
            n_dist_param=2;             % Number of distributional parameters
            S_Var{iEq}=S{iEq}(end-1);
            S_k{iEq}=S{iEq}(end);       % if model is switching in k parameter (k as the GED parameter)
    end
    
    n_indep{iEq}=size(indep_nS{iEq},2)+size(indep_S{iEq},2);
    n_S{iEq}=sum(S{iEq}(1:end-n_dist_param));
    n_nS{iEq}=n_indep{iEq}-n_S{iEq};
    
end

typeCall='estimation';
[Coeff]=param2spec_tvtp(param,Coeff_Tag,constCoeff,typeCall);

% build back the distribution parameters

switch distrib
    case 'Normal'
        myIdx=0;
    case 't'
        myIdx=1;
    case 'GED'
        myIdx=1;
end

% for cases where variance covariance does not switch states
for ik=2:k
    for iEq=1:nEq
        if S{iEq}(end-myIdx)==0
            Coeff.covMat{ik}(iEq,iEq)=Coeff.covMat{1}(iEq,iEq); 
        end
    end
end

% building symmetric cov matrix
for ik=1:k
    for iEq=1:nEq
        for jEq=1:nEq
            if iEq<=jEq
                Coeff.covMat{ik}(iEq,jEq)=Coeff.covMat{ik}(jEq,iEq);
            end
        end
    end
end

% for cases where the distributional parameter does not switch states
switch distrib
    case 't'
        for ik=2:k
            for iEq=1:nEq
                if S{iEq}(end)==0
                    Coeff.df{iEq}(1,ik)=Coeff.df{iEq}(1,1);
                end
            end
        end
        
    case 'GED'
        for ik=2:k
            for iEq=1:nEq
                if S{iEq}(end)==0
                    Coeff.K{iEq}(1,ik)=Coeff.K{iEq}(1,1);
                end
            end
        end
end

for iEq=1:nEq
    if n_nS{iEq}==0
        indep_nS{iEq}=zeros(nr,1);
        Coeff.nS_Param{iEq}=0;
    end
    
    if n_S{iEq}==0
        indep_S{iEq}=zeros(nr,1);
        Coeff.S_Param{iEq}=zeros(1,k);
    end
end

% Organizing Coeffs for each state
Cond_mean=cell(nEq,1);
e=cell(nEq,1);
n=zeros(nr,k);

% Vectorized main engine
for i=1:k
    
    for iEq=1:nEq
        Cond_mean{i}(:,iEq)=indep_nS{iEq}*Coeff.nS_Param{iEq}+indep_S{iEq}*Coeff.S_Param{iEq}(:,i);     % Conditional Mean for each equation (cell wise) and each state (column wise)
        e{i}(:,iEq)=dep(:,iEq)-Cond_mean{i}(:,iEq);                                                     % Error for each state (cell) for each Equation
    end
    
    switch distrib
        case 'Normal'
            n(:,i)=myMVNPDF_tvtp(dep,Cond_mean{i},Coeff.covMat{i});
        case 't'
            n(:,i)=( gamma(.5.*(Coeff.df{1}(i)+1)) ) ./ ( (gamma(.5.*Coeff.df{1}(i))).*sqrt(pi().*Coeff.df{1}(i).*Coeff.covMat{i})).* ...
                   ((1+((e{i}(:,1)).^2)./(Coeff.df{1}(i).*Coeff.covMat{i})).^(-.5.*(Coeff.df{1}(i)+1)) );
               
%             n(:,i)=( gamma(.5.*(Coeff.df{1}(i)+nEq)) ) ./ ( (gamma(.5.*Coeff.df{1}(i))).*(pi().*Coeff.df{1}(i))^(nEq/2).*sqrt(det(Coeff.covMat{i})) ).* ...
%                    ((1+((e{i}(:,:)).^2)./(Coeff.df{1}(i).*Coeff.covMat{i})).^(-.5.*(Coeff.df{1}(i)+1)) );
                
        case 'GED'
            n(:,i)=exp(-1/2.*abs(e{i}(:,1)./sqrt(Coeff.covMat{i})).^(1/Coeff.K{1}(1,i)))./(2.^(Coeff.K{1}(1,i)+1).* ... 
                   sqrt(Coeff.covMat{i}.*gamma(Coeff.K{1}(1,i)+1)) );
    end
    
end

% Zhuanxin Ding Comments:
% time varying transition probability;
% The code here tries to estimate the time varying transition probabilty matrix based on some state variables. The code is set using 
% the cumulative density function so that the estimated probability is always between 0 and 1 even if there are more than 2 states.
%
p=ones(k,k,nr);
pflat=zeros(nr,k^2);    % Brett Sumsion added to initialize the pflat matrix
tvtp=ones(k,k,nr);
for t=1:nr
    for i=1:k-1
        for j=1:k
            tvtp(i,j,t)=normcdf(px{i,j}(t,:)*Coeff.pa{i,j});
            p(i+1,j,t)=p(i,j,t)*(1-tvtp(i,j,t));
        end
    end   
    p(:,:,t)=p(:,:,t).*tvtp(:,:,t);
    tmp=p(:,:,t);         % Brett Sumsion added to initialize the pflat matrix
    pflat(t,:)=tmp(:)';   % Brett Sumsion added to initialize the pflat matrix
end
% Coeff.p=p;

% Marcelo Perlin's original code for using the mex_MS_Filter;
% if useMex==1
%     if exist('mex_MS_Filter')==0
%         error(['The likelihood function is not able to use the mex version of the filter.' ...
%             ' You need to compile the file mex_MS_Filter.cpp in your pc in order for it to work.' ...
%             ' More details at pdf document from the zip file.']);
%     else
%         [f,E]=mex_MS_Filter(Coeff.p,n);     % this place needs to be changed if useMex=1;
%         f=f';
%         E=E';
%     end
% else
 
% Brett Sumsion of Dupont Capital Management kindly modified Marcelo's c++ filter (mex_MS_Filter.cpp
% and renamed mex_MS_Filter_tvtp.cpp here) and the following code to incorporate the filter. 

% Brett Sumsion Comments:
% I create a "pflat" matrix that removes the need for the c++ to operation on a 3d matrix.   
% The matrix is passed the c function and returns the f and E vectors.  You will note that 
% I pass the pflat matrix and n matrix (conditional densities) with the top lines padded with zeros.  
% I believe there is an error in Marcelo's original c++ that causes the function to use the wrong 
% index for the n vector.  Padding with zeros is a work around.

if useMex==1
   if exist('mex_MS_Filter_tvtp')==0
       error(['The likelihood function is not able to use the mex version of the filter.' ...
           ' You need to compile the file mex_MS_Filter_tvtp.cpp in your pc in order for it to work.' ...
           ' More details at Marcelo Perlin''s pdf document from the zip file.']);
   else
       [f,E]=mex_MS_Filter_tvtp([zeros(k^2,1) pflat'],[zeros(1,k);n]);  %Padded the top of matrix with zeros to correct for error in Marcelo's original filter.  
       f=f(2:end)';     %Remove the zeros.
       E=E(:,2:end)';
   end
else
    
    % Pre-allocation of large matrices
    E=zeros(nr,k);
    f=zeros(nr,1);
    
    % Setting up first probs of E
    % code for constant transition probability;
%     firstProb=repmat(1/k,1,k);
%     for t=1:nr
%         if t==1                                                 % first probabilities use a naive guess (1/k)
%             f(t,1)=ones(k,1)'*(Coeff.p*firstProb'.*n(t,:)');    % Eq (8) of Hamilton's paper
%             E(t,:)=((Coeff.p*firstProb'.*n(t,:)')/f(t,1));      % Eq (9) of Hamilton's paper
%         else
%             f(t,1)=ones(k,1)'*(Coeff.p*E(t-1,:)'.*n(t,:)');     % Eq (8) of Hamilton's paper
%             E(t,:)=((Coeff.p*E(t-1,:)'.*n(t,:)')/f(t,1));       % Eq (9) of Hamilton's paper
%         end
%     end
    
    % Setting up first probs of E
    firstProb=repmat(1/k,1,k);
    for t=1:nr
        if t==1                                                  % first probabilities use a naive guess (1/k)
%             f(t,1)=n(t,:)*p(:,:,t)*firstProb';                   % Eq (8) of Hamilton's paper
            f(t,1)=ones(k,1)'*(p(:,:,t)*firstProb'.*n(t,:)');    % Eq (8) of Hamilton's paper
            E(t,:)=((p(:,:,t)*firstProb'.*n(t,:)')/f(t,1));      % Eq (9) of Hamilton's paper
        else
%             f(t,1)=n(t,:)*p(:,:,t)*E(t-1,:)';                    % Eq (8) of Hamilton's paper
            f(t,1)=ones(k,1)'*(p(:,:,t)*E(t-1,:)'.*n(t,:)');     % Eq (8) of Hamilton's paper or (22.4.5) of Hamilton's book
            E(t,:)=((p(:,:,t)*E(t-1,:)'.*n(t,:)')/f(t,1));       % Eq (9) of Hamilton's paper or (22.4.6) of Hamilton's book
        end
    end
    
end

% Negative sum of log likelihood for fmincon (fmincon minimizes the function)
sumlik=-sum(log(f(2:end)));

% Control for nan, Inf, imaginary
if isnan(sumlik)||isreal(sumlik)==0||isinf(sumlik)
    sumlik=Inf;
end

% Building Output structure

Prob_t_1=zeros(nr,k);
Prob_t_1(1,1:k)=1/k;    % This is the matrix with probability of s(t)=j conditional on the information in t-1

for t=2:nr
    Prob_t_1(t,1:k)=(p(:,:,t)*E(t-1,1:k)')'; % prob conditional on t-1
%     Prob_t_1(t,1:k)=E(t-1,1:k)*p(:,:,t)'; % prob conditional on t-1
end

f(f==0)=1;

logLikVec=log(f);
Output.Coeff=Coeff;
Output.filtProb=E;
Output.LL=-sumlik;
Output.k=k;
Output.param=param;
Output.S=S;
Output.advOpt=advOpt;
Output.p=p;

% Output.Prob_t_1=Prob_t_1;     % add this so that we don't need to recalculate in MS_Regress_Fit_tvtp;


for iEq=1:nEq
    for ik=1:k
        myStdVec{iEq}(:,ik)=repmat(sqrt(Coeff.covMat{ik}(iEq,iEq)),nr,1);
        myCondMean{iEq}(:,ik)=Cond_mean{ik}(:,iEq);
    end
    Output.condMean(:,iEq)=sum(myCondMean{iEq}.*Prob_t_1,2); % conditional mean build with probabiblites conditional in t-1
    Output.condStd(:,iEq)=sum(myStdVec{iEq}.*Prob_t_1,2);
    
    Output.resid(:,iEq)=dep(:,iEq)-Output.condMean(:,iEq);
end

if disp_out==1
    fprintf(1,['\nSum log likelihood for MS Regression -->', num2str(-sumlik)]);
end
