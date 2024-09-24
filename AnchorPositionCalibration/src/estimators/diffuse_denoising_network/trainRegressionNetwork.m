function regressionNetwork = trainRegressionNetwork(trainData, trainLabels, numAnchors)
    % Define the number of features and the number of neurons in hidden layers
   numFeatures = size(trainData, 2);
    numHiddenUnits1 = 30; % Number of neurons in the first hidden layer
    numHiddenUnits2 = 10;  % Number of neurons in the second hidden layer

    % Define layers
    layers = [
        featureInputLayer(numFeatures, 'Normalization', 'zscore', 'Name', 'input')
        
        % First hidden layer
        fullyConnectedLayer(numHiddenUnits1, 'Name', 'fc1')
        batchNormalizationLayer('Name', 'bn1')
        reluLayer('Name', 'relu1')
        dropoutLayer(0.2, 'Name', 'dropout1') % Increased dropout for better regularization
        
        % Second hidden layer
        fullyConnectedLayer(numHiddenUnits2, 'Name', 'fc2')
        batchNormalizationLayer('Name', 'bn2')
        reluLayer('Name', 'relu2')
        dropoutLayer(0.2, 'Name', 'dropout2') % Increased dropout for better regularization

        % Second hidden layer
        fullyConnectedLayer(numHiddenUnits2, 'Name', 'fc3')
        batchNormalizationLayer('Name', 'bn3')
        reluLayer('Name', 'relu3')
        dropoutLayer(0.2, 'Name', 'dropout3') % Increased dropout for better regularization

        % Second hidden layer
        fullyConnectedLayer(numHiddenUnits2, 'Name', 'fc4')
        batchNormalizationLayer('Name', 'bn4')
        reluLayer('Name', 'relu4')
        dropoutLayer(0.2, 'Name', 'dropout4') % Increased dropout for better regularization

        % Second hidden layer
        fullyConnectedLayer(numHiddenUnits2, 'Name', 'fc5')
        batchNormalizationLayer('Name', 'bn5')
        reluLayer('Name', 'relu5')
        dropoutLayer(0.2, 'Name', 'dropout5') % Increased dropout for better regularization
        
        % Output layer
        fullyConnectedLayer(numAnchors * 3, 'Name', 'fc6')
        regressionLayer('Name', 'output')
    ];
    
    % Training options
    options = trainingOptions('adam', ...
        'InitialLearnRate', 0.01, ... % Reduced learning rate for better convergence
        'LearnRateSchedule', 'piecewise', ... % Use a learning rate schedule
        'LearnRateDropPeriod', 100, ... % Period after which to drop learning rate
        'LearnRateDropFactor', 0.25, ... % Factor by which to drop learning rate
        'MaxEpochs', 2000, ... % Increased max epochs for better training
        'MiniBatchSize', 8, ... % Reduced batch size for more frequent updates
        'Plots', 'training-progress', ...
        'Shuffle', 'every-epoch', ...
        'L2Regularization', 0.001, ... % Adjusted L2 regularization
        'ExecutionEnvironment', 'cpu', ...
        'Verbose', true);

    % Train the network
    regressionNetwork = trainNetwork(trainData, trainLabels, layers, options);
end
