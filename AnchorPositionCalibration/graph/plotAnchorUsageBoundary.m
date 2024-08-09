function [usageBoundaryPlot, plotHandles] = plotAnchorUsageBoundary(anchors, radius, axesHandle)
    % Generate a higher resolution 3D grid using meshgrid
    [X, Y, Z] = meshgrid(linspace(-30, 50, 100), linspace(-20, 50, 100), linspace(-30, 50, 100));
    gridSize = size(X);

    % Number of anchors
    nAnchors = size(anchors, 1);

    % Initialize distance matrix
    distToAnchors = zeros([gridSize, nAnchors]);

    % Calculate distances from each grid point to all anchors
    for i = 1:nAnchors
        distToAnchors(:,:,:,i) = sqrt((X - anchors(i,1)).^2 + ...
                                      (Y - anchors(i,2)).^2 + ...
                                      (Z - anchors(i,3)).^2);
    end

    % Calculate the number of anchors within range
    inRangeCount = sum(distToAnchors < radius, 4);

    % Initialize color map (from blue for 1 anchor to red for nAnchors)
    colors = jet(nAnchors);

    % Plot different isosurfaces for each number of anchors in range
    hold(axesHandle, 'on');
    usageBoundaryPlot = gobjects(1, nAnchors);
    plotHandles = gobjects(1, nAnchors); % To store handles for toggles

    for k = 1:nAnchors
        % Create isosurface for regions with exactly k anchors within range
        isoSurface = isosurface(X, Y, Z, inRangeCount, k - 0.5);
        if ~isempty(isoSurface.vertices)
            usageBoundaryPlot(k) = patch(axesHandle, isoSurface, ...
                'FaceColor', colors(k, :), ...
                'EdgeColor', 'none', ...
                'FaceAlpha', 0.1);
        end

        % Store plot handle for each boundary
        plotHandles(k) = usageBoundaryPlot(k);
    end

    % Optionally adjust visualization
    camlight; lighting(axesHandle, 'gouraud'); % Improves lighting for the patches

    % Set visibility
    set(usageBoundaryPlot, 'Visible', 'on');
end