function finalMask = locateTumor(segmentedMask, minArea)
    ccCore = bwconncomp(segmentedMask);
    stats   = regionprops(ccCore,'Area','Perimeter');
    areas   = [stats.Area];
    perims  = [stats.Perimeter];
    circ    = 4*pi*areas./(perims.^2 + eps);

    valid   = find(areas >= minArea);
    if isempty(valid), valid = 1:numel(areas); end

    [~,loc]  = max(circ(valid));
    coreIdx  = valid(loc);

    coreMask = false(size(segmentedMask));
    coreMask(ccCore.PixelIdxList{coreIdx}) = true;

    seDilate = strel('disk', 2);
    finalMask = imdilate(coreMask, seDilate);
end