function update_arena_image(handles)
fn = round(str2double(get(handles.current_frame_edit,'String')));
Frame = read(handles.video,fn);
cla(handles.main_video_axes);
axes(handles.main_video_axes);
h = imshow(Frame);
e=evalin('base','who');
if ismember('arena',e)
    hold on
    vertices=evalin('base','arena');
    arena_centre=evalin('base','arena_centre');
    poly_h = plot(vertices(:,1),vertices(:,2));
    set(poly_h,'color','y','linewidth',1,'Tag','ArenaBorder')
    poly_th = text(arena_centre(1),arena_centre(2),'Arena');
    set(poly_th,'Color','y','Tag','ArenaText','HorizontalAlignment','center', 'VerticalAlignment','middle','Interpreter','none');
    hold off
end
axis equal;
axis tight
uistack(h,'bottom')
