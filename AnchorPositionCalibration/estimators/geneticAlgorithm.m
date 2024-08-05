function estimatedAnchors = geneticAlgorithm(distances_noisy, trueAnchors, tagPos)
    % Genetic Algorithm for anchor position estimation
    numAnchors = size(trueAnchors, 1);
    c = 3e8;

    % Fitness function
    fitnessFunction = @(anchors) sum((sqrt(sum((reshape(anchors, [], 3) - tagPos).^2, 2)) - distances_noisy).^2);

    % Define the genetic algorithm parameters
    options = optimoptions('ga', ...
        'Display', 'final', ...
        'PopulationSize', 500, ...
        'MaxGenerations', 3000, ...
        'CrossoverFraction', 0.2, ...
        'MutationFcn', {@mutationuniform, 0.1}, ...
        'FunctionTolerance', 0.1, ... 
        'EliteCount', 2);

    lb = repmat([-10 -10 -10], numAnchors, 1); % Lower bounds
    ub = repmat([10 10 10], numAnchors, 1);  % Upper bounds

    % Optimize using Genetic Algorithm
    [bestAnchors, ~] = ga(fitnessFunction, numAnchors * 3, [], [], [], [], lb(:), ub(:), [], options);
    
    % Reshape the result into the original format
    estimatedAnchors = reshape(bestAnchors, numAnchors, 3);
end
