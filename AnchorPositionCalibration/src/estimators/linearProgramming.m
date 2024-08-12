function estimatedAnchors = linearProgramming(distances_noisy, trueAnchors, bounds)
    % Linear Programming for anchor position estimation
    numAnchors = size(trueAnchors, 1);

    % Define the objective function coefficients for the linear programming
    % The objective is to minimize the sum of the squared errors
    f = ones(numAnchors, 1);

    % Set up the constraints for the optimization
    % We will use linear inequalities to ensure the distances are met

    % Define the bounds for the anchor positions
    lb = bounds(1, :, :);
    ub = bounds(2, :, :);

    % Flatten bounds for linear programming
    lb = lb(:);
    ub = ub(:);

    % Create the A matrix for inequality constraints
    A = [];
    b = [];

    % Compute the distance constraints
    for i = 1:numAnchors
        % Calculate the distances from the tag position to each anchor
        % This forms linear inequalities in the form of A * x <= b
        A_row = zeros(numAnchors, numAnchors);
        A_row(i, i) = 1;
        A = [A; A_row];
        b = [b; distances_noisy(i)];
    end

    % Run the linear programming optimization
    options = optimoptions('linprog', 'Display', 'iter', 'Algorithm', 'dual-simplex-highs', 'MaxIterations', 10000);
    [x, ~] = linprog(f, A, b, [], [], lb, ub, options);

    % Reshape the result into the original format
    estimatedAnchors = reshape(x, numAnchors, 3);
end