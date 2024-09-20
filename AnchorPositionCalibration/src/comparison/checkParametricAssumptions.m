function [checks] = checkParametricAssumptions(estimators, meanErrors)
    normalityTestResults = arrayfun(@(x) lillietest(meanErrors.mean_mean_Error(strcmp(meanErrors.Estimator, x))), estimators);

    % Constant variance test (e.g., Bartlett's test)
    [varTestResults, ~] = vartestn(meanErrors.mean_mean_Error, 'TestType', 'Bartlett', 'Display', 'off');
    
    % Perform parametric tests if normality and equal variance hold
    if all(normalityTestResults) && all(varTestResults)
       checks = true;
    else
        % Kruskal-Wallis and multiple comparisons
        checks = false;
    end
end

