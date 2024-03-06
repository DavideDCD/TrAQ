function tracker(handles)
global video vidfilename

if exist ('File')==1
    File=evalin('base','File');
    if strcmp(File,vidfilename(r+2:end-4))==0
        disp ('Wrong Video');
        return
    end
end
[P, base_name , ~] = fileparts(vidfilename);
data_dir = [P filesep 'Results' filesep 'Raw' filesep 'Data'];
data_file_name = [data_dir filesep base_name '_data.mat'];
load(data_file_name);

%% Read video into MATLAB using aviread
nFrames_tot = data.nFrames_tot;
FrameRate=video.FrameRate;
Temp=0:1/FrameRate:(nFrames_tot-1)/FrameRate;
color_space=data.color_space;

vertices = data.arena;
x1=round(vertices(1,1));
x2=round(vertices(2,1));
y1=round(vertices(1,2));
y2=round(vertices(end-1,2));
handles.lvl=mean(mean(data.Bkg(y1:y2,x1:x2)));
if handles.lvl>100
    Bkg=255-data.Bkg;
    data.GreyThresh = 1 - data.GreyThresh;
else
    Bkg=data.Bkg;
end

Erosion=data.Erosion;
vidHeight=data.vidHeight;
vidWidth=data.vidWidth;
i_start=data.i_start;
i_end=data.i_end;
try
    [Signal_avg,~]=ratfinder(Bkg,video,i_start,nFrames_tot,handles.lvl);
catch
    %use this function to get the rat ROI if the autodetection fails
    CurrFrame = im2double(rgb2gray(read(video,i_start))) ;
    clear k point1 finalRect point2 p1 offset
    figure
    imshow(CurrFrame,[])
    hold on
    prompt = {'Press OK then specify a ROI on the animal'};
    inputdlg(prompt, '',0.01);
    [size1, size2]=size(CurrFrame);
    waitforbuttonpress;
    point1 = get(gca,'CurrentPoint');    % button down detected
    rbbox;                               % return figure units
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
    axis manual
    p1=plot(xCoords, yCoords); % redraw in dataspace units
    set(p1,'Color','red','LineWidth',2)
    Rat = CurrFrame(y1:y2,x1:x2);
    Signal_avg=mean(mean(Rat));
end
GreyThresh = (Signal_avg^2)*data.GreyThresh;

disp(['**** Video ', get(handles.video_file_listbox,'Value'),' **** '])
disp([num2str(nFrames_tot), ' frames'])
disp([num2str(vidWidth), ' x ',num2str(vidHeight),' size' ])
disp([num2str(FrameRate), ' frames per second'])
disp([num2str((nFrames_tot-1)/FrameRate), ' s total duration'])
disp(' ')
disp('**** Video Tracking **** ')
disp([' You have selected ',num2str(i_end-i_start+1), ' frames to Track'])
disp(' ')

if data.arena==0
else
    F=roipoly(vidHeight,vidWidth,data.arena(:,1),data.arena(:,2));
end

% ***********************************
% 3 ----> Tracking algorithm
% ***********************************
disp('')
disp('Movie analized...')
disp(['Discard first ',num2str(i_start-1),' frames'])
Time(:) = Temp;
Centroid(1:2,:) = zeros(2,nFrames_tot);
Head(1:2,:) = zeros(2,nFrames_tot);
Tail(1:2,:) = zeros(2,nFrames_tot);
Area(1,:) = zeros(1,nFrames_tot);
Axes(1:2,:) = zeros(2,nFrames_tot);
Tracked(1,:) = zeros(1,nFrames_tot);    % flag 1 if ok, 0 otherwise
Eccentricity(1,:) = zeros(1,nFrames_tot);
EulerNumber(1,:) = zeros(1,nFrames_tot);
ConvexHull{1,:}= zeros(1,nFrames_tot);

if 	strcmp(color_space,'grays')==1
    color = 4;
