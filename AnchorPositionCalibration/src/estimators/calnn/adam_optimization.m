% Optimized Adam optimization with random perturbation when loss stagnates
function [net, loss_history] = adam_optimization(net, X, real_distances, real_tag_position, n_anchors, max_iters, initial_anchors, lambda, lr, stds, plot_loss, delta, plot_rm)

    % Adam hyperparameters
    tol = 1e-6;         % Tolerance for convergence
    beta1 = 0.9;
    beta2 = 0.999;
    epsilon = 1e-8;

    % Stagnation detection parameters
    stagnation_window = 100;          % Window size to detect stagnation
    stagnation_threshold = 1e-4;      % Threshold for loss stagnation
    perturbation_strength = 0.5; % Initial strength of random perturbation
    perturbation_decay_factor = 0.95;  % Decay factor for perturbation strength
    
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

    % Main optimization loop
    for iter = 1:max_iters
        % Forward pass
        [outputs, activations] = forward_pass(net, X);
        
        % Compute loss
        loss = compute_loss(outputs, real_distances, real_tag_position, n_anchors, initial_anchors, lambda, stds, delta);
        disp(['Iteration ', num2str(iter), ' Loss: ', num2str(loss)]);

        % Store the loss for this iteration
        loss_history(iter) = loss;

        % Check for stagnation
        if iter > stagnation_window
            loss_diff = abs(loss_history(iter) - loss_history(iter - stagnation_window));
            if mod(iter, stagnation_window) == 0
                % Dynamically adjust perturbation strength based on iteration
                perturbation_strength = perturbation_strength * perturbation_decay_factor;
                loss_diff = abs(loss_history(iter) - loss_history(iter - stagnation_window + 1));
                if loss_diff < stagnation_threshold && perturbation_strength > 1e-6  % Apply perturbation if above threshold
                    % Apply random perturbation to the weights and biases
                    perturbation = perturbation_strength * randn(num_layers, 1);  % Generate perturbation once
                    for i = 1:num_layers
                        net.layers{i}.W = net.layers{i}.W + perturbation(i) * randn(size(net.layers{i}.W));
                        net.layers{i}.b = net.layers{i}.b + perturbation(i) * randn(size(net.layers{i}.b));
                    end
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

    % Generate plot at the end
    if plot_loss
        figure('Units', 'Normalized', 'OuterPosition', [0 0 1 1]);  % Create a fullscreen figure
        plot(1:length(loss_history), loss_history, 'LineWidth', 2);
        xlabel('Epoch');
        ylabel('Loss');
        title(['Loss over Epochs (LR: ', num2str(lr), ', Lambda: ', num2str(lambda), ')']);
        grid on;

        % Save the plot with a meaningful filename
        filename = ['loss_plot', '_lr', num2str(lr), '_lambda', num2str(lambda), '.png'];
        saveas(gcf, filename);
        disp(['Plot saved as ', filename]);
    end
end
