function [metrics_table, seg_boundary_pts, label_boundary_pts] = ...
    compute_metrics(tumor_mask, label_mask, label, pixel_spacing, n_samples)
%COMPUTE_METRICS Computes the segmentation evaluation metrics.
%   Function COMPUTE_METRICS takes in input the information of segmentation
%   and label mask and computes the metrics of evaluation that are returned
%   in a table variable.
%
%   Calling sequence:
%       [metrics_table, seg_boundary_pts, label_boundary_pts] = ...
%           compute_metrics(tumor_mask, label_mask, label, ...
%           pixel_spacing, n_samples)
%
%   Define variables:
%       tumor_mask          -- Segmented region mask
%       label_mask          -- Labeled region mask
%       label               -- Label border points
%       pixel_spacing       -- Spacing of pixels
%       n_samples           -- Number of samples to interpolate

[rows, cols] = size(tumor_mask);

label_x = label(:, 1);
label_y = label(:, 2);

% Computes area in pixels.
A_seg = nnz(tumor_mask);
A_label = nnz(label_mask);

% Computes intersection area and union area.
inters_area = nnz(tumor_mask & label_mask);
union_area = nnz(tumor_mask | label_mask);

% Computes Dice coefficient.
if union_area == 0
    dice = NaN;
else
    dice = 2 * inters_area / (A_seg + A_label);
end

% Computes Jaccard coefficient.
if union_area == 0
    jaccard = NaN;
else
    jaccard = inters_area / union_area;
end

% Computes precision and recall.
precision = inters_area / max(A_seg, eps);
recall = inters_area / max(A_label, eps);

% Computes false positive rate (FRP).
frp = (nnz(tumor_mask & ~label_mask)) / max((rows * cols - A_label), eps);

% Computes the relative area error.
rae = (A_seg - A_label) / max(A_label, eps);

% Computes segmented region perimeter and centroid. 
try
    rp_seg = regionprops(tumor_mask, 'Perimeter', 'Centroid');
    perim_seg = sum([rp_seg.Perimeter]);
    centr_seg = mean(reshape([rp_seg.Centroid],2,[]), 2).';
catch
    perim_seg = NaN; centr_seg = [NaN NaN];
end

% Computes labeled region perimeter and centroid.
try
    rp_label = regionprops(label_mask, 'Perimeter', 'Centroid');
    perim_label = sum([rp_label.Perimeter]);
    centr_label = mean(reshape([rp_label.Centroid],2,[]), 2).';
catch
    perim_label = NaN; centr_label = [NaN NaN];
end

% Conputes centroid euclidean distance.
if all(~isnan(centr_seg)) && all(~isnan(centr_label))
    centr_dist = sqrt((centr_seg(1) - centr_label(1))^2 + ...
        (centr_seg(2) - centr_label(2))^2) * pixel_spacing;
else
    centr_dist = NaN;
end

% Collects segmented region boundary points.
seg_boundary = bwboundaries(tumor_mask, 'noholes');
seg_boundary_pts = cellfun(@(b) [b(:,2), b(:,1)], seg_boundary, ...
                           'UniformOutput', false);
seg_boundary_pts = vertcat(seg_boundary_pts{:});
seg_boundary_pts = unique(seg_boundary_pts, 'rows');

% Closes the polygon by appending the first point to the last position.
p_x = [label_x(:); label_x(1)];
p_y = [label_y(:); label_y(1)];
% Computes the list of distances between adjacent points.
dists = sqrt(diff(p_x).^2 + diff(p_y).^2);
cum_d = [0; cumsum(dists)];
total_len = cum_d(end);     % total_len represents the perimeter.

if total_len == 0
    label_boundary_pts = [label_x(:), label_y(:)];
