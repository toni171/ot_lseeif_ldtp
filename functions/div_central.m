function d = div_central(p_x, p_y)
%DIV_CENTRAL Computes the discrete divergence.
%   Function COMPUTE_METRICS takes in input the 2D vector fields (p_x, p_y)
%   and computes their discrete divergence using central differences.
%
%   Calling sequence:
%       d = div_central(p_x, p_y)
%
%   Define variables:
%       p_x                 -- x-component of vector field
%       p_y                 -- y-component of vector field
%       d                   -- discrete divergence
[dpxdx, ~] = grad_central(p_x);
[~, dpydy] = grad_central(p_y);
d = dpxdx + dpydy;
end