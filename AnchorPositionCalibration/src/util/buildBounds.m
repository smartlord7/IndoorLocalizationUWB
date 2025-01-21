function [bounds] = buildBounds(roomDimensions, numAnchors)
    % roomDimensions: A 3x2 matrix where each row contains the min and max for x, y, and z
    % numAnchors: Number of anchors

    % Extract the lower and upper bounds from the roomDimensions
    lb = repmat(roomDimensions(:, 1)', numAnchors, 1); % Lower bounds (replicated for each anchor)
    ub = repmat(roomDimensions(:, 2)', numAnchors, 1); % Upper bounds (replicated for each anchor)

    % Initialize bounds as a 2xNAnchorsx3 array
    bounds = zeros(2, numAnchors, 3);  % 2 levels (lower/upper), numAnchors, 3 (x, y, z)

    % Assign lower bounds (1st row)
    bounds(1, :, :) = lb;

    % Assign upper bounds (2nd row)
    bounds(2, :, :) = ub;
end
