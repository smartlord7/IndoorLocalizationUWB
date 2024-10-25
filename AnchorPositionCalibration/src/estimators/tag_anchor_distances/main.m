% Modified Estimator function (unchanged, included for completeness)
function estimated_anchors = estimateAnchorPositions(n_anchors, initial_anchors, tag_position, tag_distances, real_anchors, bounds)

    options = optimoptions('lsqnonlin', 'Display', 'off', 'MaxIterations', 100000, 'TolFun', 1e-10);
    init_guess = initial_anchors(:);

    % Precompute true inter-anchor distances
    true_inter_anchor_distances = zeros(n_anchors, n_anchors);
    for i = 1:n_anchors-1
        for j = i+1:n_anchors
            true_inter_anchor_distances(i, j) = norm(real_anchors(i, :) - real_anchors(j, :));
        end
    end
    
    % Objective function
    function error = objective(x)
        estimated_anchors = reshape(x, [n_anchors, 3]);
        tag_dists = sqrt(sum((estimated_anchors - tag_position).^2, 2));
        tag_dist_errors = (tag_dists - tag_distances).^2;
        
        anchor_dist_errors = [];
        for i = 1:n_anchors-1
            for j = i+1:n_anchors
                dist_ij = norm(estimated_anchors(i, :) - estimated_anchors(j, :));
                real_dist_ij = true_inter_anchor_distances(i, j);
                anchor_dist_errors = [anchor_dist_errors; (dist_ij - real_dist_ij).^2];
            end
        end
        error = [tag_dist_errors; anchor_dist_errors];
    end

    numVars = n_anchors * 3;
    lb = reshape(bounds(1, :, :), numVars, 1);
    ub = reshape(bounds(2, :, :), numVars, 1);
    estimated_flat = lsqnonlin(@objective, init_guess, lb, ub, options);
    estimated_anchors = reshape(estimated_flat, [n_anchors, 3]);
end

% Example setup and initialization
rng(0);
n_anchors = 8;
std = 1; 
mx = [10 10 10];
bounds = buildBounds(mx, n_anchors);

real_anchors = generateAnchors(mx, n_anchors);
initial_anchors = real_anchors + std * randn(n_anchors, 3);

% Define grid space and step size for the tag position
[grid_x, grid_y, grid_z] = meshgrid(0:1:30, 0:1:30, 0:1:10); % Using meshgrid

error_grid = zeros(size(grid_x));

% Loop through each grid position, calculate error at each
for ix = 1:numel(grid_x)
    disp("Position " + ix);
    % Current tag position
    tag_position = [grid_x(ix), grid_y(ix), grid_z(ix)];
    
    % True distances from current tag position to anchors
    tag_distances = sqrt(sum((real_anchors - tag_position).^2, 2));
    
    % Estimate anchor positions based on current tag position
    estimated_anchors = estimateAnchorPositions(n_anchors, initial_anchors, tag_position, tag_distances, real_anchors, bounds);
    
    % Calculate mean squared error between true and estimated anchors
    error_grid(ix) = mean(sqrt(sum((estimated_anchors - real_anchors).^2, 2)));
end

% Plotting the error as a 3D surface
figure;
slice(grid_x, grid_y, grid_z, error_grid, [], [], 0:1:10); % Slices along z-axis levels
colormap(jet); % Color map for error intensity
colorbar; % Display color scale
xlabel('X');
ylabel('Y');
zlabel('Z');
title('Anchor Position Estimation Error Across 3D Space');

