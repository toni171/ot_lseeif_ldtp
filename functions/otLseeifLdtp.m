function [sumD, meanD, hausD] = otLseeifLdtp(idx, params)
% OTLSEEIFLDTP  Apply the whole algorith to the image.
%   [SUMD, MEAND, HAUSD] = OTLSEEIFLDTP(IDX, PARAMS) takes in input the
%   index IDX of the image and the parameters PARAMS and after it applies
%   to the image the whole segmentation pipeline and gives in output the
%   evaluation metrics. The parameters PARAMS.SHOWIMAGES and
%   PARAMS.SHOWSEGMENTEDIMAGE controls the showed images.

    %   Extract grayscale image and label border points.
    [grayImage, label] = readImage(idx);
    %-- Figure 1 
    if params.showImages
        showLabeledImage(grayImage, label, "Original Grayscale Image");
    end

    %   Apply binary thresholding
    cleanedImage = cleanImage(grayImage, params.threshold);
    %-- Figure 2
    if params.showImages
        showLabeledImage( ...
            cleanedImage, label, ...
            "Grayscale Image after Binary Thresholding");
    end
    
    %   Apply the Contrast Limited Adapted Histogram Equalization
    enhancedImage = clahe(cleanedImage, params.numTiles);
    %-- Figure 3
    if params.showImages
        showLabeledImage( ...
            cleanedImage, label, "Grascale Image Enhanced by CLAHE");
    end
    
    %   Apply the adaptive Thresholding
    if params.otsu
        binaryImage = otsuThresholding(enhancedImage);
    else
        binaryImage = adaptiveThresholding(enhancedImage);
    end
    %   Apply the pre-processing pipeline
    binaryImage = preProcessing(binaryImage);
    %-- Figure 4
    if params.showImages
        if params.otsu
            title = "Binary Image after Otsu Thresholding";
        else
            title = "Binary Image after Adaptive Thresholding";
        end
        showLabeledImage(binaryImage, label, title);
    end

    %   Apply the Local Set-LDTP
    segmentedMask = segmentImage(enhancedImage, binaryImage, params);

    %-- Figure 5
    if params.showImages
        showLabeledImage( ...
            segmentedMask, label, ...
            "Binary Mask after Local Set Method with LDTP");
    end
    
    %   Apply the post-processing pipeline
    segmentedMask = postProcessing( ...
        segmentedMask, grayImage, params.maxAreaNoise, ...
        params.threshold, params.preLocationErosionSize);
        
    %-- Figure 6
    if params.showImages
        showLabeledImage( ...
            segmentedMask, label, ...
            "Binary Mask after Routines Pre-Tumor-Location");
    end
    
    %   Locate the tumor between the highlighted regions
    finalMask = locateTumor(segmentedMask, params.minArea, params.circMin);
    
    %   Dilate the tumor region
    seDilate = strel('disk', params.seRadius);
    finalMask = imdilate(finalMask, seDilate);

    %-- Figure 7
    if params.showImages
        showLabeledImage( ...
            finalMask, label, "Binary Mask of the Located Tumor");
    end
    
    %   Extract the boundary points
    [B, ~] = bwboundaries(finalMask, 'noholes');

    if params.showSegmentedImage
        showSegmentation(grayImage, label, B);
    end
    
    %   Compute the evaluation metrics
    [sumD, meanD, hausD] = evaluateSegmentation(label, B);
end