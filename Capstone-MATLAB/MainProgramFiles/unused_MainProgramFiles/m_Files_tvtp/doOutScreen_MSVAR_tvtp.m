% doOutScreen_MSVAR_tvtp
%
% Modified by Zhuanxin Ding based on the original code by Marcelo Perlin to incorporate tvtp. 
%
nr=size(dep,1);
param=Spec_Output.param;

fprintf(1,'\n\n***** Numerical Optimization Converged *****\n\n');
fprintf(1,['Final log Likelihood: ',num2str(Spec_Output.LL),'\n']);
fprintf(1,['Number of estimated parameters: ',num2str(Spec_Output.Number_Parameters),'\n']);
fprintf(1,['Number of Equations in System: ',num2str(nEq),'\n']);
fprintf(1,['Distribution Assumption -> ',Spec_Output.advOpt.distrib,'\n']);
fprintf(1,['Standard error calculation -> ',num2str(Spec_Output.advOpt.std_method) '\n']);

for iEq=1:nEq
    fprintf(1,['\n***** Final Parameters for Equation #' num2str(iEq) ' ***** \n\n']);
    
    if intercept    % display intercept
        fprintf(1,[blanks(5) 'Intercept - Parameter Value (Standard Error, p value)\n']);
        
        for ik=1:k
            seValue=Spec_Output.Coeff_SE.S_Param{iEq}(1,ik);
            pValue=2*(1-tcdf(abs(Spec_Output.Coeff.S_Param{iEq}(1,ik))/seValue,size(dep,1)-numel(Spec_Output.param)));
            fprintf(1,[blanks(10) 'State %i, Intercept = %4.2f (%4.2f,%4.2f) \n'],ik,Spec_Output.Coeff.S_Param{iEq}(1,ik),seValue,pValue);
        end
    end
    
    myCounter=intercept+1;
    for jEq=1:nEq
        fprintf(1,[blanks(5) 'Dependent Variable #%i - Parameter Value (Standard Error, p value)\n'],jEq);
        
        for iLag=1:nLag
            for ik=1:k
                seValue=Spec_Output.Coeff_SE.S_Param{iEq}(myCounter,ik);
                pValue=2*(1-tcdf(abs(Spec_Output.Coeff.S_Param{iEq}(myCounter,ik))/seValue,size(dep,1)-numel(Spec_Output.param)));
                fprintf(1,[blanks(10) 'State %i, Lag %i = %4.2f (%4.2f,%4.2f) \n'],ik,iLag,Spec_Output.Coeff.S_Param{iEq}(myCounter,ik),seValue,pValue);
                
            end
            myCounter=myCounter+1;
        end
    end
    
end

fprintf(1,'\n\n---> Time Varying Transition Probabilities Matrix Estimation (std. error, p-value) <---');
pValue_pa=cell(k-1,k);
for i=1:k-1
    for j=1:k
        fprintf(1,'\n      ');
        fprintf(1,['\npa{', num2str(i),',', num2str(j),'}']);
        pValue_pa{i,j}=2*(1-tcdf(abs(Spec_Output.Coeff.pa{i,j})./Spec_Output.Coeff_SE.pa{i,j},nr-numel(param)));
        for kk=1:size(Spec_Output.Coeff.pa{i,j},1) 
            fprintf(1,['\n   pa{', num2str(i),',', num2str(j),'}(',num2str(kk),')']);
            fprintf(1,['\n   Value:                ', num2str(Spec_Output.Coeff.pa{i,j}(kk),'%4.6f')]);
            fprintf(1,['\n   Std Error (p. value): ', num2str(Spec_Output.Coeff_SE.pa{i,j}(kk),'%4.6f'),' (',num2str(pValue_pa{i,j}(kk),'%4.4f'),')']);
        end
    end
end

fprintf(1,'\n\n---> Expected Duration of Regimes <---\n\n');

for i=1:k
    fprintf(1,['     ' 'Expected duration of Regime #%i: %4.2f time periods\n'],i,Spec_Output.stateDur(i));
end

fprintf(1,'\n---> Covariance Matrix <---\n');
for ik=1:k
    fprintf(1,['\nState ', num2str(ik)]);
    pValue_covMat=2*(1-tcdf(abs(Spec_Output.Coeff.covMat{ik})./Spec_Output.Coeff_SE.covMat{ik},nr-numel(param)));
    
    for iEq=1:nEq
        fprintf(1,'\n      ');
        for jEq=1:nEq
            fprintf(1,'%4.5f (%4.5f,%4.2f)   ',Spec_Output.Coeff.covMat{ik}(iEq,jEq),Spec_Output.Coeff_SE.covMat{ik}(iEq,jEq),pValue_covMat(iEq,jEq));
        end
    end
end

disp(' ');