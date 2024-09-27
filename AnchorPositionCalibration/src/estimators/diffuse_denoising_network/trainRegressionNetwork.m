function [meta] = trainRegressionNetwork(trainData, trainLabels)
    % Define the range of hyperparameters for Bayesian optimization
    optimVars = [
        optimizableVariable('numLayers', [1, 5], 'Type', 'integer')          % Vary number of hidden layers
        optimizableVariable('initialNeurons', [10, 100], 'Type', 'integer')  % Initial number of neurons
        optimizableVariable('finalNeurons', [5, 50], 'Type', 'integer')      % Final number of neurons
        optimizableVariable('learningRate', [1e-4, 1e-1], 'Type', 'real')    % Learning rate range
        optimizableVariable('activationFunction', {'tansig', 'logsig', 'purelin', 'satlin', 'elliotsig'}) % Activation functions
    ];

    % Initialize meta struct to track best network and performance
    meta = struct;
    meta.bestNet = [];
    meta.bestPerf = Inf;

    % Open a log file to store the results of each trial
    logFile = fopen('regression_optimization_log.txt', 'w');

    % Run Bayesian optimization
    results = bayesopt(@(params) objectiveFunction(params, trainData, trainLabels, meta, logFile), ...
                       optimVars, ...
                       'MaxObjectiveEvaluations', 50, ...  % Set maximum number of evaluations
                       'IsObjectiveDeterministic', false); % Allow non-deterministic evaluations

    % Close log file
    fclose(logFile);

    % Display the best hyperparameters and network details
    if ~isempty(meta.bestNet)
        fprintf('Best Network Performance: %f\n', meta.bestPerf);
        fprintf('Best Network Hyperparameters:\n');
        fprintf('Num Layers: %d\n', meta.bestNet.numLayers);
        fprintf('Hidden Layer Sizes: %s\n', mat2str(meta.bestNet.hiddenLayerSizes));
        fprintf('Learning Rate: %.5f\n', meta.bestNet.learningRate);
        fprintf('Activation Function: %s\n', meta.bestNet.activationFunction);
    end

    % Return the best network found
    meta.bestNet = meta.bestNet;

    % Objective function for Bayesian optimization
    function [valPerformance, net] = objectiveFunction(params, trainData, trainLabels, meta, logFile)
        % Extract hyperparameters
        numLayers = params.numLayers;
        initialNeurons = params.initialNeurons;
        finalNeurons = params.finalNeurons;
        learningRate = params.learningRate;
        activationFunction = string(params.activationFunction);

        % Log hyperparameters to console and file
        fprintf('Current Hyperparameters:\n');
        fprintf('Num Layers: %d\n', numLayers);
        fprintf('Initial Neurons: %d\n', initialNeurons);
        fprintf('Final Neurons: %d\n', finalNeurons);
        fprintf('Learning Rate: %.5f\n', learningRate);
        fprintf('Activation Function: %s\n', activationFunction);
        fprintf('-----------------------------\n');

        fprintf(logFile, 'Current Hyperparameters:\n');
        fprintf(logFile, 'Num Layers: %d\n', numLayers);
        fprintf(logFile, 'Initial Neurons: %d\n', initialNeurons);
        fprintf(logFile, 'Final Neurons: %d\n', finalNeurons);
        fprintf(logFile, 'Learning Rate: %.5f\n', learningRate);
        fprintf(logFile, 'Activation Function: %s\n', activationFunction);
        fprintf(logFile, '-----------------------------\n');

        % Define the network architecture (hidden layer sizes)
        hiddenLayerSizes = round(linspace(initialNeurons, finalNeurons, numLayers));

        % Create feedforward network
        net = feedforwardnet(hiddenLayerSizes, 'trainscg');

        % Set activation function for each layer
        for i = 1:numLayers
            net.layers{i}.transferFcn = activationFunction;
        end
        net.layers{end}.transferFcn = 'purelin';  % Output layer uses 'purelin'

        % Set training parameters
        net.trainParam.lr = learningRate;
        net.trainParam.epochs = 2000; % Max number of epochs
        net.trainParam.max_fail = 10; % Early stopping criteria
        net.trainParam.goal = 1e-6;   % Set a performance goal

        % Split data into training and validation sets
        [trainDataNorm, ps] = mapminmax(trainData'); % Normalize training data
        trainDataNorm = trainDataNorm';
        [trainData, valData, trainLabels, valLabels] = splitData(trainDataNorm, trainLabels, 0.2);

        % Train the network
        [net, tr] = train(net, trainData', trainLabels');

        % Validate the network on validation data
        valPredictions = net(valData');
        valPerformance = perform(net, valLabels', valPredictions);

        % Check if this is the best network
        if valPerformance < meta.bestPerf
            meta.bestPerf = valPerformance;
            meta.bestNet = struct('numLayers', numLayers, ...
                                  'hiddenLayerSizes', hiddenLayerSizes, ...
                                  'learningRate', learningRate, ...
                                  'activationFunction', activationFunction); % Save the best network details
        end

        fprintf('Validation Performance: %f\n', valPerformance);
    end
end