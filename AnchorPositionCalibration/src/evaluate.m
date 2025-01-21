function evaluate()
% Create a figure for UI
fig = figure('Name', 'Anchor Calibration Simulation', 'Position', [100, 100, 1200, 600]);
disp('UI Figure created.');

% Default Parameters
defaultNumAnchors = 6;
defaultNumSamples = 3000;
defaultAnchorNoise = 1;
defaultDistanceNoise = 0.1;
defaultToaNoise = 1e-10;
defaultRoomDimensions = [10, 10, 10]; % Room dimensions in meters (mx, my, mz)
rng(0);
disp('Default parameters set.');

% UI Controls
uicontrol('Style', 'text', 'Position', [10, 550, 150, 20], 'String', 'Number of Anchors:');
numAnchorsEdit = uicontrol('Style', 'edit', 'Position', [170, 550, 100, 20], 'String', num2str(defaultNumAnchors), 'Callback',  @updateRoomAndAnchors);

uicontrol('Style', 'text', 'Position', [10, 520, 150, 20], 'String', 'Number of Samples:');
numSamplesEdit = uicontrol('Style', 'edit', 'Position', [170, 520, 100, 20], 'String', num2str(defaultNumSamples));

uicontrol('Style', 'text', 'Position', [10, 490, 150, 20], 'String', 'Anchor Noise:');
anchorNoiseEdit = uicontrol('Style', 'edit', 'Position', [170, 490, 100, 20], 'String', num2str(defaultAnchorNoise), 'Callback', @updateRoomAndAnchors);

uicontrol('Style', 'text', 'Position', [10, 460, 150, 20], 'String', 'Distance Noise:');
distanceNoiseEdit = uicontrol('Style', 'edit', 'Position', [170, 460, 100, 20], 'String', num2str(defaultDistanceNoise));

uicontrol('Style', 'text', 'Position', [10, 430, 150, 20], 'String', 'ToA Noise:');
toaNoiseEdit = uicontrol('Style', 'edit', 'Position', [170, 430, 100, 20], 'String', num2str(defaultToaNoise));

% Room dimension controls
uicontrol('Style', 'text', 'Position', [10, 370, 150, 20], 'String', 'Room Dimension X (m):');
roomDimXEdit = uicontrol('Style', 'edit', 'Position', [170, 370, 100, 20], 'String', num2str(defaultRoomDimensions(1)), 'Callback', @updateRoomAndAnchors);

uicontrol('Style', 'text', 'Position', [10, 340, 150, 20], 'String', 'Room Dimension Y (m):');
roomDimYEdit = uicontrol('Style', 'edit', 'Position', [170, 340, 100, 20], 'String', num2str(defaultRoomDimensions(2)), 'Callback', @updateRoomAndAnchors);

uicontrol('Style', 'text', 'Position', [10, 310, 150, 20], 'String', 'Room Dimension Z (m):');
roomDimZEdit = uicontrol('Style', 'edit', 'Position', [170, 310, 100, 20], 'String', num2str(defaultRoomDimensions(3)), 'Callback', @updateRoomAndAnchors);

% Multiselect Listbox for Estimators
estimatorListBox = uicontrol('Style', 'listbox', 'Position', [170, 130, 150, 170], ...
    'String', { 'CALNN+NLS (static)', 'CALNN+NLS (dynamic)', 'NLS (static)', 'NLS (dynamic)', 'MLE', 'EKF', 'LLS', 'WLS', 'IR', 'GA', 'C'}, ...
    'Max', 7, 'Min', 1, 'ButtonDownFcn', @listboxDoubleClick, 'Callback', @updateSelection);

% Store the last click time to detect double-clicks
set(estimatorListBox, 'UserData', struct('LastClickTime', 0));

    function listboxDoubleClick(hObject, ~)
        % Retrieve the last click time
        userData = get(hObject, 'UserData');
        lastClickTime = userData.LastClickTime;

        % Get the current time
        currentTime = now;

        % Calculate the time difference (in seconds)
        timeDifference = (currentTime - lastClickTime) * 24 * 3600; % Convert days to seconds

        % Update the last click time
        userData.LastClickTime = currentTime;
        set(hObject, 'UserData', userData);

        % If the time difference is small enough, it's a double-click
        if timeDifference < 0.5 % Adjust threshold as necessary
            selectedValue = get(hObject, 'Value'); % Get the selected item(s)
            selectedString = hObject.String{selectedValue}; % Get the corresponding string
            %fprintf('Double-clicked on: %s\n', selectedString);

            % Call the update selection function or any other action here
            editEstimatorsParameters(selectedValue, selectedString);
        end
    end

% Checkbox for Inter-anchor distances
uicontrol('Style', 'checkbox', 'Position', [10, 100, 300, 20], 'String', 'Inter-anchor distances available', ...
    'Value', 0, 'Callback', @toggleInterAnchorDistances);

