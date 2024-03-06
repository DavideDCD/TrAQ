function video_files(handles)

mp4files = dir([handles.video_dir_text.String filesep '*.mp4']); % to add additional file extensions copy this string
avifiles = dir([handles.video_dir_text.String filesep '*.avi']);
mpgfiles = dir([handles.video_dir_text.String filesep '*.mpg']);
wmvfiles = dir([handles.video_dir_text.String filesep '*.wmv']);

videofiles = [mp4files;avifiles;mpgfiles;wmvfiles];               % and add here the variable name
video_files = {videofiles.name};

if isempty(video_files)
    handles.video_file_listbox.Value = 1;
    handles.video_file_listbox.String = [];
    % handles.video_dir_text.Value = 1;  
    return
end

handles.video_file_listbox.Value = 1;
handles.video_file_listbox.String = video_files;
