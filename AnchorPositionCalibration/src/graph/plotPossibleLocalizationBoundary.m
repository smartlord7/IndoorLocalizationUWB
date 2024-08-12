function boundaryPlot = plotPossibleLocalizationBoundary(anchors, radius)
    % Generate a 3D grid
    [X, Y, Z] = ndgrid(linspace(-30, 50, 100), linspace(-30, 50, 100), linspace(-30, 50, 100));
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

    % Determine how many anchors are within range at each point
    inRangeCount = sum(distToAnchors < radius, 4);

    % Identify regions where at least 3 anchors are within range (for trilateration)
    localizationPossible = inRangeCount >= 3;

    % Plot the possible localization region
    hold on;
    boundaryPlot = patch(isosurface(X, Y, Z, localizationPossible, 0.5), 'FaceColor', 'red', 'FaceAlpha', 0.2, 'EdgeColor', 'none');
    set(boundaryPlot, 'Visible', 'on'); % Initially shown
    
    % Optionally adjust visualization
    camlight; lighting gouraud; % Improves lighting for the patch
end
