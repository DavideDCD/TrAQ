function varargout = define_arena(varargin)
%DEFINE_ARENA MATLAB code file for define_arena.fig
%      DEFINE_ARENA, by itself, creates a new DEFINE_ARENA or raises the existing
%      singleton*.
%
%      H = DEFINE_ARENA returns the handle to a new DEFINE_ARENA or the handle to
%      the existing singleton*.
%
%      DEFINE_ARENA('Property','Value',...) creates a new DEFINE_ARENA using the
%      given property value pairs. Unrecognized properties are passed via
%      varargin to define_arena_OpeningFcn.  This calling syntax produces a
%      warning when there is an existing singleton*.
%
%      DEFINE_ARENA('CALLBACK') and DEFINE_ARENA('CALLBACK',hObject,...) call the
%      local function named CALLBACK in DEFINE_ARENA.M with the given input
%      arguments.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help define_arena

% Last Modified by GUIDE v2.5 21-Mar-2020 14:32:04

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @define_arena_OpeningFcn, ...
    'gui_OutputFcn',  @define_arena_OutputFcn, ...
    'gui_LayoutFcn',  [], ...
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


% --- Executes just before define_arena is made visible.
function define_arena_OpeningFcn(hObject, eventdata, handles, Bkg)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   unrecognized PropertyName/PropertyValue pairs from the
%            command line (see VARARGIN)

%load logo
path=mfilename('fullpath');
path=path(1:end-12);
path=[path filesep 'logo.mat'];

load(path);
axes(handles.logo_axes)
imshow(Logo,[])

axes(handles.original_video_axes);
box on
set(gca,'Ydir','reverse')
hold on
% Define axis and colormap properties
axis equal; % axis off;
axis tight

UD.colors = [1 0 0; 0 1 0; 0 0 1 ; 1 1 0 ; 1 0 1; 0 1 1 ;  0 1 0.5];

handles.Frame = Bkg;
current_image_h = imshow(handles.Frame,[]);
UD.ImageSizeInPixels = [size(handles.Frame,1) size(handles.Frame,2)];
UD.current_image_h = current_image_h;
handles.UD = UD;

% Initialize the arena structure
handles.arena = [];

% Update handles structure
guidata(hObject, handles);

% Choose default command line output for calculate_positions_in_arena
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes define_arena wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = define_arena_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes during object creation, after setting all properties.
function text22_CreateFcn(hObject, eventdata, handles)
% hObject    handle to text22 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in delete_arena_button.
function delete_arena_button_Callback(hObject, eventdata, handles)
% hObject    handle to delete_arena_button (see GCBO)
arena = handles.arena;

% Remove it from the interface
delete(arena.handle);

% Remove the arena from the arena structure
arena = [];
handles.arena = arena;
return

% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in new_arena_button.
function new_arena_button_Callback(hObject, eventdata, handles)
% hObject    handle to new_arena_button (see GCBO)

% Get the type of ROI to get
arena_type = handles.arena_type_menu.String{handles.arena_type_menu.Value};
Xlimits = handles.original_video_axes.XLim;
Ylimits = handles.original_video_axes.YLim;
IW = range(Xlimits);
IH = range(Ylimits);
W = min(IW,IH);

if isempty(handles.arena)
else
arena = handles.arena;
% Remove it from the interface
delete(arena.handle);
% Remove the arena from the arena structure
arena = [];
handles.arena = arena;
end

switch arena_type
    case 'circle'
        start_pos = [W/2-W/10, W/2-W/10, W/5, W/5];
        arena_h = imellipse(handles.original_video_axes,start_pos);
        fixedRatio = 1;
        setFixedAspectRatioMode(arena_h,fixedRatio);
    case 'ellipse'
        start_pos = [IW/2-IW/10, IH/2-IH/10, IW/5, IH/5];
        arena_h = imellipse(handles.original_video_axes,start_pos);
        fixedRatio = 0;
    case 'rectangle'
        start_pos = [IW/2-IW/10, IH/2-IH/10, IW/5, IH/5];
        arena_h = imrect(handles.original_video_axes,start_pos);
        fixedRatio = 0;
    case 'square'
        start_pos = [W/2-W/10, W/2-W/10, W/5, W/5];
        arena_h = imrect(handles.original_video_axes,start_pos);
        fixedRatio = 1;
        setFixedAspectRatioMode(arena_h,fixedRatio);
    case 'polygon'
        arena_h = impoly(handles.original_video_axes);
        if isempty(arena_h)
            delete(arena_h);
            return
        end
        arena_position = wait(arena_h);
        if isempty(arena_position)
            delete(arena_h);
            return
        end
        fixedRatio = 0;
    case 'freehand'
        arena_h = imfreehand(handles.original_video_axes);
        arena_position = wait(arena_h);
        if isempty(arena_position)
            delete(arena_h);
            return
        end
        fixedRatio = 0;
