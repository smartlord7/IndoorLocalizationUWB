function [meta] = trainDenoisingAutoencoder(noisyDistances, cleanDistances)
    % Define the range of hyperparameters for Bayesian optimization
    optimVars = [
        optimizableVariable('numLayers', [1, 5], 'Type', 'integer') % Vary number of layers
        optimizableVariable('initialNeurons', [32, 256], 'Type', 'integer') % Initial number of neurons
        optimizableVariable('finalNeurons', [8, 128], 'Type', 'integer') % Final number of neurons
        optimizableVariable('learningRate', [1e-5, 5e-1], 'Type', 'real')
        optimizableVariable('activationFunction', {'tansig', 'logsig', 'purelin', 'elliotsig', 'satlin'}) % Activation functions
    ];

    % Initialize variables to track the best performance and network
    meta = struct;
    meta.bestNet = [];
    meta.bestPerf = Inf;

    % Open a file to log the hyperparameters and performances
    logFile = fopen('optimization_log.txt', 'w');

    % Run Bayesian optimization
    results = bayesopt(@(params) objectiveFunction(params, noisyDistances, cleanDistances, meta, logFile), ...
                       optimVars, ...
                       'MaxObjectiveEvaluations', 100, ... % Set the number of evaluations
                       'IsObjectiveDeterministic', false); % Set to true if the objective function is deterministic

    % Close the log file
    fclose(logFile);

    % Print best network details at the end
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

    function [valPerformance, net] = objectiveFunction(params, noisyDistances, cleanDistances, meta, logFile)
        % Convert parameters to the correct format
        numLayers = params.numLayers;
        initialNeurons = params.initialNeurons;
        finalNeurons = params.finalNeurons;
        learningRate = params.learningRate;
        activationFunction = string(params.activationFunction);

        % Print the current hyperparameters to console and log file
        fprintf('Current Hyperparameters:\n');
        fprintf('Num Layers: %d\n', numLayers);
        fprintf('Initial Neurons: %d\n', initialNeurons);
        fprintf('Final Neurons: %d\n', finalNeurons);
        fprintf('Learning Rate: %.5f\n', learningRate);
        fprintf('Activation Function: %s\n', activationFunction);
        fprintf('-----------------------------\n');

        % Log the current hyperparameters to the file
        fprintf(logFile, 'Current Hyperparameters:\n');
        fprintf(logFile, 'Num Layers: %d\n', numLayers);
        fprintf(logFile, 'Initial Neurons: %d\n', initialNeurons);
        fprintf(logFile, 'Final Neurons: %d\n', finalNeurons);
        fprintf(logFile, 'Learning Rate: %.5f\n', learningRate);
        fprintf(logFile, 'Activation Function: %s\n', activationFunction);
        fprintf(logFile, '-----------------------------\n');

        % Generate hidden layer sizes based on the number of layers and neuron counts
        hiddenLayerSizes = round(linspace(initialNeurons, finalNeurons, numLayers)); 

        % Split data into training and validation sets
        [trainData, testData, trainTargets, testTarget] = splitData(noisyDistances, cleanDistances, 0.1);

        % Define the network architecture
        net = feedforwardnet(hiddenLayerSizes, 'trainscg');

        % Configure network
        for i = 1:numLayers
            net.layers{i}.transferFcn = activationFunction; % Set activation function for hidden layers
        end
        net.layers{end}.transferFcn = 'purelin'; % Output layer activation

        % Set training parameters
        net.trainParam.epochs = 10000; % Fixed max epochs for simplicity
        net.trainParam.lr = learningRate;
        net.divideFcn = 'divideint'; % Divide data into training and validation
        net.trainParam.max_fail = 20; % Early stopping
        net.trainParam.showWindow = true; % Disable GUI for training
        net.trainParam.showCommandLine = true; % Show command line output
        net.trainParam.goal = 1e-6; % Set goal for performance

        % Train the network
        [net, tr] = train(net, trainData', trainTargets');

        % Validate the network
        tstPredictions = net(testData');
        valPerformance = perform(net, testTarget', tstPredictions);
        
        % Check if this is the best performance
        if valPerformance < meta.bestPerf
            meta.bestPerf = valPerformance;
            meta.bestNet = struct('numLayers', numLayers, ...
                                   'hiddenLayerSizes', hiddenLayerSizes, ...
                                   'learningRate', learningRate, ...
                                   'activationFunction', activationFunction); % Store the best network details
        end

        fprintf('Validation Performance: %f\n', valPerformance);
    end
end
