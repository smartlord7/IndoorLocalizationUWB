function [cost, grad] = computeWeightedCost(anchors, distances_noisy, tagPos, numAnchors, weights)
    % Reshape the vector of anchor positions into matrix form
    anchors = reshape(anchors, [numAnchors, 3]);
    
    % Compute predicted distances
    predictedDistances = sqrt(sum((anchors - tagPos).^2, 2));
    
    % Compute residuals
    residuals = predictedDistances - distances_noisy;
    
    % Compute weighted cost (sum of weighted squared residuals)
    cost = sum(weights .* residuals.^2);
    
    % Compute the gradient of the weighted cost function
    if nargout > 1
        grad = zeros(numAnchors * 3, 1);
        for i = 1:numAnchors
            d = predictedDistances(i);
            if d > 1e-6 % Avoid division by zero
                gradient = 2 * (anchors(i, :) - tagPos) / d;
                grad((i-1)*3+1:(i-1)*3+3) = weights(i) * gradient .* residuals(i);
            end
        end
    end
end