function varargout = SignalRasterView(varargin)
% SIGNALRASTERVIEW MATLAB code for SignalRasterView.fig
%      SIGNALRASTERVIEW, by itself, creates a new SIGNALRASTERVIEW or raises the existing
%      singleton*.
%
%      H = SIGNALRASTERVIEW returns the handle to a new SIGNALRASTERVIEW or the handle to
%      the existing singleton*.
%
%      SIGNALRASTERVIEW('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SIGNALRASTERVIEW.M with the given input arguments.
%
%      SIGNALRASTERVIEW('Property','Value',...) creates a new SIGNALRASTERVIEW or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before SignalRasterView_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to SignalRasterView_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SignalRasterView

% Last Modified by GUIDE v2.5 17-Dec-2013 11:06:20

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SignalRasterView_OpeningFcn, ...
                   'gui_OutputFcn',  @SignalRasterView_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before SignalRasterView is made visible.
function SignalRasterView_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to SignalRasterView (see VARARGIN)

% Choose default command line output for SignalRasterView
handles.output = hObject;

% Clear edit text boxes
set(handles.e_edf_efFile, 'String',' ');
set(handles.pm_SignalView_signals, 'String',' ');
set(handles.e_SignalView_pptView, 'String','EDF Signal View');
set(handles.e_SignalView_PptFileName, 'String','EDF_Signal_View.PPT');

% signal raster view  xaxis scale in seconds
handles.xAxisScaleSec = ...
    [1, 2, 5, 10, 15, 20, 30, 60, ...
     2*60, 2.5*60, 3*60, 5*60, 10*60, 15*60, ...
     20*60, 30*60, 40*60, 45*60, 60*60, ...
     2*60*60, 3*60*60,  4*60*60, 6*60*60, ...
     8*60*60, 12*60*60, 24*60*60]';

% Initialize operation handles
handles.edf_fn = '';
handles.edf_pn = strcat(cd,'\');
handles.edf_file_is_selected = 0;
handles.edfObj = [];
handles.edf_file_is_loaded = 0;   
handles.signal_labels = {};

handles.compiled = 0;

% Inactivate button until data is loaded
set(handles.pb_edf_LoadEdf, 'enable','off');
set(handles.pb_edf_header, 'enable','off');
set(handles.pb_edf_signalHeader, 'enable','off');
set(handles.pb_edf_deidentify, 'enable','off');
set(handles.pb_edf_header_chk, 'enable','off');
set(handles.pb_edf_sig_head_chk, 'enable','off');
set(handles.pb_SignalView_SelectPptFn, 'enable','off');
set(handles.pb_fig_Create, 'enable','off');
set(handles.pb_save_fig, 'enable','off');

% Set popup menu's to initial value
set(handles.pm_SignalView_signals, 'value', 1);
set(handles.pm_signal_view_page_start, 'value', 1);
set(handles.pm_signal_view_page_end, 'value', 1);
set(handles.pm_signal_view_page_start, 'String', {' '});
set(handles.pm_signal_view_page_end, 'String', {' '});
set(handles.pmSignalViewEpochStart, 'String', {' '});
set(handles.pmSignalViewEpochEnd, 'String', {' '});
set(handles.pmSignalViewEpochStart, 'Value', 1);
set(handles.pmSignalViewEpochEnd, 'Value', 1);
set(handles.pmSignalViewEpochStart, 'Enable', 'off');
set(handles.pmSignalViewEpochEnd, 'Enable', 'off');

% Get Monitor Positions and set to first monitor
monitorPositionsStrCell = ConvertMonitorPosToFigPos;
set(handles.pm_SignalView_monitorID, ...
    'String', monitorPositionsStrCell);

% Output location 
handles.pptPath =  strcat(cd,'\');

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes SignalRasterView wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = SignalRasterView_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% redo but in pixel
% Set starting position in characters. Had problems with pixels
left_border = .8;
header = 2.0;
set(0,'Units','character') ;
screen_size = get(0,'ScreenSize');
set(handles.figure1,'Units','character');
dlg_size    = get(handles.figure1, 'Position');
pos1 = [ left_border , screen_size(4)-dlg_size(4)-1*header,...
    dlg_size(3) , dlg_size(4)];
set(handles.figure1,'Units','character');
set(handles.figure1,'Position',pos1);



% --- Executes on selection change in pm_SignalView_signals.
function pm_SignalView_signals_Callback(hObject, eventdata, handles)
% hObject    handle to pm_SignalView_signals (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns pm_SignalView_signals contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pm_SignalView_signals

 % Update default output
 if handles.edf_file_is_loaded == 1
    
    % Define PPT Title Default
    curSignalVal = get(handles.pm_SignalView_signals, 'Value');
    titleStr = sprintf('EDF Signal View - %s, %s', ...
        handles.signal_labels{curSignalVal}, date);
    set(handles.e_SignalView_pptView, 'String', titleStr);

    % Define PPT File Name Default
    fnStr = sprintf('%s.%s.ppt', ...
        handles.edf_fn(1:end-4), handles.signal_labels{curSignalVal});
    set(handles.e_SignalView_PptFileName, 'String', fnStr);
    
    % Update handles structure
    guidata(hObject, handles);    
 end    
 
% --- Executes during object creation, after setting all properties.
function pm_SignalView_signals_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pm_SignalView_signals (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on selection change in pm_SignalView_displayGain.
function pm_SignalView_displayGain_Callback(hObject, eventdata, handles)
% hObject    handle to pm_SignalView_displayGain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns pm_SignalView_displayGain contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pm_SignalView_displayGain


% --- Executes during object creation, after setting all properties.
function pm_SignalView_displayGain_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pm_SignalView_displayGain (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pb_edf_SelectEdfFn.
function pb_edf_SelectEdfFn_Callback(hObject, eventdata, handles)
% hObject    handle to pb_edf_SelectEdfFn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Default to current EDF path
current_edf_path = handles.edf_pn;


[edf_fn edf_pn edf_file_is_selected ] = ...
    pb_select_edf_file(current_edf_path);

% check if user selected a file
if edf_file_is_selected == 1
    % write file name to dialog box
    set(handles.e_edf_efFile, 'String', edf_fn);
    guidata(hObject, handles);
    
    % Turn on buttons
    set(handles.pb_edf_LoadEdf, 'enable','on');
    set(handles.pb_edf_header, 'enable','off');
    set(handles.pb_edf_signalHeader, 'enable','off');
    set(handles.pb_edf_deidentify, 'enable','off');
    set(handles.pb_edf_header_chk, 'enable','on');
    set(handles.pb_edf_sig_head_chk, 'enable','on');
    set(handles.pb_SignalView_SelectPptFn, 'enable','off');
    set(handles.pb_fig_Create, 'enable','off');
    set(handles.pb_save_fig, 'enable','off');
    
    % Save file information to globals
    handles.edf_fn = edf_fn;
    handles.edf_pn = edf_pn;
    handles.edf_file_is_selected = edf_file_is_selected;
    guidata(hObject, handles);
end

% --- Executes on button press in pb_edf_LoadEdf.
function pb_edf_LoadEdf_Callback(hObject, eventdata, handles)
% hObject    handle to pb_edf_LoadEdf (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if handles.edf_file_is_selected ==1
    % EDF file is specified
    edf_fn = handles.edf_fn;
    edf_pn = handles.edf_pn;
    
    % Get page lay out infomration
    xAxisScale = get(handles.pm_SignalView_xAxisScale,'value');
    xAxisScaleSec = handles.xAxisScaleSec(xAxisScale);
    linesPerPage = get(handles.pm_SignalView_linesPerPage,'value');
    linesPerPageStr = get(handles.pm_SignalView_linesPerPage,'String');
    linesPerPage = str2num(linesPerPageStr{linesPerPage});
    
    try
        % Load object
        edfFn = strcat(edf_pn,edf_fn);
        edfObj = BlockEdfLoadClass(edfFn);
        edfObj.numCompToLoad = 2;
        edfObj = edfObj.blockEdfLoad;
        signal_labels  = edfObj.signal_labels;

        % Save edf object
        handles.edfObj = edfObj;
        handles.edf_file_is_loaded = 1;  
        
        % Load and set signal labels
        handles.signal_labels = signal_labels;
        set(handles.pm_SignalView_signals, 'string',char(signal_labels)); 
        set(handles.pm_SignalView_signals, 'value',1); 
        
        % Define PPT Title Default
        currentSignal = get(handles.pm_SignalView_signals, 'Value');
        titleStr = sprintf('EDF Signal View - %s, %s', ...
            handles.signal_labels{currentSignal}, date);
        set(handles.e_SignalView_pptView, 'String', titleStr);
        
        % Define PPT File Name Default
        fnStr = sprintf('%s.%s.ppt', ...
            edf_fn(1:end-4), handles.signal_labels{currentSignal});
        set(handles.e_SignalView_PptFileName, 'String', fnStr);
        
        % Compute Page Information
        pageLengthSec = xAxisScaleSec*linesPerPage;
        signalLength = edfObj.edf.header.num_data_records* ...
            edfObj.edf.header.data_record_duration;
        numberPages = ceil(signalLength/pageLengthSec);
                
        % Populate popup menu
        pageStr = num2str([1:1:numberPages]');
        set(handles.pm_signal_view_page_start,'String',pageStr);
        set(handles.pm_signal_view_page_end,'String',pageStr);
        set(handles.pm_signal_view_page_start,'value',1);
        set(handles.pm_signal_view_page_end,'value',1);   

        % Compute Page Information
        numEpochs = numberPages*(pageLengthSec/30);
        pageLengthSec = xAxisScaleSec*linesPerPage;
        epochNumStart = floor((pageLengthSec*(1-1))/30+1);
        epochNumEnd = floor(pageLengthSec*1/30);
        
        % Fix page length bug
        
        
        % Set epoch popup menus
        edfMenuStr = num2str([1:1:numEpochs]');
        set(handles.pmSignalViewEpochStart, 'String', edfMenuStr)
        set(handles.pmSignalViewEpochEnd, 'String', edfMenuStr)
        set(handles.pmSignalViewEpochStart, 'Value', epochNumStart)
        set(handles.pmSignalViewEpochEnd, 'Value', epochNumEnd)
        
        % Enable header and signal header 
        set(handles.pb_edf_LoadEdf, 'enable','on');
        set(handles.pb_edf_header, 'enable','on');
        set(handles.pb_edf_signalHeader, 'enable','on');
        set(handles.pb_edf_deidentify, 'enable','on');
        set(handles.pb_edf_header_chk, 'enable','on');
        set(handles.pb_edf_sig_head_chk, 'enable','on');
        set(handles.pb_SignalView_SelectPptFn, 'enable','on');
        set(handles.pb_fig_Create, 'enable','on');     
        set(handles.pb_save_fig, 'enable','on');
        
        % Update handles structure
        guidata(hObject, handles);
    catch
        fprintf('Could not open edf file: %s\n', edf_fn);

    end
end

% --- Executes on button press in pb_edf_header.
function pb_edf_header_Callback(hObject, eventdata, handles)
% hObject    handle to pb_edf_header (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Check if header is loaded
if handles.edf_file_is_loaded  == 1
    % Get EDF Object and print header to console
    edfObj = handles.edfObj;
    edfObj.PrintEdfHeader;
    
    if handles.compiled == 1
        edfObj.WriteEdfHeader;
        headerTxtFn = edfObj.headerTxtFn;
        systemCmdStr = sprintf('start WordPad.exe %s', headerTxtFn);
        system(systemCmdStr);
    end
end

% --- Executes on button press in pb_edf_signalHeader.
function pb_edf_signalHeader_Callback(hObject, eventdata, handles)
% hObject    handle to pb_edf_signalHeader (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Check if signal header is loaded
if handles.edf_file_is_loaded  == 1
    % Get EDF Object and print header to console
    edfObj = handles.edfObj;
    edfObj.PrintEdfSignalHeader;
    
    if handles.compiled == 1
        edfObj.WriteEdfSignalHeader;
        signalHeaderTxtFn = edfObj.signalHeaderTxtFn;
        systemCmdStr = sprintf('start WordPad.exe %s',signalHeaderTxtFn);
        system(systemCmdStr);
    end
end

function e_edf_efFile_Callback(hObject, eventdata, handles)
% hObject    handle to e_edf_efFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of e_edf_efFile as text
%        str2double(get(hObject,'String')) returns contents of e_edf_efFile as a double


% --- Executes during object creation, after setting all properties.
function e_edf_efFile_CreateFcn(hObject, eventdata, handles)
% hObject    handle to e_edf_efFile (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in pm_SignalView_monitorID.
function pm_SignalView_monitorID_Callback(hObject, eventdata, handles)
% hObject    handle to pm_SignalView_monitorID (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns pm_SignalView_monitorID contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pm_SignalView_monitorID


% --- Executes during object creation, after setting all properties.
function pm_SignalView_monitorID_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pm_SignalView_monitorID (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in pm_SignalView_xAxisScale.
function pm_SignalView_xAxisScale_Callback(hObject, eventdata, handles)
% hObject    handle to pm_SignalView_xAxisScale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns pm_SignalView_xAxisScale contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pm_SignalView_xAxisScale

% Get page lay out infomration
xAxisScale = get(handles.pm_SignalView_xAxisScale,'value');
xAxisScaleSec = handles.xAxisScaleSec(xAxisScale);
linesPerPage = get(handles.pm_SignalView_linesPerPage,'value');
linesPerPageStr = get(handles.pm_SignalView_linesPerPage,'String');
linesPerPage = str2num(linesPerPageStr{linesPerPage});


% Compute Page Information
pageLengthSec = xAxisScaleSec*linesPerPage;
signalLength = handles.edfObj.edf.header.num_data_records* ...
    handles.edfObj.edf.header.data_record_duration;
numberPages = ceil(signalLength/pageLengthSec);

        
% Compute Page Information
numEpochs = numberPages*(pageLengthSec/30);
pageLengthSec = xAxisScaleSec*linesPerPage;
epochNumStart = floor((pageLengthSec*(1-1))/30+1);
epochNumEnd = floor(pageLengthSec*1/30);


% Populate popup menu
pageStr = num2str([1:1:numberPages]');
set(handles.pm_signal_view_page_start,'String',pageStr);
set(handles.pm_signal_view_page_end,'String',pageStr);
set(handles.pm_signal_view_page_start,'value',1);
set(handles.pm_signal_view_page_end,'value',1);
        

% Set epoch popup menus
edfMenuStr = num2str([1:1:numEpochs]');
set(handles.pmSignalViewEpochStart, 'String', edfMenuStr)
set(handles.pmSignalViewEpochEnd, 'String', edfMenuStr)
set(handles.pmSignalViewEpochStart, 'Value', epochNumStart)
set(handles.pmSignalViewEpochEnd, 'Value', epochNumEnd)

% --- Executes during object creation, after setting all properties.
function pm_SignalView_xAxisScale_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pm_SignalView_xAxisScale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in pm_SignalView_linesPerPage.
function pm_SignalView_linesPerPage_Callback(hObject, eventdata, handles)
% hObject    handle to pm_SignalView_linesPerPage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns pm_SignalView_linesPerPage contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pm_SignalView_linesPerPage

% Get page lay out infomration
xAxisScale = get(handles.pm_SignalView_xAxisScale,'value');
xAxisScaleSec = handles.xAxisScaleSec(xAxisScale);
linesPerPage = get(handles.pm_SignalView_linesPerPage,'value');
linesPerPageStr = get(handles.pm_SignalView_linesPerPage,'String');
linesPerPage = str2num(linesPerPageStr{linesPerPage});

% Compute Page Information
pageLengthSec = xAxisScaleSec*linesPerPage;
signalLength = handles.edfObj.edf.header.num_data_records* ...
    handles.edfObj.edf.header.data_record_duration;
numberPages = ceil(signalLength/pageLengthSec);
        
% Compute Epoch Information
numEpochs = numberPages*(pageLengthSec/30);
pageLengthSec = xAxisScaleSec*linesPerPage;
epochNumStart = floor((pageLengthSec*(1-1))/30+1);
epochNumEnd = floor(pageLengthSec*1/30);

% Populate popup menu
pageStr = num2str([1:1:numberPages]');
set(handles.pm_signal_view_page_start,'String',pageStr);
set(handles.pm_signal_view_page_end,'String',pageStr);
set(handles.pm_signal_view_page_start,'value',1);
set(handles.pm_signal_view_page_end,'value',1);

% Set epoch popup menus
edfMenuStr = num2str([1:1:numEpochs]');
set(handles.pmSignalViewEpochStart, 'String', edfMenuStr)
set(handles.pmSignalViewEpochEnd, 'String', edfMenuStr)
set(handles.pmSignalViewEpochStart, 'Value', epochNumStart)
set(handles.pmSignalViewEpochEnd, 'Value', epochNumEnd)
        
% --- Executes during object creation, after setting all properties.
function pm_SignalView_linesPerPage_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pm_SignalView_linesPerPage (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function e_SignalView_pptView_Callback(hObject, eventdata, handles)
% hObject    handle to e_SignalView_pptView (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of e_SignalView_pptView as text
%        str2double(get(hObject,'String')) returns contents of e_SignalView_pptView as a double


% --- Executes during object creation, after setting all properties.
function e_SignalView_pptView_CreateFcn(hObject, eventdata, handles)
% hObject    handle to e_SignalView_pptView (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function e_SignalView_PptFileName_Callback(hObject, eventdata, handles)
% hObject    handle to e_SignalView_PptFileName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of e_SignalView_PptFileName as text
%        str2double(get(hObject,'String')) returns contents of e_SignalView_PptFileName as a double


% --- Executes during object creation, after setting all properties.
function e_SignalView_PptFileName_CreateFcn(hObject, eventdata, handles)
% hObject    handle to e_SignalView_PptFileName (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end




% --- Executes on button press in pushbutton5.
function pushbutton5_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pb_SignalView_SelectPptFn.
function pb_SignalView_SelectPptFn_Callback(hObject, eventdata, handles)
% hObject    handle to pb_SignalView_SelectPptFn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if handles.edf_file_is_loaded == 1
    % Get dialog information
    fn = get(handles.e_SignalView_PptFileName, 'String');
    pptPath = handles.pptPath;
    
    % Get file 
	[file,path] = uiputfile(fn,'Save file name', strcat(pptPath,fn));
    
    % Resave values
    if ~and(length(file) == 1, length(path) == 1)
        % File and path selected
        
        % Update dialog box
        set(handles.e_SignalView_PptFileName, 'String', file);
        handles.pptPath = path;
        
        % Update Global Handles 
        guidata(hObject, handles);
    end
    
end


% --- Executes on button press in pb_fig_Create.
function pb_fig_Create_Callback(hObject, eventdata, handles)
% hObject    handle to pb_fig_Create (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if handles.edf_file_is_loaded == 1
   %% Get information from dialog box
   
   %------------------------------------------------ Get Global Information
   % Get signal filename
   edf_fn = handles.edf_fn;
   edf_pn = handles.edf_pn;
   edfFN = strcat(edf_pn, edf_fn);
   
   %--------------------------------------------- Get interface information
   % Get signal label
   pm_SignalLabelVal = get(handles.pm_SignalView_signals,'value');
   pm_SignalLabelStr = get(handles.pm_SignalView_signals,'String');
   signalLabel = {strtrim(pm_SignalLabelStr(pm_SignalLabelVal,:))};
   
   % Axis information
   xAxisScale = get(handles.pm_SignalView_xAxisScale,'value');
   linesPerPage = get(handles.pm_SignalView_linesPerPage,'value');
   
   % Display information
   displayGainVal = get(handles.pm_SignalView_displayGain,'value');
   displayGainStr = get(handles.pm_SignalView_displayGain,'String');
   displayGain = eval(displayGainStr{displayGainVal,:});
   displayPositionVal = get(handles.pm_SignalView_monitorID,'value');
   displayPositionStr = get(handles.pm_SignalView_monitorID,'String');
   displayPosition = eval(displayPositionStr{displayPositionVal,:});
   
%    % Adjust Display Position
%    dx = 40;
%    dy = 40;
%    displayPosition(1) = displayPosition(3);
%    displayPosition(2) = displayPosition(4);
%    displayPosition(3) = displayPosition(3) - dx;
%    displayPosition(4) = displayPosition(4) - dy;
   
   % Get Grid information
   yGridVal = get(handles.pm_SignalViewYGrid,'value');
   yGrid= get(handles.pm_SignalViewYGrid,'string');
   yGrid = str2num(yGrid{yGridVal,:});
   xGridVal = get(handles.pm_SignalViewXgrid,'value');
   xGrid= get(handles.pm_SignalViewXgrid,'string');
   xGrid = str2num(xGrid{xGridVal,:});
   
   % PPT Information
   pptTitle = get(handles.e_SignalView_pptView,'String');
   pptFileName = get(handles.e_SignalView_PptFileName,'String');
   pptFileName = strcat(handles.pptPath, pptFileName);
   
   % Get pages to generate
   pageStart = get(handles.pm_signal_view_page_start,'String');
   pageStartValue = get(handles.pm_signal_view_page_start,'Value');
   pageStart = str2num(pageStart(pageStartValue,:));
   pageEnd = get(handles.pm_signal_view_page_end,'String');
   pageEndValue = get(handles.pm_signal_view_page_end,'Value');
   pageEnd = str2num(pageEnd(pageEndValue,:));   
   
   
   %----------------------------------------------- Load Signal Information
   % Create a reduced edfStruct with data
   [edfStruct.header, edfStruct.signalHeader, edfStruct.signalCell] = ...
       blockEdfLoad(edfFN, signalLabel);  
   
   % Crude approach to adjust display position
   displayPosition(1) = displayPosition(1) + 20;
   displayPosition(2) = displayPosition(2) + 10;
   displayPosition(3) = displayPosition(3) - 40;
   displayPosition(4) = displayPosition(4) - 100;
   
   % Configure signal raster plot options
   opt.signalDisplayGain = displayGain;
   opt.xAxisScale = xAxisScale; % 8 for 60 second scale, 7 for 30 sec scale
   opt.setFigurePosition = 1;
   opt.figurePosition = displayPosition;
   opt.PptBySignal = 0;
   opt.numSignalsPerPageIndex = linesPerPage;   % 12 per page     
   opt.percentile_range = [10 90];
   opt.signalDefaultGain = displayGain;   
   opt.imageResolution = 100;
   
   % Get, show and select signal labels
   svObj = signalViewEdfSignals(edfStruct, signalLabel, opt);  
   
   % Create figures and create power point
   generatePages = [pageStart:pageEnd];
   svObj.xGridInc = xGrid;   
   svObj.yGridInc = 1/yGrid;
   svObj = svObj.CreateSignalViewFigures(pptFileName, ...
       pptTitle, generatePages);
   
end


% --- Executes on button press in pb_fig_CloseAll.
function pb_fig_CloseAll_Callback(hObject, eventdata, handles)
% hObject    handle to pb_fig_CloseAll (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

hands     = get (0,'Children');   % locate fall open figure handles
hands     = sort(hands);          % sort figure handles
numfigs   = size(hands,1);        % number of open figures
indexes   = find(hands-round(hands)==0);

close(hands(indexes));

% Set flags
handles.subject_is_displayed = 0;
handles.fig_id = 0;
fig_set_info = [];

% Update global handles
guidata(hObject, handles);


% --- Executes on button press in pb_fig_about.
function pb_fig_about_Callback(hObject, eventdata, handles)
% hObject    handle to pb_fig_about (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

SignalRasterViewAbout

% --- Executes on selection change in popupmenu6.
function popupmenu6_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu6 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu6


% --- Executes during object creation, after setting all properties.
function popupmenu6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in popupmenu7.
function popupmenu7_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu7 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu7


% --- Executes during object creation, after setting all properties.
function popupmenu7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in pm_signal_view_page_start.
function pm_signal_view_page_start_Callback(hObject, eventdata, handles)
% hObject    handle to pm_signal_view_page_start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns pm_signal_view_page_start contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pm_signal_view_page_start

% Get page lay out infomration
xAxisScale = get(handles.pm_SignalView_xAxisScale,'value');
xAxisScaleSec = handles.xAxisScaleSec(xAxisScale);
linesPerPage = get(handles.pm_SignalView_linesPerPage,'value');
linesPerPageStr = get(handles.pm_SignalView_linesPerPage,'String');
linesPerPage = str2num(linesPerPageStr{linesPerPage});
pageStartVal = get(handles.pm_signal_view_page_start,'value');
pageStart = get(handles.pm_signal_view_page_start,'String');
pageStart = str2num(pageStart(pageStartVal,:));
pageEndVal = get(handles.pm_signal_view_page_end,'value');
pageEnd = get(handles.pm_signal_view_page_end,'String');
pageEnd = str2num(pageEnd(pageEndVal,:));

% Check if pages are set appropraitely
if pageStart > pageEnd
    % Change pageEnd to pageStart
    pageEndVal = pageStart;
    set(handles.pm_signal_view_page_end,'value', pageEndVal);
end    

% Compute Page Information
pageLengthSec = xAxisScaleSec*linesPerPage;
epochNumStart = floor((pageLengthSec*(pageStartVal-1))/30+1);
epochNumEnd = floor(pageLengthSec*pageEndVal/30);
set(handles.pmSignalViewEpochStart,'Value', epochNumStart);
set(handles.pmSignalViewEpochEnd,'Value', epochNumEnd);


% --- Executes during object creation, after setting all properties.
function pm_signal_view_page_start_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pm_signal_view_page_start (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in pm_signal_view_page_end.
function pm_signal_view_page_end_Callback(hObject, eventdata, handles)
% hObject    handle to pm_signal_view_page_end (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns pm_signal_view_page_end contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pm_signal_view_page_end


% Get page lay out infomration
xAxisScale = get(handles.pm_SignalView_xAxisScale,'value');
xAxisScaleSec = handles.xAxisScaleSec(xAxisScale);
linesPerPage = get(handles.pm_SignalView_linesPerPage,'value');
linesPerPageStr = get(handles.pm_SignalView_linesPerPage,'String');
linesPerPage = str2num(linesPerPageStr{linesPerPage});
pageStartVal = get(handles.pm_signal_view_page_start,'value');
pageStart = get(handles.pm_signal_view_page_start,'String');
pageStart = str2num(pageStart(pageStartVal,:));
pageEndVal = get(handles.pm_signal_view_page_end,'value');
pageEnd = get(handles.pm_signal_view_page_end,'String');
pageEnd = str2num(pageEnd(pageEndVal,:));


% Check if pages are set appropraitely
if pageEnd < pageStart
    % Change pageEnd to pageStart
    pageStartVal = pageEnd;
    set(handles.pm_signal_view_page_start,'value', pageStartVal);
end    


% Compute Epoch Information
% numEpochs = numberPages*(pageLengthSec/30);
pageLengthSec = xAxisScaleSec*linesPerPage;
epochNumStart = floor((pageLengthSec*(pageStartVal-1))/30+1);
epochNumEnd = floor(pageLengthSec*pageEndVal/30);

% Set epoch popup menus
set(handles.pmSignalViewEpochStart, 'Value', epochNumStart)
set(handles.pmSignalViewEpochEnd, 'Value', epochNumEnd)

% --- Executes during object creation, after setting all properties.
function pm_signal_view_page_end_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pm_signal_view_page_end (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pb_fig_quit.
function pb_fig_quit_Callback(hObject, eventdata, handles)
% hObject    handle to pb_fig_quit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

close SignalRasterView

function eSelectedEpodddchsEpochStart_Callback(hObject, eventdata, handles)
% hObject    handle to eSelectedEpodddchsEpochStart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of eSelectedEpodddchsEpochStart as text
%        str2double(get(hObject,'String')) returns contents of eSelectedEpodddchsEpochStart as a double


% Get Start and Stop Epoch
% epochStart = str2num(get(handles.eSelectedEpodddchsEpochStart, 'String'));
% epochEnd = str2num(get(handles.eSelecteddddEpochsEpochEnd, 'String'));



% --- Executes during object creation, after setting all properties.
function eSelectedEpodddchsEpochStart_CreateFcn(hObject, eventdata, handles)
% hObject    handle to eSelectedEpodddchsEpochStart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function eSelecteddddEpochsEpochEnd_Callback(hObject, eventdata, handles)
% hObject    handle to eSelecteddddEpochsEpochEnd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of eSelecteddddEpochsEpochEnd as text
%        str2double(get(hObject,'String')) returns contents of eSelecteddddEpochsEpochEnd as a double


% --- Executes during object creation, after setting all properties.
function eSelecteddddEpochsEpochEnd_CreateFcn(hObject, eventdata, handles)
% hObject    handle to eSelecteddddEpochsEpochEnd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



% --- Executes on selection change in pmSignalViewEpochStart.
function pmSignalViewEpochStart_Callback(hObject, eventdata, handles)
% hObject    handle to pmSignalViewEpochStart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns pmSignalViewEpochStart contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pmSignalViewEpochStart


% --- Executes during object creation, after setting all properties.
function pmSignalViewEpochStart_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pmSignalViewEpochStart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% % --- Executes on selection change in pmSignalViewEpochEnd.
function pmSignalViewEpochEnd_Callback(hObject, eventdata, handles)
% hObject    handle to pmSignalViewEpochEnd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns pmSignalViewEpochEnd contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pmSignalViewEpochEnd


% --- Executes during object creation, after setting all properties.
function pmSignalViewEpochEnd_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pmSignalViewEpochEnd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pb_save_fig.
function pb_save_fig_Callback(hObject, eventdata, handles)
% hObject    handle to pb_save_fig (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if handles.edf_file_is_loaded == 1
   %% Get information from dialog box
   
   %------------------------------------------------ Get Global Information
   % Get signal filename
   edf_fn = handles.edf_fn;
   edf_pn = handles.edf_pn;
   edfFN = strcat(edf_pn, edf_fn);
   
   %--------------------------------------------- Get interface information
   % Get signal label
   pm_SignalLabelVal = get(handles.pm_SignalView_signals,'value');
   pm_SignalLabelStr = get(handles.pm_SignalView_signals,'String');
   signalLabel = {strtrim(pm_SignalLabelStr(pm_SignalLabelVal,:))};
   
   % Axis information
   xAxisScale = get(handles.pm_SignalView_xAxisScale,'value');
   linesPerPage = get(handles.pm_SignalView_linesPerPage,'value');
   
   % Get Grid information
   yGridVal = get(handles.pm_SignalViewYGrid,'value');
   yGrid= get(handles.pm_SignalViewYGrid,'string');
   yGrid = str2num(yGrid{yGridVal,:});
   xGridVal = get(handles.pm_SignalViewXgrid,'value');
   xGrid= get(handles.pm_SignalViewXgrid,'string');
   xGrid = str2num(xGrid{xGridVal,:});
   
   % Display information
   displayGainVal = get(handles.pm_SignalView_displayGain,'value');
   displayGainStr = get(handles.pm_SignalView_displayGain,'String');
   displayGain = eval(displayGainStr{displayGainVal,:});
   displayPositionVal = get(handles.pm_SignalView_monitorID,'value');
   displayPositionStr = get(handles.pm_SignalView_monitorID,'String');
   displayPosition = eval(displayPositionStr{displayPositionVal,:});
   
   % PPT Information
   pptTitle = get(handles.e_SignalView_pptView,'String');
   pptFileName = get(handles.e_SignalView_PptFileName,'String');
   pptFileName = strcat(handles.pptPath, pptFileName);
   
   % Get pages to generate
   pageStart = get(handles.pm_signal_view_page_start,'String');
   pageStartValue = get(handles.pm_signal_view_page_start,'Value');
   pageStart = str2num(pageStart(pageStartValue,:));
   pageEnd = get(handles.pm_signal_view_page_end,'String');
   pageEndValue = get(handles.pm_signal_view_page_end,'Value');
   pageEnd = str2num(pageEnd(pageEndValue,:));   
   
   
   %----------------------------------------------- Load Signal Information
   % Create a reduced edfStruct with data
   [edfStruct.header, edfStruct.signalHeader, edfStruct.signalCell] = ...
       blockEdfLoad(edfFN, signalLabel);  
    
   % Configure signal raster plot options
   opt.signalDisplayGain = displayGain;
   opt.xAxisScale = xAxisScale; % 8 for 60 second scale, 7 for 30 sec scale
   opt.setFigurePosition = 1;
   opt.figurePosition = displayPosition;
   opt.PptBySignal = 1;
   opt.numSignalsPerPageIndex = linesPerPage;   % 12 per page     
   opt.percentile_range = [10 90];
   opt.signalDefaultGain = displayGain;   
   opt.imageResolution = 100;
   
   % Get, show and select signal labels
   svObj = signalViewEdfSignals(edfStruct, signalLabel, opt);
    
   % Create figures and create power point
   generatePages = [pageStart:pageEnd];
   svObj.xGridInc = xGrid;   
   svObj.yGridInc = 1/yGrid;
   svObj = svObj.CreateSignalViewFigures(pptFileName, ...
       pptTitle, generatePages);
   
   
end
% --- Executes on button press in pb_fig_folder.
function pb_fig_folder_Callback(hObject, eventdata, handles)
% hObject    handle to pb_fig_folder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Open folder dialog box
start_path = handles.pptPath;
dialog_title = 'PPT Save Directory';
folder_name = uigetdir(start_path, dialog_title);

% Check return values
if isstr(folder_name)
   % user selected a folder
   handles.pptPath = strcat(folder_name,'\');
   
   % Update handles structure
    guidata(hObject, handles);
end


% --- Executes on selection change in pm_SignalViewYGrid.
function pm_SignalViewYGrid_Callback(hObject, eventdata, handles)
% hObject    handle to pm_SignalViewYGrid (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns pm_SignalViewYGrid contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pm_SignalViewYGrid


% --- Executes during object creation, after setting all properties.
function pm_SignalViewYGrid_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pm_SignalViewYGrid (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in pm_SignalViewXgrid.
function pm_SignalViewXgrid_Callback(hObject, eventdata, handles)
% hObject    handle to pm_SignalViewXgrid (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns pm_SignalViewXgrid contents as cell array
%        contents{get(hObject,'Value')} returns selected item from pm_SignalViewXgrid


% --- Executes during object creation, after setting all properties.
function pm_SignalViewXgrid_CreateFcn(hObject, eventdata, handles)
% hObject    handle to pm_SignalViewXgrid (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pb_edf_header_chk.
function pb_edf_header_chk_Callback(hObject, eventdata, handles)
% hObject    handle to pb_edf_header_chk (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if handles.edf_file_is_selected ==1
    % Get file name
    edf_fn = handles.edf_fn;
    edf_pn = handles.edf_pn;
    fn = strcat(edf_pn, edf_fn);
    
    % Load EDF
    belClass = BlockEdfLoadClass(fn);
    belClass.numCompToLoad = 1;
    belClass = belClass.blockEdfLoad;  
    belClass = belClass.CheckEdf;
    fprintf('Checking Header: %s\n', edf_fn);
    if isempty(belClass.errMsg)
        fprintf('\tNo error Messages found\n');
    else
        for m = 1:length(belClass.errMsg)
            fprintf('\t%s\n',belClass.errMsg{m});
        end
    end
    
    % Write to file if compiled
    if handles.compiled == 1
        belClass.WriteCheck;
        checkTxtFn = belClass.checkTxtFn;
        systemCmdStr = sprintf('start WordPad.exe %s', checkTxtFn);
        system(systemCmdStr);
    end
end
% --- Executes on button press in pb_edf_sig_head_chk.
function pb_edf_sig_head_chk_Callback(hObject, eventdata, handles)
% hObject    handle to pb_edf_sig_head_chk (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if handles.edf_file_is_selected ==1
    % Get file name
    edf_fn = handles.edf_fn;
    edf_pn = handles.edf_pn;
    fn = strcat(edf_pn, edf_fn);
    
    % Load EDF
    belClass = BlockEdfLoadClass(fn);
    belClass.numCompToLoad = 2;
    belClass = belClass.blockEdfLoad;  
    belClass = belClass.CheckEdf;
    fprintf('Checking header and signal header: %s\n', edf_fn);
    
    % Display check
    belClass.DispCheck
    
    if handles.compiled == 1
        belClass.WriteCheck;
        checkTxtFn = belClass.checkTxtFn;
        systemCmdStr = sprintf('start WordPad.exe %s', checkTxtFn);
        system(systemCmdStr);
    end

    
%     if isempty(belClass.errMsg)
%         fprintf('\tNo error Messages found\n');
%     else
%         for m = 1:length(belClass.errMsg)
%             fprintf('\t%s\n',belClass.errMsg{m});
%         end
%     end
%     
%     % Write to file if compiled
%     if handles.compiled == 1
%         belClass.WriteCheck;
%         checkTxtFn = belClass.checkTxtFn;
%         systemCmdStr = sprintf('start WordPad.exe %s', checkTxtFn);
%         system(systemCmdStr);
%     end
end

% --- Executes on button press in pb_edf_deidentify.
function pb_edf_deidentify_Callback(hObject, eventdata, handles)
% hObject    handle to pb_edf_deidentify (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if handles.edf_file_is_loaded ==1
    warnStr = 'Please make a copy of the EDF before proceeding.  Deidentifying a file may result in corrupution. Do you want to continue?';
    button = questdlg(warnStr);
    
    % Proceed with deidentify, if requested
    if strcmp(button,'Yes')==1
        % Get file name
        edf_fn = handles.edf_fn;
        edf_pn = handles.edf_pn;
        fn = strcat(edf_pn, edf_fn);

        % Load EDF
        status = BlockEdfDeidentify(fn);
        
        % Echo status to conole
        if status >0
            fprintf('File deidentified successfully\n');
        else
            fprintf('File deidentified un-successfully. please check edf.\n');
        end
    end
    
    % Reload 
    pb_edf_LoadEdf_Callback(hObject, eventdata, handles)
    
    % Update handles structure
    guidata(hObject, handles);
end


% --- Executes on button press in cb_write_to_text_file.
function cb_write_to_text_file_Callback(hObject, eventdata, handles)
% hObject    handle to cb_write_to_text_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of cb_write_to_text_file

% Get check box value
value = get(handles.cb_write_to_text_file, 'value');
handles.compiled = value;

% Update handles structure
guidata(hObject, handles);
