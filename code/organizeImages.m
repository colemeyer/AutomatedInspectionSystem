%% organizeImages

% This function compliles a list of filenames in the proper order.


% Inputs:

% *dirpath* – image directory
% *mosaicLayout* – [imagesInRow, imagesInColumn]

% Outputs:

% *filenames* – list of file names in proper order


function filenames = organizeImages(dirpath, mosaicLayout)
    directory = dir(dirpath);
    
    tempnames = {directory.name};
    tempSize = size(tempnames);
    
    % Identify images within directory
    count = 0;
    filenames = tempnames;
    for k = 1:tempSize(2)
        name = tempnames{k};
    
        if name(1) == '2'
            filenames{count + 1} = tempnames{k};
            count = count + 1;
        end
    end
    tempnames = filenames(1:(count));
    
    [tempnames, ~] = sort(tempnames); % sort by numerical value
    tempnames = tempnames((end - (mosaicLayout(1) * mosaicLayout(2)) + 1):end); % remove extra files (e.g., ".", "..", ".DS_Store", etc.)
    
    % Rearrange to more convenient order
    filenames = tempnames;
    filenameSize = size(filenames);
    for k = 0:(mosaicLayout(2) - 1)
        filenames((filenameSize(2) - mosaicLayout(1) * (k + 1) + 1):(filenameSize(2) - mosaicLayout(1) * k)) = tempnames((1 + mosaicLayout(1) * k):(mosaicLayout(1) * (k + 1)));
    end
end