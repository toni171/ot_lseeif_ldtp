function [] = showLabeledImage(grayImage, labelPoints, titleText)
% SHOWLABELEDIMAGE Shows an image and overlay to it the plot of label
% points.

    figure;
    imshow(grayImage);      
    hold on;

    if iscell(labelPoints)
        labelPoints = cell2mat(cellfun(@cell2mat, labelPoints, 'UniformOutput', false));
    end

    for i = 1:size(labelPoints, 1)
        x = round(labelPoints(i, 1));
        y = round(labelPoints(i, 2));
    
        plot(x, y, 'r+', 'MarkerSize', 10, 'LineWidth', 2);
    end
    title(titleText);
    hold off;
end