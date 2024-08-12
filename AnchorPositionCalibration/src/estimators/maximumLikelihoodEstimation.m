function estimatedAnchors = maximumLikelihoodEstimation(distances_noisy, initialAnchors, estimatedTag)
        % Maximum Likelihood Estimation
        costFunction = @(anchors) -sum(log(normpdf(sqrt(sum((reshape(anchors, [], 3) - estimatedTag).^2, 2)), distances_noisy, 0.1)));
        initialGuess = initialAnchors(:);
        estimatedAnchors = fminsearch(costFunction, initialGuess);
        estimatedAnchors = reshape(estimatedAnchors, [], 3);
    end