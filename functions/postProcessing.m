function processedMask = postProcessing(segmentedMask, grayImage, ...
    maxArea, threshold)
% POSTPROCESSING    Removes noisy points, erodes the borders and fills
% holes.
%   PROCESSEDMASK = POSTPROCESSING(SEGMENTEDMASK, GRAYIMAGE, MAXAREA,
%   THRESHOLD) takes in input the mask SEGMENTEDMASK after the Level 
%   Set-Local Directional Ternary Pattern, the original grayscale image
%   GRAYIMAGE and the MAXAREA and THRESHOLD paramenters. The max area
%   parameter is used to remove small noises, than the mask is eroded and
%   the holles are filled.

    backgroundMask = grayImage < threshold;

    segmentedMask = ~segmentedMask;
    cleanedMask = ~bwareaopen(segmentedMask, maxArea);

    cleanedMask(backgroundMask) = 0;
    seErode = strel('disk', 10);
    erodedMask = imerode(cleanedMask, seErode);

    processedMask = imfill(erodedMask, 'holes');

end