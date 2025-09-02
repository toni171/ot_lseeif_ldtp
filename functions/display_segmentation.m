function [] = display_segmentation(init_img, seg_boundary_pts, ...
    label_boundary_pts, region_stats, tumor_idx, tumor_mask)
%DISPLAY_EVOLUTION Shows the overlayed segmented and labeled region.
%   Function DISPLAY_EVOLUTION takes in input the initial image, the
%   segmented and labeled boundary points, the region stats and the
%   segmented tumor mask and display the initial image with overlayed the
%   segmented region in red and the labeled region in green.
%
%   Calling sequence:
%       display_segmentation(init_img, seg_boundary_pts, ...
%           label_boundary_pts, region_stats, tumor_idx, tumor_mask)
%
%   Define variables:
%       init_img                -- Initial grayscale image
%       seg_boundary_pts        -- Segmented region boundary points
%       label_boundary_pts      -- Labeled region boundary points
%       region_stats            -- Stats of segmented region
%       tumor_idx               -- Index of tumor region between other
%                                   segmented
%       tumor_mask              -- Segmented tumor mask

% Shows segmented and labeled tumor on the original image.
figure('Name','Segmentation vs Ground Truth','NumberTitle','off');
imshow(init_img, []); hold on

if ~isempty(seg_boundary_pts)
    plot(seg_boundary_pts(:,1), seg_boundary_pts(:,2), 'r-', ...
        'LineWidth', 1.5);
end

if ~isempty(label_boundary_pts)
    plot(label_boundary_pts(:,1), label_boundary_pts(:,2), 'g-', ...
        'LineWidth', 1.5);
end

legend({'Segmentation','Ground Truth'}, 'TextColor','b');
title('Red = segmentation boundary, Green = GT boundary');
axis image
hold off

if exist('region_stats','var') && exist('tumor_idx','var') && ...
        ~isempty(tumor_idx)
    centroid = region_stats.Centroid(tumor_idx,:);
    area_val = region_stats.Area(tumor_idx);
    circ_val = region_stats.Circularity(tumor_idx);
else
    rp = regionprops(tumor_mask, 'Centroid', 'Area');
    if isempty(rp)
        centroid = [NaN NaN];
        area_val = 0;
        circ_val = NaN;
    else
        centroid = rp(1).Centroid;
        area_val = rp(1).Area;
        % Computes perimeter/circularity if needed
        per = regionprops(tumor_mask, 'Perimeter');
        if ~isempty(per) && per(1).Perimeter > 0
            circ_val = 4 * pi * area_val / (per(1).Perimeter^2);
        else
            circ_val = NaN;
        end
    end
end

% Adds annotation text (white text with black outline for readability).
txt = sprintf('Area: %d px\nCirc: %.3f', round(area_val), circ_val);
if all(~isnan(centroid))
    t = text(centroid(1), centroid(2), txt, 'Color','w','FontSize',12, ...
             'FontWeight','bold', 'HorizontalAlignment','center');
    set(t, 'EdgeColor', 'k', 'Margin', 1, 'BackgroundColor', 'none');
else
    title('Selected region overlay');
end

axis image off;
hold off;
end

