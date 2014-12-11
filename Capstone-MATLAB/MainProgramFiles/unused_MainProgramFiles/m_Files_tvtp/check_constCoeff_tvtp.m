% check_constCoeff_tvtp;
%
% Modified by Zhuanxin Ding based on the original code by Marcelo Perlin to incorporate tvtp. 
%

if any([~isfield(advOpt.constCoeff,'nS_Param'), ...
        ~isfield(advOpt.constCoeff,'S_Param') , ...
        ~isfield(advOpt.constCoeff,'covMat')  , ...
        ~isfield(advOpt.constCoeff,'pa') ])
    str=sprintf(['In the construction of constCoeff, its missing one (or more) of the fields:\n' ...
        'nS_param\n','S_Param\n','Std\n','pa\n','See Example files (and pdf) for details of how to use advOpt.constCoeff']);
    error(str);
end

if any([~iscell(advOpt.constCoeff.nS_Param) , ...
        ~iscell(advOpt.constCoeff.S_Param)  , ...
        ~iscell(advOpt.constCoeff.covMat)   , ...
        ~iscell(advOpt.constCoeff.pa)])
    str=sprintf(['In the construction of constCoeff, all members should be cell arrays ' ...
        'with number of elements equal to the number of equations in system (see example files']);
    error(str);
end

switch distrib
    case 't'
        if ~isfield(advOpt.constCoeff,'df')
            error('In argument advOpt.constCoeff, its missing the parameter df for the t distribution')
        end
        
    case 'GED'
        if ~isfield(advOpt.constCoeff,'K')
            error('In argument advOpt.constCoeff, its missing the parameter K for the GED distribution')
        end
end

