function [label_mask] = label_mask_creation(label, img, smt_disk)
%LABEL_MASK_CREATION Computes the labeled tumor region mask.
%   Function LABEL_MASK_CREATION takes in input the labeled border points
%   coordinates, the image (for dimensions) and the radius for smoothing
%   and computes the labeled tumor region mask.
%
%   Calling sequence:
%       label_mask = label_mask_creation(label, img, smt_disk)
%
%   Define variables:
%       label               -- Labeled border points coordinates
%       img                 -- Enhanced grayscale image
%       smt_disk            -- Radius of smoothing disk
%       label_mask          -- Labeled tumor region mask

% Creates the mask of the true tumor region based on border points.
label_x = label(:, 1);
label_y = label(:, 2);
[rows, cols] = size(img);
label_mask = poly2mask(label_x, label_y, rows, cols);
% Smooths the polygon.
smt_se = strel('disk', smt_disk);
label_mask = imopen(label_mask, smt_se);
label_mask = imclose(label_mask, smt_se);
end

