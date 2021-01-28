%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   PIV-Postprocessingprogramm 
%   by Enno Bösenberg 
%   
%   Preparation:
%    1.	find and adjust readIMXfolder 
%    2.	change 'refDir' to folder including the reference picture
%    3.	change 'svDir' to where any videos should be saved
%   
%   Optional:
%    1.	change filenames for any video in this script
%    2.	change 'vector_factor' to adjust vectorsize
%    3.	change 'fps' to adjust frames per second in all output videos
%    4.	change 'quali' to adjust video quality for all output videos
%
%   Manual:
%    1.	folder including the measurements must be opened in Matlab.
%    2.	RUN script
%    3.	follow the instructions in COMMANDWINDOW (DO NOT PRESS ENTER AT
%       RANDOM)
%
%   Automated operations (chronologically):
%    1.	running readimxdemo to help Matlab find the 'readimx.mex'-file
%    2.	user will be asked to answer a few important questions
%    3.	starting VIDEOWRITER
%    4.	adjustment of the mask requires input as shown in COMMANDWINDOW
%    5.	PROCESSING starts
%    6.	output of information about remaining datasets, processes and time
%    7.	loading and masking datasets according to mask set by user
%    8.	calculate (AF,STD,RMS) depending on user input
%    9.	show and get frames using showf and VideoWriter
%   10.	stopping timer to adjust calculation time vector
%   11.	repeating 4. to 10. untill all datasets are done
%   12.	closing VIDEOWRITER
%   
%   LIVE IMAGES are required to get recommended and default settings for
%   image-adjustments.
%   Cutting measurements into set amount of pieces and averaging over set 
%   frames. (4 in order to match the 355Hz framerate of the thermal camera)
%   Original measurement framerate was 1420Hz. Masks will be applied 
%   according to the users wishes and needs as a product of a finite amount
%   of rectangles at different angles (or preset) in adjustMaskHARD.
%   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Make program more presentable (only works if cd is adjusted)

check = 0;
while check == 0
    file_list 	= dir(fullfile(cd, '*.vc7'));                               % listing files from reference directory
    if isempty(file_list)
        check = 0;
        cd('G:\Enno-Messkampagne-2\00_ag2d_spd129_fps1420_rerun_060\PIV_MP(3x16x16_75%ov_ImgCorr)_GPU\MakePermanentMask')  % finds working directory
    else
        check = 1;
    end
end

%% Solving the recurring mexfile problem for now

mydir = cd;
readIMXfolder = 'G:\Programme der Masterarbeit\PIV-Auswertung\readimx-v2.1.3-win64';
cd(readIMXfolder)
readimxdemo
cd(mydir)

%% Start of main programm

clc
close all
clear

autotransFind   = 1;
runningavg      = 1;

xcut            = 65;                                                       % cutting useless parts from image in findcrit_PIV x-direction
ycut            = 115;                                                      % cutting useless parts from image in findcrit_PIV y-direction
stepsize        = 4;                                                        % number of lines to be averaged over when searching for t-line
smoothingParam  = 0.001;                                                    % smoothes image for better analysis

fps             = 71;                                                       % frames per second in VideoWriter
quali           = 99;                                                       % quality of VideoWriter
vector_factor   = 0.15;                                                     % factor for vectorlength adjustment
chordlength     = 180;                                                   	% chordlength of airfoil in mm
visibleDist     = 105;                                                      % visible distance in mm

refDir          = 'G:\Enno_DU95W180_Mono\Live images';                      % directory to the reference picture (e. g. 'E:\Enno_DU95W180_Mono\Live images';)
verify_refDir   = 'something wrong for there is no reason for reference';  	% verifying directory to the reference picture if you want recommendations and default settings
svDir           = 'G:\ProcessedVideos\';                                    % where to save videos
formatFile      = '.im7';                                                   % format of reference file
just_velofield  = 'SOL_velocityfield';                                      % name of the velocity video
rootmeansquare  = 'RMS_velocityfield';                                      % name of the rms-video
ensembleaverage = 'eUX_velocityfield';                                      % name of the af-video
stddeviation    = 'EPS_velocityfield';                                      % name of the std-video
colorMap        = 'jet';                                                    % image color

%% Aquiring processing specifications from user

[numoim, avgrange, avgtype, numooper, sample_pic, reference_pic,...
    filetypeindex, firstim] = userInput(refDir, verify_refDir, formatFile);          % asking user for averaging/processing range, type and what image should be used as reference

%% Small calculations

