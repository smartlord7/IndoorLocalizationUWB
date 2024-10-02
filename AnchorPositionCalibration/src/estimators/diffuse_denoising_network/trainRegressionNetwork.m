function [meta] = trainRegressionNetwork(trainData, trainLabels)
    % Define the range of hyperparameters for Bayesian optimization
    optimVars = [
        optimizableVariable('numLayers', [2, 3], 'Type', 'integer')          % Vary number of hidden layers
        optimizableVariable('initialNeurons', [85, 100], 'Type', 'integer')  % Initial number of neurons
        optimizableVariable('finalNeurons', [25, 50], 'Type', 'integer')      % Final number of neurons
        optimizableVariable('learningRate', [1e-2, 1e-1], 'Type', 'real')    % Learning rate range
        optimizableVariable('activationFunction', {'tansig', 'logsig'}) % Activation functions
        %optimizableVariable('trainFunction', {'trainscg'}) % Train functions
    ];

    % Initialize meta struct to track best network and performance
    meta = struct;
    meta.bestNet = [];
    meta.bestPerf = Inf;

    % Open a log file to store the results of each trial
    logFile = fopen('regression_optimization_log.txt', 'w');

    % Create or append to CSV file for logging hyperparameters and performance
    csvFileName = 'network_hyperparameters_log.csv';
    if ~isfile(csvFileName)
        % If file does not exist, create it and write the header
        fid = fopen(csvFileName, 'w');
        fprintf(fid, 'numLayers,initialNeurons,finalNeurons,learningRate,activationFunction,trainFunction,valPerformance\n');
        fclose(fid);
    end

    % Run Bayesian optimization
    results = bayesopt(@(params) objectiveFunction(params, trainData, trainLabels, meta, logFile, csvFileName), ...
                       optimVars, ...
                       'MaxObjectiveEvaluations', 300, ...  % Set maximum number of evaluations
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
        fprintf('Train Function: %s\n', meta.bestNet.trainFunction);
        fprintf('Activation Function: %s\n', meta.bestNet.activationFunction);
    end

    % Return the best network found
    meta.bestNet = meta.bestNet;

    % Objective function for Bayesian optimization
    function [valPerformance, net] = objectiveFunction(params, trainData, trainLabels, meta, logFile, csvFileName)
        % Extract hyperparameters
        numLayers = params.numLayers;
        initialNeurons = params.initialNeurons;
        finalNeurons = params.finalNeurons;
        learningRate = params.learningRate;
        activationFunction = string(params.activationFunction);
        trainFunction = 'trainscg';

        % Log hyperparameters to console and file
        fprintf('Current Hyperparameters:\n');
        fprintf('Num Layers: %d\n', numLayers);
        fprintf('Initial Neurons: %d\n', initialNeurons);
        fprintf('Final Neurons: %d\n', finalNeurons);
        fprintf('Learning Rate: %.5f\n', learningRate);
        fprintf('Activation Function: %s\n', activationFunction);
        fprintf('Train Function: %s\n', 'trainscg');
        fprintf('-----------------------------\n');

        fprintf(logFile, 'Current Hyperparameters:\n');
        fprintf(logFile, 'Num Layers: %d\n', numLayers);
        fprintf(logFile, 'Initial Neurons: %d\n', initialNeurons);
        fprintf(logFile, 'Final Neurons: %d\n', finalNeurons);
        fprintf(logFile, 'Learning Rate: %.5f\n', learningRate);
        fprintf(logFile, 'Activation Function: %s\n', activationFunction);
        fprintf(logFile, 'Train Function: %s\n', 'trainscg');
        fprintf(logFile, '-----------------------------\n');

        [net, ~, valPerformance] = trainRegressionNetwork_(initialNeurons, finalNeurons, numLayers, activationFunction, learningRate, trainData, trainLabels);

        % Check if this is the best network
        if valPerformance < meta.bestPerf
            meta.bestPerf = valPerformance;
            meta.bestNet = struct('numLayers', numLayers, ...
                                  'hiddenLayerSizes', hiddenLayerSizes, ...
                                  'learningRate', learningRate, ...
                                  'trainFunction', trainFunction, ...
                                  'activationFunction', activationFunction); % Save the best network details
        end

        fprintf('Validation Performance: %f\n', valPerformance);

        % Append current trial's hyperparameters and performance to CSV
        fid = fopen(csvFileName, 'a');
        fprintf(fid, '%d,%d,%d,%.5f,%s,%s,%.5f\n', numLayers, initialNeurons, finalNeurons, learningRate, activationFunction, trainFunction, valPerformance);
        fclose(fid);
    end
end
