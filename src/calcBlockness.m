function [ S ] = calcBlockness( image )
% ===============================================================================
% PURPOSE:          Find the Blockness of an image; based on a paper
% CREATED:          Jay Patel
%
% image:            The input image
% S:                A value between 0 and 1 signifying the Blockness
% 
% Reference:        No-Reference Perceptual Quality Assessment of JPEG Compressed Images
%                   Zhou Wang, Hamid R. Sheikh and Alan C. Bovik
% ===============================================================================

% PARAMETERS =========================================================
BLOCK_SIZE = 8;
[size_y, size_x] = size(image);


% Blockness ===========================================================
% Find Bh
Block_Horiz_odd = image(:,BLOCK_SIZE:BLOCK_SIZE:(end-1));
Block_Horiz_even = image(:,BLOCK_SIZE+1:BLOCK_SIZE:end);
Diff_Horiz = abs(Block_Horiz_even - Block_Horiz_odd);
Bh = (1/(size_y*((size_x/BLOCK_SIZE)-1))) * sum(sum(Diff_Horiz));
% Find Bv
Block_Vert_odd = image(BLOCK_SIZE:BLOCK_SIZE:(end-1),:);
Block_Vert_even = image(BLOCK_SIZE+1:BLOCK_SIZE:end,:);
Diff_Vert = abs(Block_Vert_even - Block_Vert_odd);
Bv = (1/(size_x*((size_y/BLOCK_SIZE)-1))) * sum(sum(Diff_Vert));
% Activity Measure =====================================================
% Find Ah
Horiz_odd = image(:,1:2:(end-1));
Horiz_even = image(:,2:2:end);
Diff_Horiz = abs(Horiz_even - Horiz_odd);
Ah = (1/7) * ( (8/(size_y*(size_x-1))) * sum(sum(Diff_Horiz)) - Bh );
% Find Av
Vert_odd = image(1:2:(end-1),:);
Vert_even = image(2:2:end,:);
Diff_Vert = abs(Vert_even - Vert_odd);
Av = (1/7) * ( (8/(size_x*(size_y-1))) * sum(sum(Diff_Vert)) - Bv );
% Activity Measure =====================================================
% Find Zh
vec = [];
for j=1:size_y
    vec = (image(j,:) ~= 0);
    vec = ((vec(1:end-1) + vec(2:end)) == 1);
    num_zc = length(vec);
end
Zh = (1/(size_y*(size_x-2))) * sum(num_zc);
% Find Zv
vec = [];
for i=1:size_x
    vec = (image(:,i) ~= 0);
    vec = ((vec(1:end-1) + vec(2:end)) == 1);
    num_zc = length(vec);
end
Zv = (1/(size_x*(size_y-2))) * sum(num_zc);
% Find B, A, Z =========================================================
B = (Bh + Bv)/2;
A = (Ah + Av)/2;
Z = (Zh + Zv)/2;

% Model from paper
alpha = -245.9; beta = 261.9; gama1 = -0.0240; gama2 = 0.0160; gama3 = 0.0064;
S = alpha + beta*(B^-gama1)*(A^-gama2)*(Z^gama3);

% Our Model
S = abs(B/A)*(1/100);
if (S > 1)
    S = 1;
end


end