numopar         = (1+numoim-firstim)/avgrange;                           	% number of pieces
avgwincounter   = numoim/numopar/avgrange;                                  % number auf averagewindows
% filescalor      = floor(numoim/numopar);                                  	% number of images in a piece
estprocTime     = avgrange*2 + numooper;                                    % educated guess as to how long one process would take
calculationTime = ones(1,numopar).*estprocTime;                             % preallocate timevector
lonam           = cell(1,numopar);                                          % preallovate filenamecellarray

%% VideoWriter start up

[addnum] = numberSTH(svDir);                                                % find number so old videos wont be overwritten

switch avgtype
    case 'non'
        % Create movie of the velocityfield
        vtitle                 = [svDir just_velofield '_' addnum];         % 'E:\ProcessedVideos\just_velocityfield';
        v_vid                  = VideoWriter(vtitle, 'MPEG-4');
        v_vid.FrameRate        = fps;
        v_vid.Quality          = quali;
        open(v_vid);                                                        % open videofile to be written

    case 'AF'
        % Create movie of the velocityfield
        aftitle                 = [svDir ensembleaverage '_' addnum];       % 'E:\ProcessedVideos\AF_velocityfield';
        af_vid                  = VideoWriter(aftitle, 'MPEG-4');
        af_vid.FrameRate        = fps;
        af_vid.Quality          = quali;
        open(af_vid);                                                       % open videofile to be written

    case 'RMS'
        % Create movie of the velocityfield
        rmstitle                = [svDir rootmeansquare '_' addnum];        % 'E:\ProcessedVideos\RMS_velocityfield';
        rms_vid                 = VideoWriter(rmstitle, 'MPEG-4');
        rms_vid.FrameRate       = fps;
        rms_vid.Quality         = quali;
        open(rms_vid);                                                      % open videofile to be written

    case 'STD'
        % Create movie of average
     	stdtitle                = [svDir stddeviation '_' addnum];          % 'E:\ProcessedVideos\STD_velocityfield';
        std_vid                 = VideoWriter(stdtitle, 'MPEG-4');
        std_vid.FrameRate       = fps;
        std_vid.Quality         = quali;
        open(std_vid);                                                      % open videofile to be written

    case 'all'
        % Create movie of the velocityfield
        vtitle                  = [svDir just_velofield '_' addnum];        % 'E:\ProcessedVideos\just_velocityfield';
        v_vid                   = VideoWriter(vtitle, 'MPEG-4');
        v_vid.FrameRate         = fps;
        v_vid.Quality           = quali;
        open(v_vid);                                                        % open videofile to be written        

        % Create movie of the velocityfield
        aftitle                 = [svDir ensembleaverage '_' addnum];       % 'E:\ProcessedVideos\AF_velocityfield';
        af_vid                  = VideoWriter(aftitle, 'MPEG-4');
        af_vid.FrameRate        = fps;
        af_vid.Quality          = quali;
        open(af_vid);                                                       % open videofile to be written

        % Create movie of the velocityfield
        rmstitle                = [svDir rootmeansquare '_' addnum];        % 'E:\ProcessedVideos\RMS_velocityfield';
        rms_vid                 = VideoWriter(rmstitle, 'MPEG-4');
        rms_vid.FrameRate       = fps;
        rms_vid.Quality         = quali;
        open(rms_vid);                                                      % open videofile to be written

        % Create movie of average
     	stdtitle                 = [svDir stddeviation '_' addnum];         % 'E:\ProcessedVideos\STD_velocityfield';
        std_vid                  = VideoWriter(stdtitle, 'MPEG-4');
        std_vid.FrameRate        = fps;
        std_vid.Quality          = quali;
        open(std_vid);                                                      % open videofile to be written
end

%% Create/adjust mask

[mask, rect_vec, rot_vec, minimum_scale, maximum_scale, calculationTime, angleoupsurface] = ...
    adjustMaskHARD(sample_pic, reference_pic, vector_factor, calculationTime, colorMap, filetypeindex);

%%  Process the entire dataset in cd

fprintf('\nStart processing...\n\n');

AFcrit = zeros(numopar,2);
STDcrit = AFcrit;
AFycrit = AFcrit;
RMScrit = AFcrit;
speedcompare = AFcrit;