useInterAnchorDistances = false;

    function updateSelection(~, ~)
        % Get selected estimator(s)
        selectedEstimators = estimatorListBox.String(estimatorListBox.Value);
    end

    function toggleInterAnchorDistances(src, ~)
        if src.Value
            disp('Inter-anchor distances enabled');
            useInterAnchorDistances = true;
        else
            disp('Inter-anchor distances disabled');
            useInterAnchorDistances = false;
        end
    end


% Initialize variables to store imported data
anchorsData = [];
tagSamplesData = [];

% Add a button to load anchor data
uicontrol('Style', 'pushbutton', 'Position', [10, 50, 150, 30], 'String', 'Load Anchors Data', ...
    'Callback', @loadAnchorsDataCallback);

% Add a button to load tag samples data
uicontrol('Style', 'pushbutton', 'Position', [10, 20, 150, 30], 'String', 'Load Tag Samples Data', ...
    'Callback', @loadTagSamplesDataCallback);

% Initialize variables to store imported data
anchorsData = [];
tagSamplesData = [];

% Callback function for loading anchor data
    function loadAnchorsDataCallback(~, ~)
        % Prompt user to select the anchor positions CSV file
        [anchorFile, anchorPath] = uigetfile('*.csv', 'Select Anchor Positions CSV');
        if isequal(anchorFile, 0)
            disp('No anchor positions file selected.');
            return;
        end
        % Load the anchor positions from the selected CSV file
        anchorsData = readtable(fullfile(anchorPath, anchorFile));
        disp('Anchor positions loaded.');
        
        % Update the room and anchors plot based on the loaded data
        plotRoomAndAnchors(anchorsData);
    end

% Callback function for loading tag samples data
    function loadTagSamplesDataCallback(~, ~)
        % Prompt user to select the tag samples CSV file
        [tagSampleFile, tagSamplePath] = uigetfile('*.csv', 'Select Tag Samples CSV');
        if isequal(tagSampleFile, 0)
            disp('No tag samples file selected.');
            return;
        end
        % Load the tag samples from the selected CSV file
        tagSamplesData = readtable(fullfile(tagSamplePath, tagSampleFile));
        disp('Tag samples loaded.');
        
        % Optionally, print out the loaded data
        disp(tagSamplesData);
    end

% Function to plot room and anchors based on loaded data
   function plotRoomAndAnchors(anchorsData)
    if isempty(anchorsData)
        disp('No anchor data available to plot.');
        return;
    end

    % Calculate the room dimensions based on the anchor positions
    minX = min(anchorsData.X);
    maxX = max(anchorsData.X);
    minY = min(anchorsData.Y);
    maxY = max(anchorsData.Y);
    minZ = min(anchorsData.Z);
    maxZ = max(anchorsData.Z);
     anchorNoise = str2double(anchorNoiseEdit.String);  % Retrieve anchor noise for uncertainty visualization


    % Clear previous plots
    % Clear the axes and set limits
    cla(ax);
    hold(ax, 'on');
    axis(ax, [-1 - anchorNoise maxX + 1 + anchorNoise -1 - anchorNoise maxY + 1 + anchorNoise -1 - anchorNoise maxZ + 1 + anchorNoise]);
    xlabel(ax, 'X (m)');
    ylabel(ax, 'Y (m)');
    zlabel(ax, 'Z (m)');
    grid(ax, 'on');
    view(ax, 3);
    axis(ax, 'equal');
    % Define the room size to fit all anchors with some margin
    margin = 1;  % Margin in meters to add around the anchors
    roomDims = [maxX - minX + 2 * margin, maxY - minY + 2 * margin, maxZ - minZ + 2 * margin];

    % Update the room boundaries (make sure they fit all the anchors)
    % Room bounds will be from min to max with a margin
    xlim([minX - margin, maxX + margin]);
    ylim([minY - margin, maxY + margin]);
    zlim([minZ - margin, maxZ + margin]);
   
    
    % Plot anchors as spheres with Gouraud lighting
    [sx, sy, sz] = sphere(20);  % Sphere for anchor representation
    for i = 1:height(anchorsData)
        x = anchorsData.X(i);
        y = anchorsData.Y(i);
        z = anchorsData.Z(i);

         % Plot the main anchor as a solid sphere
        surf(ax, x + 0.2*sx, y + 0.2*sy, z + 0.2*sz, ...
            'FaceColor', 'r', 'EdgeColor', 'none', 'FaceLighting', 'gouraud');

        % Generate points for 3D Gaussian cloud around the anchor
        numCloudPoints = 500;  % Number of points in the Gaussian cloud
        cloudPoints = mvnrnd([x, y, z], (anchorNoise^2) * eye(3), numCloudPoints);

        % Plot the Gaussian-distributed cloud points
        scatter3(ax, cloudPoints(:, 1), cloudPoints(:, 2), cloudPoints(:, 3), ...
            10, 'MarkerFaceColor', [0.5, 0.5, 1], 'MarkerEdgeColor', 'none', ...
            'MarkerFaceAlpha', 0.3);  % Semi-transparent points
    end
    
    % Labeling
    xlabel(ax, 'X (m)');
    ylabel(ax, 'Y (m)');
    zlabel(ax, 'Z (m)');
    title(ax, 'Room with Anchors and Gaussian Clouds');
