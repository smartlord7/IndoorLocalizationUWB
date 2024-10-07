% Initialize the network with modular architecture
function net = initialize_network(layer_sizes)
    num_layers = length(layer_sizes) - 1;
    net.layers = cell(num_layers, 1);
    
    % Initialize weights and biases
    for i = 1:num_layers
        net.layers{i}.W = randn(layer_sizes(i+1), layer_sizes(i)) * 0.1; % Larger weights
        net.layers{i}.b = zeros(layer_sizes(i+1), 1);                    % Biases initialized to zero
    end
end

% Forward pass
function [outputs, activations] = forward_pass(net, X)
    num_layers = length(net.layers);
    activations = cell(num_layers, 1);
    A = X; % Input layer activations
    
    for i = 1:num_layers
        Z = net.layers{i}.W * A + net.layers{i}.b;  % Linear combination
        if i < num_layers
            A = max(0, Z);  % ReLU activation for hidden layers
        else
            A = Z;  % Linear activation for output layer
        end
        activations{i} = A; % Store activations
    end
    
    outputs = A; % Final output (predicted anchor positions)
end

% Custom loss: Distance error with regularization
function loss = compute_loss(predicted_anchors, real_distances, real_tag_position, n_anchors, initial_anchors, lambda, stds)
    predicted_anchors = reshape(predicted_anchors, [n_anchors, 3]);
    
    % Compute predicted distances from each anchor to the tag
    predicted_distances = sqrt(sum((predicted_anchors - real_tag_position).^2, 2));
    
    % Compute the mean squared error between the predicted distances and the real distances
    distance_loss = sum((predicted_distances - real_distances).^2); % MSE of distance error
    
    % Regularization term: Penalize deviation from initial anchors
    regularization_term = sum(sum(((predicted_anchors - initial_anchors).^2) ./ (stds.^2))); % Scaled by std deviation
    
    % Total loss is distance error + regularization term (with a weighting factor lambda)
    loss = distance_loss + lambda * regularization_term;
end


% Backpropagation
function grads = backward_pass(net, X, real_distances, real_tag_position, n_anchors, activations, initial_anchors, lambda)
    num_layers = length(net.layers);
    grads = cell(num_layers, 1);
    
    % Compute predicted distances from tag
    predicted_anchors = reshape(activations{end}, [n_anchors, 3]);
    predicted_distances = sqrt(sum((predicted_anchors - real_tag_position).^2, 2));
    
    % Gradient of distance loss w.r.t predicted distances
    dL_dPredDist = 2 * (predicted_distances - real_distances);
    
    % Gradient of distance loss w.r.t predicted anchor positions
    dPredDist_dPredAnchors = (predicted_anchors - real_tag_position) ./ predicted_distances;
    dL_dPredAnchors = dL_dPredDist .* dPredDist_dPredAnchors; % Gradient w.r.t anchors

    % Gradient of regularization term w.r.t predicted anchor positions
    reg_grad = 2 * lambda * (predicted_anchors - initial_anchors); 
    
    % Total gradient w.r.t predicted anchor positions
    dL_dPredAnchors = dL_dPredAnchors + reg_grad;

    % Reshape gradient for backpropagation
    dL_dZ = reshape(dL_dPredAnchors, [], 1);  % Reshape to column vector
    
    % Backpropagate through layers
    for i = num_layers:-1:1
        if i == 1
            A_prev = X;  % Use input data for the first layer
        else
            A_prev = activations{i-1};  % Use the activations from the previous layer
        end
        
        % Gradient w.r.t weights and biases
        grads{i}.dW = dL_dZ * A_prev'; % Gradient w.r.t weights
        grads{i}.db = dL_dZ;           % Gradient w.r.t biases
        
        % Backpropagate through ReLU
        if i > 1
            dL_dA_prev = net.layers{i}.W' * dL_dZ;
            dZ_dA_prev = A_prev > 0; % ReLU derivative
            dL_dZ = dL_dA_prev .* dZ_dA_prev;
        end
    end
end

% SCG Optimization (placeholder using simple gradient descent for now)
function net = scg_optimization(net, X, real_distances, real_tag_position, n_anchors, max_iters, initialAnchors, lambda, lr, stds)
    tol = 1e-6;     % Tolerance for convergence

    for iter = 1:max_iters
        % Forward pass
        [outputs, activations] = forward_pass(net, X);
        
        % Compute loss
        loss = compute_loss(outputs, real_distances, real_tag_position, n_anchors, initialAnchors, lambda, stds);
        disp(['Iteration ', num2str(iter), ' Loss: ', num2str(loss)]);
        
        % Compute gradients via backpropagation
        grads = backward_pass(net, X, real_distances, real_tag_position, n_anchors, activations, initialAnchors, lambda);
        
        % Update weights and biases (gradient descent for now)
        for i = 1:length(net.layers)
            net.layers{i}.W = net.layers{i}.W - lr * grads{i}.dW;
            net.layers{i}.b = net.layers{i}.b - lr * grads{i}.db;
        end
        
        % Check for convergence
        if loss < tol
            break;
        end
    end
end

% Problem setup
rng(0);
n_anchors = 4;
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

layer_sizes = [3 * n_anchors, 20, 20, 3 * n_anchors];  % Input, hidden1, hidden2, output
net = initialize_network(layer_sizes);

% Train the network using SCG optimization
max_iters = 1000000;
lambda = 0.005;
lr = 1e-5;
net = scg_optimization(net, initial_anchors(:), real_distances, real_tag_position, n_anchors, max_iters, initial_anchors, lambda, lr, stds);

% Final estimated anchor positions
[final_outputs, ~] = forward_pass(net, initial_anchors(:));
final_anchors = reshape(final_outputs, [n_anchors, 3]);

disp('Initial anchor positions:');
disp(initial_anchors);

disp('Estimated anchor positions:');
disp(final_anchors);

disp('Real anchor positions:');
disp(real_anchors);

disp('Final Loss:')
disp(compute_loss(final_anchors, real_distances, real_tag_position, n_anchors, initial_anchors, lambda))
