function d = minkowski_distance(x, y, p)
    % Compute Minkowski distance between vectors x and y with parameter p
    d = (sum(abs(x - y).^p))^(1/p);
end