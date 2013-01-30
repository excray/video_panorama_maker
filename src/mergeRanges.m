function [merged_ranges] = mergeRanges(ranges, thresh)

    % Sort Ranges by Start:
    sorted_ranges = sortrows(ranges, [1 2]);

    % Merge Ranges:
    merged_ranges = [];
    cur = sorted_ranges(1, :);
    
    for i = 2:size(sorted_ranges, 1)
        
        % Cur End > Next Start 
        if cur(1, 2) > sorted_ranges(i, 1)
            
            % Cur End < Next End [NOT COMBINED]
            if cur(1, 2) <= sorted_ranges(i, 2)
                
                diff = cur(1, 2) - sorted_ranges(i, 1);
                cov_1 = diff / (sorted_ranges(i, 2) - sorted_ranges(i, 1));
                cov_2 = diff / (cur(1, 2) - cur(1, 1));

                % Good Coverage?
                if cov_1 > thresh || cov_2 > thresh
                    cur(1, 2) = sorted_ranges(i, 2);

                else

                    % Range Complete
                    merged_ranges = [merged_ranges; cur];
                    cur = sorted_ranges(i, :);

                end
            end
            
        else
            
            % Range Complete
            merged_ranges = [merged_ranges; cur];
            cur = sorted_ranges(i, :);
            
        end
        
        
    end

    % Add Final Panorama:
    merged_ranges = [merged_ranges; cur];
    
end

