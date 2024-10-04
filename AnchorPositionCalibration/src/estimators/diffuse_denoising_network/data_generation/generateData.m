function [noisyDistances, cleanDistances, noisyAnchors, trueAnchors, tagPositions] = generateData(numTopologies, numTagsPerTopology, numAnchors, stdDevs, anchorPosNoiseStd, showAnimation, varargin)
    % Parameters with default values
    if nargin < 5 || isempty(stdDevs)
        stdDevs = [0.1, 0.5, 1.0]; % Default distance standard deviations
    end
    if nargin < 6 || isempty(anchorPosNoiseStd)
        anchorPosNoiseStd = 1.0; % Default standard deviation for anchor position noise
    end
    if nargin < 7
        xMin = 0; xMax = 10;
        yMin = 0; yMax = 10;
        zMin = 0; zMax = 10;
    else
        xMin = varargin{1}(1); xMax = varargin{1}(2);
        yMin = varargin{2}(1); yMax = varargin{2}(2);
        zMin = varargin{3}(1); zMax = varargin{3}(2);
    end

    totalSamples = numTopologies * numTagsPerTopology * length(stdDevs);
    numDimensions = 3;

    noisyDistances = zeros(totalSamples, numAnchors + 1); 
    cleanDistances = zeros(totalSamples, numAnchors); 
    trueAnchors = zeros(totalSamples, numAnchors * numDimensions); 
    noisyAnchors = zeros(totalSamples, numAnchors * numDimensions); 
    tagPositions = zeros(totalSamples, numDimensions); 

    % Create a figure for the animation if needed
    if showAnimation
        figure;
    end

    sampleIndex = 1;
    for stdIdx = 1:length(stdDevs)
        noiseStdDev = stdDevs(stdIdx);

        for topologyIdx = 1:numTopologies
            % Generate different controlled topologies (random, clustered, grid)
            if mod(topologyIdx, 3) == 0
                anchors = generateGridAnchors(numAnchors, [xMin, xMax], [yMin, yMax], [zMin, zMax]);
            elseif mod(topologyIdx, 3) == 1
                anchors = generateClusteredAnchors(numAnchors, [xMin, xMax], [yMin, yMax], [zMin, zMax]);
            else
                anchors = generateRandomAnchors(numAnchors, [xMin, xMax], [yMin, yMax], [zMin, zMax]);
            end

            noisyAnchorsSample = anchors + randn(numAnchors, numDimensions) * anchorPosNoiseStd;

            for tagIdx = 1:numTagsPerTopology
                tagPos = generateStratifiedTags([xMin, xMax], [yMin, yMax], [zMin, zMax]);
                distances = sqrt(sum((anchors - tagPos).^2, 2));
                noisyDistancesSample = sqrt(sum((noisyAnchorsSample - tagPos).^2, 2)) + randn(size(distances)) * noiseStdDev;

                noisyDistances(sampleIndex, 1:numAnchors) = noisyDistancesSample';
                noisyDistances(sampleIndex, numAnchors + 1) = noiseStdDev;
                cleanDistances(sampleIndex, :) = distances';
                trueAnchors(sampleIndex, :) = anchors(:)';
                noisyAnchors(sampleIndex, :) = noisyAnchorsSample(:)';
                tagPositions(sampleIndex, :) = tagPos;

                % Plot the topology and tags if animation is enabled
                if showAnimation
                    clf; % Clear figure
                    hold on;

                    % Plot true anchor positions using spheres
                    plotSpheres3D(anchors(:, 1), anchors(:, 2), anchors(:, 3), 'b', 0.3);

                    % Plot noisy anchor positions using spheres
                    plotSpheres3D(noisyAnchorsSample(:, 1), noisyAnchorsSample(:, 2), noisyAnchorsSample(:, 3), 'r', 0.3);

                    % Plot tag position using a sphere
                    plotSpheres3D(tagPos(1), tagPos(2), tagPos(3), 'g', 0.5);

                    % Annotate the plot
                    xlabel('X'); ylabel('Y'); zlabel('Z');
                    title(sprintf('Topology %d, Tag %d (Std Dev: %.2f)', topologyIdx, tagIdx, noiseStdDev));
                    axis([xMin xMax yMin yMax zMin zMax]);
                    grid on;
                    view(3); % 3D view

                    % Set lighting and Gouraud shading
                    lighting gouraud;
                    camlight;
                    drawnow;
                    pause(0.001); % Pause to create animation effect
                end

                sampleIndex = sampleIndex + 1;
            end
        end
    end
end
