function [Bkg]=Backgrounder(video,vidHeight,vidWidth,i_start,i_end,color_space)

nSamples = 50;
    
    % Frame stack preallocation (H x W x N_frames)
    frameStack = zeros(vidHeight, vidWidth, nSamples, 'uint8');
    
    % generate random indeces
    randIndices = randi([i_start, i_end], 1, nSamples);
    
    % color channel selection
    channelMap = containers.Map({'red','green','blue','grays'}, {1, 2, 3, 0});
    chan = channelMap(color_space);
    
    disp(['Calculating Bacgkround over ', num2str(nSamples), ' random frames...']);
    
    for i = 1:nSamples
        video.CurrentTime = (randIndices(i) - 1) / video.FrameRate;
        
        rawFrame = readFrame(video);
        
        if size(rawFrame, 3) == 3
            if chan == 0 % Grays
                frameStack(:,:,i) = rgb2gray(rawFrame);
            else % Color channel
                frameStack(:,:,i) = rawFrame(:,:,chan);
            end
        else
            frameStack(:,:,i) = rawFrame;
        end
    end
        
    Bkg = mode(frameStack, 3);
    
    disp('Done');
end
