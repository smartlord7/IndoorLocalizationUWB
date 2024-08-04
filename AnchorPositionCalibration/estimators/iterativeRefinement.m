function estimatedAnchors = iterativeRefinement(distances_noisy, trueAnchors, tagPos)
    % Iterative Refinement for anchor position estimation
    maxIter = 10;
    tol = 1e-6;
    estimatedAnchors = trueAnchors;

    for iter = 1:maxIter
        % Compute the current estimated distances
        estimatedDistances = sqrt(sum((estimatedAnchors - tagPos).^2, 2));
        
        % Update positions
        A = (estimatedAnchors - tagPos) ./ estimatedDistances;
        B = distances_noisy - estimatedDistances;
        correction = (A' * A) \ (A' * B);
        estimatedAnchors = estimatedAnchors + correction';
        
        % Check for convergence
        if norm(correction) < tol
            break;
        end
    end
end
