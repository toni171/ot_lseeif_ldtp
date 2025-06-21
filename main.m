addpath('functions')

params.threshold = 15;
params.sigma = 1;
params.epsilon = 1;
params.dt = 1;
params.mu = 0.1;
params.lambda = 1.5;
params.alpha = 0;
params.minArea = 500;
params.iteration = 20;
params.numTiles = 8;

% for iteration = 20 
%       fprintf("%0.2f\n", iteration)
%       sum = 0;

    for idx = 1 : 9
        
        [grayImage, label] = readImage(idx);
        
        % if idx == 1, showLabeledImage(grayImage, label); end
    
        cleanedImage = cleanImage(grayImage, params.threshold);
    
        % if idx == 1, showLabeledImage(cleanedImage, label); end
    
        enhancedImage = clahe(cleanedImage, params.numTiles);
    
        % showLabeledImage(cleanedImage, label);
        
        binaryImage = otsuThresholding(enhancedImage);

        % binaryImage = bwareaopen(binaryImage, 10);
    
        % showLabeledImage(binaryImage, label);
    
        % seErode = strel('disk', iteration);
        % binaryImage = ~binaryImage;
        % binaryImage = imerode(binaryImage, seErode);
        % binaryImage = ~binaryImage;
        % if idx == 7, showLabeledImage(binaryImage, label); end
    
        segmentedMask = segmentImage(enhancedImage, binaryImage, params);
   
        % showLabeledImage(segmentedMask, label);

    
        segmentedMask = ~segmentedMask;
        segmentedMask = ~bwareaopen(segmentedMask, params.minArea);

        segmentedMask = imfill(segmentedMask, 'holes');
        

        seErode = strel('disk', 2);
        segmentedMask = imerode(segmentedMask, seErode);
        
    
        % if idx == 3, showLabeledImage(segmentedMask, label); end
    
        coreMask = locateTumor(segmentedMask, params.minArea);
        

        seDilate = strel('disk', 2);
        finalMask = imdilate(coreMask, seDilate);
        
    
        % if idx == 1, showLabeledImage(finalMask, label); end
    
        [B, ~] = bwboundaries(finalMask, 'noholes');
    
        showSegmentation(grayImage, label, B);
    
        [sumD, meanD, hausD] = evaluateSegmentation(label, B);
        fprintf("L'immagine %d ha Directed Hausdorff %0.2f\n", idx, hausD)
        % sum = sum + hausD;
    end

%     if iteration == 1
%         bestParam = iteration;
%         bestSum = sum;
%         if sum < bestSum
%            bestParam = iteration;
%            bestSum = sum;
%         end
%     end
% end
% 
% fprintf("migliore è %0.2f\n", bestParam)