for ii = 1:numopar
    
 	tic
        
    startim         = 1+avgrange*ii-avgrange;                               % what's the starting-image
    endim           = ii*avgrange;                                          % what's the final-image
    leftpar         = 1+numopar-ii;                                         % how many images are left
    
    [days_left, hours_left, minutes_left, seconds_left] = processingTime(leftpar, calculationTime);
    
    fprintf('...averaging over datasets %d to %d (of %d).\n   There are %d processes left.\n   Estimated time untill finish: %dd %dh %dmin %ds\n',...
        startim, endim, 1+numoim-firstim, leftpar, days_left, hours_left,...
        minutes_left, seconds_left);                                        % output to raise confidence in this programm
    
    lonam = {['B[' num2str(ii*avgrange-avgrange+firstim) ':1:' ...
        num2str(ii*avgrange+firstim) '].vc7']};                                   % get filenames
    
    [v] = adjustDataHARD(lonam, rect_vec, rot_vec);                             % loading and adjusting all data
    
    fprintf('...loading complete.\n');                                      % output of loading time
    
    hold on
    if strcmp(avgtype, 'non')
        [AF, STD, RMS]	= averf(vec2scal(v,'ux','keepzero'));
        [visiblepx, visiblepy] = size(RMS.w);
        mmSize        	= visiblepx/visibleDist;                                                  % size of 1mm in Image

        
        
        showf(AF,'norm','CLim',[minimum_scale maximum_scale],...
             'CMap', colorMap, 'ScaleArrow', vector_factor)
        frame                               = getframe(gcf);            % get frame from figure
        writeVideo(v_vid, frame);
