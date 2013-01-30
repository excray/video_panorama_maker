function [layered_rgb, im1_origin] = createLayeredImages( images, translations )
% ===============================================================================
% PURPOSE:                  Creates a Matrix of the aligned images in layers
% CREATED:                  Jay Patel
%
% images:                   Height x Width x RGB x NUM_IMAGES
% translations:             EachTranslation x (x,y)
% layered_rgb:              Height x Width x RGB x NUM_IMAGES
%
% NOTE:                     Invalid pixels have a value of 0 (black)
% NOTE:                     First Translation must be [0 0]
% ===============================================================================

    NUM_IMAGES = size(images, 4);
    FRAME_SIZE = [size(images, 2) size(images, 1)];

    % Get Panorama Size and image 1 origin
    [im1_origin, panorama_size] = getOriginAndDim(translations, FRAME_SIZE);

    % Running origin of images
    origin_x = im1_origin(1);
    origin_y = im1_origin(2);

    % Initialize size of Matrices
    layered_rgb = NaN(panorama_size(2), panorama_size(1), 3, NUM_IMAGES);

    for i=1:NUM_IMAGES

        % Stamp Image on Layer:
        origin_x = translations(i,1) + origin_x;
        origin_y = translations(i,2) + origin_y;
        layered_rgb(origin_y:(origin_y+FRAME_SIZE(2)-1), origin_x:(origin_x+FRAME_SIZE(1)-1), :, i) = images(:,:,:,i);  

    end

end

