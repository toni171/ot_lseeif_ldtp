function [] = showLabeledImage(grayImage, label)

    figure;
    imshow(grayImage);      
    hold on;

    if iscell(label)
        label = cell2mat(cellfun(@cell2mat, label, 'UniformOutput', false));
    end

    for i = 1:size(label, 1)
        x = round(label(i, 1));
        y = round(label(i, 2));
    
        plot(x, y, 'r+', 'MarkerSize', 10, 'LineWidth', 2);
    end
    title('Labeled Image');
end