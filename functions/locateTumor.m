function finalMask = locateTumor(segmentedMask, minArea)
    
    circMin    = 0.3;               % allow elongated shapes down to circ=0.3
    

    ccCore = bwconncomp(segmentedMask);
    stats   = regionprops(ccCore,'Area','Perimeter');
    areas   = [stats.Area];
    perims  = [stats.Perimeter];
    circ    = 4*pi*areas./(perims.^2 + eps);

    valid   = find(areas >= minArea);
    goodIdx    = valid(circ(valid) >= circMin);

    if isempty(goodIdx)
        warning('No region passes circ ≥ %.2f; falling back to area-only', circMin);
        [~,loc2] = max(areas(valid));
        coreIdx  = valid(loc2);
    else
        % pick the largest area among the “good” ones
        [~,loc2] = max(areas(goodIdx));
        coreIdx  = goodIdx(loc2);
    end

    coreMask = false(size(segmentedMask));
    coreMask(ccCore.PixelIdxList{coreIdx}) = true;

    seDilate = strel('disk', 2);
    finalMask = imdilate(coreMask, seDilate);
end