end


% Selected estimators list
selectedEstimators = {'NLS (dynamic)', 'MLE', 'EKF', 'LLS', 'WLS', 'IR', 'GA', 'CALNN+NLS (static)', 'CALNN+NLS (dynamic)', 'C'};

    function initializeEstimatorParameters()
        % Initialize a struct with default parameters for each estimator
        global parametersStruct;
        parametersStruct = struct( ...
            'CALNN_NLS_static', struct(), ...
            'CALNN_NLS_dynamic', struct('Memory', 30, 'ReuseEstimates', true), ...
            'NLS_static', struct(), ...
            'NLS_dynamic', struct('Memory', 30), ...
            'MLE', struct(), ...
            'EKF', struct(), ...
            'LLS', struct(), ...
            'WLS', struct(), ...
            'IR', struct(), ...
            'GA', struct(), ...
            'C', struct());
    end

initializeEstimatorParameters();

    function editEstimatorsParameters(~, ~)

        global parametersStruct;

        % Create a new figure for parameter settings
        paramWindow = figure('Name', 'Estimator Parameters', 'Position', [500, 300, 300, 300]);

        % Loop through the selected estimators and create relevant
        % parameter fields
        % Loop through selected estimators to create UI elements
    for idx = 1:length(selectedEstimators)
        estimator = selectedEstimators{idx};
        switch estimator
            case 'CALNN+NLS (static)'
                uicontrol('Style', 'text', 'Position', [10, 250, 200, 20], ...
                    'String', 'No additional parameters');

            case 'CALNN+NLS (dynamic)'
                % Define Memory field
                uicontrol('Style', 'text', 'Position', [10, 250, 200, 20], 'String', 'Define Memory:');
                uicontrol('Style', 'edit', 'Position', [10, 220, 100, 25], ...
                    'String', num2str(parametersStruct.CALNN_NLS_dynamic.Memory), 'Tag', 'MemoryField');

                % Reuse previous estimates checkbox
                uicontrol('Style', 'checkbox', 'Position', [10, 190, 200, 20], ...
                    'String', 'Reuse previous estimates', ...
                    'Value', parametersStruct.CALNN_NLS_dynamic.ReuseEstimates, 'Tag', 'ReuseEstimatesCheckbox');

            case 'NLS (static)'
                uicontrol('Style', 'text', 'Position', [10, 250, 200, 20], ...
                    'String', 'No additional parameters');

            case 'NLS (dynamic)'
                % Define Memory field
                uicontrol('Style', 'text', 'Position', [10, 250, 200, 20], 'String', 'Define Memory:');
                uicontrol('Style', 'edit', 'Position', [10, 220, 100, 25], ...
                    'String', num2str(parametersStruct.NLS_dynamic.Memory), 'Tag', 'MemoryField');

            case 'MLE'
                uicontrol('Style', 'text', 'Position', [10, 250, 200, 20], ...
                    'String', 'No additional parameters');

            case 'EKF'
                uicontrol('Style', 'text', 'Position', [10, 250, 200, 20], ...
                    'String', 'No additional parameters');

            case 'LLS'
                uicontrol('Style', 'text', 'Position', [10, 250, 200, 20], ...
                    'String', 'No additional parameters');

            case 'WLS'
                uicontrol('Style', 'text', 'Position', [10, 250, 200, 20], ...
                    'String', 'No additional parameters');

            case 'IR'
                uicontrol('Style', 'text', 'Position', [10, 250, 200, 20], ...
                    'String', 'No additional parameters');

            case 'GA'
                uicontrol('Style', 'text', 'Position', [10, 250, 200, 20], ...
                    'String', 'No additional parameters');

            case 'C'
                uicontrol('Style', 'text', 'Position', [10, 250, 200, 20], ...
                    'String', 'No additional parameters');
        end
    end

        % Add a button to save parameters
        uicontrol('Style', 'pushbutton', 'Position', [100, 10, 100, 40], 'String', 'Save Parameters', 'Callback', @saveParameters);
    end

    function saveParameters(~, ~)
        global parametersStruct;

        % Retrieve the Memory value
        memoryField = findobj('Tag', 'MemoryField');
        if ~isempty(memoryField)
            memoryValue = str2double(get(memoryField, 'String'));
        else
            memoryValue = []; % Default if not defined
        end

        % Retrieve the Reuse Estimates checkbox value
        reuseCheckbox = findobj('Tag', 'ReuseEstimatesCheckbox');
        if ~isempty(reuseCheckbox)
            reuseValue = get(reuseCheckbox, 'Value');
        else
            reuseValue = []; % Default if not defined
        end

        % Example for updating specific estimator's parameters
        if ~isempty(memoryValue)
            parametersStruct.CALNN_NLS_dynamic.Memory = memoryValue;
        end
        if ~isempty(reuseValue)
            parametersStruct.CALNN_NLS_dynamic.ReuseEstimates = reuseValue;
        end

        % Example for NLS Dynamic
        if ~isempty(memoryValue)
            parametersStruct.NLS_dynamic.Memory = memoryValue;
        end

        % Confirm saving
        disp('Parameters updated:');
        disp(parametersStruct);
    end
