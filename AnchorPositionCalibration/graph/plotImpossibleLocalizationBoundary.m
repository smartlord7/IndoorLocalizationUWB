function boundaryPlot = plotImpossibleLocalizationBoundary(anchors, radius)
    % Generate a 3D grid
    [X, Y, Z] = ndgrid(linspace(0, 40, 50), linspace(0, 40, 50), linspace(0, 40, 50));
    gridSize = size(X);

    % Calculate distances from each grid point to all anchors
    distToAnchors = sqrt(sum((reshape(X, [], 1) - anchors(:,1)').^2 + ...
                              (reshape(Y, [], 1) - anchors(:,2)').^2 + ...
                              (reshape(Z, [], 1) - anchors(:,3)').^2, 2));

    % Determine if a point is within any anchor's radius
    inRange = any(distToAnchors < radius, 2);
    inRange = reshape(inRange, gridSize);

    % Plot the impossible localization region
    hold on;
    boundaryPlot = patch(isosurface(X, Y, Z, ~inRange, 0), 'FaceColor', 'red', 'FaceAlpha', 0.3, 'EdgeColor', 'none');
    set(boundaryPlot, 'Visible', 'on'); % Initially shown
end