else
    % Generates a linear spaced vector from 0 to the total perimeter.
    t = linspace(0, total_len, n_samples);
    % Interpolates the coordinates given a length.
    g_x = interp1(cum_d, p_x, t, 'linear');
    g_y = interp1(cum_d, p_y, t, 'linear');
    % Collects label points.
    label_boundary_pts = [g_x(:), g_y(:)];
end


if isempty(seg_boundary_pts) && isempty(label_boundary_pts)
    warning('Both boundary sets are empty. No boundary metrics computed.');
    hausdorff = NaN;
    hausdorff_dir_label2seg = NaN; 
    hausdorff_dir_seg2label = NaN;
    assd = NaN;
    rmsd_sym = NaN;
else
   % Computes direct distances.
    if isempty(seg_boundary_pts)
        d_label2seg = sqrt((label_boundary_pts(:,1) - centr_seg(1)).^2 + ...
            (label_boundary_pts(:,2) - centr_seg(2)).^2); 
        d_seg2label = Inf;
    elseif isempty(label_boundary_pts)
        d_seg2label = sqrt((seg_boundary_pts(:,1) - centr_label(1)).^2 + ...
            (seg_boundary_pts(:,2) - centr_label(2)).^2);
        d_label2seg = Inf;
    else
        D_label_seg = pdist2(label_boundary_pts, seg_boundary_pts);
        d_label2seg = min(D_label_seg, [], 2);
        D_seg_label = pdist2(seg_boundary_pts, label_boundary_pts);
        d_seg2label = min(D_seg_label, [], 2);
    end

    % Computes directed Hausdorff distances.
    hausdorff_dir_label2seg = max(d_label2seg) * pixel_spacing;
    hausdorff_dir_seg2label = max(d_seg2label) * pixel_spacing;
    hausdorff = max(hausdorff_dir_label2seg, hausdorff_dir_seg2label);

    % Computes the average symmetric surface distance (ASSD): 
    % the mean of both mean distances.
    mean_label2seg = mean(d_label2seg) * pixel_spacing;
    mean_seg2label = mean(d_seg2label) * pixel_spacing;
    assd = (mean_label2seg + mean_seg2label) / 2;

    % Computes the symmetric RMS distance.
    rms_label2seg = sqrt(mean(d_label2seg.^2)) * pixel_spacing;
    rms_seg2label = sqrt(mean(d_seg2label.^2)) * pixel_spacing;
    rmsd_sym = (rms_label2seg + rms_seg2label) / 2;
end

% Packs metrics in a structure array.
metrics = struct();
metrics.Dice = dice;
metrics.Jaccard = jaccard;
metrics.Precision = precision;
metrics.Recall = recall;
metrics.FPR = frp;
metrics.RelAreaError = rae;
metrics.AreaGT = A_label;
metrics.AreaSeg = A_seg;
metrics.PerimeterGT = perim_label;
metrics.PerimeterSeg = perim_seg;
metrics.CentroidDist = centr_dist;
metrics.Hausdorff = hausdorff;
metrics.Hausdorff_dir_gt2seg = hausdorff_dir_label2seg;
metrics.Hausdorff_dir_seg2gt = hausdorff_dir_seg2label;
metrics.ASSD = assd;
metrics.RMSD_sym = rmsd_sym;

% Creates summary table (nicely formatted).
names = {'Dice', 'Jaccard', 'Precision', 'Recall', 'RelAreaError', ...
    'AreaGT', 'AreaSeg', 'PerimeterGT', 'PerimeterSeg', 'CentroidDist', ...
    'Hausdorff', 'ASSD', 'RMSD_sym'};
vals = [metrics.Dice, metrics.Jaccard, metrics.Precision, ...
    metrics.Recall, metrics.RelAreaError, metrics.AreaGT, ...
    metrics.AreaSeg, metrics.PerimeterGT, metrics.PerimeterSeg, ...
    metrics.CentroidDist, metrics.Hausdorff, metrics.ASSD, ...
    metrics.RMSD_sym];
metrics_table = array2table(vals, 'VariableNames', names);
end

