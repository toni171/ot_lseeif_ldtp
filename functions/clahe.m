function [enhancedImage] = clahe(cleanedImage, numTiles)
    backgroundMask = cleanedImage == 0;
    enhancedImage = adapthisteq(cleanedImage, "NumTiles", [numTiles numTiles], 'ClipLimit', 0.01);
    enhancedImage(backgroundMask) = 0;
end