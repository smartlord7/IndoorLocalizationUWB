function d = cosine_distance(x, y)
    % Compute cosine distance between vectors x and y
    dot_product = dot(x, y);
    norm_x = norm(x);
    norm_y = norm(y);
    d = 1 - (dot_product / (norm_x * norm_y)); % Cosine similarity, then convert to distance
end