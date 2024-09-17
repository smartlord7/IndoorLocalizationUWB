function estimatedAnchors = combineModel(noisyDistances, denoisingAutoencoder, regressionNetwork)
    % Preprocess the noisy distances with the autoencoder
    cleanedDistances = denoisingAutoencoder(noisyDistances');
    
    % Predict anchor positions using the regression network
    estimatedAnchors = regressionNetwork(cleanedDistances');
    
    % Reshape the output to match anchor dimensions
    numAnchors = length(estimatedAnchors) / 3;
    estimatedAnchors = reshape(estimatedAnchors, [], 3);
end
