function estimatedAnchors = iterativeRefinement(distances_noisy, initialAnchors, tagPos)
    % Iterative Refinement for anchor position estimation
    % distances_noisy: Noisy distances from the tag to the anchors
    % initialAnchors: Initial guess for anchor positions
    % tagPos: Current tag position

    maxIter = 100000; % Maximum number of iterations
    tol = 1e-6; % Convergence tolerance
    
    % Initialize with the provided initial guess
    estimatedAnchors = initialAnchors;

    for iter = 1:maxIter
        % Compute the current estimated distances
        estimatedDistances = sqrt(sum((estimatedAnchors - tagPos).^2, 2));
        
        % Compute the Jacobian matrix
        % Compute the matrix A where each row represents the partial derivatives
        A = (estimatedAnchors - tagPos) ./ estimatedDistances;
        A(isnan(A)) = 0; % Handle NaN values if distances are zero
        
        % Compute the correction vector
        B = distances_noisy - estimatedDistances;
        % Ensure A' * A is invertible
        if rcond(A' * A) < eps
            warning('Matrix A'' * A is nearly singular. Refinement might be unstable.');
            break;
        end
        
        correction = (A' * A) \ (A' * B);
        
        % Update the anchor positions
        estimatedAnchors = estimatedAnchors + correction';
        
        % Check for convergence
        if norm(correction) < tol
            disp(['Converged after ', num2str(iter), ' iterations.']);
            return; % Exit if converged
        end
    end
    
    disp('Maximum number of iterations reached without convergence.');
end
