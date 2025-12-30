function varargout = TrAQ(varargin)
% % TRAQ Main interface for tracking.
%   TRAQ launches the main working environment for capturing and analysing
%   behavioural videos. It allows you to configure detection parameters,
%   manage video files and launch tracking processes.
%
%   DESCRIPTION:
%   The system initialises user parameters from a “UserSettings.txt” file 
%   located in the root directory of the software. It manages video selection, 
%   test arena definition, and threshold parameter settings 
%   for image segmentation.
%
%   MAIN FUNCTIONS:
%   * Load Settings: Automatically reads threshold parameters, 
%     erosion and arena size at startup.
%   * File Selection: Allows you to choose the video file (.avi, .mp4, etc.) 
%     using a dedicated file browser.
%   * Arena Configuration: Manages the definition of the test area boundaries 
%     and background calculation.
%   * Parameter Control: Sliders and text fields to adjust grey thresholds, 
%     erosion levels and time parameters.
%   * Tracking Execution: Includes callbacks to start the process of 
%     extracting coordinates (Centroid, Head, Tail).
%
%   USAGE:
%   TrAQ               - Starts the main GUI.
%   h = TrAQ           - Returns the GUI handle.
%
%   TECHNICAL NOTES:
%   The function initialises a complex “handles” object that carries 
%   data between the different stages of analysis (OpeningFcn, OutputFcn and Callbacks).
%
%   See also: GUIDE, GUIDATA, RES_VIEW, VIDEOREADER.

