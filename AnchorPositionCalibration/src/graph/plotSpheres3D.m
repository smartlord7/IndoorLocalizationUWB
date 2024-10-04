
% Helper function to plot spheres for 3D visualization
function plotSpheres3D(x, y, z, color, radius)
    [X, Y, Z] = sphere(20); % Generate a sphere with 20-by-20 faces
    for i = 1:length(x)
        surf(radius * X + x(i), radius * Y + y(i), radius * Z + z(i), ...
            'FaceColor', color, 'EdgeColor', 'none', 'FaceLighting', 'gouraud');
    end
end