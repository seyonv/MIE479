% preCalc_MSModel_tvtp
%
% Modified by Zhuanxin Ding based on the original code by Marcelo Perlin to incorporate tvtp. 
%
nr=size(dep,1);
multIdx=.75;    % controls the factor for starting values of cov matrix
myFactor=1.5;   % controls how to factor each cov matrix for states

% Building bounds for parameters
% The upper and lower bound portion is not needed in the tvtp code. Zhuanxin Ding  kept the 
% structure so that it can be used in the future if necessary.

for ik=1:k
    Coeff0.covMat{ik}=cov(dep).*multIdx;    % initial parameters for cov matrix
    multIdx=multIdx*myFactor;   % for each state, factor cov matrix up
    
    % building bounds for cov matrix
    
    CoeffUpperBnd.covMat{ik}=repmat(Inf,nEq,nEq); 
    CoeffLowerBnd.covMat{ik}=repmat(-Inf,nEq,nEq);
    
    for iEq=1:nEq
        for jEq=1:nEq
            minValue=min((dep(:,iEq)-mean(dep(:,iEq))).*(dep(:,jEq)-mean(dep(:,jEq))));
            CoeffLowerBnd.covMat{ik}(iEq,jEq)=minValue; % minimum possible covariance value of i and j
            
            maxValue=max((dep(:,iEq)-mean(dep(:,iEq))).*(dep(:,jEq)-mean(dep(:,jEq))));
            CoeffUpperBnd.covMat{ik}(iEq,jEq)=maxValue; % maximum possible covariance value of i and j
        end
    end
    
end

% building size variables
%
% add comment, it seems the cell declaration here is problemetic. Matlab automatically declare a nEq by nEq cells 
% when one uses cell(nEq) while we only need nEq by 1 cells.
%
n_indep=cell(nEq,1);      % number of explanatory variables for each equation;
n_S=cell(nEq,1);          % number of switching variables for each equation;
n_nS=cell(nEq,1);         % number of non-switching variables for each equation;
count=cell(nEq,1);        % count the number of non-switching parameters for each equation;
countS=cell(nEq,1);       % count the number of switching parameters for each equation;

S_S=cell(nEq,1);          % position holder of switching parameters for each equation; 
indep_S=cell(nEq,1);      % explanatory variable vector related to switching parameters for each equation; 
S_nS=cell(nEq,1);         % position holder of non-switching parameters for each equation; 
indep_nS=cell(nEq,1);     % explanatory variable vector related to non-switching parameters for each equation; 

param0_indep_nS=cell(nEq,1);  % initial value for non-switching parameters (from OLS)
param_ols_S=cell(nEq,1);      % first round value for switching parameters (from OLS)
param0_indep_S=cell(nEq,1);   % initial value for switching parameters 

% n_indep=cell(nEq);      % number of explanatory variables for each equation;
% n_S=cell(nEq);          % number of switching variables for each equation;
% n_nS=cell(nEq);         % number of non-switching variables for each equation;
% count=cell(nEq);        % count the number of non-switching parameters for each equation;
% countS=cell(nEq);       % count the number of switching parameters for each equation;
% 
% S_S=cell(nEq);          % position holder of switching parameters for each equation; 
% indep_S=cell(nEq);      % explanatory variable vector related to switching parameters for each equation; 
% S_nS=cell(nEq);         % position holder of non-switching parameters for each equation; 
% indep_nS=cell(nEq);     % explanatory variable vector related to non-switching parameters for each equation; 
% 
% param0_indep_nS=cell(nEq);  % initial value for non-switching parameters (from OLS)
% param_ols_S=cell(nEq);      % first round value for switching parameters (from OLS)
% param0_indep_S=cell(nEq);   % initial value for switching parameters 

