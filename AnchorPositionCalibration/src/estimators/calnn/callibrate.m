function final_anchors = callibrate(n_anchors, initial_anchors, real_distances, real_tag_position, std)
    % Network initialization (input, hidden layers, output)
    layer_sizes = [3 * n_anchors + 3, 10, 10, 3 * n_anchors];  % Input, hidden1, hidden2, output
    activation_functions = {'relu', 'sigmoid', 'linear'};  % Specify activation functions for each layer
    stds = std * ones(n_anchors, 3);  % Uncertainties have the same std deviation
    
    net = initialize_network(layer_sizes, activation_functions);

   % Parameters struct
    params = struct();
    params.max_iters = 6000;
    params.lambda = 0.0025;    % Regularization parameter
    params.lr = 1e-2;          % Learning rate
    params.stds = stds;        % Standard deviations
    params.delta = 1;          % Huber loss delta parameter

    input = initial_anchors(:);
    input = cat(1, input, real_tag_position');
    [net, ~] = adam_optimization(net, input, real_distances, real_tag_position, n_anchors, initial_anchors, params);
    
    % Final estimated anchor positions
    [final_outputs, ~] = forward_pass(net, input);
    final_anchors = reshape(final_outputs, [n_anchors, 3]);
end
