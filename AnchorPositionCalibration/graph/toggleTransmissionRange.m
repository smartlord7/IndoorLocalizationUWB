function toggleTransmissionRange(checkbox, ~)
    handles = guidata(gcf); % Retrieve handles structure
    % Update visibility of transmission range spheres based on checkbox state
    if get(checkbox, 'Value') == 1
        % Show transmission range
        set(handles.transmissionRangePlot, 'Visible', 'on');
    else
        % Hide transmission range
        set(handles.transmissionRangePlot, 'Visible', 'off');
    end
end