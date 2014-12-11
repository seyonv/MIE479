% spec2param_tvtp, function for converting form
%
% Modified by Zhuanxin Ding based on the original code by Marcelo Perlin to incorporate tvtp. 
%

function [Spec_Tag,out_param]=spec2param_tvtp(Spec)

Fields=fieldnames(Spec);
nField=length(Fields);

count=0;
for n=1:nField
    
    if ~iscell(eval(['Spec.',Fields{n}]))
        
        str=['Spec.',Fields{n}];
        [nr,nc]=size(eval(str));
        
        if (nr==0)
            eval(['Spec_Tag.',Fields{n}, '{' num2str(iEq) '}','={};']);
        end
        
        for i=1:nr
            for j=1:nc
                count=count+1;
                out_param(count)=eval([str,'(',num2str(i),',',num2str(j),')']);
                eval(['Spec_Tag.',Fields{n},'(',num2str(i),',',num2str(j),')','=',num2str(count) ';']);
            end
        end
        
    else
                
        str=['Spec.',Fields{n},'{irCell,icCell}' ];
        [nrCell,ncCell]=size(eval(['Spec.',Fields{n}]));
        
        for irCell=1:nrCell
        for icCell=1:ncCell
            
            [nr,nc]=size(eval(str));
            
            if (nr==0)
                eval(['Spec_Tag.',Fields{n}, '{' num2str(irCell) ',' num2str(icCell) '}','={};']);
            end
            
            for i=1:nr
                for j=1:nc
                    count=count+1;
                    out_param(count)=eval([str,'(',num2str(i),',',num2str(j),')']);
                    eval(['Spec_Tag.',Fields{n},'{' num2str(irCell) ',' num2str(icCell) '}','(',num2str(i),',',num2str(j),')','=',num2str(count) ';']);
                end
            end
            
        end
        end
        
    end
end

