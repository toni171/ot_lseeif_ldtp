function binaryImage = preProcessing(binaryImage)
% PREPROCESSING Apply the pre-processing pipeline to the binary image.
%   BINARYIMAGE = PREPROCESSING(BINARYIMAGE) take in input the BINARYIMAGE,
%   erodes the image, removes small noises and dilates it again.

    se = strel('disk', 1);
    binaryImage = imerode(binaryImage, se);

    binaryImage = bwareaopen(binaryImage, 100);

    binaryImage = imdilate(binaryImage, se);