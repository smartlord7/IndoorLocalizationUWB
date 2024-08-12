function cost = neuralNetworkCost(params, distances_noisy, tagPos, numInputs, numHiddenUnits, numOutputs)
    % Extract parameters
    W1 = reshape(params(1:numHiddenUnits*numInputs), numHiddenUnits, numInputs);
    b1 = params(numHiddenUnits*numInputs+1:numHiddenUnits*numInputs+numHiddenUnits);
    idx = numHiddenUnits*numInputs + numHiddenUnits;

    W2 = reshape(params(idx+1:idx+numOutputs*numHiddenUnits), numOutputs, numHiddenUnits);
    b2 = params(idx+numOutputs*numHiddenUnits+1:end);

    % Forward pass
    estimatedAnchors = calculateAnchors(W1, b1, W2, b2, tagPos, numOutputs / 3);

    % Calculate cost (sum of squared errors)
    cost = sum((sqrt(sum((reshape(estimatedAnchors, [], 3) - tagPos).^2, 2)) - distances_noisy).^2);
end