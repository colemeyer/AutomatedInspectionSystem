%% generateSmallHoleMask

% This function generates a binary mask representing the small holes in the
% full color mosaic


% Inputs:

% *goodMosaic* – full color image containing only good holes
% *brightnessThreshold* – brightness threshold used to differentiate small holes
% from background and large holes

% Outputs:

% *smallHoleMask* – binary mask representing small holes


function smallHoleMask = generateSmallHoleMask(goodMosaic, brightnessThreshold)
    % Make red more prominent
    smallHoleMask = 8 * (goodMosaic(:, :, 1) - 2 * goodMosaic(:, :, 2));

    smallHoleMask = imbinarize(smallHoleMask, brightnessThreshold);
    smallHoleMask = imopen(smallHoleMask, strel('disk', 4));
end