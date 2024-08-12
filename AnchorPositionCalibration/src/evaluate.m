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

        % Prepare CSV files to store results
        csvFileAnchor = fopen('anchor_errors.csv', 'w');
        csvFileTag = fopen('tag_errors.csv', 'w');
        
        % Headers
        fprintf(csvFileAnchor, 'Estimator,Scenario,Anchor,Sample,Error\n');
        fprintf(csvFileTag, 'Estimator,Scenario,Sample,Error\n');

        % Loop over each estimator
        estimators = {'NLS', 'MLE'};
        for estimator = estimators
            estName = estimator{1};
            
            % Scenario 1: Static Tag
            rmseStatic = simulateCalibration(trueAnchors, initialAnchors, tagPositionsStatic, estName, numAnchors, distanceNoise, toaNoise, numSamples);
            plotAndSaveResults(rmseStatic, estName, 'Static');

            % Scenario 2: Moving Tag
            rmseMoving = simulateCalibration(trueAnchors, initialAnchors, tagPositionsMoving, estName, numAnchors, distanceNoise, toaNoise, numSamples);
            plotAndSaveResults(rmseMoving, estName, 'Moving');
        
            % Save errors to CSV
            saveErrorsToCSV(rmseStatic, estName, 'Static', csvFileAnchor, csvFileTag);
            saveErrorsToCSV(rmseMoving, estName, 'Moving', csvFileAnchor, csvFileTag);
        end
        
        % Close CSV files
        fclose(csvFileAnchor);
        fclose(csvFileTag);
        
        % Compute statistics and perform tests
        analyzeResults('anchor_errors.csv', 'tag_errors.csv', estimators, numAnchors);
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

    % Function to save errors to CSV
    function saveErrorsToCSV(rmse, estimator, scenario, csvFileAnchor, csvFileTag)
        numAnchors = size(rmse, 1) - 1;
        for i = 1:numAnchors
            for j = 1:size(rmse, 2)
                fprintf(csvFileAnchor, '%s,%s,Anchor%d,%d,%.6f\n', estimator, scenario, i, j, rmse(i, j));
            end
        end
        
        for j = 1:size(rmse, 2)
            fprintf(csvFileTag, '%s,%s,%d,%.6f\n', estimator, scenario, j, rmse(end, j));
        end
    end
    
    function analyzeResults(anchorErrorCSV, tagErrorCSV, estimators, numAnchors)
        % Load the data
        anchorErrors = readtable(anchorErrorCSV);
        tagErrors = readtable(tagErrorCSV);
        
        % Separate scenarios for anchor errors
        staticAnchorErrors = anchorErrors(strcmp(anchorErrors.Scenario, 'Static'), :);
        movingAnchorErrors = anchorErrors(strcmp(anchorErrors.Scenario, 'Moving'), :);
        
        % Separate scenarios for tag errors
        staticTagErrors = tagErrors(strcmp(tagErrors.Scenario, 'Static'), :);
        movingTagErrors = tagErrors(strcmp(tagErrors.Scenario, 'Moving'), :);
        
        % Analyze each scenario and subgroup
        analyzeSubgroup(staticAnchorErrors, estimators, 'Static', 'Anchor');
        analyzeSubgroup(movingAnchorErrors, estimators, 'Moving', 'Anchor');
        analyzeSubgroup(staticTagErrors, estimators, 'Static', 'Tag');
        analyzeSubgroup(movingTagErrors, estimators, 'Moving', 'Tag');
    end

    function analyzeSubgroup(errorsTable, estimators, scenario, errorType)
        % Compute mean errors
        meanErrors = varfun(@mean, errorsTable, 'InputVariables', 'Error', ...
            'GroupingVariables', {'Estimator', 'Sample'});
        
        % Normality test (e.g., Shapiro-Wilk)
        normalityTestResults = arrayfun(@(x) lillietest(errorsTable.Error(strcmp(errorsTable.Estimator, x))), estimators);

        % Constant variance test (e.g., Bartlett's test)
        [varTestResults, varTestP] = vartestn(errorsTable.Error, errorsTable.Estimator, 'TestType', 'Bartlett', 'Display', 'off');
        
        % Perform parametric tests if normality and equal variance hold
        if all(normalityTestResults) && varTestResults
            % ANOVA and multiple comparisons
            [pVal, tbl, stats] = anova1(errorsTable.Error, errorsTable.Estimator, 'off');
        else
            % Kruskal-Wallis and multiple comparisons
            [pVal, tbl, stats] = kruskalwallis(errorsTable.Error, errorsTable.Estimator, 'off');
        end

        results = multcompare(stats, 'CType', 'bonferroni');
        
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
        figure;
        boxplot(meanErrors.mean_Error, meanErrors.Estimator);
        title(sprintf('Mean %s Error for Each Estimator (%s Scenario)', errorType, scenario));
        xlabel('Estimator');
        ylabel('Mean Error');
        saveas(gcf, sprintf('../img/Mean_%s_Error_BoxPlot_%s.png', errorType, scenario));
        
        grouped = sortrows(varfun(@mean, meanErrors, 'InputVariables', 'mean_Error', ...
            'GroupingVariables', {'Estimator'}));
        % Ranking of estimators based on mean errors
        [~, rank] = sortrows(grouped.mean_mean_Error, 'ascend');
        
        fprintf('Ranking for %s Calibration in %s Scenario:\n', errorType, scenario);
        disp(grouped.Estimator(rank));
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
        boxplot(rmseData', 'Labels', arrayfun(@(x) sprintf('Anchor %d', x), 1:numAnchors, 'UniformOutput', false));
        title(sprintf('%s - %s: RMSE Boxplot', estimator, scenario));
        xlabel('Anchor');
        ylabel('RMSE');
        grid on;
        saveas(gcf, sprintf('../img/%s_%s_RMSE_Boxplot.png', estimator, scenario));

        pause(0.1);
        close all;
    end
end
