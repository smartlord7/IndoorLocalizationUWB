function [net] = trainDenoisingAutoencoder(noisyDistances, cleanDistances)
    % Parameters
    hiddenLayerSizes = [128, 64, 32]; % Number of neurons in each hidden layer
    maxEpochs = 1000; % Maximum number of epochs
    learningRate = 0.05; % Learning rate

    % Split data into training and validation sets
    [trainData, valData, trainTargets, valTargets] = splitData(noisyDistances, cleanDistances, 0.8);

    % Define the network architecture
    layers = [size(trainData, 2), hiddenLayerSizes, size(trainData, 2)];
    
    % Create the network with multiple hidden layers
    net = feedforwardnet(hiddenLayerSizes, 'trainscg'); % Levenberg-Marquardt backpropagation

    % Configure network
    net.layers{1}.transferFcn = 'satlin'; % Set activation function for the first hidden layer
    net.layers{end}.transferFcn = 'purelin'; % Set activation function for the output layer
    
    % Set training parameters
    net.trainParam.epochs = maxEpochs;
    net.trainParam.lr = learningRate;
    net.trainParam.showWindow = false; % Disable GUI
    net.trainParam.showCommandLine = true; % Show command line output

    % Train the network
    [net, tr] = train(net, trainData', trainTargets');

    % Validate the network
    valPredictions = net(valData');
    valPerformance = perform(net, valTargets', valPredictions);
    fprintf('Validation Performance: %f\n', valPerformance);
end