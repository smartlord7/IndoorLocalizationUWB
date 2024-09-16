function negLogLikelihood = calculateLogLikelihood(anchors, distances_noisy, estimatedTag, sigma)
    % Reshape anchors to Nx3
    anchors = reshape(anchors, [], 3);
    
    % Compute the distances from the estimated tag to each anchor
    estimatedDistances = sqrt(sum((anchors - estimatedTag).^2, 2));
    
    % Ensure estimatedDistances are valid
    if any(estimatedDistances < 0)
        negLogLikelihood = Inf; % Return a large penalty if distances are invalid
        return;
    end
    
    % Compute the squared error between estimated and noisy distances
    squaredErrors = (estimatedDistances - distances_noisy).^2;
    
    % Compute the log-likelihood manually assuming Gaussian noise
    logLikelihood = -sum(squaredErrors / (2 * sigma^2));
    
    % If logLikelihood is invalid (e.g., NaN or Inf), penalize heavily
    if isnan(logLikelihood) || isinf(logLikelihood)
        negLogLikelihood = Inf; % Penalize invalid likelihoods
    else
        negLogLikelihood = -logLikelihood; % We minimize the negative log-likelihood
    end
end