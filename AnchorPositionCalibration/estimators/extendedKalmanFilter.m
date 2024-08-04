function estimatedAnchors = extendedKalmanFilter(distances_noisy, initialAnchors, trueTagPosition)
    % Extended Kalman Filter (EKF) for Anchor Calibration
    numAnchors = size(initialAnchors, 1);
    
    % Initialize state and covariance
    state = initialAnchors(:);
    P = eye(numAnchors * 3) * 1e-3; % Initial covariance
    Q = eye(numAnchors * 3) * 1e-4; % Process noise covariance
    R = diag(ones(numAnchors, 1) * 0.1); % Measurement noise covariance
    
    % Number of measurements
    numMeasurements = length(distances_noisy);
    
    % Kalman filter iteration
    for k = 1:numMeasurements
        % Predict step
        state_pred = state; % No control input in this simplified version
        P_pred = P + Q;
        
        % Measurement matrix H (partial derivatives of the measurement function)
        H = zeros(numMeasurements, numAnchors * 3);
        for i = 1:numMeasurements
            anchorPos = reshape(state, [], 3);
            distances = sqrt(sum((anchorPos - trueTagPosition).^2, 2));
            dX = (anchorPos(:, 1) - trueTagPosition(1)) ./ distances;
            dY = (anchorPos(:, 2) - trueTagPosition(2)) ./ distances;
            dZ = (anchorPos(:, 3) - trueTagPosition(3)) ./ distances;
            H(i, (i-1)*3 + 1) = dX(i);
            H(i, (i-1)*3 + 2) = dY(i);
            H(i, (i-1)*3 + 3) = dZ(i);
        end
        
        % Update step
        y = distances_noisy - sqrt(sum((reshape(state, [], 3) - trueTagPosition).^2, 2));
        S = H * P_pred * H' + R;
        K = P_pred * H' / S;
        state = state_pred + K * y;
        P = (eye(numAnchors * 3) - K * H) * P_pred;
    end
    
    estimatedAnchors = reshape(state, [], 3);
end