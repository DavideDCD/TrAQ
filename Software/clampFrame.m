function fn = clampFrame(fn, handles)
% Round and clamp a frame index to valid range (avoid last 5 frames)
    fn = round(fn);
    maxFrame = max(1, handles.video.NumberOfFrames - 5);
    fn = min(fn, maxFrame);
    fn = max(fn, 1);
end