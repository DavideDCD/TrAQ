function varargout = Res_View(varargin)
% RES_VIEW MATLAB code for Res_View.fig
%      RES_VIEW, by itself, creates a new RES_VIEW or raises the existing
%      singleton*.
%
%      H = RES_VIEW returns the handle to a new RES_VIEW or the handle to
%      the existing singleton*.
%
%      RES_VIEW('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in RES_VIEW.M with the given input arguments.
%
% %      RES_VIEW('Property','Value',...) creates a new RES_VIEW or raises the
% %      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Res_View_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Res_View_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Res_View

% Last Modified by GUIDE v2.5 21-Mar-2020 14:00:20

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @Res_View_OpeningFcn, ...
    'gui_OutputFcn',  @Res_View_OutputFcn, ...
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

% --- Executes just before Res_View is made visible.
function Res_View_OpeningFcn(hObject, ~, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Res_View (see VARARGIN)

% Choose default command line output for Res_View
handles.output = hObject;

%load logo
path=mfilename('fullpath');
path=path(1:end-8);


user_settings_path = [path filesep 'UserSettings.txt'];
UserSettings=readtable(user_settings_path);
settings = table2array(UserSettings(:,3));

% handles.movement_win=settings(6);
% set(handles.M_thresh,'String',(num2str(settings(5))));
set(handles.v_thresh,'String',(num2str(settings(5))));
handles.Theta=settings(7);
handles.N=settings(8);
logo_path=[path filesep 'logo.mat'];

img=load(logo_path);
axes(handles.logo_axes)
imshow(img.Logo,[])

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Res_View wait for user response (see UIRESUME)
% uiwait(handles.Res_View);

% --- Outputs from this function are returned to the command line.
function varargout = Res_View_OutputFcn(hObject, ~, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
guidata(hObject, handles);

% --- Executes on button press in open_directory_2.
function open_directory_2_Callback(~, ~, handles)
% hObject    handle to open_directory_2 (see GCBO)
uiwait(msgbox('Please select MAIN video directory','Select Dir','modal'));

folder_name = uigetdir('select video file directory');

if folder_name
    handles.video_dir_text.String = folder_name;
    video_files(handles)
    video_file_listbox_Callback(handles.video_file_listbox,[], handles);
end
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes on selection change in video_file_listbox.
function video_file_listbox_Callback(hObject, ~, handles)
% hObject    handle to video_file_listbox (see GCBO)
global video vidfilename

if isempty(handles.video_file_listbox.String)
    cla(handles.oden_video_axes)
    handles.current_frame_info_text.String = '';
    return
else
    
    video_file = cellstr(get(handles.video_file_listbox,'String'));
    
    cla(handles.oden_video_axes)
    axes(handles.oden_video_axes);
    handles.oden_video_axes.YDir = 'reverse';
    hold on
    
    vidfilename = [handles.video_dir_text.String filesep video_file{get(handles.video_file_listbox,'Value')}];
    
    video=VideoReader(vidfilename);
    videodata.VideoWidth = video.Width;
    videodata.VideoHeight = video.Height;
    videodata.Nframes = video.NumberOfFrames;
    videodata.vidfilename = vidfilename;
    videodata.duration = video.Duration;
    videodata.framerate=video.FrameRate;
    SR = 1/videodata.framerate;
    handles.SR = SR;
    handles.videodata = videodata;
    handles.current_frame_slider.Value = 1;
    handles.current_frame_edit.String  = '1';
    handles.current_frame_slider.Max = videodata.Nframes;
    handles.current_frame_slider.Min = 1;
    handles.last_time_edit.String = num2str(videodata.Nframes/handles.videodata.framerate);
    handles.first_time_edit.String = '1';
    
    onesecond = (1/videodata.duration);
    oneminute = (onesecond*60);
    
    try
        handles.current_frame_slider.SliderStep = [onesecond oneminute];
    catch
    end
    % update frame time string
    handles.go_to_time_edit.String = num2str(handles.SR * 1, '%.2f') ;
    
    guidata(handles.Res_View, handles);
end

[P, base_name , ~] = fileparts(vidfilename);
data_dir = [P filesep 'Results' filesep 'Raw' filesep 'Data'];
data_file_name = [data_dir filesep base_name '_data'];
StrTrack=[P filesep 'Results' filesep 'Raw' filesep 'Out_' base_name];
trackdata=[P filesep 'Results' filesep 'Out_' base_name];
load(data_file_name);
handles.data=data;
x1=min(handles.data.arena(:,1));
x2=max(handles.data.arena(:,1));
y1=min(handles.data.arena(:,2));
y2=max(handles.data.arena(:,2));
handles.lvl=mean(mean(data.Bkg(y1:y2,x1:x2)));
try
    Tracked=load(trackdata);
    handles.track=Tracked.track;
    i_first=Tracked.data.i_first;
    i_last=Tracked.data.i_last;
    
    handles.track.Time=0:1/videodata.framerate:(videodata.Nframes-1)/videodata.framerate;
    handles.Time = Tracked.track.Time;
    if handles.data.arena==0
        msgbox('Please define the Arena');
        uiwait
        define_arena(data.Bkg);
        uiwait
        handles.data.arena=evalin('base','arena');
        handles.data.arena_centre=evalin('base','arena_centre');
    end
    
    D1=x2-x1;
    D2=y2-y1;
    
    Xaxis=str2double(data.arena_x);
    
    pixels_per_cm=D1/Xaxis;
    
    
    try
        handles.Centroid = Tracked.track.Centroid_px;
        handles.Tail = Tracked.track.Tail_px;
        handles.Head = Tracked.track.Head_px;
    catch
        handles.Centroid = zeros(2,videodata.Nframes);
        handles.Centroid(:,i_first:i_last)=Tracked.track.Centroid;
        handles.Head = zeros(2,videodata.Nframes);
        handles.Head(:,i_first:i_last)=Tracked.track.Head;
        handles.Tail = zeros(2,videodata.Nframes);
        handles.Tail(:,i_first:i_last)=Tracked.track.Tail;
        
        for i=i_first:i_last
            handles.Centroid(1,i)=(handles.Centroid(1,i)*pixels_per_cm)+x1;
            handles.Centroid(2,i)=D2-(handles.Centroid(2,i)*pixels_per_cm)+y1;
            handles.Head(1,i)=(handles.Head(1,i)*pixels_per_cm)+x1;
            handles.Head(2,i)=D2-(handles.Head(2,i)*pixels_per_cm)+y1;
            handles.Tail(1,i)=(handles.Tail(1,i)*pixels_per_cm)+x1;
            handles.Tail(2,i)=D2-(handles.Tail(2,i)*pixels_per_cm)+y1;
        end
    end
    try
        Tracked=load(StrTrack);
        handles.track.ConvexHull=Tracked.track.ConvexHull;
    catch
    end
catch

    Tracked=load(StrTrack);
    handles.track=Tracked.track;
    if handles.data.arena==0
        msgbox('Please define the Arena');
        uiwait
        define_arena(data.Bkg);
        uiwait
        handles.data.arena=evalin('base','arena');
        handles.data.arena_centre=evalin('base','arena_centre');
    end
    Tracked=load(StrTrack);
    handles.track=Tracked.track;
    handles.Centroid=Tracked.track.Centroid;
    handles.Head=Tracked.track.Head;
    handles.bkHead=[];
    handles.Tail=Tracked.track.Tail;
    handles.Time=Tracked.track.Time;
end
    
handles.zones=[];
guidata(hObject, handles);
update_arena_track(handles)
update_arena_plot(handles)
return
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: video_file = cellstr(get(hObject,'String')) returns video_file_listbox video_file as cell array
%        video_file{get(hObject,'Value')} returns selected item from video_file_listbox

% --- Executes during object creation, after setting all properties.
function video_file_listbox_CreateFcn(hObject, ~, ~)
% hObject    handle to video_file_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on slider movement.
function current_frame_slider_Callback(hObject, eventdata, handles)
% hObject    handle to current_frame_slider (see GCBO)
fn = round(get(handles.current_frame_slider,'Value'));

if fn < 1
    fn = 1;
elseif fn > handles.videodata.Nframes-5
    fn = handles.videodata.Nframes-5;
end

handles.current_frame_edit.String = num2str(fn);
% The edit frame callback will update the display
current_frame_edit_Callback(hObject, eventdata, handles);
guidata(hObject, handles);

% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider

% --- Executes during object creation, after setting all properties.
function current_frame_slider_CreateFcn(hObject, ~, ~)
% hObject    handle to current_frame_slider (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end

function go_to_time_edit_Callback(hObject, ~, handles)
% hObject    handle to go_to_time_edit (see GCBO)

frame = str2double(get(handles.current_frame_edit,'String'));
frametime = str2double(get(handles.go_to_time_edit,'String'));

if ~(frametime>=0 && frametime<=handles.videodata.duration)
    errordlg(['Time value valid or out of video range'],'frame range','modal');
    handles.go_to_time_edit.String = num2str(frame*handles.SR,'%.2f');
    return
end

% find the closest time to this frame
all_times = [1:handles.videodata.Nframes]*handles.SR;
[~,fn] = min(abs(all_times - frametime));

%but make sure it is not the last 5, which make the reader get stuck
fn = min(fn,handles.videodata.Nframes-5);

handles.current_frame_edit.String = num2str(fn);
handles.current_frame_slider.Value = fn;
update_arena_track(handles);
guidata(hObject, handles);

% update_arena_images(handles.current_frame_edit,handles);
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns video_file of go_to_time_edit as text
%        str2double(get(hObject,'String')) returns video_file of go_to_time_edit as a double

% --- Executes during object creation, after setting all properties.
function go_to_time_edit_CreateFcn(hObject, ~, ~)
% hObject    handle to go_to_time_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function current_frame_edit_Callback(hObject, ~, handles)
% hObject    handle to current_frame_edit (see GCBO)

editstr = str2double(get(handles.current_frame_edit,'String'));

if ~(editstr>=1 && editstr<=handles.videodata.Nframes-5)
    errordlg(['frame number must be an integer between 1 and (5 before) the last video frame'],'frame range','modal');
    hObject.String = '1';
end

fn = round(str2double(get(handles.current_frame_edit,'String')));
handles.go_to_time_edit.String = num2str(handles.SR * fn, '%.2f');
handles.current_frame_edit.String = num2str(fn);
handles.current_frame_slider.Value = fn;
try
    update_arena_track(handles);
catch
end
guidata(hObject, handles);

% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns video_file of current_frame_edit as text
%        str2double(get(hObject,'String')) returns video_file of current_frame_edit as a double

% --- Executes during object creation, after setting all properties.
function current_frame_edit_CreateFcn(hObject, ~, ~)
% hObject    handle to current_frame_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in plot_handles.Head.
function plot_head_Callback(~, ~, handles)
% hObject    handle to plot_handles.Head (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
update_arena_plot(handles)

% Hint: get(hObject,'Value') returns toggle state of plot_handles.Head

% --- Executes on button press in plot_handles.Centroid.
function plot_centroid_Callback(~, ~, handles)
% hObject    handle to plot_handles.Centroid (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
update_arena_plot(handles)

% Hint: get(hObject,'Value') returns toggle state of plot_handles.Centroid

% --- Executes on button press in plot_handles.Tail.
function plot_tail_Callback(~, ~, handles)
% hObject    handle to plot_handles.Tail (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
update_arena_plot(handles)

% Hint: get(hObject,'Value') returns toggle state of plot_handles.Tail

function mobile_window_size_Callback(~, ~, ~)
% hObject    handle to mobile_window_size (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns video_file of mobile_window_size as text
%        str2double(get(hObject,'String')) returns video_file of mobile_window_size as a double

% --- Executes during object creation, after setting all properties.
function mobile_window_size_CreateFcn(hObject, ~, ~)
% hObject    handle to mobile_window_size (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function first_time_edit_Callback(hObject, ~, handles)
% hObject    handle to first_time_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

editstr = str2double(get(hObject,'String'));

end_frame = str2double(handles.last_time_edit.String);

if ~(editstr>0 && editstr<=end_frame)
    errordlg(['frame number must be an integer between 1 and the ''end frame'' frame'],'frame range','modal');
    hObject.String = '1';
end
update_arena_plot(handles)
% Hints: get(hObject,'String') returns video_file of first_time_edit as text
%        str2double(get(hObject,'String')) returns video_file of first_time_edit as a double

% --- Executes during object creation, after setting all properties.
function first_time_edit_CreateFcn(hObject, ~, ~)
% hObject    handle to first_time_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function last_time_edit_Callback(hObject, ~, handles)
% hObject    handle to last_time_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
editstr = str2double(get(hObject,'String'));
first_time = str2double(handles.first_time_edit.String);

if ~(editstr>=first_time && editstr<=handles.videodata.Nframes)
    errordlg(['frame number must be an integer between the ''first frame'' and the last frame in the video'],'frame range','modal');
    hObject.String = num2str(handles.videodata.Nframes);
end
update_arena_plot(handles)
% Hints: get(hObject,'String') returns video_file of last_time_edit as text
%        str2double(get(hObject,'String')) returns video_file of last_time_edit as a double

% --- Executes during object creation, after setting all properties.
function last_time_edit_CreateFcn(hObject, ~, ~)
% hObject    handle to last_time_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in figure_track.
function figure_track_Callback(hObject, ~, handles)
% hObject    handle to figure_track (see GCBO)
X1=round(min(handles.data.arena(:,1)));
X2=round(max(handles.data.arena(:,1)));
Y1=round(min(handles.data.arena(:,2)));
Y2=round(max(handles.data.arena(:,2)));
i_first=floor((str2double(handles.first_time_edit.String))*handles.videodata.framerate);
i_last=floor((str2double(handles.last_time_edit.String))*handles.videodata.framerate);
D1=X2-X1;
D2=Y2-Y1;
Xaxis=str2double(handles.data.arena_x);
Yaxis=str2double(handles.data.arena_y);

%rescale trajectories
Centroid=handles.Centroid;

for i=i_first:i_last
    Centroid(1,i)=(Centroid(1,i)-X1)/D1*Xaxis;
    Centroid(2,i)=Yaxis-(Centroid(2,i)-Y1)/D2*Yaxis;
end

figure
plot(Centroid(1,i_first:i_last)',Centroid(2,i_first:i_last)','b')
h=convhull(Centroid(1,:)',Centroid(2,:)');
axis ([0 Xaxis 0 Yaxis])
hold on
plot(Centroid(1,i_first)',Centroid(2,i_first)','r>','MarkerSize',10)
plot(Centroid(1,i_last)',Centroid(2,i_last)','rs','MarkerSize',10)
plot(Centroid(1,h)',Centroid(2,h)','g')
hold off
xt = (0:10:Xaxis);
yt = (0:10:Yaxis);
set(gca, 'XTick', xt)             % Relabel 'XTick'
set(gca, 'YTick', yt)             % Relabel 'YTick'
xlabel('X [cm]'); ylabel('Y [cm]');
title('Arena Centroid Track Recording')
handles.scaled_Centroid=Centroid;
guidata(hObject, handles);

handles.scaled_Centroid=Centroid;
guidata(hObject, handles);
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes on button press in figure_heat_map.
function figure_heat_map_Callback(hObject, ~, handles)
% hObject    handle to figure_heat_map (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%%**************** Heatmap
i_first=floor((str2double(handles.first_time_edit.String))*handles.videodata.framerate);
i_last=floor((str2double(handles.last_time_edit.String))*handles.videodata.framerate);

%%********Arena Dimensions
X1=min(handles.data.arena(:,1));
X2=max(handles.data.arena(:,1));
Y1=min(handles.data.arena(:,2));
Y2=max(handles.data.arena(:,2));
D1=X2-X1;
D2=Y2-Y1;

Xaxis=floor(str2double(handles.data.arena_x));
Yaxis=floor(str2double(handles.data.arena_y));

if floor(Xaxis/2)*2 == Xaxis
else
    Xaxis=Xaxis+1;
end

if floor(Yaxis/2)*2 == Yaxis
else
    Yaxis=Yaxis+1;
end

P_distrib=zeros(Yaxis,Xaxis);
for i=i_first+30:i_last-30
    %     if handles.Vt(i)==1
    column=1+floor((Xaxis-1)*(handles.Centroid(1,i)-X1)/D1); % coarse column index
    row=Yaxis-floor((Yaxis-1)*(handles.Centroid(2,i)-Y1)/D2); % coarse row index    
    P_distrib(row,column)=P_distrib(row,column)+1;
    %     end
end

k_distrib=fftshift(fftn(P_distrib));
[Mx,My]=size(k_distrib);
filter=tukeyfilter(k_distrib,Mx,25,My,25); 
k_distrib = k_distrib .* filter.^5;
P_distrib = abs(ifftn((fftshift(k_distrib))));


P_distrib=P_distrib/max(max(P_distrib));
% Define integer grid of coordinates for the above data
[X,Y] = meshgrid(1:size(P_distrib,2), 1:size(P_distrib,1));

% Define a finer grid of points
[X2,Y2] = meshgrid(1:0.01:size(P_distrib,2), 1:0.01:size(P_distrib,1));

% Interpolate the data and show the output
outData = interp2(X, Y, P_distrib, X2, Y2, 'cubic');
outData(outData<0) = 0;
outData=flip(outData,1);
figure;
colormap(jet);
imagesc(outData);
xt = get(gca, 'XTick');
yt = get(gca, 'YTick');
set(gca, 'XTick', xt, 'XTickLabel', xt/100)             % Relabel 'XTick'
set(gca, 'YTick', yt, 'YTickLabel', yt/100)             % Relabel 'YTick'
xlabel('X [cm]'); ylabel('Y [cm]');
% Add colour bar
colorbar;
title('Arena Heatmap')

% try
%     P_distrib=zeros(Yaxis,Xaxis);
%     for i=i_first:i_last
%         if handles.Vt(i)==1
%             column=1+floor((Xaxis-1)*(handles.Centroid(1,i)-X1)/D1); % coarse column index
%             row=Yaxis-floor((Yaxis-1)*(handles.Centroid(2,i)-Y1)/D2); % coarse row index
%             P_distrib(row,column)=P_distrib(row,column)+1;
%         end
%     end
% %     
% %     k_distrib=fftshift(fftn(P_distrib));
% %     [Mx,My]=size(k_distrib);
% %     filter=tukeyfilter(k_distrib,Mx,25,My,25);
% %     k_distrib = k_distrib .* filter.^5;
% %     P_distrib = abs(ifftn((fftshift(k_distrib))));
%     
%     P_distrib=P_distrib/max(max(P_distrib));
%     % Define integer grid of coordinates for the above data
%     [X,Y] = meshgrid(1:size(P_distrib,2), 1:size(P_distrib,1));
%     
%     % Define a finer grid of points
%     [X2,Y2] = meshgrid(1:0.01:size(P_distrib,2), 1:0.01:size(P_distrib,1));
%     
%     % Interpolate the data and show the output
%     outData = interp2(X, Y, P_distrib, X2, Y2, 'cubic');
%     outData(outData<0) = 0;
%     outData=flip(outData,1);
%     figure;
%     colormap(jet);
%     imagesc(outData);
%     xt = get(gca, 'XTick');
%     yt = get(gca, 'YTick');
%     set(gca, 'XTick', xt, 'XTickLabel', xt/100)             % Relabel 'XTick'
%     set(gca, 'YTick', yt, 'YTickLabel', yt/100)             % Relabel 'YTick'
%     xlabel('X [cm]'); ylabel('Y [cm]');
%     % Add colour bar
%     colorbar;
%     title('Unbiased Arena Heatmap')
% catch
%     X1=round(min(handles.data.arena(:,1)));
%     X2=round(max(handles.data.arena(:,1)));
%     Y1=round(min(handles.data.arena(:,2)));
%     Y2=round(max(handles.data.arena(:,2)));
%     Xaxis=str2double(handles.data.arena_x);
%     Yaxis=str2double(handles.data.arena_y);
%     
%     if handles.videodata.framerate*(str2double(handles.first_time_edit.String))>handles.data.i_start
%         i_first=floor(handles.videodata.framerate*(str2double(handles.first_time_edit.String)));
%     else
%         i_first=handles.data.i_start;
%     end
%     
%     if handles.videodata.framerate*(str2double(handles.last_time_edit.String))<handles.data.i_end
%         i_last=floor(handles.videodata.framerate*(str2double(handles.last_time_edit.String)));
%     else
%         i_last=handles.data.i_end;
%     end
%     
%     D1=X2-X1;
%     D2=Y2-Y1;
%     Time=handles.track.Time;
%     
%     %rescale trajectories
%     Centroid=handles.Centroid;
%     
%     for i=1:length(Centroid)
%         Centroid(1,i)=(Centroid(1,i)-X1)/D2*Xaxis;
%         Centroid(2,i)=Yaxis-(Centroid(2,i)-Y1)/D1*Yaxis;
%     end
%     Vx=zeros(1,length(Centroid));
%     Vy=zeros(1,length(Centroid));
%     for i=1:length(Centroid)-1
%         Vx(i)=(Centroid(1,i+1)-Centroid(1,i))/(Time(i+1)-Time(i));
%         Vy(i)=(Centroid(2,i+1)-Centroid(2,i))/(Time(i+1)-Time(i));
%     end
%     Vx(1,i_last)=Vx(1,i_last-1);
%     Vy(1,i_last)=Vy(1,i_last-1);
%     V=sqrt(Vx.^2+Vy.^2);
%     for i=i_first:i_last-1
%         if V(i) > 100
%             if i == i_first
%                 V(i) = 0;
%             else
%                 V(i)=V(i-1);
%             end
%         end
%     end
%     
%     v_thresh=str2double(get(handles.v_thresh,'String'));
%     Vt=zeros(1,handles.data.nFrames_tot);
%     
%     for i=1:i_first:i_last-1
%         if V(i) < v_thresh
%             Vt(i)=0;
%         else
%             Vt(i)=1;
%         end
%     end
%     
%     if floor(Xaxis/2)*2 == Xaxis
%         Xaxis=floor(Xaxis);
%     else
%         Xaxis=floor(Xaxis+1);
%     end
%     
%     if floor(Yaxis/2)*2 == Yaxis
%         Yaxis=floor(Yaxis);
%     else
%         Yaxis=floor(Yaxis+1);
%     end
%     
%     P_distrib=zeros(Yaxis,Xaxis);
%     for i=i_first:i_last
%         if Vt(i)==1
%             column=1+floor((Xaxis-1)*(handles.Centroid(1,i)-X1)/D1); % coarse column index
%             row=Yaxis-floor((Yaxis-1)*(handles.Centroid(2,i)-Y1)/D2); % coarse row index
%             P_distrib(row,column)=P_distrib(row,column)+1;
%         end
%     end
%     
% %     k_distrib=fftshift(fftn(P_distrib));
% %     [Mx,My]=size(k_distrib);
% %     filter=tukeyfilter(k_distrib,Mx,25,My,25);
% %     k_distrib = k_distrib .* filter.^5;
% %     P_distrib = abs(ifftn((fftshift(k_distrib))));
%     
%     P_distrib=P_distrib/max(max(P_distrib));
%     % Define integer grid of coordinates for the above data
%     [X,Y] = meshgrid(1:size(P_distrib,2), 1:size(P_distrib,1));
%     
%     % Define a finer grid of points
%     [X2,Y2] = meshgrid(1:0.01:size(P_distrib,2), 1:0.01:size(P_distrib,1));
%     
%     % Interpolate the data and show the output
%     outData = interp2(X, Y, P_distrib, X2, Y2, 'cubic');
%     outData(outData<0) = 0;
%     outData=flip(outData,1);
%     figure;
%     colormap(jet);
%     imagesc(outData);
%     xt = get(gca, 'XTick');
%     yt = get(gca, 'YTick');
%     set(gca, 'XTick', xt, 'XTickLabel', xt/100)             % Relabel 'XTick'
%     set(gca, 'YTick', yt, 'YTickLabel', yt/100)             % Relabel 'YTick'
%     xlabel('X [cm]'); ylabel('Y [cm]');
%     % Add colour bar
%     colorbar;
%     title('Unbiased Arena Heatmap')
% end

guidata(hObject, handles);

% --- Executes on button press in figure_probability.
function figure_probability_Callback(~, ~, handles)
% hObject    handle to figure_probability (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

%get all the variables names present in the workspace
i_first=floor((str2double(handles.first_time_edit.String))*handles.videodata.framerate);
i_last=floor((str2double(handles.last_time_edit.String))*handles.videodata.framerate);

%%********Arena Dimensions
X1=min(handles.data.arena(:,1));
X2=max(handles.data.arena(:,1));
Y1=min(handles.data.arena(:,2));
Y2=max(handles.data.arena(:,2));

D1=X2-X1;
D2=Y2-Y1;

N_sectors=str2double(get(handles.n_sectors,'String'));
P_distrib=zeros(N_sectors,N_sectors);
Nframes=i_last-i_first+1;
try
    for i=i_first:i_last
        column=1+floor((N_sectors-1)*(handles.Centroid(1,i)-X1)/D1); % coarse column index
        row=N_sectors-floor((N_sectors-1)*(handles.Centroid(2,i)-Y1)/D2); % coarse row index
        P_distrib(row,column)=P_distrib(row,column)+1;
    end
    P_distrib=P_distrib/Nframes;
    Max_P=max(max(P_distrib));
    P_distrib=flip(P_distrib,1);
    figure
    h=bar3(P_distrib);
    view([-14 28]);
    for k = 1:length(h)
        zdata = get(h(k),'ZData');
        set(h(k),'CData',zdata,'FaceColor','interp');
    end
    axis([0 N_sectors+1 0 N_sectors+1 -0.01 1.1*Max_P ])
    colorbar
    xlabel('X'); ylabel('Y');
    title('Arena Sectors Occupation Probability')
catch
    errordlg(['This function requires a square arena'],'modal');
end

% try
%     P_distrib=zeros(N_sectors,N_sectors);
%     for i=i_first:i_last
%         if handles.Vt(i)==1
%             column=1+floor((N_sectors-1)*(handles.Centroid(1,i)-X1)/D1); % coarse column index
%             row=N_sectors-floor((N_sectors-1)*(handles.Centroid(2,i)-Y1)/D2); % coarse row index
%             P_distrib(row,column)=P_distrib(row,column)+1;
%         end
%     end
%     
%     P_distrib=P_distrib/Nframes;
%     Max_P=max(max(P_distrib));
%     P_distrib=flip(P_distrib,1);
%     figure
%     h=bar3(P_distrib);
%     view([-14 28]);
%     for k = 1:length(h)
%         zdata = get(h(k),'ZData');
%         set(h(k),'CData',zdata,'FaceColor','interp');
%     end
%     axis([0 N_sectors+1 0 N_sectors+1 -0.01 1.1*Max_P ])
%     colorbar
%     xlabel('X'); ylabel('Y');
%     title('Unbiased Overall Arena Sectors Occupation Probability')
%     
% catch
%     X1=round(min(handles.data.arena(:,1)));
%     X2=round(max(handles.data.arena(:,1)));
%     Y1=round(min(handles.data.arena(:,2)));
%     Y2=round(max(handles.data.arena(:,2)));
%     Xaxis=str2double(handles.data.arena_x);
%     Yaxis=str2double(handles.data.arena_y);
%     
%     if handles.videodata.framerate*(str2double(handles.first_time_edit.String))>handles.data.i_start
%         i_first=floor(handles.videodata.framerate*(str2double(handles.first_time_edit.String)));
%     else
%         i_first=handles.data.i_start;
%     end
%     
%     if handles.videodata.framerate*(str2double(handles.last_time_edit.String))<handles.data.i_end
%         i_last=floor(handles.videodata.framerate*(str2double(handles.last_time_edit.String)));
%     else
%         i_last=handles.data.i_end;
%     end
%     
%     D1=X2-X1;
%     D2=Y2-Y1;
%     Time=handles.track.Time;
%     
%     %rescale trajectories
%     Centroid=handles.Centroid;
%     
%     for i=1:length(Centroid)
%         Centroid(1,i)=(Centroid(1,i)-X1)/D2*Xaxis;
%         Centroid(2,i)=Yaxis-(Centroid(2,i)-Y1)/D1*Yaxis;
%     end
%     Vx=zeros(1,length(Centroid));
%     Vy=zeros(1,length(Centroid));
%     for i=1:length(Centroid)-1
%         Vx(i)=(Centroid(1,i+1)-Centroid(1,i))/(Time(i+1)-Time(i));
%         Vy(i)=(Centroid(2,i+1)-Centroid(2,i))/(Time(i+1)-Time(i));
%     end
%     Vx(1,i_last)=Vx(1,i_last-1);
%     Vy(1,i_last)=Vy(1,i_last-1);
%     V=sqrt(Vx.^2+Vy.^2);
%     for i=i_first:i_last-1
%         if V(i) > 100
%             if i == i_first
%                 V(i) = 0;
%             else
%                 V(i)=V(i-1);
%             end
%         end
%     end
%     
%     v_thresh=str2double(get(handles.v_thresh,'String'));
%     Vt=zeros(1,handles.data.nFrames_tot);
%     
%     for i=1:i_first:i_last-1
%         if V(i) < v_thresh
%             Vt(i)=0;
%         else
%             Vt(i)=1;
%         end
%     end
%     
%     P_distrib=zeros(N_sectors,N_sectors);
%     for i=i_first:i_last
%         if Vt(i)==1
%             column=1+floor((N_sectors-1)*(handles.Centroid(1,i)-X1)/D1); % coarse column index
%             row=N_sectors-floor((N_sectors-1)*(handles.Centroid(2,i)-Y1)/D2); % coarse row index
%             P_distrib(row,column)=P_distrib(row,column)+1;
%         end
%     end
%     
%     P_distrib=P_distrib/Nframes;
%     Max_P=max(max(P_distrib));
%     P_distrib=flip(P_distrib,1);
%     figure
%     h=bar3(P_distrib);
%     view([-14 28]);
%     for k = 1:length(h)
%         zdata = get(h(k),'ZData');
%         set(h(k),'CData',zdata,'FaceColor','interp');
%     end
%     axis([0 N_sectors+1 0 N_sectors+1 -0.01 1.1*Max_P ])
%     colorbar
%     xlabel('X'); ylabel('Y');
%     title('Unbiased Overall Arena Sectors Occupation Probability')
% end


% --- Executes on button press in figure_velocity.
function figure_velocity_Callback(hObject, ~, handles)
% hObject    handle to figure_velocity (see GCBO)
X1=round(min(handles.data.arena(:,1)));
X2=round(max(handles.data.arena(:,1)));
Y1=round(min(handles.data.arena(:,2)));
Y2=round(max(handles.data.arena(:,2)));
Xaxis=str2double(handles.data.arena_x);
Yaxis=str2double(handles.data.arena_y);

if handles.videodata.framerate*(str2double(handles.first_time_edit.String))>handles.data.i_start
    i_first=floor(handles.videodata.framerate*(str2double(handles.first_time_edit.String)));
else
    i_first=handles.data.i_start;
end

if handles.videodata.framerate*(str2double(handles.last_time_edit.String))<handles.data.i_end
    i_last=floor(handles.videodata.framerate*(str2double(handles.last_time_edit.String)));
else
    i_last=handles.data.i_end;
end

D1=X2-X1;
D2=Y2-Y1;
Time=handles.track.Time;

%rescale trajectories
Centroid=handles.Centroid;

for i=1:length(Centroid)
    Centroid(1,i)=(Centroid(1,i)-X1)/D2*Xaxis;
    Centroid(2,i)=Yaxis-(Centroid(2,i)-Y1)/D1*Yaxis;
end
Vx=zeros(1,length(Centroid));
Vy=zeros(1,length(Centroid));
for i=1:length(Centroid)-1
    Vx(i)=(Centroid(1,i+1)-Centroid(1,i))/(Time(i+1)-Time(i));
    Vy(i)=(Centroid(2,i+1)-Centroid(2,i))/(Time(i+1)-Time(i));
end
Vx(1,i_last)=Vx(1,i_last-1);
Vy(1,i_last)=Vy(1,i_last-1);
V=sqrt(Vx.^2+Vy.^2);
for i=i_first:i_last-1
    if V(i) > 100
        if i == i_first
            V(i) = 0;
        else
            V(i)=V(i-1);
        end
    end
end

v_thresh=str2double(get(handles.v_thresh,'String'));
Vt=zeros(1,handles.data.nFrames_tot);

for i=1:i_first:i_last-1
    if V(i) < v_thresh
        Vt(i)=0;
    else
        Vt(i)=1;
    end
end

figure
subplot(2,1,1);
plot(Time(i_first:i_last),V(i_first:i_last),'b')
axis ([0 inf 0 50])
hold on
plot([Time(i_first) Time(i_last)],[v_thresh v_thresh],'r')
hold off

xlabel('T [s]'); ylabel('V [cm/s]');

title('Speed Plot')
legend('Speed','Threshold')
subplot(2,1,2);
histogram(V(i_first:i_last),100,'Normalization','probability')
axis ([0 25 0 inf])
yt = get(gca, 'YTick');                                 % 'YTick' Values
set(gca, 'YTick', yt, 'YTickLabel', yt*100)             % Relabel 'YTick' With 'YTickLabel' Values
xlabel('|V| [cm/s]'); ylabel('[%]');
title('Speed Probability')

V=V(i_first:i_last);

handles.scaled_Centroid=Centroid;
handles.V=V;
handles.Vt=Vt;
guidata(hObject, handles);

% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes on button press in mobile_mean_smooth.
function mobile_mean_smooth_Callback(hObject, ~, handles)
% hObject    handle to mobile_mean_smooth (see GCBO)

% smoothing trajectories
win = str2double(get(handles.mobile_window_size,'String'));
win = win*handles.videodata.framerate;

i_first=handles.data.i_start;
i_last=handles.data.i_end;

C_Path=zeros(size(handles.Centroid));
H_Path=zeros(size(handles.Head));
T_Path=zeros(size(handles.Tail));
C_Path(1,i_first:i_last)=movmean(handles.Centroid(1,i_first:i_last),win);
C_Path(2,i_first:i_last)=movmean(handles.Centroid(2,i_first:i_last),win);
H_Path(1,i_first:i_last)=movmean(handles.Head(1,i_first:i_last),win);
H_Path(2,i_first:i_last)=movmean(handles.Head(2,i_first:i_last),win);
T_Path(1,i_first:i_last)=movmean(handles.Tail(1,i_first:i_last),win);
T_Path(2,i_first:i_last)=movmean(handles.Tail(2,i_first:i_last),win);

handles.H_bak=handles.Head;
handles.T_bak=handles.Tail;

handles.Centroid=C_Path;
handles.Head=H_Path;
handles.Tail=T_Path;

fn = round(str2double(get(handles.current_frame_edit,'String')));
fn = min(fn,handles.videodata.Nframes-5);
handles.current_frame_edit.String = num2str(fn);
handles.current_frame_slider.Value = fn;
update_arena_track(handles);
update_arena_plot(handles)
guidata(hObject, handles);
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of mobile_mean_smooth

% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of spline_smoothing

% --- Executes during object creation, after setting all properties.
function oden_video_axes_CreateFcn(~, ~, ~)
% hObject    handle to oden_video_axes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate oden_video_axes

% --- Executes on button press in export_data_button.
function export_data_button_Callback(~, ~, handles)
% hObject    handle to export_data_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
global vidfilename
[P, base_name , ~] = fileparts(vidfilename);
X1=round(min(handles.data.arena(:,1)));
X2=round(max(handles.data.arena(:,1)));
Y1=round(min(handles.data.arena(:,2)));
Y2=round(max(handles.data.arena(:,2)));
i_first=floor((str2double(handles.first_time_edit.String))*handles.videodata.framerate);
i_last=floor((str2double(handles.last_time_edit.String))*handles.videodata.framerate);
D1=X2-X1;
D2=Y2-Y1;
Xaxis=str2double(handles.data.arena_x);
Yaxis=str2double(handles.data.arena_y);
handles.pixel_x_cm=D1/Xaxis;
handles.pixel_x_cm2=(D1*D2)/(Xaxis*Yaxis);
Centroid=handles.Centroid;
Head=handles.Head;
Tail=handles.Tail;
handles.track.Axes=handles.track.Axes/handles.pixel_x_cm;
handles.track.Area=handles.track.Area/handles.pixel_x_cm2;
nn=zeros(1,length(Centroid));
nn(i_first+1)=norm(Centroid(:,i_first+1)-Centroid(:,i_first));
nn(i_first)=nn(i_first+1);

for i=i_first+2:i_last-1
    nn(i)=norm(Centroid(:,i)-Centroid(:,i-1));
end

for i=i_first+1:i_last-1
    if nn(i)>3*((nn(i-1)+nn(i+1))/2)
        handles.track.Tracked(i)=0;
        nn(i)=nn(i-1);
    end
end

i_p=i_first;
while i_p < i_last
    j_p=i_p-i_first+1;
    for i_next = i_p+1:i_last
        if (handles.track.Tracked(1,i_next)==1), break,  end  % find next tracked frame
    end
    j_next=i_next-i_first+1;
    
    Centroid(1,i_p:i_next)=linspace(Centroid(1,i_p),Centroid(1,i_next),i_next-i_p+1);
    Centroid(2,i_p:i_next)=linspace(Centroid(2,i_p),Centroid(2,i_next),i_next-i_p+1);
    [i_p i_next j_p j_next Centroid(2,j_p)];
    i_p=i_next;
end

%rescale trajectories
for i=1:length(Centroid)
    Centroid(1,i)=(Centroid(1,i)-X1)/D2*Xaxis;
    Centroid(2,i)=Yaxis-(Centroid(2,i)-Y1)/D1*Yaxis;
    Head(1,i)=(Head(1,i)-X1)/D2*Xaxis;
    Head(2,i)=Yaxis-(Head(2,i)-Y1)/D1*Yaxis;
    Tail(1,i)=(Tail(1,i)-X1)/D2*Xaxis;
    Tail(2,i)=Yaxis-(Tail(2,i)-Y1)/D1*Yaxis;
end

Distance=zeros(1,length(Centroid));
Distance(i_first)=0;

for i=i_first+1:length(Centroid)
    dx=Centroid(1,i)-Centroid(1,i-1);
    dy=Centroid(2,i)-Centroid(2,i-1);
    Distance(i)=sqrt(dx^2+dy^2);
end

handles.Distance=Distance;
handles.Teta=(atan2((Head(2,:)-Centroid(2,:)),(Head(1,:)-Centroid(1,:))));
Vx=zeros(1,length(Centroid));
Vy=zeros(1,length(Centroid));

for i=i_first:i_last
    Vx(i)=(Centroid(1,i+1)-Centroid(1,i))/(handles.Time(i+1)-handles.Time(i));
    Vy(i)=(Centroid(2,i+1)-Centroid(2,i))/(handles.Time(i+1)-handles.Time(i));
end

Vx(1,i_last)=Vx(1,i_last-1);
Vy(1,i_last)=Vy(1,i_last-1);
handles.V=sqrt(Vx.^2+Vy.^2);
handles.V(length(Centroid))=handles.V(length(Centroid)-1);

for i=i_first:i_last
    if handles.V(i) > 100
        handles.V(i)=handles.V(i-1);
    end
end

handles.V=handles.V(i_first:i_last);
v_thresh=str2double(get(handles.v_thresh,'String'));
Vt=zeros(1,length(handles.V));

for i=1:length(handles.V)
    if handles.V(i) < v_thresh
        Vt(i)=0;
    else
        Vt(i)=1;
    end
end

handles.ACT=100*sum(Vt)/length(Vt);
data.arena = handles.data.arena;
data.arena_x=Xaxis;
data.arena_y=Yaxis;
data.dimesions = [D1, D2];
data.Nframes = i_last-i_first+1;
data.i_first = i_first;
data.i_last = i_last;
track.Centroid_px = handles.Centroid;
track.Head_px = handles.Head;
track.Tail_px = handles.Tail;
track.Centroid(1,:) = Centroid(1,i_first:i_last);
track.Centroid(2,:) = Centroid(2,i_first:i_last);
track.Head(1,:) = Head(1,i_first:i_last);
track.Head(2,:) = Head(2,i_first:i_last);
track.Tail(1,:) = Tail(1,i_first:i_last);
track.Tail(2,:) = Tail(2,i_first:i_last);
track.Area = handles.track.Area(i_first:i_last);
track.Axes = handles.track.Axes(i_first:i_last);
track.Teta = handles.Teta(i_first:i_last);
track.Time = handles.Time(i_first:i_last);
track.Velocity = handles.V;
track.Distance = handles.Distance(i_first:i_last);

for i_frame=1:i_last+1-i_first
    track.Vertices{i_frame}=handles.track.ConvexHull{i_frame+i_first-1};
end

track.Tracked = handles.track.Tracked(i_first:i_last);
handles.Centre=Centroid(:,i_first:i_last);
handles.Nose = Head(:,i_first:i_last);
handles.Butt = Tail(:,i_first:i_last);
StrFile_out=[P filesep 'Results' filesep 'Out_' base_name '.mat'];

try
    stats=handles.stats;
    save(StrFile_out, 'data','track','stats')
catch
    save(StrFile_out, 'data','track')
end

data_export(handles,i_first,i_last)
msgbox(['data exported']);

% handles    structure with handles and user data (see GUIDATA)

% --- Executes on button press in no_smooth.
function no_smooth_Callback(hObject, ~, handles)
% hObject    handle to no_smooth (see GCBO)
handles.Head=handles.H_bak;
handles.Tail=handles.T_bak;

handles.Centroid=handles.track.Centroid;
fn = round(str2double(get(handles.current_frame_edit,'String')));
fn = min(fn,handles.videodata.Nframes-5);
handles.current_frame_edit.String = num2str(fn);
handles.current_frame_slider.Value = fn;
update_arena_track(handles);
update_arena_plot(handles)
guidata(hObject, handles);

% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of no_smooth

% --- Executes on button press in fix_head.
function fix_head_Callback(hObject, ~, handles)
% % % hObject    handle to fix_handles.Head (see GCBO)
% % % eventdata  reserved - to be defined in a future version of MATLAB
% % % handles    structure with handles and user data (see GUIDATA)
global video

fn = round(str2double(get(handles.current_frame_edit,'String')));
i_last=handles.videodata.Nframes;

% Get Head coordinates
CurrFrame = rgb2gray(read(video,fn));
clear k point1 finalRect point2 p1 offset
figure
imshow(CurrFrame,[])
hold on
prompt = {'Press OK then select the Head'};
inputdlg(prompt, '',0.01);
[size1, size2]=size(CurrFrame);
clear point1 finalRect point2 p1 offset
waitforbuttonpress;
point1 = get(gca,'CurrentPoint');    % button down detected
rbbox;                   % return figure units
point2 = get(gca,'CurrentPoint');    % button up detected
point1 = point1(1,1:2);              % extract x and y
point2 = point2(1,1:2);
p1 = min(point1,point2);             % calculate locations
offset = abs(point1-point2);         % and dimensions
xCoords = [p1(1) p1(1)+offset(1) p1(1)+offset(1) p1(1) p1(1)];
yCoords = [p1(2) p1(2) p1(2)+offset(2) p1(2)+offset(2) p1(2)];
x1 = round(xCoords(1));
x2 = round(xCoords(2));
y1 = round(yCoords(5));
y2 = round(yCoords(3));
if x1<1, x1=1; end
if x1>size2, x1=size2; end
if x2<1, x2=1; end
if x2>size2, x2=size2; end
if y1<1, y1=1; end
if y1>size1, y1=size1; end
if y2<1, y2=1; end
if y2>size1, y2=size1; end
[x1 x2 y1 y2];
p1=plot(xCoords, yCoords); % redraw in dataspace units
set(p1,'Color','red','LineWidth',2)
handles.Head_x = mean(x1,x2);
handles.Head_y = mean (y1,y2);

handles.Tail(1,fn)=handles.Head(1,fn);
handles.Tail(2,fn)=handles.Head(2,fn);

handles.Head(1,fn)=handles.Head_x;
handles.Head(2,fn)=handles.Head_y;

% **************** Fix Head-Tail Position

for i_frame=fn+1:i_last
    VecH=[handles.Head(1,i_frame)-handles.Centroid(1,i_frame),handles.Head(2,i_frame)-handles.Centroid(2,i_frame)];
    VecH_old=[handles.Head(1,i_frame-1)-handles.Centroid(1,i_frame-1),handles.Head(2,i_frame-1)-handles.Centroid(2,i_frame-1)];
    Hdot=dot(VecH,VecH_old);
    if  Hdot<0
        xTail=handles.Head(1,i_frame);
        yTail=handles.Head(2,i_frame);
        handles.Head(1,i_frame)=handles.Tail(1,i_frame);
        handles.Head(2,i_frame)=handles.Tail(2,i_frame);
        handles.Tail(1,i_frame)=xTail;
        handles.Tail(2,i_frame)=yTail;
    end
end

update_arena_track(handles);
update_arena_plot(handles);
guidata(hObject, handles);

% --- Executes on button press in angular_plot.
function angular_plot_Callback(hObject, ~, handles)
% hObject    handle to angular_plot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

i_first=floor((str2double(handles.first_time_edit.String))*handles.videodata.framerate);
i_last=floor((str2double(handles.last_time_edit.String))*handles.videodata.framerate);
handles.Teta=(atan2((handles.Head(2,i_first:i_last)-handles.Centroid(2,i_first:i_last)),(handles.Head(1,i_first:i_last)-handles.Centroid(1,i_first:i_last))));

figure;
polarhistogram(handles.Teta,180,'Normalization','probability');
title('Head Position Angular Histogram');

% Teta=handles.Teta;
% try
%     
%     for i=i_first:i_last
%         if handles.Vt(i)==0
%             Teta(i)=nan;
%         end
%     end
%     
% catch
%     
%     X1=round(min(handles.data.arena(:,1)));
%     X2=round(max(handles.data.arena(:,1)));
%     Y1=round(min(handles.data.arena(:,2)));
%     Y2=round(max(handles.data.arena(:,2)));
%     Xaxis=str2double(handles.data.arena_x);
%     Yaxis=str2double(handles.data.arena_y);
%     
%     if handles.videodata.framerate*(str2double(handles.first_time_edit.String))>handles.data.i_start
%         i_first=floor(handles.videodata.framerate*(str2double(handles.first_time_edit.String)));
%     else
%         i_first=handles.data.i_start;
%     end
%     
%     if handles.videodata.framerate*(str2double(handles.last_time_edit.String))<handles.data.i_end
%         i_last=floor(handles.videodata.framerate*(str2double(handles.last_time_edit.String)));
%     else
%         i_last=handles.data.i_end;
%     end
%     
%     D1=X2-X1;
%     D2=Y2-Y1;
%     Time=handles.track.Time;
%     
%     %rescale trajectories
%     Centroid=handles.Centroid;
%     
%     for i=1:length(Centroid)
%         Centroid(1,i)=(Centroid(1,i)-X1)/D2*Xaxis;
%         Centroid(2,i)=Yaxis-(Centroid(2,i)-Y1)/D1*Yaxis;
%     end
%     Vx=zeros(1,length(Centroid));
%     Vy=zeros(1,length(Centroid));
%     for i=1:length(Centroid)-1
%         Vx(i)=(Centroid(1,i+1)-Centroid(1,i))/(Time(i+1)-Time(i));
%         Vy(i)=(Centroid(2,i+1)-Centroid(2,i))/(Time(i+1)-Time(i));
%     end
%     Vx(1,i_last)=Vx(1,i_last-1);
%     Vy(1,i_last)=Vy(1,i_last-1);
%     V=sqrt(Vx.^2+Vy.^2);
%     for i=i_first:i_last-1
%         if V(i) > 100
%             if i == i_first
%                 V(i) = 0;
%             else
%                 V(i)=V(i-1);
%             end
%         end
%     end
    
%     v_thresh=str2double(get(handles.v_thresh,'String'));
%     Vt=zeros(1,handles.data.nFrames_tot);
%     
%     for i=1:i_first:i_last-1
%         if V(i) < v_thresh
%             Vt(i)=0;
%         else
%             Vt(i)=1;
%         end
%     end
%     
%     for i=i_first:i_last
%         if Vt(i)==0
%             Teta(i)=nan;
%         end
%     end
%     
% end
% 
% figure;
% polarhistogram(Teta,180,'Normalization','probability');
% title('Unbiased Head Position Angular Histogram');

guidata(hObject, handles);

% --- Executes on button press in define_zones.
function define_zones_Callback(hObject, ~, handles)
% hObject    handle to define_zones (see GCBO)

define_zones(handles);
uiwait
video_file = cellstr(get(handles.video_file_listbox,'String'));
vidfilename = [handles.video_dir_text.String filesep video_file{get(handles.video_file_listbox,'Value')}];

[P, base_name , ~] = fileparts(vidfilename);
zones_dir = [P filesep 'Results' filesep 'Raw' filesep 'Zones'];
zonesfilename = [zones_dir filesep base_name '_zones'];

a=load(zonesfilename);
handles.zones=a.ROIs;

fn = round(str2double(get(handles.current_frame_edit,'String')));
fn = min(fn,handles.videodata.Nframes-5);
update_arena_track(handles);
guidata(hObject, handles);

% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes on selection change in zones_listbox.
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: video_file = cellstr(get(hObject,'String')) returns zones_listbox video_file as cell array
%        video_file{get(hObject,'Value')} returns selected item from zones_listbox

% --- Executes during object creation, after setting all properties.
function zones_listbox_CreateFcn(hObject, ~, ~)
% hObject    handle to zones_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in load_zones.
function load_zones_Callback(hObject, ~, handles)
% hObject    handle to load_zones (see GCBO)

[File, Directory] = uigetfile({'*.*','All Files (*.*)'},'Select the file', path);

zonesfilename = [Directory filesep File];

a=load(zonesfilename);
handles.zones=a.ROIs;

fn = round(str2double(get(handles.current_frame_edit,'String')));
fn = min(fn,handles.videodata.Nframes-5);
handles.current_frame_edit.String = num2str(fn);
handles.current_frame_slider.Value = fn;

update_arena_track(handles);
guidata(hObject, handles);
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes on button press in realize_video.
function realize_video_Callback(~, ~, handles)
% hObject    handle to realize_video (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global video vidfilename
[P, base_name , ~] = fileparts(vidfilename);
StrFile_out=[P filesep 'Video_' base_name '.avi'];
writerObj = VideoWriter(StrFile_out);
writerObj.FrameRate = handles.videodata.framerate;
open(writerObj);
f=figure();
i_first=floor((str2double(handles.first_time_edit.String))*handles.videodata.framerate);
i_last=floor((str2double(handles.last_time_edit.String))*handles.videodata.framerate);
vertices=handles.data.arena;
arena_centre=handles.data.arena_centre;


for i = i_first:i_last
    Frame=rgb2gray(read(video,i));
    imshow(Frame,[])
    title(['Frame n. ',num2str(i)])
    hold on
    if i-i_first<300
        plot(handles.Centroid(1,i_first:i),handles.Centroid(2,i_first:i),'LineWidth',2)
    else
        plot(handles.Centroid(1,i-300:i),handles.Centroid(2,i-300:i),'LineWidth',2)
    end
    plot(handles.Centroid(1,i), handles.Centroid(2,i), 'ko','MarkerSize',10)
    plot(handles.Head(1,i), handles.Head(2,i), 'r.','MarkerSize',15)
    plot(handles.Tail(1,i), handles.Tail(2,i), 'b.','MarkerSize',15)
        if handles.data.Erosion > 0
            % Vertices=handles.track.ConvexHull{i};
            % Lines=[(1:size(Vertices,1))' (2:size(Vertices,1)+1)']; Lines(end,2)=1;
            % plot([Vertices(Lines(:,1),1) Vertices(Lines(:,2),1)]',[Vertices(Lines(:,1),2) Vertices(Lines(:,2),2)]','b');
            plot([handles.Head(1,i) handles.Centroid(1,i)], [handles.Head(2,i) handles.Centroid(2,i)],'g');
            plot([handles.Tail(1,i) handles.Centroid(1,i)], [handles.Tail(2,i) handles.Centroid(2,i)],'g');
        end
   
    
    poly_h = plot(vertices(:,1),vertices(:,2));
    set(poly_h,'color','y','linewidth',1,'Tag','ZoneBorder')
    poly_th = text(arena_centre(1),arena_centre(2),'Arena');
    set(poly_th,'Color','y','Tag','ZoneText','HorizontalAlignment','center', 'VerticalAlignment','middle','Interpreter','none');
    try
        for nz = 1:length(handles.zones)
            poly_h = plot(handles.zones(nz).vertices(:,1),handles.zones(nz).vertices(:,2));
            set(poly_h,'color','g','linewidth',1,'Tag','ArenaBorder')
            poly_th = text(handles.zones(nz).centre(1),handles.zones(nz).centre(2),handles.zones(nz).name);
            set(poly_th,'Color','g','Tag','ArenaText','HorizontalAlignment','center', 'VerticalAlignment','middle','Interpreter','none');
        end
    catch
    end
    hold off
    
    writeVideo(writerObj,getframe(f));
end
close
close(writerObj);

% --- Executes on button press in zones_stats.
function zones_stats_Callback(hObject, ~, handles)
% hObject    handle to zones_stats (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.stats=position_analysis(handles);
guidata(hObject, handles);

function n_sectors_Callback(~, ~, ~)
% hObject    handle to n_sectors (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns video_file of n_sectors as text
%        str2double(get(hObject,'String')) returns video_file of n_sectors as a double

% --- Executes during object creation, after setting all properties.
function n_sectors_CreateFcn(hObject, ~, ~)
% hObject    handle to n_sectors (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function v_thresh_Callback(~, ~, ~)
% hObject    handle to v_thresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns video_file of v_thresh as text
%        str2double(get(hObject,'String')) returns video_file of v_thresh as a double

% --- Executes during object creation, after setting all properties.
function v_thresh_CreateFcn(hObject, ~, ~)
% hObject    handle to v_thresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in bkg_video.
function bkg_video_Callback(hObject, eventdata, handles)
% hObject    handle to bkg_video (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global video vidfilename
[P, base_name , ~] = fileparts(vidfilename);
StrFile_out=[P filesep 'BkgVideo_' base_name '.avi'];
writerObj = VideoWriter(StrFile_out);
writerObj.FrameRate = handles.videodata.framerate;
open(writerObj);
f=figure();
i_first=floor((str2double(handles.first_time_edit.String))*handles.videodata.framerate);
i_last=floor((str2double(handles.last_time_edit.String))*handles.videodata.framerate);
Bkg = handles.data.Bkg;

for i = i_first:i_last
    if handles.lvl<150
        CurrFrame=rgb2gray(read(video,i));
    else
        CurrFrame=rgb2gray(read(video,i));
        CurrFrame=255-CurrFrame;
    end
    imshow(CurrFrame-Bkg,[])
    title(['Frame n. ',num2str(i)])
    writeVideo(writerObj,getframe(f));
end
close
close(writerObj);



function M_thresh_Callback(hObject, eventdata, handles)
% hObject    handle to M_thresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of M_thresh as text
%        str2double(get(hObject,'String')) returns contents of M_thresh as a double


% --- Executes during object creation, after setting all properties.
function M_thresh_CreateFcn(hObject, eventdata, handles)
% hObject    handle to M_thresh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in auto_fix_head.
function auto_fix_head_Callback(hObject, eventdata, handles)
% hObject    handle to auto_fix_head (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% fix head tail position
% M_thresh=str2double(get(handles.M_thresh,'String'));
% win=floor(handles.movement_win);

i_first=handles.data.i_start;
i_last=handles.data.i_end;

for i_frame=i_first:i_last
    if handles.data.Erosion > 0
        Y = handles.Head(:,i_frame);
        Z = handles.Tail(:,i_frame);
%         d1 = norm(X-Y);
%         d2 = norm(X-Z);
%         if d1/d2 < 1.35
%             H1 = norm(Y-handles.Head(:,i_frame-1));
%             H2 = norm(Z-handles.Head(:,i_frame-1));
            T1 = norm(Y-handles.Tail(:,i_frame));
            T2 = norm(Z-handles.Tail(:,i_frame));
            disp(min(T1,T2))
            % if min(T1,T2) <= M_thresh
                if T1 < T2
                    xHead=handles.Tail(1,i_frame);
                    yHead=handles.Tail(2,i_frame);
                    handles.Tail(1,i_frame) = handles.Head(1,i_frame);
                    handles.Tail(2,i_frame) = handles.Head(2,i_frame);
                    handles.Head(1,i_frame)=xHead;
                    handles.Head(2,i_frame)=yHead;
                end
            % else
%                 Vertices = handles.track.ConvexHull{i_frame};
%                 dist = sqrt((Vertices(:,1) - handles.Head(1,i_frame-1)).^2 + (Vertices(:,2) - handles.Head(2,i_frame-1)).^2);
%                 [~,pos] = min(dist);
%                 handles.Head(1,i_frame) = Vertices(pos,1);
%                 handles.Head(2,i_frame) = Vertices(pos,2);
%                 clear dist
%                 dist = sqrt((Vertices(:,1) - handles.Tail(1,i_frame-1)).^2 + (Vertices(:,2) - handles.Tail(2,i_frame-1)).^2);
%                 [~,pos] = min(dist);
%                 handles.Tail(1,i_frame) = Vertices(pos,1);
%                 handles.Tail(2,i_frame) = Vertices(pos,2);
%                 clear dist
            % end
%         end
    end
end
                 
update_arena_plot(handles);
update_arena_track(handles);
guidata(hObject,handles);

% --- Executes on button press in fill_gap_in_data.
function fill_gap_in_data_Callback(hObject, eventdata, handles)
% hObject    handle to fill_gap_in_data (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
Tracked=handles.track.Tracked;
i_first=handles.data.i_start;
i_last=handles.data.i_end;
nn=zeros(1,length(handles.Centroid));
nn(i_first+1)=norm(handles.Centroid(:,i_first+1)-handles.Centroid(:,i_first));
nn(i_first)=nn(i_first+1);
for i=i_first+2:i_last-1
    nn(i)=norm(handles.Centroid(:,i)-handles.Centroid(:,i-1));
end

for i_frame=i_first:i_last
    if Tracked(1,i_frame)==0
        i_p=i_frame;
        while i_p < i_last
            j_p=i_p-i_first+1;
            for i_next = i_p+1:i_last
                if (Tracked(1,i_next)==1)
                    break
                end  % find next tracked frame
            end
            j_next=i_next-i_first+1;
            handles.Centroid(1,i_p:i_next)=linspace(handles.Centroid(1,i_p),handles.Centroid(1,i_next),i_next-i_p+1);
            handles.Centroid(2,i_p:i_next)=linspace(handles.Centroid(2,i_p),handles.Centroid(2,i_next),i_next-i_p+1);
            handles.Head(1,i_p:i_next)=linspace(handles.Head(1,i_p),handles.Head(1,i_next),i_next-i_p+1);
            handles.Head(2,i_p:i_next)=linspace(handles.Head(2,i_p),handles.Head(2,i_next),i_next-i_p+1);
            handles.Tail(1,i_p:i_next)=linspace(handles.Tail(1,i_p),handles.Tail(1,i_next),i_next-i_p+1);
            handles.Tail(2,i_p:i_next)=linspace(handles.Tail(2,i_p),handles.Tail(2,i_next),i_next-i_p+1);
            
            [i_p i_next j_p j_next handles.Centroid(2,j_p)];
            i_p=i_next;
        end
    end
end
guidata(hObject, handles);
update_arena_track(handles)
update_arena_plot(handles)
    