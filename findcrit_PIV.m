function [bubplace, startpt] = findcrit_PIV(inputdata, opt, smoothingParam)

% test_OG	= inputdata.w;

switch opt
    case 'AF'
        test_OG	= inputdata.vx;
    case 'RMS'
        test_OG	= inputdata.w;
    case 'STD'
        test_OG	= inputdata.w;
end

test_OG(isnan(test_OG)) = 0;
teststd = std(test_OG);

% gathering useful information from test_OG
[xsize, ysize]	= size(test_OG);

if strcmpi(opt,'TI')
    startpt     = find(teststd <= 1,1,'last')+1;
    if ysize <= startpt
        startpt     = find(islocalmin(teststd) == 1,1,'first');
    end
else
	startpt     = find(teststd > ceil(mean(teststd(1:2))),1,'first')+1;
	if ysize <= startpt
        startpt     = find(islocalmin(teststd) == 1,1,'first');
    elseif isempty(startpt)
        startpt = 1;
	end
end
    
velo_vec	= mean(test_OG(:, startpt:startpt+3)');
x           = 1:xsize;

% find bubble or transitionzone
bubplace = find(velo_vec < 0);

if isempty(bubplace)
    McSmooth        = fit(x',velo_vec','smoothingspline',...
                        'SmoothingParam', smoothingParam);
    d_rive          = differentiate(McSmooth, x);
    
    bubplace = find(d_rive == min(d_rive));
end

[~, bsize] = size(bubplace);
startpt(1:bsize) = startpt;
end









%% OLD CRITERIA
% ii = 0;
% while ii < xsize
% 
%     x               = 1:ysize;
%     
% 	% checking whether next step might exceed number of columns in image
%  	ii_check        = ii + stepsize;
%   	if xsize < ii_check
%      	stepsize        = xsize - ii;
%    	end
%     
%     if stepsize > 1
%         workingData     = mean(test_OG(1+ii:ii+stepsize,:));                %  test
%         positionImg     = 1 + ii : ii + stepsize;             % 1 + ii + xcut : ii + xcut + stepsize;
%     else
%         workingData     = test_OG(1+ii,:);                     % test
%         positionImg     = 1 + ii;                        % 1 + ii + xcut;
%     end
%     
%     rel_wData_start	= find(workingData ~= 0,1,'first');
%     rel_wData_end   = find(workingData ~= 0,1,'last');
%     
%     workingData     = workingData(rel_wData_start:rel_wData_end);
%     x               = x(rel_wData_start:rel_wData_end);
%     
%     McSmooth        = fit(x',workingData','smoothingspline',...
%                         'SmoothingParam', smoothingParam);
%     d_rive          = differentiate(McSmooth, x);
%     
%     maxfind         = islocalmax(d_rive);
%     maxval          = max(d_rive(maxfind));
%     maxfin_place    = find(d_rive == maxval);
%     mean_diff       = mean(d_rive);
%     rel_std_diff	= std(d_rive(maxfin_place:end-maxfin_place));
%     
%     diff_max        = max(d_rive(maxfin_place:end));
%     if diff_max <= mean_diff + rel_std_diff || diff_max <= 0.1
%         transPlace      = 1;
%     else    
%         transPlace      = find(d_rive == diff_max);
%     end
%     
% %    transPlace = transPlace + rel_wData_start;
%     
% %    if transPlace >= 0.02
% 	tPlace_vec(1:stepsize) = transPlace;
% 	trans_matrix(1+ii:ii+stepsize,1:3)    = [tPlace_vec', positionImg',...
%                             test_OG(positionImg, transPlace)];       %[tPlace_vec' + ycut, positionImg',...
%                                                                           	%   test_OG(positionImg, transPlace + ycut)];
% %    end
%     
%     ii          = ii + stepsize;
%     
% end
% 
% startpt         = find(trans_matrix ~= 0,1,'first');
% trans_matrix    = trans_matrix(startpt:end,:);
% McSmooth        = fit(trans_matrix(:,2),trans_matrix(:,1),'smoothingspline',...
%                         'SmoothingParam', 0.001);
% 
% data    = McSmooth(trans_matrix(:,2));
% maxfind = islocalmax(data);
% tpt   = find(maxfind == 1,1,'first');


%% Pieces

% xcut    = 1;
% ycut    = 1;

%xcut            = 65;                                                       % round(find(diffx_fitable == min(diffx_fitable(minfindx))));
%ycut            = 115;                                                      % round(ycut_pt1 - ycut_pt2);

% mean_OG         = mean(test_OG);
% ycut_up         = find(diff(mean_OG) == min(diff(mean_OG)));
% trans_matrix   	= zeros(xsize, 3);
% 
% % using a more handy dataset
% test            = test_OG(xcut:end-1,ycut:ycut_up);
% [xsize, ysize]	= size(test);

%stepsize        = 4;
%smoothingParam 	= 0.001;
%filescalor      = 4;
%ii = 24000/4;

% figure(1); surf(test_OG, 'EdgeColor', 'none')
% hold on

%lonam = {['B[' num2str(1+ii*filescalor-filescalor) ':1:' ...
%        num2str(ii*filescalor) '].vc7']};
%v                           = loadvec(lonam);
%v                           = rotatef(v,15);
%v                           = rotatef(v,-15);
%v                           = extractf(v, rect_vec(qq,1:4));
%[AF, STD, RMS]                          = averf(filterf(v));

%row_avg         = std(test(:,:));

% OG_min          = islocalmin(mean_OG);
% OG_mami         = min(mean_OG(OG_min));
% ycut_pt1        = find(mean_OG == OG_mami);
% ycut_pt2        = std(mean_OG);

%     McFit           = fit(x',fitable,'sin8');
 
% mean_OG         = mean(test_OG');
% test_x          = 1:xsize;
% McSmooth        = fit(test_x',mean_OG','smoothingspline',...
%                         'SmoothingParam', smoothingParam);
% diffx_fitable  	= diff(McSmooth(test_x));
% minfindx        = islocalmin(diffx_fitable);

% hold off

% figure this out
% result = test_OG + trans_matrix;
% 
% figure(2); surf(test, 'EdgeColor', 'none')
% figure(3); surf(trans_matrix, 'EdgeColor', 'none')
% figure(4); surf(result, 'EdgeColor', 'none')
% figure(5); plot(mean_OG)
% figure(6); plot(diff(mean_OG))