for iEq=1:nEq
    n_indep{iEq}=size(indep{iEq},2);
    n_S{iEq}=sum(S{iEq}(1:end-n_dist_param));
    n_nS{iEq}=n_indep{iEq}-n_S{iEq};
    count{iEq}=0;
    countS{iEq}=0;
    
    % Checking which parameters will have switching effect
    
    S_S{iEq}=zeros(1,n_S{iEq});
    indep_S{iEq}=zeros(nr,n_S{iEq});
    S_nS{iEq}=zeros(1,n_nS{iEq});
    indep_nS{iEq}=zeros(nr,n_nS{iEq});
    
    for i=1:(length(S{iEq})-n_dist_param)
        if S{iEq}(i)==1
            countS{iEq}=countS{iEq}+1;
            S_S{iEq}(countS{iEq})=i;
            indep_S{iEq}(:,countS{iEq})=indep{iEq}(:,i);
        else
            count{iEq}=count{iEq}+1;
            S_nS{iEq}(count{iEq})=i;
            indep_nS{iEq}(:,count{iEq})=indep{iEq}(:,i);
        end
    end
    
    % Calculating starting coefficients (OLS based)
    
    if n_nS{iEq}~=0
        param0_indep_nS{iEq}=regress(dep(:,iEq),indep_nS{iEq}); % simple Ols for param0 of non switching variables
    else
        param0_indep_nS{iEq}=0;
        indep_nS{iEq}=zeros(nr,1);
    end
    
    % Zhuanxin Ding comments:
    % set the parameter for different states to opposite sign (only sensible if there are 2 states). Why don't
    % set the same initial value at the begining so that the null is that there is no regime shift and later 
    % the code can try to find the optimal different solutions. The current way is very arbitrary and may
    % land us into some unwanted territory.
    % I would set this part differently if I write the code. 
    % Y=XB is the original model, create an auxillary array B_S(k,size(B)) to keep switching parameters. 
    % for non-switching parameters, us a IB matrix indicator to fix them.
    
    if n_S{iEq}~=0
        param_ols_S{iEq}=regress(dep(:,iEq),indep_S{iEq}); % simple OlS for param0 of switching variables
        
        param0_indep_S{iEq}=[];
        idx=1;
        for i=0:k-1
            param0_indep_S{iEq}(:,i+1)=idx*param_ols_S{iEq}'; % building param0 of switching variables (changing sign of coefficients)
            idx=-idx;
        end
    else
        param0_indep_S{iEq}=0;
        indep_S{iEq}=zeros(nr,1);
    end
    
    % Building the whole param0 as a structure, which will be then translated to vector notation
    
    Coeff0.nS_Param{iEq}=param0_indep_nS{iEq};
    Coeff0.S_Param{iEq}=param0_indep_S{iEq};
    
    for j=1:numel(Coeff0.nS_Param{iEq})   % building max possible values for betas
        CoeffUpperBnd.nS_Param{iEq}(j,1)=inf;
        CoeffLowerBnd.nS_Param{iEq}(j,1)=-inf;
    end
    
    for j1=1:size(Coeff0.S_Param{iEq},1)   % building max possible values for betas
        for j2=1:size(Coeff0.S_Param{iEq},2)
            CoeffUpperBnd.S_Param{iEq}(j1,j2)=inf;
            CoeffLowerBnd.S_Param{iEq}(j1,j2)=-inf;
        end
    end
   
    switch distrib

        case 't'
            Coeff0.df{iEq}=repmat(10,1,k);
            CoeffUpperBnd.df{iEq}=repmat(Inf,1,k);
            CoeffLowerBnd.df{iEq}=repmat(0.1,1,k);
        case 'GED'
            Coeff0.K{iEq}=repmat(.5,1,k);
            CoeffUpperBnd.K{iEq}=repmat(5,1,k);
            CoeffLowerBnd.K{iEq}=repmat(0.01,1,k);
    end

end
    
% set initial values for pa
    
for i=1:k-1
    for j=1:k
        Coeff0.pa{i,j}=zeros(size(px{i,j},2),1);
        if i==j
            Coeff0.pa{i,j}(1,1)=2;
        else
            Coeff0.pa{i,j}(1,1)=-2;
        end                
        CoeffUpperBnd.pa{i,j}=inf*ones(size(px{i,j},2),1);
        CoeffLowerBnd.pa{i,j}=-inf*ones(size(px{i,j},2),1);
    end
end
 
% add the following portion so that the user can pre-specify any start value he/she wants;

if isfield(advOpt,'Coeff0')==1
    if isfield(advOpt.Coeff0,'covMat')==1
        Coeff0.covMat=advOpt.Coeff0.covMat;
    end
    if isfield(advOpt.Coeff0,'nS_Param')==1
        Coeff0.nS_Param=advOpt.Coeff0.nS_Param;
    end
    if isfield(advOpt.Coeff0,'S_Param')==1
        Coeff0.S_Param=advOpt.Coeff0.S_Param;
    end
    if isfield(advOpt.Coeff0,'pa')==1
        Coeff0.pa=advOpt.Coeff0.pa;
    end
