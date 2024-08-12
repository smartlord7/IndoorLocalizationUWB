function estimatedAnchors = weightedLeastSquares(distances_noisy, initialAnchors, tagPos)
    % Weighted Least Squares for anchor position estimation
    numAnchors = size(initialAnchors, 1);
    weights = 1 ./ (distances_noisy .^ 2); % Inverse of squared noisy distances
    W = diag(weights); % Weight matrix
    
    A = zeros(numAnchors, 3);
    b = zeros(numAnchors, 1);
    
    for i = 1:numAnchors
        A(i, :) = 2 * (initialAnchors(i, :) - tagPos);
        b(i) = distances_noisy(i) ^ 2 - sum(initialAnchors(i, :) .^ 2) + sum(tagPos .^ 2);
    end
    
    % Solve the weighted least squares problem
    estimatedTagPos = (A' * W * A) \ (A' * W * b);
    
    % Adjust anchors based on estimated tag position
    estimatedAnchors = initialAnchors + repmat(estimatedTagPos' - tagPos, numAnchors, 1);
    
    % Correct translation by aligning centroids
    estimatedCentroid = mean(estimatedAnchors, 1);
    trueCentroid = mean(initialAnchors, 1);
    translationCorrection = trueCentroid - estimatedCentroid;
    estimatedAnchors = estimatedAnchors + repmat(translationCorrection, numAnchors, 1);
end
