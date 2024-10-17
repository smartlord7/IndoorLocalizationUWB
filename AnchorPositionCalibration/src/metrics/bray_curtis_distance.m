function d = bray_curtis_distance(x, y)
    % Compute Bray-Curtis distance between vectors x and y
    d = sum(abs(x - y)) / sum(abs(x + y));
end
