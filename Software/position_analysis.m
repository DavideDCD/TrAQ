function [stats]=position_analysis(handles)

i_first=handles.data.i_start;
i_last=handles.data.i_end;
Time=handles.Time(i_first:i_last);
Centroid=handles.Centroid(:,i_first:i_last);
Head=handles.Head(:,i_first:i_last);

%% get zone vertices and areas
deltaT=1/handles.videodata.framerate; %length of a frame in sec
X1=round(min(handles.data.arena(:,1)));
X2=round(max(handles.data.arena(:,1)));
D1=X2-X1;
Xaxis=str2double(handles.data.arena_x);
Yaxis=str2double(handles.data.arena_y);
pixels_per_cm=D1/Xaxis;
zones = handles.zones;
zone_names = {zones.name};

% Get vertices and area
for i = 1:length(zones)
    vertices{i} = (handles.zones(i).vertices(1:end-1,:));
    zone_area(i) = polyarea(vertices{i}(:,1),vertices{i}(:,2))/pixels_per_cm^2;
end

for i = 1:length(zones)
    % check if mouse was in zone for each frame
    nose_position(i,:) = inpolygon(Head(1,:),Head(2,:),vertices{i}(:,1),vertices{i}(:,2)) ;
    % cumulative sum of time spent
    tot_nose_position(i,:) = cumsum(nose_position(i,:));
    % same for body positions
    body_position(i,:) = inpolygon(Centroid(1,:),Centroid(2,:),vertices{i}(:,1),vertices{i}(:,2)) ;
    tot_body_position(i,:) = cumsum(body_position(i,:));
end

% total frames in each zone
total_frames_nose = tot_nose_position(:,end);
total_frames_body = tot_body_position(:,end);

% multiply to get time in each tzone
total_time_nose = total_frames_nose * deltaT;
total_time_body = total_frames_body * deltaT;

% first do nose ...
for k = 1:length(zones)
    zone_visits{k} = [];
    zone_transitions =     diff(nose_position(k,:));
    % the one is added because this is a diff operation
    zone_entries     = find(zone_transitions == 1)  + 1;
    zone_exits       = find(zone_transitions == -1) + 1;
    
    vi = 1;
    % make a list of all visits
    if ~isempty(zone_exits) && ~isempty(zone_entries)
        if zone_exits(1) < zone_entries(1)
            zone_visits{k}(vi,:) = [1 zone_exits(1)] * deltaT;
            zone_exits(1) = [];
            vi = vi + 1;
        end
    elseif ~isempty(zone_exits) && isempty(zone_entries) % if we have only one exit and no entries
        zone_visits{k}(vi,:) = [1 zone_exits(1)] * deltaT;
        zone_exits(1) = [];
        vi = vi + 1;
    end
    
    if ~isempty(zone_entries)
        for eni = 1:length(zone_entries)
            this_start = zone_entries(eni);
            % we look for the first exit that is larger than this entry
            % by design, there should be not additional entries before this
            % exit
            minind     = min(find(zone_exits > zone_entries(eni)));
            if isempty(minind) % if there is an entry without a subsequent exit
                this_end = size(nose_position(k,:),2);
            else
                this_end   = zone_exits(minind);
            end
            zone_visits{k}(vi,:) = [this_start this_end] * deltaT;
            vi = vi + 1;
        end
    end
    zone_durations{k} = diff(zone_visits{k},[],2);
end % end of nose
nose_zone_visits    = zone_visits;
nose_zone_durations = zone_durations;
clear zone_visits zone_durations

% then do body - the difference is only in the first line within the
% loop
for k = 1:length(zones)
    
    zone_visits{k} = [];
    zone_transitions =     diff(body_position(k,:));
    % the one is added because this is a diff operation
    zone_entries     = find(zone_transitions == 1)  + 1;
    zone_exits       = find(zone_transitions == -1) + 1;
    
    vi = 1;
    % make a list of all visits
    if ~isempty(zone_exits) && ~isempty(zone_entries)
        if zone_exits(1) < zone_entries(1)
            zone_visits{k}(vi,:) = [1 zone_exits(1)] * deltaT;
            zone_exits(1) = [];
            vi = vi + 1;
        end
    elseif ~isempty(zone_exits) && isempty(zone_entries) % if we have only one exit and no entries
        zone_visits{k}(vi,:) = [1 zone_exits(1)] * deltaT;
        zone_exits(1) = [];
        vi = vi + 1;
    end
    
    if ~isempty(zone_entries)
        for eni = 1:length(zone_entries)
            this_start = zone_entries(eni);
            % we look for the first exit that is larger than this entry
            % by design, there should be not additional entries before this
            % exit
            minind     = min(find(zone_exits > zone_entries(eni)));
            if isempty(minind) % if there is an entry without a subsequent exit
                this_end = size(nose_position(k,:),2);
            else
                this_end   = zone_exits(minind);
            end
            zone_visits{k}(vi,:) = [this_start this_end] * deltaT;
            vi = vi + 1;
        end
    end
    zone_durations{k} = diff(zone_visits{k},[],2);
