function redraw(frame, vidObj, time)
% REDRAW  Process a particular frame of the video
%   REDRAW(FRAME, VIDOBJ)
%       frame  - frame number to process
%       vidObj - VideoReader object

% Read frame
frame
f = vidObj.read(frame);
nFrames = vidObj.NumberOfFrames;
vidHeight = vidObj.Height;
vidWidth = vidObj.Width;


if frame<1,
    frame=1; time=0;
end
if frame>nFrames,
    frame=nFrames;time=9999;
end
% Get edge
%f2 = edge(rgb2gray(f), 'canny');
text_str = cell(2,1);
conf_val = [frame time]; 
text_str{1} = ['Frame n. ' num2str(conf_val(1),'%0.0f') '    '];
text_str{2} = ['Time     ' num2str(conf_val(2),'%0.2f') ' sec'];
position = [5 vidHeight-30; round(vidWidth/2) vidHeight-30]; % [x y]
box_color = {'blue','blue'};
GREY=rgb2gray(f);
LOW=min(min(GREY));
HIGH=max(max(GREY));

RGB = insertText(f, position, text_str, 'FontSize', 18, 'BoxColor', box_color, 'BoxOpacity', 0.4);

% Overlay edge on original image
%f3 = bsxfun(@plus, f,  uint8(255*f2));

% Display
%image( rgb2gray(RGB) ); axis image off
GREY=rgb2gray(RGB);
imshow(GREY,[LOW HIGH])

end
