function data_export(handles,i_first,i_last)
global vidfilename
[P, base_name , ~] = fileparts(vidfilename);
Time=handles.Time(i_first:i_last);
Centre=handles.Centre;
Nose=handles.Nose;
Butt=handles.Butt;
Area=handles.track.Area(i_first:i_last);
Axes=handles.track.Axes(:,i_first:i_last);
Teta=handles.Teta(i_first:i_last);
R=deg2rad(handles.Theta);
N=handles.N;
V=handles.V;
Distance=handles.Distance(i_first:i_last);
V(1)=0;

rot = unwrap(Teta);
for i = 4:3:length(Teta)-2*N
    a = mean(rot(i-3:i+3));
    b = mean(rot(i+N-3:i+N+3));
    if abs(b-a) > (R)
        rot(i+N/2:end)=rot(i+N/2:end) + (a-b);
    end
end
rotations=rot(end)/(2*pi);

OUT{:,:}= zeros(16+length(handles.Time),14);
OUT{1,1}='Data provided by TrAQ, devoleped by MISPIN Lab';
OUT{2,1}='Video file';
OUT{2,2}=base_name;
OUT{3,1}='Frame Rate (FPS):';
OUT{3,2}=handles.videodata.framerate;
OUT{4,1}='Duration (s):';
OUT{4,2}=((i_last-i_first+1)/handles.videodata.framerate);
OUT{5,1}='Total travelled Distance (cm):';
OUT{5,2}=sum(handles.Distance(i_first:i_last));
OUT{6,1}='Average Speed (cm/s):';
OUT{6,2}=sum(handles.Distance(i_first:i_last))/((i_last-i_first+1)/handles.videodata.framerate);
OUT{7,1}='Mean of Speed (cm/s):';
OUT{7,2}=mean(handles.V);
OUT{8,1}='Speed STD (cm/s):';
OUT{8,2}=std(handles.V);
OUT{9,1}='Speed Skewness:';
OUT{9,2}=skewness(handles.V);
OUT{10,1}='Speed Kurtosis:';
OUT{10,2}=kurtosis(handles.V);
OUT{11,1}='Treshold speed (cm/s):';
OUT{11,2}=2;
OUT{12,1}='Activity %:';
OUT{12,2}=handles.ACT;
OUT{13,1}='Inactivity %:';
OUT{13,2}=100-handles.ACT;
OUT{13,1}='Number of Rotations';
OUT{13,2}=rotations;
OUT{15,1}='Tracking Data:';
OUT{16,1}='Frame Number';
OUT{16,2}='Time (s)';
OUT{16,3}='Centroid X (cm)';
OUT{16,4}='Centroid Y (cm)';
OUT{16,5}='Head X (cm)';
OUT{16,6}='Head Y (cm)';
OUT{16,7}='Tail X (cm)';
OUT{16,8}='Tail Y (cm)';
OUT{16,9}='Area (cm^2)';
OUT{16,10}='Elongation';
OUT{16,11}='Head Direction (rad)';
OUT{16,12}='Speed (cm/s)';
OUT{16,13}='Distance (cm)';

for i=1:length(Time)
    OUT{i+16,1}=i+i_first-1;
    OUT{i+16,2}=Time(i);
    OUT{i+16,3}=Centre(1,i);
    OUT{i+16,4}=Centre(2,i);
    OUT{i+16,5}=Nose(1,i);
    OUT{i+16,6}=Nose(2,i);
    OUT{i+16,7}=Butt(1,i);
    OUT{i+16,8}=Butt(2,i);
    OUT{i+16,9}=Area(i);
    OUT{i+16,10}=max(Axes(i))/min(Axes(i));
    OUT{i+16,11}=Teta(i);
    OUT{i+16,12}=V(i);
    OUT{i+16,13}=Distance(i);
end
File=[P filesep 'Results' filesep 'output_' base_name '.xlsx'];
sheet = 1;
xlRange = 'A1';
xlswrite(File,OUT,sheet,xlRange)

clear OUT
try
    
zones=handles.stats;
zone_names = zones.ROI_name;
number_of_body_visits=zones.number_of_body_visits;
body_zone_durations=zones.body_zone_durations;
number_of_nose_visits=zones.number_of_nose_visits;
nose_zone_durations=zones.nose_zone_durations;
ROI_distance=zones.ROI_distance;

OUT{1,1}='Data provided by TrAQ, devoleped by MISPIN Lab';
OUT{3,1}='ROI name:';

for j=1:length(zone_names)
    OUT{4,j+1}=zone_names(j);
end

OUT{5,1}='number of body visits:';
for j=1:length(number_of_body_visits)
    OUT{5,j+1}=number_of_body_visits(j);
end

OUT{6,1}='Body visits durations (s):';
for j=1:length(number_of_body_visits)
    for k=1:number_of_body_visits(j)
        OUT{6+k,j+1}=body_zone_durations{j}(k);
    end
end

z=max(number_of_body_visits);

OUT{7+z,1}='Number of nose visits:';
for j=1:length(number_of_nose_visits)
        OUT{7+z,j+1}=number_of_nose_visits(j);
end

OUT{8+z,1}='Nose visits durations (s):';
for j=1:length(nose_zone_durations)
    for k=1:number_of_nose_visits(j)
        OUT{8+z+k,j+1}=nose_zone_durations{j}(k);
    end
end

z=z+max(number_of_nose_visits);

OUT{14+z,1}='Distance Nose - ROI (cm):';
OUT{15+z,1}='Time (s)';

for i=1:length(Time)
    OUT{i+16+z,1}=Time(i);
    for j=1:size(ROI_distance,1)
       OUT{i+16+z,j+1}=ROI_distance(j,i);
    end
end

assignin('base','OUT',OUT)
File=[P filesep 'Results' filesep 'output_' base_name '.xlsx'];
sheet = 2;
xlRange = 'A1';
xlswrite(File,OUT,sheet,xlRange)
catch
end