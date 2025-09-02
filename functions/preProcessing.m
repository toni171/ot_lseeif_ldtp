function [img, mask] = preprocessing(init_img, num_tiles, clip_limit, ...
    otsu_tech, sensitivity, noise_area, conn)
%PREPROCESSING Performs the preprocessing before Level Set Evolution. 
%   Function PREPROCESSING takes in input the initial grayscale image, and
%   other parameters and performs the CLAHE algorithm and extracts a binary
%   mask.
%
%   Calling sequence:
%       [img, mask] = preprocessing(init_img, num_tiles, clip_limit, ...
%           otsu_tech, sensitivity, noise_area, conn)
%
%   Define variables:
%       init_img            -- Initial grayscale image
%       num_tiles           -- NumTiles for CLAHE algorithm
%       clip_limit          -- ClipLimit for CLAHE algorithm
%       otsu_tech           -- Select the binarization technique
%       noise_area          -- Smaller noisy regions are removed
%       conn                -- Connectivity for noise cleaning

% The background of the images is already set to 0.
% Extracts the mask of the liver.
liver_mask = init_img > 0;

% Implements CLAHE algorithm.
img = adapthisteq(init_img, "NumTiles", num_tiles, "ClipLimit", clip_limit);

% Computes threshold and mask.
if otsu_tech
    level = graythresh(img);
else
    level = adaptthresh(img, sensitivity);
end
mask = imbinarize(img, level);

% Now in the mask, the background is black, the liver region is white and
% the possible tumor regions are black.

% Sets the background white.
mask(~liver_mask) = 1;

% Removes small white and black regions.
mask = ~bwareaopen(~mask, noise_area, conn);
mask = bwareaopen(mask, noise_area, conn);
end

