function results(handles)

[File, Directory, StrFile_in] = uigetfile({'*.*','All Files (*.*)'},'Select video file', path);
filename=(strcat(Directory,File));

%% Read video into MATLAB using aviread
video = VideoReader(filename);
nFrames_tot = video.NumberOfFrames;
vidHeight = video.Height;
vidWidth = video.Width;
FrameRate=video.FrameRate;
Temp=0:1/FrameRate:(nFrames_tot-1)/FrameRate;

% % Define the geometrical sizes
% prompt = {'Enter the horizontal arena size in cm:','Enter the vertical arena size in cm:'};
% dlg_title = 'Input ROI sizes';
% num_lines = 1;
% def = {'50','50'};
% answer = inputdlg(prompt,dlg_title,num_lines,def);
% Xaxis=str2num(answer{1,1});
% Yaxis=str2num(answer{2,1});
Xaxis=handles.arena_x.String;
Yaxis=handles.arena_y.String;

File=File(1:end-4);
StrTrack=strcat(Directory,'\Results\Raw\Out_',File,'.mat');
load(StrTrack)
Centroid=track.Centroid;
Head=track.Head;
Tail=track.Tail;
Time=track.Time;
Area=track.Area;
Axes=track.Axes;
Eccentricity=track.Eccentricity;
Tracked=track.Tracked;
EulerNumber=track.EulerNumber;
ConvexHull=track.ConvexHull;
[a, Np]=size(Time);

StrData=strcat(Directory,'\Results\Raw\Data_',File,'.mat');
load(StrData)
X1=data.arena(1);
X2=data.arena(2);
Y1=data.arena(3);
Y2=data.arena(4);
i_first=data.i_start;
i_last=data.i_end;
% neigh=round(mean(track.Axes(1,:))/5);
D1=X2-X1;
D2=Y2-Y1;

 
% % **************** Interpolating untracked frames
Ecc_tresh=0.5;
i_end=Np;
Nframes=i_last-i_first+1;

% ***********************************
% Get head coordinates
% ***********************************
CurrFrame = rgb2gray(read(video,i_first-1)) ;
clear k point1 finalRect point2 p1 offset
figure
imshow(CurrFrame,[])
hold on
prompt = {'Press OK then select the head'};
answer= inputdlg(prompt, '',0.01);
dlg_title='Noise';
[size1, size2]=size(CurrFrame);
clear k point1 finalRect point2 p1 offset
k = waitforbuttonpress;
point1 = get(gca,'CurrentPoint');    % button down detected
finalRect = rbbox;                   % return figure units
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
xhead = mean(x1,x2);
yhead = mean (y1,y2);

Head(1,i_first-1)=xhead;
Head(2,i_first-1)=yhead;

for i=i_first:i_last
   
    if Area(i)<mean(Area)-3*std(Area)
        Head(1,i)=Head(1,i-1);
        Head(2,i)=Head(2,i-1);
        Tail(1,i)=Tail(1,i-1);
        Tail(2,i)=Tail(2,i-1);
    end
end
i_p=i_first;
while i_p < i_last
    j_p=i_p-i_first+1;
    for i_next = i_p+1:i_last
        if (Tracked(1,i_next)==1), break,  end  % find next tracked frame
    end
    j_next=i_next-i_first+1;
    
    Centroid(1,i_p:i_next)=linspace(Centroid(1,i_p),Centroid(1,i_next),i_next-i_p+1);
    Centroid(2,i_p:i_next)=linspace(Centroid(2,i_p),Centroid(2,i_next),i_next-i_p+1);
    [i_p i_next j_p j_next Centroid(2,j_p)];
    i_p=i_next;
end
disp(['Useful frames between: ',num2str(i_first),' - ',num2str(i_last)])
disp(' ')



