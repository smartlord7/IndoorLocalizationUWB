function process_log_file(inputLogFile, anchorsFile, tagSamplesFile)
    % Open the log file for reading
    fid = fopen(inputLogFile, 'r');
    if fid == -1
        error('Unable to open log file: %s', inputLogFile);
    end

    % Initialize data structures
    anchors = {}; % Stores anchor data
    tagSamples = {}; % Stores tag sample data
    anchorIDMap = containers.Map(); % Map to associate the last 4 digits of hex ID with numerical ID

    % Initialize counter for assigning numerical anchor IDs
    currentAnchorID = 1;
    
    % Initialize sample number counter
    sampleCounter = 1;

    % Process the file line by line
    while ~feof(fid)
        line = fgetl(fid);

        % Match anchor lines
        anchorPattern = '0x([A-F0-9]+) initial-position: x=([-0-9]+) y=([-0-9]+) z=([-0-9]+)';
        anchorMatch = regexp(line, anchorPattern, 'tokens');
        if ~isempty(anchorMatch)
            anchorHexID = anchorMatch{1}{1};
            x = str2double(anchorMatch{1}{2});
            y = str2double(anchorMatch{1}{3});
            z = str2double(anchorMatch{1}{4});
            
            % Extract the last 4 digits of the hex anchor ID
            anchorSuffix = anchorHexID(end-3:end);
            
            % Check if this anchor has been encountered before
            if ~isKey(anchorIDMap, anchorSuffix)
                % Assign the next available numerical ID
                anchorIDMap(anchorSuffix) = currentAnchorID;
                currentAnchorID = currentAnchorID + 1; % Increment numerical ID
            end
            
            % Retrieve the numerical anchor ID based on the last 4 hex digits
            anchorID = anchorIDMap(anchorSuffix);

            % Store the anchor data (with the numerical anchor ID)
            anchors{end+1, 1} = anchorID; % Numerical ID
            anchors{end, 2} = x; % X position
            anchors{end, 3} = y; % Y position
            anchors{end, 4} = z; % Z position
            continue;
        end

        % Match tag sample lines
        samplePattern = '([0-9.]+): .*distances: (.+)';
        sampleMatch = regexp(line, samplePattern, 'tokens');
        if ~isempty(sampleMatch)
            timestamp = str2double(sampleMatch{1}{1});
            distancesStr = sampleMatch{1}{2};
            distancePattern = '([A-F0-9]+) distance=Distance{length=([0-9]+), quality=[0-9]+}';
            distanceMatches = regexp(distancesStr, distancePattern, 'tokens');
            
            % Create a temporary table to hold the distances for this timestamp
            tempTagSamples = {};
            
            % Process each distance
            for i = 1:length(distanceMatches)
                anchorHexID = distanceMatches{i}{1};
                distance = str2double(distanceMatches{i}{2});
                
                % Extract the last 4 digits of the hex anchor ID
                anchorSuffix = anchorHexID(end-3:end);
                
                % Retrieve the numerical anchor ID based on the last 4 hex digits
                anchorID = anchorIDMap(anchorSuffix);

                % Store the tag sample with the same timestamp and the incremented sample number
                tempTagSamples{end+1, 1} = timestamp; % Timestamp
                tempTagSamples{end, 2} = anchorID; % Numerical Anchor ID
                tempTagSamples{end, 3} = distance; % Distance
            end
            
            % Sort by anchor ID within the same timestamp
            tempTagSamples = sortrows(tempTagSamples, 2);
            
            % Assign the same sample number for all distances with the same timestamp
            for j = 1:size(tempTagSamples, 1)
                tempTagSamples{j, 4} = sampleCounter; % Sample number
            end
            
            % Add the sorted samples to the main tagSamples list
            tagSamples = [tagSamples; tempTagSamples];
            
            % Increment the sample number counter
            sampleCounter = sampleCounter + 1;
        end
    end

    % Close the file
    fclose(fid);

    % Convert anchors data to table
    anchorTable = cell2table(anchors, 'VariableNames', {'AnchorID', 'X', 'Y', 'Z'});

    % Sort anchors by numerical AnchorID (to maintain order)
    anchorTable = sortrows(anchorTable, 'AnchorID');

    % Save anchors data to CSV
    writetable(anchorTable, anchorsFile);

    % Convert tag samples data to table
    if ~isempty(tagSamples)
        tagSamplesMatrix = cell2mat(tagSamples);
        tagSamplesTable = array2table(tagSamplesMatrix, 'VariableNames', {'Timestamp', 'AnchorID', 'Distance', 'SampleNumber'});
        writetable(tagSamplesTable, tagSamplesFile);
    else
        % Write an empty CSV if no samples exist
        fid = fopen(tagSamplesFile, 'w');
        fprintf(fid, 'Timestamp,AnchorID,Distance,SampleNumber\n');
        fclose(fid);
    end

    disp('Processing complete!');
end
