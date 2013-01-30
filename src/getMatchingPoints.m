function [X1 X2] = getMatchingPoints(image1, image2, QUICK_SIFT, im1_index, im2_index, siftMap)

locationsImg1 = [];
descriptorsImg1 = [];
locationsImg2 = [];
descriptorsImg2 = [];

if( QUICK_SIFT == 1)
    
    % Get Descriptors and Locations of keypoints using SIFT
    % loc: numKeypoints x 4
    % des: numKeypoints x 128
    % locationsImg: 4 x numKeypoints
    % descriptorsImg: 128 x numKeypoints
    [ loc1 , des1 ] = vl_sift(single(rgb2gray(image1)));
    [ loc2 , des2 ] = vl_sift(single(rgb2gray(image2)));
    temp1 = single(loc1');
    temp2 = single(loc2');
    locationsImg1 = [temp1(:,2) temp1(:,1) temp1(:,2:3)];
    locationsImg2 = [temp2(:,2) temp2(:,1) temp2(:,2:3)];
    temp3 = single(des1');
    temp4 =  single(des2');  
    
    % Normalize Descriptors
    for i=1:size(temp3,2)
        descriptorsImg1 = temp3 ./ norm(temp3(i,:)) ;
    end
    for i=1:size(temp4,2)
        descriptorsImg2 = temp4 ./ norm(temp4(i,:)) ;
    end    
    
else

    % Get Descriptors and Locations of keypoints using SIFT
    % locationsImg: numKeypoints x 4
    % descriptorsImg: numKeypoints x 128  
    if isKey(siftMap, im1_index)        
        vals = siftMap(im1_index);
        descriptorsImg1 = vals{1};
        locationsImg1 = vals{2};
        
        %Remove
        remove(siftMap, im1_index);
        if isKey(siftMap, im1_index-1)
            remove(siftMap, im1_index-1);
        end
    else
        [ ~ , descriptorsImg1 , locationsImg1 ] = sift(rgb2gray(image1));
        vals{1} = descriptorsImg1;
        vals{2} = locationsImg1;
        siftMap(im1_index) = vals;
    end
    
    if isKey(siftMap, im2_index)
        vals = siftMap(im2_index);
        descriptorsImg2 = vals{1};
        locationsImg2 = vals{2};
        
        %Remove
        remove(siftMap, im2_index);
        if isKey(siftMap, im1_index+1)
            remove(siftMap, im1_index+1);
        end
    else
        [ ~ , descriptorsImg2 , locationsImg2 ] = sift(rgb2gray(image2));
        vals{1} = descriptorsImg2;
        vals{2} = locationsImg2;
        siftMap(im2_index) = vals;
    end


end


% For efficiency in Matlab, it is cheaper to compute dot products between
%  unit vectors rather than Euclidean distances.  Note that the ratio of 
%  angles (acos of dot products of unit vectors) is a close approximation
%  to the ratio of Euclidean distances for small angles.
%
% distRatio: Only keep matches in which the ratio of vector angles from the
%   nearest to second nearest neighbor is less than distRatio.
distRatio = 0.6;   

% For each descriptor in the first image, select its match to second image.
descriptorsImg2Transpose = descriptorsImg2';                    % Precompute matrix transpose

for i = 1 : size(descriptorsImg1,1)
   dotprods = descriptorsImg1(i,:) * descriptorsImg2Transpose;	% Computes vector of dot products
   [vals,indx] = sort(acos(dotprods));                          % Take inverse cosine and sort results

   % Check if nearest neighbor has angle less than distRatio times 2nd.
   if (vals(1) < distRatio * vals(2))
      match(i) = indx(1);
   else
      match(i) = 0;
   end
end

% Determine Points
match_idx = 1;
for i = 1: size(descriptorsImg1,1)
    if (match(i) > 0)
        X1(match_idx,:) = [locationsImg1(i,1) locationsImg1(i,2) 1];
        X2(match_idx,:) = [locationsImg2(match(i),1) locationsImg2(match(i),2) 1];
        match_idx = match_idx + 1;
    end
end
numMatches = sum(match > 0);



fprintf('Found %d matches.\n', numMatches);



