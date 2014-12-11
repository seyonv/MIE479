% This function applies the closed form equation to compute the terminal
% value associated with each node in the markov tree for expected inflation
% This equation is simply the result of recursion(due to the autoregressive term)
% and is unique for each node.
function [tnodeval] = terminal_inflation(n,tnodes,c1,c2,ar1,ar2,y0)

	%{
	a0=c1;
	a1=c2;
	b0=ar1;
	b1=ar2;
    beta1 and beta2 represent the betas for regime 1 and 2
	%}
	a=[c1 c2];
	b=[ar1 ar2];
 
	%iterates over each terminal node
	tnodeval = [];
	for i=1:2^n
		cnode=tnodes{i};
		cnodeval = 0;
		%For a given terminal node, iterates over each time step
		for j=n:-1:1
			%period=n-j+1;
			 if (j==n)
			% 	disp('Value of a() is');
			% 	a(str2num(cnode(n))+1)
				cnodeval = cnodeval + a(str2num(cnode(n))+1);
			else
				ind_j=str2num(cnode(j))+1;
				currprod=a(ind_j);

				% over number of terms for a given time step
				for k = j+1:n;
					% disp('Value of a() is');
					% a(str2num(cnode(n))+1)
					ind_k=str2num(cnode(k))+1;
					currprod = currprod*b(ind_k);
				end
				cnodeval=cnodeval+currprod;
			end
			if (j==1)
				currprod=1;
				for k= 1:n
					ind_k=str2num(cnode(k))+1;
					currprod=currprod*b(ind_k);
				end
				cnodeval=cnodeval+currprod*y0;
			end
        end
        tnodeval(i)=cnodeval;
    end

end