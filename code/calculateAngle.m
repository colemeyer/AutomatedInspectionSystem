%% calculateAngle

% This function applies a radon transform to the binary mask
% representing "good holes" to acquire the angle of rotation needed to
% square the orientation of the full color mosaic.


% Inputs:

% *goodBinaryMask* – binary mask representing "good holes"

% Outputs:

% *angle* – angle of rotation needed to correct for full color mosaic's
% orientation


function angle = calculateAngle(goodBinaryMask)
    % Apply radon transform
    theta = 0:180;
    [R, ~] = radon(goodBinaryMask, theta);
    
    % Calculate peak of radon transform
    maxR = max(R(:));
    [~, columnOfMax] = find(R == maxR);
    
    % Return angle
    angle = -(theta(columnOfMax) - 90);
end