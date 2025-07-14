function binaryImage = otsuThresholding(grayImage)
% OTSUTHRESHOLDING Perform the Otsu thresholding on a grayscale image
%   BINARYIMAGE = OTSUTHRESHOLDING(GRAYIMAGE) takes in input a grayscale
%   image that has been previously processed (background has 0 intensity)
%   and returns the result of Otsu thresholding. In the output image
%   BINARYIMAGE the background has intensity 1.
    threshold = graythresh(grayImage);
    binaryImage = imbinarize(grayImage, threshold);
end