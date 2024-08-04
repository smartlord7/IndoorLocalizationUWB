function updateErrorPlots()
    % Retrieve handles
    handles = guidata(gcbo);

    % Update the error for the tag
    tagError = norm(handles.trueTagPosition - handles.estimatedTagPosition);
    handles.tagErrorData = [handles.tagErrorData; tagError]; % Store new error data
    
    % Update the tag error plot
    plot(handles.tagErrorAxes, handles.tagErrorData, 'r-', 'DisplayName', 'Tag Error');
    legend(handles.tagErrorAxes, 'show');
    
    % Update errors for each anchor
    numAnchors = size(handles.trueAnchors, 1);
    for i = 1:numAnchors
        anchorError = norm(handles.trueAnchors(i, :) - handles.estimatedAnchors(i, :));
        handles.anchorErrorData{i} = [handles.anchorErrorData{i}; anchorError]; % Store new error data
        
        % Update the anchor error plot
        plot(handles.anchorErrorAxes(i), handles.anchorErrorData{i}, 'b-', 'DisplayName', ['Anchor ' num2str(i) ' Error']);
        legend(handles.anchorErrorAxes(i), 'show');
    end
    
    % Store the updated handles
    guidata(gcbo, handles);
end