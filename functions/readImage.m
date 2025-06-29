function [grayImage, label] = readImage(idx)
% READIMAGE Returns image and labels of the corresponding index.

    [imagesPath, labelsPath] = getPaths();
    
    imagePath = strcat(imagesPath, string(idx), '.jpg');
    labelPath = strcat(labelsPath, string(idx), '.json');

    image = imread(imagePath);
    jsonLabel = fileread(labelPath);

    if size(image, 3) == 3
        grayImage = rgb2gray(image);
    else
        grayImage = image;
    end
    label = jsondecode(jsonLabel);
end