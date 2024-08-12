function updateErrorPlots()
    % Retrieve handles
    handles = guidata(gcbo);

    % Update the error for the tag
    tagError = sum((handles.trueTagPosition - handles.estimatedTagPosition).^2, 2);
    anchorErrors = sum((handles.trueAnchors - handles.estimatedAnchors).^2, 2);
    handles.tagErrorData = [handles.tagErrorData; tagError]; % Store new error data
    
    % Update the tag error plot
    plot(handles.tagErrorAxes, handles.tagErrorData, 'r-', 'DisplayName', 'Tag Error');
    legend(handles.tagErrorAxes, 'show');

     % Update histogram for tag error
    histogram(handles.tagErrorHistAxes, handles.tagErrorData, ...
        'BinWidth', 0.2, ...
        'DisplayName', 'Tag Position Error Histogram');
    
    % Update errors for each anchor
    numAnchors = size(handles.trueAnchors, 1);
    for i = 1:numAnchors
        anchorError = norm(handles.trueAnchors(i, :) - handles.estimatedAnchors(i, :));
        handles.anchorErrorData{i} = [handles.anchorErrorData{i}; anchorError]; % Store new error data
        
        % Update the anchor error plot
        plot(handles.anchorErrorAxes(i), handles.anchorErrorData{i}, 'b-', 'DisplayName', ['Anchor ' num2str(i) ' Error']);
        legend(handles.anchorErrorAxes(i), 'show');

        % Update histogram for each anchor
        histogram(handles.anchorErrorHistAxes(i), handles.anchorErrorData{i}, ...
            'BinWidth', 0.2, ...
            'DisplayName', ['Anchor ' num2str(i) ' Position Error Histogram']);
        legend(handles.anchorErrorHistAxes(i), 'show');
    end
    
    % Store the updated handles
    guidata(gcbo, handles);
end