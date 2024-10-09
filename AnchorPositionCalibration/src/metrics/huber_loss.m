% Huber loss: Robust loss function to handle outliers
function loss = huber_loss(predicted_distances, real_distances, delta)
    abs_diff = abs(predicted_distances - real_distances);
    quadratic = min(abs_diff, delta);
    linear = abs_diff - quadratic;
    loss = 0.5 * quadratic.^2 + delta * linear;
    loss = sum(loss); % Sum across all distances
end
