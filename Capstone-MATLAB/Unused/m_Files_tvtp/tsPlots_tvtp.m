% tsPlots_tvtp
% developed by Zhuanxin Ding to plot time series tvtp charts;
%
% Plotting time varying probabilities

for i=1:k-1
    States{i}=['State ',num2str(i),' Expected'];
    States{k-1+i}=['State ',num2str(i),' Smoothed'];
end

for i=1:nEq
%         myMeanLeg{i}=['Dependent Variable #' num2str(i)];
%         myStdLeg{i}=['Conditional Std #' num2str(i)];
        myMeanLeg{i}=['Dep #' num2str(i)];
        myStdLeg{i}=['Cond Std #' num2str(i)];
end

for i=1:nEq
%         myMeanLeg{nEq+i}=['Conditional Mean #' num2str(i)];
        myMeanLeg{nEq+i}=['Cond Mean #' num2str(i)];
end

% figurecount = length(findobj('Type','figure'));
% figure(figurecount+1);

figure

subplot(3,1,1)
tsdep=timeseries([dep Spec_Output.condMean zeros(length(dep),1)],advOpt.YYYYMM);
tsdep.TimeInfo.Format = 'yyyymm';     
plot(tsdep);
xlabel('');
ylabel(upper(char(advOpt.fName)),'Interpreter','none');
legend(myMeanLeg,'Interpreter','none');

if isfield(advOpt,'mName')==1
    title([upper(char(advOpt.fName)) ' using macro variable ' upper(char(advOpt.mName))],'Interpreter','none');
else
    title([upper(char(advOpt.fName))],'Interpreter','none');
end

subplot(3,1,2);
tsStd=timeseries(Spec_Output.condStd,advOpt.YYYYMM);
tsStd.TimeInfo.Format = 'yyyymm';     
plot(tsStd);
xlabel('');
ylabel('Conditional Std');
legend(myStdLeg);
title('');

subplot(3,1,3);
tsProb=timeseries([Spec_Output.filtProb(:,1:k-1) Spec_Output.smoothProb(:,1:k-1)],advOpt.YYYYMM);
tsProb.TimeInfo.Format = 'yyyymm';     
plot(tsProb);
ylim([0 1]);
xlabel('');
ylabel('States Probabilities');
legend(States);
title('');

