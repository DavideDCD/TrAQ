function autofix_head(handles)
M_thresh=get(handles.M_thresh,'Value');

win=floor(handles.movement_win/2);

C_Path(1,:)=movmean(handles.Centroid(1,:),handles.movement_win);
C_Path(2,:)=movmean(handles.Centroid(2,:),handles.movement_win);
H_Path(1,:)=movmean(handles.Head(1,:),handles.movement_win);
H_Path(2,:)=movmean(handles.Head(2,:),handles.movement_win);
T_Path(1,:)=movmean(handles.Tail(1,:),handles.movement_win);
T_Path(2,:)=movmean(handles.Tail(2,:),handles.movement_win);

vec=zeros(length(handles.Centroid),2);
Vdot=zeros(length(handles.Centroid),1);

i_first=handles.data.i_start;
i_last=handles.data.i_end;

for i_frame=i_first+win:i_last-win
    Dx=C_Path(1,i_frame+win)-C_Path(1,i_frame-win);
    Dy=C_Path(2,i_frame+win)-C_Path(2,i_frame-win);
    M=norm(Dx,Dy);
    if M>M_thresh
        vec(i_frame,:)=[Dx,Dy];
        VecH=[handles.Head(1,i_frame)-handles.Centroid(1,i_frame),handles.Head(2,i_frame)-handles.Centroid(2,i_frame)];
        VecT=[handles.Tail(1,i_frame)-handles.Centroid(1,i_frame),handles.Tail(2,i_frame)-handles.Centroid(2,i_frame)];
        Hdot=dot(vec(i_frame,:),VecH);
        Tdot=dot(vec(i_frame,:),VecT);
        if  Tdot>Hdot
            xTail=handles.Head(1,i_frame);
            yTail=handles.Head(2,i_frame);
            handles.Head(1,i_frame)=handles.Tail(1,i_frame);
            handles.Head(2,i_frame)=handles.Tail(2,i_frame);
            handles.Tail(1,i_frame)=xTail;
            handles.Tail(2,i_frame)=yTail;
        end
    else
        Hx = H_Path(1,i_frame)-H_Path(1,i_frame-1);
        Hy = H_Path(2,i_frame)-H_Path(2,i_frame-1);
        Tx = T_Path(1,i_frame)-H_Path(1,i_frame-1);
        Ty = T_Path(2,i_frame)-H_Path(2,i_frame-1);
        H_distance = norm(Hx,Hy);
        T_distance = norm(Tx,Ty);
        if  T_distance<H_distance
            xTail=handles.Head(1,i_frame);
            yTail=handles.Head(2,i_frame);
            handles.Head(1,i_frame)=handles.Tail(1,i_frame);
            handles.Head(2,i_frame)=handles.Tail(2,i_frame);
            handles.Tail(1,i_frame)=xTail;
            handles.Tail(2,i_frame)=yTail;
            vec(i_frame,:)=abs(vec(i_frame,:));
        end
    end
end

update_arena_plot(handles);
update_arena_track(handles);
guidata(handles);