function segmentedMask = postProcessing(segmentedMask, minArea)
    segmentedMask = ~segmentedMask;
    segmentedMask = ~bwareaopen(segmentedMask, minArea);
    segmentedMask = imfill(segmentedMask, 'holes');
    seErode = strel('disk', 2);
    segmentedMask = imerode(segmentedMask, seErode);
end