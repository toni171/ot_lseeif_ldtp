function [binaryImage] = otsuThresholding(enhancedImage)
    backgroundMask = enhancedImage == 0;
    otsuThreshold = graythresh(enhancedImage(~backgroundMask));
    binaryImage = imbinarize(enhancedImage, otsuThreshold);
    binaryImage(backgroundMask) = 1;
end