end % end of body
body_zone_visits    = zone_visits;
body_zone_durations = zone_durations;
clear zone_visits zone_durations

ROI_distance=zeros(length(zones),length(Time)); 

for j=1:length(Time)
    for  i=1:length(zones)
    ROI_distance(i,j)=sqrt((Head(1,j)-zones(i).centre(1))^2 + (Head(2,j)-zones(i).centre(2))^2)/pixels_per_cm;
    end
end

%% plot zone stats as a function of time
figure
set(gcf,'numbertitle','off')
set(gcf,'name',['Zone occupancy as a function of time']);

subplot(2,1,1)
% run over each event
for k = 1:length(zones)
    % construct a vector of nans (all frames, including "bad ones")
    this_zone_times = nan(1,length(nose_position(1,:)));
    % assign an integer value to frames that include the event
    this_zone_times(nose_position(k,:)) = k;
    % plot then
    plot(Time,this_zone_times,'.');
    %             set(ph,'color',zone_colors(zi,:))
    hold on
end
set(gca,'Ytick',[1:length(zones)]);
set(gca,'YtickLabel',zone_names);
set(gca,'YLim' ,[0 length(zones)+1]);
set(gca,'xlim',[0 Time(end)])
xlabel('time s');
title('Zone occupancy of nose as a function of time')

subplot(2,1,2)
for k = 1:length(zones)
    % construct a vector of nans (all frames, including "bad ones")
    this_zone_times = nan(1,length(body_position(1,:)));
    % assign an integer value to frames that include the event
    this_zone_times(body_position(k,:)) = k;
    % plot then
    plot(Time,this_zone_times,'.');
    %             set(ph,'color',zone_colors(zi,:))
    hold on
end

set(gca,'Ytick',[1:length(zones)]);
set(gca,'YtickLabel',zone_names);
set(gca,'YLim' ,[0 length(zones)+1]);
set(gca,'xlim',[0 Time(end)])
xlabel('time s');
title('Zone occupancy of body as a function of time')

figure
set(gcf,'numbertitle','off')
set(gcf,'name',['Euclidean distance Head - ROIs centre']);

% % This will plot the euclidean distance Head - ROIs centre
plot(Time,ROI_distance(1,:));
hold on
for k=2:length(zones)
    plot(Time,ROI_distance(k,:));
end

axis tight
legend (zones.name)
set(gca,'XLim',[0 Time(end)])
xlabel('time s');
ylabel('Distance [cm]');
title('Head - ROIs distance')

number_of_nose_visits=zeros(length(zones),1);
number_of_body_visits=zeros(length(zones),1);

for i=1:length(nose_zone_visits)
number_of_nose_visits(i)=size(nose_zone_visits{i},1);
end

for i=1:length(body_zone_visits)
number_of_body_visits(i)=size(body_zone_visits{i},1);
end

% % This will plot the number of visits per zone
figure
set(gcf,'numbertitle','off')
set(gcf,'name',['Number of nose visits']);
bar(number_of_nose_visits);
ylabel('Number of Visits')
xlabel('Zones')
set(gca,'Xtick',[1:length(zones)]);
set(gca,'XtickLabel',zone_names);

figure
set(gcf,'numbertitle','off')
set(gcf,'name',['Number of body visits']);
bar(number_of_body_visits);
ylabel('Number of Visits')
xlabel('Zones')
set(gca,'Xtick',[1:length(zones)]);
set(gca,'XtickLabel',zone_names);

stats.ROI_name=zone_names;
stats.ROI_distance=ROI_distance;
stats.number_of_body_visits=number_of_body_visits;
stats.body_zone_visits = body_zone_visits;
stats.body_zone_durations=body_zone_durations;
stats.number_of_nose_visits=number_of_nose_visits;
stats.nose_zone_visits = nose_zone_visits;
stats.nose_zone_durations=nose_zone_durations;

assignin('base','stats',stats);