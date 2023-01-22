%% identifyBlockedHoles

% This function identifies all large and small holes, checks for small
% holes within the radii of the large holes, and returns a list of large
% holes that do not have corresponding small holes. 


% Inputs:

% *smallHoleMask* – binary mask representing small holes
% *goodBinaryMask* – binary mask representing good holes
% *angle* – angle of rotation that squares mosaic against field of view

% Outputs:

% *badLargeCentroids* – array of large holes which do not have
% corresponding small holes
% *percentEffective* – percentage of large holes which have a corresponding
% small hole


function [centroidOffsets, badLargeCentroids, percentEffective] = identifyBlockedHoles(smallHoleMask, goodBinaryMask, angle)
    smallHoleMask = imrotate(smallHoleMask, angle);
    goodBinaryMask = imrotate(goodBinaryMask, angle);

    % Identify small holes
    [B, L] = bwboundaries(smallHoleMask, 'noholes');
    stats = regionprops(L, 'Area', 'Centroid');
    smallCentroids = zeros(length(B), 3); % three dimensions: (x, y, radius)
    for j = 1:length(B) % fill in x- and y-values
        smallCentroids(j, 1) = stats(j).Centroid(1);
        smallCentroids(j, 2) = stats(j).Centroid(2);
    end
    smallCentroids(:, 3) = ([stats.Area] / 3.14159).^0.5; % calculate radius
    
    % Identify large holes
    [B, L] = bwboundaries(goodBinaryMask, 'noholes');
    stats = regionprops(L, 'Area', 'Centroid');
    largeCentroids = zeros(length(B), 3); % three dimensions: (x, y, radius)
    for j = 1:length(B) % fill in x- and y-values
        largeCentroids(j, 1) = stats(j).Centroid(1);
        largeCentroids(j, 2) = stats(j).Centroid(2);
    end
    largeCentroids(:, 3) = ([stats.Area] / 3.14159).^0.5; % calculate radius


    largeCentroidsSize = size(largeCentroids(:,1));
    smallCentroidsSize = size(smallCentroids(:,1));
    
    % If a given large hole has a corresponding small hole, add them to the
    % good hole list
    goodLargeCentroids = [];
    goodSmallCentroids = [];
    for j = 1:largeCentroidsSize
        withinHoleIndex = 1;
        tempCentroids = zeros(1, 3, 'double');
        for k = 1:smallCentroidsSize
            if ((largeCentroids(j, 1) - smallCentroids(k, 1))^2 + (largeCentroids(j, 2) - smallCentroids(k, 2))^2)^0.5 < largeCentroids(j, 3)
                tempCentroids(withinHoleIndex, :) = smallCentroids(k, :);
    
                withinHoleIndex = withinHoleIndex + 1;
            end
        end
        if withinHoleIndex > 1
            goodLargeCentroids(end + 1, 1:3) = largeCentroids(j, :);
            goodSmallCentroids(end + 1, 1:3) = [mean(tempCentroids(:, 1), 'all'), mean(tempCentroids(:, 2), 'all'), mean(tempCentroids(:, 3), 'all')];
        end
    end
    
    % Using generated list, compile another list of blocked holes
    badLargeCentroids = [];
    for j = 1:largeCentroidsSize
        hasSmallHole = false;
        for k = 1:size(goodLargeCentroids(:, 1))
            if largeCentroids(j, :) == goodLargeCentroids(k, :)
                hasSmallHole = true;
            end
        end
    
        if hasSmallHole == false
            badLargeCentroids(end + 1, 1:3) = largeCentroids(j, :);
        end 
    end

    % Calculated percentage of holes that are effective
    sizeOne = size(goodLargeCentroids(:, 1));
    sizeTwo = size(largeCentroids(:, 1));
    percentEffective = round(100 * (sizeOne(1) / sizeTwo(1)), 2);

    offsets = zeros(size(goodLargeCentroids(:, 1)), 'double');
    
    for k = 1:size(goodLargeCentroids(:,1))
        radius = ((goodLargeCentroids(k, 1) - goodSmallCentroids(k, 1))^2 + (goodLargeCentroids(k, 2) - goodSmallCentroids(k, 2))^2)^0.5;
    
        offsets(k) = radius / goodLargeCentroids(k, 3);
    end
    
    centroidOffsets = double([goodLargeCentroids(:, 1:2), offsets]);

end