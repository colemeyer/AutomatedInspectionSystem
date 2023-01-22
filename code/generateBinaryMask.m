%% generateBinaryMask

% This function binarizes the full color mosaic according to the package
% material. 


% Inputs:

% *fullMosaic* – original, full color mosaic
% *brightnessThreshold* – brightness threshold used to differentiate holes
% from background
% *type* – type of packaging; used to determine approach to binarization
% ('unbaggedGrid', 'baggedGrid', or 'foil')

% Outputs:

% *fullBinaryMask* – binary mask representing all holes and features

function fullBinaryMask = generateBinaryMask(fullMosaic, brightnessThreshold, type)
    if strcmp(type,'unbaggedGrid') || strcmp(type,'foil')
        fullBinaryMask = imbinarize(rgb2gray(fullMosaic), 'adaptive','ForegroundPolarity', 'bright', 'Sensitivity', brightnessThreshold);
        fullBinaryMask = imcomplement(fullBinaryMask);
        fullBinaryMask = imopen(fullBinaryMask, strel('disk', 15));
        fullBinaryMask = imfill(fullBinaryMask,'holes');
    else
        fullBinaryMask = imbinarize(rgb2gray(fullMosaic), 'adaptive','ForegroundPolarity', 'bright', 'Sensitivity', brightnessThreshold);
        fullBinaryMask = imopen(fullBinaryMask, strel('disk', 35));
    end
end