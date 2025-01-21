function completeTagDistances(inputAnchorsFile, inputTagSamplesFile, outputTagSamplesFile)
    % Inputs:
    % - inputAnchorsFile: Path to the anchors CSV file
    % - inputTagSamplesFile: Path to the tag samples CSV file
    % - outputTagSamplesFile: Path for the output tag samples CSV file
    %
    % The output file will include:
    % - All original tag sample data
    % - Missing anchor-tag distances
    % - Estimated tag positions (X, Y, Z) for each timestamp

    % Read anchors and tag samples
    anchors = readtable(inputAnchorsFile);
    tagSamples = readtable(inputTagSamplesFile);

    % Extract unique timestamps
    uniqueTimestamps = unique(tagSamples.Timestamp);
    numTimestamps = length(uniqueTimestamps);

    % Initialize new data structure for output
    outputData = tagSamples; % Start with existing data
    outputData.EstimatedX = nan(height(outputData), 1); % Column for estimated X
    outputData.EstimatedY = nan(height(outputData), 1); % Column for estimated Y
    outputData.EstimatedZ = nan(height(outputData), 1); % Column for estimated Z

    % Loop through each timestamp
    for tIdx = 1:numTimestamps
        % Get data for the current timestamp
        currentTimestamp = uniqueTimestamps(tIdx);
        currentSamples = tagSamples(tagSamples.Timestamp == currentTimestamp, :);

        % Known anchors and distances
        knownAnchors = currentSamples.AnchorID; % Anchor IDs
        knownDistances = currentSamples.Distance; % Known distances
        anchorPositions = anchors{ismember(anchors.AnchorID, knownAnchors), 2:4}; % Get positions of known anchors

        % Optimization to estimate tag position
        % Initial guess: centroid of known anchor positions
        initialGuess = mean(anchorPositions, 1);

        % Define the objective function
        objective = @(tagPos) sum((vecnorm(anchorPositions - tagPos, 2, 2) - knownDistances).^2);

        % Bounds (optional): Constrain tag position within a reasonable range
        lb = min(anchors{:, 2:4}) - 10; % Add some buffer
        ub = max(anchors{:, 2:4}) + 10;

        % Solve using fmincon
        options = optimoptions('fmincon', 'Display', 'off', 'Algorithm', 'interior-point');
        [estimatedTagPos, ~] = fmincon(objective, initialGuess, [], [], [], [], lb, ub, [], options);

        % Add estimated position to the output table
        outputData.EstimatedX(outputData.Timestamp == currentTimestamp) = estimatedTagPos(1);
        outputData.EstimatedY(outputData.Timestamp == currentTimestamp) = estimatedTagPos(2);
        outputData.EstimatedZ(outputData.Timestamp == currentTimestamp) = estimatedTagPos(3);

        % Compute missing distances
        allAnchorIDs = anchors.AnchorID; % All possible anchor IDs
        missingAnchors = setdiff(allAnchorIDs, knownAnchors); % Anchors not in current samples

        for missingAnchorID = missingAnchors'
            % Compute the distance to this anchor
            anchorPos = anchors{anchors.AnchorID == missingAnchorID, 2:4};
            distance = norm(anchorPos - estimatedTagPos);

            % Add the missing distance to the output table
            newRow = {currentTimestamp, missingAnchorID, distance, currentSamples.SampleNumber(1), ...
                      estimatedTagPos(1), estimatedTagPos(2), estimatedTagPos(3)};
            outputData = [outputData; newRow]; %#ok<AGROW>
        end
    end

    % Sort the output table by Timestamp, SampleNumber, then AnchorID
    outputData = sortrows(outputData, {'Timestamp', 'SampleNumber', 'AnchorID'});

    % Write the completed output data to the CSV file
    writetable(outputData, outputTagSamplesFile);
    disp('Completed tag samples file written to:');
    disp(outputTagSamplesFile);
end
