function cleanedImage = binaryThresholding(image, threshold)
    binaryMask = image > threshold;
    cleanedImage = image;
    cleanedImage(~binaryMask) = 0;
end