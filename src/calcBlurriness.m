function [ BlurExtent ] = calcBlurriness( image )
% ===============================================================================
% PURPOSE:          Find the Blurriness of an image; based on a paper
% CREATED:          Jay Patel
%
% image:            The input image
% BlurExtent:       A value between 0 and 1 signifying the Blurriness
% 
% Reference:        Blur Detection for Digital Images Using Wavelet Transform
%                   Hanghang Tong, Mingjing Li, Hongjiang Zhang, Changshui Zhang
% ===============================================================================

% PARAMETERS =========================================================
[size_y, size_x] = size(image);
THRESHOLD = 35;                 % This was used in the paper
MinZero = 0.05;                 % This was used in the paper
MinZero = .2;                   % Our model

% Set Up ==============================================================
M = double(image);
level_size_y = size_y;
level_size_x = size_x;
DIV_BY = 16;
if(mod(level_size_y,DIV_BY) ~= 0)
	level_size_y = level_size_y - mod(level_size_y,DIV_BY);
end
if(mod(level_size_x,DIV_BY) ~= 0)
	level_size_x = level_size_x - mod(level_size_x,DIV_BY);
end      
Emax = [];


% NOTE: Matrix M is changing for each iteration of the loop
% NOTE: This loop was designed for only 3 levels
for level=1:3
    
    % Perform 1D Haar Transform on each row
    image_odd_rows = M(1:2:level_size_y,1:level_size_x);
    image_even_rows = M(2:2:level_size_y,1:level_size_x);
    AVG = ((image_odd_rows+image_even_rows).*0.5);
    DIF = (image_odd_rows-image_even_rows);
    M = double([AVG; DIF]);    

    % Perform 1D Haar Transform on each col
    image_odd_columns = M(1:level_size_y,1:2:end);
    image_even_columns = M(1:level_size_y,2:2:end);
    AVG = ((image_odd_columns+image_even_columns).*0.5);
    DIF = (image_odd_columns-image_even_columns);
    M = double([AVG DIF]);
    

    % Create Edge Map
    LH = []; HL = []; HH = [];
    LH = (M((level_size_y/2)+1:level_size_y,1:(level_size_x/2)));
    HL = (M(1:(level_size_y/2),(level_size_x/2)+1:level_size_x));
    HH = (M((level_size_y/2)+1:level_size_y,(level_size_x/2)+1:level_size_x));
    Emap = [];
    Emap(:,:) = sqrt(LH.*LH + HL.*HL + HH.*HH);
    
    
    % Find local maxima    
    if (level == 1)
        WINDOW_SIZE = 8;
    elseif (level == 2)
        WINDOW_SIZE = 4;
    elseif (level == 3)
        WINDOW_SIZE = 2;
    else
        WINDOW_SIZE = 0;  % Throw error
    end        
    for j=1:WINDOW_SIZE:((level_size_y/2)-1)
        for i=1:WINDOW_SIZE:((level_size_x/2)-1)
            Window = Emap(j:j+WINDOW_SIZE-1,i:i+WINDOW_SIZE-1);
            Emax(floor(j/WINDOW_SIZE)+1,floor(i/WINDOW_SIZE)+1,level) = max(Window(:));            
        end        
    end        
    
    
    % Resize image for next level
    level_size_y = (level_size_y/2);
    level_size_x = (level_size_x/2);
        
end


% Find Number of Edge Points
Rule1 = (max(Emax,[],3) > THRESHOLD);
N_edge = sum(sum(Rule1));
% Find Dirac-Structure or Astep-Structure Edge Points
Rule2 = (Rule1) & (Emax(:,:,1) > Emax(:,:,2)) & (Emax(:,:,2) > Emax(:,:,3));
N_da = sum(sum(Rule2));
% Find Gstep-Structure Edge Points
Rule3 = (Rule1) & (Emax(:,:,1) < Emax(:,:,2)) & (Emax(:,:,2) < Emax(:,:,3));
% Find Roof-Structure Edge Points
Rule4 = (Rule1) & (Emax(:,:,1) < Emax(:,:,2)) & (Emax(:,:,2) > Emax(:,:,3));
N_rg = sum(sum(Rule3)) + sum(sum(Rule4));
% Find Roof-Structure and Gstep-Structure that have lost sharpness
Rule5 = ((Rule3) | (Rule4)) & (Emax(:,:,1) < THRESHOLD);
N_brg = sum(sum(Rule5));


% Find Blur Extent
BlurExtent = N_brg/N_rg;

% Determine if Image is Blurry
Per = N_da/N_edge;
if (Per > MinZero)
    IsBlur = 1;
else
    IsBlur = 0;
end


end

