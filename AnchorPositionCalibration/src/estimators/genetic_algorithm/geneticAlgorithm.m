function estimatedAnchors = geneticAlgorithm(distances_noisy, initialGuess, tagPos, bounds)
    % Genetic Algorithm for anchor position estimation
    numAnchors = size(initialGuess, 1);
    numVars = numAnchors * 3;

    % Fitness function to minimize
    fitnessFunction = @(anchors) sum(calcResiduals(anchors, initialGuess, distances_noisy, tagPos, numAnchors).^2);

    % Define the genetic algorithm parameters
    options = optimoptions('ga', ...
        'Display', 'iter', ... % Detailed output for debugging
        'PopulationSize', 100, ... 
        'MaxGenerations', 300, ... 
        'CrossoverFraction', 0.8, ...
        'MutationFcn', {@mutationadaptfeasible, 0.2}, ...
        'EliteCount', 5, ...
        'InitialPopulationMatrix', generateInitialPopulation(initialGuess, numVars, 200, bounds)); ... % Use initial guess to generate initial population); % Plot the best fitness value in each generation

    % Bounds
    lb = reshape(bounds(1, :, :), numVars, 1);
    ub = reshape(bounds(2, :, :), numVars, 1);

    % Optimize using Genetic Algorithm
    [bestAnchors, ~, ~, ~] = ga(fitnessFunction, numVars, [], [], [], [], lb, ub, [], options);

    % Reshape the result into the original format
    estimatedAnchors = reshape(bestAnchors, numAnchors, 3);
end