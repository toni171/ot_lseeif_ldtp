function g = getG(enhancedImage, sigma)
    enhancedImage = im2double(enhancedImage);
    smoothedImage = imgaussfilt(enhancedImage, sigma);

    [gradX, gradY] = gradient(smoothedImage);

    gradXY = conv2(smoothedImage, [1 -1; -1 1] / 2, 'same');
    gradYX = conv2(smoothedImage, [-1 1; 1 -1] / 2, 'same');

    correctedGradX = gradX + (gradXY - gradYX) * cos(pi / 4);
    correctedGradY = gradY + (gradXY - gradYX) * sin(pi / 4);

    g = 1 ./ (1 + sqrt(correctedGradX.^2 + correctedGradY.^2));
end