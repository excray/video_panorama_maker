%Returns downsampled frames of video if no shots are detected.
%Returns downsampled frames of shots if shots are detected.

function [shots_frames shotCount frame_size] = extract_shots(video_file, threshold, threshold_num_changed_blocks, use_step, down_sample )


NumTimes = 1;   % Number of times the stream processing loop should run

%outputPath = videoFile(1, 1:find(videoFile=='\', 1, 'last')-1);

%fileName = videoFile(find(videoFile=='\', 1, 'last')+1 : end);

%picFormat = 'JPG';

%outputPath = fullfile(outputPath, fileName(1, 1:find(fileName=='.', 1, 'last')-1));

%numOrder = 4;

%mkdir(outputPath);

if use_step == 1
    hmfr = vision.VideoFileReader( ...
        'Filename', video_file , ...
        'PlayCount',  NumTimes );
        
    
    % Get the dimensions of each frame.
    Info = info(hmfr);
    rows = Info.VideoSize(2);  % Height in pixels
    cols = Info.VideoSize(1);  % Width in pixels
else
    %
    video_obj = VideoReader(video_file);
    video_frames = read(video_obj);
    rows = size(video_frames, 1);  % Height in pixels
    cols = size(video_frames, 2);  % Width in pixels
end
frame_size = [cols rows];
blk_size = 32;  % Block size

% Create ROI rectangle indices for each block in image.
blk_rows = (1:blk_size:rows-blk_size+1);
blk_cols = (1:blk_size:cols-blk_size+1);
[X, Y] = meshgrid(blk_rows, blk_cols);
block_roi = [X(:)'; Y(:)'];
block_roi(3:4, :) = blk_size;
block_roi = block_roi([2 1 4 3], :)';

hedge = vision.EdgeDetector( ...
    'EdgeThinning' ,true, ...
    'ThresholdScaleFactor', 3);

hmean = vision.Mean;
hmean.ROIProcessing = true;

% Initialize variables.
mean_blks_prev = zeros([size(blk_rows,2)*size(blk_cols,2), 1], 'single');
count          = 1;
frameCount     = 0;
shotCount      = 1;
framesInShot   = uint8([]);
framesInShotCntr = 1;
shots_frames = {};
startFrame = 1;
frameRate = 25;

startImg = 0;
hidtypeconv1 = ...
   vision.ImageDataTypeConverter('OutputDataType','uint8');
hidtypeconv2 = ...
   vision.ImageDataTypeConverter('OutputDataType','double');

while count <= NumTimes 
    
    frameCount = frameCount + 1;
    
    
    if(mod(frameCount, 1000) == 0)
        frameCount
    end
 
    if use_step == 1
        
        I = step(hmfr);        
        if isDone(hmfr)
            count = count+1;
        end
        
    else
        I = video_frames(:,:,:,frameCount);            % Read input video
        if video_obj.NumberOfFrames == frameCount
            count = count+1;
        end
    end
    
       
    if mod(frameCount-1, down_sample) ~= 0
        continue
    end
    
    % Calculate the edge-detected image for one video component.
    
    I_edge = step(hedge, step(hidtypeconv2, I(:,:,3)));
    
    % Compute mean of every block of the edge image.
    mean_blks = step(hmean, single(I_edge), block_roi);
    
    % Compare the absolute difference of means between two consecutive
    % frames against a threshold to detect a scene change.
    edge_diff = abs(mean_blks - mean_blks_prev);
    edge_diff_b = edge_diff > threshold;
    num_changed_blocks = sum(edge_diff_b(:));
    
    % It is a scene change if there is more than one changed block.
    scene_chg = num_changed_blocks > threshold_num_changed_blocks;
    
    % Display the sequence of identified scene changes along with the edges
    % information. Only the start frames of the scene changes are
    % displayed.
    %I_out = cat(2, I, repmat(I_edge, [1,1,3]));
    
    % Display the number of frames and the number of scene changes detected
    
    %I_out = step(htextinserter, I_out, int32([frameCount shotCount]));
    
    % Generate sequence of scene changes detected
    if scene_chg
        % Shift old shots to left and add new video shot
        %scene_out(:, 1:2*cols, :) = scene_out(:, cols+1:end, :);
        %scene_out(:, 2*cols+1:end, :) = I;
        %step(hVideo2, scene_out); % Display the sequence of scene changes
        
        if frameCount - startFrame > frameRate
            
            %             saveFormat = strcat('%s\\%s_%0', int2str(numOrder), 'd_start.%s');
            %             picName = sprintf(saveFormat, outputPath, fileName, shotCount , picFormat);
            %             imwrite(startImg, picName);
            %
            %             saveFormat = strcat('%s\\%s_%0', int2str(numOrder), 'd_end.%s');
            %             picName = sprintf(saveFormat, outputPath, fileName , shotCount, picFormat);
            %             imwrite(prevFrame, picName);
            
            shots_frames{shotCount} = framesInShot;
            framesInShot = uint8([]);
            framesInShotCntr = 1;
            
            %shots_frames(shotCount, 2) = prevFrame;
            shotCount = shotCount+1;
            
            startFrame = frameCount;
            startImg = I;
        end
        
    end
    
    if startImg == 0
        startImg = I;
    end
    
    if use_step
        framesInShot(:,:,:,framesInShotCntr) =  step(hidtypeconv1, I);
    else
        framesInShot(:,:,:,framesInShotCntr) =  I;
    end
    framesInShotCntr = framesInShotCntr+1;
    
    %step(hVideo1, I_out);         % Display the Original Video.
    mean_blks_prev = mean_blks;      % Save block mean matrix
    
end

shots_frames{shotCount} = framesInShot;

end
