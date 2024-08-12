function estimatedAnchors = customNeuralNetwork(distances_noisy, initialGuess, tagPos, bounds)
    numAnchors = size(initialGuess, 1);
    numInputs = 3; % 3 coordinates (x, y, z) for each anchor
    numHiddenUnits = 20; % Experiment with more neurons in the hidden layer
    numOutputs = numAnchors * 3; % Each anchor has 3 coordinates (x, y, z)

    % Initialize weights and biases with He initialization
    W1 = randn(numHiddenUnits, numInputs) * sqrt(2/numInputs);
    b1 = zeros(numHiddenUnits, 1);
    W2 = randn(numOutputs, numHiddenUnits) * sqrt(2/numHiddenUnits) + reshape(initialGuess', numOutputs, 1);
    b2 = reshape(initialGuess', numOutputs, 1);

    paramsInit = [W1(:); b1(:); W2(:); b2(:)];

    % Define the cost function for the neural network
    costFunction = @(params) neuralNetworkCost(params, distances_noisy, tagPos, numInputs, numHiddenUnits, numOutputs);

    % Use a more suitable optimization method like 'adam'
    options = optimoptions('fminunc', 'Display', 'iter', 'Algorithm', 'quasi-newton', 'MaxIterations', 1000);

    % Optimize the parameters using fminunc
    [paramsOpt, ~] = fminunc(costFunction, paramsInit, options);

    % Extract the optimized weights and biases
    W1_opt = reshape(paramsOpt(1:numHiddenUnits*numInputs), numHiddenUnits, numInputs);
    b1_opt = reshape(paramsOpt(numHiddenUnits*numInputs+1:numHiddenUnits*numInputs+numHiddenUnits), numHiddenUnits, 1);
    W2_opt = reshape(paramsOpt(numHiddenUnits*numInputs+numHiddenUnits+1:end-numOutputs), numOutputs, numHiddenUnits);
    b2_opt = reshape(paramsOpt(end-numOutputs+1:end), numOutputs, 1);

    % Calculate the estimated anchors using the optimized network
    estimatedAnchors = calculateAnchors(W1_opt, b1_opt, W2_opt, b2_opt, tagPos, numAnchors);

    % Ensure the anchors stay within the bounds
    lowerBounds = reshape(bounds(1, :, :), numAnchors, 3);
    upperBounds = reshape(bounds(2, :, :), numAnchors, 3);
    estimatedAnchors = max(min(estimatedAnchors, upperBounds), lowerBounds);
end