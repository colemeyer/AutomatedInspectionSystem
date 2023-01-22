%% mosaicImages

% This function takes a series of images and mosaics them together in one
% high-resolution image.


% Inputs:

% *dirpath* – image directory
% *mosaicLayout* – [imagesInRow, imagesInColumn]
% *spacing* – [horMin, horMax, vertMin, vertMax]
% *angle* – angle used to correct for miscalibration

% Outputs:

% *fullMosaic* – original, full color mosaic


function fullMosaic = mosaicImages(dirpath, mosaicLayout, spacing, angle)

    filenames = organizeImages(dirpath, [mosaicLayout(1), mosaicLayout(2)]);

    imSize = size(imrotate(imread(dirpath + "/" + filenames{(1)}), angle)); % length: imSize(2), width: imSize(1)
    vertImageEdge = imSize(1);
    
    for columnIndex = 1:mosaicLayout(2)
        mosaic = zeros(1,1,3,'uint8'); % create 1 x 1 x 3 array of zeros, type uint8; we'll append to this later
        horImageEdge = imSize(2);
    
        for rowIndex = 1:mosaicLayout(1)
            if rowIndex == 1 % 1
                % If given image is the first in a row, don't worry about averaging
                im = imrotate(imread(dirpath + "/" + filenames{(rowIndex + ((columnIndex - 1) * mosaicLayout(1)))}), angle);
                mosaic(1:imSize(1), 1:imSize(2), :) = im(:, :, :); % input first image
            else
                % Read image
                im = imrotate(imread(dirpath + "/" + filenames{(rowIndex + ((columnIndex - 1) * mosaicLayout(1)))}), angle);
    
                % Since we have uncertainties in the x-stepper, we'll fit the
                % x-position of the second image below for the best alignment
                differenceValues = zeros(1, 20, 'double');
                for trialNum = 1:20
                    % horOffset will shift for each iteration
                    horOffset = round(spacing(1) + (trialNum * ((spacing(2) - spacing(1)) / 20)));
    
                    % differenceArray represents the difference between the two overlapping images
                    differenceArray = abs(rgb2gray(mosaic(1:imSize(1), (horImageEdge - horOffset + 1):horImageEdge, :)) - rgb2gray(im(:, 1:horOffset, :)));
    
                    % lower differenceArray means greater alignment since holes have higher rgb values than background
                    differenceValues(trialNum) = mean(differenceArray, 'all');
                end
                % select minimum differenceValue and set horOffset accordingly
                horOffset = round(spacing(1) + find(differenceValues == min(differenceValues)) * ((spacing(2) - spacing(1)) / 20));
    
                % input overlapping section
                mosaic(1:imSize(1), (horImageEdge - horOffset + 1):horImageEdge, :) = (mosaic(1:imSize(1), (horImageEdge - horOffset + 1):horImageEdge, :) + im(:, 1:horOffset, :)) / 2; % / 2
                
                % input non-overlapping right segment of new image
                mosaic(1:imSize(1), horImageEdge:(horImageEdge + (imSize(2) - horOffset)), :) = im(:, horOffset:end, :);
    
                % update horImageEdge parameter
                horImageEdge = horImageEdge + (imSize(2) - horOffset);
            end
        end
        
        % If a given row is the first, don't worry about averaging
        if columnIndex == 1
            fullMosaic = zeros(35000, 55000, 3, 'uint8');
            tempSize = size(mosaic);
            fullMosaic(1:tempSize(1), 1:tempSize(2), :) = mosaic;
        else
            fullSize = size(fullMosaic);
            partialSize = size(mosaic);
            minWidth = min(fullSize(2),partialSize(2));
    
            % Since we have uncertainties in the y-stepper, we'll fit the
            % y-position of the next row for the best alignment
            differenceValues = zeros(1, 20, 'double');
            for trialNum = 1:20
                % vertOffset will shift for each iteration
                vertOffset = round(spacing(3) + (trialNum * ((spacing(4) - spacing(3)) / 20)));
    
                % differenceArray represents the difference between the two overlapping images
                differenceArray = abs(rgb2gray(fullMosaic((vertImageEdge - vertOffset + 1):vertImageEdge, 1:minWidth, :)) - rgb2gray(mosaic(1:vertOffset, 1:minWidth, :)));
    
                % lower differenceArray means greater alignment since holes have higher rgb values than background
                differenceValues(trialNum) = mean(differenceArray, 'all');
            end
            % select minimum differenceValue and set vertOffset accordingly
            vertOffset = round(spacing(3) + (find(differenceValues == min(differenceValues)) * ((spacing(4) - spacing(3)) / 20)));
    
            % input overlapping section
            fullMosaic((vertImageEdge - vertOffset + 1):vertImageEdge, 1:minWidth, :) = (fullMosaic((vertImageEdge - vertOffset + 1):vertImageEdge, 1:minWidth, :) + mosaic(1:vertOffset, 1:minWidth, :)) / 2;
            
            % input non-overlapping right segment of new image
            fullMosaic(vertImageEdge:(vertImageEdge + (imSize(1) - vertOffset)), 1:minWidth, :) = mosaic(vertOffset:end, 1:minWidth, :);
    
            vertImageEdge = vertImageEdge + (imSize(1) - vertOffset);
        end
    end
    fullMosaic = fullMosaic(1:vertImageEdge, 1:horImageEdge, :);
end