elseif strcmp(color_space,'red')==1
    color = 1;
elseif strcmp(color_space,'green')==1
    color = 2;
elseif strcmp(color_space,'blue')==1
    color = 3;
end

axes(handles.sec_video_axes);

if color==4
    tic
    for i_frame = i_start:i_end
        if i_frame==i_start+51
            elapsedTime = toc;
            disp([num2str(round((i_end-i_start+1)/(50*60)*elapsedTime)),' min to complete the tracking']),
        end
        j = i_frame-i_start+1;
        if rem(j,100)==0, disp([num2str(j),' of ', num2str(i_end-i_start+1)]), end
        if handles.lvl>100
            CurrFrame=(255-(rgb2gray(read(video,i_frame))));
            if data.arena==0
                CurrFrame=(single(CurrFrame-(Bkg)).^2);
            else
                CurrFrame=(single(CurrFrame-(Bkg)).^2).*F;
            end
        else
            CurrFrame=(rgb2gray(read(video,i_frame)));
            if data.arena==0
                CurrFrame=(single(CurrFrame-(Bkg)).^2);
            else
                CurrFrame=(single(CurrFrame-(Bkg)).^2).*F;
            end
        end
        BW = imerode(imbinarize(CurrFrame,GreyThresh),strel('disk',floor(Erosion)));
        [xhead,yhead,xtail,ytail,maxArea,cc,majoraxis,minoraxis,eccentricity,vertices,eulernumber,~,flag]=getcoordinates(BW,handles.Area_th,Erosion);
        
        if get(handles.live_tracking, 'Value') == 1
            imshow(BW,[]);
            hold on
            plot(cc(1),cc(2),'g+')
            hold off
        end
        
        if flag ==0
            if i_frame>i_start+2
                Centroid(1,i_frame)=Centroid(1,i_frame-1);
                Centroid(2,i_frame)=Centroid(2,i_frame-1);
                Head(1,i_frame)=Head(1,i_frame-1);
                Head(2,i_frame)=Head(2,i_frame-1);
                Tail(1,i_frame)=Tail(1,i_frame-1);
                Tail(2,i_frame)=Tail(2,i_frame-1);
                Area(1,i_frame) =Area(1,i_frame-1);
                Axes(1,i_frame)=Axes(1,i_frame-1); % Axes lenght
                Axes(2,i_frame)=Axes(2,i_frame-1);
                Eccentricity(1,i_frame) = Eccentricity(1,i_frame-1);
                EulerNumber(1,i_frame) = EulerNumber(1,i_frame-1);
                ConvexHull{i_frame}=ConvexHull{i_frame-1};
            end
        else
            Tracked(1,i_frame)=1;
            Centroid(1,i_frame)=cc(1);
            Centroid(2,i_frame)=cc(2);
            Head(1,i_frame)=xhead;
            Head(2,i_frame)=yhead;
            Tail(1,i_frame)=xtail;
            Tail(2,i_frame)=ytail;
            Area(1,i_frame) =maxArea;
            Axes(1,i_frame)=majoraxis; % Axes lenght
            Axes(2,i_frame)=minoraxis;
            Eccentricity(1,i_frame) = eccentricity;
            EulerNumber(1,i_frame) = eulernumber;
            ConvexHull{i_frame}=vertices;
        end
        if j==1
            whos
        end
        clear markimg labelimg
    end
    disp(['Discard last ',num2str(nFrames_tot-i_end-1),' frames'])
    toc
