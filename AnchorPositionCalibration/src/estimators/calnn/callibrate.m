function final_anchors = callibrate(n_anchors, initial_anchors, real_distances, real_tag_position)
    % Network initialization (input, hidden layers, output)
    layer_sizes = [3 * n_anchors + 3, 10, 10, 3 * n_anchors];  % Input, hidden1, hidden2, output
    activation_functions = {'relu', 'sigmoid', 'linear'};  % Specify activation functions for each layer
    
    net = initialize_network(layer_sizes, activation_functions);
    
    % Training using Adam optimization
    max_iters = 100000;
    lambda = 0.0025;
    lr = 1e-5;
    input = initial_anchors(:);
    input = cat(1, input, real_tag_position');
    delta = 1;  % Huber loss delta parameter
    [net, loss_history] = adam_optimization(net, input, real_distances, real_tag_position, n_anchors, max_iters, initial_anchors, lambda, lr, stds, true, delta);
    
    % Final estimated anchor positions
    [final_outputs, ~] = forward_pass(net, input);
    final_anchors = reshape(final_outputs, [n_anchors, 3]);
end
