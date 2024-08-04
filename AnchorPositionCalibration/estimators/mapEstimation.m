function estimatedAnchors = mapEstimation(distances_noisy, trueAnchors, tagPos)
    % Maximum A Posteriori (MAP) Estimation for anchor position
    lambda = 1e-3; % Regularization parameter
    numAnchors = size(trueAnchors, 1);
    A = zeros(numAnchors, 3);
    b = zeros(numAnchors, 1);
    
    for i = 1:numAnchors
        A(i, :) = 2 * (trueAnchors(i, :) - tagPos);
        b(i) = distances_noisy(i)^2 - sum(trueAnchors(i, :).^2) + sum(tagPos.^2);
    end
    
    % Regularization term to avoid overfitting
    R = lambda * eye(3);
    estimatedAnchors = (A' * A + R) \ (A' * b)';
end