else
    for i_frame = i_start:i_end
        if i_frame==i_start+51
            elapsedTime = toc;
            disp([num2str(round((i_end-i_start+1)/(50*60)*elapsedTime)),' min to complete the tracking']),
        end
        j = i_frame-i_start+1;
        if rem(j,100)==0, disp([num2str(j),' of ', num2str(i_end-i_start+1)]), end
        if handles.lvl>100
            CurrFrame=(read(video,i_frame));
            CurrFrame=255-(CurrFrame(:,:,color));
            if data.arena==0
                CurrFrame=(single(CurrFrame-(Bkg)).^2);
            else
                CurrFrame=(single(CurrFrame-(Bkg)).^2).*F;
            end
        else
            CurrFrame=(read(video,i_frame));
            CurrFrame=CurrFrame(:,:,color);
            if data.arena==0
                CurrFrame=(single(CurrFrame-(Bkg)).^2);
            else
                CurrFrame=(single(CurrFrame-(Bkg)).^2).*F;
            end
        end
        BW = imerode(imbinarize(CurrFrame,GreyThresh),strel('disk',Erosion));
        [xhead,yhead,xtail,ytail,maxArea,cc,majoraxis,minoraxis,eccentricity,vertices,eulernumber,~,flag]=getcoordinates(BW,handles.Area_th,Erosion);
        
        if get(handles.live_tracking, 'Value') == 1
            imshow(BW,[]);
            hold on
            plot(cc(1),cc(2),'g+')
            hold off
        end
        
        if flag ==0
            if i_frame>i_start+2
                Centroid(1,i_frame)=Centroid(1,i_frame-1);
                Centroid(2,i_frame)=Centroid(2,i_frame-1);
                Head(1,i_frame)=Head(1,i_frame-1);
                Head(2,i_frame)=Head(2,i_frame-1);
                Tail(1,i_frame)=Tail(1,i_frame-1);
                Tail(2,i_frame)=Tail(2,i_frame-1);
                Area(1,i_frame) =Area(1,i_frame-1); % mass of the centroid
                Axes(1,i_frame)=Axes(1,i_frame-1);  % Axes lenght
                Axes(2,i_frame)=Axes(2,i_frame-1);
                Eccentricity(1,i_frame) = Eccentricity(1,i_frame-1);
                EulerNumber(1,i_frame) = EulerNumber(1,i_frame-1);
                ConvexHull{i_frame}=ConvexHull{i_frame-1};
            end
        else
            Tracked(1,i_frame)=1;
            Centroid(1,i_frame)=cc(1);
            Centroid(2,i_frame)=cc(2);
            Head(1,i_frame)=xhead;
            Head(2,i_frame)=yhead;
            Tail(1,i_frame)=xtail;
            Tail(2,i_frame)=ytail;
            Area(1,i_frame) =maxArea;  % mass of the centroid
            Axes(1,i_frame)=majoraxis; % Axes lenght
            Axes(2,i_frame)=minoraxis;
            Eccentricity(1,i_frame) = eccentricity;
            EulerNumber(1,i_frame) = eulernumber;
            ConvexHull{i_frame}=vertices;
        end
        if j==1
            whos
        end
        clear markimg labelimg
    end
    disp(['Discard last ',num2str(nFrames_tot-i_end-1),' frames'])
    toc
end

% Data Structure for Output
track.Centroid = Centroid;
track.Head = Head;
track.Tail = Tail;
track.Area = Area;
track.Axes = Axes;
track.Tracked = Tracked;
track.Time = Time;
track.Eccentricity=Eccentricity;
track.EulerNumber=EulerNumber;
track.ConvexHull=ConvexHull;
track.GreyThresh = GreyThresh;

% Output
video_file = cellstr(get(handles.video_file_listbox,'String'));
file=video_file{get(handles.video_file_listbox,'Value')};
pFrames=sum(Tracked(1,i_start:i_end))/(i_end-i_start+1)*100;
disp([num2str(pFrames), '% of selected frames has been tracked'])
DataFolder=[handles.video_dir_text.String filesep 'Results' filesep 'Raw'];
StrFile_out=[DataFolder filesep 'Out_',file(1:end-4),'.mat'];
save(StrFile_out, 'track')

msgbox('Track complete','TrAQ');
end

