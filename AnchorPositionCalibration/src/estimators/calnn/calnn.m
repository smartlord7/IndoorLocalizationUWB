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

% Training using Adam optimization
max_iters = 500000;
lambda = 0.0025;
lr = 1e-5;
input = initial_anchors(:);
input = cat(1, input, real_tag_position');
delta = 1;  % Huber loss delta parameter
[net, loss_history] = adam_optimization(net, input, real_distances, real_tag_position, n_anchors, max_iters, initial_anchors, lambda, lr, stds, false, delta);

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
disp(compute_loss(final_anchors, real_distances, real_tag_position, n_anchors, initial_anchors, 0, stds, delta));

disp('Control Loss:');
disp(compute_loss(initial_anchors, real_distances, real_tag_position, n_anchors, initial_anchors, 0, stds, delta));

disp('Final error (RMSE):');
disp(root_mean_squared_error(final_anchors, real_anchors));

disp('Control error (RMSE):');
disp(root_mean_squared_error(initial_anchors, real_anchors));