%%**************** Fix Head Tail Position
for i_frame=i_first:i_last
    
    deltaH=sqrt((Head(1,i_frame)-Head(1,i_frame-1))^2 + (Head(2,i_frame)-Head(2,i_frame-1))^2);
    deltaT=sqrt((Tail(1,i_frame)-Head(1,i_frame-1))^2 + (Tail(2,i_frame)-Head(2,i_frame-1))^2);
    
    if deltaH<deltaT
    else
        xtail=Head(1,i_frame);
        ytail=Head(2,i_frame);
        Head(1,i_frame)=Tail(1,i_frame);
        Head(2,i_frame)=Tail(2,i_frame);
        Tail(1,i_frame)=xtail;
        Tail(2,i_frame)=ytail;
      end
end

figure
CurrFrame = im2double(rgb2gray(read(video,1)));
imshow(CurrFrame),
hold on
plot(Centroid(1,i_first:i_last),Centroid(2,i_first:i_last))
plot(Head(1,i_first:i_last),Head(2,i_first:i_last))
plot(Tail(1,i_first:i_last),Tail(2,i_first:i_last))
plot(Centroid(1,i_first),Centroid(2,i_first),'r>','MarkerSize',15)
plot(Head(1,i_first),Head(2,i_first),'r>','MarkerSize',15)
plot(Tail(1,i_first),Tail(2,i_first),'r>','MarkerSize',15)
plot(Centroid(1,i_last),Centroid(2,i_last),'rs','MarkerSize',15)
plot(Head(1,i_last),Head(2,i_last),'rs','MarkerSize',15)
plot(Tail(1,i_last),Tail(2,i_last),'rs','MarkerSize',15)
legend('Centroid','Head','Tail')
title('Overall Arena Track recording')
hold off

answer = questdlg('Video?','Video Output','Yes','No','No');
% Handle response
switch answer
    case 'Yes'
        vid = 1;
    case 'No'
        vid = 0;
end

if vid == 1
    
    StrFile_out=strcat(Directory,'\Video_',File,'.avi');
    writerObj = VideoWriter(StrFile_out);
    writerObj.FrameRate = FrameRate;
    open(writerObj);
    f=figure();
    
    Nframes = i_last-i_first+1;
    disp('**** Video Tracking **** ')
    disp([' You have selected ',num2str(Nframes), ' frames to Track'])
    disp(' ')
    
    for i = i_first:i_last
        CurrFrame=rgb2gray(read(video,i));
        imshow(CurrFrame,[])
        title(['Frame n. ',num2str(i)])
        hold on
        plot(Centroid(1,i), Centroid(2,i), 'ro','MarkerSize',10)
        plot(Head(1,i), Head(2,i), 'r.','MarkerSize',15)
        plot(Tail(1,i), Tail(2,i), 'b.','MarkerSize',15)
       
        Vertices=ConvexHull{i};
        Lines=[(1:size(Vertices,1))' (2:size(Vertices,1)+1)']; Lines(end,2)=1;
        plot([Vertices(Lines(:,1),1) Vertices(Lines(:,2),1)]',[Vertices(Lines(:,1),2) Vertices(Lines(:,2),2)]','b');
        plot([Head(1,i) Centroid(1,i)], [Head(2,i) Centroid(2,i)],'g');
        plot([Tail(1,i) Centroid(1,i)], [Tail(2,i) Centroid(2,i)],'g');
        writeVideo(writerObj,getframe(f));
        hold off
    end
    
    close
    close(writerObj);
end

for i=i_first:i_last
    Centroid(1,i)=(Centroid(1,i)-X1)/D2*Xaxis;
    Centroid(2,i)=Yaxis-(Centroid(2,i)-Y1)/D1*Yaxis;
    Head(1,i)=(Head(1,i)-X1)/D2*Xaxis;
    Head(2,i)=Yaxis-(Head(2,i)-Y1)/D1*Yaxis;
    Tail(1,i)=(Tail(1,i)-X1)/D2*Xaxis;
    Tail(2,i)=Yaxis-(Tail(2,i)-Y1)/D1*Yaxis;
end

