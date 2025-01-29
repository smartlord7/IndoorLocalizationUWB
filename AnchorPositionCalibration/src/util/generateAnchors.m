function trueAnchors = generateAnchors(roomDimensions, numAnchors)
    % Determine the number of anchors per dimension (assuming a cubic grid)
    numAnchorsPerDim = ceil(nthroot(numAnchors, 3)); % Find cube root and round up
    
    % Create linearly spaced points for each dimension
    linspaceX = linspace(roomDimensions(1, 1), roomDimensions(1, 2), numAnchorsPerDim);
    linspaceY = linspace(roomDimensions(2, 1), roomDimensions(2, 2), numAnchorsPerDim);
    linspaceZ = linspace(roomDimensions(3, 1), roomDimensions(3, 2), numAnchorsPerDim);
    
    % Generate grid of points
    [X, Y, Z] = ndgrid(linspaceX, linspaceY, linspaceZ);
    
    % Combine the grid points into an array of 3D coordinates
    gridPoints = [X(:), Y(:), Z(:)];
    
    % Select the first numAnchors points from the grid (if necessary)
    if size(gridPoints, 1) > numAnchors
        trueAnchors = gridPoints(1:numAnchors, :);
    else
        trueAnchors = gridPoints; % In case numAnchors matches or exceeds grid points
    end
end
