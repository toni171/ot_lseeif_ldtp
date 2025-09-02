function l = laplacian(img)
%LAPLACIAN Computes the discrete Laplacian of an image.
%   Function LAPLACIAN computes the 5-point stencil Laplacian of a 
%   2D matrix.
%
%   Calling sequence:
%       l = laplacian(img)
%
%   Define variables:
%       img     -- Input image
%       l       -- 5-point discrete Laplacian
l = -4 * img + circshift(img, [0 1]) + circshift(img, [0 -1]) + ...
    circshift(img, [1 0]) + circshift(img, [-1 0]);
end
