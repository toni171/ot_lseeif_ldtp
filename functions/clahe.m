function [enhancedImage] = clahe(grayImage, numTiles)
% CLAHE Perform Constrast Limited Adaptive Histogram Equalization.
%   ENHANCEDIMAGE = CLAHE(GRAYIMAGE, NUMTILES) takes in input a grayscale
%   image GRAYIMAGE that has been previously processed (by setting to 0 all the
%   background area) and perform the Contrast Limited Adaptive Histogram
%   Equalization (using the NUMTILES parameters given in input). Then the
%   background area is set to 0 again and the equalized image ENHANCEDIMAGE
%   is returned.
    backgroundMask = grayImage == 0;
    enhancedImage = adapthisteq(grayImage, "NumTiles", [numTiles ...
        numTiles], 'ClipLimit', 0.01);
    enhancedImage(backgroundMask) = 0;
end