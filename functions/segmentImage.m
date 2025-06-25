function segmentedMask = segmentImage(enhancedImage, binaryImage, params)    
    
    g = getG(enhancedImage, params.sigma);

    signedDistance = bwdist(binaryImage) - bwdist(~binaryImage);

    phi = signedDistance + double(binaryImage) - 0.5;

    enhancedImage = im2double(enhancedImage);

    T_ldtp = 10;  % threshold LDTP, può essere regolato empiricamente
    ldtpMap = computeLDTP(enhancedImage, T_ldtp);
    
    % Normalizza la mappa per usarla nella funzione di energia
    ldtpMap = double(ldtpMap);
    ldtpMap = ldtpMap / max(ldtpMap(:));  % normalizzazione in [0,1]

    for iteration = 1:params.iteration
        H = 0.5 * (1 + (2 / pi) * atan(phi / params.epsilon));

        delta = (params.epsilon / pi) ./ (params.epsilon ^ 2 + phi .^ 2);
        
        cIn_tex = sum(ldtpMap(:) .* H(:)) / (sum(H(:)) + params.epsilon);
        cOut_tex = sum(ldtpMap(:) .* (1 - H(:))) / (sum(1 - H(:)) + params.epsilon);

        dataForce = (ldtpMap - cIn_tex).^2 - (ldtpMap - cOut_tex).^2;

        [phiX, phiY] = gradient(phi);

        gradPhiNorm = sqrt(phiX .^ 2 + phiY .^ 2) + 1e-8;

        nx = phiX ./ gradPhiNorm;
        ny = phiY ./ gradPhiNorm;

        curvature = divergence(nx, ny);

        laplacianPhi = del2(phi);

        phi = phi + params.dt * ( ...
            params.mu * curvature + ...                 % Smoothness term
            params.lambda * (g .* dataForce .* delta) + ...  % Image data term
            params.alpha * laplacianPhi ...            % Regularization term
        );
        
        % if mod(iteration - 1, 10) == 0, figure, imshow(phi); end

    end

    segmentedMask = phi > 0;
end