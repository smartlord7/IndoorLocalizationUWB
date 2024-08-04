function h = plotAnchors(positions, color, displayName)
        % Plot the anchors and return handles
        [X, Y, Z] = sphere;
        h = [];
        for i = 1:size(positions, 1)
            handle = surf(X + positions(i, 1), Y + positions(i, 2), Z + positions(i, 3), 'FaceColor', color, 'EdgeColor', 'none', 'DisplayName', displayName, 'HandleVisibility', 'off');
            h = [h; handle];
        end
    end