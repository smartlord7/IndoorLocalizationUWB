function estimatedAnchors = linearLeastSquares(distances_noisy, trueAnchors, tagPos)
    % Number of anchors
    numAnchors = size(trueAnchors, 1);
    
    % Define the objective function for the least squares problem
    objectiveFunction = @(anchors) calcResiduals(anchors, trueAnchors, distances_noisy, tagPos, numAnchors);
    
    % Initial guess for the anchor positions (same as true anchors)
    initialGuess = trueAnchors(:);
    
    % Use linear least squares solver to minimize the residuals
    options = optimoptions('lsqlin', 'Display', 'off');
    [estimatedAnchorsVec, ~] = lsqlin(objectiveFunction, initialGuess, [], [], options);
    
    % Reshape the vector of estimated anchors back into matrix form
    estimatedAnchors = reshape(estimatedAnchorsVec, [numAnchors, 3]);
end
