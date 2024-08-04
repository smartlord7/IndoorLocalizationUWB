function estimatedAnchors = calibrateAnchors(~, ~)
    % Get the handles structure
    handles = guidata(gcbo);

    % Remove previous estimated anchors from plot
    if ~isempty(handles.estimatedAnchorsPlot)
        delete(handles.estimatedAnchorsPlot);
    end

    % Get selected algorithm
    algorithms = get(handles.algorithmMenu, 'String');
    selectedAlgorithm = algorithms{get(handles.algorithmMenu, 'Value')};

    % Simulate distances with noise
    distances = sqrt(sum((handles.trueAnchors - handles.trueTagPosition).^2, 2));
    distances_noisy = distances + randn(size(distances)) * 0.1; % Add noise with std deviation of 0.1 m

    if isempty(handles.estimatedTagPosition)
        tagPos = handles.trueTagPosition; % Fix typo: should be handles.trueTagPosition
    else
        tagPos = handles.estimatedTagPosition;
    end

    % Define period for resetting initial guess (e.g., every 10 calls)
    resetPeriod = 10;
    
    % Initialize or update the call counter
    if ~isfield(handles, 'callCounter')
        handles.callCounter = 0;
    end
    handles.callCounter = handles.callCounter + 1;

    % Generate an initial guess for the anchor positions
    % Periodically reset the initial guess to the true anchor positions
    if mod(handles.callCounter, resetPeriod) == 0
        initialGuess = handles.trueAnchors;
    else
        initialGuess = handles.trueAnchors + rand(size(handles.trueAnchors)) * handles.initGuessRange;
    end

    % Choose algorithm for anchor calibration
    switch selectedAlgorithm
        case 'Nonlinear Least Squares'
            estimatedAnchors = nonlinearLeastSquares(distances_noisy, initialGuess, tagPos);
        case 'Maximum Likelihood Estimation'
            estimatedAnchors = maximumLikelihoodEstimation(distances_noisy, initialGuess, tagPos);
        case 'Extended Kalman Filter'
            estimatedAnchors = extendedKalmanFilter(distances_noisy, initialGuess, tagPos);
        case 'Linear Least Squares'
            estimatedAnchors = linearLeastSquares(distances_noisy, initialGuess, tagPos);
        case 'Weighted Least Squares'
            estimatedAnchors = weightedLeastSquares(distances_noisy, initialGuess, tagPos);
        case 'Iterative Refinement'
            estimatedAnchors = iterativeRefinement(distances_noisy, initialGuess, tagPos);
        case 'Maximum A Posteriori'
            estimatedAnchors = mapEstimation(distances_noisy, initialGuess, tagPos);
        case 'Genetic Algorithm'
            estimatedAnchors = geneticAlgorithm(distances_noisy, initialGuess, tagPos);
    end

    % Display estimated positions
    disp('Estimated Anchor Positions (m):');
    disp(estimatedAnchors);

    % Update plot with estimated anchors
    handles.estimatedAnchorsPlot = plotAnchors(estimatedAnchors, 'g', 'Estimated Anchors');
    handles.estimatedAnchors = estimatedAnchors;

    % Store the updated handles structure
    guidata(gcbo, handles);

    % Update legend
    legend();
end
