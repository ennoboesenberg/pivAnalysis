function [addnum] = numberSTH(svDir)

A = 0;

[datasetpath,~,~]	= fileparts(cd);                                       	% find full path of current directory
num2find            = regexp(datasetpath,'\d*','Match');                    % finds all numbers in foldername
if isempty(num2find)
    num2find        = {'1', '1'};
end

name2find           = num2find{end-1};                                    	% extract number of measurement
nameinquest         = ['*' name2find '*'];                                 	% make searchable string
file_list           = dir(fullfile(svDir, nameinquest));                   	% find old files
[atten, ~]          = size(file_list);                                      % number of old files
if atten == 0
    addnum          = name2find;                                            % add new measurement
else
    for aa = 1:atten                                                        % list names of old measurements
        a           = file_list(aa).name;
        b{aa}       = a;
    end
    c               = unique(b,'sorted');                                   % list names of unique old measurements
    c_char          = char(c);
    [c_index]       = cell2mat(strfind(c,name2find));
    
    [~, sizeofc]	= size(c);
    for bb = 1:sizeofc
        B           = sscanf(c_char(bb,c_index(bb)+length(name2find):end),...
                        strcat('_',"%d",'_',"%d",'.mp4'));                 	% scan for numbers in old file names
        if B > A                                                            % find highest number and therefore latest files
            A       = B;
        end
    end

    addnum          = [name2find '_' num2str(A+1)];                         % return what end of new file name should look like
end
end