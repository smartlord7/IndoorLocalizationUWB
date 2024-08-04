function moveTag(~, event)
    % Retrieve handles
    handles = guidata(gcbo);

    % Determine the step size for movement
    stepSize = handles.stepSize;

    % Move the tag based on key press
    switch event.Key
        case 'uparrow'
            handles.trueTagPosition(3) = handles.trueTagPosition(3) + stepSize;
        case 'downarrow'
            handles.trueTagPosition(3) = handles.trueTagPosition(3) - stepSize;
        case 'leftarrow'
            handles.trueTagPosition(1) = handles.trueTagPosition(1) - stepSize;
        case 'rightarrow'
            handles.trueTagPosition(1) = handles.trueTagPosition(1) + stepSize;
        case 'pageup'
            handles.trueTagPosition(2) = handles.trueTagPosition(2) + stepSize;
        case 'pagedown'
            handles.trueTagPosition(2) = handles.trueTagPosition(2) - stepSize;
    end
    
    % Update tag position in the plot
    if ishandle(handles.tagPlot)
        delete(handles.tagPlot);
    end
    handles.tagPlot = plotTag(handles.trueTagPosition, 'r', 'Tag');
    
    % Store the updated handles structure
    guidata(gcbo, handles);
    
    % Perform calibration
    calibrateAnchors(handles);

    % Call locateTag to update the plot and calculate tag position
    locateTag();

    % Update the error plots
    updateErrorPlots();

    % Update plot and GUI
    drawnow;
end
