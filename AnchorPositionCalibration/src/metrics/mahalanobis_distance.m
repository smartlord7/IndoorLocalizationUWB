function d = mahalanobis_distance(x, y, points)
    % Compute Mahalanobis distance between vectors x and y
    % points is the dataset (rows = points, columns = features)
    
    % Calculate the covariance matrix of the dataset
    covMatrix = cov(points);
    
    % Compute the difference between the two vectors
    delta = x - y;
    
    % Compute the Mahalanobis distance
    d = sqrt(delta' * inv(covMatrix) * delta);
end
