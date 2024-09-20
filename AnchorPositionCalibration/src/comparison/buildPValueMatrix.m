function [pValuesMatrix] = buildPValueMatrix(estimators, results)
 % Create a symmetrical matrix for p-values
    numEstimators = length(estimators);
    pValuesMatrix = NaN(numEstimators, numEstimators);
    
    % Fill in the p-values
    for i = 1:size(results, 1)
        idx1 = results(i, 1);
        idx2 = results(i, 2);
        pValue = results(i, 6);
        pValuesMatrix(idx1, idx2) = pValue;
        pValuesMatrix(idx2, idx1) = pValue;
    end
end

