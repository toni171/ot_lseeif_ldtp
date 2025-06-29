function tumorMask = locateTumor(regionsMask, minArea, circMin)
% LOCATETUMOR   Locates the tumor and returns it highlighted in a mask.
%   tumorMask = LOCATETUMOR(REGIONSMASK, MINAREA, CIRCMIN) takes in input
%   a mask REGIONSMASK with possible tumor regions, the minimum area for a
%   tumor MINAREA and the circularity threhsold parameter CIRCMIN and 
%   select the most likely region to be a tumor (it is returned in a mask
%   TUMORMASK)

    %   Select connected components
    connectedComponents = bwconncomp(regionsMask);
    
    %   Compute area and perimeters
    stats = regionprops(connectedComponents,'Area','Perimeter');
    areas = [stats.Area];
    perims = [stats.Perimeter];

    %   Compute circularity metric
    circ = 4*pi*areas./(perims.^2 + eps);

    %   Filter regions by minimum area
    validIdx = find(areas >= minArea);
    
    %   Filter regions by circuarity metric
    goodIdx = validIdx(circ(validIdx) >= circMin);
    
    %   If no regions satisfy circularity, take the region in validIdx
    %   whose area is the largest
    if isempty(goodIdx)
        [~,loc] = max(areas(validIdx));
        tumorIdx  = validIdx(loc);
    
    %    Otherwise, pick the region in goodIdx whose area is the largest
    else
        [~,loc] = max(areas(goodIdx));
        tumorIdx  = goodIdx(loc);
    end
    
    %   Create the tumor mask
    tumorMask = false(size(regionsMask));
    tumorMask(connectedComponents.PixelIdxList{tumorIdx}) = true;

end