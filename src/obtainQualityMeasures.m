function [H_all, H_err, blurr, block, translations] = obtainQualityMeasures(frames)

    NUM_FRAMES = size(frames, 4);

    % Obtain H_err:
    H_err = zeros(1, NUM_FRAMES-1);
    H_all = zeros(3, 3, NUM_FRAMES-1);
    
    % Pre-Alloc:
    translations = zeros(NUM_FRAMES-1, 2);
    
    PARALLEL = 1;
    siftMap = containers.Map('KeyType', 'uint32', 'ValueType', 'any');
    
    if (PARALLEL)
    
        matlabpool local 6
        for i = 1:NUM_FRAMES-1
            fun{i} = @getHomography;
        end
        parfor i = 1:NUM_FRAMES-1
            disp(' ')
            disp(sprintf('Frames: %d and %d', i, i+1))
            [H, H_err(i)] =  fun{i}(frames(:, :, :, i), frames(:, :, :, i+1), i, i+1, siftMap);
            translations(i, :) = [-round(H(2,3)) -round(H(1,3))]; 
            H_all(:,:,i) = H;
        end
        matlabpool close
        
    else

        for i = 1:NUM_FRAMES-1
            disp(' ')
            disp(sprintf('Frames: %d and %d', i, i+1))
            [H_all(:,:,i), H_err(i)] =  getHomography(frames(:, :, :, i), frames(:, :, :, i+1), i, i+1, siftMap);
            translations(i, :) = [-round(H_all(2,3,i)) -round(H_all(1,3,i))];        
        end

    end
    % Pre-allocate:
    blurr = zeros(1, NUM_FRAMES);
    block = zeros(1, NUM_FRAMES);
    
    for i = 1:NUM_FRAMES
        
        % Convert to Grayscale:
        grayscale_frame = rgb2gray(frames(:, : , :, i));
        
        % Obtain blurriness:
        blurr(i) = calcBlurriness(grayscale_frame);

        % Obtain blockness:
        block(i) = calcBlockness(grayscale_frame);
        
    end
    
    % Append Starting Translation:
    translations = [0 0; translations];
    
end