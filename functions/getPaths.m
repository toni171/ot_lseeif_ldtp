function [imagesPath, labelsPath] = getPaths()
% GETPATHS  Returns the paths of images and labels.

    datasetPath = 'dataset/';
    imagesFolder = 'images/';
    labelsFolder = 'labels/';

    imagesPath = strcat(datasetPath, imagesFolder);
    labelsPath = strcat(datasetPath, labelsFolder);
    
end