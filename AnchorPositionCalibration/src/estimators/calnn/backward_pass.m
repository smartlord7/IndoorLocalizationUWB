% Backpropagation with adaptive gradients (Adam optimizer)
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

        % Backpropagate through the activation function
        if i > 1
            dL_dA_prev = net.layers{i}.W' * dL_dZ;
            dZ_dA_prev = activation_derivative(net.activation_functions{i-1}, A_prev); % Activation derivative
            dL_dZ = dL_dA_prev .* dZ_dA_prev;
        end
    end
end