% Axes for the 3D room and anchors plot
ax = axes('Parent', fig, 'Position', [0.4, 0.2, 0.55, 0.75]);
plotRoomAndAnchors2([]);  % Initial plot of the room and anchors

% Run Simulation button
uicontrol('Style', 'pushbutton', 'Position', [10, 150, 150, 30], 'String', 'Run Simulation', ...
    'Callback', @(~, ~) runSimulation());

% Callback to update room and anchors
    function updateRoomAndAnchors(~, ~)
        plotRoomAndAnchors2([]);
    end

    function plotRoomAndAnchors2(tagPositions)
        % Get the room dimensions and number of anchors
        mx = str2double(roomDimXEdit.String);
        my = str2double(roomDimYEdit.String);
        mz = str2double(roomDimZEdit.String);
        numAnchors = str2double(numAnchorsEdit.String);
        anchorNoise = str2double(anchorNoiseEdit.String);  % Retrieve anchor noise for uncertainty visualization

        % Generate anchor positions randomly within the room dimensions
        anchorPositions = generateAnchors([mx, my, mz], numAnchors);

        % Clear the axes and set limits
        cla(ax);
        hold(ax, 'on');
        axis(ax, [-1 - anchorNoise mx + 1 + anchorNoise -1 - anchorNoise my + 1 + anchorNoise -1 - anchorNoise mz + 1 + anchorNoise]);
        xlabel(ax, 'X (m)');
        ylabel(ax, 'Y (m)');
        zlabel(ax, 'Z (m)');
        grid(ax, 'on');
        view(ax, 3);

        % Define a semi-transparent color for the cube's edges
        transparentGray = [0 0 0 0.3];  % RGB with 0.3 alpha for transparency

        % Draw the room as a wireframe cube Bottom face
        plot3(ax, [0 mx mx 0 0], [0 0 my my 0], [0 0 0 0 0], 'Color', transparentGray);
        % Top face
        plot3(ax, [0 mx mx 0 0], [0 0 my my 0], [mz mz mz mz mz], 'Color', transparentGray);
        % Vertical edges connecting top and bottom faces
        plot3(ax, [0 0], [0 0], [0 mz], 'Color', transparentGray);
        plot3(ax, [mx mx], [0 0], [0 mz], 'Color', transparentGray);
        plot3(ax, [0 0], [my my], [0 mz], 'Color', transparentGray);
        plot3(ax, [mx mx], [my my], [0 mz], 'Color', transparentGray);

        % Plot anchors as spheres with Gouraud lighting
        [sx, sy, sz] = sphere(20);  % Sphere for anchor representation
        for i = 1:numAnchors
            x = anchorPositions(i, 1);
            y = anchorPositions(i, 2);
            z = anchorPositions(i, 3);

            % Plot the main anchor as a solid sphere
            surf(ax, x + 0.2*sx, y + 0.2*sy, z + 0.2*sz, ...
                'FaceColor', 'r', 'EdgeColor', 'none', 'FaceLighting', 'gouraud');

            % Generate points for 3D Gaussian cloud around the anchor
            numCloudPoints = 500;  % Number of points in the Gaussian cloud
            cloudPoints = mvnrnd([x, y, z], (anchorNoise^2) * eye(3), numCloudPoints);

            % Plot the Gaussian-distributed cloud points
            scatter3(ax, cloudPoints(:, 1), cloudPoints(:, 2), cloudPoints(:, 3), ...
                10, 'MarkerFaceColor', [0.5, 0.5, 1], 'MarkerEdgeColor', 'none', ...
                'MarkerFaceAlpha', 0.3);  % Semi-transparent points
        end

        % Check if tagPositionsMoving exists and plot it
        if ~isempty(tagPositions)
            plot3(ax, tagPositions(:, 1), tagPositions(:, 2), tagPositions(:, 3), ...
                '-o', 'Color', [0, 0.5, 1], 'MarkerSize', 5, 'MarkerFaceColor', [0, 0.5, 1]);
        end

        % Add a light to enhance the 3D effect
        camlight(ax, 'headlight');
        hold(ax, 'off');
    end


