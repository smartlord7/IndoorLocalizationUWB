function uwb_3d_anchor_calibration()
    % Parameters
    fs = 1e9; % Sampling frequency
    pulseWidth = 2e-9; % Pulse width in seconds
    pulseAmplitude = 1; % Pulse amplitude
    c = 3e8; % Speed of light in m/s

    % Define 3D Indoor Environment with Initial Anchor Positions
    trueAnchors = [0, 0, 0; 10, 0, 0; 0, 10, 0; 10, 10, 10]; % True anchor positions
    trueTagPosition = [5, 5, 5]; % True position of the tag
    
    % Create Figure
    fig = figure;
    hold on;
    plotAnchors(trueAnchors, 'b', 'True Anchors');
    plotTag(trueTagPosition, 'r', 'True Tag');
    % Ensure legend shows only one entry per type
    legend({'True Anchors', 'True Tag'});
    title('3D Indoor Environment');
    xlabel('X (m)');
    ylabel('Y (m)');
    zlabel('Z (m)');
    grid on;
    view(3);

    % Dropdown menu for algorithm selection
    uicontrol('Style', 'text', 'String', 'Select Calibration Algorithm:', 'Position', [20 60 200 20]);
    algorithmMenu = uicontrol('Style', 'popupmenu', 'String', {'Nonlinear Least Squares', 'Maximum Likelihood Estimation', 'Extended Kalman Filter'}, 'Position', [20 30 200 30]);

    % Initialize handles structure
    handles = struct();
    handles.estimatedAnchorsPlot = [];
    handles.estimatedAnchors = [];
    handles.algorithmMenu = algorithmMenu;
    handles.trueAnchors = trueAnchors;
    handles.trueTagPosition = trueTagPosition;
    handles.estimatedTagPlot = [];

    % Store the handles structure
    guidata(fig, handles);

    % Button for calibrating anchors
    uicontrol('Style', 'pushbutton', 'String', 'Calibrate Anchors', 'Position', [20 0 120 30], 'Callback', @(src, event) calibrateAnchors(src, event));

    % Button for locating tag
    uicontrol('Style', 'pushbutton', 'String', 'Locate Tag', 'Position', [150 0 100 30], 'Callback', @(src, event) locateTag(src, event));


end


