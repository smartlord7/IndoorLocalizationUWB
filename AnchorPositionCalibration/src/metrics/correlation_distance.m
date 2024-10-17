function d = correlation_distance(x, y)
    % Compute Correlation distance between vectors x and y
    x_mean = mean(x);
    y_mean = mean(y);
    
    numerator = sum((x - x_mean) .* (y - y_mean));
    denominator = sqrt(sum((x - x_mean).^2) * sum((y - y_mean).^2));
    
    correlation = numerator / denominator;
    d = 1 - correlation; % Correlation similarity converted to distance
end