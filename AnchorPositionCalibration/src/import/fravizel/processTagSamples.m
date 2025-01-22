function [tagPositions, tagDistances] = processTagSamples(tagTable)
    % Extract unique sample numbers
    uniqueSamples = unique(tagTable.SampleNumber);
    numSamples = length(uniqueSamples);
    
    % Extract unique anchors
    uniqueAnchors = unique(tagTable.AnchorID);
    numAnchors = length(uniqueAnchors);
    
    % Initialize output matrices
    tagPositions = zeros(numSamples, 3); % [x, y, z] for each sample
    tagDistances = zeros(numSamples, numAnchors); % distances for each sample and anchor
    
    % Process each sample
    for i = 1:numSamples
        % Filter data for the current sample
        currentSampleData = tagTable(tagTable.SampleNumber == uniqueSamples(i), :);
        
        % Store estimated tag position (assumed to be constant per sample)
        tagPositions(i, :) = [currentSampleData.EstimatedX(1), ...
                              currentSampleData.EstimatedY(1), ...
                              currentSampleData.EstimatedZ(1)];
                          
        % Store distances to each anchor
        for j = 1:numAnchors
            anchorData = currentSampleData(currentSampleData.AnchorID == uniqueAnchors(j), :);
            if ~isempty(anchorData)
                tagDistances(i, j) = anchorData.Distance;
            else
                tagDistances(i, j) = NaN; % If no data for an anchor, use NaN
            end
        end
    end
end
