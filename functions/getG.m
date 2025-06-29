function g = getG(grayImage, sigma)
% GETG  Compute the enhanced edge indicator function.
%   G = GETG(GRAYIMAGE, SIGMA) takes in input a grayscale image GRAYIMAGE
%   that has been previously enhanced with CLAHE technique and the standard
%   deviation parameter SIGMA and returns  the enhanced edge indicator
%   function G.

    %   Convert image to double
    grayImage = im2double(grayImage);

    %   Smooth the image with Gaussian filter with standard deviation sigma
    smoothedImage = imgaussfilt(grayImage, sigma);

    %   Compute first-order spatial gradients
    [gradX, gradY] = gradient(smoothedImage);

    %   Compute cross-derivative approximations
    gradXY = conv2(smoothedImage, [1 -1; -1 1] / 2, 'same');
    gradYX = conv2(smoothedImage, [-1 1; 1 -1] / 2, 'same');

    %   Correct primary gradients adding a weighted difference of
    %   cross-derivatives
    %   Weights correspond to cosine and sine of 45 degrees
    correctedGradX = gradX + (gradXY - gradYX) * cos(pi / 4);
    correctedGradY = gradY + (gradXY - gradYX) * sin(pi / 4);

    %   Compute the enhanced edge indicator
    g = 1 ./ (1 + sqrt(correctedGradX.^2 + correctedGradY.^2));
end