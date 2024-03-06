function update_arena_plot(handles)

axes(handles.plot_axes);
cla(handles.plot_axes)

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

X1=round(min(handles.data.arena(:,1)));
X2=round(max(handles.data.arena(:,1)));
Y1=round(min(handles.data.arena(:,2)));
Y2=round(max(handles.data.arena(:,2)));
Xaxis=str2double(handles.data.arena_x);
Yaxis=str2double(handles.data.arena_y);
D1=X2-X1;
D2=Y2-Y1;

H = get(handles.plot_head, 'Value');
C = get(handles.plot_centroid, 'Value');
T = get(handles.plot_tail, 'Value');

Head(1,:)=(handles.Head(1,:)-X1)/D1*Xaxis;
Head(2,:)=Yaxis-(handles.Head(2,:)-Y1)/D2*Yaxis;
Centroid(1,:)=(handles.Centroid(1,:)-X1)/D1*Xaxis;
Centroid(2,:)=Yaxis-(handles.Centroid(2,:)-Y1)/D2*Yaxis;
Tail(1,:)=(handles.Tail(1,:)-X1)/D1*Xaxis;
Tail(2,:)=Yaxis-(handles.Tail(2,:)-Y1)/D2*Yaxis;

if H==1
    n=plot(Head(1,i_first:i_last),Head(2,i_first:i_last),'r');
    hold on
    plot(Head(1,i_first),Head(2,i_first),'k>','MarkerSize',10)
    plot(Head(1,i_last),Head(2,i_last),'ks','MarkerSize',10)
    axis ([0 Xaxis 0 Yaxis])
    xlabel('X [cm]'); ylabel('Y [cm]');
    
    axis equal;
    axis tight
    hold off
    uistack(n,'bottom')
end
if C==1
    n=plot(Centroid(1,i_first:i_last),Centroid(2,i_first:i_last),'k');
    hold on
    plot(Centroid(1,i_first),Centroid(2,i_first),'k>','MarkerSize',10)
    plot(Centroid(1,i_last),Centroid(2,i_last),'ks','MarkerSize',10)
    axis ([0 Xaxis 0 Xaxis])
    xlabel('X [cm]'); ylabel('Y [cm]');
    axis equal;
    axis tight
    hold off
    uistack(n,'bottom')
end
if T==1
    n=plot(Tail(1,i_first:i_last),Tail(2,i_first:i_last),'b');
    hold on
    plot(Tail(1,i_first),Tail(2,i_first),'k>','MarkerSize',10)
    plot(Tail(1,i_last),Tail(2,i_last),'ks','MarkerSize',10)
    axis ([0 Xaxis 0 Xaxis])
    xlabel('X [cm]'); ylabel('Y [cm]');
    axis equal;
    axis tight
    hold off
    uistack(n,'bottom')
end
if H==1 && C==1
    n=plot(Head(1,i_first:i_last),Head(2,i_first:i_last),'r');
    hold on
    m=plot(Centroid(1,i_first:i_last),Centroid(2,i_first:i_last),'k');
    plot(Centroid(1,i_first),Centroid(2,i_first),'k>','MarkerSize',10)
    plot(Centroid(1,i_last),Centroid(2,i_last),'ks','MarkerSize',10)
    axis ([0 Xaxis 0 Xaxis])
    xlabel('X [cm]'); ylabel('Y [cm]');
    hold off
    axis equal;
    axis tight
end
if H==1 && T==1
    n=plot(Head(1,i_first:i_last),Head(2,i_first:i_last),'r');
    hold on
    m=plot(Tail(1,i_first:i_last),Tail(2,i_first:i_last),'b');
    axis ([0 Xaxis 0 Xaxis])
    xlabel('X [cm]'); ylabel('Y [cm]');
    hold off
    axis equal;
    axis tight
end
if C==1 && T==1
    n=plot(Centroid(1,i_first:i_last),Centroid(2,i_first:i_last),'k');
    hold on
    m=plot(Tail(1,i_first:i_last),Tail(2,i_first:i_last),'b');
    hold on
    plot(Centroid(1,i_first),Centroid(2,i_first),'k>','MarkerSize',10)
    plot(Centroid(1,i_last),Centroid(2,i_last),'ks','MarkerSize',10)
    axis ([0 Xaxis 0 Xaxis])
    xlabel('X [cm]'); ylabel('Y [cm]');
    hold off
    axis equal;
    axis tight
end
if C==1 && T==1 && H==1
    n=plot(Centroid(1,i_first:i_last),Centroid(2,i_first:i_last),'k');
    hold on
    plot(Centroid(1,i_first),Centroid(2,i_first),'k>','MarkerSize',10)
    plot(Centroid(1,i_last),Centroid(2,i_last),'ks','MarkerSize',10)
    m=plot(Tail(1,i_first:i_last),Tail(2,i_first:i_last),'b');
    o=plot(Head(1,i_first:i_last),Head(2,i_first:i_last),'r');
    axis ([0 Xaxis 0 Xaxis])
    xlabel('X [cm]'); ylabel('Y [cm]');
    hold off
    axis equal;
    axis tight
end
% guidata(handles);