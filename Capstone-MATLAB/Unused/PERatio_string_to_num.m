function [ PE_ratio ] = PERatio_string_to_num(PE_ratio_string)
	disp(PE_ratio_string);
	if isnan(PE_ratio_string)
		PE_ratio='NaN';
    else
       PE_ratio = PE_ratio_string;
    end
end
