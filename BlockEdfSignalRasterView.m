classdef BlockEdfSignalRasterView
    %BlockEdfSignalRasterView Create a signal raster plot from EDF
    %   Function creates a raster plot from signals stored in an EDF file.
    % The x axis of the raster plot represents time and the y axis
    % presents seqential time segment. The X axis duration and number of 
    % segments to display on the y axis options are predefined to values most
    % likely to be used in sleep and circadian research. Gridlines corresponding
    % to 30 second sleep epochs are automatically displayed. The function can
    % be used to create MATALB figures and can be used to create power 
    % point summaries. 
    %
    % Function prototypes:
    %
    %    obj = BlockEdfSignalRasterView             % Generate Class
    %    opt = obj.opt\n')                          % Get option structure
    %    obj = BlockEdfSignalRasterView(fn|edfStruct, signalLabelCell)
    %    obj = BlockEdfSignalRasterView(fn|edfStruct, signalLabelCell, opt)
    %    obj = BlockEdfSignalRasterView(fn|edfStruct, signalLabelCell, opt, anote)
    %
    %              fn : file name with path included
    %       edfStruct : Struct(header, signalHeader, signalCell) created
    %                   from BlockEdfLoad or BlockEdfLoadClass 
    % signalLabelCell : A cell array of an EDF signal labels, {'edf signal lablel'}
    %             opt : A list of options which provide fine control of
    %                   raster generation
    %      anotations : An array of times to mark on the raster plot
    %
    % Public Properties:
    %
    %    Optional Properties:
    %                 subjectID :  For figure and PPT titles
    %       annotateSignalTimes :  Array of times to annotate time series
    %         
    %    Figure Properties:
    %          percentile_range :  [10 90]: Select data percentiles to include 
    %                              when scaling data, [10 90]
    %             signalToView :  Need to select signals to display {'Pleth', 'EKG'};
    %                              Recommended to only use one signal.
    %                              Feature may be removed in future release
    %         signalDisplayGain :  Set display gain indivudal gain (non zero factor);
    %         signalDefaultGain :  if signalDisplayGain not set: 0.25;            
    %           imageResolution :  Image resolution defined as a string ('100')
    %         setFigurePosition :  Set figure position flag (0);
    %            figurePosition :  Figure position [x,y,w,h];
    %                xAxisScale :  Index of private property (see xTickValues below);
    %    numSignalsPerPageIndex :  Index of private property (see w below);
    %          AnnoteMarkerSize :  10;
    %    
    % Setting Raster Properties:
    %    The three most common adjustments required for generating signal
    %    raster plots are descibed below:
    %
    %    (1) Set x axis duration.The x axis duration is set by selecting an
    %        index to the w array.  The w array durations are:
    %        
    %        1, 2, 5, 10, 15, 20, 30 seconds
    %        1, 2, 2.5, 3, 5, 10, 15, 20 30 40 45 minutes
    %        1, 2, 3, 4, 6, 8, 12, 14 hours
    %
    %        example: 
    %        Setting obj.xAxisScale = 14; prior to creating figures or a
    %        powerpoint will set the raster x axis to 15 minute
    %
    %   (2) Set number of segments to display. The number of segments is
    %       set by indexing numSignalsPerPage.  The numSignalsPerPage
    %       values are:[1 2 3 4 5 6 10 12 20 24 30 60]
    %
    %       example: 
    %       Setting obj.numSignalsPerPageIndex = 8; prior to creating figures or a
    %       powerpoint will set the number of segments displayed to 12.
    %
    %   (3) Change signal scale. Set signalDisplayGain to adjust signal
    %       scaling. Values between .2 and 8 generally work best.
    %   
    % Reccomendations
    %   New users may want to model function calls around test cases which 
    % are distributed with this file. More advance user may want to review 
    % the private properties. If you are very new to programming you may want to
    % use the gui SignalRasterView.
    %
    % Warning:
    %   The program can generate a large number of figures. Care must be
    % taken to not exceed memory/system limitations.
    %
    %
    % Version: 0.1.28
    %
    % ---------------------------------------------
    % Dennis A. Dean, II, Ph.D
    %
    % Program for Sleep and Cardiovascular Medicine
    % Brigam and Women's Hospital
    % Harvard Medical School
    % 221 Longwood Ave
    % Boston, MA  02149
    %
    % File created: October 23, 2012
    % Last update:  April 25, 2014 
    %    
    % Copyright © [2012] The Brigham and Women's Hospital, Inc. THE BRIGHAM AND 
    % WOMEN'S HOSPITAL, INC. AND ITS AGENTS RETAIN ALL RIGHTS TO THIS SOFTWARE 
    % AND ARE MAKING THE SOFTWARE AVAILABLE ONLY FOR SCIENTIFIC RESEARCH 
    % PURPOSES. THE SOFTWARE SHALL NOT BE USED FOR ANY OTHER PURPOSES, AND IS
    % BEING MADE AVAILABLE WITHOUT WARRANTY OF ANY KIND, EXPRESSED OR IMPLIED, 
    % INCLUDING BUT NOT LIMITED TO IMPLIED WARRANTIES OF MERCHANTABILITY AND 
    % FITNESS FOR A PARTICULAR PURPOSE. THE BRIGHAM AND WOMEN'S HOSPITAL, INC. 
    % AND ITS AGENTS SHALL NOT BE LIABLE FOR ANY CLAIMS, LIABILITIES, OR LOSSES 
    % RELATING TO OR ARISING FROM ANY USE OF THIS SOFTWARE.
    %
 
    %---------------------------------------------------- Public Properties
    properties
        % Input Properties
        edf_fn = '';

        % Optional parameters
        subjectID = ''       % For figure and PPT titles
        annotateSignalTimes  % Array of times to annotate time series
        
        % Figure parameters
        percentile_range = [10 90]; % Select data to include in scale
        
        signalToView         % Need to select signal to display {'Pleth'};
        signalDisplayGain    % Need to select indivudal gain:[.5, 0.25];
        signalDefaultGain    % Default if signalDisplayGain not set: 0.25;            


        % figure Parameters
        imageResolution = 100;
        setFigurePosition = 0;
        figurePosition = [];
        xAxisScale = 12;
        numSignalsPerPageIndex = 8;
        
        xGridInc = 1;
        yGridInc = 0.05;
        
        % Annotation Parameters
        AnnoteMarkerSize = 10;
        AnnoteMarker = 'x';
        AnnoteColor = [1 0 0];
        AnnoteLabel = '';
        AddEpochNumbers = 1;
        
        % PPT Parameters
        PptBySignal = 0;    % 0: Generate rasterplot figure 
                            % 1: Generate rasterplot figures and create
                            %    MS PowerPoint file
        
    end
    %------------------------------------------------- Dependent Properties
    properties (Dependent)
        % Input Propertied
        num_signals              % Number of signals in EDF
        edf_signals_labels       % signal lables for EDF
        opt                      % Option structure
        numSignalsToView         % Size of signal sto view
        
        % Derrived properties
        totalNumPages            % Total number of print pages under current
                                 % x and y axis settings
        
        % Display properties
        signalDisplayGainDefault  % Default to (0.4) gain)
        
        % Output Properties
        fig_ids                  % Figure IDs for generated figures
        figCell                  % Support for multiple signals
        window_epochs            % Array of allowable window epochs            
    end
    %--------------------------------------------------- Private Properties
    properties (GetAccess = private)
        % Input Properteis
        arg1                     % First argument
        num_args                 % Number of arguments for 
        signal_list              % Signals available for display
        signalIndexes            % Indexes of signals to display
        userOpt = [];            % User defined options 
        
        % EDF Properties
        edf_header               % EDF header structure from blockEdfLoad
        edf_signal_header        % EDF signal header structure
        edf_signal_cell_arrray   % EDF signal cell array      
        
        % plot constants
        plotProportion = 8.5/11;         
        w = [1, 2, 5, 10, 15, 20, 30, 60, ...
            2*60, 2.5*60, 3*60, 5*60, 10*60, 15*60, ...
            20*60, 30*60, 40*60, 45*60, 60*60, ...
            2*60*60, 3*60*60,  4*60*60, 6*60*60, ...
            8*60*60, 12*60*60, 24*60*60]';
        xTickValues = ...
            {[0:.2:1];             [0:0.5:2];         [0:1:5]; ...
             [0:2:10];             [0:5:15];          [0:5:20]; ...
             [0:5:30];             [0:15:60];         [0:30:2*60]; ...
             [0:30:2.5*60]; ...
             [0:30:3*60];          [0:30:5*60];       [0:300:10*60]; ...
             [0:5*60:15*60];       [0:5*60:20*60];    [0:10*60:30*60]; ...
             [0:10*60:40*60];      [0:15*60:45*60];   [0:15*60:60*60]; ...
             [0:30*60:2*60*60];    [0:60*60:3*60*60]; [0:60*60:4*60*60];...
             [0:2*60*60:6*60*60];   [0:2*60*60:8*60*60]; ...
             [0:3*60*60:12*60*60]; [0:6*60*60:24*60*60]};
        
        %  xTickValues  = {[0:5:30], [0:10:60]};
        xTickLabels = ...
            {{' 0 ', '0.2', '0.4', '0.6', '0.8', ' 1 '}; ...
             {' 0 ', '0.5', '1.0', '1.5', ' 2 '};...
             {'0', '1', '2', '3', '4', '5'}; ...
             {'0 ', '2 ', '4 ', '5 ', '8 ', '10'}; ...
             {'0 ', '3 ', '6 ', '9 ', '12', '15'};...
             {'0 ', '5 ', '10', '15', '20'}; ...
             {'0 ', '5 ', '10', '15', '20', '25', '30'}; ...
             {'0 ', '15', '30', '45', '60'};...
             {' 0 ', '0.5', ' 1 ', '1.5', '2.0'};...
             {' 0 ', '0.5', ' 1 ', '1.5', '2.0', '2.5'};...
             {'0', '1', '2', '3'}; ...
             {'0', '0.5', '1', '1.5', '2', '2.5', '3', '3.5', '4', '4.5', '5'}; ...
             {'0 ', '5 ', '10'};...
             {'0 ', '5 ', '10', '15'};...
             {'0 ', '5 ', '10', '15', '20'};...
             {'0 ', '10', '20', '30'};...
             {'0 ', '10', '20', '30', '40'};...
             {'0 ', '15', '30', '45'};...
             {'0 ', '15', '30', '45', '60'};...
             {' 0 ', '0.5', ' 1 ', '1.5', ' 2 '};...
             {'0', '1', '2', '3'};... 
             {'0', '2', '3', '4'};... 
             {'0', '2', '4', '6'};...
             {'0', '2', '4', '6', '8'};...
             {'0 ', '3 ', '6 ', '9 ', '12'};...
             {'0 ', '6 ', '12', '18', '24'} };

        xTickUnits = ...
            {'Time (sec.)'; ...
             'Time (sec.)'; ...
             'Time (sec.)'; ...
             'Time (sec.)'; ...
             'Time (sec.)'; ...
             'Time (sec.)'; ...
             'Time (sec.)'; ...
             'Time (sec.)'; ...
             'Time (min.)';...
             'Time (min.)';...
             'Time (min.)';...
             'Time (min.)';...
             'Time (min.)';...
             'Time (min.)';...
             'Time (min.)';...
             'Time (min.)';...
             'Time (min.)';...
             'Time (min.)';...
             'Time (min.)';...
             'Time (hr.)';...
             'Time (hr.)';...
             'Time (hr.)';...
             'Time (hr.)';...
             'Time (hr.)';...
             'Time (hr.)';...
             'Time (hr.)'};

        % Define Page information
        numSignalsPerPage = [1 2 3 4 5 6 10 12 20 24 30 60];
        numSignalsPerPageTicks = ...
            { ...
              [1], [1 2], [1 2 3], [1 2 3 4], [1 2 3 4 5], ...
              [1 2 3 4 5 6], ...
              [1 3 5 7 9], ... 
              [1 4 7 10 12], ...
              [1 5 10 15 20], ...
              [1 6 12 18 24], ...
              [1,5:5:30], ...
              [1,10:10:60] ...
              };
        numSignalsPerPageTicksLabels = { ...
            {'1'}; ...
            {'2', '1'};... 
            {'3', '2', '1'};...
            {'4', '3', '2', '1'};...
            {'5', '4', '3', '2', '1'}; ...
            {'6', '5', '4', '3', '2', '1'};...
            {'10' ' 8' ' 6' ' 4' ' 2'};...
            {'12', ' 9', '6', '3', '1'};...
            {'20' '15' '10' ' 5' ' 1'};...
            {'24', '18', '12', '6 ', '1 '};...
            {'30', '25', '20', '15', '10', '5', '1'}; ...
            {'60', '50', '40', '30', '20', '10', '1'} ...
            };   
       
        % Raster plot properteis
        xAxisLineWidth = 2.5
        yAxisEpochWidth = 2.5;
        
        % Output Properties
        multiFigPosition = [ -1679 -149  1680 974];   % Preset size
        fig_idsP                                        % Organized Figures
        defaultPptName ='signalRaster.ppt';
        figCellP                       % Generated figures by signal
        
    end   
    %------------------------------------------------------- Public Methods
    methods
        %------------------------------------------------------ Constructor
        function obj = BlockEdfSignalRasterView(varargin)
            % Constructor
            
         % Store number of input arguments
         obj.num_args = nargin;
         
         % Process input arguments
         if nargin == 0
             %  used to get option structure
             return
         elseif nargin == 1
             % Get argument
             obj.arg1 = varargin{1};   
         elseif nargin == 2
             obj.arg1 = varargin{1};
             obj.signalToView = varargin{2};   
         elseif nargin == 3
             obj.arg1 = varargin{1};
             obj.signalToView = varargin{2};   
             obj.userOpt = varargin{3}; 
         elseif nargin == 4
             obj.arg1 = varargin{1};
             obj.signalToView = varargin{2};   
             obj.userOpt = varargin{3}; 
             obj.annotateSignalTimes = varargin{4}; 
         else
            % function prototype not supported
            fprintf('obj = signalViewEdfSignals\nopt = obj.opt\n');
            fprintf('obj = signalViewEdfSignals(fn|edfStruct, signalLabelCell)\n');
            fprintf('obj = signalViewEdfSignals(fn|edfStruct, signalLabelCell, opt)\n');
            fprintf('obj = signalViewEdfSignals(fn|edfStruct, signalLabelCell, opt, anotations)\n');
            return
         end            
 
                  % Process first argument
         if ischar(obj.arg1)
             % First argument is a file name
             obj.edf_fn = obj.arg1;
         
             % Load Data
             [header signalHeader signalCell] = blockEdfLoad(obj.edf_fn);

             % Record EDF components
             obj.edf_header = header;
             obj.edf_signal_header = signalHeader;
             obj.edf_signal_cell_arrray = signalCell;    
         else
              % Record EDF components
             obj.edf_header = obj.arg1.header;
             obj.edf_signal_header = obj.arg1.signalHeader;
             obj.edf_signal_cell_arrray = obj.arg1.signalCell;            
         end
         
         % Specify signals to display
         if nargin == 1
             obj.signal_list = obj.edf_signals_labels;
         elseif nargin == 2 | nargin == 3   
             if isempty(obj.signal_list)
                 % Signal list is empty, set default
                 obj.signal_list = obj.edf_signals_labels;
             end
         end  
         
         % Need to double check what to do
         % Get signal indexes
         obj.signalIndexes = obj.GetSignalIndexes...
                  (obj.edf_signals_labels, obj.signal_list);       
             
         % Set user provided options
         if nargin == 3 | nargin == 4
            % Signal Parameters
            obj.percentile_range = obj.userOpt.percentile_range;
            obj.signalDisplayGain = obj.userOpt.signalDisplayGain;
            obj.signalDefaultGain = obj.userOpt.signalDefaultGain;         


            % figure Parameters
            obj.imageResolution = obj.userOpt.imageResolution;
            obj.setFigurePosition = obj.userOpt.setFigurePosition;
            obj.figurePosition = obj.userOpt.figurePosition;
            obj.xAxisScale = obj.userOpt.xAxisScale;
            obj.numSignalsPerPageIndex = obj.userOpt.numSignalsPerPageIndex;
            obj.PptBySignal = obj.userOpt.PptBySignal;             
         end

        end
        %------------------------------------------------- CreateSignalView
        function obj = GenerateSignalRasterViewFigures(obj, varargin)
            % Create a signal raster plot
            
            % Set default values
            pptFn = '';
            pptTitle = '';
            pagesToPrint = [];
            
            % Process input argument
            if nargin == 2
                pptFn = varargin{1};
            elseif nargin ==3
                pptFn = varargin{1};
                pptTitle = varargin{2};
            elseif nargin == 4
                pptFn = varargin{1};
                pptTitle = varargin{2};   
                pagesToPrint = varargin{3};
            end         
            
            % Get information to display figure
            numSignals = obj.edf_header.num_signals;
            num_data_records = obj.edf_header.num_data_records;
            data_record_duration = obj.edf_header.data_record_duration;
            getSignalSamplesF = @(x)obj.edf_signal_header(x).samples_in_record;
            signalSamplesPerRecord = arrayfun(getSignalSamplesF,[1:numSignals]);
           
            % Define signals to view 
            getSignalLablesF = @(x)obj.edf_signal_header(x).signal_labels;
            signalLabels = cellfun...
                (getSignalLablesF, num2cell([1:numSignals]), 'UniformOutput', false);
            signalToView = obj.signalToView;
            signalDisplayGain = obj.signalDisplayGain;
            signalsToViewIndexes = ...
                obj.GetSignalIndexes(signalLabels, signalToView);
            numSignalsToView = obj.numSignalsToView;

            % plot constants
            plotProportion = obj.plotProportion;
            w = obj.w;
            xTickValues = obj.xTickValues;
            xTickLables = obj.xTickLabels;

            % Define Page information
            numSignalsPerPage = obj.numSignalsPerPage;
            numSignalsPerPageTicks = obj.numSignalsPerPageTicks;
            numSignalsPerPageTicksLabels = obj.numSignalsPerPageTicksLabels;

            % Get annotation information if present
            annotateT =[];
            if ~isempty(obj.annotateSignalTimes);
                annotateT = obj.annotateSignalTimes;
            end
            
            % figure Parameters
            figCell = cell(numSignalsToView,1);
            for v = 1:numSignalsToView;
                % assign old counter to current index (hack)
                s = signalsToViewIndexes(v);

                % Create a plot for each signal
                signalSize = double(signalSamplesPerRecord(s)*num_data_records);

                % Define preset widths in second
                widthIndex = obj.xAxisScale;  
                widthDuration = obj.w(widthIndex);

                % Compute Image size
                ptWidth = widthDuration*signalSamplesPerRecord(s)/data_record_duration;
                ptHeight = numSignalsPerPage(obj.numSignalsPerPageIndex);
                signalImage = zeros(ptHeight, ptWidth);

                % Move point into image
                signal = obj.edf_signal_cell_arrray{s};
                goodRange = ...
                    prctile(signal, obj.percentile_range);
                goodRangeIndexes = find(and(signal>=goodRange(1), signal<=goodRange(2)));

                % Create scale with the goal of showing 80% of the data
                goodRangeMin = min(signal(goodRangeIndexes));
                goodRangeMax = max(signal(goodRangeIndexes));
                goodRangeScaleF = ...
                 @(x)(x-goodRangeMin)*signalDisplayGain(v)/(goodRangeMax-goodRangeMin);
                if (goodRangeMax-goodRangeMin)~= 0
                    signal = goodRangeScaleF(signal);
                else
                   signal = (signal-goodRangeMin); 
                end

                % Compute Page Information
                pageLengthSec = ...
                    widthDuration*numSignalsPerPage(obj.numSignalsPerPageIndex);
                pageLengthPts = pageLengthSec*signalSamplesPerRecord(s)/data_record_duration;
                signalLengthHr = length(signal)*data_record_duration/signalSamplesPerRecord(s);
                numberPages = ceil(signalLengthHr/pageLengthSec);

                % Reset figure for current signal
                figs = [];
                if isempty(pagesToPrint)
                    generatePages = [1:1:numberPages-1];
                    pagesToPrint = numberPages;
                else
                    generatePages = pagesToPrint;
                    if generatePages(end) == numberPages
                        generatePages(end) = [];
                    end
                end
                for p = generatePages

                    % Move data into array
                    signalStart = 1+ptHeight*ptWidth*(p-1);
                    signalEnd =  ptHeight*ptWidth*p;
                    signalImage(1:ptHeight,1:ptWidth) =  ...
                        reshape(signal(signalStart:signalEnd), ptWidth, ptHeight)';

                    % Create figure
                    % ax1 is used to create epoch level grid lines
                    % ax2 is used to generate minor grid lines defined by
                    % user.  
                    %   Axis control is sensitive to command order. Care
                    % must be taken when revising. Note that each axis 
                    % is created prior to plotting.
                    fid = figure('InvertHardcopy','off','Color',[1 1 1]);
                    ax1 = gca;
                    set(ax1,'Box','On');
                    set(ax1,'Color','None');
                    set(ax1,'Box','On');
                    set(ax1, 'xLim',[0,widthDuration]);
                    set(ax1, 'yLim',[ 0.0, numSignalsPerPage(obj.numSignalsPerPageIndex)+ 1]);
                                      
                    %create new axis
                    ax2=axes('position',get(gca,'position'),'Visible', 'on', ...
                        'Color', 'None');
                    set(ax2,'Box','On');
                    set(ax2, 'xLim',[0,widthDuration]);
                    set(ax2, 'yLim',[ 0.0, numSignalsPerPage(obj.numSignalsPerPageIndex)+ 1]);
                   
                    % Set x axis labels
                    set(ax1,'YTick',[],'Xcolor',[.75 .75 .75],'Xtick',...
                        [1:obj.xGridInc:widthDuration],...
                        'xgrid','on','color','none','GridLineStyle','-'); ...
                        %color none to make the axis transparent
                    %set(ax2,'xlim',get(ax2,'xlim')) %resize 2nd axis to match 1st
                    set(ax1,'XTickLabel',{});
                    
                    % Set y axis labels
                    set(ax1,'Ycolor',[.75 .75 .75],...
                        'Ytick',[0:obj.yGridInc:numSignalsPerPage(obj.numSignalsPerPageIndex)+ 1],...
                        'ygrid','on','color','none','GridLineStyle','-');
                    %set(ax2,'xlim',get(ax1,'xlim')) %resize 2nd axis to match 1st                    
                    set(ax1,'YTickLabel',{});
                    
                    axis(ax1, [0,widthDuration, 0.0, numSignalsPerPage(obj.numSignalsPerPageIndex)+ 1]);
                    hold on
                    
                    % Create first page view
                    x = (([1:ptWidth]*data_record_duration/signalSamplesPerRecord(s))')...
                        *ones(1,numSignalsPerPage...
                        (obj.numSignalsPerPageIndex));
                    y = signalImage';    % Get data by page
                    
                    % determin upper and lower envelope
                    y = y - ones(ptWidth, 1)*mean(y,1);             % zero offset
                    y = y + ones(ptWidth, 1)*[numSignalsPerPage(obj.numSignalsPerPageIndex):-1:1]; % Page

                    % Plot on second axis 
                    hold on    
                    plot (ax2, x, y,'LineWidth',2,'Color',[0 0 1]);
                    hold on
                    
                    % Add Annotation
                    if ~isempty(annotateT)
                        % Identify annotations to plot
                        pgEndSec = p*pageLengthSec;
                        pgStartSec = pgEndSec-pageLengthSec;
                        annotateMask = and(annotateT>=pgStartSec,...
                            annotateT <= pgEndSec);
                        pageAnnotationT = annotateT(find(annotateMask));
                        numPageAnote = length(pageAnnotationT);
                        
                        % Convert annotation times to index
                        pageTime = pageAnnotationT - pgStartSec;
                        signalSamplingRate = signalSamplesPerRecord(v)/...
                            data_record_duration;
                        pageIndex = int64(pageTime*signalSamplingRate);
                        yIndex = (ceil(double(pageIndex)/ptWidth));
                        xIndex = double(pageIndex)-...
                            (yIndex-1.0)*double(ptWidth);
                        xIndex = int32(xIndex);
                        yIndex = int32(yIndex);
                        
                        % Get Annotation points and plot                       
                        xAnote = arrayfun(@(z)x(xIndex(z), yIndex(z)),...
                            [1:numPageAnote]);
                        yAnote = arrayfun(@(z)y(xIndex(z), yIndex(z)),...
                            [1:numPageAnote]);
                        plot(xAnote, yAnote, obj.AnnoteMarker,...
                            'Color', obj.AnnoteColor,...
                            'MarkerFaceColor', obj.AnnoteColor,...
                            'MarkerSize', obj.AnnoteMarkerSize,...
                            'LineStyle', 'None',...
                            'LineWidth', 1);
                    end                
                    
                    % Annotate figure
                    timeStartStr = obj.getTimeStr...
                        (signalStart*data_record_duration/signalSamplesPerRecord(s));
                    timeEndStr = obj.getTimeStr...
                        (signalEnd*data_record_duration/signalSamplesPerRecord(s));
                    if isempty(obj.subjectID)
                        titleStr = sprintf('%s\nPage %.0f of %.0f: %s - %s', ...
                            obj.edf_signal_header(s).signal_labels,p, ...
                            numberPages, timeStartStr, timeEndStr);
                    else
                        titleStr = sprintf('%s - %s\nPage %.0f of %.0f: %s - %s', ...
                            obj.subjectID, ...
                            obj.edf_signal_header(s).signal_labels,p, ...
                            numberPages, timeStartStr, timeEndStr);
                    end
                    if and(~isempty(annotateT), ~isempty(obj.AnnoteLabel))
                        titleStr = sprintf('%s - %s', titleStr,...
                            obj.AnnoteLabel);
                    end
                    
                    title(titleStr,'FontWeight','bold','FontSize',14,...
                        'Interpreter', 'None');
   
%                     % Set figure limits
%                     axis([0,widthDuration, 0.0, numSignalsPerPage(obj.numSignalsPerPageIndex)+ 1]);
%                     
%                     ax2=axes('position',get(gca,'position'),'Visible', 'on'); 
                    
                    % Set X Axis
                    xticks = obj.xTickValues{obj.xAxisScale};
                    set(ax2,'XTick',xticks);
                    set(ax2,'XTickLabel',obj.xTickLabels{obj.xAxisScale});
                    set(ax2, 'Xcolor','black');
                    set(ax2, 'xgrid','on');
                    set(ax2, 'xMinorGrid','On');
                    set(ax2, 'GridLineStyle','-');
                    set(ax2, 'LineWidth', 3.0);
                    xlabel(ax2, obj.xTickUnits{obj.xAxisScale},...
                        'FontWeight','bold','FontSize',14,'Color','black');

                    % Create yaxis labels
                    set(ax2,'YTick',numSignalsPerPageTicks{obj.numSignalsPerPageIndex})
                    set(ax2,'YTickLabel', numSignalsPerPageTicksLabels{obj.numSignalsPerPageIndex});
                    set(ax2, 'Ycolor','black');
                    set(ax2, 'ygrid','on');
                    set(ax2, 'GridLineStyle','-');
                    set(ax2, 'LineWidth', 1);
                    set(ax2, 'yMinorGrid','On');
                    set(ax2, 'MinorGridLineStyle','-');
                    ylabel(ax2, 'Page Line','FontWeight','bold','FontSize',14,...
                        'Color','black');
                    set(ax1, 'Color','None');
                    set(ax2, 'Color','None');
                    
                    % Manually add epoch boundary
                    eBound = [0:30:widthDuration];
                    u = axis;
                    for l = 1:length(eBound)
                        % Add Epoch line
                        line([eBound(l) eBound(l)], [u(3) u(4)], ...
                            'Color', [0 0 0], ...
                            'LineWidth', obj.yAxisEpochWidth);
                    end
                    
                    % Add epoch numbers
                    if obj.AddEpochNumbers == 1
                        xTextOFF = 1;
                        yTextOFF = 0.0; %1/20;
                        epochLabelFontSize = 12;
                        numLines = numSignalsPerPage(obj.numSignalsPerPageIndex);
                        numEpochsPerLine = length(eBound)-1;
                        pageEpoch = (p-1)*numLines*numEpochsPerLine;
                        for f = 1:1:numLines
                            for l = 1:numEpochsPerLine
                                % Determine epoch number
                                lineNum = numLines + 1 - f;
                                epochNum = pageEpoch+(f-1)*numEpochsPerLine+l;

                                % Add text for each epoch 
                                hT = text(eBound(l)+xTextOFF, lineNum+yTextOFF, ...
                                    num2str(epochNum), 'Color', [0 0 0], ...
                                    'FontSize', epochLabelFontSize, ...
                                    'BackgroundColor', [0.9 0.9 0.9], ...
                                    'EdgeColor', [0 0 0 ],...
                                    'VerticalAlignment', 'Bottom',...
                                    'HorizontalAlignment', 'Left');
                            end
                        end
                    end
                    
                    
                    % Add X axis
                    a = axis();
                    for f = 1:numSignalsPerPage(obj.numSignalsPerPageIndex)
                        line(a(1:2), [f f], 'Color', 'Black',...
                            'LineWidth', obj.xAxisLineWidth);
                    end
                    axis(a)
                    
                    % Set figure position 
                    if obj.setFigurePosition == 1
                        if ~isempty (obj.figurePosition)
                            set(fid, 'Position', obj.figurePosition);
                        else
                            set(fid, 'Position', obj.multiFigPosition);
                        end
                    end
                    
                    % Save figure ID
                    figs = [figs; fid];
                end
                if or(pagesToPrint(end) == numberPages, ...
                      isempty(numberPages));
                    % Generate last page
                    
                    % Move data into array
                    p = numberPages;
                    signalStart = 1+ptHeight*ptWidth*(p-1);
                    signalEnd =  signalSize;
                    lastPtHeight = floor((signalEnd-signalStart)/ptWidth);
                    lastLinePtWidth = ...
                        (signalEnd-signalStart)-lastPtHeight*ptWidth;
                    lastLinePtStart = signalStart+lastPtHeight*ptWidth;

                    % Create Signal Matrix
                    signalImage(1:lastPtHeight,1:ptWidth) =  ...
                    reshape(signal(signalStart:lastLinePtStart-1), ...
                                                    ptWidth, lastPtHeight)';

                    % Create first page view
                    x = (([1:ptWidth]*data_record_duration/signalSamplesPerRecord(s))')...
                        *ones(1,lastPtHeight);
                    y = signalImage(1:lastPtHeight,1:end)';  
                    y = y - ones(ptWidth, 1)*mean(y,1);      % zero offset
                    terminalEpoch = numSignalsPerPage(obj.numSignalsPerPageIndex)...
                        - lastPtHeight +1;
                    y = y + ones(ptWidth, 1)*...
                        [numSignalsPerPage(obj.numSignalsPerPageIndex):-1:terminalEpoch];

                    % Plot signal block
                    fid = figure('InvertHardcopy','off','Color',[1 1 1]);
                    
                    % ax1 is used to create epoch level grid lines
                    % ax2 is used to generate minor grid lines defined by
                    % user.  
                    %   Axis control is sensitive to command order. Care
                    % must be taken when revising. Note that each axis 
                    % is created prior to plotting.           
                    ax1 = gca;
                    set(ax1,'Box','On');
                    set(ax1,'Color','None');
                    set(ax1,'Box','On');
                    set(ax1, 'xLim',[0,widthDuration]);
                    set(ax1, 'yLim',[ 0.0, numSignalsPerPage(obj.numSignalsPerPageIndex)+ 1]);
                                      
                    %create new axis
                    ax2=axes('position',get(gca,'position'),'Visible', 'on', ...
                        'Color', 'None');
                    set(ax2,'Box','On');
                    set(ax2, 'xLim',[0,widthDuration]);
                    set(ax2, 'yLim',[ 0.0, numSignalsPerPage(obj.numSignalsPerPageIndex)+ 1]);
                    plot (x, y,'LineWidth',2,'Color',[0 0 1]);
                    hold on

                                        % Set x axis labels
                    set(ax1,'YTick',[],'Xcolor',[.75 .75 .75],'Xtick',...
                        [1:obj.xGridInc:widthDuration],...
                        'xgrid','on','color','none','GridLineStyle','-'); ...
                        %color none to make the axis transparent
                    %set(ax2,'xlim',get(ax2,'xlim')) %resize 2nd axis to match 1st
                    set(ax1,'XTickLabel',{});
                    
                    
                    % Set y axis labels
                    set(ax1,'Ycolor',[.75 .75 .75],...
                        'Ytick',[0:obj.yGridInc:numSignalsPerPage(obj.numSignalsPerPageIndex)+ 1],...
                        'ygrid','on','color','none','GridLineStyle','-');
                    %set(ax2,'xlim',get(ax1,'xlim')) %resize 2nd axis to match 1st                    
                    set(ax1,'YTickLabel',{});
                    
                    axis(ax1, [0,widthDuration, 0.0, numSignalsPerPage(obj.numSignalsPerPageIndex)+ 1]);
                    hold on
                    
                    % Add Annotations to partial page
                    if ~isempty(annotateT)
                        % Identify annotations to plot
                        pgEndSec = p*pageLengthSec;
                        pgStartSec = pgEndSec-pageLengthSec;
                        pgEndSec = pgEndSec - (ptHeight-lastPtHeight)*...
                            pageLengthSec/ptHeight;
                        annotateMask = and(annotateT>=pgStartSec,...
                            annotateT <= pgEndSec);
                        pageAnnotationT = annotateT(find(annotateMask));
                        numPageAnote = length(pageAnnotationT);

                        % Convert annotation times to index
                        pageTime = pageAnnotationT - pgStartSec;
                        signalSamplingRate = signalSamplesPerRecord(v)/...
                            data_record_duration;
                        pageIndex = int64(pageTime*signalSamplingRate);
                        yIndex = (ceil(double(pageIndex)/ptWidth));
                        xIndex = double(pageIndex)-...
                            (yIndex-1.0)*double(ptWidth);
                        xIndex = int32(xIndex);
                        yIndex = int32(yIndex);

                        % Get Annotation points and plot                       
                        xAnote = arrayfun(@(z)x(xIndex(z), yIndex(z)),...
                            [1:numPageAnote]);
                        yAnote = arrayfun(@(z)y(xIndex(z), yIndex(z)),...
                            [1:numPageAnote]);
                        plot(xAnote, yAnote, obj.AnnoteMarker,...
                            'Color', obj.AnnoteColor,...
                            'MarkerFaceColor', obj.AnnoteColor,...
                            'MarkerSize', obj.AnnoteMarkerSize,...
                            'LineStyle', 'None',...
                            'LineWidth', 1);
                    end                    

                    % Plot last incomplete line, if available
                    if lastPtHeight ~= numSignalsPerPage(obj.numSignalsPerPageIndex)
                        % Plot remaining points
                        y = signal(lastLinePtStart:end);  
                        x = (([1:length(y)]*data_record_duration/signalSamplesPerRecord(s))')...
                            *ones(1,1);

                        % Scale signal for page
                        y = y - ones(length(y), 1)*mean(y,1);      % zero offset
                        terminalEpoch = numSignalsPerPage(obj.numSignalsPerPageIndex)...
                            - lastPtHeight;
                        y = y + ones(length(y), 1)*terminalEpoch;
                        plot (x, y,'LineWidth',2,'Color',[0 0 1]);
                        hold on  

                        % Add Annotations to partial line
                        if ~isempty(annotateT)
                            % lastPtHeight
                            % Identify annotations to plot
                            pgEndSec = p*pageLengthSec;
                            pgStartSec = pgEndSec-(ptHeight - lastPtHeight)*...
                                pageLengthSec/ptHeight;
                            annotateMask = and(annotateT>=pgStartSec,...
                                annotateT <= pgEndSec);
                            pageAnnotationT = annotateT(find(annotateMask));
                            numPageAnote = length(pageAnnotationT);

                            % Convert annotation times to index
                            pageTime = pageAnnotationT - pgStartSec;
                            signalSamplingRate = signalSamplesPerRecord(v)/...
                                data_record_duration;
                            pageIndex = int64(pageTime*signalSamplingRate);
                            yIndex = (ceil(double(pageIndex)/ptWidth));
                            xIndex = double(pageIndex)-...
                                (yIndex-1.0)*double(ptWidth);
                            xIndex = int32(xIndex);
                            yIndex = int32(yIndex);

                            % Get Annotation points and plot                       
                            xAnote = arrayfun(@(z)x(xIndex(z), yIndex(z)),...
                                [1:numPageAnote]);
                            yAnote = arrayfun(@(z)y(xIndex(z), yIndex(z)),...
                                [1:numPageAnote]);
                            plot(xAnote, yAnote, obj.AnnoteMarker,...
                                'Color', obj.AnnoteColor,...
                                'MarkerFaceColor', obj.AnnoteColor,...
                                'MarkerSize', obj.AnnoteMarkerSize,...
                                'LineStyle', 'None',...
                                'LineWidth', 1);
                        end   

                    end

                    % Annotate figure
                    timeStartStr = obj.getTimeStr...
                        (signalStart*data_record_duration/signalSamplesPerRecord(s));
                    timeEndStr = obj.getTimeStr...
                        (signalEnd*data_record_duration/signalSamplesPerRecord(s));
                    if isempty(obj.subjectID)
                        titleStr = sprintf('%s\nPage %.0f of %.0f: %s - %s', ...
                            obj.edf_signal_header(s).signal_labels,p, ...
                            numberPages, timeStartStr, timeEndStr);
                    else
                        titleStr = sprintf('%s - %s\nPage %.0f of %.0f: %s - %s', ...
                            obj.subjectID, ...
                            obj.edf_signal_header(s).signal_labels,p, ...
                            numberPages, timeStartStr, timeEndStr);
                    end
                    if and(~isempty(annotateT), ~isempty(obj.AnnoteLabel))
                        titleStr = sprintf('%s - %s', titleStr,...
                            obj.AnnoteLabel);
                    end
                    title(titleStr,'FontWeight','bold','FontSize',14, ...
                        'Interpreter', 'None');

                    % Set figure limits
                    axis([0,widthDuration, 0.0, numSignalsPerPage(obj.numSignalsPerPageIndex)+ 1]);

                    % Set X Axis
                    xticks = obj.xTickValues{obj.xAxisScale};
                    set(ax2,'XTick',xticks);
                    set(ax2,'XTickLabel',obj.xTickLabels{obj.xAxisScale});
                    set(ax2, 'Xcolor','black');
                    set(ax2, 'xgrid','on');
                    set(ax2, 'xMinorGrid','On');
                    set(ax2, 'GridLineStyle','-');
                    set(ax2, 'LineWidth', 3.0);
                    xlabel(ax2, obj.xTickUnits{obj.xAxisScale},...
                        'FontWeight','bold','FontSize',14,'Color','black');

                    % Create yaxis labels
                    set(ax2,'YTick',numSignalsPerPageTicks{obj.numSignalsPerPageIndex})
                    set(ax2,'YTickLabel', numSignalsPerPageTicksLabels{obj.numSignalsPerPageIndex});
                    set(ax2, 'Ycolor','black');
                    set(ax2, 'ygrid','on');
                    set(ax2, 'GridLineStyle','-');
                    set(ax2, 'LineWidth', 1);
                    set(ax2, 'yMinorGrid','On');
                    set(ax2, 'MinorGridLineStyle','-');
                    ylabel(ax2, 'Page Line','FontWeight','bold','FontSize',14,...
                        'Color','black');
                    set(ax1, 'Color','None');
                    set(ax2, 'Color','None');
                    
                    
                    % Add epoch numbers
                    if obj.AddEpochNumbers == 1
                        eBound = [0:30:widthDuration];
                        xTextOFF = 0.2;
                        yTextOFF = 1/20;
                        epochLabelFontSize = 12;
                        numLines = numSignalsPerPage(obj.numSignalsPerPageIndex);
                        numEpochsPerLine = length(eBound)-1;
                        pageEpoch = (p-1)*numLines*numEpochsPerLine;
                        for f = 1:1:numLines
                            for l = 1:numEpochsPerLine
                                % Determine epoch number
                                lineNum = numLines + 1 - f;
                                epochNum = pageEpoch+(f-1)*numEpochsPerLine+l;

                                % Add text for each epoch 
                                text(eBound(l)+xTextOFF, lineNum, ...
                                    num2str(epochNum), 'Color', [0 0 0], ...
                                    'FontSize', epochLabelFontSize, ...
                                    'BackgroundColor', [0.9 0.9 0.9], ...
                                    'EdgeColor', [0 0 0 ],...
                                    'VerticalAlignment', 'Bottom');
                            end
                        end
                    end
                    
                    % Manually add epoch boundary
                    eBound = [0:30:widthDuration];
                    u = axis;
                    for l = 1:length(eBound)
                        line([eBound(l) eBound(l)], [u(3) u(4)], ...
                            'Color', [0 0 0], 'LineWidth', 3);
                    end
                    
                    
                    % Replot data to place on top of gridlines
                    plot (ax2, x, y,'LineWidth',2,'Color',[0 0 1]);

                    % Add epoch numbers
                    eBound = [0:30:widthDuration];
                    xTextOFF = 0.2;
                    yTextOFF = 1/20;
                    epochLabelFontSize = 12;
                    numLines = numSignalsPerPage(obj.numSignalsPerPageIndex);
                    numEpochsPerLine = length(eBound)-1;
                    pageEpoch = (p-1)*numLines*numEpochsPerLine;
                    for f = 1:1:numLines
                        for l = 1:numEpochsPerLine
                            % Determine epoch number
                            lineNum = numLines + 1 - f;
                            epochNum = pageEpoch+(f-1)*numEpochsPerLine+l;
                            
                            % Add text for each epoch 
                            text(eBound(l)+xTextOFF, lineNum, ...
                                num2str(epochNum), 'Color', [0 0 0], ...
                                'FontSize', epochLabelFontSize, ...
                                'BackgroundColor', [0.9 0.9 0.9], ...
                                'EdgeColor', [0 0 0 ],...
                                'VerticalAlignment', 'Bottom');
                        end
                    end
                    
                    % Set figure position 
                    if obj.setFigurePosition == 1
                        if ~isempty (obj.figurePosition)
                            set(fid, 'Position', obj.figurePosition);
                        else
                            set(fid, 'Position', obj.multiFigPosition);
                        end
                    end

                    % Add X axis
                    a = axis();
                    for f = 1:numSignalsPerPage(obj.numSignalsPerPageIndex)
                        line(a(1:2), [f f], 'Color', 'Black',...
                            'LineWidth', obj.xAxisLineWidth);
                    end
                    axis(a)
                    
                    
                    % Save last figure id
                    figs = [figs; fid];
                end
                
                % Record figures generated for signal
                figCell{v} = figs;
                
                % Not reccomended for use, will be removed
                if obj.PptBySignal == 1
                   % Create PPT by signal
                   % obj = obj.CreateSignalPPT (v, figs);
                   if nargin == 2
                       obj = obj.CreateSignalPPT(v, figs, pptFn);
                   elseif or(nargin == 3, nargin == 4)
                       obj = obj.CreateSignalPPT(v, figs, pptFn, pptTitle);
                   else
                       obj = obj.CreateSignalPPT(v, figs);
                   end
                   
                   % Delete figures in order to reduce memory load
                   close(figs)
                   figCell{v} = figs;
                end
            end
     
           
            % Save created figures 
            obj.figCellP = figCell;
     
        end
        %---------------------------------------------- CreateSignalViewPPT
        function obj = CreateSignalViewPPT (obj, varargin)
           % Create Power Point From Created Figures
           % 
           % Prototypes:
           %     obj = CreateSignalViewPPT
           %     obj = CreateSignalViewPPT(pptFn)
           %     obj = CreateSignalViewPPT(pptFn, pptTitle)
           %
           
           
           
            % Define default input
            pptFn = 'signalRaster.ppt';
            pppTitle = 'Signal Raster';

            % User subject id if available 
            if ~isempty(obj.subjectID)   
                pptFn =strcat(obj.subjectID,'.ppt');
                pppTitle =strcat(obj.subjectID,' - Signal Raster');
            end
                
            % Process input arguments
            if nargin == 1
                % Use default file name and title
            elseif nargin == 2
                pptFn = varargin{1};
            elseif nargin == 3
                pptFn = varargin{1};
                pppTitle = varargin{2};
            else
                warningMsg = 'obj.CreateSignalViewPPT prototype not supported: Using default settings';
                warning(warningMsg);
            end
                      
            % Create Combined powerpoint
            index = strfind(obj.edf_fn,'.');

            figCell = obj.figCell;

            if ~isempty(figCell)
                % Identifying Information
                pptFn = strcat(obj.edf_fn(1:index),...
                    num2str(obj.w(obj.xAxisScale)),'.ppt');
                titleStr = obj.numericPatientID(obj.edf_header.patient_id);

                ppt = saveppt2(pptFn,'init', 'res', obj.imageResolution); 
                saveppt2('ppt', ppt, 'f', 0,'text', titleStr);
                for s = 1:obj.numSignalsToView
                    % Add signal Seperator
                    saveppt2('ppt', ppt,'f', 0,'text', obj.signalToView{s});
                    figs = obj.figCell{s};
                    for f = 1:length(figs)
                        figure(figs(f));
                        saveppt2('ppt', ppt );
                    end
                end
                saveppt2(pptFn,'ppt',ppt,'close');
            end       
        end
    end
    %---------------------------------------------------- Dependent Methods
    methods
        %------------------------------------------------------- figure ids
        function value = get.fig_ids(obj)
            value = obj.fig_idsP;
        end
        %---------------------------------------------------------- figCell
        function value = get.figCell(obj)
            value = obj.figCellP;
        end
        %----------------------------------------------- edf_signals_labels
        function value = get.edf_signals_labels(obj)
            sigLabelF = @(x)obj.edf_signal_header(x).signal_labels;
            value = cellfun(sigLabelF, num2cell([1:obj.edf_header.num_signals]), ...
                    'UniformOutput', false);
        end
        %----------------------------------------------- edf_signals_labels
        function value = get.window_epochs(obj)
            value = obj.window_epochs_private;
        end
        %---------------------------------------------------------- Options
        function value = get.opt(obj)
            % Return structure with current figure options

            % Signal Parameters
            value.percentile_range = obj.percentile_range;
            value.signalDisplayGain = obj.signalDisplayGain;
            value.signalDefaultGain = obj.signalDefaultGain;         


            % figure Parameters
            value.imageResolution = obj.imageResolution;
            value.setFigurePosition = obj.setFigurePosition;
            value.figurePosition = obj.figurePosition;
            value.xAxisScale = obj.xAxisScale;
            value.numSignalsPerPageIndex = obj.numSignalsPerPageIndex;
            value.PptBySignal = obj.PptBySignal;
        end  
        %------------------------------------------------- numSignalsToView
        function value = get.numSignalsToView(obj)
            value = length(obj.signalToView);
        end  
        %----------------------------------------------- Derrived Variables
        %---------------------------------------------------- totalNumPages
        function value = get.totalNumPages(obj)
            xAxisScaleSec = obj.w(obj.xAxisScale);
            linesPerPage = ...
                obj.numSignalsPerPage(obj.numSignalsPerPageIndex);
            pageLengthSec = xAxisScaleSec*linesPerPage;
            signalLength = obj.edf_header.num_data_records* ...
                obj.edf_header.data_record_duration;
            value = ceil(signalLength/pageLengthSec);
        end
        %---------------------------------------- signalDisplayGainDefaullt
        function value = get.signalDisplayGainDefault(obj)
            value = length(obj.signalToView)*obj.signalDefaultGain;
        end        
    end
    %------------------------------------------------------ Private Methods
    methods (Access = private)
        %---------------------------------------------- CreateSignalViewPPT
        function obj = CreateSignalPPT (obj, s, figs, varargin)
           % Create Power Point From Created Figures
            
           % Process optional arguments if present
           pptFnIn = '';
           pptTitle = '';
           if nargin == 4
               pptFnIn = varargin{1};
           elseif nargin == 5
               pptFnIn = varargin{1};
               pptTitle = varargin{2};
           end
           
            % Create Combined powerpoint
            if ~isempty(figs)
                % Set output file name
                if and(strcmp(pptFnIn,'')==1,strcmp(obj.edf_fn,'')~=1);
                    % Generate signal ppt fn string         
                    index = strfind(obj.edf_fn,'.');
                    index = index(end);
                    pptFn = strcat(obj.edf_fn(1:index),obj.signalToView{s},...
                        '.',num2str(obj.w(obj.xAxisScale)),'.ppt');
                elseif strcmp(pptFnIn,'')~=1
                    pptFn = pptFnIn;
                else
                    pptFn = obj.defaultPptName;
                end
                
                % Set ppt title string, added a space to avoid error with
                % numeric titles.
                if strcmp(pptTitle,'')==1
                    % Identifying Information
                    titleStr = ...
                        sprintf('_%s',num2str(obj.numericPatientID(obj.edf_header.patient_id)));
                else
                    titleStr = sprintf(' %s ', pptTitle);
                end
                
                ppt = saveppt2(pptFn,'init', 'res', ...
                    num2str(obj.imageResolution)); 
                saveppt2('ppt', ppt, 'f', 0,'title', titleStr);
                
                % Add signal Seperator
                saveppt2('ppt', ppt,'f', 0,'text', obj.signalToView{s});
                for f = 1:length(figs)
                    figure(figs(f));
                    saveppt2('ppt', ppt );
                end

                saveppt2(pptFn,'ppt',ppt,'close');
            end       
        end
    end
    %------------------------------------------------------- Static Methods
    methods
        %------------------------------------------------- GetSignalIndexes
        function indexes = GetSignalIndexes(obj, signals, signal)
            % Function identifies the signal indexes in the signals table
            numVars = length(signal);
            indexes = zeros(numVars,1);
            for v = 1:numVars
                curVar = signal{v};
                TF = strcmp(curVar,signals);
                temp = find(TF);
                if isempty(temp)
                    curVar
                end
                indexes(v)= temp(1);
            end
        end
        %------------------------------------------------------- getTimeStr
        function timeStr = getTimeStr(obj, timeSeconds)
            % Determine total time
            hr = floor(timeSeconds/60/60);
            min = floor((timeSeconds-hr*60*60)/60);
            sec = floor(timeSeconds-hr*60*60-min*60);

            % Convert time to a 
            timeStr = datestr([2012 7 31 hr, min, sec], 'HH:MM:SS');
        end
        %------------------------------------------------- numericPatientID
        function numericPatientStr = numericPatientID(obj,idStr)
            % Convert string to ASCII array    

            % Find numeric portion of idStr
            temp = idStr-0;
            numericCheckF = @(x)~isempty(str2num(char(x)));
            TF = arrayfun(numericCheckF, temp);
            numericIndexes = find(TF);

            % Create new ID
            numericPatientStr = idStr(numericIndexes);

        end       
    end
    %------------------------------------------------------- Static Methods
    methods(Static)
        %----------------------------------------------------- printStrList
        function printStrList(strList)
            % Print an array of numbers
            numPerLine = 5;
            fprintf('\n%20s', strList{1});
            for p = 2:length(strList)
                if mod(p,numPerLine) ~= 1
                    fprintf(', ');
                end
                fprintf('%20s', strList{p});
                if mod(p,numPerLine) == 0
                    fprintf('\n');
                end
            end
        end
    end
end
