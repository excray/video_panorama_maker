function [area] = getPanoramaArea(translations, frame_size)

    % Obtain Global Origin:
    [cur panorama_size] = getOriginAndDim(translations, frame_size);
    
    % Create Panorama:
    panorama = zeros(panorama_size);
    
    % Place Ones;
    for i = 1:size(translations, 1)
        
        % Stamp w/Ones:
        panorama(cur(2):cur(2)+frame_size(2)-1, cur(1):cur(1)+frame_size(1)-1) = 1;
        
        % Next Origin:
        cur = cur + translations(i, :);
        
    end

    % Calculate Area:
    area = sum(sum(panorama));

end