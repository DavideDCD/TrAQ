function update_arena_track(handles)
global video  
fn = round(str2double(get(handles.current_frame_edit,'String')));
Frame = read(video,fn);

axes(handles.oden_video_axes);
cla(handles.oden_video_axes)
if handles.lvl>100
h=imshow(Frame,[]);
else
h = imshow(rgb2gray(Frame)-handles.data.Bkg,[]);
end
hold on
if fn-handles.data.i_start<300
    plot(handles.Centroid(1,handles.data.i_start:fn),handles.Centroid(2,handles.data.i_start:fn))
else
    plot(handles.Centroid(1,fn-300:fn),handles.Centroid(2,fn-300:fn))
end
plot(handles.Centroid(1,fn), handles.Centroid(2,fn),'ko','MarkerSize',10)
plot(handles.Head(1,fn), handles.Head(2,fn), 'r.','MarkerSize',15)
plot(handles.Tail(1,fn), handles.Tail(2,fn), 'b.','MarkerSize',15)

try
    if handles.data.Erosion > 0
        Vertices=handles.track.ConvexHull{fn};
        Lines=[(1:size(Vertices,1))' (2:size(Vertices,1)+1)']; Lines(end,2)=1;
        plot([Vertices(Lines(:,1),1) Vertices(Lines(:,2),1)]',[Vertices(Lines(:,1),2) Vertices(Lines(:,2),2)]','b');
        plot([handles.Head(1,fn) handles.Centroid(1,fn)], [handles.Head(2,fn) handles.Centroid(2,fn)],'g');
        plot([handles.Tail(1,fn) handles.Centroid(1,fn)], [handles.Tail(2,fn) handles.Centroid(2,fn)],'g');
    end
catch
end

vertices=handles.data.arena;
arena_centre=handles.data.arena_centre;
poly_h = plot(vertices(:,1),vertices(:,2));
set(poly_h,'color','y','linewidth',1,'Tag','ZoneBorder')
poly_th = text(arena_centre(1),arena_centre(2),'Arena');
set(poly_th,'Color','y','Tag','ZoneText','HorizontalAlignment','center', 'VerticalAlignment','middle','Interpreter','none');

if isempty(handles.zones)
else
    % plot polygons over arena - and text with arena name at the centre
for i = 1:length(handles.zones)   
    poly_h = plot(handles.zones(i).vertices(:,1),handles.zones(i).vertices(:,2));
    set(poly_h,'color','g','linewidth',1,'Tag','ArenaBorder')
    poly_th = text(handles.zones(i).centre(1),handles.zones(i).centre(2),handles.zones(i).name);
    set(poly_th,'Color','g','Tag','ArenaText','HorizontalAlignment','center', 'VerticalAlignment','middle','Interpreter','none');
end
end
hold off
axis equal;
axis tight
uistack(h,'bottom')