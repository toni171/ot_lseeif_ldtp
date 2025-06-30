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
params.seRadius = 14;
params.circMin = 0.3;

params.showImages = false;
params.showSegmentedImage = true;

for idx = 1 : 17
    [sumD, meanD, hausD] = otLseeifLdtp(idx, params);
    fprintf("L'immagine %d ha Directed Hausdorff %0.2f\n", idx, hausD)
end