addpath('functions')

params.threshold = 15;

for idx = 1 : 22
    [grayImage, label] = readImage(idx);
    
    % if idx == 7, showLabeledImage(grayImage, label); end
    
    cleanedImage = binaryThresholding(grayImage, params.threshold);

    if idx == 7, showLabeledImage(cleanedImage, label); end

end