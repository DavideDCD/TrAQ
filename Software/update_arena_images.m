function update_arena_images(handles)

GreyThresh = str2double(handles.detection_threshold_text.String);
Erosion = round(str2double(handles.detection_erosion_text.String));
infostr = round(str2double(get(handles.current_frame_edit,'String')));
Frame = read(handles.video,infostr);
cla(handles.sec_video_axes);
axes(handles.sec_video_axes);
if 	strcmp(handles.color_space,'grays')==1
    Frame = rgb2gray(Frame);
elseif strcmp(handles.color_space,'red')==1
    Frame = Frame(:,:,1);
elseif strcmp(handles.color_space,'green')==1
    Frame=Frame(:,:,2);
elseif strcmp(handles.color_space,'blue')==1
    Frame=Frame(:,:,3);
end
try 
    if handles.lvl>140
    GreyThresh=1-GreyThresh;
    Frame=255-Frame;
    end
catch
end
BW=imerode(imbinarize(Frame,GreyThresh),strel('disk',Erosion));
h = imshow(BW);
axis equal;
axis tight
uistack(h,'bottom')