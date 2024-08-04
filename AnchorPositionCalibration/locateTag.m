function estimatedTagPlot = locateTag(~, ~)
        % Get the handles structure
        handles = guidata(gcbo);

        % Check if estimatedAnchors exists and is not empty before proceeding
        if isempty(handles.estimatedAnchorsPlot)
            msgbox('Please calibrate anchors first.');
            return;
        end

        % Remove previous estimated tag from plot
        if ~isempty(handles.estimatedTagPlot)
            delete(handles.estimatedTagPlot);
        end

        % Calculate Distances and ToA from calibrated anchors to true tag
        distances = sqrt(sum((handles.estimatedAnchors - handles.trueTagPosition).^2, 2));
        c = 3e8;
        ToA = distances / c;

        % Add Noise to ToA
        ToA_noisy = ToA + randn(size(ToA)) * 1e-9; % Add noise with standard deviation of 1 ns

        % Multilateration to estimate tag position
        costFunction = @(pos) sum((sqrt(sum((handles.estimatedAnchors - pos).^2, 2)) - ToA_noisy * c).^2);
        initialGuess = [5, 5, 5];
        estimatedTagPosition = fminsearch(costFunction, initialGuess);

        % Display estimated position
        disp('Estimated Tag Position (m):');
        disp(estimatedTagPosition);

        % Calculate error
        error = sqrt(sum((handles.trueTagPosition - estimatedTagPosition).^2));
        disp('Positioning Error (m):');
        disp(error);

        % Update plot with estimated tag position
        handles.estimatedTagPlot = plotTag(estimatedTagPosition, 'g', 'Estimated Tag');

        % Store the updated handles structure
        guidata(gcbo, handles);
        
        % Update legend
        legend();
    end