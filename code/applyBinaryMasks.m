%% applyBinaryMasks

% This function takes two binary masks and applies each of them to 
% the full color mosaic to acquire two masked, full color images.


% Inputs:

% *fullMosaic* – original, full color mosaic
% *goodBinaryMask* – binary mask representing "good holes"
% *featureBinaryMask* – binary mask representing "features"

% Outputs:

% *goodMosaic* – full color iamge containing only good holes
% *featureMosaic* – full color iamge containing only features


function [goodMosaic, featureMosaic] = applyBinaryMasks(fullMosaic, goodBinaryMask, featureBinaryMask)
    goodMosaic = fullMosaic .* uint8(goodBinaryMask);

    featureMosaic = fullMosaic .* uint8(featureBinaryMask);
    % Change black background to gray background for easier filtering later
    idx = all(featureMosaic == 0, 3);
    featureMosaic(repmat(idx, [1, 1, 3])) = 50;
end