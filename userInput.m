function [numoim, avgrange, avgtype, numooper, sample_pic, reference_pic,...
    filetypeindex, startim] = userInput(refDir, verify_refDir, formatFile)

file_list                       =	dir(fullfile(cd, '*B*.vc7'));
date_info                       =   file_list(1).date;
switch date_info(4:6)
    case 'Mrz'
        date_info(4:6) = 'Mar';
    case 'Mai'
        date_info(4:6) = 'May';
    case 'Okt'
        date_info(4:6) = 'Oct';
    case 'Dez'
        date_info(4:6) = 'Dec';
end
        
date_info_format                =   datestr(date_info, 29);

switch date_info(4:6)
    case 'Mar'
        date_info(4:6) = 'Mrz';
    case 'May'
        date_info(4:6) = 'Mai';
    case 'Oct'
        date_info(4:6) = 'Okt';
    case 'Dec'
        date_info(4:6) = 'Dez';
end

[numofiles, ~] = size(file_list);

%% Aquiring starting image

verificator                     =   0;
while verificator == 0
    prompt                      =	'   Enter number of starting image: ';
    wateysay                    =	input(prompt,'s');

    verificator                 =   all(ismember(wateysay,...
                                        '0123456789'));                     % is user input within resonable boundaries
end

if isempty(wateysay) || str2double(wateysay) >= numofiles
    startim                  	=	1;
else
    startim                  	=	str2double(wateysay);
end

%% Aquiring processing range

verificator                     =   0;
while verificator == 0
    prompt                      =	'   Enter number of image you wish to analyse: ';
    wateysay                    =	input(prompt,'s');

    if isempty(wateysay)
        wateysay                =	'1420';
    end
    
    verificator                 =   all(ismember(wateysay,...
                                        '0123456789al'));                   % is user input within resonable boundaries
  	if verificator == 1 && numofiles < str2double(wateysay) + startim - 1
        verificator             =	0;
        fprintf('\n   That is EXCEEDING the NUMBER OF FILES by: %d\n\n', str2double(wateysay) + startim - numofiles);
    end
end

if strncmpi(wateysay,'all',1) || str2double(wateysay) >= numofiles
    numoim                      =	numofiles;
else
    numoim                  	=	str2double(wateysay) + startim - 1;
    if numoim > numofiles
        numoim                  =	numofiles;
    end
end

%% Aquiring averaging type

numooper = 1;

verificator                     =   0;
while verificator == 0
    prompt                      =   'Type of averaging (non, all, AF, STD, RMS): ';
    wateysay                    =   input(prompt,'s');

    verificator                 =   all(ismember(wateysay,...
                                        '0123456789+-.alnofrms'));          % is user input within resonable boundaries
end

if isempty(wateysay) || strncmpi(wateysay,'n',1) || str2double(wateysay) == 0
    avgtype                  	=	'non';
elseif strncmpi(wateysay,'all',2) || str2double(wateysay) > 3
    avgtype                  	=	'all';
    numooper = 3;
elseif strncmpi(wateysay,'AF',2) || str2double(wateysay) == 1
    avgtype                  	=	'AF';
elseif strncmpi(wateysay,'RMS',2) || str2double(wateysay) == 2
    avgtype                  	=	'RMS';
elseif strncmpi(wateysay,'STD',2) || str2double(wateysay) == 3
    avgtype                  	=	'STD';
end

%% Aquiring averaging range

verificator                     =   0;
while verificator == 0
    prompt                      =   'Number of images to average over (default is 4): ';
    wateysay                    =   input(prompt,'s');
    if isempty(wateysay)
        wateysay               	=	'4';
    end
    verificator                 =   all(ismember(wateysay, '0123456789'));	% is user input within resonable boundaries

    if verificator == 1                                                     % checks if number of files can be divided by avraging number without remainder
        divider                 =	mod(numoim-startim+1, str2double(wateysay));
        if  divider == 0
            verificator         =	1;
        else
            verificator         =	0;
            fprintf('\n"NUMBER OF IMAGES" must be divisible without remainder\n by number of "IMAGES TO AVERAGE OVER".\n');
        end
    end
end


if strncmpi(wateysay,'all',1) || str2double(wateysay) >= numofiles
    avgrange                  	=	numofiles;
else
    avgrange                  	=	str2double(wateysay);
end

%% Find reference picture

mydir       = cd;                                                           % keeping old directory to return to

