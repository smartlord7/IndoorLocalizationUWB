function estimatedAnchors = nonlinearLeastSquares(distances_noisy, trueAnchors, tagPos, bounds)
    % Number of anchors
    numAnchors = size(trueAnchors, 1);
    numVars = numAnchors * 3;
    
    % Define the objective function for the least squares problem
    objectiveFunction = @(anchors) calcResiduals(anchors, trueAnchors, distances_noisy, tagPos, numAnchors);
    
    % Initial guess for the anchor positions (same as true anchors)
    initialGuess = trueAnchors(:);

    % Bounds
    lb = reshape(bounds(1, :, :), numVars, 1);
    ub = reshape(bounds(2, :, :), numVars, 1);

    % Use linear least squares solver to minimize the residuals
    options = optimoptions('lsqnonlin', 'Display', 'final-detailed', 'MaxIterations', 10000, 'Algorithm','levenberg-marquardt');
    [estimatedAnchorsVec, ~] = lsqnonlin(objectiveFunction, initialGuess, lb, ub, options);
    
    % Reshape the vector of estimated anchors back into matrix form
    estimatedAnchors = reshape(estimatedAnchorsVec, [numAnchors, 3]);
end
