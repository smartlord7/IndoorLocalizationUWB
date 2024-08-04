function estimatedAnchors = geneticAlgorithm(distances_noisy, trueAnchors, tagPos)
    % Genetic Algorithm for anchor position estimation
    numAnchors = size(trueAnchors, 1);
    fitnessFunction = @(anchors) sum((sqrt(sum((anchors - tagPos).^2, 2)) - distances_noisy).^2);
    
    % Define the genetic algorithm parameters
    options = optimoptions('ga', 'Display', 'off', 'PopulationSize', 50, 'MaxGenerations', 100);
    lb = repmat([-10 -10 -10], numAnchors, 1); % Lower bounds
    ub = repmat([10 10 10], numAnchors, 1);  % Upper bounds

    % Optimize using Genetic Algorithm
    [bestAnchors, ~] = ga(fitnessFunction, numAnchors * 3, [], [], [], [], lb(:), ub(:), [], options);
    
    % Reshape the result into the original format
    estimatedAnchors = reshape(bestAnchors, numAnchors, 3);
end
