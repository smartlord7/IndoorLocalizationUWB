% Example usage
rng(0);
n_anchors = 8;
std = 1; % Standard deviation of the Gaussian noise
stds = std * ones(n_anchors, 3);  % Uncertainties have the same std deviation

% Generate the true anchor positions
real_anchors = rand(n_anchors, 3) * 10;

% Initial anchors: real anchors with independent Gaussian noise
initial_anchors = real_anchors + std * randn(n_anchors, 3);

% Known position of the tag (fixed)
real_tag_position = [5, 5, 5];            

% True distances from tag to anchors
real_distances = sqrt(sum((real_anchors - real_tag_position).^2, 2));

% Network initialization (input, hidden layers, output)
layer_sizes = [3 * n_anchors + 3, 10, 10, 3 * n_anchors];  % Input, hidden1, hidden2, output
activation_functions = {'relu', 'sigmoid', 'linear'};  % Specify activation functions for each layer
net = initialize_network(layer_sizes, activation_functions);

% Parameters struct
params = struct();
params.max_iters = 6000;
params.lambda = 0.0025;    % Regularization parameter
params.lr = 1e-2;          % Learning rate
params.stds = stds;        % Standard deviations
params.delta = 1;          % Huber loss delta parameter
params.plot_ = true;   % Plot loss over time
params.real_anchors = real_anchors;    % Whether to plot RMSE (optional)


input = initial_anchors(:);
input = cat(1, input, real_tag_position');
[net, loss_history] = adam_optimization(net, input, real_distances, real_tag_position, n_anchors, initial_anchors, params);

% Final estimated anchor positions
[final_outputs, ~] = forward_pass(net, input);
final_anchors = reshape(final_outputs, [n_anchors, 3]);

% Display results
disp('Initial anchor positions:');
disp(initial_anchors);

disp('Estimated anchor positions:');
disp(final_anchors);

disp('Real anchor positions:');
disp(real_anchors);

disp('Final Loss:');
disp(compute_loss(final_anchors, real_distances, real_tag_position, n_anchors, initial_anchors, params.lambda, params.stds, params.delta));

disp('Control Loss:');
disp(compute_loss(initial_anchors, real_distances, real_tag_position, n_anchors, initial_anchors, params.lambda, params.stds, params.delta));

disp('Final error (RMSE):');
disp(root_mean_squared_error(final_anchors, real_anchors));

disp('Control error (RMSE):');
disp(root_mean_squared_error(initial_anchors, real_anchors));
