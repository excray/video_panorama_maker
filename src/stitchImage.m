function [stitched_img] = stitchImage(translations, frames, blurr, block)

    FRAME_SIZE_X = size(frames, 2);
    FRAME_SIZE_Y = size(frames, 1);
    NUM_FRAMES = size(frames, 4);
    GAMMA = 0.45;
    SIGMASQ = (5).^2;

    translations = [0 0; translations];
    
    % Get Matrix of aligned images    
    [rgb_final, p_offset] = createLayeredImages(frames, translations);    

    % Compute Panorama Size:
    panorama_size_x = size(rgb_final, 2); 
    panorama_size_y = size(rgb_final, 1);
    
    % Calculate Distance Matrix:
    row_weight = [1:ceil(FRAME_SIZE_X/2) floor(FRAME_SIZE_X/2):-1:1];
    distance_weights = repmat(row_weight, [FRAME_SIZE_Y 1]);
    origin_x = p_offset(1);
    origin_y = p_offset(2);
    
    t0 = cputime;
    
    % Compute w Matrix;
    w = zeros(panorama_size_y, panorama_size_x, NUM_FRAMES);   

    for i = 1:NUM_FRAMES
        origin_x = origin_x + translations(i, 1);
        origin_y = origin_y + translations(i, 2);
        w(origin_y:origin_y+FRAME_SIZE_Y-1, origin_x:origin_x+FRAME_SIZE_X-1, i) = distance_weights;
    end
    
    disp('Completed w calculation.')
    
    % Compute w' Matrix:
    r_med = repmat(nanmedian(rgb_final(:, :, 1, :), 4), [1 1 NUM_FRAMES]);
    g_med = repmat(nanmedian(rgb_final(:, :, 2, :), 4), [1 1 NUM_FRAMES]);
    b_med = repmat(nanmedian(rgb_final(:, :, 3, :), 4), [1 1 NUM_FRAMES]);
  
    w_prime_r = w.*exp(-((squeeze(rgb_final(:, :, 1, :)) - r_med).^2) ./ SIGMASQ);
    w_prime_g = w.*exp(-((squeeze(rgb_final(:, :, 2, :)) - g_med).^2) ./ SIGMASQ);
    w_prime_b = w.*exp(-((squeeze(rgb_final(:, :, 3, :)) - b_med).^2) ./ SIGMASQ);    
  
    disp('Completed w_prime calculation.')
    clear r_med; clear g_med; clear b_med; clear w;
    
    % Calculate w'' Matrix:
    w_prime_prime_r = zeros(panorama_size_y, panorama_size_x, NUM_FRAMES);
    w_prime_prime_g = zeros(panorama_size_y, panorama_size_x, NUM_FRAMES);
    w_prime_prime_b = zeros(panorama_size_y, panorama_size_x, NUM_FRAMES);

    % Calculate Visual Quality per Frame:
    vqm_per_frame = exp(-(GAMMA*block + (1-GAMMA)*blurr));
    
    for i = 1:NUM_FRAMES
        w_prime_prime_r(:, :, i) = w_prime_r(:, :, i) * vqm_per_frame(i);
        w_prime_prime_g(:, :, i) = w_prime_g(:, :, i) * vqm_per_frame(i);
        w_prime_prime_b(:, :, i) = w_prime_b(:, :, i) * vqm_per_frame(i);
    end    

    clear w_prime_r; clear w_prime_g; clear w_prime_b;
    
    % Calculate Final RGB Values:
    r_final = nansum((w_prime_prime_r .* squeeze(rgb_final(:, :, 1, :))), 3) ./ nansum(w_prime_prime_r, 3);
    g_final = nansum((w_prime_prime_g .* squeeze(rgb_final(:, :, 2, :))), 3) ./ nansum(w_prime_prime_g, 3);
    b_final = nansum((w_prime_prime_b .* squeeze(rgb_final(:, :, 3, :))), 3) ./ nansum(w_prime_prime_b, 3);
    
    disp('Completed w_prime_prime calculation.')

    % Stitch Image Together:
    stitched_img = zeros(panorama_size_y, panorama_size_x, 3);
    stitched_img(:, :, 1) = r_final;
    stitched_img(:, :, 2) = g_final;
    stitched_img(:, :, 3) = b_final;
    stitched_img = uint8(stitched_img);
    
end