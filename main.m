close all;
clear, clc;

addpath('functions')

params.threshold = 15;
params.sigma = 1;
params.epsilon = 1;
params.dt = 1;
params.mu = 0.1;
params.lambda = 1.5;
params.alpha = 0;
params.minArea = 50;
params.maxAreaNoise = 10;
params.iteration = 10;
params.numTiles = 8;
params.seRadius = 12;    % prev 14
params.circMin = 0.3;
params.preLocationErosionSize = 10;  % prev 10
% Set params.showImages to true to see the current state of each image
% during each phase of the algorithm
params.showImages = false;
% Set params.showSegmentedImage to true to see the initial grayscale image
% with highlighted the border segmented by the algorithm and the labeled
% points of the border of the tumor
params.showSegmentedImage = false;
% Set true to use the adaptive thresholding, otherwise it uses the Otsu
% thresholding
params.otsu = false;

for idx = 1 : 17
    [sumD, meanD, hausD] = otLseeifLdtp(idx, params);
    fprintf("The Image %d has Directed Hausdorff %0.2f\n", idx, hausD)
    fprintf( ...
        "The Image %d has Mean Distance %0.2f from the Label\n\n", ...
        idx, meanD)
end