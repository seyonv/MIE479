function [market_cap]= marketcap_string_to_num(market_cap_string);

	
	disp(market_cap_string);
	if (market_cap_string(1) =='N')
		market_cap='NaN';
	else
		temp='';
		for i=1:length(market_cap_string)
			if (market_cap_string(i)=='M')
				temp=strcat(temp,repmat('0',1,6-(i-dot_position-1)));
			elseif (market_cap_string(i)=='B')
				temp=strcat(temp,repmat('0',1,9-(i-dot_position-1)));
			elseif (market_cap_string(i)=='.')
				dot_position=i;
			else
				temp=strcat(temp,market_cap_string(i));
			end
		end
		market_cap=str2num(temp);
	end
end

%{
%1.3M - >1300000
%1.345M ->1 345 000

%10.345M
current position = 6
mill = 6

%12.34M - > 12 340 000  [6-(6-3-1)]

start with 1.2345M

this needs to become 1234500

1.23

6/9-(curr_position-dot_position-1)
%}