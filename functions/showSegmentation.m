function [] = showSegmentation(image, data, B)
    figure;
    imshow(image), hold on;
    if iscell(data)
        data = cell2mat(cellfun(@cell2mat, data, 'UniformOutput', false));
    end
    for i = 1:size(data, 1)
        x = round(data(i, 1));
        y = round(data(i, 2));
        
        % Plot the point
        plot(x, y, 'r+', 'MarkerSize', 10, 'LineWidth', 2);
        
        % Optional: label with coordinates
        text(x+5, y, sprintf('(%d, %d)', x, y), 'Color', 'red', 'FontSize', 9);
    end
    
    for k = 1:numel(B)
        boundary = B{k};
        plot(boundary(:,2), boundary(:,1), 'g--', 'LineWidth', 2);
    end
    
    title('Tumor outlined in green dashed line');
    hold off;
end