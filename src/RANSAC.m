function [H_Best, H_err] = myRANSAC(X1, X2, k, distanceThresh, inlierThresh)
% ===============================================================================
% PURPOSE:          Perform RANSAC to obtain H_Best
% CREATED:          Jay Patel
%
% X1:               Homogenous Points in image 1 (each point is a row)
% X2:               Homogenous Points in image 2 (each point is a row)
% k:                Number of iterations
% distanceThresh:   The distance threshold to set the condition for inlier
% inlierThresh:     The minimum number of inliers required
% ===============================================================================   

% Number of points used to find H
n = 1;

% Number of total points
numpts = size(X1,1);

% Vector containing random indice numbers ranging from 1 to numpts
rand_ind = round(((numpts-1)*rand(k*n,1))+1); 

Inliers_Best = [];



% Loop through for every iteration
for i=1:n:(k*n)
 
    % Determine random set of point pairs
    X1_Set = X1(rand_ind(i:i+n-1),:);
    X2_Set = X2(rand_ind(i:i+n-1),:);

    % Compute homography for 'n' Number of points
    deltaX = X2_Set(1, 1) - X1_Set(1, 1);
    deltaY = X2_Set(1, 2) - X1_Set(1, 2);
    H_curr=[1 0 deltaX; 0 1 deltaY; 0 0 1];     % Constraint so that images are only translated!
    
    % Find inliers and count number of Outliers
    Inliers = [];
    Outliers = [];
    Num_Outliers(floor(i/n)+1) = 0;
    for j=1:numpts
        % Calculate new Points
        X2_Calc(j,:) = H_curr*X1(j,:)';
        X2_Calc(j,:) = X2_Calc(j,:)./(X2_Calc(j,3));
        X1_Calc(j,:) = inv(H_curr)*X2(j,:)';
        X1_Calc(j,:) = X1_Calc(j,:)./(X1_Calc(j,3));
        % Find distance error between calculated point and given point
        Error(j) = norm(X2(j,:)'-X2_Calc(j,:)')  +  norm(X1(j,:)'-X1_Calc(j,:)');        
        % Check if its an Inlier or Outlier
        if ( Error(j) < distanceThresh)
            Inliers = [Inliers, j];
        else
            Num_Outliers(floor(i/n)+1) = Num_Outliers(floor(i/n)+1) + 1;
            Outliers = [Outliers, j];
        end        
    end
           
    % Find all the inliners
    if (((length(Inliers_Best) < length(Inliers))) && ((inlierThresh < length(Inliers)))) % <==== Line to Point Out
        Inliers_Best = Inliers;  
        Outliers_Best = Outliers;
        H_Best = H_curr;
    end
    
end


% Calculate new Points
X2_Calc = (H_Best*X1')';
for i=1:size(X2_Calc,2);
	X2_Calc(:,i) = X2_Calc(:,i)./(X2_Calc(:,3));
end
% Find distance error between calculated point and given point
Error(j) = norm(X2-X2_Calc);  
H_err = sum(Error)/numpts;



end

