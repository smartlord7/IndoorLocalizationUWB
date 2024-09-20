function [noisyDistances, cleanDistances, trueAnchors, tagPositions] = generateData(numSamplesPerStd, numAnchors, stdDevs, varargin)
    % Parameters with default values
    if nargin < 3 || isempty(stdDevs)
        stdDevs = [0.1, 0.5, 1.0]; % Default standard deviations
    end
    if nargin < 4
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
    noisyDistances = zeros(totalSamples, numAnchors); % Noisy distances
    cleanDistances = zeros(totalSamples, numAnchors); % Clean distances
    trueAnchors = zeros(totalSamples, numAnchors * numDimensions); % True anchor positions
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

            % Simulate random tag position within [min, max] range for x, y, z
            tagPos = [rand(1) * (xMax - xMin) + xMin, ...
                      rand(1) * (yMax - yMin) + yMin, ...
                      rand(1) * (zMax - zMin) + zMin];

            % Compute true distances
            distances = sqrt(sum((anchors - tagPos).^2, 2));

            % Generate noise with the specified std deviation
            noise = randn(size(distances)) * noiseStdDev;
            noisyDistancesSample = distances + noise;

            % Store data
            noisyDistances(sampleIndex, :) = noisyDistancesSample';
            cleanDistances(sampleIndex, :) = distances';
            trueAnchors(sampleIndex, :) = anchors(:)'; % Flattened true anchor positions
            tagPositions(sampleIndex, :) = tagPos; % Store tag position

            sampleIndex = sampleIndex + 1;
        end
    end
end
