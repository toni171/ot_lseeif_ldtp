function [] = showSegmentation(image, labelPoints, boundaryPoints)
% SHOWLABELEDIMAGE Shows an image and overlay to it the plot of label
% points and the boundary of segmented tumor region.

    figure;
    imshow(image), hold on;
    if iscell(labelPoints)
        labelPoints = cell2mat(cellfun(@cell2mat, labelPoints, ...
            'UniformOutput', false));
    end
    for i = 1:size(labelPoints, 1)
        x = round(labelPoints(i, 1));
        y = round(labelPoints(i, 2));
        
        plot(x, y, 'r+', 'MarkerSize', 10, 'LineWidth', 2);
        
        text(x+5, y, sprintf('(%d, %d)', x, y), 'Color', 'red', ...
            'FontSize', 9);
    end
    
    for k = 1:numel(boundaryPoints)
        boundary = boundaryPoints{k};
        plot(boundary(:,2), boundary(:,1), 'g--', 'LineWidth', 2);
    end
    
    title("Segmented Tumor Outlined in Green Dashed Line");
    hold off;
end