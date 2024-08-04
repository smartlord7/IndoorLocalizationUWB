function estimatedAnchors = calibrateAnchors(~, ~)
        % Get the handles structure
        handles = guidata(gcbo);

        % Remove previous estimated anchors from plot
        if ~isempty(handles.estimatedAnchorsPlot)
            delete(handles.estimatedAnchorsPlot);
        end

        % Get selected algorithm
        algorithms = get(handles.algorithmMenu, 'String');
        selectedAlgorithm = algorithms{get(handles.algorithmMenu, 'Value')};

        % Simulate distances with noise
        distances = sqrt(sum((handles.trueAnchors - handles.trueTagPosition).^2, 2));
        distances_noisy = distances + randn(size(distances)) * 0.1; % Add noise with std deviation of 0.1 m

        % Choose algorithm for anchor calibration
        switch selectedAlgorithm
            case 'Nonlinear Least Squares'
                estimatedAnchors = nonlinearLeastSquares(distances_noisy, handles.trueAnchors, handles.trueTagPosition);
            case 'Maximum Likelihood Estimation'
                estimatedAnchors = maximumLikelihoodEstimation(distances_noisy, handles.trueAnchors, handles.trueTagPosition);
            case 'Extended Kalman Filter'
                estimatedAnchors = extendedKalmanFilter(distances_noisy, handles.trueAnchors, handles.trueTagPosition);
        end

        % Display estimated positions
        disp('Estimated Anchor Positions (m):');
        disp(estimatedAnchors);

        % Update plot with estimated anchors
        handles.estimatedAnchorsPlot = plotAnchors(estimatedAnchors, 'g', 'Estimated Anchors');
        handles.estimatedAnchors = estimatedAnchors;
        % Store the updated handles structure
        guidata(gcbo, handles);

        % Update legend
        legend();
    end