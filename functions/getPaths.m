function [imagesPath, labelsPath] = getPaths()
    datasetPath = 'dataset/';
    imagesFolder = 'images/';
    labelsFolder = 'labels/';
    imagesPath = strcat(datasetPath, imagesFolder);
    labelsPath = strcat(datasetPath, labelsFolder);
end