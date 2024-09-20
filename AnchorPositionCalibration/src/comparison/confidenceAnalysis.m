function confidenceAnalysis(estimators, meanErrors, errorType, scenario)
% Confidence Interval Calculation for Each Estimator
    numEstimators = length(estimators);
    confidenceIntervals = NaN(numEstimators, 2);  % [lowerBound, upperBound]
    overallMeans = NaN(numEstimators, 1);
    stdDevs = NaN(numEstimators, 1);
    sampleCounts = NaN(numEstimators, 1);

    for i = 1:numEstimators
        % Extract samples for each estimator
        estimatorErrors = meanErrors.mean_mean_Error(strcmp(meanErrors.Estimator, estimators{i}));
        
        % Calculate mean, standard deviation, and sample size
        overallMean = mean(estimatorErrors);
        stdDev = std(estimatorErrors);
        n = length(estimatorErrors);
        sampleCounts(i) = n;
        
        % Compute standard error
        SE = stdDev / sqrt(n);
        
        % 95% confidence interval
        lowerBound = overallMean - (1.96 * SE);
        upperBound = overallMean + (1.96 * SE);
        
        % Store results
        overallMeans(i) = overallMean;
        stdDevs(i) = stdDev;
        confidenceIntervals(i, :) = [lowerBound, upperBound];
    end
    
    % Check for intersections between confidence intervals
    intersectionMatrix = zeros(numEstimators, numEstimators);
    
    for i = 1:numEstimators
        for j = i+1:numEstimators
            % Check the overlap between [lower_i, upper_i] and [lower_j, upper_j]
            lower_i = confidenceIntervals(i, 1);
            upper_i = confidenceIntervals(i, 2);
            lower_j = confidenceIntervals(j, 1);
            upper_j = confidenceIntervals(j, 2);
            
            % Intersection occurs if there's overlap
            if lower_j <= upper_i && lower_i <= upper_j
                intersectionLength = min(upper_i, upper_j) - max(lower_i, lower_j);
                intersectionMatrix(i, j) = intersectionLength;
                intersectionMatrix(j, i) = intersectionLength;
            end
        end
    end

    % Plot heatmap of intersections
    figure('Position', get(0, 'Screensize'));
    heatmap(estimators, estimators, intersectionMatrix, 'Colormap', parula, 'ColorLimits', [0, max(max(intersectionMatrix(:)), 0.1)]);
    title(sprintf('Heatmap of Confidence Interval Intersections for %s %s Estimators', scenario, errorType));
    xlabel('Estimator');
    ylabel('Estimator');
    saveas(gcf, sprintf('../img/%s_%s_Estimator_ConfidenceInterval_Heatmap.png', scenario, errorType));
    
    % Display the confidence intervals and rankings
    disp('Confidence Intervals for Each Estimator:');
    for i = 1:numEstimators
        fprintf('%s: [%.4f, %.4f]\n', estimators{i}, confidenceIntervals(i, 1), confidenceIntervals(i, 2));
    end
end

