% Function to split data into training and validation sets
function [trainData, valData, trainTargets, valTargets] = splitData(noisyDistances, cleanDistances, trainRatio)
    numSamples = size(noisyDistances, 1);
    idx = randperm(numSamples); % Random permutation of indices
    numTrain = floor(trainRatio * numSamples); % Number of training samples
    
    trainIdx = idx(1:numTrain); % Training indices
    valIdx = idx(numTrain+1:end); % Validation indices
    
    trainData = noisyDistances(trainIdx, :); % Training noisy data
    valData = noisyDistances(valIdx, :); % Validation noisy data
    trainTargets = cleanDistances(trainIdx, :); % Training clean targets
    valTargets = cleanDistances(valIdx, :); % Validation clean targets
end