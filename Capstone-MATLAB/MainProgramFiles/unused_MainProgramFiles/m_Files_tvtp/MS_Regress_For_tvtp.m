% Function for forecasting in t+1 an Markov Switching regression model
% estimated with MS_Regress_Fit.m
%
%   Input:  Spec_Output - Specification output from estimation (check MS_Regress_Fit.m)
%           newIndepData - New information that has arrived for t+1 and beyond (maybe lagged variables ?)
%           newpxData - New information that has arrived for t+1 and beyond for macro state variables
%
%   Output: meanFor - Forecast for the mean equation (column iterating over equations of system)
%           stdFor - Forecast for the standard deviation (columns iterating over
%           equations of system)
% 
%   Author: Marcelo Perlin
%   Email:  marceloperlin@gmail.com
%
%   Author: Marcelo Perlin (UFRGS/BR) for the constant transition probability version.  
%   Contact:  marceloperlin@gmail.com
%
%   Author: Zhuanxin Ding for the time varying transition probability version.
%
%   Modified by Zhuanxin Ding based on the original code by Marcelo Perlin to incorporate the 
%   time-varying transition probability matrix that depends on state variables, May 21,2012.
%   (see paper by Gabriel Perez-Quiros and Allan Timmermann, Journal of Finance, June 2000)
%

function [meanFor,stdFor]=MS_Regress_For_tvtp(Spec_Out,newIndepData,newpxData)

% Retrieving variables from Spec_Output
nEq=size(Spec_Out.condMean,2);
k=Spec_Out.k;
S=Spec_Out.S;
Coeff=Spec_Out.Coeff;

if ~iscell(newIndepData)
    temp=newIndepData;
    clear newIndepData;
    for iEq=1:nEq
        newIndepData{iEq}=temp;
    end
end

if ~iscell(newpxData)
    temp=newpxData;
    clear newpxData;
    for i=1:k-1
        for j=1:k
            newpxData{i,j}=temp;
        end
    end
end

% forecast horizon;
h=size(newIndepData{1},1);

for ik=1:k
    Std{ik}=sqrt(diag(Coeff.covMat{ik}));
end

distrib=Spec_Out.advOpt.distrib;

for iEq=1:nEq
    switch distrib
        case 'Normal'
            S_Std{iEq}=S{iEq}(end);
            n_dist_param=1; % Number of d
        case 't'
            S_Std{iEq}=S{iEq}(end-1);
            n_dist_param=2; % Number of distributional parameters
        case 'GED'
            S_Std{iEq}=S{iEq}(end-1);
            n_dist_param=2; % Number of distributional parameters
    end
end

indep_S=cell(nEq,1);
indep_nS=cell(nEq,1);
for iEq=1:nEq
    
    count_S=0;
    count_nS=0;
    
    for i=1:length(S{iEq})-n_dist_param
        if S{iEq}(i)==1
            count_S=count_S+1;
            indep_S{iEq}(:,count_S)=newIndepData{iEq}(:,i);
        else
            count_nS=count_nS+1;
            indep_nS{iEq}(:,count_nS)=newIndepData{iEq}(:,i);
        end
    end
    
    if count_nS==0
        indep_nS{iEq}=zeros(h,1);
    end
    
end

% Building Forecasts

% future time varying transition probability matrix;
pa=Spec_Out.Coeff.pa;
p=ones(k,k,h);
tvtp=ones(k,k,h);
for t=1:h
    for i=1:k-1
        for j=1:k
            tvtp(i,j,t)=normcdf(newpxData{i,j}(t,:)*pa{i,j});
            p(i+1,j,t)=p(i,j,t)*(1-tvtp(i,j,t));
        end
    end   
    p(:,:,t)=p(:,:,t).*tvtp(:,:,t);
end

% state probability;
firstProb=Spec_Out.filtProb;
for t=1:h
    if t==1
        E(t,:)=p(:,:,t)*firstProb(end,:)';      % Eq (9) of Hamilton's paper
    else
        E(t,:)=p(:,:,t)*E(t-1,:)';       % Eq (9) of Hamilton's paper or (22.4.6) of Hamilton's book
    end
end

for t=1:h
    for iEq=1:nEq

        for j=1:k
            meanFor_S{iEq}(t,j)=indep_nS{iEq}(t,:)*Coeff.nS_Param{iEq}+indep_S{iEq}(t,:)*Coeff.S_Param{iEq}(:,j); % mean forecast for each state
            stdFor_S{iEq}(t,j)=Std{j}(iEq); % sigma forecast for each state

        end
        
        meanFor{iEq}(1,t)=meanFor_S{iEq}(t,:)*E(t,:)'; % mean t+1 forecast
        stdFor{iEq}(1,t)=stdFor_S{iEq}(t,:)*E(t,:)';   % std t+1 forecast

    end
end


