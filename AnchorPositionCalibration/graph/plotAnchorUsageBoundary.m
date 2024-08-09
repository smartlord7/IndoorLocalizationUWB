function usageBoundaryPlot = plotAnchorUsageBoundary(anchors, radius)
    % Generate a 3D grid
    [X, Y, Z] = ndgrid(linspace(0, 40, 50), linspace(0, 40, 50), linspace(0, 40, 50));
    gridSize = size(X);

    % Calculate distances from each grid point to all anchors
    distToAnchors = sqrt(sum((reshape(X, [], 1) - anchors(:,1)').^2 + ...
                              (reshape(Y, [], 1) - anchors(:,2)').^2 + ...
                              (reshape(Z, [], 1) - anchors(:,3)').^2, 2));

    % Calculate the number of anchors within range
    inRangeCount = sum(distToAnchors < radius, 2);
    inRangeCount = reshape(inRangeCount, gridSize);

    % Create a colormap from red (few anchors) to green (many anchors)
    cmap = [linspace(1,0,10)', linspace(1,0,10)', linspace(1,0,10)']; % Red to green gradient

    % Plot the anchor usage boundary with color gradient
    hold on;
    usageBoundaryPlot = isosurface(X, Y, Z, inRangeCount, 0.5); % 0.5 threshold to create surface
    patch(usageBoundaryPlot, 'FaceColor', 'interp', 'EdgeColor', 'none', 'FaceAlpha', 0.3);
    colormap(cmap);
    colorbar;
end
