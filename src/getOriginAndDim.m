function [ im1_origin, panorama_size ] = getOriginAndDim( Translations, FRAME_SIZE )


NUM_IMAGES = size(Translations,1);

% Find the origin offset of image1 with respect to the Final Panorama AND Find the size of the Panorama ===========

% Offset of the panorama origin with respect to image 1 origin 
Offset_im1_y = 0;
Offset_im1_x = 0;

% Running total offset
Total_Offset_y = 0;
Total_Offset_x = 0;

top_limit = 0; bottom_limit = 0; right_limit = 0; left_limit = 0;

for i=1:NUM_IMAGES
    
    Total_Offset_y = Translations(i,2)+Total_Offset_y;
    Total_Offset_x = Translations(i,1)+Total_Offset_x;
    
    % Offset in y direction    
    if( Total_Offset_y < Offset_im1_y)
        Offset_im1_y = Total_Offset_y;           
    end    
    % Offset in x direction    
    if( Total_Offset_x < Offset_im1_x)
        Offset_im1_x = Total_Offset_x;           
    end    
    
    % Find top limit (max y)
    if( Total_Offset_y > top_limit )
        top_limit = Total_Offset_y;
    end
    % Find bottom limit (min y)
    if( Total_Offset_y < bottom_limit )
        bottom_limit = Total_Offset_y;
    end
    % Find right limit (max x)
    if( Total_Offset_x > right_limit )
        right_limit = Total_Offset_x;           
    end
    % Find left limit (max x)
    if( Total_Offset_x < left_limit )
        left_limit = Total_Offset_x;           
    end
    
end

panorama_size_x = right_limit - left_limit + FRAME_SIZE(1);
panorama_size_y = top_limit - bottom_limit + FRAME_SIZE(2);
panorama_size = [panorama_size_x panorama_size_y];

im1_origin = [(abs(Offset_im1_x)+1) (abs(Offset_im1_y)+1)];


end

