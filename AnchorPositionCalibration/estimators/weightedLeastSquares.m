function estimatedAnchors = weightedLeastSquares(distances_noisy, trueAnchors, tagPos)
    % Weighted Least Squares for anchor position estimation
    numAnchors = size(trueAnchors, 1);
    weights = 1 ./ (distances_noisy + 0.1); % Example weights (adjust as needed)
    W = diag(weights);
    A = zeros(numAnchors, 3);
    b = zeros(numAnchors, 1);

    for i = 1:numAnchors
        A(i, :) = 2 * (trueAnchors(i, :) - tagPos);
        b(i) = distances_noisy(i)^2 - sum(trueAnchors(i, :).^2) + sum(tagPos.^2);
    end

    % Solve for the estimated tag position
    estimatedTagPos = (A' * W * A) \ (A' * W * b);

    % Adjust the anchor positions based on the estimated tag position
    estimatedAnchors = trueAnchors + repmat(estimatedTagPos' - tagPos, numAnchors, 1);
end
