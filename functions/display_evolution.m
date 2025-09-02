function [] = display_evolution(img, phi, k, g, ...
    diag_area, diag_L2, diag_E1, diag_E2)
%DISPLAY_EVOLUTION Show the evolution of level set.
%   Function DISPLAY_EVOLUTION takes in input the image, the level set at a
%   certain step and other data and update the figure with the current
%   level set (step k).
%
%   Calling sequence:
%       display_evolution(img, phi, k, g, diag_area, diag_L2, diag_E1, ...
%           diag_E2)
%
%   Define variables:
%       img                 -- Enhanced grayscale image
%       phi                 -- Current level set
%       k                   -- Current iteration step
%       g                   -- Edge indicator function
%       diag_area           -- Area of segmented regions.
%       diag_L2             -- Differences between consecutive phi
%       diag_E1             -- Inside intensity mean
%       diag_E2             -- Outside intensity mean

figure(10), clf

subplot(2,2,1), imshow(img), hold on
contour(phi, [0 0], 'r', 'LineWidth', 1.2);
title(sprintf('Level Set: step %d',k)), hold off

subplot(2,2,2), imagesc(g), axis image off
title('Edge Indicator Function (g)');

subplot(2,2,3), plot(1:k, diag_area(1:k));
xlabel('Iteration Step'), ylabel('Area Changes'), grid on

subplot(2,2,4), plot(1:k, diag_L2(1:k)), hold on, yyaxis right
plot(1:k, diag_E1(1:k),'--');
plot(1:k, diag_E2(1:k),':');
legend('L2 difference','Inside Mean Intensity (E1)', ...
    'Outside Mean Intensity (E2)'); title('L2 / E1/E2');
drawnow
end

