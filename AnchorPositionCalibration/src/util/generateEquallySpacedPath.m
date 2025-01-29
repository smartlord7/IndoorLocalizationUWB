function path = generateEquallySpacedPath(steps, roomDimensions)
    % Generate a grid of equally spaced points within the room boundaries
    % Steps along x, y, z axes are determined proportionally
    numPointsPerAxis = ceil(nthroot(steps, 3)); % Calculate the number of points per axis
    [x_vals, y_vals, z_vals] = ndgrid(...
        linspace(roomDimensions(1, 1), roomDimensions(1, 2), numPointsPerAxis), ...
        linspace(roomDimensions(2, 1), roomDimensions(2, 2), numPointsPerAxis), ...
        linspace(roomDimensions(3, 1), roomDimensions(3, 2), numPointsPerAxis));
    
    % Combine the grid points into a path array
    allPositions = [x_vals(:), y_vals(:), z_vals(:)];
    
    % Select the first `steps` points from the generated grid
    if size(allPositions, 1) >= steps
        path = allPositions(1:steps, :);
    else
        error('Not enough grid points to generate the desired number of steps.');
    end
end
