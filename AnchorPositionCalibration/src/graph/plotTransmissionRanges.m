function h = plotTransmissionRanges(positions, radius)
    % Plot translucent spheres representing transmission range of each anchor
    [X, Y, Z] = sphere;
    numAnchors = size(positions, 1);
    h = gobjects(numAnchors, 1);

    for i = 1:numAnchors
        h(i) = surf(X * radius + positions(i, 1), ...
                    Y * radius + positions(i, 2), ...
                    Z * radius + positions(i, 3), ...
                    'FaceColor', [0.5 0.5 0.5], 'FaceAlpha', 0.3, 'EdgeColor', 'none', ...
                    'HandleVisibility', 'off');
    end
end