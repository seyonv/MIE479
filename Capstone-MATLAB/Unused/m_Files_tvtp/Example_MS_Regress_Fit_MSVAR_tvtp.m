% Example Script MS_Regress_Fit.m - MS-VAR estimation

clear;

% addpath('m_Files'); % add 'm_Files' folder to the search path
% addpath('data_Files');

logRet=importdata('Example_Fex.txt');  % load some Data.

dep=logRet(:,1);                    % Defining dependent variable from .mat file
constVec=ones(length(dep),1);       % Defining a constant vector in mean equation (just an example of how to do it)
px=[constVec logRet(:,2:3)];


nLag=2;                             % Number of lags in system
k=3;                                % Number of States
doIntercept=1;                      % add intercept to equations?
advOpt.distrib='Normal';            % The Distribution assumption (only 'Normal' for MS VAR models)
advOpt.std_method=1;                % Defining the method for calculation of standard errors. See pdf file for more details

[Spec_Out]=MS_VAR_Fit_tvtp(dep,nLag,px,k,doIntercept,advOpt);

rmpath('m_Files');
rmpath('data_Files'); 