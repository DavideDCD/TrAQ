function [i_first,i_last] = getFrameBounds(handles)
% Compute frame indices from first/last time edits, clamp to video and data bounds
    first_time = str2double(handles.first_time_edit.String);
    last_time = str2double(handles.last_time_edit.String);
    i_first = floor(first_time * handles.video.FrameRate);
    i_last = floor(last_time * handles.video.FrameRate);

    % Respect data.i_start / i_end when available
    if isfield(handles,'data') && isfield(handles.data,'i_start')
        i_first = max(i_first, handles.data.i_start);
    else
        i_first = max(i_first, 1);
    end
    if isfield(handles,'data') && isfield(handles.data,'i_end')
        i_last = min(i_last, handles.data.i_end);
    else
        i_last = min(i_last, handles.video.NumberOfFrames);
    end

    % Final clamp to video frame range
    i_first = max(1, min(i_first, handles.video.NumberOfFrames));
    i_last = max(1, min(i_last, handles.video.NumberOfFrames));
end