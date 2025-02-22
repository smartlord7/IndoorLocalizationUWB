function [estimatedTagPosition] = trilateration(trueAnchors, estimatedAnchors, trueTagPosition, anchorTransmissionRadius, toaStd, initialGuess)
    % Calculate distances from true tag position to each anchor
    distances = sqrt(sum((trueAnchors - trueTagPosition).^2, 2));

    % Filter anchors based on transmission radius
    validAnchors = distances <= anchorTransmissionRadius;
    
    if sum(validAnchors) < 3
        error('Not enough anchors within the transmission radius for localization.');
    end

    % Only consider valid anchors
    filteredAnchors = estimatedAnchors(validAnchors, :);
    filteredDistances = distances(validAnchors);

    % Calculate ToA
    c = 3e8; % Speed of light
    ToA = filteredDistances / c;

    % Add Noise to ToA
    ToA_noisy = ToA + randn(size(ToA)) * toaStd; % Add noise with standard deviation of 1 ns

    % Calculate anchor calibration errors (deviation from true anchors)
    % anchorErrors = sqrt(sum((filteredAnchors - trueAnchors(validAnchors, :)).^2, 2));
    
    % Multilateration to estimate tag position with anchor deviation penalty
    costFunction = @(pos) sum(((sqrt(sum((filteredAnchors - pos).^2, 2)) - ToA_noisy * c)).^2);

    % Initial guess for the tag position
    % initialGuess = trueTagPosition + randn(size(trueTagPosition)) * tagPosStd;

    % Use lsqnonlin to minimize the error
    options = optimoptions('lsqnonlin', 'Display', 'off', 'Algorithm', 'levenberg-marquardt');
    estimatedTagPosition = lsqnonlin(costFunction, initialGuess, [], [], options);
end

