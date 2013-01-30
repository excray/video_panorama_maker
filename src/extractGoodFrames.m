function [merged_panorama_idx_ranges] = extractGoodFrames(H_err, blurr, block, translations, FRAME_SIZE, DELTA, BETA)
% ===============================================================================
% PURPOSE:                  Finds the Panoramas in a sequence of shot frames
% CREATED:                  
%
% H_err:                    NUM_FRAMES x 1
% blurr:                    NUM_FRAMES x 1
% block:                    NUM_FRAMES x 1
% translations:             EachTranslation x (x,y)
% FRAME_SIZE:               [width height]
% DELTA:                    The threshold for Ev
% BETA:                     The gain threshold for Area
%
% NOTE:                     First Translation must be [0 0]
% ===============================================================================

    % Constants:    
    GAMMA = 0.45;               % The percentage of block versus blurr
    ALPHA_v = 1;                % The weight for visual error
    ALPHA_m = 1;                % The weight for motion error
    TOTAL_FRAMES = length(block);
    NUM_ATTEMPTS = 600;
    REMAINING_FRAMES = 10;
    
    % Visual Quality Measures
    Evv_vec = (GAMMA .* block) + ((1 - GAMMA) .* blurr);
    Evm_vec = H_err;    
    Ev_calc_array = [ ALPHA_v.*Evv_vec(1:end-1)   ALPHA_m.*Evm_vec   ALPHA_v.*Evv_vec(2:end) ];    
    
    % Pre-Loop Inits
    panorama_idx_range = [];  
    frame_numbers = [];    
    for i=2:TOTAL_FRAMES-1
        frame_numbers = [frame_numbers i];
    end    
    attempts = 0;
    
    % MAIN LOOP
    %while ((length(frame_numbers) > REMAINING_FRAMES) & attempts < NUM_ATTEMPTS)
    for ReferenceFrame=2:TOTAL_FRAMES-1    
        attempts = attempts + 1;

        % Make sure this value is greater than 1 and less than (TOTAL_FRAMES - 1)
        %ReferenceFrame = randsample(frame_numbers,1);   

        % Calculate Ev for (ReferenceFrame) and (ReferenceFrame + 1)
        Ev = sum(Ev_calc_array(ReferenceFrame,:));
        left = ReferenceFrame - 1;
        right = ReferenceFrame + 1;

        while (Ev < DELTA)

            % Make sure exceeded limits are excluded
            if (left == 0)
                Ev_left_marginal = NaN;
            else
                Ev_left_marginal = sum(Ev_calc_array(left,1:2));
            end
            if (right == TOTAL_FRAMES)
                Ev_right_marginal = NaN;
            else
                Ev_right_marginal = sum(Ev_calc_array(right,2:3));
            end

            % Find min Error between left and right
            [Val, Idx] = nanmin([Ev_left_marginal Ev_right_marginal]);

            if (isnan(Val))
                break;
            end

            % Update Ev
            if(Idx == 1)
                Ev = Ev + Ev_left_marginal;
                left = left - 1;
            else
                Ev = Ev + Ev_right_marginal;
                right = right + 1;
            end

            % Check whether left and right limits are exceeded
            if(left < 1)
                left = 0;
            end
            if(right > TOTAL_FRAMES)
                right = TOTAL_FRAMES;
            end

        end

        % Update candidate panoramas
        cand_panorama_idx_range = [(left+1) (right-1)];

        % Select only relevant translations
        cand_translations = translations((cand_panorama_idx_range(1)):(cand_panorama_idx_range(2)) , : );
        cand_translations(1,:) = [0 0];

        % Find area of the candidate panorama
        [Area] = getPanoramaArea(cand_translations, FRAME_SIZE);

        % Check if Area is sufficient
        if( Area > (BETA*FRAME_SIZE(1)*FRAME_SIZE(2)) )
            
            % Update panoramas
            panorama_idx_range = [panorama_idx_range; cand_panorama_idx_range]; 

            % Update avalible frames
            left_indices = find(frame_numbers < (left+1));
            right_indices = find(frame_numbers > (right-1));
            temp = frame_numbers([left_indices right_indices]);
            frame_numbers = [];
            frame_numbers = temp;
            temp = [];    
            
            % Display information
            disp(sprintf('Try Reference Frame: %d',ReferenceFrame))
            disp(sprintf('Panorama Found, Frame Range: %d - %d',cand_panorama_idx_range(1),cand_panorama_idx_range(2)))
            disp(sprintf('Ev: %f',Ev))
            disp(sprintf('Area: %f',Area))
            disp(' ')
            
        else
            % Display information
            disp(sprintf('Try Reference Frame: %d',ReferenceFrame))
            disp(sprintf('Panorama Failed, Frame Range: %d - %d',cand_panorama_idx_range(1),cand_panorama_idx_range(2)))
            disp(sprintf('Ev: %f',Ev))
            disp(sprintf('Area: %f',Area))
            disp(' ')
        end    
    
    
    end
    disp(sprintf('Number of Remaining Reference Frames in Pool: %d',length(frame_numbers)))
    
    % Merge Ranges
    if (isempty(panorama_idx_range))
        merged_panorama_idx_ranges = [];
    else
        [merged_panorama_idx_ranges] = mergeRanges(unique(panorama_idx_range,'rows'), 0.5);
    end
    


end