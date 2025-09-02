function phi = sussman_reinit(phi, dt, n_iters)
%SUSSMAN_REINIT Performs the Sussman reinitialization on a level set.
%   Function SUSSMAN_REINIT performs a Sussman reinitialization procedure 
%   on the level set phi. This procedure keeps phi numerically and prevents 
%   the segmentation contour to collapse or explode during iterations.
%
%   Calling sequence:
%       phi = sussman_reinit(phi, dt, n_iters)
%
%   Define variables:
%       phi         -- Level set to update
%       dt          -- Time step
%       n_iters     -- Number of iterations.

% Saves the sign of initial phi.
sign_phi = phi ./ sqrt(phi .^ 2 + 1e-8);
idx_pos = sign_phi > 0;
idx_neg = sign_phi < 0;

for k = 1: n_iters
    % Computes forward/backward differences along x and y.
    a = phi - circshift(phi, [0 1]);    % Backward x.
    b = circshift(phi, [0 -1]) - phi;   % Forward x.
    c = phi - circshift(phi, [1 0]);    % Backward y.
    d = circshift(phi, [-1 0]) - phi;   % Forward y.

    % Splits into positive and negative parts.
    a_p = max(a, 0); a_n = min(a, 0);
    b_p = max(b, 0); b_n = min(b, 0);
    c_p = max(c, 0); c_n = min(c, 0);
    d_p = max(d, 0); d_n = min(d, 0);
    
    % Computes the gradient for phi > 0.
    grad_plus = sqrt( max(a_p.^2, b_n.^2) + max(c_p.^2, d_n.^2) );
    % Computes the gradient for phi < 0.
    grad_minus = sqrt( max(a_n.^2, b_p.^2) + max(c_n.^2, d_p.^2) );

    % Performs the Sussman update.
    D = zeros(size(phi));
    D(idx_pos) = grad_plus(idx_pos) - 1;
    D(idx_neg) = grad_minus(idx_neg) - 1;
    phi = phi - dt .* sign_phi .* D;
end
end
