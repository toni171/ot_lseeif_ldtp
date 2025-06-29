function segmentedMask = segmentImage(grayImage, binaryImage, params)
% SEGMENTIMAGE  Segment an imageusing Level Set and Local Directional 
% Ternary Pattern.
%   SEGMENTEDMASK = SEGMENTIMAGE(GRAYIMAGE, BINARYIMAGE, PARAMS) takes
%   in input a grayscale image GRAYIMAGE, an initial binary mask
%   BINARYIMAGE and a set of paramenters PARAMS. The function evolves on
%   the image a level set function to segment the region of interest.
    
    %   Compute the edge indicator function
    g = getG(grayImage, params.sigma);
    
    %   Initialize level set function using the signed distance of the mask
    signedDistance = bwdist(binaryImage) - bwdist(~binaryImage);
    phi = signedDistance + double(binaryImage) - 0.5;
    
    %   Convert the grayscale image to double
    grayImage = im2double(grayImage);

    %   Compute local directional ternaty pattern
    T_ldtp = 10;  
    ldtpMap = computeLDTP(grayImage, T_ldtp);
    ldtpMap = double(ldtpMap);
    ldtpMap = ldtpMap / max(ldtpMap(:));  

    %   Evolution of the level set
    for iteration = 1:params.iteration

        %   Compute Heavyside function
        H = 0.5 * (1 + (2 / pi) * atan(phi / params.epsilon));
        %   Compute Dirac delta approximation
        delta = (params.epsilon / pi) ./ (params.epsilon ^ 2 + phi .^ 2);
        
        %   Compute region-based intensity means for texture force
        cIn_tex = sum(ldtpMap(:) .* H(:)) / (sum(H(:)) + params.epsilon);
        cOut_tex = sum(ldtpMap(:) .* (1 - H(:))) / (sum(1 - H(:)) + ...
            params.epsilon);
        
        %   Compute data-fitting term
        dataForce = (ldtpMap - cIn_tex).^2 - (ldtpMap - cOut_tex).^2;

        %   Compute spatial gradients
        [phiX, phiY] = gradient(phi);
        gradPhiNorm = sqrt(phiX .^ 2 + phiY .^ 2) + 1e-8;
        nx = phiX ./ gradPhiNorm;
        ny = phiY ./ gradPhiNorm;
        
        %   Compute curvature term
        curvature = divergence(nx, ny);
        
        %   Compute laplacian of level set function
        laplacianPhi = del2(phi);
        
        %   Update the level set function
        phi = phi + params.dt * ( ...
            params.mu * curvature + ...
            params.lambda * (g .* dataForce .* delta) + ...
            params.alpha * laplacianPhi ...
        );

    end
    
    %   Generate binary segmentation mask
    segmentedMask = phi > 0;
end