function [tumor_mask, tumor_idx, region_stats] = tumor_identification(...
    regions_mask, min_area, expand_radius)
%TUMOR_IDENTIFICATION Selects the tumor between eligible regions.
%   Function TUMOR_IDENTIFICATION takes in input the mask of eligible
%   regions and other parameters and returns the tumor mask, the index of
%   selected tumor and the table of region stats.
%
%   Calling sequence:
%       [tumor_mask, tumor_idx, region_stats] = tumor_identification(...
%           regions_mask, min_area, expand_radius)
%
%   Define variables:
%       regions_mask        -- Mask of eligible regions
%       min_area            -- Minimum area for tumor
%       expand_radius       -- Radius of dilation disk
%       tumor_mask          -- Final segmented tumor mask
%       tumor_idx           -- Index of region elected as tumor
%       region_stats        -- Table of region statistics

% Extracts connected components.
CC = bwconncomp(regions_mask);
N = CC.NumObjects;

% Initializes tumor mask.
tumor_mask = false(size(regions_mask));
tumor_idx = [];
if N == 0
    region_stats = table([], [], [], [], [], 'VariableNames', ...
        {'Area', 'Perimeter', 'Circularity', 'PixelIdxList', 'Centroid'});
    warning('No connected regions found in regions_mask.');
    return;
end

% Computes area, perimeter and centroid for each connected component.
props = regionprops(CC, 'Area', 'Perimeter', 'Centroid', 'PixelIdxList');

% Builds arrays of stats.
areas = [props.Area]';
perimeters = [props.Perimeter]';
centroids = reshape([props.Centroid], 2, []).';
pixel_idx_list = {props.PixelIdxList}';

% Builds the array of circularities.
circularities = zeros(N,1);
for i = 1:N
    p = perimeters(i);
    a = areas(i);
    if p > 0
        circularities(i) = 4*pi*a / (p^2);
    else
        circularities(i) = 0;
    end
end

% Packs information into a table.
region_stats = table(areas, perimeters, circularities, pixel_idx_list, ...
    centroids, 'VariableNames', ...
    {'Area',' Perimeter', 'Circularity', 'PixelIdxList', 'Centroid'});

% Sorts by circularity descending.
[~, order] = sort(region_stats.Circularity, 'descend');

% Prints the table of eligible tumor regions.

% Keeps only relevant columns for clarity.
stats_table = region_stats(:, {'Area','Circularity'});

% Sorts table in descending circularity (same as selection order).
stats_table = sortrows(stats_table, 'Circularity', 'descend');

% Displays table in MATLAB command window.
disp("Detected regions (sorted by circularity):");
disp(stats_table);

% Displays in a figure using uitable (GUI table).
f = figure('Name', 'Region Stats Table', 'NumberTitle', ...
    'off', 'Color', 'w');
uitable(f, ...
    'Data', table2cell(stats_table), ...
    'ColumnName', stats_table.Properties.VariableNames, ...
    'Units','normalized', ...
    'Position',[0 0 1 1]);

% Iterates in that order and picks first region with enough wide area.
for k = 1:length(order)
    idx = order(k);
    if region_stats.Area(idx) >= min_area
        tumor_idx = idx;
        tumor_mask(region_stats.PixelIdxList{idx}) = true;
        break;
    end
end

% Expands the selected tumor region.
se_expand = strel('disk', expand_radius);
tumor_mask = imdilate(tumor_mask, se_expand);

% Warns if no region is detected.
if isempty(tumor_idx)
    warning("No tumor region detected.\n" + ...
        "No region has an area of at least %d pixels.", min_area);
    return
end
end

