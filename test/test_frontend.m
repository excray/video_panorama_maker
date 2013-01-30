clc
%{

MAX_NUM_IMAGES = 500;
TEST_DIR = 'Frontend_Test_Case3';

cd(TEST_DIR);
for i=1:MAX_NUM_IMAGES
    file = sprintf('%d.jpg', i);
    i
    if exist(file)
        im = imread(file);
        images(:,:,:,i) = im;  
    else
        break;
    end
end
cd ..


shot_range = [1 size(images,4)]

% Obtain Quality Measures:
shot_frames = images;
[H_all, H_err, blurr, block, translations] = obtainQualityMeasures(shot_frames);

%}



if(0)
% WEST LAKE =========================
% Merge Overlap: 50%
clear
load west.mat
DELTA = 200;    
BETA = 2.75;       
% ===================================
end

if(0)
% DELICATE ARCHES ===================
% Merge Overlap: 50%
clear
load Arches.mat
DELTA = 200;    
BETA = 2.75;       
% ===================================
end

if(1)
% VANCOUVER BEACH ===================
% Merge Overlap: 50%
%clear
%load Vancouver2.mat
DELTA = 250;    
BETA = 2.2;       
% ===================================
end

% Extract Frames:
FRAME_SIZE = [size(images,2) size(images,1)];
[good_frames_idx] = extractGoodFrames(H_err', blurr', block', translations, FRAME_SIZE, DELTA, BETA)




for num_pans=1:size(good_frames_idx,1)

% Composite and Blend Images
[panorama_img] = stitchImage(translations(good_frames_idx(num_pans,1)+1:good_frames_idx(num_pans,2),:), images(:,:,:,good_frames_idx(num_pans,1):good_frames_idx(num_pans,2)), ... 
    blurr(good_frames_idx(num_pans,1):good_frames_idx(num_pans,2)), block(good_frames_idx(num_pans,1):good_frames_idx(num_pans,2)));

figure(num_pans)
imshow(uint8(panorama_img))


end

