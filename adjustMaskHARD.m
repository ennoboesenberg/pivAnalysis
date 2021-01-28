%% Adjust Mask
function [mask, rect_vec, rot_vec, mini_ref, maximum_ref, calculationTime, angleoupsurface] =...
    adjustMaskHARD(sample_pic, reference_pic, vector_factor, calculationTime, colorMap, filetypeindex)

%ans_mask                        =	1;                                      % to enter while loop when defining mask

%% Adjustment part

if filetypeindex == 1

    [val, ~]                        =   max(sample_pic.w);                      % adjusting 'CLim' maximum
    maximum_sc                      =   ceil(mean(val));
    [val, ~]                        =   min(sample_pic.w);                      % adjusting 'CLim' minimum
    mini_sc                         =   floor(min(val));
    sample_color = 'gray';
    
else
    
    [val, ~]                        =   max(sample_pic.vx);                      % adjusting 'CLim' maximum
    maximum_sc                      =   ceil(mean(val));
    [val, ~]                        =   min(sample_pic.vx);                      % adjusting 'CLim' minimum
    mini_sc                         =   floor(min(val));
    sample_color = 'jet';
    
end
    
[val, ~]                        =   max(reference_pic.vx);                  % adjusting 'CLim' maximum
maximum_ref                     =   ceil(mean(val));
[val, ~]                        =   min(reference_pic.vx);                  % adjusting 'CLim' minimum
mini_ref                        =   floor(mean(val));



showf(sample_pic, 'norm', 'CLim', [mini_sc maximum_sc], 'CMap', sample_color)
sc_size                         =   get(0, 'Screensize');                   % adjusting figuresize
sc_size(1)                      =   sc_size(1);
sc_size(2)                      =   sc_size(4)/2-80;
sc_size(3)                      =   sc_size(3)/2;
sc_size(4)                      =   sc_size(4)/2;
set(gcf, 'Position', sc_size);

hold on
% fprintf('Select TWO points of a line to rotate the image around.\nPress ENTER to continue.\n');
% [x, y] = getpts;                                                            % getting points
% line([x(end-1),x(end)], [y(end-1),y(end)], 'Color', 'r', 'LineWidth', 1);
% ang_las = atan((y(end)-y(end-1))/(x(end)-x(end-1)));

ang_las         = -0.2174;                                               	% full image: 0;	%old: -0.2154; %new: -0.2174;
angleoupsurface = rad2deg(ang_las);                                         % deg of airfoil surface
rect1           = [-68.0569      -12.9       37.0569      76];              % full image: [-85      -85       60      70];	%old: [-89.4179      25.01104       15.5821      102.6612]; %new: [-68.0569      -12.9       37.0569      76];

if filetypeindex ~= 1
    ang_las = -ang_las;
end

pause(0.5);
hold off

rot_counter                     =   1;
rot_vec(rot_counter)            =	-ang_las;

reference_pic                   =	rotatef(reference_pic,-ang_las);        % rotating samplepicture to give light section a rectangular alinement
showf(reference_pic, 'norm', 'CLim', [mini_ref maximum_ref],...
    'CMap', colorMap, 'ScaleArrow', vector_factor)
[mask, rect_1]                  =	extractf(reference_pic, rect1);         % extracting rectangular alinement of light section
rect_vec(1,1:4)                 =   rect_1;

showf(mask, 'norm', 'CLim', [mini_ref maximum_ref], 'CMap', colorMap,...
    'ScaleArrow', vector_factor)



%mask                            =   rotatef(mask,-sum(rot_vec));            % rotating back to original orientation
    
showf(mask, 'norm', 'CLim', [mini_ref maximum_ref], 'CMap', colorMap,...
    'ScaleArrow', vector_factor)

%% Adjusting calculationTime according to the amount of rotations
[~, op_Factor] = size(rot_vec);
calculationTime               	=   calculationTime(1:end) + op_Factor;

end








% rect_vec(1,1:4)                 =   rect_1;
% maskcounter                     =   1;

% while ans_mask == 1
%     prompt                      = 	'\nDo you wish to adjust the mask? \n';
%     ans_mask                    = 	input(prompt,'s');
%     
%     if isempty(ans_mask) || strncmpi(ans_mask,'y',1) ...
%             || strncmpi(ans_mask,'1',1)
%         ans_mask                =	1;
%     else
%         break
%     end
% 
%     hold on
%     fprintf('Select TWO points of a line to rotate the image around.\nPress ENTER to continue.\n');
%     [x, y] = getpts;
%     line([x(end-1),x(end)], [y(end-1),y(end)], 'Color', 'r',...
%         'LineWidth', 1);
%     ang_las_2 = atan((y(end)-y(end-1))/(x(end)-x(end-1)));
%     pause(0.5);
%     hold off
%     
%  	mask                        =   rotatef(mask,ang_las_2);                % rotating to new orientation
%     rot_counter                 =   rot_counter + 1;
%     rot_vec(rot_counter)        =   ang_las_2;
%     
%  	showf(mask, 'norm', 'CLim', [mini_ref maximum_ref], 'CMap', colorMap,...
%         'ScaleArrow', vector_factor)
%     
%  	[mask, rect_2]              =   extractf(mask,'draw');                  % extracting original part of the image
%  	maskcounter                 =   maskcounter+1;
%     rect_vec(maskcounter,1:4)   =   rect_2;
%     
%     showf(mask, 'norm', 'CLim', [mini_ref maximum_ref], 'CMap', colorMap,...
%         'ScaleArrow', vector_factor)
% end

% prompt                          =   'Rotate image by (deg): ';
% ang_las                         =   input(prompt,'s');
% if isempty(ang_las)
%     ang_las                     =   deg2rad(ang_mea);
% elseif strncmpi(ang_las,'n',1) 
%     ang_las                     =   0;
% else
%     ang_las                     =   deg2rad(str2double(ang_las));
% end

%     prompt                      =	'Rotate image by (deg): ';
%     ang_las_2_in                =	input(prompt);
%     if isempty(ang_las_2_in) || isnan(ang_las_2_in)
%         ang_las_2               =	ang_las;
%     else
%      	ang_las_2               =   deg2rad(ang_las_2_in);
%     end