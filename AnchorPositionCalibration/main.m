function main()
    % Parameters
    fs = 1e9; % Sampling frequency
    pulseWidth = 2e-9; % Pulse width in seconds
    pulseAmplitude = 1; % Pulse amplitude
    c = 3e8; % Speed of light in m/s

    % Define 3D Indoor Environment with Initial Anchor Positions
    trueAnchors = [0, 0, 0; 10, 0, 0; 0, 10, 0; 10, 10, 10]; % True anchor positions
    trueTagPosition = [5, 5, 5]; % True position of the tag

    % Create Figure
    fig = figure('Name', 'Anchor Calibration', 'NumberTitle', 'off', 'KeyPressFcn', @moveTag);
    hold on;
    plotAnchors(trueAnchors, 'b', 'True Anchors');
    tagPlot = plotTag(trueTagPosition, 'r', 'True Tag');
    % Ensure legend shows only one entry per type
    legend({'True Anchors', 'True Tag'});
    title('3D Indoor Environment');
    xlabel('X (m)');
    ylabel('Y (m)');
    zlabel('Z (m)');
    grid on;
    view(3);
    axis vis3d;
    axis equal;

    % Dropdown menu for algorithm selection
    uicontrol('Style', 'text', 'String', 'Select Calibration Algorithm:', 'Position', [20 60 200 20]);
    % Dropdown menu for algorithm selection
    algorithmMenu = uicontrol('Style', 'popupmenu', 'String', {'Nonlinear Least Squares', ...
                                                            'Maximum Likelihood Estimation', ...
                                                            'Extended Kalman Filter', ...
                                                            'Linear Least Squares', ...
                                                            'Weighted Least Squares', ...
                                                            'Iterative Refinement', ...
                                                            'Maximum A Posteriori', ...
                                                            'Genetic Algorithm'}, ...
                          'Position', [20 30 200 30]);


    % Initialize handles structure
    handles = struct();
    handles.estimatedAnchorsPlot = [];
    handles.estimatedAnchors = [];
    handles.algorithmMenu = algorithmMenu;
    handles.trueAnchors = trueAnchors;
    handles.trueTagPosition = trueTagPosition;
    handles.estimatedTagPlot = [];
    handles.estimatedTagPosition = [];
    handles.tagPlot = tagPlot; % Handle for the tag plot
    handles.stepSize = 0.1;
    handles.tagErrorData = [];
    handles.anchorErrorData = cell(1, 4);
    handles.tagErrorAxes = [];
    handles.initGuessRange = 0.1;

    % Create Calibrate Anchors button with callback
    uicontrol('Style', 'pushbutton', 'String', 'Calibrate Anchors', 'Position', [20 0 120 30], ...
        'Callback', @(src, event) calibrateAnchors(src, event));

    % Button for locating tag
    uicontrol('Style', 'pushbutton', 'String', 'Locate Tag', 'Position', [150 0 100 30], 'Callback', @(src, event) locateTag(src, event));

    % Create a single figure for all error plots
    handles.errorFigure = figure('Name', 'Error Plots', 'NumberTitle', 'off');
    
    % Create subplots
    numAnchors = size(handles.trueAnchors, 1);
    
    % Tag Error Plot
    handles.tagErrorAxes = subplot(numAnchors + 1, 1, 1, 'Parent', handles.errorFigure);
    xlabel(handles.tagErrorAxes, 'Movement Steps');
    ylabel(handles.tagErrorAxes, 'Error (m)');
    title(handles.tagErrorAxes, 'Tag Position Error');
    handles.tagErrorData = []; % Initialize empty data for tag error

    % Anchor Error Plots
    handles.anchorErrorAxes = gobjects(numAnchors, 1);
    handles.anchorErrorData = cell(numAnchors, 1); % Initialize cell array for errors
    
    for i = 1:numAnchors
        handles.anchorErrorAxes(i) = subplot(numAnchors + 1, 1, i + 1, 'Parent', handles.errorFigure);
        xlabel(handles.anchorErrorAxes(i), 'Movement Steps');
        ylabel(handles.anchorErrorAxes(i), 'Error (m)');
        title(handles.anchorErrorAxes(i), ['Anchor ' num2str(i) ' Error']);
        handles.anchorErrorData{i} = []; % Initialize empty data for each anchor
    end

    % Store the handles structure
    guidata(fig, handles);

end


