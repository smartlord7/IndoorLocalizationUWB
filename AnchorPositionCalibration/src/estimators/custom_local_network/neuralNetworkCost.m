function cost = neuralNetworkCost(params, distances_noisy, tagPos, numInputs, numHiddenUnits, numOutputs)
    W1 = reshape(params(1:numHiddenUnits*numInputs), numHiddenUnits, numInputs);
    b1 = reshape(params(numHiddenUnits*numInputs+1:numHiddenUnits*numInputs+numHiddenUnits), numHiddenUnits, 1);
    W2 = reshape(params(numHiddenUnits*numInputs+numHiddenUnits+1:end-numOutputs), numOutputs, numHiddenUnits);
    b2 = reshape(params(end-numOutputs+1:end), numOutputs, 1);

    estimatedAnchors = calculateAnchors(W1, b1, W2, b2, tagPos, numOutputs / 3);
    cost = sum((sqrt(sum((reshape(estimatedAnchors, [], 3) - tagPos).^2, 2)) - distances_noisy).^2);
end