end

[Coeff_Tag,param0]=spec2param_tvtp(Coeff0);      % converting starting coefficients to vector notation
[Coeff_Tag,uB]=spec2param_tvtp(CoeffUpperBnd);   % converting upper bound to vector notation
[Coeff_Tag,lB]=spec2param_tvtp(CoeffLowerBnd);   % converting lower bound to vector notation

% procedures for adjusting parameter vector (for estimated/non estimated coefficients)

% building a new tag structure for the coefficients

for ik=1:k
    newCoeff_Tag.covMat{ik}=zeros(size(Coeff_Tag.covMat{ik}));
end
    
for iEq=1:nEq
    newCoeff_Tag.nS_Param{iEq}=zeros(size(Coeff_Tag.nS_Param{iEq}));
    newCoeff_Tag.S_Param{iEq}=zeros(size(Coeff_Tag.S_Param{iEq}));
    
    switch distrib
        case 't'
            newCoeff_Tag.df{iEq}=zeros(size(Coeff_Tag.df{iEq}));
        case 'GED'
            newCoeff_Tag.K{iEq}=zeros(size(Coeff_Tag.K{iEq}));
    end
end
    
for i=1:k-1
    for j=1:k
        newCoeff_Tag.pa{i,j}=zeros(size(Coeff_Tag.pa{i,j}));
    end
end

% calculating new tags

idxVec=zeros(0);
count_e=1;
count_ne=1;

for ik=1:k
    for i=1:nEq
        for j=1:nEq
            if ~(isnumeric(constCoeff.covMat{ik}{i,j}))
                newCoeff_Tag.covMat{ik}(i,j)=count_e;
                count_e=count_e+1;
            else
                idxVec(count_ne)=Coeff_Tag.covMat{ik}(i,j);
                count_ne=count_ne+1;
            end
        end
    end
end

for iEq=1:nEq
    for i=1:numel(Coeff0.nS_Param{iEq})
        if ~(isnumeric(constCoeff.nS_Param{iEq}{i}))
            newCoeff_Tag.nS_Param{iEq}(i,1)=count_e;
            count_e=count_e+1;
        else
            idxVec(count_ne)=Coeff_Tag.nS_Param{iEq}(i);
            count_ne=count_ne+1;
        end
    end
end

for iEq=1:nEq
    for i=1:size(Coeff0.S_Param{iEq},1)
        for j=1:size(Coeff0.S_Param{iEq},2)
            if ~(isnumeric(constCoeff.S_Param{iEq}{i,j}))
                newCoeff_Tag.S_Param{iEq}(i,j)=count_e;
                count_e=count_e+1;
            else
                idxVec(count_ne)=Coeff_Tag.S_Param{iEq}(i,j);
                count_ne=count_ne+1;
            end
        end
    end
end

for iEq=1:nEq
    switch distrib
        case 't'
            for i=1:size(Coeff0.df{iEq},2)
                if ~(isnumeric(constCoeff.df{iEq}{i}))
                    newCoeff_Tag.df{iEq}(i)=count_e;
                    count_e=count_e+1;
                else
                    idxVec(count_ne)=Coeff_Tag.df{iEq}(i);
                    count_ne=count_ne+1;
                end
            end

        case 'GED'
            for i=1:size(Coeff0.K{iEq},2)
                if ~(isnumeric(constCoeff.K{iEq}{i}))
                    newCoeff_Tag.K{iEq}(i)=count_e;
                    count_e=count_e+1;
                else
                    idxVec(count_ne)=Coeff_Tag.K{iEq}(i);
                    count_ne=count_ne+1;
                end
            end
    end
end    

for i=1:k-1
    for j=1:k
        for kk=1:size(Coeff0.pa{i,j},1)
            if ~(isnumeric(constCoeff.pa{i,j}{kk,1}))
                newCoeff_Tag.pa{i,j}(kk)=count_e;
                count_e=count_e+1;
            else
                idxVec(count_ne)=Coeff_Tag.pa{i,j}(kk);
                count_ne=count_ne+1;
            end
        end        
    end
end

% Cleaning values in vectors that won't be estimated

param0(idxVec)=[];
lB(idxVec)=[];
uB(idxVec)=[];

Coeff_Tag=newCoeff_Tag;
advOpt.Coeff_Tag=Coeff_Tag;