% Function to Run Simulation
    function runSimulation()
        disp('Running simulation...');
        numAnchors = str2double(numAnchorsEdit.String);
        numSamples = str2double(numSamplesEdit.String);
        anchorNoise = str2double(anchorNoiseEdit.String);
        distanceNoise = str2double(distanceNoiseEdit.String);
        toaNoise = str2double(toaNoiseEdit.String);
        numTopologies = 1;

        % Room dimensions
        mx = str2double(roomDimXEdit.String);
        my = str2double(roomDimYEdit.String);
        mz = str2double(roomDimZEdit.String);
        roomDimensions = [0, mx; 0, my; 0, mz];

        bounds = buildBounds(roomDimensions, numAnchors);
        disp('Bounds built for anchor positions.');

        % Generate random tag positions along a path
        tagPositionsMoving = generateEquallySpacedPath(numSamples, roomDimensions);
        disp('Generated random path for moving tag.');

        if isempty(tagSamplesData)
            plotRoomAndAnchors2(tagPositionsMoving);
        end

        pause(1);

        % Static tag at a fixed position
        tagPositionsStatic = repmat([mx/2, my/2, mz/2], numSamples, 1);
        disp('Static tag positions generated.');

        % Prepare CSV files to store results
        csvFileAnchor = fopen('../data/anchor_errors.csv', 'w');
        csvFileTag = fopen('../data/tag_errors.csv', 'w');
        disp('CSV files prepared for results.');

        % Headers
        fprintf(csvFileAnchor, 'Estimator,Scenario,Topology,Anchor,Sample,Error\n');
        fprintf(csvFileTag, 'Estimator,Scenario,Topology,Sample,Error\n');

        % Generate true anchor positions
        if isempty(anchorsData)
            trueAnchors = generateAnchors(roomDimensions, numAnchors);
            disp('True anchor positions generated.');
        else
            trueAnchors = [anchorsData.X, anchorsData.Y, anchorsData.Z];
            numAnchors = size(trueAnchors, 1);
            % Extract min and max values from the anchors data
            minX = min(anchorsData.X);  % Minimum x-coordinate
            maxX = max(anchorsData.X);  % Maximum x-coordinate
            minY = min(anchorsData.Y);  % Minimum y-coordinate
            maxY = max(anchorsData.Y);  % Maximum y-coordinate
            minZ = min(anchorsData.Z);  % Minimum z-coordinate
            maxZ = max(anchorsData.Z);  % Maximum z-coordinate
            
            % Define the roomDimensions matrix with appropriate min and max values
            roomDimensions = [minX, maxX;  % x-dimension: min and max
                  minY, maxY;  % y-dimension: min and max
                  minZ, maxZ]; % z-dimension: min and max
            bounds = buildBounds(roomDimensions, numAnchors);
        end



        if useInterAnchorDistances
            % Precompute true inter-anchor distances
            true_inter_anchor_distances = zeros(numAnchors, numAnchors);
            for i = 1:numAnchors-1
                for j = i+1:numAnchors
                    true_inter_anchor_distances(i, j) = norm(trueAnchors(i, :) - trueAnchors(j, :));
                end
            end
        else
            true_inter_anchor_distances = [];
        end

        % Add Gaussian noise to anchor positions for initial guess
        initialAnchors = trueAnchors + anchorNoise * randn(size(trueAnchors));
        disp('Initial anchor positions with noise generated.');
        net = {};

        

        % Loop over each selected estimator
        for i = 1:length(selectedEstimators)
            estName = selectedEstimators{i};
            disp(['Simulating for estimator: ', estName]);

            % Scenario 1: Static Tag
            rmseStatic = simulateCalibration(numTopologies, trueAnchors, initialAnchors, tagPositionsStatic, estName, numAnchors, distanceNoise, true_inter_anchor_distances, anchorNoise, toaNoise, numSamples, bounds);
            plotAndSaveResults(rmseStatic, estName, 'Static');
            disp(['Static scenario RMSE calculated for estimator: ', estName]);

            % Scenario 2: Moving Tag
            rmseMoving = simulateCalibration(numTopologies, trueAnchors, initialAnchors, tagPositionsMoving, estName, numAnchors, distanceNoise, true_inter_anchor_distances, anchorNoise, toaNoise, numSamples, bounds);
            plotAndSaveResults(rmseMoving, estName, 'Moving');
            disp(['Moving scenario RMSE calculated for estimator: ', estName]);

            % Save errors to CSV
            saveErrorsToCSV(rmseStatic, estName, 'Static', csvFileAnchor, csvFileTag);
            saveErrorsToCSV(rmseMoving, estName, 'Moving', csvFileAnchor, csvFileTag);
            disp(['Errors saved to CSV for estimator: ', estName]);
        end

        % Close CSV files
        fclose(csvFileAnchor);
        fclose(csvFileTag);
        disp('CSV files closed.');

        % Compute statistics and perform tests
        analyzeResults('../data/anchor_errors.csv', '../data/tag_errors.csv', selectedEstimators);
        disp('Analysis of results completed.');
    end


