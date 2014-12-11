% Example Script MS_Regress_Fit.m

clear;

% addpath('m_Files'); % add 'm_Files' folder to the search path
% addpath('data_Files');

logRet=importdata('Example_Fex.txt');  % load some Data.

dep=logRet(:,1);                    % Defining dependent variable from .mat file
constVec=ones(length(dep),1);       % Defining a constant vector in mean equation (just an example of how to do it)
indep=[constVec logRet(:,2:3)];     % Defining some explanatory variables
% indep=[constVec];                   % Defining some explanatory variables
px=[constVec logRet(:,3)];
% px=constVec;

k=2;                                % Number of States
S=[1 0 0 1 0];                        % Defining which parts of the equation will switch states (column 1 and variance only)
% S=[1 1];                        % Defining which parts of the equation will switch states (column 1 and variance only)
advOpt.distrib='t';            % The Distribution assumption ('Normal', 't' or 'GED')
advOpt.optimizer='fminunc';
% advOpt.std_method=1;                % Defining the method for calculation of standard errors. See pdf file for more details
advOpt.std_method=2;                % Defining the method for calculation of standard errors. See pdf file for more details
advOpt.doPlots=1;

% advOpt.constCoeff0.covMat{1}(1,1)={'e'};
% advOpt.constCoeff0.covMat{2}(1,1)={'e'};
% advOpt.constCoeff0.nS_Param{1}={0};
% advOpt.constCoeff0.S_Param{1}={'e','e'};
% advOpt.constCoeff0.pa{1,1}={2.357;'e'};
% advOpt.constCoeff0.pa{1,2}={-1;'e'};
% 
% advOpt.Coeff0.pa{1,1}=[0.9; 0.1];
% advOpt.Coeff0.pa{1,2}=[-0.7; 0.1];


[Spec_Out]=MS_Regress_Fit_tvtp(dep,indep,px,k,S,advOpt); % Estimating the model

rmpath('m_Files');
rmpath('data_Files'); 