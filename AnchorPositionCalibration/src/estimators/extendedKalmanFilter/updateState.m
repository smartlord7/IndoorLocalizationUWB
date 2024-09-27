function [state, P] = updateState(state, P, measurement, anchors, R, tagPos)
    % Measurement function
    z_hat = zeros(size(anchors, 1), 1);
    for i = 1:length(anchors)
        z_hat(i) = norm(state(1:3) - anchors(i, :)'); % Distance from tag to anchor
    end

    % Measurement residual
    H = computeJacobian(state, anchors, tagPos); % Jacobian of the measurement function
    y = measurement - z_hat; % Measurement residual

    % Innovation covariance
    S = H * P * H' + R;

    % Kalman gain
    K = P * H' / S;

    % Update state estimate
    state = state + K * y;

    % Update estimation error covariance
    P = (eye(size(P)) - K * H) * P;
end