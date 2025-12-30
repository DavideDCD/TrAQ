function varargout = define_zones(varargin)
% YBS 9/16
% DEFINE_ZONES MATLAB code for define_zones.fig
%      DEFINE_ZONES, by itself, creates a new DEFINE_ZONES or raises the existing
%      singleton*.
%
%      H = DEFINE_ZONES returns the handle to a new DEFINE_ZONES or the handle to
%      the existing singleton*.
%
%      DEFINE_ZONES('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DEFINE_ZONES.M with the given input arguments.
%
%      DEFINE_ZONES('Property','Value',...) creates a new DEFINE_ZONES or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before define_zones_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to define_zones_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help define_zones

% Last Modified by GUIDE v2.5 15-Jun-2018 14:50:55

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @define_zones_OpeningFcn, ...
                   'gui_OutputFcn',  @define_zones_OutputFcn, ...
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

% --- Executes just before define_zones is made visible.
function define_zones_OpeningFcn(hObject, eventdata, handles, varargin)

%load logo
path=mfilename('fullpath');
path=path(1:end-12);
path=[path filesep 'logo.mat'];

load(path);
axes(handles.logo_axes)
imshow(Logo,[])

calling_fig_handles = varargin{end}; % which is the main zone figure
contents = cellstr(get(calling_fig_handles.video_file_listbox,'String')); 
handles.vidfilename = [calling_fig_handles.folder_name filesep contents{get(calling_fig_handles.video_file_listbox,'Value')}];

[P, base_name , ~] = fileparts(handles.vidfilename);
    data_dir = [P filesep 'Results' filesep 'Raw' filesep 'Data'];
data_file_name = [data_dir filesep base_name,'_data.mat'];
load(data_file_name);

Bkg=data.Bkg;

axes(handles.very_original_video_axes);
box on
set(gca,'Ydir','reverse')
hold on
% Define axis and colormap properties
axis equal; % axis off;
axis tight

UD.colors = [1 0 0; 0 1 0; 0 0 1 ; 1 1 0 ; 1 0 1; 0 1 1 ;  0 1 0.5];

Frame = Bkg;
current_image_h = imshow(Frame,[]);
UD.vidfilename=handles.vidfilename;
UD.ImageSizeInPixels = [size(Frame,1) size(Frame,2)];
UD.current_image_h = current_image_h;
handles.UD = UD;

% Define axis and colormap properties
axis equal; % axis off; 
axis tight


% Initialize the zones structure
handles.zones = [];

% Update handles structure
guidata(hObject, handles);

% Choose default command line output for calculate_positions_in_zone
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% --- Outputs from this function are returned to the command line.
function varargout = define_zones_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in new_zones_button.
function new_zones_button_Callback(hObject, eventdata, handles,duplicate)
% hObject    handle to new_zones_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get the type of ROI to get
zone_type = handles.zone_type_menu.String{handles.zone_type_menu.Value};

% However, if we had the duplicate button we take the current object's type
if nargin == 4
    duplicate = 1;
    current_zone = handles.zone_listbox.String{handles.zone_listbox.Value};
    zone_names = {handles.zones.name};
    rel_ind = strcmp(current_zone,zone_names);
    zone_type = handles.zones(rel_ind).zone_type;
    orig_pos = getPosition(handles.zones(rel_ind).handle);
else
    duplicate = 0;
end

Xlimits = handles.very_original_video_axes.XLim;
Ylimits = handles.very_original_video_axes.YLim;

IW = (Xlimits(2) - Xlimits(1));
IH = (Ylimits(2) - Ylimits(1));
W = min(IW,IH);

switch zone_type
    case 'circle'
        if duplicate
            start_pos = orig_pos;
        else
            start_pos = [W/2-W/10, W/2-W/10, W/5, W/5];
        end
        zone_h = imellipse(handles.very_original_video_axes,start_pos);
        fixedRatio = 1;
        setFixedAspectRatioMode(zone_h,fixedRatio);
    case 'ellipse'
        if duplicate
            start_pos = orig_pos;
        else
            start_pos = [IW/2-IW/10, IH/2-IH/10, IW/5, IH/5];
        end
        zone_h = imellipse(handles.very_original_video_axes,start_pos);
        fixedRatio = 0;
    case 'rectangle'
        if duplicate
            start_pos = orig_pos;
        else
            start_pos = [IW/2-IW/10, IH/2-IH/10, IW/5, IH/5];
        end
        zone_h = imrect(handles.very_original_video_axes,start_pos);
        fixedRatio = 0;
    case 'square'
        if duplicate
            start_pos = orig_pos;
        else
            start_pos = [W/2-W/10, W/2-W/10, W/5, W/5];
        end
        zone_h = imrect(handles.very_original_video_axes,start_pos);
        fixedRatio = 1;
        setFixedAspectRatioMode(zone_h,fixedRatio);
    case 'polygon'
        if duplicate
            zone_h = impoly(handles.very_original_video_axes,orig_pos);
        else
            zone_h = impoly(handles.very_original_video_axes);
            if isempty(zone_h)
                delete(zone_h);
                return
            end
            zone_position = wait(zone_h);
            if isempty(zone_position)
                delete(zone_h);
                return
            end
        end
        fixedRatio = 0;
    case 'freehand'
        if duplicate
            zone_h = imfreehand(handles.very_original_video_axes,orig_pos);
        else
            zone_h = imfreehand(handles.very_original_video_axes);
            if isempty(zone_h)
                delete(zone_h);
                return
            end
            zone_position = wait(zone_h);
            if isempty(zone_position)
                delete(zone_h);
                return
            end
        end
        fixedRatio = 0;
end
% allow deleting only through GUI, not by right click
zone_h.Deletable = false;

% Add zone to handle structure - 
handles = guidata(hObject);

zones = handles.zones;
zind = length(zones) + 1;

if ~(zind == 1) % IF not the first one
    zone_names = {zones.name};
    good_name = 0;
    % Find a zone name that is not taken
    gnc = 0;
    while ~good_name
        proposed_name= ['zone ' num2str(zind+gnc)];
        if ~ismember(proposed_name,zone_names)
            good_name = 1;
        end
        gnc = gnc + 1;
    end    
else
    proposed_name = ['zone ' num2str(zind)];   
end
    
zones(zind).name  = proposed_name;

zones(zind).handle = zone_h;
zones(zind).fixedRatio = fixedRatio;
zones(zind).zone_type = zone_type;

zone_id = rand;
zones(zind).unique_id = zone_id;
handles.zones = zones;

% append zone name to list
% and make it current 
zone_list = handles.zone_listbox.String;
ll = length(zone_list);
zone_list{ll+1} = zones(zind).name;
handles.zone_listbox.String = zone_list;
handles.zone_listbox.Value = ll+1;

% Update handles structure
guidata(hObject, handles);

% to highlight the new zone
zone_listbox_Callback(hObject, eventdata, handles)

% --- Executes on selection change in zone_type_menu.
function zone_type_menu_Callback(hObject, eventdata, handles)
% hObject    handle to zone_type_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns zone_type_menu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from zone_type_menu

% --- Executes during object creation, after setting all properties.
function zone_type_menu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to zone_type_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in zone_listbox.
function zone_listbox_Callback(hObject, eventdata, handles)

if isempty(handles.zone_listbox.String)
    return
end
current_zone = handles.zone_listbox.String{handles.zone_listbox.Value};
zone_names = {handles.zones.name};
rel_ind = strcmp(current_zone,zone_names);
setColor(handles.zones(rel_ind).handle,'r');

% update the position of the selected zone
zone_pos = getPosition(handles.zones(rel_ind).handle);

%setResizable(handles.zones(rel_ind).handle,1);
other_inds = find(~rel_ind);
for i = 1:length(other_inds)
    setColor(handles.zones(other_inds(i)).handle,'b'); 
end

guidata(hObject, handles);

% --- Executes during object creation, after setting all properties.
function zone_listbox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to zone_listbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in edit_zone_position_button.
function edit_zone_position_button_Callback(hObject, eventdata, handles)
% hObject    handle to edit_zone_position_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes on button press in delete_zones_button.
function delete_zones_button_Callback(hObject, eventdata, handles)

if isempty(handles.zone_listbox.String)
    return
end
zone_strings = handles.zone_listbox.String;
current_zone = zone_strings{handles.zone_listbox.Value};
zone_names = {handles.zones.name};
rel_ind = strcmp(current_zone,zone_names);

zones = handles.zones;

% Remove it from the interface
delete(zones(rel_ind).handle);

% Remove the zone from the zone structure structure
zones(rel_ind) = [];
handles.zones = zones;


% remove the zone from the list
zone_strings(rel_ind) = [];
handles.zone_listbox.String = zone_strings;
% Make the last zone active
handles.zone_listbox.Value = length(zone_strings);
guidata(hObject, handles);

% and update the active region
zone_listbox_Callback(hObject, eventdata, handles)

return

% --- Executes on button press in rename_zones_button.
function rename_zones_button_Callback(hObject, eventdata, handles)

if isempty(handles.zone_listbox.String)
    return
end

% active zone name from listbox
current_zone_name = handles.zone_listbox.String{handles.zone_listbox.Value};

% zone name index in structure
zones = handles.zones;
zone_names = {zones.name};
zone_name_ind = strcmp(current_zone_name,zone_names);

% Ask the user to give a new name
prompt = {['Enter new name for zone ' current_zone_name]};
dlg_title = 'rename zone';
num_lines = 1;
defaultans = {current_zone_name};
answer = inputdlg(prompt,dlg_title,num_lines,defaultans);

if isempty(answer) || isempty(answer{1})
    errordlg(['A name must be given for the zone'],'Rename zone','modal');
    return
end

new_name = answer{1};

% return if name not changed
if strcmp(new_name,current_zone_name)    
    return
end
% return if name exists
if ismember(new_name,zone_names)    
    errordlg(['The name ' current_zone_name ' is already taken'])
    return
end

% Change the zone name in the list
zone_names_in_listbox = handles.zone_listbox.String;
zone_names_in_listbox{handles.zone_listbox.Value} = new_name;
handles.zone_listbox.String = zone_names_in_listbox;

% change name in structure
zones(zone_name_ind).name = new_name;

% Update name change
handles.zones = zones;
guidata(hObject, handles);

% --- Executes on button press in duplicate_zones_button.
function duplicate_zones_button_Callback(hObject, eventdata, handles)
if isempty(handles.zone_listbox.String)
    return
end
new_zones_button_Callback(hObject, eventdata, handles,1)

function save_zones_button_Callback(hObject, eventdata, handles)

% to be saved in zone files

% although the zone interface was used, here these regions are
% called ROIS
ROIs = handles.zones;

if isempty(ROIs)
    uiwait(msgbox('No Zones were defined','zone Definition','modal'));
    return
end

% Handles cannot be saved
ROIs = rmfield(ROIs,'handle');

% Find the path and file name to save the zone file
vidfilename = handles.UD.vidfilename;
[P, base_name , ~] = fileparts(vidfilename);
zone_dir = [P filesep 'Results' filesep 'Raw' filesep 'Zones'];
if ~exist(zone_dir,'dir')
    mkdir(zone_dir)
end

zone_file_name = [zone_dir filesep base_name '_zones.mat'];

% Get ROI positions
for i = 1:length(ROIs)
    ROIs(i).roi_position_in_pixels = getPosition(handles.zones(i).handle);
end

for i = 1:length(ROIs)
    switch ROIs(i).zone_type
        case {'circle','ellipse'}
            zone_vertices{i} = getVertices(handles.zones(i).handle);
        case {'rectangle','square'}
            pos = getPosition(handles.zones(i).handle);
            zone_vertices{i}(1,:) = [pos(1) pos(2)];
            zone_vertices{i}(2,:) = [pos(1)+pos(3) pos(2)];
            zone_vertices{i}(3,:) = [pos(1)+pos(3) pos(2)+pos(4)];
            zone_vertices{i}(4,:) = [pos(1)        pos(2)+pos(4)];
            zone_vertices{i}(5,:) = [pos(1) pos(2)]; % close the rect
        case {'polygon','freehand'}            
            zone_vertices{i} = getPosition(handles.zones(i).handle);
            % close the shape if it is not closed - I think it never will
            % be even if a right mouse click is used
            if ~(zone_vertices{i}(size(zone_vertices{i},1),1) == zone_vertices{i}(1,1) && zone_vertices{i}(size(zone_vertices{i},1),2) == zone_vertices{i}(1,2))            
                zone_vertices{i}(size(zone_vertices{i},1)+1,:) = zone_vertices{i}(1,:);            
            end
    end
    ROIs(i).vertices = zone_vertices{i};
    min_x = min(zone_vertices{i}(:,1));
    max_x = max(zone_vertices{i}(:,1));
    cen_x = mean([min_x max_x]);
    min_y = min(zone_vertices{i}(:,2));
    max_y = max(zone_vertices{i}(:,2));
    cen_y = mean([min_y max_y]);    
    ROIs(i).centre = [cen_x cen_y];
end
zones_names=handles.zone_listbox.String;
% Save the zone file and close the figure
save(zone_file_name,'vidfilename','ROIs','zones_names');
msgbox(['Zones saved in ' zone_file_name ],'Define Zones') 

fh = findobj('name','TrAQ - prepare sessions');
if ishandle(fh)
    calling_figure_handles = guidata(fh);
    prepare_zone_data('zone_listbox_Callback',fh,eventdata,guidata(fh))
    [~,F,E] = fileparts(zone_file_name);
    short_zone_name = [F E];
    zone_file_ind = strmatch(short_zone_name,calling_figure_handles.zone_listbox.String,'exact');
    if ~isempty(zone_file_ind)
        calling_figure_handles.zone_listbox.Value = zone_file_ind;
        prepare_zone_data('apply_selected_zone_button_Callback',fh,eventdata,calling_figure_handles)
    end
end
drawnow
% close the figure
delete(handles.figure1);

function X_pos_edit_Callback(hObject, eventdata, handles)
apply_edit_values_to_zone_position(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function X_pos_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to X_pos_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function Y_pos_edit_Callback(hObject, eventdata, handles)
apply_edit_values_to_zone_position(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function Y_pos_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Y_pos_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function width_edit_Callback(hObject, eventdata, handles)
apply_edit_values_to_zone_position(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function width_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to width_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function height_edit_Callback(hObject, eventdata, handles)
apply_edit_values_to_zone_position(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function height_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to height_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% ButtonName = questdlg('Really close? Any unsaved settings will be erased. Continue?', ...
%     'Optimouse', 'Cancel', 'Close', 'Cancel');
% if strcmp(ButtonName,'Cancel')
%         return        
% end
% Hint: delete(hObject) closes the figure
delete(hObject);
