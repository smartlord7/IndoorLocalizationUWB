function estimatedAnchors = maximumLikelihoodEstimation(distances_noisy, initialAnchors, estimatedTag, sigma)
    % Maximum Likelihood Estimation for Anchor Positions
    %
    % Inputs:
    %   distances_noisy - Noisy distance measurements
    %   initialAnchors  - Initial guess of anchor positions (Nx3)
    %   estimatedTag    - Known tag position (1x3)
    %   sigma           - Standard deviation of the noise (default 0.1)
    %
    % Output:
    %   estimatedAnchors - Estimated positions of the anchors (Nx3)

    if nargin < 4
        sigma = 0.1; % Default standard deviation of noise
    end

    % Flatten initial guess of anchors for optimization
    initialGuess = initialAnchors(:);
    
    % Define the cost function for Maximum Likelihood Estimation
    costFunction = @(anchors) calculateLogLikelihood(anchors, distances_noisy, estimatedTag, sigma);
    
    % Optimization settings for fminunc
    options = optimoptions('fminunc', 'Algorithm', 'quasi-newton', 'Display', 'off');
    
    % Optimize using fminunc
    [estimatedAnchorsVector, ~] = fminunc(costFunction, initialGuess, options);
    
    % Reshape the result to get the estimated anchor positions
    estimatedAnchors = reshape(estimatedAnchorsVector, [], 3);
end