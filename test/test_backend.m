clc

clear




MAX_NUM_IMAGES = 100;
TEST_DIR = 'Backend_Test_Case1';

cd(TEST_DIR);
for i=1:MAX_NUM_IMAGES
    file = sprintf('%d.jpg', i);
    if exist(file)
        im = imread(file);
        images(:,:,:,i) = im;  
    else
        break;
    end
end
cd ..

% Obtain Quality Measures
[H_all, H_err, blurr, block, translations] = obtainQualityMeasures(images);


% Composite and Blend Images
[panorama_img] = stitchImage(translations, images, blurr, block);

imshow(uint8(panorama_img))



