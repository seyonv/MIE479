% Example Script MS_Regress_Fit.m - MS-VAR estimation

clear;

addpath('m_Files'); % add 'm_Files' folder to the search path
addpath('data_Files');

logRet=importdata('Example_Fex.txt');  % load some Data.

dep=logRet(:,1:2);                  % Defining dependent variables in system (solving for two dependent variables)
nLag=1;                             % Number of lags in system
k=2;                                % Number of States
doIntercept=1;                      % add intercept to equations?
%%
advOpt.diagCovMat=0					%if this value is 1, then only the elements on the diagonal(the variances) are estimated
%%
advOpt.distrib='Normal';            % The Distribution assumption (only 'Normal' for MS VAR models) )this is the default avlue
advOpt.std_method=1;                % Defining the method for calculation of standard errors. See pdf file for more details

[Spec_Out]=MS_VAR_Fit(dep,nLag,k,doIntercept,advOpt);

rmpath('m_Files');
rmpath('data_Files'); 