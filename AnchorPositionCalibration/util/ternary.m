function result = ternary(condition, trueValue, falseValue)
    % Helper function for ternary logic
    if condition
        result = trueValue;
    else
        result = falseValue;
    end
end