% Function to simulate calibration
    function rmse = simulateCalibration(numTopologies, trueAnchors, initialAnchors, tagPositions, estimator, numAnchors, distanceNoise, true_inter_anchor_distances, anchorNoise, toaNoise, numSamples, bounds)
        global parametersStruct;
        % Initialize matrix to accumulate RMSE
        rmse = zeros(numAnchors + 1, numSamples, numTopologies);
        % Initialize storage for noisy distances
        noisyDistancesHistory = [];
        disp(['Simulating calibration for estimator: ', estimator]);

        % Perform calibration and compute RMSE
        for sample = 1:numSamples
            disp(['Processing sample: ', num2str(sample)]);
            % Current tag position
            currentTagPos = tagPositions(sample, :);

            % Simulate distances with noise for the current tag position
            trueDistances = sqrt(sum((trueAnchors - currentTagPos).^2, 2));
            noisyDistances = trueDistances + randn(size(trueDistances)) * distanceNoise;
            % Append the current noisy distances to the history
            noisyDistancesHistory = [noisyDistancesHistory; noisyDistances'];

            estimatedAnchors = [];

            estimatedTagPos = trilateration(trueAnchors, trueAnchors, currentTagPos, 1000, toaNoise, distanceNoise);
            rmse(numAnchors + 1, sample, 1) = sqrt(mean(((estimatedTagPos - currentTagPos).^2), 2));
            tagPos = tagPositions(1:sample, :);

            % Estimate anchor positions based on the noisy distances
            switch estimator
                case 'NLS (static)'
                    estimatedAnchors = nonlinearLeastSquares(noisyDistances, true_inter_anchor_distances, initialAnchors, estimatedTagPos, bounds, false);
                case 'NLS (dynamic)'
                    estimatedAnchors = nonlinearLeastSquares(noisyDistancesHistory, true_inter_anchor_distances, initialAnchors, tagPos, bounds, true);
                case 'MLE'
                    estimatedAnchors = maximumLikelihoodEstimation(noisyDistances, initialAnchors, estimatedTagPos);
                case 'EKF'
                    estimatedAnchors = extendedKalmanFilter(noisyDistances, anchorNoise, distanceNoise, initialAnchors, estimatedTagPos);
                case 'LLS'
                    estimatedAnchors = linearLeastSquares(noisyDistances, initialAnchors, estimatedTagPos);
                case 'WLS'
                    estimatedAnchors = nonLinearWeightedLeastSquares(noisyDistances, initialAnchors, estimatedTagPos);
                case 'IR'
                    estimatedAnchors = iterativeRefinement(noisyDistances, initialAnchors, estimatedTagPos);
                case 'GA'
                    estimatedAnchors = geneticAlgorithm(noisyDistances, initialAnchors, estimatedTagPos, bounds, true_inter_anchor_distances);
                case 'CALNN+NLS (dynamic)'

                    memory = parametersStruct.CALNN_NLS_dynamic.Memory;
                    noisyDistancesHistory_ = noisyDistancesHistory;

                    if sample > memory
                        tagPos = tagPositions(sample - memory + 1:sample, :);
                        noisyDistancesHistory_ = noisyDistancesHistory(sample - memory + 1:sample, :);
                    end
                    %testData = cat(2, noisyDistances', estimatedTagPos);
                    %testData = cat(2, testData, reshape(initialAnchors',
                    %1, [])); % Transpose and flatten); [testData, ps] =
                    %mapminmax('apply', testData', ps);

                    %estimatedAnchors = net(testData); estimatedAnchors =
                    %reshape(estimatedAnchors, size(initialAnchors, 1), 3);
                    estimatedAnchors = callibrate(numAnchors, initialAnchors, noisyDistances, true_inter_anchor_distances, estimatedTagPos, anchorNoise, bounds, noisyDistancesHistory_, tagPos, true);

                    if  parametersStruct.CALNN_NLS_dynamic.ReuseEstimates
                        initialAnchors = estimatedAnchors;
                    end
                case 'CALNN+NLS (static)'
                    %testData = cat(2, noisyDistances', estimatedTagPos);
                    %testData = cat(2, testData, reshape(initialAnchors',
                    %1, [])); % Transpose and flatten); [testData, ps] =
                    %mapminmax('apply', testData', ps);

                    %estimatedAnchors = net(testData); estimatedAnchors =
                    %reshape(estimatedAnchors, size(initialAnchors, 1), 3);
                    estimatedAnchors = callibrate(numAnchors, initialAnchors, noisyDistances, true_inter_anchor_distances, estimatedTagPos, anchorNoise, bounds, [], estimatedTagPos, false);
                case 'C'
                    estimatedAnchors = control(initialAnchors);
                otherwise
                    error('Unknown estimator: %s', estimator);
            end

            % Compute RMSE for the current topology
            rmse(1:numAnchors, sample, 1) = sqrt(mean(((estimatedAnchors - trueAnchors).^2), 2));
        end

        % Compute average RMSE over all samples and topologies
        disp(['RMSE calculated for estimator: ', estimator]);
    end

% Function to save errors to CSV
    function saveErrorsToCSV(error, estimator, scenario, csvFileAnchor, csvFileTag)
        [numAnchors, numSamples, numTopologies, ~] = size(error);

        % Save anchor errors
        for t = 1:numTopologies
            for sample = 1:numSamples
                for anchorIdx = 1:numAnchors-1
                    fprintf(csvFileAnchor, '%s,%s,%d,%d,%d,%.6f\n', estimator, scenario, t, anchorIdx, sample, error(anchorIdx, sample, t));
                end
            end
        end

        % Save tag errors
        for t = 1:numTopologies
            for sample = 1:numSamples
                fprintf(csvFileTag, '%s,%s,%d,%d,%.6f\n', estimator, scenario, t, sample, error(numAnchors, sample, t));
            end
        end
    end

    function analyzeResults(anchorErrorCSV, tagErrorCSV, estimators)
        % Load the data
        anchorErrors = readtable(anchorErrorCSV);
        tagErrors = readtable(tagErrorCSV);

        % Separate scenarios for anchor errors
        staticAnchorErrors = anchorErrors(strcmp(anchorErrors.Scenario, 'Static'), :);
        movingAnchorErrors = anchorErrors(strcmp(anchorErrors.Scenario, 'Moving'), :);

        % Separate scenarios for tag errors staticTagErrors =
        % tagErrors(strcmp(tagErrors.Scenario, 'Static'), :);
        % movingTagErrors = tagErrors(strcmp(tagErrors.Scenario, 'Moving'),
        % :);

        % Analyze each scenario and subgroup
        analyzeSubgroup(staticAnchorErrors, estimators, 'Static', 'Anchor');
        analyzeSubgroup(movingAnchorErrors, estimators, 'Moving', 'Anchor');
        % analyzeSubgroup(staticTagErrors, estimators, 'Static', 'Tag');
        % analyzeSubgroup(movingTagErrors, estimators, 'Moving', 'Tag');
    end

    function analyzeSubgroup(errorsTable, estimators, scenario, errorType)
        % Compute mean errors
        meanErrors = varfun(@mean, errorsTable, 'InputVariables', 'Error', ...
            'GroupingVariables', {'Estimator', 'Topology', 'Sample'});

        meanErrors = varfun(@mean, meanErrors, 'InputVariables', 'mean_Error', ...
            'GroupingVariables', {'Estimator', 'Sample'});

        if checkParametricAssumptions(estimators, meanErrors)
            % ANOVA and multiple comparisons
            [~, ~, stats] = anova1(meanErrors.mean_mean_Error, meanErrors.Estimator, 'off');
        else
            % Kruskal-Wallis and multiple comparisons
            [~, ~, stats] = kruskalwallis(meanErrors.mean_mean_Error, meanErrors.Estimator, 'off');
        end

        results = multcompare(stats, 'CType', 'bonferroni', 'Display', 'off');

        pValuesMatrix = buildPValueMatrix(estimators, results);

        % Plot heatmap of p-values
        figure('Position', get(0, 'Screensize'));
        heatmap(estimators, estimators, pValuesMatrix, 'Colormap', parula, 'ColorLimits', [0, 1]);
        title(sprintf('Heatmap of P-values for %s %s Estimators', scenario, errorType));
        xlabel('Estimator');
        ylabel('Estimator');
        set(gca, 'FontSize', 12); % Increase font size for axes
        saveas(gcf, sprintf('../img/%s_%s_Estimator_PValue_Heatmap.png', scenario, errorType));


        % Plot box plot for mean errors with log-scaled y-axis
        figure('Position', get(0, 'Screensize'));
        boxplot(meanErrors.mean_mean_Error, meanErrors.Estimator);
        title(sprintf('Mean %s Error for Each Estimator (%s Scenario)', errorType, scenario));
        xlabel('Estimator');
        ylabel('Mean Error (Log Scale)');
        set(gca, 'FontSize', 12); % Increase font size for axes

        % Set y-axis to logarithmic scale
        set(gca, 'YScale', 'log');

        % Save the figure
        saveas(gcf, sprintf('../img/Mean_%s_Error_BoxPlot_LogScale_%s.png', errorType, scenario));

        confidenceAnalysis(estimators, meanErrors, errorType, scenario);

        grouped = sortrows(varfun(@mean, meanErrors, 'InputVariables', 'mean_mean_Error', ...
            'GroupingVariables', {'Estimator'}));
        % Ranking of estimators based on mean errors
        [~, rank] = sortrows(grouped.mean_mean_mean_Error, 'ascend');

        fprintf('Ranking for %s Calibration in %s Scenario:\n', errorType, scenario);
        disp(grouped.Estimator(rank));
    end

% Function to plot and save results
    function plotAndSaveResults(rmseData, estimator, scenario)
        % Extract dimensions
        [numAnchors, ~] = size(rmseData);

        % Plot RMSE evolution for each anchor
        figure('Position', get(0, 'Screensize'));
        for anchor = 1:numAnchors
            subplot(numAnchors, 1, anchor);
            rmseLine = rmseData(anchor, :);
            plot(rmseLine, 'LineWidth', 1.5); % Each line represents the RMSE of an anchor over samples
        
            % Label the last point
            lastRMSE = rmseLine(end);
            hold on;
            plot(length(rmseLine), lastRMSE, 'ro', 'MarkerFaceColor', 'r'); % Red circle at last point
            text(length(rmseLine), lastRMSE, sprintf(' %.2f', lastRMSE), 'VerticalAlignment', 'bottom', 'HorizontalAlignment', 'right'); % Display RMSE value at last point
        
            % Display RMSE value in the console
            fprintf('Anchor %d - Last RMSE Value: %.2f\n', anchor, lastRMSE);
        
            % Set the title and labels
            if anchor == numAnchors
                t = 'Tag';
            else
                t = sprintf('Anchor %d - RMSE Evolution', anchor);
            end
            title(t);
            xlabel('Sample');
            ylabel('RMSE');
            set(gca, 'FontSize', 11); % Increase font size for axes
            grid on;
        end
        sgtitle(sprintf('%s - %s: RMSE Evolution', estimator, scenario)); % Super title for all subplots
        saveas(gcf, sprintf('../img/%s_%s_RMSE_Evolution.png', estimator, scenario));

        % Plot RMSE histograms for each anchor
        figure('Position', get(0, 'Screensize'));
        for anchor = 1:numAnchors
            subplot(numAnchors, 1, anchor);
            histogram(rmseData(anchor, :), 'Normalization', 'pdf', 'FaceColor', [0.2, 0.6, 0.8]); % Normalized histogram
            if anchor == numAnchors
                t = 'Tag';
            else
                t = sprintf('Anchor %d - RMSE Evolution', anchor);
            end
            title(t);
            xlabel('RMSE');
            ylabel('Occurrences');
            set(gca, 'FontSize', 11); % Increase font size for axes
            grid on;
        end
        sgtitle(sprintf('%s - %s: RMSE Histogram', estimator, scenario)); % Super title for all subplots
        saveas(gcf, sprintf('../img/%s_%s_RMSE_Histogram.png', estimator, scenario));

        % Plot RMSE boxplots for each anchor
        figure('Position', get(0, 'Screensize'));
        labels = arrayfun(@(x) sprintf('Anchor %d', x), 1:numAnchors, 'UniformOutput', false);
        labels{end} = 'Tag'; % Replace the last label with 'Tag'
        boxplot(mean(rmseData, 3)', 'Labels', labels);
        title(sprintf('%s - %s: RMSE Boxplot', estimator, scenario));
        xlabel('Anchor');
        ylabel('RMSE');
        grid on;
        set(gca, 'FontSize', 12); % Increase font size for axes
        saveas(gcf, sprintf('../img/%s_%s_RMSE_Boxplot.png', estimator, scenario));

        pause(0.1);
    end

    function trainDDN()
        [noisyDistances, cleanOriginalDistances, trueAnchors] = generateData(numTopologies * numSamples * 2, numAnchors, distanceNoise); % Adjust the number of samples and anchors

        % Train denoising autoencoder
        ae = trainDenoisingAutoencoder(noisyDistances, cleanOriginalDistances);
        trainDataCleaned = ae(noisyDistances');

        noisyDistancesMatrix = reshapeToSquare(noisyDistances);
        trainDataCleanedMatrix = reshapeToSquare(trainDataCleaned);
        cleanOriginalDistances = reshapeToSquare(cleanOriginalDistances);

        % Calculate residuals
        residualsMatrix = abs(trainDataCleanedMatrix - cleanOriginalDistances);

        % Create the figure and subplots
        figure;

        % Plot Noisy Distances
        subplot(2, 2, 1);
        heatmap(noisyDistancesMatrix, 'Title', 'Noisy Distances', 'XLabel', 'i', 'YLabel', 'j');
        colorbar;
        set(gca, 'FontSize', 12); % Increase font size for axes
        colormap('jet'); % Color map that goes from blue to red

        % Plot Original Distances
        subplot(2, 2, 2);
        heatmap(cleanOriginalDistances, 'Title', 'Original Distances', 'XLabel', 'i', 'YLabel', 'j');
        colorbar;
        set(gca, 'FontSize', 12); % Increase font size for axes
        colormap('jet'); % Color map that goes from blue to red

        % Plot Cleaned Distances
        subplot(2, 2, 3);
        heatmap(trainDataCleanedMatrix, 'Title', 'Cleaned Distances', 'XLabel', 'i', 'YLabel', 'j');
        colorbar;
        set(gca, 'FontSize', 12); % Increase font size for axes
        colormap('jet'); % Color map that goes from blue to red

        % Plot Residuals
        subplot(2, 2, 4);
        heatmap(residualsMatrix, 'Title', 'Residuals', 'XLabel', 'i', 'YLabel', 'j');
        colorbar;
        set(gca, 'FontSize', 12); % Increase font size for axes
        colormap('hot'); % Color map that goes from black to red through yellow and orange

        % Adjust subplot layout
        sgtitle('Distance Matrices and Residuals');

        % Train regression network
        regressionNetwork = trainRegressionNetwork(noisyDistances, trueAnchors, numAnchors);
    end
end


function trainRN()
[noisyDistances, cleanDistances, noisyAnchors, trueAnchors, tagPositions] = generateData(20000, 6, [0.1, 0,4, 0,7, 1.0, 1.4, 1.8]); % Adjust the number of samples and anchors

trainData = cat(2, cleanDistances, tagPositions);
trainData = cat(2, trainData, noisyAnchors);

% Train regression network
regressionNetwork = trainRegressionNetwork(trainData, trueAnchors);

end
