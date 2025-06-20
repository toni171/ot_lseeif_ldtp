function cleanedImage = cleanImage(grayImage, threshold)

    binaryMask = grayImage > threshold;
    
    % structElem = strel('disk', 3);
    % binaryMask = imopen(binaryMask, structElem);
    % 
    % connectedComponents = bwconncomp(binaryMask);
    % numPixels = cellfun(@numel, connectedComponents.PixelIdxList);
    % [~, largestIdx] = max(numPixels);
    % liverMask = false(size(binaryMask));
    % liverMask(connectedComponents.PixelIdxList{largestIdx}) = true;
    % 
    % liverMask = imdilate(liverMask, strel('disk', 4));
    % 
    cleanedImage = grayImage;
    % cleanedImage(~liverMask) = 0;

    cleanedImage(~binaryMask) = 0;

end