% Author: [Davide Di Censo/MISPIN Lab - University of L'Aquila]
% Version: 2.5 (Modified on 30-Dec-2025)

% Edit the above text to modify the response to help TrAQ

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @TrAQ_OpeningFcn, ...
    'gui_OutputFcn',  @TrAQ_OutputFcn, ...
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

% --- Executes just before TrAQ is made visible.
function TrAQ_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to TrAQ (see VARARGIN)

% Choose default command line output for TrAQ
handles.output = hObject;

%load logo
path=mfilename('fullpath');
path=path(1:end-4);
logo_path=[path filesep 'logo.mat'];

load(logo_path);
axes(handles.logo_axes)
imshow(Logo,[])

user_settings_path = [path filesep 'UserSettings.txt'];
UserSettings=readtable(user_settings_path);
settings = table2array(UserSettings(:,3));

set(handles.arena_x,'String',(num2str(settings(1))));
set(handles.arena_y,'String',(num2str(settings(2))));
set(handles.detection_threshold_text,'String',(num2str(settings(3))));
set(handles.detection_threshold_slider,'Value',settings(3));
set(handles.detection_erosion_text,'String',settings(4));
set(handles.detection_erosion_slider,'Value',settings(4));
handles.movement_win=settings(6);
handles.Speed_thresh=settings(7);
handles.Area_th=settings(8);

% Update handles structure
guidata(hObject, handles);
% UIWAIT makes TrAQ wait for user response (see UIRESUME)
% uiwait(handles.TrAQ);

% --- Outputs from this function are returned to the command line.
function varargout = TrAQ_OutputFcn(~, ~, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in open_directory.
function open_directory_Callback(hObject, eventdata, handles)
% hObject    handle to open_directory (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.color_space=('grays');

uiwait(msgbox('Please select MAIN video directory','Select Dir','modal'));
handles.folder_name = uigetdir('select video file directory');

if handles.folder_name
    video_files(handles)
    video_file_listbox_Callback(handles.video_file_listbox,[], handles); 
end
DataFolder=[handles.folder_name filesep 'Results' filesep 'Raw'];

if ~exist(DataFolder,'dir')
    mkdir(DataFolder)
end



% --- Executes on selection change in video_file_listbox.
function video_file_listbox_Callback(hObject, eventdata, handles)
% hObject    handle to video_file_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isempty(handles.video_file_listbox.String)
    cla(handles.main_video_axes)
    handles.define_arena_button.Enable = 'off';
    handles.current_frame_info_text.String = '';
    return
else
    video_file = cellstr(get(handles.video_file_listbox,'String'));
    
    % reset info string
    handles.movie_info_text.String = [];
    
    cla(handles.main_video_axes)
    axes(handles.main_video_axes);
    handles.main_video_axes.YDir = 'reverse';
    hold on
    
    handles.vidfilename = [handles.folder_name filesep video_file{get(handles.video_file_listbox,'Value')}];    
    
    try
        evalin( 'base', 'clear arena')
        evalin( 'base', 'clear arena_centre')
    catch
    end
    
    handles.video=VideoReader(handles.vidfilename);
    SR = 1/handles.video.FrameRate;
    handles.SR = SR;
    handles.current_frame_slider.Value = 1;
    handles.current_frame_edit.String  = '1';
    handles.current_frame_slider.Max = handles.video.NumberOfFrames;
    handles.current_frame_slider.Min = 1;
    handles.last_frame_edit.String = num2str(handles.video.NumberOfFrames);
    handles.first_frame_edit.String = '1';
    
    onesecond = (1/handles.video.Duration);
    oneminute = (onesecond*60);
    try
        handles.current_frame_slider.SliderStep = [onesecond oneminute];
    catch
    end
    % update frame time string
    handles.go_to_time_edit.String = num2str(handles.SR * 1, '%.2f') ;
    guidata(handles.TrAQ, handles);
end

update_arena_image(handles);
update_arena_images(handles);
return
% Hints: video_file = cellstr(get(hObject,'String')) returns video_file_listbox video_file as cell array
%        video_file{get(hObject,'Value')} returns selected item from video_file_listbox

% --- Executes during object creation, after setting all properties.
function video_file_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to video_file_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function file_name_filter_edit_Callback(hObject, eventdata, handles)
video_files(handles);
video_file_listbox_Callback(hObject, eventdata, handles);

% --- Executes during object creation, after setting all properties.
function file_name_filter_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to file_name_filter_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function current_frame_edit_Callback(hObject, eventdata, handles)

editstr = str2double(get(handles.current_frame_edit,'String'));

if ~(editstr>=0 && editstr<=handles.video.NumberOfFrames-5)
    errordlg(['frame number must be an integer between 1 and (5 before) the last movie frame'],'frame range','modal');
    hObject.String = '1';
end

fn = round(str2double(get(handles.current_frame_edit,'String')));

handles.go_to_time_edit.String = num2str(handles.SR * fn, '%.2f');
handles.current_frame_edit.String = num2str(fn);
handles.current_frame_slider.Value = fn;
update_arena_image(handles);
update_arena_images(handles);

% --- Executes during object creation, after setting all properties.
function current_frame_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to current_frame_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on slider movement.
function current_frame_slider_Callback(hObject, eventdata, handles)

fn = round(get(handles.current_frame_slider,'Value'));

if fn < 1
    fn = 1;
elseif fn > handles.video.NumberOfFrames-5
    fn = handles.video.NumberOfFrames-5;
end

handles.current_frame_edit.String = num2str(fn);
% The edit frame callback will update the display
current_frame_edit_Callback(hObject, eventdata, handles);

% --- Executes during object creation, after setting all properties.
function current_frame_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to current_frame_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function go_to_time_edit_Callback(hObject, eventdata, handles)

frame = str2double(get(handles.current_frame_edit,'String'));
frametime = str2double(get(handles.go_to_time_edit,'String'));

if ~(frametime>=0 && frametime<=handles.video.Duration)
    errordlg(['Time value valid or out of movie range'],'frame range','modal');
    handles.go_to_time_edit.String = num2str(frame*handles.SR,'%.2f');
    return
end


% find the closest time to this frame
all_times = [1:handles.video.NumberOfFrames]*handles.SR;
[~,fn] = min(abs(all_times - frametime));

%but make sure it is not the last 5, which make the reader get stuck
fn = min(fn,handles.video.NumberOfFrames-5);

handles.current_frame_edit.String = num2str(fn);
handles.current_frame_slider.Value = fn;
update_arena_image(handles.current_frame_edit,handles,fn);
handles.video.CurrentTime = 0;

update_arena_images(handles.current_frame_edit,handles);
handles.video.CurrentTime = 0;

% --- Executes during object creation, after setting all properties.
function go_to_time_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to go_to_time_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in run_batch.
function run_batch_Callback(hObject, eventdata, handles)
% hObject    handle to run_batch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
tracker_batch(handles);

function first_frame_edit_Callback(hObject, eventdata, handles)
% hObject    handle to first_frame_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
editstr = str2double(get(hObject,'String'));

end_frame = str2double(handles.last_frame_edit.String);

if ~(editstr>=0 && editstr<=end_frame)
    errordlg(['frame number must be an integer between 1 and the ''end frame'' frame'],'frame range','modal');
    hObject.String = '1';
end
% Hints: get(hObject,'String') returns video_file of first_frame_edit as text
%        str2double(get(hObject,'String')) returns video_file of first_frame_edit as a double

% --- Executes during object creation, after setting all properties.
function first_frame_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to first_frame_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function last_frame_edit_Callback(hObject, eventdata, handles)
% hObject    handle to last_frame_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
editstr = str2double(get(hObject,'String'));
first_frame = str2double(handles.first_frame_edit.String);

if ~(editstr>=first_frame && editstr<=handles.video.NumberOfFrames)
    errordlg(['frame number must be an integer between the ''first frame'' and the last frame in the movie'],'frame range','modal');
    hObject.String = num2str(handles.video.NumberOfFrames);
end
% Hints: get(hObject,'String') returns video_file of last_frame_edit as text
%        str2double(get(hObject,'String')) returns video_file of last_frame_edit as a double

% --- Executes during object creation, after setting all properties.
function last_frame_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to last_frame_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function user_defined_settings_Callback(hObject, eventdata, handles)
% hObject    handle to user_defined_settings (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB

[P, base_name , ~] = fileparts(handles.vidfilename);
data_dir = [P filesep 'Results' filesep 'Raw' filesep 'Data'];

if ~exist(data_dir,'dir')
    mkdir(data_dir)
end

data_file_name = [data_dir filesep base_name,'_data.mat'];

calcolate_data = false; % control flag
if ~exist(data_file_name, 'file')
    calcolate_data = true;
else
    % if data file exist ask if overwrite
    choice = questdlg(['Data file ' base_name ' exists. Do you want to overwrite?'], ...
        'File Exists', ...
        'Yes', 'No', 'No');
    
    switch choice
        case 'Yes'
            calcolate_data = true;
            disp('Overwriting...');
        case 'No'
            calcolate_data = false;
            disp('Loading...');
            % Load data
            temp = load(data_file_name);
            data = temp.data;
            if isfield(data, 'Bkg')
                Bkg = data.Bkg;
            elseif isfield(handles, 'Bkg')
                Bkg = handles.Bkg;
            end
    end
end

if calcolate_data
    data = struct();
    e = evalin('base','who');
    
    if ismember('arena',e)
        data.arena = evalin('base','arena');
        data.arena_centre = evalin('base','arena_centre');
    else
        answer = questdlg('Defining arena is recommended if you have reflections. Are you sure you want to continue?','Arena Definition','Yes','No','No');
        switch answer
            case 'Yes'
                data.arena = 0;
                data.arena_centre = [0;0];
            case 'No'
                define_arena(handles.Bkg);
                uiwait
                data.arena = evalin('base','arena');
                data.arena_centre = evalin('base','arena_centre');
        end
    end

    % Background
    if ~isfield(handles, 'Bkg') && ~isempty(handles.Bkg)
        disp('Calculating Background...');
        data.i_start = str2double(get(handles.first_frame_edit, 'String'));
        data.i_end = str2double(get(handles.last_frame_edit, 'String'));
        handles.Bkg = Backgrounder(handles.video, handles.video.Height, handles.video.Width, data.i_start, data.i_end, handles.color_space);
        guidata(hObject, handles);
    end

    data.GreyThresh = str2double(get(handles.detection_threshold_text, 'String'));
    data.Erosion = str2double(get(handles.detection_erosion_text, 'String'));
    data.Area_th    = handles.Area_th;
    data.LiveView   = get(handles.live_tracking, 'Value');
    data.Bkg = handles.Bkg; 
    data.color_space = handles.color_space;
    data.vidHeight = handles.video.Height;
    data.vidWidth = handles.video.Width;
    data.nFrames_tot = handles.video.NumberOfFrames;
    data.i_start = str2double(get(handles.first_frame_edit, 'String'));
    data.i_end = str2double(get(handles.last_frame_edit, 'String'));
    data.arena_x = str2double(get(handles.arena_x, 'String'));
    data.arena_y = str2double(get(handles.arena_y, 'String'));
    
    if ~exist(data_dir,'dir')
        mkdir(data_dir)
    end
    
    save(data_file_name,'data');
    msgbox(['Data saved in ' data_file_name ])
end

if get(handles.batch_analysis, 'Value') == 1
    tracker_batch(handles);
else
    % Check vobj
    tracker(data, handles);
end

function detection_threshold_slider_Callback(hObject, eventdata, handles)
val = get(handles.detection_threshold_slider,'Value');
handles.detection_threshold_text.String = num2str(val);
update_arena_images(handles);
handles.video.CurrentTime = 0;
function detection_threshold_slider_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function detection_threshold_text_Callback(hObject, eventdata, handles)

editstr = get(handles.detection_threshold_text,'String');
val = str2double(editstr);

minV = handles.detection_threshold_slider.Min;
maxV = handles.detection_threshold_slider.Max;

if ~(isscalar(val))
    errordlg(['Threshold must be a number between ' num2str(minV) ' and ' num2str(maxV)],'image threshold','modal');
    handles.detection_threshold_text.String = '0.5';
    return
end

if val < handles.detection_threshold_slider.Min || val > handles.detection_threshold_slider.Max
    errordlg(['Threshold must be a number between ' num2str(minV) ' and ' num2str(maxV)],'image threshold','modal');
    handles.detection_threshold_text.String = '0.5';
    return
end

handles.detection_threshold_slider.Value = str2double(editstr);
update_arena_images(handles);

function detection_threshold_text_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on slider movement.
function detection_erosion_slider_Callback(hObject, eventdata, handles)
% hObject    handle to detection_erosion_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
val = get(handles.detection_erosion_slider,'Value');
handles.detection_erosion_text.String = num2str(val);
update_arena_images(handles);
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

% --- Executes during object creation, after setting all properties.
function detection_erosion_slider_CreateFcn(hObject, eventdata, handles)
% hObject    handle to detection_erosion_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function detection_erosion_text_Callback(hObject, eventdata, handles)
% hObject    handle to detection_erosion_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
editstr = get(handles.detection_erosion_text,'String');
val = str2double(editstr);

minV = handles.detection_erosion_slider.Min;
maxV = handles.detection_erosion_slider.Max;

if ~(isscalar(val))
    errordlg(['Erosion factor must be a number between ' num2str(minV) ' and ' num2str(maxV)],'image erosion','modal');
    handles.detection_erosion_text.String = '1';
    return
end

if val < handles.detection_erosion_slider.Min || val > handles.detection_erosion_slider.Max
    errordlg(['Erosion factor must be a number between ' num2str(minV) ' and ' num2str(maxV)],'image erosion','modal');
    handles.detection_erosion_text.String = '1';
    return
end

handles.detection_erosion_slider.Value = round(str2double(editstr));
update_arena_images(handles);
% Hints: get(hObject,'String') returns video_file of detection_erosion_text as text
%        str2double(get(hObject,'String')) returns video_file of detection_erosion_text as a double

% --- Executes during object creation, after setting all properties.
function detection_erosion_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to detection_erosion_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in save_button.
function save_button_Callback(hObject, eventdata, handles)
% hObject    handle to save_button (see GCBO)
e=evalin('base','who'); %get all the variables names present in the workspace
if ismember('arena',e)
    data.arena=evalin('base','arena');
    data.arena_centre=evalin('base','arena_centre');
else
    if ismember('arena',e)
        data.arena=evalin('base','arena');
        data.arena_centre=evalin('base','arena_centre');
    else
        answer = questdlg('defining arena is recommended if you have reflections. Are you sure you want to continue?','Arena Definition','Yes','No','No');
        switch answer
            case 'Yes'
                data.arena=[];
                data.arena_centre=[];
            case 'No'
                try
                    define_arena(handles.Bkg);
                catch
                    handles.Bkg=Backgrounder(video,vidHeight,vidWidth,i_start,i_end,handles.color_space);
                    define_arena(handles.Bkg);
                end
                uiwait
                data.arena=evalin('base','arena');
                data.arena_centre=evalin('base','arena_centre');
                update_arena_image(handles);
                update_arena_images(handles);
        end
        uiwait
    end
end
data.Bkg = handles.Bkg;
data.GreyThresh = str2double(handles.detection_threshold_text.String);
data.Erosion = str2double(get(handles.detection_erosion_text,'String'));
data.color_space = handles.color_space;
data.vidHeight = handles.video.Height;
data.vidWidth = handles.video.Width;
data.nFrames_tot = handles.video.NumberOfFrames;
data.i_start = str2double(handles.first_frame_edit.String);
data.i_end = str2double(handles.last_frame_edit.String);
data.arena_x = handles.arena_x.String;
data.arena_y = handles.arena_y.String;
[P, base_name , ~] = fileparts(handles.vidfilename);
data_dir = [P filesep 'Results' filesep 'Raw' filesep 'Data'];
if ~exist(data_dir,'dir')
    mkdir(data_dir)
end
data_file_name = [data_dir filesep base_name,'_data.mat'];
save(data_file_name,'data');
msgbox(['data saved in ' data_file_name ],'Save Data')

% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes on button press in load_button.
function load_button_Callback(hObject, eventdata, handles)
% hObject    handle to load_button (see GCBO)
[File, Directory, ~] = uigetfile({'*.*','All Files (*.*)'},'Select mat file', path);
StrFile=[Directory filesep File];
load(StrFile)
handles.Bkg = data.Bkg;

set(handles.detection_threshold_text,'String',num2str(data.GreyThresh));
set(handles.detection_threshold_slider,'Value',data.GreyThresh);
set(handles.detection_erosion_text,'String',num2str(data.Erosion));
set(handles.detection_erosion_slider,'Value',data.Erosion);
set(handles.arena_x,'String',num2str(data.arena_x));
set(handles.arena_y,'String',num2str(data.arena_y));
set(handles.first_frame_edit,'String',num2str(data.i_start));
set(handles.last_frame_edit,'String',num2str(data.i_end));
handles.color_space=data.color_space;

assignin('base','data', data);
assignin('base','arena', data.arena);
assignin('base','arena_centre', data.arena_centre);

update_arena_image(handles);
update_arena_images(handles);
guidata(hObject, handles);

% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

function arena_x_Callback(hObject, eventdata, handles)
% hObject    handle to arena_x (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
arena_x = str2double(handles.arena_x.String);
% Hints: get(hObject,'String') returns video_file of arena_x as text
%        str2double(get(hObject,'String')) returns video_file of arena_x as a double

% --- Executes during object creation, after setting all properties.
function arena_x_CreateFcn(hObject, eventdata, handles)
% hObject    handle to arena_x (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function arena_y_Callback(hObject, eventdata, handles)
% hObject    handle to arena_y (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
arena_y = str2double(handles.arena_y.String);
% Hints: get(hObject,'String') returns video_file of arena_y as text
%        str2double(get(hObject,'String')) returns video_file of arena_y as a double

% --- Executes during object creation, after setting all properties.
function arena_y_CreateFcn(hObject, eventdata, handles)
% hObject    handle to arena_y (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in draw_arena.
function draw_arena_Callback(hObject, eventdata, handles)
% hObject    handle to draw_arena (see GCBO)

% If updated, delete all previous (arena and text) objects
delete(findobj(handles.TrAQ,'Tag','ArenaBorder'));
delete(findobj(handles.TrAQ,'Tag','ArenaText'));
try
    Bkg=handles.Bkg;
catch
    errordlg('Background not defined, i''ll fix for you.');
    uiwait
    vidHeight = handles.video.Height;
    vidWidth = handles.video.Width;
    i_start=str2double(handles.first_frame_edit.String);
    i_end=str2double(handles.last_frame_edit.String);
    handles.Bkg=Backgrounder(video,vidHeight,vidWidth,i_start,i_end,handles.color_space);
    Bkg=handles.Bkg;
end
define_arena(Bkg);
uiwait
update_arena_image(handles);
guidata(hObject, handles);

% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes on button press in calculate_background.
function calculate_background_Callback(hObject, eventdata, handles)
% hObject    handle to calculate_background (see GCBO)
vidHeight = handles.video.Height;
vidWidth = handles.video.Width;
i_start=str2double(handles.first_frame_edit.String);
i_end=str2double(handles.last_frame_edit.String);
handles.Bkg=Backgrounder(handles.video,vidHeight,vidWidth,i_start,i_end,handles.color_space);
handles.video.CurrentTime = 0;
figure
imshow(handles.Bkg,[])
guidata(hObject, handles);
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes on button press in results.
function results_Callback(hObject, eventdata, handles)
% hObject    handle to results (see GCBO)
Res_View
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes when selected object is changed in color_space_selector.
function color_space_selector_SelectionChangedFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in color_space_selector
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

switch(get(eventdata.NewValue,'Tag'))
    case 'grays'
        handles.color_space=('grays');
        update_arena_images(handles);
    case 'red'
        handles.color_space=('red');
        update_arena_images(handles);
    case 'green'
        handles.color_space=('green');
        update_arena_images(handles);
    case 'blue'
        handles.color_space=('blue');
        update_arena_images(handles);
end

function color_space_selector_CreateFcn(hObject, eventdata, handles)
% hObject    handle to analysis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes during object creation, after setting all properties.
function main_video_axes_CreateFcn(hObject, eventdata, handles)
% hObject    handle to main_video_axes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate main_video_axes

% --- Executes on button press in grays.
function grays_Callback(hObject, eventdata, handles)
% hObject    handle to grays (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of grays

% --- Executes on button press in live_tracking.
function live_tracking_Callback(hObject, eventdata, handles)
% hObject    handle to live_tracking (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of live_tracking

% --- Executes on button press in batch_analysis.
function batch_analysis_Callback(hObject, eventdata, handles)
% hObject    handle to batch_analysis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of batch_analysis
