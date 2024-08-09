function toggleVisibility(src, ~, plotType)
    % Retrieve handles structure
    handles = guidata(src);
    
    % Toggle visibility based on checkbox state
    switch plotType
        case 'transmissionRange'
            set(handles.transmissionRangePlot, 'Visible', src.Value);
        case 'impossibleBoundary'
            set(handles.possibleBoundaryPlot, 'Visible', src.Value);
        case 'usageBoundary'
            set(handles.usageBoundaryPlot, 'Visible', src.Value);
    end
end