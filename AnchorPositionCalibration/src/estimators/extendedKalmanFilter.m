function estimatedAnchors = extendedKalmanFilter(distances_noisy, noiseVariance, initialGuess, tagPos)
    % Extended Kalman Filter (EKF) for Anchor Calibration
    numAnchors = size(initialGuess, 1);
    
    % Initialize state and covariance
    state = initialGuess(:);
    P = eye(numAnchors * 3) * 1e-3; % Initial covariance
    Q = eye(numAnchors * 3) * 1e-4; % Process noise covariance
    R = diag(ones(numAnchors, 1) * noiseVariance); % Measurement noise covariance
    
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
            distances = sqrt(sum((anchorPos - tagPos).^2, 2));
            dX = (anchorPos(:, 1) - tagPos(1)) ./ distances;
            dY = (anchorPos(:, 2) - tagPos(2)) ./ distances;
            dZ = (anchorPos(:, 3) - tagPos(3)) ./ distances;
            H(i, (i-1)*3 + 1) = dX(i);
            H(i, (i-1)*3 + 2) = dY(i);
            H(i, (i-1)*3 + 3) = dZ(i);
        end
        
        % Update step
        y = distances_noisy - sqrt(sum((reshape(state, [], 3) - tagPos).^2, 2));
        S = H * P_pred * H' + R;
        K = P_pred * H' / S;
        state = state_pred + K * y;
        P = (eye(numAnchors * 3) - K * H) * P_pred;
    end
    
    estimatedAnchors = reshape(state, [], 3);
end