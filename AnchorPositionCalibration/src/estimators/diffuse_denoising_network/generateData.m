function [noisyDistances, cleanDistances, noisyAnchors, trueAnchors, tagPositions] = generateData(numSamplesPerStd, numAnchors, stdDevs, anchorPosNoiseStd, varargin)
    % Parameters with default values
    if nargin < 3 || isempty(stdDevs)
        stdDevs = [0.1, 0.5, 1.0]; % Default distance standard deviations
    end
    if nargin < 4 || isempty(anchorPosNoiseStd)
        anchorPosNoiseStd = 1.0; % Default standard deviation for anchor position noise
    end
    if nargin < 5
        xMin = 0; xMax = 10;
        yMin = 0; yMax = 10;
        zMin = 0; zMax = 10;
    else
        % Assign variable arguments for min and max positions
        xMin = varargin{1}(1); xMax = varargin{1}(2);
        yMin = varargin{2}(1); yMax = varargin{2}(2);
        zMin = varargin{3}(1); zMax = varargin{3}(2);
    end
    
    % Total samples
    totalSamples = numSamplesPerStd * length(stdDevs);

    % Initialize data matrices
    numDimensions = 3; % x, y, z
    noisyDistances = zeros(totalSamples, numAnchors + 1); % Noisy distances
    cleanDistances = zeros(totalSamples, numAnchors); % Clean distances
    trueAnchors = zeros(totalSamples, numAnchors * numDimensions); % True anchor positions
    noisyAnchors = zeros(totalSamples, numAnchors * numDimensions); % Noisy anchor positions (with uncertainty)
    tagPositions = zeros(totalSamples, numDimensions); % Tag positions

    % Generate data for each noise level
    sampleIndex = 1; % To keep track of current sample index
    for stdIdx = 1:length(stdDevs)
        noiseStdDev = stdDevs(stdIdx); % Noise level for this group of samples

        for sample = 1:numSamplesPerStd
            % Simulate random anchor positions within [min, max] range for x, y, z
            anchors = [rand(numAnchors, 1) * (xMax - xMin) + xMin, ...
                       rand(numAnchors, 1) * (yMax - yMin) + yMin, ...
                       rand(numAnchors, 1) * (zMax - zMin) + zMin];

            % Introduce noise to the anchor positions to simulate uncertainty
            noisyAnchorsSample = anchors + randn(numAnchors, numDimensions) * anchorPosNoiseStd;

            % Simulate random tag position within [min, max] range for x, y, z
            tagPos = [rand(1) * (xMax - xMin) + xMin, ...
                      rand(1) * (yMax - yMin) + yMin, ...
                      rand(1) * (zMax - zMin) + zMin];

            % Compute true distances from the true anchor positions to the tag position
            distances = sqrt(sum((anchors - tagPos).^2, 2));

            % Compute noisy distances from noisy anchor positions to the tag position
            noisyDistancesSample = sqrt(sum((noisyAnchorsSample - tagPos).^2, 2));

            % Generate noise with the specified std deviation and add it to the distances
            distanceNoise = randn(size(distances)) * noiseStdDev;
            noisyDistancesSample = noisyDistancesSample + distanceNoise;

            % Store data
            noisyDistances(sampleIndex, 1:numAnchors) = noisyDistancesSample';
            noisyDistances(sampleIndex, numAnchors + 1) = noiseStdDev;
            cleanDistances(sampleIndex, :) = distances';
            trueAnchors(sampleIndex, :) = anchors(:)'; % Flattened true anchor positions
            noisyAnchors(sampleIndex, :) = noisyAnchorsSample(:)'; % Flattened noisy anchor positions
            tagPositions(sampleIndex, :) = tagPos; % Store tag position

            sampleIndex = sampleIndex + 1;
        end
    end
end
