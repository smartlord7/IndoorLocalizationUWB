% Define Estimator function (unchanged)
function estimated_anchors = estimateAnchorPositions(n_anchors, initial_anchors, tag_position, tag_distances, true_inter_anchor_distances, real_anchors, bounds)

    options = optimoptions('lsqnonlin', 'Display', 'off', 'MaxIterations', 1000, 'TolFun', 1e-6);
    init_guess = initial_anchors(:);
    
    % Optimized Objective function
    function error = objective(x)
        estimated_anchors = reshape(x, [n_anchors, 3]);
    
        % Compute tag-anchor distance errors (vectorized)
        tag_dists = sqrt(sum((estimated_anchors - tag_position).^2, 2));
        tag_dist_errors = (tag_dists - tag_distances).^2;
    
        % Precompute pairwise inter-anchor distances (vectorized)
        [i_idx, j_idx] = find(triu(ones(n_anchors), 1)); % Get index pairs for unique upper triangle
        dist_diffs = sqrt(sum((estimated_anchors(i_idx, :) - estimated_anchors(j_idx, :)).^2, 2)) - ...
                     true_inter_anchor_distances(sub2ind(size(true_inter_anchor_distances), i_idx, j_idx));
        anchor_dist_errors = dist_diffs.^2;
    
        % Combine errors
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


% Precompute true inter-anchor distances
true_inter_anchor_distances = zeros(n_anchors, n_anchors);
for i = 1:n_anchors-1
    for j = i+1:n_anchors
        true_inter_anchor_distances(i, j) = norm(real_anchors(i, :) - real_anchors(j, :));
    end
end

% Define 2D grid space for the tag position
[x_vals, y_vals] = meshgrid(linspace(0, mx(1), 100), linspace(0, mx(2), 100));
error_grid = zeros(size(x_vals));

% Loop through each grid position, calculate error at each
for ix = 1:numel(x_vals)
    disp("Position " + ix);
    % Current tag position in 2D
    tag_position = [x_vals(ix), y_vals(ix), 0];  % Fixed z-coordinate

    % True distances from current tag position to anchors
    tag_distances = sqrt(sum((real_anchors - tag_position).^2, 2));

    % Estimate anchor positions based on current tag position
    estimated_anchors = estimateAnchorPositions(n_anchors, initial_anchors, tag_position, tag_distances, true_inter_anchor_distances, real_anchors, bounds);

    % Calculate mean squared error between true and estimated anchors
    error_grid(ix) = mean(sqrt(sum((estimated_anchors - real_anchors).^2, 2)));
end

% Plotting the error as a 3D surface
figure;
surf(x_vals, y_vals, error_grid, 'EdgeColor', 'none');
colormap(jet); % Color map for error intensity
colorbar; % Display color scale
xlabel('X');
ylabel('Y');
zlabel('Estimation Error');
title('Anchor Position Estimation Error Across X-Y Space');
