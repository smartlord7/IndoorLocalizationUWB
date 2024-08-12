function evaluate()
    % Create a figure for UI
    fig = figure('Name', 'Anchor Calibration Simulation', 'Position', [100, 100, 800, 600]);

    % Default Parameters
    defaultNumAnchors = 6;
    defaultNumSamples = 1000;
    defaultAnchorNoise = 0.1;
    defaultDistanceNoise = 0.05;
    defaultToaNoise = 1e-9;

    % UI Controls
    uicontrol('Style', 'text', 'Position', [10, 550, 150, 20], 'String', 'Number of Anchors:');
    numAnchorsEdit = uicontrol('Style', 'edit', 'Position', [170, 550, 100, 20], 'String', num2str(defaultNumAnchors));
    
    uicontrol('Style', 'text', 'Position', [10, 520, 150, 20], 'String', 'Number of Samples:');
    numSamplesEdit = uicontrol('Style', 'edit', 'Position', [170, 520, 100, 20], 'String', num2str(defaultNumSamples));
    
    uicontrol('Style', 'text', 'Position', [10, 490, 150, 20], 'String', 'Anchor Noise:');
    anchorNoiseEdit = uicontrol('Style', 'edit', 'Position', [170, 490, 100, 20], 'String', num2str(defaultAnchorNoise));
    
    uicontrol('Style', 'text', 'Position', [10, 460, 150, 20], 'String', 'Distance Noise:');
    distanceNoiseEdit = uicontrol('Style', 'edit', 'Position', [170, 460, 100, 20], 'String', num2str(defaultDistanceNoise));

    uicontrol('Style', 'text', 'Position', [10, 430, 150, 20], 'String', 'ToA Noise:');
    toaNoiseEdit = uicontrol('Style', 'edit', 'Position', [170, 430, 100, 20], 'String', num2str(defaultToaNoise));

    
    uicontrol('Style', 'pushbutton', 'Position', [10, 390, 150, 30], 'String', 'Run Simulation', ...
        'Callback', @(~, ~) runSimulation());
    
    % Function to Run Simulation
    function runSimulation()
        numAnchors = str2double(numAnchorsEdit.String);
        numSamples = str2double(numSamplesEdit.String);
        anchorNoise = str2double(anchorNoiseEdit.String);
        distanceNoise = str2double(distanceNoiseEdit.String);
        toaNoise = str2double(toaNoiseEdit.String);


        % Generate true anchor positions
        trueAnchors = 40 * rand(numAnchors, 3); 
        % Add Gaussian noise to anchor positions for initial guess
        initialAnchors = trueAnchors + anchorNoise * randn(size(trueAnchors));
        
        % Generate random tag positions along a path
        tagPositionsMoving = generateRandomPath(numSamples);
        % Static tag at a fixed position
        tagPositionsStatic = repmat([10, 10, 10], numSamples, 1);

        

        % Loop over each estimator
        estimators = {'NLS', 'MLE', 'EKF', 'LLS', 'WLS', 'IR', 'GA'};
        for estimator = estimators
            estName = estimator{1};
            
            % Scenario 1: Static Tag
            % Simulate calibration with static tag
            rmseStatic = simulateCalibration(trueAnchors, initialAnchors, tagPositionsStatic, estName, numAnchors, distanceNoise, toaNoise, numSamples);
            % Plot and save results
            plotAndSaveResults(rmseStatic, estName, 'Static');

            % Scenario 2: Moving Tag
            % Simulate calibration with moving tag
            rmseMoving = simulateCalibration(trueAnchors, initialAnchors, tagPositionsMoving, estName, numAnchors, distanceNoise, toaNoise, numSamples);
            % Plot and save results
            plotAndSaveResults(rmseMoving, estName, 'Moving');
        
        end
    end
    
    % Function to simulate calibration
    function rmse = simulateCalibration(trueAnchors, initialAnchors, tagPositions, estimator, numAnchors, distanceNoise, toaNoise, numSamples)
        % Initialize matrix to accumulate RMSE
        rmse = zeros(numAnchors + 1, numSamples);

        % Perform calibration and compute RMSE
        for sample = 1:numSamples
            % Current tag position
            currentTagPos = tagPositions(sample, :);
            
            % Simulate distances with noise for the current tag position
            trueDistances = sqrt(sum((initialAnchors - currentTagPos).^2, 2));
            noisyDistances = trueDistances + randn(size(trueDistances)) * distanceNoise;
            estimatedAnchors = [];
            
            % Estimate anchor positions based on the noisy distances
            switch estimator
                case 'NLS'
                    estimatedAnchors = nonlinearLeastSquares(noisyDistances, initialAnchors, currentTagPos);
                case 'MLE'
                    estimatedAnchors = maximumLikelihoodEstimation(noisyDistances, initialAnchors, currentTagPos);
                case 'EKF'
                    estimatedAnchors = extendedKalmanFilter(noisyDistances, initialAnchors, currentTagPos);
                case 'LLS'
                    estimatedAnchors = linearLeastSquares(noisyDistances, initialAnchors, currentTagPos);
                case 'WLS'
                    estimatedAnchors = weightedLeastSquares(noisyDistances, initialAnchors, currentTagPos);
                case 'IR'
                    estimatedAnchors = iterativeRefinement(noisyDistances, initialAnchors, currentTagPos);
                case 'GA'
                    estimatedAnchors = geneticAlgorithm(noisyDistances, initialAnchors, currentTagPos);
            end
            
            % Compute RMSE for anchors
            rmse(1:numAnchors, sample) = sqrt(mean(((estimatedAnchors - trueAnchors).^2), 2));
            estimatedTagPos = trilateration(trueAnchors, estimatedAnchors, currentTagPos, 1000, toaNoise, distanceNoise);
            rmse(numAnchors + 1, sample) = sqrt(mean(((estimatedTagPos - currentTagPos).^2), 2));
        end
    end
    
    % Function to generate a random path
    function path = generateRandomPath(steps)
        path = cumsum(randn(steps, 3), 1) + [10, 10, 10];
    end
    
   % Function to plot and save results