% %******************** Rotation Analisys
Teta=zeros(1,nFrames_tot);
for i_frame=1:i_first:i_last
    Teta(i_frame)=atan2(Centroid(2,i_frame)-Head(2,i_frame),Centroid(1,i_frame)-Head(1,i_frame));
end

% i_start = Np; i_end = Np+1;
% while (i_start < i_first) || (i_end > i_last) || (i_start >= i_end)
    prompt = {'Enter the first frame to analize:','Enter the last frame to analize:'};
    dlg_title = 'Select Analisys Interval';
    num_lines = 1;
    def = {num2str(i_first),num2str(i_last)};
    answer = inputdlg(prompt,dlg_title,num_lines,def);
    i_start = round(abs(str2double(answer{1,1})));
    i_end = round(abs(str2double(answer{2,1})));
% end

% if i_start2 > i_start, i_start = i_start2; end
% if i_last2 < i_last, i_last = i_last2; end
while Centroid(1,i_start)==0
    i_start=i_start+i;
end
while Centroid(1,i_end)==0
    i_end=i_end-1;
end
% disp(['The effective frame range is ',num2str(i_start),'-',num2str(i_end)])
% disp(['The effective time range is ',num2str(Time(i_start)),'-',num2str(Time(i_end)),' sec'])
Xp = Centroid(1,i_start:i_end);
Yp = Centroid(2,i_start:i_end);
Xh = Head(1,i_start:i_end);
Yh = Head(2,i_start:i_end);
Xt = Tail(1,i_start:i_end);
Yt = Tail(2,i_start:i_end);
AM = Axes(:,i_start:i_end);
Time = Time(i_start:i_end);
Nframes = i_end-i_start+1;
MA=mean(Axes(1,:));
mA=mean(Axes(2,:));
Teta=Teta(i_start:i_end);

%******************** Velocity Analisys
Vx=zeros(1,Nframes);
Vy=zeros(1,Nframes);
for i=1:Nframes-1
    Vx(i)=(Xp(i+1)-Xp(i))/(Time(i+1)-Time(i));
    Vy(i)=(Yp(i+1)-Yp(i))/(Time(i+1)-Time(i));
end
Vx(1,Nframes)=Vx(1,Nframes-1);
Vy(1,Nframes)=Vy(1,Nframes-1);
V=sqrt(Vx.^2+Vy.^2);
V_average=mean(V);
V_std=std(V);
for i=2:Nframes
    if V(i) > 5*V_average
        Xp(i)=Xp(i-1);
        Yp(i)=Yp(i-1);
        V(i)=0;
    end
end

% %******************** Position Analisys
Distance=0;
for i=1:Nframes-1
    dx=Xp(i+1)-Xp(i);
    dy=Yp(i+1)-Yp(i);
    Distance=Distance+sqrt(dx^2+dy^2);
end

% % %**************** Filtering frames positions
% % Paccuracy = 0.2;   % accuracy of position in cm
% % f = 1/Paccuracy;
% % Xp = round(Xp*f)/f;
% % Yp = round(Yp*f)/f;

clear data track

% % Data Structure for Output
data.window = [X1 X2 Y1 Y2];
data.arena = [Xaxis Yaxis];
data.dimesions = [D1, D2];
data.Nframes = Nframes;
track.Centroid(1,:) = Xp;
track.Centroid(2,:) = Yp;
track.Head(1,:) = Xh;
track.Head(2,:) = Yh;
track.Tail(1,:) = Xt;
track.Tail(2,:) = Yt;
track.Area = Area;
track.Axes = AM;
track.Teta = Teta;
track.Time = Time;
track.Velocity = V;
track.Distance = Distance;
track.Tracked = Tracked;
% data.Rearing = Rearing;

% Output
DataFolder=strcat(Directory,'\Results\');
File=File(1:end-4);
StrFile_out=strcat(DataFolder,'\Out_',File,'.mat');
save(StrFile_out, 'data','track')
