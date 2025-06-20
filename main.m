addpath('functions')

params.threshold = 15;

for idx = 1 : 22
    [grayImage, label] = readImage(idx);
    
    % if idx == 7, showLabeledImage(grayImage, label); end

    cleanedImage = cleanImage(grayImage, params.threshold);

    % if idx == 7, showLabeledImage(cleanedImage, label); end

    enhancedImage = clahe(cleanedImage);
    
    binaryImage = preprocessing(enhancedImage);

    % if idx == 7, showLabeledImage(binaryImage, label); end
    
end