function initialPop = generateInitialPopulation(initialGuess, numVars, popSize, bounds)
    % Reshape initial guess into a vector
    initialGuessVec = reshape(initialGuess, [], 1);

    % Generate initial population around the initial guess
    initialPop = repmat(initialGuessVec', popSize, 1) + 0.1 * randn(popSize, numVars);

    % Ensure that the initial population is within bounds
    lb = reshape(bounds(1, :, :), numVars, 1);
    ub = reshape(bounds(2, :, :), numVars, 1);
    initialPop = min(max(initialPop, lb'), ub');
end