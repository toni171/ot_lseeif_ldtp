function ldtpCode = computeLDTP(I, T)
% computeLDTP  Compute the Local Directional Ternary Pattern map.
%
%   ldtpCode = computeLDTP(I, T) returns an M×N matrix of integer
%   codes, one per pixel, where each code encodes the 8-directional
%   ternary pattern around that pixel.  
%
%   Inputs:
%     I : M×N grayscale image (uint8 or double in [0,1] or [0,255]).
%     T : scalar threshold for ternary quantization (e.g. 5–15 for uint8).
%
%   Output:
%     ldtpCode : M×N integer matrix, each in [0 … 3^8−1].
%
%   Example:
%     I = imread('yourImage.png');
%     ldtp = computeLDTP(I, 10);
%     imagesc(ldtp); axis image off; colorbar;

    %–– Convert to double for filtering
    I = double(I);
    
    %–– Define 8 Kirsch kernels (N, NE, E, SE, S, SW, W, NW)
    K{1} = [ 5  5  5; -3  0 -3; -3 -3 -3];  % North
    K{2} = [ 5  5 -3;  5  0 -3; -3 -3 -3];  % Northeast
    K{3} = [ 5 -3 -3;  5  0 -3;  5 -3 -3];  % East
    K{4} = [-3 -3 -3;  5  0 -3;  5  5 -3];  % Southeast
    K{5} = [-3 -3 -3; -3  0 -3;  5  5  5];  % South
    K{6} = [-3 -3 -3; -3  0  5; -3  5  5];  % Southwest
    K{7} = [-3 -3  5; -3  0  5; -3 -3  5];  % West
    K{8} = [-3  5  5; -3  0  5; -3 -3 -3];  % Northwest
    
    %–– Pre-allocate directional response stack
    [M,N] = size(I);
    R = zeros(M, N, 8);
    
    %–– Filter image with each Kirsch kernel
    for d = 1:8
        R(:,:,d) = imfilter(I, K{d}, 'replicate', 'conv');
    end
    
    %–– For each pixel, compare each directional response to the center
    %–– Here we use the *pixel intensity* I as the “center” reference.
    %–– You could also use a local mean or median if you prefer.
    C = I;              % M×N
    D = bsxfun(@minus, R, C);  % M×N×8 differences
    
    %–– Quantize into ternary:  1 if >T, 0 if |·|<=T, -1 if < -T
    Tpos = D >  T;
    Tzer = abs(D) <= T;
    Tneg = D < -T;
    % Sanity: Tpos+Tzer+Tneg should == 1 everywhere
    
    %–– Map ternary {-1,0,1} → {0,1,2} by adding +1
    TR = single(Tpos)*2 + single(Tzer)*1 + single(Tneg)*0;  
    % TR contains values 0,1,2 for each direction
    
    %–– Encode the 8 ternary digits as a base-3 number:
    %–– code = sum_{k=1..8} TR(:,:,k) * 3^(k-1)
    ldtpCode = zeros(M, N, 'uint32');
    for k = 1:8
        ldtpCode = ldtpCode + uint32( TR(:,:,k) ) * uint32(3^(k-1));
    end
    
    %–– Optionally mask out a 1-pixel border (since filtering is less
    %–– reliable there):
    ldtpCode(1,:) = 0;
    ldtpCode(end,:) = 0;
    ldtpCode(:,1) = 0;
    ldtpCode(:,end) = 0;
end
