clc
clear

% Test calc_Blurriness
disp('=================== Blurriness =====================')
if(1)

disp('Blurry Images')

image = rgb2gray(imread('Visual_Quality_Test_Cases\b1.jpg'));
[ BlurExtent ] = calc_Blurriness( image );
disp(sprintf('Image b1: %.4f',BlurExtent))

image = rgb2gray(imread('Visual_Quality_Test_Cases\b2.jpg'));
[ BlurExtent ] = calc_Blurriness( image );
disp(sprintf('Image b2: %.4f',BlurExtent))

image = rgb2gray(imread('Visual_Quality_Test_Cases\b3.jpg'));
[ BlurExtent ] = calc_Blurriness( image );
disp(sprintf('Image b3: %.4f',BlurExtent))

image = rgb2gray(imread('Visual_Quality_Test_Cases\b4.jpg'));
[ BlurExtent ] = calc_Blurriness( image );
disp(sprintf('Image b4: %.4f',BlurExtent))


disp('Sharp Images')

image = rgb2gray(imread('Visual_Quality_Test_Cases\1.jpg'));
[ BlurExtent ] = calc_Blurriness( image );
disp(sprintf('Image 1: %.4f',BlurExtent))

image = rgb2gray(imread('Visual_Quality_Test_Cases\2.jpg'));
[ BlurExtent ] = calc_Blurriness( image );
disp(sprintf('Image 2: %.4f',BlurExtent))

image = rgb2gray(imread('Visual_Quality_Test_Cases\3.jpg'));
[ BlurExtent ] = calc_Blurriness( image );
disp(sprintf('Image 3: %.4f',BlurExtent))

image = rgb2gray(imread('Visual_Quality_Test_Cases\4.jpg'));
[ BlurExtent ] = calc_Blurriness( image );
disp(sprintf('Image 4: %.4f',BlurExtent))




end









disp(' ')
disp('=================== Blockness =====================')
% Test calc_Blockness
if(1)

disp('Tiffany')    
image = rgb2gray(imread('Visual_Quality_Test_Cases\tiffany.jpg'));
[ S ] = calc_Blockness( image );
disp(sprintf('Clear: %.4f',S))

image = rgb2gray(imread('Visual_Quality_Test_Cases\tiffanyb.jpg'));
[ S ] = calc_Blockness( image );
disp(sprintf('Block: %.4f',S))


disp('Lake')    
image = rgb2gray(imread('Visual_Quality_Test_Cases\lake.jpg'));
[ S ] = calc_Blockness( image );
disp(sprintf('Clear: %.4f',S))

image = rgb2gray(imread('Visual_Quality_Test_Cases\lakeb.jpg'));
[ S ] = calc_Blockness( image );
disp(sprintf('Block: %.4f',S))


disp('flower')    
image = rgb2gray(imread('Visual_Quality_Test_Cases\flowerb.jpg'));
[ S ] = calc_Blockness( image );
disp(sprintf('Block: %.4f',S))   



    
    
end





