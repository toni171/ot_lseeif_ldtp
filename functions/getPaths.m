function [imagesPath, labelsPath] = getPaths()
    datasetPath = 'old_dataset/';
    imagesFolder = 'images/';
    labelsFolder = 'labels/';
    imagesPath = strcat(datasetPath, imagesFolder);
    labelsPath = strcat(datasetPath, labelsFolder);
end