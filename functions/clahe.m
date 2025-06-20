function [enhancedImage] = clahe(cleanedImage)
    backgroundMask = cleanedImage == 0;
    enhancedImage = adapthisteq(cleanedImage, "NumTiles", [8 8], 'ClipLimit', 0.01);
    enhancedImage(backgroundMask) = 0;
end