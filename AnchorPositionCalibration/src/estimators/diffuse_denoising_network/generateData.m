function [noisyDistances, cleanDistances, trueAnchors, tagPositions] = generateData(numSamples, numAnchors, maxNoise)
    % Parameters
    maxPosition = 10; % Maximum coordinate value for positions
    numDimensions = 3; % Number of dimensions (x, y, z)

    % Initialize data matrices
    noisyDistances = zeros(numSamples, numAnchors); % Noisy distances
    cleanDistances = zeros(numSamples, numAnchors); % Clean distances
    trueAnchors = zeros(numSamples, numAnchors * numDimensions); % True anchor positions
    tagPositions = zeros(numSamples, numDimensions); % Tag positions

    % Generate training samples
    for i = 1:numSamples
        % Simulate random anchor positions
        anchors = rand(numAnchors, numDimensions) * maxPosition;
        
        % Simulate random tag position
        tagPos = rand(1, numDimensions) * maxPosition;
        
        % Compute true distances
        distances = sqrt(sum((anchors - tagPos).^2, 2));
        
        % Generate random noise
        noiseStdDev = rand * maxNoise; % Random noise level for each sample
        noise = randn(size(distances)) * noiseStdDev;
        noisyDistancesSample = distances + noise;
        
        % Store data
        noisyDistances(i, :) = noisyDistancesSample';
        cleanDistances(i, :) = distances';
        trueAnchors(i, :) = anchors(:)'; % Flattened true anchor positions
        tagPositions(i, :) = tagPos; % Store tag position
    end
end
