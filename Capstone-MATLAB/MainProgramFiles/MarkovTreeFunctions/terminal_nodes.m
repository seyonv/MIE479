%This function returns a vector of all the terminal nodes
function [S_bin] = terminal_nodes(n)
	for i=0:2^n-1
		S_bin{i+1}=dec2bin(i,n);
	end
end