end
% allow deleting only through GUI, not by right click
arena_h.Deletable = false;
% Add arena to handle structure - 
handles = guidata(hObject);

arena = handles.arena;
proposed_name= 'arena ';    
arena.name  = proposed_name;
arena.handle = arena_h;
arena.fixedRatio = fixedRatio;
arena.arena_type = arena_type;
arena_id = rand;
arena.unique_id = arena_id;
handles.arena = arena;

% Update handles structure
guidata(hObject, handles);

% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in save_arena_button.
function save_arena_button_Callback(hObject, eventdata, handles)
% hObject    handle to save_arena_button (see GCBO)
% although the arena interface was used, here these regions are
% called ROIS
ROI = handles.arena;

if isempty(ROI)
    uiwait(msgbox('No Arena was defined','Arena Definition','modal'));
    return
end

% Handles cannot be saved
ROI = rmfield(ROI,'handle');

% Get ROI positions
ROI.roi_position_in_pixels = getPosition(handles.arena.handle);

% Since for each type of IMROI the getPosition returns a different type of
% output, we need specific analysis for each type to extract their
% vertices.
switch ROI.arena_type
    case {'circle','ellipse'}
        arena_vertices = getVertices(handles.arena.handle);
    case {'rectangle','square'}
        pos = getPosition(handles.arena.handle);
        arena_vertices(1,:) = [pos(1) pos(2)];
        arena_vertices(2,:) = [pos(1)+pos(3) pos(2)];
        arena_vertices(3,:) = [pos(1)+pos(3) pos(2)+pos(4)];
        arena_vertices(4,:) = [pos(1)        pos(2)+pos(4)];
        arena_vertices(5,:) = [pos(1) pos(2)]; % close the rect
    case {'polygon','freehand'}
        arena_vertices = getPosition(handles.arena.handle);
        % close the shape if it is not closed - I think it never will
        % be even if a right mouse click is used
        if ~(arena_vertices(size(arena_vertices,1),1) == arena_vertices(1,1) && arena_vertices(size(arena_vertices,1),2) == arena_vertices(1,2))
            arena_vertices(size(arena_vertices,1)+1,:) = arena_vertices(1,:);
        end
end
% Find their centre positions - this is only required for the
% text strings describing their location in the arena interface
ROI.vertices = arena_vertices;
min_x = min(arena_vertices(:,1));
max_x = max(arena_vertices(:,1));
cen_x = mean([min_x max_x]);
min_y = min(arena_vertices(:,2));
max_y = max(arena_vertices(:,2));
cen_y = mean([min_y max_y]);
ROI.centre = [cen_x cen_y];

assignin('base','arena',ROI.vertices);
assignin('base','arena_centre',ROI.centre);

% Save the arena file and close the figure
msgbox('arena data exported to workspace')
uiwait
% close the figure
delete(handles.figure1);
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on selection change in arena_type_menu.
function arena_type_menu_Callback(hObject, eventdata, handles)
% hObject    handle to arena_type_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns arena_type_menu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from arena_type_menu

% --- Executes on selection change in arena_type_menu.
function arena_type_menu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to arena_type_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns arena_type_menu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from arena_type_menu


% --- Executes on button press in find_arena.
function find_arena_Callback(hObject, eventdata, handles)
% hObject    handle to find_arena (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
try
BW = edge(handles.Frame,'Prewitt','nothinning');
BW2 = imdilate(BW,strel('disk',8));
BW3=bwareaopen(BW2,500);

[a,b]=size(BW3);

A=BW3(a/2,:);
B=BW3(:,b/2);
k=find(A==1);
z=find(B==1);
k1=(a/2)-k;
z1=(b/2)-z;
bri=min(sort (find(k1<0)));
x2=k(bri)+5;
gi=max(sort (find(k1>0)));
x1=k(gi)-5;
da=min(sort (find(z1<0)));
y2=z(da)+5;
ila=max(sort (find(z1>0)));
y1=z(ila)-5;
arena_vertices = [x1 y1; x1 y2; x2 y2; x2 y1; x1 y1];

ROI.vertices = arena_vertices;
min_x = min(arena_vertices(:,1));
max_x = max(arena_vertices(:,1));
cen_x = mean([min_x max_x]);
min_y = min(arena_vertices(:,2));
max_y = max(arena_vertices(:,2));
cen_y = mean([min_y max_y]);
ROI.centre = [cen_x cen_y];

% axes(handles.original_video_axes);
% poly_h = plot(vertices(:,1),vertices(:,2));
% set(poly_h,'color','y','linewidth',1,'Tag','ZoneBorder')
% poly_th = text(arena_centre(1),arena_centre(2),'Arena');

assignin('base','arena',ROI.vertices);
assignin('base','arena_centre',ROI.centre);

% Save the arena file and close the figure
msgbox('arena data exported to workspace')
uiwait
close the figure
delete(handles.figure1);
catch
    errordlg('Arena not found','Arena Detection');
end