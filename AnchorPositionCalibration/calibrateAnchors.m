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

    anchors = handles.trueAnchors + rand(size(handles.trueAnchors)) * handles.initGuessRange;

    % Simulate distances with noise / GOD MODE
    distances = sqrt(sum((anchors - handles.trueTagPosition).^2, 2));
    distances_noisy = distances + randn(size(distances)) * handles.distancesStd; % Add noise with std deviation of 0.1 m
    tagPos = handles.trueTagPosition + randn(size(handles.trueTagPosition)) * handles.tagPosStd; % Add noise with std deviation of 0.1 m

    % Generate an initial guess for the anchor positio
    initialGuess = anchors;

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

    % Example of updating estimated anchor positions with a smooth transition
    handles.estimatedAnchors = estimatedAnchors;
    handles.estimatedAnchorsPlot = plotAnchors(handles.estimatedAnchors, estimatedAnchors, 'g', 'Estimated Anchors', 0.5, false); % 2 seconds transition time

    % Store the updated handles structure
    guidata(gcbo, handles);

    % Update legend
    legend();
end