if strcmp(refDir, verify_refDir)
    cd(refDir)
    file_list   = dir(fullfile(cd));                                      	% listing files from reference directory
    numofile    = size(file_list);
    for aa = 1:numofile                                                         
        a             	=	file_list(aa).date;
        b{aa}         	=	a;
    end
    c                 	=	char(unique(b,'sorted'));                       % finding unique dates in folder

    fprintf('The following measurement dates were found:\n\n');
    for aa = 1:size(c)
        fprintf('%s \n', c(aa,:));                                        	% listing measurementdates
    end
    fprintf('Recommended (and default): %s\n', date_info);

	fileEnding        	=	formatFile;
    filetypeindex     	=   1;

    verificator       	=   0;
    while verificator == 0
        prompt         	=   '\nYear of measurement (e.g. 08): ';
        ang_yea        	=   input(prompt,'s');
        
        if isempty(ang_yea)
            ang_yea   	=	date_info_format(3:4);
        end
        verificator    	=   all(ismember(ang_yea, '0123456789+- '));        % is user input within resonable boundaries
    end

    verificator       	=	0;
    while verificator == 0
        prompt        	=   'Month of measurement (e.g. 08): ';
        ang_mon       	=   input(prompt,'s');
        
      	if isempty(ang_mon)
            ang_mon    	=	date_info_format(6:7);
        end
        verificator    	=   all(ismember(ang_mon, '0123456789+- '));        % is user input within resonable boundaries
    end

    verificator       	=   0;
    while verificator == 0
        prompt         	=   'Day of measurement (e.g. 08): ';
        ang_day       	=   input(prompt,'s');
        
       	if isempty(ang_day)
            ang_day    	=	date_info_format(9:10);
        end
        verificator   	=   all(ismember(ang_day, '0123456789+- '));        % is user input within resonable boundaries
    end
    
    nam                	=	['.\*' ang_yea ang_mon ang_day '_Time=*'];

  	findIm            	=	dir(fullfile(cd, nam, ['*B*' fileEnding]));     % ['E:\Enno_DU95W180_Mono\Live images\Live Image Date=180818_Time=175121'];
                                    
else
    cd(mydir)
    
	file_list   = dir(fullfile(cd));                                      	% listing files from reference directory
    numofile    = size(file_list);
    for aa = 1:numofile                                                         
        a             	=	file_list(aa).date;
        b{aa}         	=	a;
    end
    c                 	=	char(unique(b,'sorted'));                       % finding unique dates in folder

    fprintf('The following measurement dates were found:\n\n');
    for aa = 1:size(c)
        fprintf('%s \n', c(aa,:));                                        	% listing measurementdates
    end
    fprintf('Recommended (and default): %s\n', date_info);
    
    verificator        	=   0;
    while verificator == 0
        prompt         	=   '\n Select reference measurement (default is 1st): ';
        refimn       	=   input(prompt,'s');
        
        if isempty(refimn)
            xx          =   struct2cell(file_list);
            [~, refimn] =  find(string(xx) == date_info);
            refimn      = num2str(refimn(1));
        end
        verificator    	=   all(ismember(refimn, '0123456789+- '));       % is user input within resonable boundaries
    end
	refimn            =   str2double(refimn);
    
    filetypeindex     	=   0;
    
    findIm            	=	dir(fullfile(cd, file_list(refimn).name));  	% ['E:\Enno_DU95W180_Mono\Live images\Live Image Date=180818_Time=175121'];
end

cd(findIm(1).folder)
sample_pic            	=	loadvec(findIm(1).name);                        % loading samplepicture to define a mask from

cd(mydir)
file_list              	=	dir(fullfile(cd,'*.vc7'));
[chosen_file, ~]        =   size(file_list);
findrefIm           	=	dir(fullfile(cd, file_list(chosen_file).name));
reference_pic         	=	loadvec(findrefIm(1).name);

end


%% Müll
% lonam                  	=	{['B[' num2str(chosen_file) '].vc7']};          % get filenames


% verificator                     =   0;
% while verificator == 0
%     prompt                      =	['Number of image you wish to analyse (found ' num2str(numofiles) '): '];
%     wateysay                    =	input(prompt,'s');
% 
%     verificator                 =   all(ismember(wateysay,...
%                                         '0123456789al'));                   % is user input within resonable boundaries
% end
% 
% if isempty(wateysay)
%     numoim                  	=	120;
% elseif strncmpi(wateysay,'all',1) || str2double(wateysay) >= numofiles
%     numoim                      =	numofiles;
% else
%     numoim                  	=	str2double(wateysay);
% end
