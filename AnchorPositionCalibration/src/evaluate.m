function evaluate()
    % Create a figure for UI
    fig = figure('Name', 'Anchor Calibration Simulation', 'Position', [100, 100, 800, 600]);
    disp('UI Figure created.');

    % Default Parameters
    defaultNumAnchors = 6;
    defaultNumSamples = 3000;
    defaultAnchorNoise = 1;
    defaultDistanceNoise = 0.1;
    defaultToaNoise = 1e-10;
    defaultNumTopologies = 1;
    rng(0);
    disp('Default parameters set.');

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
        disp('Updated selected estimators.');
    end

    % Run Simulation button
    uicontrol('Style', 'pushbutton', 'Position', [10, 250, 150, 30], 'String', 'Run Simulation', ...
        'Callback', @(~, ~) runSimulation());

    % Function to Run Simulation
    function runSimulation()
        disp('Running simulation...');
        numAnchors = str2double(numAnchorsEdit.String);
        numSamples = str2double(numSamplesEdit.String);
        anchorNoise = str2double(anchorNoiseEdit.String);
        distanceNoise = str2double(distanceNoiseEdit.String);
        toaNoise = str2double(toaNoiseEdit.String);
        numTopologies = str2double(numTopologiesEdit.String);
        mx = [10 10 10];

        bounds = buildBounds(mx, numAnchors);
        disp('Bounds built for anchor positions.');

        % Generate random tag positions along a path
        tagPositionsMoving = generateRandomPath(numSamples, mx);
        disp('Generated random path for moving tag.');

        % Static tag at a fixed position
        tagPositionsStatic = repmat([10, 10, 10], numSamples, 1);
        disp('Static tag positions generated.');

        % Prepare CSV files to store results
        csvFileAnchor = fopen('../data/anchor_errors.csv', 'w');
        csvFileTag = fopen('../data/tag_errors.csv', 'w');
        disp('CSV files prepared for results.');

        % Headers
        fprintf(csvFileAnchor, 'Estimator,Scenario,Topology,Anchor,Sample,Error\n');
        fprintf(csvFileTag, 'Estimator,Scenario,Topology,Sample,Error\n');

        % Generate true anchor positions
        trueAnchors = generateAnchors(mx, numAnchors);
        disp('True anchor positions generated.');

        % Add Gaussian noise to anchor positions for initial guess
        initialAnchors = trueAnchors + anchorNoise * randn(size(trueAnchors));
        disp('Initial anchor positions with noise generated.');
        net = {};

        % Loop over each selected estimator
        for i = 1:length(selectedEstimators)
            estName = selectedEstimators{i};
            disp(['Simulating for estimator: ', estName]);

            if estName == "DDN"
                %[noisyDistances, cleanDistances, noisyAnchors, realAnchors, tagPositions] = generateData(1000, 1000, 6, [0.1], 1.0, true); % Adjust the number of samples and anchors

                %trainData = cat(2, cleanDistances, tagPositions);
                %trainData = cat(2, trainData, noisyAnchors);
                %[ps, net, ~, valPerformance] = trainRegressionNetwork_(100, 50, 3, 'tansig', 0.06333, trainData, realAnchors);
            end

            % Scenario 1: Static Tag
            rmseStatic = simulateCalibration(numTopologies, trueAnchors, initialAnchors, tagPositionsStatic, estName, numAnchors, distanceNoise, anchorNoise, toaNoise, numSamples, bounds);
            plotAndSaveResults(rmseStatic, estName, 'Static');
            disp(['Static scenario RMSE calculated for estimator: ', estName]);

            % Scenario 2: Moving Tag
            rmseMoving = simulateCalibration(numTopologies, trueAnchors, initialAnchors, tagPositionsMoving, estName, numAnchors, distanceNoise, anchorNoise, toaNoise, numSamples, bounds);
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
    function rmse = simulateCalibration(numTopologies, trueAnchors, initialAnchors, tagPositions, estimator, numAnchors, distanceNoise, anchorNoise, toaNoise, numSamples, bounds)
        % Initialize matrix to accumulate RMSE
        rmse = zeros(numAnchors + 1, numSamples, numTopologies);
        disp(['Simulating calibration for estimator: ', estimator]);

        % Perform calibration and compute RMSE
        for sample = 1:numSamples
            disp(['Processing sample: ', num2str(sample)]);
            % Current tag position
            currentTagPos = tagPositions(sample, :);
            
            % Simulate distances with noise for the current tag position
            trueDistances = sqrt(sum((trueAnchors - currentTagPos).^2, 2));
            noisyDistances = trueDistances + randn(size(trueDistances)) * distanceNoise;
            estimatedAnchors = [];

            estimatedTagPos = trilateration(trueAnchors, trueAnchors, currentTagPos, 1000, toaNoise, distanceNoise);
            rmse(numAnchors + 1, sample, 1) = sqrt(mean(((estimatedTagPos - currentTagPos).^2), 2));
            
            % Estimate anchor positions based on the noisy distances
            switch estimator
                case 'NLS'
                    estimatedAnchors = nonlinearLeastSquares(noisyDistances, initialAnchors, estimatedTagPos, bounds);
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
                    estimatedAnchors = geneticAlgorithm(noisyDistances, initialAnchors, estimatedTagPos, bounds);
                case 'DDN'                  
                    %testData = cat(2, noisyDistances', estimatedTagPos);
                    %testData = cat(2, testData, reshape(initialAnchors', 1, [])); % Transpose and flatten);
                    %[testData, ps] = mapminmax('apply', testData', ps);

                    %estimatedAnchors = net(testData);
                    %estimatedAnchors = reshape(estimatedAnchors, size(initialAnchors, 1), 3);
                    estimatedAnchors = callibrate(numAnchors, initialAnchors, noisyDistances, estimatedTagPos, anchorNoise);
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
        
        pValuesMatrix = buildPValueMatrix(estimators, results);
        
        % Plot heatmap of p-values
        figure('Position', get(0, 'Screensize'));
        heatmap(estimators, estimators, pValuesMatrix, 'Colormap', parula, 'ColorLimits', [0, 1]);
        title(sprintf('Heatmap of P-values for %s %s Estimators', scenario, errorType));
        xlabel('Estimator');
        ylabel('Estimator');
        set(gca, 'FontSize', 12); % Increase font size for axes
        saveas(gcf, sprintf('../img/%s_%s_Estimator_PValue_Heatmap.png', scenario, errorType));      

        
        % Plot bar plot for mean errors
        figure('Position', get(0, 'Screensize'));
        boxplot(meanErrors.mean_mean_Error, meanErrors.Estimator);
        title(sprintf('Mean %s Error for Each Estimator (%s Scenario)', errorType, scenario));
        xlabel('Estimator');
        ylabel('Mean Error');
        set(gca, 'FontSize', 12); % Increase font size for axes
        saveas(gcf, sprintf('../img/Mean_%s_Error_BoxPlot_%s.png', errorType, scenario));

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
            plot(rmseData(anchor, :), 'LineWidth', 1.5); % Each line represents the RMSE of an anchor over samples
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
