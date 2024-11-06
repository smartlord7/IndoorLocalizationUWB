function estimatedAnchors = nonlinearLeastSquares(distances_noisy, trueAnchors, tagPos, bounds, isDynamic)
    % Number of anchors
    numAnchors = size(trueAnchors, 1);
    numVars = numAnchors * 3;
    numSamples = size(tagPos, 1);

    % Define the objective function for the least squares problem
    if isDynamic
        objectiveFunction = @(anchors) calcWeightedResiduals(anchors, distances_noisy, tagPos, numAnchors, numSamples);
    else
        objectiveFunction = @(anchors) calcResiduals(anchors, distances_noisy, tagPos, numAnchors);
    end

    % Initial guess for the anchor positions (same as true anchors)
    initialGuess = trueAnchors(:);

    % Bounds
    lb = reshape(bounds(1, :, :), numVars, 1);
    ub = reshape(bounds(2, :, :), numVars, 1);

    % Use nonlinear least squares solver to minimize the residuals
    options = optimoptions('lsqnonlin', 'Display', 'final-detailed', 'MaxIterations', 10000, 'Algorithm','levenberg-marquardt');
    [estimatedAnchorsVec, ~] = lsqnonlin(objectiveFunction, initialGuess, lb, ub, options);

    % Reshape the vector of estimated anchors back into matrix form
    estimatedAnchors = reshape(estimatedAnchorsVec, [numAnchors, 3]);
end