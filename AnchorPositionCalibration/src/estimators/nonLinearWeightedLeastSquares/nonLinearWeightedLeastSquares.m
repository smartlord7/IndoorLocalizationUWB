function estimatedAnchors = nonLinearWeightedLeastSquares(distances_noisy, initialAnchors, tagPos)
    % Non-Linear Weighted Least Squares for anchor position estimation

    numAnchors = size(initialAnchors, 1);
    
    % Define the weights (inverse of squared noisy distances, to emphasize more reliable measurements)
    weights = 1 ./ (distances_noisy .^ 2); %  Weights

    % Define the cost function for non-linear optimization
    costFunction = @(anchors) computeWeightedCost(anchors, distances_noisy, tagPos, numAnchors, weights);

    % Flatten initial guess for optimization
    initialGuess = initialAnchors(:);
    
    % Use fminunc for non-linear optimization
    options = optimoptions('fminunc', 'Algorithm', 'quasi-newton', 'Display', 'iter', 'GradObj', 'on');
    [estimatedAnchorsVec, ~] = fminunc(costFunction, initialGuess, options);
    
    % Reshape the optimized vector back to matrix form
    estimatedAnchors = reshape(estimatedAnchorsVec, [], 3);
end