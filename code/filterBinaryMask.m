%% filterBinaryMask

% This function further inspects the feature mosaic to identify any
% unblocked holes that may have been masked out due to a stain or another 
% similar feature. If holes within the feature mosaic are identified, 
% masks and mosaics are updated.


% Inputs:

% *fullMosaic* – original, full color mosaic
% *featureMosaic* – full color image containing only features
% *featureBinaryMask* – binary mask representing features
% *goodBinaryMask* – binary mask representing good holes
% *brightnessThreshold* – brightness threshold used to differentiate holes
% from stains or other similar features

% Outputs:

% *goodMosaic* – full color image containing only good holes
% *featureMosaic* – full color image containing only features
% *featureBinaryMask* – binary mask representing features
% *goodBinaryMask* – binary mask representing good holes


function [goodMosaic, featureMosaic, featureBinaryMask, goodBinaryMask] = filterBinaryMask(fullMosaic, featureMosaic, featureBinaryMask, goodBinaryMask, brightnessThreshold)
    newHoleMask = rgb2gray(featureMosaic);
    newHoleMask = imbinarize(newHoleMask, brightnessThreshold);
    newHoleMask = imcomplement(newHoleMask);
    newHoleMask = imopen(newHoleMask, strel('disk', 15));
    newHoleMask = imfill(newHoleMask,'holes');
    newHoleMask = bwconvhull(newHoleMask, 'Objects');

    featureBinaryMask = featureBinaryMask - newHoleMask;
    goodBinaryMask = goodBinaryMask + newHoleMask;

    [goodMosaic, featureMosaic] = applyBinaryMasks(fullMosaic, goodBinaryMask, featureBinaryMask);
end