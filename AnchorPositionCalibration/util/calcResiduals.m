function residuals = calcResiduals(anchors, trueAnchors, distances_noisy, tagPos, numAnchors)
    % Reshape the vector of anchor positions into matrix form
    anchors = reshape(anchors, [numAnchors, 3]);
    
    % Compute residuals
    residuals = zeros(numAnchors, 1);
    for i = 1:numAnchors
        predictedDistance = norm(anchors(i, :) - tagPos);
        residuals(i) = predictedDistance - distances_noisy(i);
    end
    
    % Flatten residuals into a vector
    residuals = residuals(:);
end