%         for pp = 1:avgrange
%             showf(v(pp),'norm','CLim',[minimum_scale maximum_scale],...
%             'CMap', colorMap, 'ScaleArrow', vector_factor)
%             frame                               = getframe(gcf);            % get frame from figure
%             writeVideo(v_vid, frame);                                       % save frame to video
%         end
    else
        [AF, STD, RMS]	     = averf(vec2scal(v,'ux','keepzero'));          % v should include avgrange vx-fields to average over (averf(filterf(v)))
        [visiblepx, visiblepy] = size(RMS.w);
        mmSize        	= visiblepx/visibleDist;
        
        speedcompare(ii, 2) = AF.w(110, 100);
        
        % labeling of the axes
        tixinv     	= visiblepx:-mmSize*10:0;
        tix         = tixinv(end:-1:1);
        lblxng      = round((chordlength-(visiblepx-tix)./mmSize)/chordlength*100)/100;
        lblx      	= {num2str(lblxng')};
        
        tiy         = 0:mmSize*10:visiblepy;
        lblyng      = round((tiy./mmSize)*100)/100;
        lbly      	= {num2str(lblyng')};
        
        switch avgtype

            case 'all'
                close 1
                figure(1);
                clf
                colormap('jet')
               	% different analysing methodes (e.g. eps2D)
              	[~, ~, af]	= averf(v);         % [af, ~, ~]	= averf(vec2scal(v, 'ux', 'keepzero'));
                
                speedcompare(ii, 1) = af.w(110, 100);
                
              	imagesc(af.w');
                
                caxis([-5 25]);
               	set(gca,'YDir','normal');
                h = colorbar;
                ylabel(h, 'Velocity / m/s');
                
                
                xticks(tix)
                xticklabels(lblx)
                xlabel('x / c')
    
                yticks(tiy)
                yticklabels(lbly)
                ylabel('Height above Airfoil / mm')

              	if autotransFind == 1
                   	[bubplace, startpt] = findcrit_PIV(af, 'RMS',...
                                            	smoothingParam);         	% find a zone in PIV-data ('RMS' to get AF.w instead of AF.vx which is nonexistend when using vec2scal)

                   	if ~isempty(bubplace) || ~isempty(startpt)
                     	hold on
                      	%plot(bubplace, 2, 'ro','MarkerFaceColor','r');      % old: startpt instead of HARDCODE 2
                      	hold off
                    else
                        bubplace = 0;
                    end

                  	[x_new, McSmooth, mark] = findcrit2_PIV(af, 'RMS',...
                                               	smoothingParam);        	% find transition between zones in y-direction

                   	hold on
                 	plot(x_new, McSmooth(x_new), 'ko','MarkerFaceColor','k');
                    plot(mark, McSmooth(mark), 'go','MarkerFaceColor','g');
                  	colorbar('Ticks',0:1e6:1e7);
                  	
                    c = colorbar;
                    c.Label.String = 'Velocity / m/s';
                    hold off
                    
                    AFcrit(ii,:)  = [mark, bubplace(1)];
                end
              	frame                       = getframe(gcf);                % get frame from figure
             	writeVideo(v_vid, frame);                                   % save frame to video

                % ensemble average (AF)
                figure(2);
                clf
                colormap('jet')
                imagesc(AF.w');
                caxis([-5 25]);
                set(gca,'YDir','normal');
                xticks(tix)
                xticklabels(lblx)
                xlabel('x / c')
    
                
                tiy2inv  	= 0:mmSize*10:visiblepy;
                tiy2     	= tiy2inv(1:end);
                lbly2ng  	= round(((tiy2)./mmSize)/chordlength*100)/100;
                lbly2      	= {num2str(lbly2ng')};
      
                yticks(tiy2)
                yticklabels(lbly2)
                ylabel('z / c')

             	if autotransFind == 1
                    [bubplace, startpt] = findcrit_PIV(AF, 'RMS',...
                                                smoothingParam);         	% find a zone in PIV-data ('RMS' to get AF.w instead of AF.vx which is nonexistend when using vec2scal)

                	if ~isempty(bubplace) || ~isempty(startpt)
                        hold on
                        %plot(bubplace, 2, 'ro','MarkerFaceColor','r');      % old: startpt instead of HARDCODE 2
                        hold off
                    else
                        bubplace = 0;
                	end

                   	[x_new, McSmooth, mark] = findcrit2_PIV(AF, 'RMS',...
                                                smoothingParam);        	% find transition between zones in y-direction

                    hold on
                    plot(x_new, McSmooth(x_new), 'ko','MarkerFaceColor','k');
                    plot(mark, McSmooth(mark), 'go','MarkerFaceColor','g');
                    colorbar('Ticks',-50:2:50);
                    
                    c = colorbar;
                    c.Label.String = 'Velocity / m/s'; 
                    hold off
                    
                    Normcrit(ii,:)  = [mark, bubplace(1)];
            	end
                frame                           = getframe(gcf);            % get frame from figure
                writeVideo(af_vid, frame);                                  % save frame to video
                
                % root-mean-square analysis (RMS)
              	figure(3);
                clf
                colormap('jet')
                imagesc(RMS.w');
                caxis([0 3]);
                set(gca,'YDir','normal');
                xticks(tix)
                xticklabels(lblx)
                xlabel('x / c')
    
                yticks(tiy)
                yticklabels(lbly)
                ylabel('Height above Airfoil / mm')

                if autotransFind == 1
%                     [bubplace, startpt] = findcrit_PIV(STD, 'RMS',...
%                                                 smoothingParam);         	% find a bubble-like zone in PIV-data
                                      	
                	if ~isempty(bubplace) || ~isempty(startpt)
                        hold on
                        %plot(bubplace, 2, 'ro','MarkerFaceColor','r');      % old: startpt instead of HARDCODE 2
                        hold off
                    else
                        bubplace = 0;
                	end
                    
                    [x_new, McSmooth, mark] = findcrit2_PIV(RMS, 'RMS',...
                                             	smoothingParam);        	% find transition between zones in y-direction
                    
                  	hold on
                    plot(x_new, McSmooth(x_new), 'ko','MarkerFaceColor','k');
                    plot(mark, McSmooth(mark), 'go','MarkerFaceColor','g');
                    colorbar('Ticks',-50:2:50);
                    hold off
                    
                    RMScrit(ii,:) = [mark bubplace(1)];
                end
                frame                           = getframe(gcf);            % get frame from figure
                writeVideo(rms_vid, frame);                                 % save frame to video

                % standard deviation (STD)
              	figure(4);
                clf
                colormap('jet')
                imagesc(STD.w');
                caxis([0 3]);
                set(gca,'YDir','normal');
                xticks(tix)
                xticklabels(lblx)
                xlabel('x / c')
    
                yticks(tiy)
                yticklabels(lbly)
                ylabel('Height above Airfoil / mm')

                if autotransFind == 1
%                     [bubplace, startpt] = findcrit_PIV(STD, 'RMS',...
%                                                 smoothingParam);         	% find a bubble-like zone in PIV-data
                                      	
                	if ~isempty(bubplace) || ~isempty(startpt)
                        hold on
                        %plot(bubplace, 2, 'ro','MarkerFaceColor','r');      % old: startpt instead of HARDCODE 2
                        hold off
                    else
                        bubplace = 0;
                	end
                    
                    [x_new, McSmooth, mark] = findcrit2_PIV(STD, 'RMS',...
                                             	smoothingParam);        	% find transition between zones in y-direction
                    
                  	hold on
                    plot(x_new, McSmooth(x_new), 'ko','MarkerFaceColor','k');
                    plot(mark, McSmooth(mark), 'go','MarkerFaceColor','g');
                    colorbar('Ticks',-50:2:50);
                    hold off
                    
                    STDcrit(ii,:) = [mark bubplace(1)];
                end
                frame                           = getframe(gcf);            % get frame from figure
                writeVideo(std_vid, frame);                                 % save frame to video

            case 'AF'
                % ensemble average (AF)
                figure(1);
                clf
                colormap('jet')
                imagesc(AF.w');
                caxis([-5 25]);
                set(gca,'YDir','normal');
                xticks(tix)
                xticklabels(lblx)
                xlabel('x / c')
    
                
                tiy2inv  	= 0:mmSize*10:visiblepy;
                tiy2     	= tiy2inv(1:end);
                lbly2ng  	= round(((tiy2)./mmSize)/chordlength*100)/100;
                lbly2      	= {num2str(lbly2ng')};
      
                yticks(tiy2)
                yticklabels(lbly2)
                ylabel('z / c')

             	if autotransFind == 1
                    [bubplace, startpt] = findcrit_PIV(AF, 'RMS',...
                                                smoothingParam);         	% find a zone in PIV-data ('RMS' to get AF.w instead of AF.vx which is nonexistend when using vec2scal)

                	if ~isempty(bubplace) || ~isempty(startpt)
                        hold on
                        %plot(bubplace, 2, 'ro','MarkerFaceColor','r');      % old: startpt instead of HARDCODE 2
                        hold off
                    else
                        bubplace = 0;
                	end

                   	[x_new, McSmooth, mark] = findcrit2_PIV(AF, 'RMS',...
                                                smoothingParam);        	% find transition between zones in y-direction

                    hold on
                    plot(x_new, McSmooth(x_new), 'ko','MarkerFaceColor','k');
                    plot(mark, McSmooth(mark), 'go','MarkerFaceColor','g');
                    colorbar('Ticks',-50:2:50);
                    
                    c = colorbar;
                    c.Label.String = 'Velocity / m/s'; 
                    hold off
                    
                    Normcrit(ii,:)  = [mark, bubplace(1)];
            	end
                frame                           = getframe(gcf);            % get frame from figure
                writeVideo(af_vid, frame);                                  % save frame to video

            case 'RMS'
                % root-mean-square analysis (RMS)
              	figure(3);
                clf
                colormap('jet')
                imagesc(RMS.w');
                caxis([0 3]);
                set(gca,'YDir','normal');
                xticks(tix)
                xticklabels(lblx)
                xlabel('x / c')
    
                yticks(tiy)
                yticklabels(lbly)
                ylabel('Height above Airfoil / mm')

                if autotransFind == 1
%                     [bubplace, startpt] = findcrit_PIV(STD, 'RMS',...
%                                                 smoothingParam);         	% find a bubble-like zone in PIV-data
                                      	
                	if ~isempty(bubplace) || ~isempty(startpt)
                        hold on
                        %plot(bubplace, 2, 'ro','MarkerFaceColor','r');      % old: startpt instead of HARDCODE 2
                        hold off
                    else
                        bubplace = 0;
                	end
                    
                    [x_new, McSmooth, mark] = findcrit2_PIV(RMS, 'RMS',...
                                             	smoothingParam);        	% find transition between zones in y-direction
                    
                  	hold on
                    plot(x_new, McSmooth(x_new), 'ko','MarkerFaceColor','k');
                    plot(mark, McSmooth(mark), 'go','MarkerFaceColor','g');
                    colorbar('Ticks',-50:2:50);
                    
                  
                    c = colorbar;
                    c.Label.String = 'rms'; 
                    hold off
                    
                    RMScrit(ii,:) = [mark bubplace(1)];
                end
                frame                           = getframe(gcf);            % get frame from figure
                writeVideo(rms_vid, frame);                                 % save frame to video

            case 'STD'
                % standard deviation (STD)
              	figure(1);
                clf
                colormap('jet')
                imagesc(STD.w');
                caxis([0 3]);
                set(gca,'YDir','normal');
                xticks(tix)
                xticklabels(lblx)
                xlabel('x / c')
    
                yticks(tiy)
                yticklabels(lbly)
                ylabel('Height above Airfoil / mm')

                if autotransFind == 1
%                     [bubplace, startpt] = findcrit_PIV(STD, 'RMS',...
%                                                 smoothingParam);         	% find a bubble-like zone in PIV-data
                                      	
                	if ~isempty(bubplace) || ~isempty(startpt)
                        hold on
                        %plot(bubplace, 2, 'ro','MarkerFaceColor','r');      % old: startpt instead of HARDCODE 2
                        hold off
                    else
                        bubplace = 0;
                	end
                    
                    [x_new, McSmooth, mark] = findcrit2_PIV(STD, 'RMS',...
                                             	smoothingParam);        	% find transition between zones in y-direction
                    
                  	hold on
                    plot(x_new, McSmooth(x_new), 'ko','MarkerFaceColor','k');
                    plot(mark, McSmooth(mark), 'go','MarkerFaceColor','g');
                    colorbar('Ticks',-50:2:50);
                    
                                        
                    c = colorbar;
                    c.Label.String = 'std'; 
                    hold off
                    
                    STDcrit(ii,:) = [mark bubplace(1)];
                end
                frame                           = getframe(gcf);            % get frame from figure
                writeVideo(std_vid, frame);                               % save frame to video
        end
    end
    
    calculationTime(ii)             = toc;                                  % determine processing time
    calculationTime(1+ii:end)       = ceil(mean(calculationTime(1:ii)));
    fprintf('...that took %d s\n\n', ceil(calculationTime(ii)));
end

hold off

switch avgtype
    case 'non'
        close(v_vid);                                                       % saves the movie

    case 'AF'
        close(af_vid);                                                      % saves the movie

    case 'RMS'
        close(rms_vid);                                                     % saves the movie

    case 'STD'
        close(fr_vid);                                                      % saves the movie

    case 'all'
        close(v_vid); 
        close(af_vid); 
        close(rms_vid); 
        close(std_vid); 
end

avgcalTime                      =	round(mean(calculationTime));           % average processing time

fprintf('\n...done!\n\n');
fprintf('Average processing time was: %d s\n', avgcalTime);


figure(6); plot(AFcrit)
figure(7); plot(STDcrit)


    
%% OLD


%                for pp = 1:avgrange
%                     showf(vec2scal(v(pp), 'eps2D'),'norm','CLim',[minimum_scale maximum_scale],...
%                         'CMap', colorMap, 'ScaleArrow', vector_factor);
%                     if autotransFind == 1
%                         [bubplace, startpt] = findcrit_PIV(vec2scal(v(pp), 'eps2D'), 'RMS',...
%                                                     smoothingParam);         	% find a zone in PIV-data ('RMS' to get AF.w instead of AF.vx which is nonexistend when using vec2scal)
% 
%                         if ~isempty(bubplace) || ~isempty(startpt)
%                             hold on
%                             plot(bubplace, startpt, 'ro','MarkerFaceColor','r');
%                             hold off
%                         end
% 
%                         [x_new, McSmooth] = findcrit2_PIV(vec2scal(v(pp), 'eps2D'), 'RMS',...
%                                                     smoothingParam);        	% find transition between zones in y-direction
% 
%                         hold on
%                         plot(x_new, McSmooth(x_new), 'go','MarkerFaceColor','g');
%                         colorbar('Ticks',-50:5:50);
%                         hold off
%                      end
%                 end
                

%                 showf(RMS,'norm','CLim',[0 maximum_scale],...
%                     'CMap', colorMap, 'ScaleArrow', vector_factor)

%                 showf(vec2scal(AF,'ux'),'norm',...
%                     'CMap', colorMap, 'ScaleArrow', vector_factor)          % ,'CLim',[minimum_scale maximum_scale]

%                 showf(vec2scal(AF,'eps2D'),'norm',...
%                     'CMap', colorMap, 'ScaleArrow', vector_factor)          % ,'CLim',[0 maximum_scale/2]
%                 if autotransFind == 1
%                     [trans_STD, data, maxfind, startpt] = findcrit_PIV(STD, 'STD', stepsize,...
%                                     smoothingParam);        	% find a zone in PIV-data
%                     
%                     hold on
%                   	plot(trans_RMS(:,2),data, 'r.')
%                     plot(trans_RMS(maxfind,2)+startpt ,data(maxfind), 'yo','MarkerFaceColor','y')
%                     colorbar('Ticks',-50:5:50)
% %                     plot3(trans_STD(:,1),trans_STD(:,2),trans_STD(:,3),...
% %                         '.r','markersize',10)
% %                     caxis([0 maximum_scale/2])
% %                     view(-90, 90)
%                     hold off
%                 end