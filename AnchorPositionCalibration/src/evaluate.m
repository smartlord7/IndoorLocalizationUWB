function evaluate()
    % Create a figure for UI
    fig = figure('Name', 'Anchor Calibration Simulation', 'Position', [100, 100, 800, 600]);

    % Default Parameters
    defaultNumAnchors = 6;
    defaultNumSamples = 1000;
    defaultAnchorNoise = 2;
    defaultDistanceNoise = 0.3;
    defaultToaNoise = 2e-9;
    defaultNumTopologies = 30;

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

    uicontrol('Style', 'text', 'Position', [10, 400, 150, 20], 'String', 'Number of Topologies:');
    numTopologiesEdit = uicontrol('Style', 'edit', 'Position', [170, 400, 100, 20], 'String', num2str(defaultNumTopologies));

    % Multiselect Listbox for Estimators
    uicontrol('Style', 'text', 'Position', [10, 400, 150, 20], 'String', 'Select Estimators:');
    estimatorListBox = uicontrol('Style', 'listbox', 'Position', [170, 300, 150, 100], ...
        'String', {'NLS', 'MLE', 'EKF', 'LLS', 'WLS', 'IR', 'GA', 'DDN', 'C'}, 'Max', 7, 'Min', 1, ...
        'Value', 1:7, 'Callback', @updateSelection);

    % Selected estimators list
    selectedEstimators = {'NLS', 'MLE', 'EKF', 'LLS', 'WLS', 'IR', 'GA', 'DDN', 'C'};

    % Function to update selected estimators
    function updateSelection(~, ~)
        selectedEstimators = estimatorListBox.String(estimatorListBox.Value);
    end

    % Run Simulation button
    uicontrol('Style', 'pushbutton', 'Position', [10, 250, 150, 30], 'String', 'Run Simulation', ...
        'Callback', @(~, ~) runSimulation());

    % Function to Run Simulation
    function runSimulation()
        numAnchors = str2double(numAnchorsEdit.String);
        numSamples = str2double(numSamplesEdit.String);
        anchorNoise = str2double(anchorNoiseEdit.String);
        distanceNoise = str2double(distanceNoiseEdit.String);
        toaNoise = str2double(toaNoiseEdit.String);
        numTopologies = str2double(numTopologiesEdit.String);
        mx = 40;

        lb = repmat([0 0 0], numAnchors, 1); % Lower bounds
        ub = repmat([mx mx mx], numAnchors, 1);  % Upper bounds
        sz = size(lb);
        bounds = zeros(2, sz(1), sz(2));
        bounds(1, :, :) = lb;
        bounds(2, :, :) = ub;

        
        % Generate random tag positions along a path
        tagPositionsMoving = generateRandomPath(numSamples, mx);
        % Static tag at a fixed position
        tagPositionsStatic = repmat([10, 10, 10], numSamples, 1);

        % Prepare CSV files to store results
        csvFileAnchor = fopen('../data/anchor_errors.csv', 'w');
        csvFileTag = fopen('../data/tag_errors.csv', 'w');
        
        % Headers
        fprintf(csvFileAnchor, 'Estimator,Scenario,Topology,Anchor,Sample,Error\n');
        fprintf(csvFileTag, 'Estimator,Scenario,Topology,Sample,Error\n');

        % Loop over each selected estimator
        for i = 1:length(selectedEstimators)
            estName = selectedEstimators{i};
            
            % Scenario 1: Static Tag
            rmseStatic = simulateCalibration(numTopologies, mx, anchorNoise, tagPositionsStatic, estName, numAnchors, distanceNoise, toaNoise, numSamples, bounds);
            plotAndSaveResults(rmseStatic, estName, 'Static');

            % Scenario 2: Moving Tag
            rmseMoving = simulateCalibration(numTopologies, mx, anchorNoise, tagPositionsMoving, estName, numAnchors, distanceNoise, toaNoise, numSamples, bounds);
            plotAndSaveResults(rmseMoving, estName, 'Moving');
        
            % Save errors to CSV
            saveErrorsToCSV(rmseStatic, estName, 'Static', csvFileAnchor, csvFileTag);
            saveErrorsToCSV(rmseMoving, estName, 'Moving', csvFileAnchor, csvFileTag);
        end
        
        % Close CSV files
        fclose(csvFileAnchor);
        fclose(csvFileTag);
        
        % Compute statistics and perform tests
        analyzeResults('../data/anchor_errors.csv', '../data/tag_errors.csv', selectedEstimators);
    end

    % Function to simulate calibration
    function rmse = simulateCalibration(numTopologies, mx, anchorNoise, tagPositions, estimator, numAnchors, distanceNoise, toaNoise, numSamples, bounds)
        % Initialize matrix to accumulate RMSE
        rmse = zeros(numAnchors + 1, numSamples, numTopologies);

        for topology=1:numTopologies
            % Generate true anchor positions
            trueAnchors = mx * rand(numAnchors, 3); 
            % Add Gaussian noise to anchor positions for initial guess
            initialAnchors = trueAnchors + anchorNoise * randn(size(trueAnchors));
    
            % Perform calibration and compute RMSE
            for sample = 1:numSamples
                % Current tag position
                currentTagPos = tagPositions(sample, :);
                
                % Simulate distances with noise for the current tag position
                trueDistances = sqrt(sum((trueAnchors - currentTagPos).^2, 2));
                noisyDistances = trueDistances + randn(size(trueDistances)) * distanceNoise;
                estimatedAnchors = [];

                estimatedTagPos = trilateration(trueAnchors, trueAnchors, currentTagPos, 1000, toaNoise, distanceNoise);
                rmse(numAnchors + 1, sample, topology) = sqrt(mean(((estimatedTagPos - currentTagPos).^2), 2));
                
                % Estimate anchor positions based on the noisy distances
                switch estimator
                    case 'NLS'
                        estimatedAnchors = nonlinearLeastSquares(noisyDistances, initialAnchors, estimatedTagPos);
                    case 'MLE'
                        estimatedAnchors = maximumLikelihoodEstimation(noisyDistances, initialAnchors, estimatedTagPos);
                    case 'EKF'
                        estimatedAnchors = extendedKalmanFilter(noisyDistances, distanceNoise * distanceNoise, initialAnchors, estimatedTagPos);
                    case 'LLS'
                        estimatedAnchors = linearLeastSquares(noisyDistances, initialAnchors, estimatedTagPos);
                    case 'WLS'
                        estimatedAnchors = nonLinearWeightedLeastSquares(noisyDistances, initialAnchors, estimatedTagPos);
                    case 'IR'
                        estimatedAnchors = iterativeRefinement(noisyDistances, initialAnchors, estimatedTagPos);
                    case 'GA'
                        estimatedAnchors = geneticAlgorithm(noisyDistances, initialAnchors, estimatedTagPos, bounds);
                    case 'DDN'
                        %estimatedAnchors = combinedModel(noisyDistances, denoisingAutoencoder, regressionNetwork);
                    case 'C'
                        estimatedAnchors = control(initialAnchors);
                end
                
                % Compute RMSE for anchors
                rmse(1:numAnchors, sample, topology) = sqrt(mean(((estimatedAnchors - trueAnchors).^2), 2));
            end
        end
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
        
        % Separate scenarios for tag errors
        % staticTagErrors = tagErrors(strcmp(tagErrors.Scenario, 'Static'), :);
        % movingTagErrors = tagErrors(strcmp(tagErrors.Scenario, 'Moving'), :);
        
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
        
        % Create a symmetrical matrix for p-values
        numEstimators = length(estimators);
        pValuesMatrix = NaN(numEstimators, numEstimators);
        
        % Fill in the p-values
        for i = 1:size(results, 1)
            idx1 = results(i, 1);
            idx2 = results(i, 2);
            pValue = results(i, 6);
            pValuesMatrix(idx1, idx2) = pValue;
            pValuesMatrix(idx2, idx1) = pValue;
        end
        
        % Plot heatmap of p-values
        figure('Position', get(0, 'Screensize'));
        heatmap(estimators, estimators, pValuesMatrix, 'Colormap', parula, 'ColorLimits', [0, 1]);
        title(sprintf('Heatmap of P-values for %s %s Estimators', scenario, errorType));
        xlabel('Estimator');
        ylabel('Estimator');
        saveas(gcf, sprintf('../img/%s_%s_Estimator_PValue_Heatmap.png', scenario, errorType));      

        
        % Plot bar plot for mean errors
        figure('Position', get(0, 'Screensize'));
        boxplot(meanErrors.mean_mean_Error, meanErrors.Estimator);
        title(sprintf('Mean %s Error for Each Estimator (%s Scenario)', errorType, scenario));
        xlabel('Estimator');
        ylabel('Mean Error');
        saveas(gcf, sprintf('../img/Mean_%s_Error_BoxPlot_%s.png', errorType, scenario));

        confidenceAnalysis(estimators, meanErrors, errorType, scenario);
        
        grouped = sortrows(varfun(@mean, meanErrors, 'InputVariables', 'mean_mean_Error', ...
            'GroupingVariables', {'Estimator'}));
        % Ranking of estimators based on mean errors
        [~, rank] = sortrows(grouped.mean_mean_mean_Error, 'ascend');
        
        fprintf('Ranking for %s Calibration in %s Scenario:\n', errorType, scenario);
        disp(grouped.Estimator(rank));
    end
    
    % Function to generate a random path
    function path = generateRandomPath(steps, mx)
        path = cumsum(randn(steps, 3), 1) + [mx, mx, mx];
    end
    
    % Function to plot and save results
    function plotAndSaveResults(rmseData, estimator, scenario)
        % Extract dimensions
        [numAnchors, ~] = size(rmseData);

        % Plot RMSE evolution for each anchor
        figure('Position', get(0, 'Screensize'));
        for anchor = 1:numAnchors
            subplot(numAnchors, 1, anchor);
            plot(rmseData(anchor, :), 'LineWidth', 1.5); % Each line represents the RMSE of an anchor over samples
            title(sprintf('Anchor %d - RMSE Evolution', anchor));
            xlabel('Sample');
            ylabel('RMSE');
            grid on;
        end
        sgtitle(sprintf('%s - %s: RMSE Evolution', estimator, scenario)); % Super title for all subplots
        saveas(gcf, sprintf('../img/%s_%s_RMSE_Evolution.png', estimator, scenario));
        
        % Plot RMSE histograms for each anchor
        figure('Position', get(0, 'Screensize'));
        for anchor = 1:numAnchors
            subplot(numAnchors, 1, anchor);
            histogram(rmseData(anchor, :), 'Normalization', 'pdf', 'FaceColor', [0.2, 0.6, 0.8]); % Normalized histogram
            title(sprintf('Anchor %d - RMSE Histogram', anchor));
            xlabel('RMSE');
            ylabel('Probability Density');
            grid on;
        end
        sgtitle(sprintf('%s - %s: RMSE Histogram', estimator, scenario)); % Super title for all subplots
        saveas(gcf, sprintf('../img/%s_%s_RMSE_Histogram.png', estimator, scenario));
        
        % Plot RMSE boxplots for each anchor
        figure('Position', get(0, 'Screensize'));
        boxplot(mean(rmseData, 3)', 'Labels', arrayfun(@(x) sprintf('Anchor %d', x), 1:numAnchors, 'UniformOutput', false));
        title(sprintf('%s - %s: RMSE Boxplot', estimator, scenario));
        xlabel('Anchor');
        ylabel('RMSE');
        grid on;
        saveas(gcf, sprintf('../img/%s_%s_RMSE_Boxplot.png', estimator, scenario));

        pause(0.1);
        close all;
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
        colormap('jet'); % Color map that goes from blue to red
        
        % Plot Original Distances
        subplot(2, 2, 2);
        heatmap(cleanOriginalDistances, 'Title', 'Original Distances', 'XLabel', 'i', 'YLabel', 'j');
        colorbar;
        colormap('jet'); % Color map that goes from blue to red
        
        % Plot Cleaned Distances
        subplot(2, 2, 3);
        heatmap(trainDataCleanedMatrix, 'Title', 'Cleaned Distances', 'XLabel', 'i', 'YLabel', 'j');
        colorbar;
        colormap('jet'); % Color map that goes from blue to red
        
        % Plot Residuals
        subplot(2, 2, 4);
        heatmap(residualsMatrix, 'Title', 'Residuals', 'XLabel', 'i', 'YLabel', 'j');
        colorbar;
        colormap('hot'); % Color map that goes from black to red through yellow and orange
        
        % Adjust subplot layout
        sgtitle('Distance Matrices and Residuals');

        % Train regression network
        regressionNetwork = trainRegressionNetwork(noisyDistances, trueAnchors, numAnchors);
    end
end
