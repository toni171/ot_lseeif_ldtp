function [sumDist, meanDist, hausDist] = evaluateSegmentation( ...
    labelPoints, segmentedPoints)
% EVALUATESEGMENTATION  Compute label-segmentation boundary distances.
%   [SUMDIST, MEANDIST, HAUSDIST] = EVALUATESEGMENTATION(LABELPOINTS,
%   SEGMENTEDPOINTS) takes in input the true values of tumor boundary points
%   LABELPOINTS and the segmented tumor boundary points SEGMENTEDPOINTS and
%   returns the sum of min-pointwise distances SUMDIST, the mean of those
%   distances MEANDIST and the max of those distances (directed Hausdorff)
%   HAUSDIST

    %   Stack all segmented boundary pixels into one big list
    segmentedPoints = vertcat(segmentedPoints{:});
    
    %   Convert to [x y] to match labelPoints
    segmentedXY = [segmentedPoints(:,2), segmentedPoints(:,1)];
    labelXY  = labelPoints;
    
    %   Compute full label×segmentation distance matrix
    distances = pdist2(labelXY, segmentedXY, 'euclidean');
    
    %   For each label point, find its nearest boundary pixel
    minDistances = min(distances, [], 2);
    
    %   Compute metrics
    sumDist  = sum(minDistances);
    meanDist = mean(minDistances);
    hausDist = max(minDistances);
end
