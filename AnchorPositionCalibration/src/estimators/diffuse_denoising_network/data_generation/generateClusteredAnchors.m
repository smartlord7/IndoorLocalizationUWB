function anchors = generateClusteredAnchors(numAnchors, xRange, yRange, zRange)
    % Generates anchors clustered within certain regions of the space.
    
    % Define the number of clusters (e.g., 3 clusters)
    numClusters = 3;
    anchorsPerCluster = ceil(numAnchors / numClusters);
    
    anchors = [];
    for clusterIdx = 1:numClusters
        % Randomly select a cluster center within the range
        clusterCenter = [rand(1) * (xRange(2) - xRange(1)) + xRange(1), ...
                         rand(1) * (yRange(2) - yRange(1)) + yRange(1), ...
                         rand(1) * (zRange(2) - zRange(1)) + zRange(1)];
        
        % Generate random anchor positions around the cluster center
        clusterAnchors = clusterCenter + randn(anchorsPerCluster, 3) * 0.5;
        
        % Ensure anchor positions stay within bounds
        clusterAnchors = max(min(clusterAnchors, [xRange(2), yRange(2), zRange(2)]), [xRange(1), yRange(1), zRange(1)]);
        
        anchors = [anchors; clusterAnchors];
    end
    
    % Trim extra anchors if the number exceeds the requested count
    if size(anchors, 1) > numAnchors
        anchors = anchors(1:numAnchors, :);
    end
end
