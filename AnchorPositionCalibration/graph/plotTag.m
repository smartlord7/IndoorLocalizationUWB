function h = plotTag(position, color, displayName)
        % Define the vertices of the cube
        [X, Y, Z] = meshgrid([-.5 .5], [-.5 .5], [-.5 .5]);
        X = X(:) + position(1);
        Y = Y(:) + position(2);
        Z = Z(:) + position(3);

        % Define the faces of the cube
        F = [1 2 6 5; 2 4 8 6; 4 3 7 8; 3 1 5 7; 1 2 4 3; 5 6 8 7];

        % Plot the cube and return handle
        h = patch('Vertices', [X Y Z], 'Faces', F, 'FaceColor', color, 'EdgeColor', 'none', 'DisplayName', displayName, 'HandleVisibility', 'off');
    end