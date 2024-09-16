function estimatedAnchors = linearLeastSquares(distances_noisy, initialAnchors, tagPos)
    % Number of anchors
    numAnchors = size(initialAnchors, 1);

    % Initialize the matrix A and vector b for the linear system Ax = b
    A = zeros(numAnchors * 3, numAnchors * 3);  % 3 coordinates per anchor
    b = zeros(numAnchors * 3, 1);  % Corresponding b vector

    % Build the linear system for each anchor
    for i = 1:numAnchors
        % Current initial guess of the anchor position
        anchorInitial = initialAnchors(i, :);

        % Distance from the tag to the current anchor (noisy)
        distance = distances_noisy(i);
        
        % Set up the linear equations for each axis (x, y, z)
        A(3*i-2:3*i, 3*i-2:3*i) = eye(3);  % Identity matrix for x, y, z coefficients
        b(3*i-2:3*i) = tagPos + (distance / norm(anchorInitial - tagPos)) * (anchorInitial - tagPos);
    end

    % Solve the linear system
    estimatedAnchorsVector = A \ b;  % Linear least squares solution

    % Reshape the result to get the estimated anchor positions
    estimatedAnchors = reshape(estimatedAnchorsVector, [], 3);
end