% checkInputs_tvtp;  Error checking lines.
%
% Modified by Zhuanxin Ding based on the original code by Marcelo Perlin to incorporate tvtp. 
%

if nargin<5
    error('The function needs at least 5 arguments');
end

if nargin==5    % Default values when advOpt is not an input
    advOpt.distrib='Normal';
    advOpt.optimizer='fmincon';
    advOpt.std_method=1;
    advOpt.useMex=0;
    advOpt.diagCovMat=1;
    advOpt.printOut=1;
    advOpt.printIter=1;
    advOpt.doPlots=1;

else    % checking inputs of advOpt
    
    if isfield(advOpt,'distrib')==0
        advOpt.distrib='Normal';
    end

    if isfield(advOpt,'optimizer')==0
        advOpt.optimizer='fmincon';
    end

    if isfield(advOpt,'printOut')==0
        advOpt.printOut=1;
    end

    if isfield(advOpt,'printIter')==0
        advOpt.printIter=1;
    end

    if isfield(advOpt,'doPlots')==0
        advOpt.doPlots=1;
    end

    if isfield(advOpt,'std_method')==0
        advOpt.std_method=1;
    end
       
    if isfield(advOpt,'diagCovMat')==0
        advOpt.diagCovMat=1;
    end

    if isfield(advOpt,'useMex')==0
        advOpt.useMex=0;
    end
    
end

% copying some values for easier handling

distrib=advOpt.distrib;
std_method=advOpt.std_method;
useMex=advOpt.useMex;

if useMex~=1&&useMex~=0
    error('The input advOpt.useMex only take values 1 or 0');
end

% options 3 and 4 excluded (until equations are verified)

% if ~any(std_method==[1 2 3 4])
%     error('The input advOpt.std_method should be 1, 2, 3 or 4, only.');
% end

if ~any(std_method==[1 2])
    error('The input advOpt.std_method should be 1, 2, only.');
end

if strcmp(distrib,'Normal')==0&&strcmp(distrib,'t')==0&&strcmp(distrib,'GED')==0
    error('The distrib input should be ''Normal'', ''t'' or ''GED''');
end

nEq=size(dep,2);

if iscell(dep)
    dep=cell2mat(dep);
end

if ~iscell(indep)
    temp=indep;
    clear indep;
    for iEq=1:nEq
        indep{iEq}=temp;
    end
end

% Zhuanxin Ding Comments:
% put explanatory variables for each equation separately. This can be
% inconvenient for coding purpose. But if the dep-indep relationship is
% specific for each equation then this cell setting is fine. 
%
% The transition probability can depend on different state variables;
%
if ~iscell(px)
    temp=px;
    clear px;
    for i=1:k-1
        for j=1:k
            px{i,j}=temp;
        end
    end
end

% The switch indicator can also be different for each equation.

if ~iscell(S)
    temp=S;
    clear S;
    for iEq=1:nEq
        S{iEq}=temp;
    end
end

if size(dep,2)>1    % flag for multivariate switching model
    mvFlag=1;
else
    mvFlag=0;
end

if mvFlag
    if ~strcmp('Normal',distrib)
        error('So far, in the multivariate version (size(dep,2)>1), the package only handles the multivariate normal distribution. Please set advOpt.distrib=''Normal''.')
    end

    if numel(indep)~=nEq
        error('For a multivariate model, the size of cell indep should match the number of columns in dep.')
    end

    if numel(S)~=nEq
        error('For a multivariate model, the size of cell S should match the number of columns in dep.')
    end
end

% add comment
% multivariate t should be easily added

for iEq=1:nEq
    switch distrib
        case 'Normal'
            n_dist_param=1;             % Number of distributional parameters
            S_Var{iEq}=S{iEq}(end);     % if model switches in variance
            S_df{iEq}=0;                % flag for S_df (NOT USED, keep for simplicity of algorithm)
            S_K{iEq}=0;                 % flag for S_K (NOT USED, keep for simplicity of algorithm)
        case 't'
            S_Var{iEq}=S{iEq}(end-1);   % if model switches in variance
            S_df{iEq}=S{iEq}(end);      % if model is switching in degrees of freedom
            S_K{iEq}=0;
            n_dist_param=2;             % Number of distributional parameters
        case 'GED'
            S_Var{iEq}=S{iEq}(end-1);
            S_K{iEq}=S{iEq}(end);       % if model is switching in K parameter (K as the GED parameter)
            S_df{iEq}=0;
            n_dist_param=2;             % Number of distributional parameters
    end
end

if ~any([numel(indep)==nEq numel(S)==nEq])
    error('The number of elements in cell arrays indep and S should equal to the number of columns in dep.')
end

if k<2
    error('k should be an integer higher than 1. If you trying to do a linear regression, check Matlab statistical toolbox.') ;
end

for i=1:nEq
    
    if any(isnan(dep))
        [idx1 idx2]=find(isnan(dep));
        error(sprintf('NaN values found for row #%i, column #%i of dep matrix.\n',idx1(1),idx2(1)));
    end
    
    if any(isinf(dep))
        [idx1 idx2]=find(isinf(dep));
        error(sprintf('Inf values found for row #%i, column #%i of dep matrix.',idx1(1),idx2(1)));
    end
       
    if any(isnan(indep{i}))
        [idx1 idx2]=find(isnan(indep{i}));
        error(sprintf('NaN values found for row #%i, column #%i of indep matrix %i.',idx1(1),idx2(1),i));
    end
    
    if any(isinf(indep{i}))
        [idx1 idx2]=find(isinf(indep{i}));
        error(sprintf('Inf values found for row #%i, column #%i of indep matrix %i.',idx1(1),idx2(1),i));
    end
    
    if size(indep{i},1)~=size(dep,1)
        error('The number of rows in any cell in indep should be equal to the number of rows in dep.')
    end

    if (size(S{i},2))~=(size(indep{i},2)+n_dist_param)
        error('The number of elements in any cell in S should be equal to the number of elements in S, plus one (the variance flag). Check pdf manual for details.')
    end

    if sum((S{i}==0)+(S{i}==1))~=size(S{i},2)
        error('The S input should have only 1 and 0 values (those tell the function where to place markov switching effects)') ;
    end

    if sum(S{i})==0
        error('The S input should have at least one value 1 in each equation (something must switch states).') ;
    end
end
%
% The following code tries to check if there are any NaN or Inf number in the regime state variables;
%
for i=1:k-1
    for j=1:k
        
        if any(isnan(px{i,j}))
            [idx1 idx2]=find(isnan(px{i,j}));
            error(sprintf('NaN values found for row #%i, column #%i of px{%i,%i}.',idx1(1),idx2(1),i,j));
        end
        
        if any(isinf(px{i,j}))
            [idx1 idx2]=find(isinf(px{i,j}));
            error(sprintf('Inf values found for row #%i, column #%i of px{%i,%i}.',idx1(1),idx2(1),i,j));
        end
        
    end
end
% 
