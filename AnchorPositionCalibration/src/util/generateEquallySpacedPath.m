function path = generateEquallySpacedPath(steps, mx)
    % Generate a grid of equally spaced points within the room boundaries
    % Steps along x, y, z axes are determined proportionally
    numPointsPerAxis = ceil(nthroot(steps, 3)); % Calculate the number of points per axis
    [x_vals, y_vals, z_vals] = ndgrid(...
        linspace(0, mx(1), numPointsPerAxis), ...
        linspace(0, mx(2), numPointsPerAxis), ...
        linspace(0, mx(3), numPointsPerAxis));
    
    % Combine the grid points into a path array
    allPositions = [x_vals(:), y_vals(:), z_vals(:)];
    
    % Select the first `steps` points from the generated grid
    if size(allPositions, 1) >= steps
        path = allPositions(1:steps, :);
    else
        error('Not enough grid points to generate the desired number of steps.');
    end
end