function plotAndSaveResults(rmseData, estimator, scenario)
    % Extract dimensions
    [numAnchors, ~] = size(rmseData);

    % Plot RMSE evolution for each anchor
    figure;
    for anchor = 1:numAnchors
        subplot(numAnchors, 1, anchor);
        plot(rmseData(anchor, :), 'LineWidth', 1.5); % Each line represents the RMSE of an anchor over samples
        title(sprintf('Anchor %d - RMSE Evolution', anchor));
        xlabel('Sample');
        ylabel('RMSE');
        grid on;
    end
    sgtitle(sprintf('%s - %s: RMSE Evolution', estimator, scenario)); % Super title for all subplots
    saveas(gcf, sprintf('%s_%s_RMSE_Evolution.png', estimator, scenario));
    
    % Plot RMSE histograms for each anchor
    figure;
    for anchor = 1:numAnchors
        subplot(numAnchors, 1, anchor);
        histogram(rmseData(anchor, :), 'Normalization', 'pdf', 'FaceColor', [0.2, 0.6, 0.8]); % Normalized histogram
        title(sprintf('Anchor %d - RMSE Histogram', anchor));
        xlabel('RMSE');
        ylabel('Probability Density');
        grid on;
    end
    sgtitle(sprintf('%s - %s: RMSE Histogram', estimator, scenario)); % Super title for all subplots
    saveas(gcf, sprintf('%s_%s_RMSE_Histogram.png', estimator, scenario));
    
    % Plot RMSE boxplots for each anchor
    figure;
    boxplot(rmseData', 'Labels', arrayfun(@(x) sprintf('Anchor %d', x), 1:numAnchors, 'UniformOutput', false));
    title(sprintf('%s - %s: RMSE Boxplot', estimator, scenario));
    xlabel('Anchor');
    ylabel('RMSE');
    grid on;
    saveas(gcf, sprintf('%s_%s_RMSE_Boxplot.png', estimator, scenario));

    pause(0.5);
    close all;
end
end
