function [regions_mask, diagnostics] = level_set_evolution(img, mask, ...
    sigma, n_iters, eps_h, lambda_1, lambda_2, alpha, beta, mu_ldtp, ...
    dt, reinit_int, reinit_dt, reinit_iters, display_set, display_every, ...
    noise_area)
%LEVEL_SET_EVOLUTION Performs the Level Set Evolution.
%   Function LEVEL_SET_EVOLUTION takes in input the grayscale image, the
%   binary mask and other coefficients and perform a level set evolution
%   using parameters in input. The final region mask is returned with the
%   diagnostics structure array.
%
%   Calling sequence:
%       [regions_mask, diagnostics] = level_set_evolution(img, mask, ...
%           sigma, n_iters, eps_h, lambda_1, lambda_2, alpha, beta, ...
%           mu_ldtp, dt, reinit_int, reinit_dt, reinit_iters, ...
%           display_set, display_every, noise_area)
%
%   Define variables:
%       img                 -- Enhanced grayscale image
%       mask                -- Binary mask
%       sigma               -- Standard deviation of Gaussian filtering
%       n_iters             -- Number of iterations
%       eps_h               -- Variable for smoothed Heaviside function
%       lambda_1            -- Weight for data force computation
%       lambda_2            -- Weight for data force computation
%       alpha               -- Weight for smoothing force
%       beta                -- Weight for edge attraction force
%       mu_ldtp             -- Weight for LDTP-based force
%       dt                  -- Time step
%       reinit_int          -- Iterations between two reinitializations
%       einit_dt            -- Time step for Sussman reinitialization
%       reinit_iters        -- Iterations for Sussman reinitialization
%       display_set         -- It will show the segmentation process if true
%       display_every       -- Iterations between two shown set
%       noise_area          -- Smaller noisy regions are removed

% Initializes phi.
phi = bwdist(~mask) - bwdist(mask);

% Computes the smoothed image.
smt_img = imgaussfilt(img, sigma);

% Computes first and second-order derivatives of the smoothed image.
smt_img = im2double(smt_img);
[Ig_x, Ig_y] = grad_central(smt_img);
[Ig_xy, ~]  = grad_central(Ig_y);
[~,  Ig_yx] = grad_central(Ig_x);

% Diagonal directions regularization.
Ig_x_p = Ig_x + (Ig_xy - Ig_yx) * cos(pi/4);
Ig_y_p = Ig_y + (Ig_xy - Ig_yx) * sin(pi/4);

% Computes edge indicator function and derivatives.
mag = sqrt(Ig_x_p.^2 + Ig_y_p.^2);
g = 1 ./ (1 + mag);
[g_x, g_y] = grad_central(g);

% Converts the image to double.
img = im2double(img);

% Initiaizes diagnostic metrics.
diag_area = zeros(n_iters,1);
diag_L2 = zeros(n_iters,1);
diag_E1 = zeros(n_iters,1);
diag_E2 = zeros(n_iters,1);

prev_phi = phi;

for k = 1:n_iters
    % Computes the smoothed Heaviside function of phi.
    H = 0.5 * (1 + (2/pi) * atan(phi./eps_h));

    % Approximates the area inside and outside the contours.
    inside_area  = sum(H(:));
    outside_area = sum(1 - H(:));

    % Approximates average intensity inside and outside.
    inside_mean = sum(img(:) .* H(:)) / (inside_area + eps);          
    outside_mean = sum(img(:) .* (1 - H(:))) / (outside_area + eps);

    % Computes the data force term.
    F_d = lambda_1 * (img - inside_mean) .^ 2 - ...
        lambda_2 * (img - outside_mean) .^ 2;

    % Computes phi gradient.
    [phi_x, phi_y] = grad_central(phi);
    norm_grad = sqrt(phi_x.^2 + phi_y.^2 + 1e-10);
    n_x = phi_x ./ norm_grad;
    n_y = phi_y ./ norm_grad;

    % Computes the curvature.
    curv = div_central(n_x, n_y);

    % Computes the smoothing force F_geo (prevents excessive irregularity).
    F_geo = alpha .* (g .* curv);

    % Computes the edge attraction force.
    F_edge = beta .* (g_x .* phi_x + g_y .* phi_y);

    % Computes the LDTP-based regularization force.
    F_ldtp = mu_ldtp * laplacian(phi);

    % Updates phi.
    phi = phi + dt .* (F_d + F_geo - F_edge + F_ldtp);

    % Performs Sussman reinitialization.
    if reinit_int > 0 && mod(k, reinit_int) == 0
        phi = sussman_reinit(phi, reinit_dt, reinit_iters);
    end

    % Updates diagnostics.
    newMask = phi < 0;
    prevMask = prev_phi < 0;
    diag_area(k) = nnz(newMask ~= prevMask);
    diag_L2(k) = norm(phi(:) - prev_phi(:));
    diag_E1(k) = inside_mean;
    diag_E2(k) = outside_mean;
    prev_phi = phi;

    % Display level set evolution.
    if display_set && (k == 1 || k == n_iters || mod(k, display_every)==0)
        display_evolution(img, phi, k, g, diag_area, diag_L2, diag_E1, ...
            diag_E2)
    end

end

% Extracts the possible tumor regions.
regions_mask = phi < 0;

% Performs a cleaning on the mask.
regions_mask = bwareaopen(regions_mask, noise_area);
regions_mask = imfill(regions_mask, 'holes');

diagnostics = struct();
diagnostics.areaChange = diag_area;
diagnostics.L2change = diag_L2;
diagnostics.inside_mean = diag_E1;
diagnostics.outside_mean = diag_E2;
end

