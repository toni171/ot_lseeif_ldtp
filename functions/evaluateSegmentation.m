function [sumDist, meanDist, hausDist] = evaluateSegmentation(gtPoints, B)
% evaluateSegmentation  Compute GT→segmentation boundary distances.
%   gtPoints is an N×2 array of [x y] coordinates from your JSON.
%   B       is the cell array output of bwboundaries: each B{k} is
%           a M_k×2 array of [row, col] points.
%
% Outputs:
%   sumDist  = sum of min-pointwise distances
%   meanDist = mean of those distances
%   hausDist = max   of those distances (directed Hausdorff)

    % 1) Stack all segmented boundary pixels into one big list
    segBC = vertcat(B{:});              % [row col]
    
    % 2) Convert to [x y] to match gtPoints
    segXY = [segBC(:,2), segBC(:,1)];   % [x y]
    gtXY  = gtPoints;                  % already [x y]
    
    % 3) Compute full GT×SEG distance matrix
    D = pdist2(gtXY, segXY, 'euclidean');
    
    % 4) For each GT point, find its nearest boundary pixel
    minD = min(D, [], 2);   % N×1 vector
    
    % 5) Summaries
    sumDist  = sum(minD);
    meanDist = mean(minD);
    hausDist = max(minD);
end
