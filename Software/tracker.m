
function track = tracker(data, handles)
% Input:
%   vObj: VideoReader object
%   startFrame, endFrame
%   data: struct containing .Bkg .GreyThresh, .Erosion, .Area_th, .LiveView

    % --- setting up ---

    vObj = handles.video;
    startFrame = data.i_start;
    endFrame = data.i_end; % Define endFrame based on input data
    nFrames = endFrame - startFrame + 1;
    track.Centroid = nan(2, endFrame);
    track.Head     = nan(2, endFrame);
    track.Tail     = nan(2, endFrame);
    track.Area     = nan(1, endFrame);
    track.Tracked   = zeros(1,endFrame);
    track.Eccentricity = nan(1, endFrame);
    track.EulerNumber = nan(1, endFrame);
    track.ConvexHull = {};
    track.Axes  = nan(2, endFrame);
    Bkg = single(data.Bkg);
    avgBkg = mean(Bkg(:));    
    vObj.CurrentTime = (startFrame - 1) / vObj.FrameRate;
    
    % Setup live view
    if data.LiveView
        axes(handles.sec_video_axes)
        hIm = imshow(zeros(size(Bkg),'uint8'),[0 1]); 
        hold on;
        hPt = plot(0,0,'g+','MarkerSize',10);
    end
    
    % erosion
    se = strel('disk', max(1, floor(data.Erosion)));
    useErosion = data.Erosion > 0;

    % --- Tracking ---
    hWait = waitbar(0, 'Tracking...');
    
    track.Time=0:1/vObj.FrameRate:(endFrame-1)/vObj.FrameRate;
    count = 0;
    while hasFrame(vObj) && count < nFrames
        count = count + 1;
        
        rawFrame = readFrame(vObj);
        
        % grayscale conversion
        if size(rawFrame, 3) == 3
            currFrame = single(rgb2gray(rawFrame));
        else
            currFrame = single(rawFrame);
        end
        
        % Background subtraction
        if avgBkg > 100
             diffFrame = (single(255) - currFrame) - (single(255) - Bkg);
        else
             diffFrame = currFrame - Bkg;
        end
        
        % increase differences
        diffFrame = diffFrame .^ 2;
        
        % image normalization and binarization
        maxVal = max(diffFrame(:));
        if maxVal > 0
            diffFrame = diffFrame / maxVal;
        end
                BW = imbinarize(diffFrame, data.GreyThresh);
        
        if useErosion
            BW = imerode(BW, se);
        end
        
        % Blob analysis
        props = regionprops(BW, {'Area', 'Centroid', 'PixelList','MajorAxisLength','MinorAxisLength', 'Eccentricity','ConvexHull','EulerNumber'});
        
        found = false;
        if ~isempty(props)
            % find biggest blob
            [maxArea, idx] = max([props.Area]);
            
            if maxArea > data.Area_th
                found = true;
                blob = props(idx);
                
                % save data
                track.Area(count + startFrame - 1) = maxArea;
                track.Centroid(:, count + startFrame - 1) = blob.Centroid';
                track.Eccentricity(count + startFrame - 1) = blob.Eccentricity;
                track.EulerNumber(count + startFrame - 1) = blob.EulerNumber;
                track.ConvexHull{count + startFrame - 1} = blob.ConvexHull;               
                track.Axes(1,count + startFrame - 1) = blob.MajorAxisLength;
                track.Axes(2,count + startFrame - 1) = blob.MinorAxisLength;
                
                
                % --- Head&tail localization ---
                pixels = blob.PixelList; % [x, y]
                if useErosion
                    dists = sum((pixels - blob.Centroid).^2, 2); % calculate head-tail position using quadratic distance
                    [~, idxHead] = max(dists);
                    headPos = pixels(idxHead, :);

                    distsFromHead = sum((pixels - tailPos).^2, 2);
                    [~, idxTail] = max(distsFromHead);
                    tailPos = pixels(idxTail, :);

                    track.Tail(:, count + startFrame - 1) = tailPos';
                    track.Head(:, count + startFrame - 1) = headPos';
                else
                    BW1 = false(size(BW));
                    ind = sub2ind(size(BW), pixels(:,2), pixels(:,1));
                    BW1(ind) = 1;
                    % Identify the tail as the farthest point from centroid
                    dists = bwdistgeodesic(BW1,floor(blob.Centroid(1)),floor(blob.Centroid(2)),'quasi-euclidean'); % calculate head-tail position using geodesic distance
                    [~,val_max_idx] = max(dists(:));
                    [tailPos(2), tailPos(1)] = ind2sub(size(dists),val_max_idx);
                    
                    % Identify the head as the fartherst point from the tail
                    dists = bwdistgeodesic(BW1,floor(tailPos(1)),floor(tailPos(2)),'quasi-euclidean');
                    [~,val_max_idx] = max(dists(:));
                    [headPos(2), headPos(1)] = ind2sub(size(dists),val_max_idx);

                    track.Tail(:, count + startFrame - 1) = tailPos';
                    track.Head(:, count + startFrame - 1) = headPos';
                end
                track.Tracked(count + startFrame - 1) = 1;
            end
        end
        
        % handling errors
        if ~found && count > 1
            track.Centroid(:, count) = track.Centroid(:, count-1);
            track.Head(:, count)     = track.Head(:, count-1);
            track.Tail(:, count)     = track.Tail(:, count-1);
        end

        % Update live video
        if data.LiveView && mod(count, 3) == 0
            set(hIm, 'CData', BW);
            if found
                set(hPt, 'XData', track.Centroid(1,count + startFrame - 1), 'YData', track.Centroid(2,count + startFrame - 1));
            end
            drawnow limitrate;
        end
        
        % waitbar update every 50 frame
        if mod(count, 50) == 0
            waitbar(count / nFrames, hWait);
        end
    end
    
    close(hWait);

track.GreyThresh = data.GreyThresh;

% Output
video_file = cellstr(get(handles.video_file_listbox,'String'));
file = video_file{get(handles.video_file_listbox,'Value')};
pFrames = sum(track.Tracked)/(endFrame-startFrame+1)*100;
disp([num2str(pFrames), '% of selected frames has been tracked'])
DataFolder = [handles.folder_name filesep 'Results' filesep 'Raw'];
StrFile_out = [DataFolder filesep 'Out_',file(1:end-4),'.mat'];
save(StrFile_out, 'track')

msgbox('Track complete','TrAQ');

end