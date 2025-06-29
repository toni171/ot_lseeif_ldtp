function ldtpCode = computeLDTP(grayImage, threshold)
% COMPUTELDTP  Compute the Local Directional Ternary Pattern map.
%   LDPTCODE = COMPUTELDTP(GRAYIMAGE, THRESHOLD) takes in input a grayscale
%   image GRAYIMAGE and a scalar THRESHOLD and returns a M×N matrix
%   LDPTCODE of integer codes, one per pixel, where each code encodes the
%   8-directional ternary pattern around a pixel.

    grayImage = double(grayImage);
    
    %   Define 8 Kirsch kernels (N, NE, E, SE, S, SW, W, NW)
    kernels{1} = [ 5  5  5; -3  0 -3; -3 -3 -3];  % North
    kernels{2} = [ 5  5 -3;  5  0 -3; -3 -3 -3];  % Northeast
    kernels{3} = [ 5 -3 -3;  5  0 -3;  5 -3 -3];  % East
    kernels{4} = [-3 -3 -3;  5  0 -3;  5  5 -3];  % Southeast
    kernels{5} = [-3 -3 -3; -3  0 -3;  5  5  5];  % South
    kernels{6} = [-3 -3 -3; -3  0  5; -3  5  5];  % Southwest
    kernels{7} = [-3 -3  5; -3  0  5; -3 -3  5];  % West
    kernels{8} = [-3  5  5; -3  0  5; -3 -3 -3];  % Northwest
    
    %   Pre-allocate directional response stack
    [M,N] = size(grayImage);
    responseStack = zeros(M, N, 8);
    
    %   Filter image with each Kirsch kernel
    for d = 1:8
        responseStack(:,:,d) = imfilter(grayImage, kernels{d}, ...
            'replicate', 'conv');
    end
    
    %   For each pixel, compare each directional response to the center
    %   Here we use the grayscale image as the “center” reference.
    %   You could also use a local mean or median if you prefer.
    central = grayImage;

    %   M×N×8 differences
    differences = bsxfun(@minus, responseStack, central);
    
    %   Quantize into ternary:
    %   1 if > threshold, 0 if |·|<=threshold, -1 if < -threshold
    Tpos = differences > threshold;
    Tzer = abs(differences) <= threshold;
    Tneg = differences < -threshold;
    %   Sanity: Tpos+Tzer+Tneg should == 1 everywhere
    
    %   Map ternary {-1,0,1} → {0,1,2} by adding +1
    TR = single(Tpos)*2 + single(Tzer)*1 + single(Tneg)*0;  
    %   TR contains values 0,1,2 for each direction
    
    %   Encode the 8 ternary digits as a base-3 number:
    %   code = sum_{k=1..8} TR(:,:,k) * 3^(k-1)
    ldtpCode = zeros(M, N, 'uint32');
    for k = 1:8
        ldtpCode = ldtpCode + uint32( TR(:,:,k) ) * uint32(3^(k-1));
    end
    
    %   Optionally mask out a 1-pixel border (since filtering is less
    %   reliable there):
    ldtpCode(1,:) = 0;
    ldtpCode(end,:) = 0;
    ldtpCode(:,1) = 0;
    ldtpCode(:,end) = 0;
end
