

s = matlabpool('size');
if s ~= 0
    matlabpool close;
end

tic;


opt_flow_enabled = 0;
display_enabled = 0;
NUM_CHANGE_BLOCKS = 1;

%Read Video
%video_frames = getVideo(video_file, 5);

% Extract List of shots:    
[shot_list num_shots FRAME_SIZE]  = extractShots(video_file, EDGE_THRESHOLD, NUM_CHANGE_BLOCKS, 0, SAMPLING_RATE);
fprintf('Number of shots found in video: %d\n', num_shots);

shot_num = 0;
for shot = shot_list
    
    shot_num = shot_num+1;

    % Obtain Quality Measures:        
    shot_frames = shot{1};
    fprintf('Number of frames in shot %d: %d', shot_num, size(shot_frames,4));
    [~, H_err, blurr, block, translations] = obtainQualityMeasures(shot_frames);

    % Extract Frames:
    [good_frames_idx] = extractGoodFrames(H_err', blurr', block', translations, FRAME_SIZE, DELTA, BETA);
    if(isempty(good_frames_idx))
        disp('No panoramas found in the input video file.');
        continue;
    end

    % Align Frames to Image:
    for num_pans=1:size(good_frames_idx,1)

        % Composite and Blend Images
        startIdx = good_frames_idx(num_pans,1);
        endIdx = good_frames_idx(num_pans,2);
        [stitched_img] =    stitchImage(translations(startIdx+1:endIdx,:), shot_frames(:,:,:,startIdx:endIdx), ... 
                            blurr(startIdx:endIdx), block(startIdx:endIdx));    
    
        % Apply Optical Flow:
        if (opt_flow_enabled)


        end

        % Save Panorama Image in the directory as video - change later?:
        path = video_file(1:find(video_file=='\', 1, 'last'));
        file_name = video_file(find(video_file=='\', 1, 'last')+1:find(video_file=='.', 1, 'last')-1);
        if isempty(file_name)
            file_name=video_file(1:find(video_file=='.', 1, 'last')-1);
        end
        outputfile = sprintf('%spanorama_%s_%d_%d.jpg', path, file_name, shot_num, num_pans);
        imwrite(stitched_img, outputfile);

        % Display Image:
        if (display_enabled)
            figure(shot_num)
            imshow(stitched_img)
            title(['Panorama #' num2str(shot_num) ' in ' file_name]);
        end
    end  
    
end    
%cleanup
tmpfiles = dir('./tmp*');
n = length(tmpfiles);
for i = 1:n
    delete(tmpfiles(i).name);
end
toc;
