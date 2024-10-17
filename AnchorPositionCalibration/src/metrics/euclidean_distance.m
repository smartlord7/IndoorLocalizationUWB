function d = euclidean_distance(x, y)
    % Compute Euclidean distance between vectors x and y
    d = sqrt(sum((x - y).^2));
end
