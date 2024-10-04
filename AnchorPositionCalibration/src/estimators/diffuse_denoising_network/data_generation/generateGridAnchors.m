% Modified grid generation function with perturbation
function anchors = generateGridAnchors(numAnchors, xRange, yRange, zRange)
    % Create a grid with anchors roughly spaced within the range
    gridSize = ceil(numAnchors^(1/3));  % Cube root of numAnchors for 3D grid
    [X, Y, Z] = ndgrid(linspace(xRange(1), xRange(2), gridSize), ...
                       linspace(yRange(1), yRange(2), gridSize), ...
                       linspace(zRange(1), zRange(2), gridSize));

    % Reshape into a set of points
    anchors = [X(:), Y(:), Z(:)];

    % Randomly sample the required number of anchors if more points are generated
    if size(anchors, 1) > numAnchors
        anchors = anchors(randperm(size(anchors, 1), numAnchors), :);
    end

    % Add a small random perturbation to each anchor's position
    perturbation = 0.05 * (xRange(2) - xRange(1)) * randn(size(anchors));
    anchors = anchors + perturbation;
end