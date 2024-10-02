function [ps, net, tr, valPerformance] = trainRegressionNetwork_(initialNeurons, finalNeurons, numLayers, activationFunction, learningRate, trainData, trainLabels)
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
        net.divideFcn = 'divideint';
        net.trainParam.epochs = 500; % Max number of epochs
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
end

