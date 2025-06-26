function segmentedMask = postProcessing(segmentedMask, grayImage, minArea, threshold, label)
    backgroundMask = grayImage < threshold;

    segmentedMask = ~segmentedMask;
    segmentedMask = ~bwareaopen(segmentedMask, minArea);
    segmentedMask(backgroundMask) = 0;
    seErode = strel('disk', 10);
    segmentedMask = imerode(segmentedMask, seErode);
    % showLabeledImage(segmentedMask, label)
    segmentedMask = imfill(segmentedMask, 'holes');

end