function estimatedAnchors = nonlinearLeastSquares(distances_noisy, initialAnchors, estimatedTag)
        % Nonlinear Least Squares Optimization
        costFunction = @(anchors) sum((sqrt(sum((reshape(anchors, [], 3) - estimatedTag).^2, 2)) - distances_noisy).^2);
        initialGuess = initialAnchors(:);
        estimatedAnchors = fminsearch(costFunction, initialGuess);
        estimatedAnchors = reshape(estimatedAnchors, [], 3);
    end