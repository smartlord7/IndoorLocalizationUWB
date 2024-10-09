function final_anchors = callibrate(n_anchors, initial_anchors, real_distances, real_tag_position, std)
    % Network initialization (input, hidden layers, output)
    layer_sizes = [3 * n_anchors + 3, 10, 10, 3 * n_anchors];  % Input, hidden1, hidden2, output
    activation_functions = {'relu', 'relu', 'linear'};  % Specify activation functions for each layer
    stds = std * ones(n_anchors, 3);  % Uncertainties have the same std deviation
    
    net = initialize_network(layer_sizes, activation_functions);
    
    % Training using Adam optimization
    max_iters = 200000;
    lambda = 0.05;
    lr = 1e-3;
    input = initial_anchors(:);
    input = cat(1, input, real_tag_position');
    delta = 1;  % Huber loss delta parameter
    [net, loss_history] = adam_optimization(net, input, real_distances, real_tag_position, n_anchors, max_iters, initial_anchors, lambda, lr, stds, false, delta);
    
    % Final estimated anchor positions
    [final_outputs, ~] = forward_pass(net, input);
    final_anchors = reshape(final_outputs, [n_anchors, 3]);
end
