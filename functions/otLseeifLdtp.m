function hausD = otLseeifLdtp(idx, params)

    [grayImage, label] = readImage(idx);
    
    % if idx == 1, showLabeledImage(grayImage, label); end

    cleanedImage = cleanImage(grayImage, params.threshold);

    % if idx == 1, showLabeledImage(cleanedImage, label); end

    enhancedImage = clahe(cleanedImage, params.numTiles);

    % showLabeledImage(cleanedImage, label);
    
    % binaryImage = otsuThresholding(enhancedImage);

    T_local = adaptthresh(enhancedImage, 0.5, ...
                      'NeighborhoodSize', [101 101], ...
                      'Statistic', 'mean', ...
                      'ForegroundPolarity', 'dark');

    binaryImage = imbinarize(enhancedImage, T_local);

    se = strel('disk', 1);
    binaryImage = imerode(binaryImage, se);

    binaryImage = bwareaopen(binaryImage, 100);

    binaryImage = imdilate(binaryImage, se);

    % showLabeledImage(binaryImage, label);

    segmentedMask = segmentImage(enhancedImage, binaryImage, params);

    % showLabeledImage(segmentedMask, label);

    segmentedMask = postProcessing(segmentedMask, grayImage, params.minArea, params.threshold, label);
        
    % showLabeledImage(segmentedMask, label);

    finalMask = locateTumor(segmentedMask, params.minArea);

    seDilate = strel('disk', params.seRadius);
    finalMask = imdilate(finalMask, seDilate);

    % showLabeledImage(finalMask, label);

    [B, ~] = bwboundaries(finalMask, 'noholes');

    % showSegmentation(grayImage, label, B);

    [sumD, meanD, hausD] = evaluateSegmentation(label, B);
    fprintf("L'immagine %d ha Directed Hausdorff %0.2f\n", idx, hausD)

    showSegmentation(grayImage, label, B);
end