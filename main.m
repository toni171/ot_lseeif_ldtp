addpath('functions')

params.threshold = 15;
params.sigma = 1;
params.epsilon = 1;
params.dt = 1;
params.mu = 0.1;
params.lambda = 1.5;
params.alpha = 0;
params.minArea = 150;
params.iteration = 5;
params.numTiles = 8;
params.seRadius = 12;

for idx = 1 : 17 
    hausD = otLseeifLdtp(idx, params);
end