% Optimized Adam optimization with random perturbation when loss stagnates
function [net, loss_history] = adam_optimization(net, X, real_distances, real_tag_position, n_anchors, max_iters, initial_anchors, lambda, lr, stds, plot_loss, delta)

    % Adam hyperparameters
    tol = 1e-6;         % Tolerance for convergence
    beta1 = 0.9;
    beta2 = 0.999;
    epsilon = 1e-8;

    % Stagnation detection parameters
    stagnation_window = 100;          % Window size to detect stagnation
    stagnation_threshold = 1e-4;      % Threshold for loss stagnation
    perturbation_strength = 0.05;     % Strength of random perturbation
    
    % Initialize Adam parameters
    num_layers = length(net.layers);
    mW = cell(num_layers, 1);
    vW = cell(num_layers, 1);
    mb = cell(num_layers, 1);
    vb = cell(num_layers, 1);
    
    % Preallocate moment estimates
    for i = 1:num_layers
        mW{i} = zeros(size(net.layers{i}.W));
        vW{i} = zeros(size(net.layers{i}.W));
        mb{i} = zeros(size(net.layers{i}.b));
        vb{i} = zeros(size(net.layers{i}.b));
    end
    
    loss_history = zeros(max_iters, 1);  % Preallocate array for loss values

    % Initialize the figure for interactive plotting
    if plot_loss
        figure;
        h = plot(NaN, NaN, 'LineWidth', 2);  % Empty plot initialized
        xlabel('Epoch');
        ylabel('Loss');
        title('Loss over Epochs');
        grid on;
        hold on;  % Keep updating the same plot
    end

    % Main optimization loop
    for iter = 1:max_iters
        % Forward pass
        [outputs, activations] = forward_pass(net, X);
        
        % Compute loss
        loss = compute_loss(outputs, real_distances, real_tag_position, n_anchors, initial_anchors, lambda, stds, delta);
        %disp(['Iteration ', num2str(iter), ' Loss: ', num2str(loss)]);

        % Store the loss for this iteration
        loss_history(iter) = loss;

        % Update the plot interactively (optimized to update less frequently)
        if plot_loss && mod(iter, 10) == 0  % Update every 10 iterations
            set(h, 'XData', 1:iter, 'YData', loss_history(1:iter));  % Update data
            drawnow;  % Force MATLAB to update the plot immediately
        end

        % Check for stagnation
        if iter > stagnation_window
            loss_diff = abs(loss_history(iter) - loss_history(iter - stagnation_window));
            if loss_diff < stagnation_threshold
                % Apply random perturbation to the weights and biases
                perturbation = perturbation_strength * randn(num_layers, 1);  % Generate perturbation once
                for i = 1:num_layers
                    net.layers{i}.W = net.layers{i}.W + perturbation(i) * randn(size(net.layers{i}.W));
                    net.layers{i}.b = net.layers{i}.b + perturbation(i) * randn(size(net.layers{i}.b));
                end
            end
        end

        % Compute gradients via backpropagation
        grads = backward_pass(net, X, real_distances, real_tag_position, n_anchors, activations, initial_anchors, lambda);

        % Adam optimization: Update weights and biases
        for i = 1:num_layers
            % Update moment estimates
            mW{i} = beta1 * mW{i} + (1 - beta1) * grads{i}.dW;
            vW{i} = beta2 * vW{i} + (1 - beta2) * grads{i}.dW.^2;
            mb{i} = beta1 * mb{i} + (1 - beta1) * grads{i}.db;
            vb{i} = beta2 * vb{i} + (1 - beta2) * grads{i}.db.^2;

            % Bias-corrected estimates
            mW_hat = mW{i} / (1 - beta1^iter);
            vW_hat = vW{i} / (1 - beta2^iter);
            mb_hat = mb{i} / (1 - beta1^iter);
            vb_hat = vb{i} / (1 - beta2^iter);

            % Update weights and biases
            net.layers{i}.W = net.layers{i}.W - lr * mW_hat ./ (sqrt(vW_hat) + epsilon);
            net.layers{i}.b = net.layers{i}.b - lr * mb_hat ./ (sqrt(vb_hat) + epsilon);
        end
        
        % Check for convergence
        if loss < tol
            loss_history = loss_history(1:iter);  % Trim loss history up to the current iteration
            break;
        end
    end

    % Trim loss history in case we converged early
    if iter < max_iters
        loss_history = loss_history(1:iter);
    end
end
