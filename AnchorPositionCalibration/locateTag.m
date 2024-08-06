function estimatedTagPlot = locateTag(~, ~)
    % Get the handles structure
    handles = guidata(gcbo);

    % Check if estimatedAnchors exists and is not empty before proceeding
    if isempty(handles.estimatedAnchors)
        msgbox('Please calibrate anchors first.');
        return;
    end

    % Remove previous estimated tag from plot
    if ~isempty(handles.estimatedTagPlot)
        delete(handles.estimatedTagPlot);
    end

    % Calculate Distances and ToA from calibrated anchors to true tag
    distances = sqrt(sum((handles.estimatedAnchors - trueTagPosition).^2, 2));
    c = 3e8; % Speed of light
    ToA = distances / c;

    % Add Noise to ToA
    ToA_noisy = ToA + randn(size(ToA)) * 1e-9; % Add noise with standard deviation of 1 ns

    % Multilateration to estimate tag position
    costFunction = @(pos) sum((sqrt(sum((handles.estimatedAnchors - pos).^2, 2)) - ToA_noisy * c).^2);
    
    if isempty(handles.estimatedTagPosition)
        initialGuess = handles.trueTagPosition;
    else
        initialGuess = handles.estimatedTagPosition;
    end
    % Initial guess for the tag position

    estimatedTagPosition = fminsearch(costFunction, initialGuess);

    % Display estimated position
    disp('Estimated Tag Position (m):');
    disp(estimatedTagPosition);

    % Calculate error
    err = (handles.trueTagPosition - estimatedTagPosition).^2;
    sse = sum(err);
    mse = mean(err);
    rmse = sqrt(mean(err));
    err_x = err(1);
    err_y = err(2);
    err_z = err(3);
    fprintf("Error (x,y,z) = (%.3f, %.3f, %.3f)\n", err_x, err_y, err_z);
    disp('Positioning SSE (m2):');
    disp(sse);
    disp('Positioning MSE (m2):');
    disp(mse);
    disp('Positioning RMSE (m):');
    disp(rmse);

    % Update plot with estimated tag position
    handles.estimatedTagPlot = plotTag(estimatedTagPosition, 'g', 'Estimated Tag');
    handles.estimatedTagPosition = estimatedTagPosition; % Store the new estimated tag position

    % Store the updated handles structure
    guidata(gcbo, handles);
    
    % Update legend
    legend();
end
