function [g_x, g_y] = grad_central(img)
%GRAD_CENTRAL Computes the image gradients.
%   Function GRAD_CENTRAL computes the image gradients using central finite
%   differences.
%
%   Calling sequence:
%       [g_x, g_y] = grad_central(img)
%
%   Define variables:
%       img     -- Input image
%       g_x     -- Gradient component in x
%       g_y     -- Gradient component in y
g_x = 0.5 * (circshift(img, [0 -1]) - circshift(img, [0 1]));
g_y = 0.5 * (circshift(img, [-1 0]) - circshift(img, [1 0]));
end