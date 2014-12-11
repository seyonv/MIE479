%input parameters are # of states, smoothingprobabilities,and no. of time periods
%THe function returns a matrix of the resulting regime for each period
%and counts the total type of each regime for the historical inflation data

%The regime associated with each time is ultimately the greater of the two 
% probabilities of that time period belonging to that regime
function [whichregime, countregime] = ...
		regimecount(k,smoothProb,timelength)


	
	%NOte that the size of Spec_Out.filtProb is (# of time periods) x (# of states)
	%IMPORTANT: NOTE THAT IT Is likely to change .filtProb to .smoothProb
	for i=1:length(smoothProb(1,:))
		r_prob(:,i)=smoothProb(:,i);
	end


	%initializes countregime matrix of size k(no. of states)
	countregime=zeros(1,k); 

	for i=1:timelength
		if (k==3)
			if (r_prob(i,1)>=r_prob(i,2) && r_prob(i,1)>=r_prob(i,3))
				whichregime(i)=1;
				countregime(1)=countregime(1)+1;
			elseif (r_prob(i,2)>=r_prob(i,1) && r_prob(i,2)>=r_prob(i,3))
				whichregime(i)=2;
				countregime(2)=countregime(2)+1;
			else
				whichregime(i)=3;
				countregime(3)=countregime(3)+1;
			end
		elseif (k==2)
			if (r_prob(i,1)>=r_prob(i,2))
				whichregime(i)=1;
				countregime(1)=countregime(1)+1;
			else
				whichregime(i)=2;
				countregime(2)=countregime(2)+1;
			end
		end
	end

end