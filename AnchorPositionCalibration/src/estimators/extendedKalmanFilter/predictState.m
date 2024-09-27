function [state, P] = predictState(state, P, Q)
    % State transition model (assuming constant position for the tag)
    F = eye(length(state)); % State transition matrix

    % Predict state
    state = F * state;  % State prediction
    
    % Predict error covariance
    P = F * P * F' + Q; % Error covariance prediction
end