function estimatedAnchors = extendedKalmanFilter(distances_noisy, initialAnchorsNoise, distanceNoise, initialGuess, tagPos)
    % Extended Kalman Filter (EKF) for Anchor Calibration
    numAnchors = size(initialGuess, 1);
    
    % Initialize state and covariance
    state = initialGuess(:);
    P = eye(numAnchors * 3) * (initialAnchorsNoise * 1e-3); % Adjust as necessary
    Q = eye(numAnchors * 3) * 1e-5; % Process noise covariance; consider increasing this value
    R = diag(ones(numAnchors, 1) * distanceNoise); % Measurement noise covariance; use distanceNoise only
    
    % Number of measurements
    numMeasurements = length(distances_noisy);
    
    % Kalman filter iteration
    for k = 1:numMeasurements
        % Predict step
        state_pred = state; % Assuming no motion model for anchors
        P_pred = P + Q; % Predict the covariance
        
        % Measurement matrix H (partial derivatives of the measurement function)
        H = zeros(numAnchors, numAnchors * 3); % Adjusted size to numAnchors x (numAnchors*3)
        anchorPos = reshape(state, [], 3); % Calculate anchor positions once outside the loop
        distances = sqrt(sum((anchorPos - tagPos).^2, 2)); % Compute distances from tag to anchors
        dX = (anchorPos(:, 1) - tagPos(1)) ./ distances; % Derivatives
        dY = (anchorPos(:, 2) - tagPos(2)) ./ distances;
        dZ = (anchorPos(:, 3) - tagPos(3)) ./ distances;

        % Fill H matrix with computed derivatives
        for i = 1:numAnchors
            H(i, (i-1)*3 + 1) = dX(i);
            H(i, (i-1)*3 + 2) = dY(i);
            H(i, (i-1)*3 + 3) = dZ(i);
        end
        
        % Update step
        y = distances_noisy - distances; % Measurement residual
        S = H * P_pred * H' + R; % Innovation covariance
        K = P_pred * H' / S; % Kalman gain
        
        % Debugging: Check the Kalman gain and residual
        fprintf('Iteration %d:\n', k);
        fprintf('Kalman Gain:\n'); disp(K);
        fprintf('Residual (y):\n'); disp(y);
        
        state = state_pred + K * y; % State update
        P = (eye(numAnchors * 3) - K * H) * P_pred; % Covariance update
    end
    
    estimatedAnchors = reshape(state, [], 3); % Reshape state into 3D coordinates
end
