function cleanedImage = cleanImage(grayImage, threshold)
% CLEANIMAGE    Perform a binary thresholding by a given threshold
%   CLEANEDIMAGE = CLEANIMAGE(GRAYIMAGE, THRESHOLD) takes in input a
%   grayscale image GRAYIMAGE and perform a binary thresholding by the
%   parameter THRESHOLD. All pixels with intensity less than or equal to
%   the threshold are set to 0 and CLEANEDIMAGE is returned.

    binaryMask = grayImage > threshold;

    cleanedImage = grayImage;

    cleanedImage(~binaryMask) = 0;

end
