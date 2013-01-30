% =============================================================
% Recommended System Requirements:
% 16GB of RAM
% 8 cores
% =============================================================
% Instructions:
% 1) Read ReadMe.txt , and follow instructions
% 2) Select one of the following test cases below
% 3) Results will be placed in the folder with the source video
% =============================================================

clc
clear

% Move into src folder
cd src

% DelicateArches =============================================
% Estimated Run Time: 1.5 min
if(0) 
video_file = '..\demos\DelicateArches\Delicate Arch.mp4';
% Shot Detection Constants:
SAMPLING_RATE = 5;
EDGE_THRESHOLD = 0.5;
% Discovering Panoramas Constants:
DELTA = 150;
BETA = 1.5;
end

% VancouverBeach ==============================================
% Estimated Run Time: 4 min
if(0) 
video_file = '..\demos\VancouverBeach\Vancouver.mp4';
% Shot Detection Constants:
SAMPLING_RATE = 10;
EDGE_THRESHOLD = 0.5;
% Discovering Panoramas Constants:
DELTA = 150;
BETA = 2.5;    
end

% WestLakeHangzhou ============================================
% Estimated Run Time: 4 min
if(1) 
video_file = '..\demos\WestLakeHangzhou\WestLake.mp4';
% Shot Detection Constants:
SAMPLING_RATE = 10;
EDGE_THRESHOLD = 0.5;
% Discovering Panoramas Constants:
DELTA = 150;
BETA = 2.85;    
BETA = 3;
end

% =============================================================

% Call our Code
discoverPanoramas

% Move out of src folder
cd ..

