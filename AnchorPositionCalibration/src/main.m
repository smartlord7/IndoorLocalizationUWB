function main()
    % Parameters
    fs = 1e9; % Sampling frequency
    pulseWidth = 2e-9; % Pulse width in seconds
    pulseAmplitude = 1; % Pulse amplitude
    c = 3e8; % Speed of light in m/s

    % Number of Anchors
    nAnchors = 6;
    % Define 3D Indoor Environment with Random Anchor Positions
    mx = 30;
    trueAnchors = mx * rand(nAnchors, 3); % Random anchor positions in the cube [0, 30] x [0, 30] x [0, 30]
    trueTagPosition = [20, 20, 20]; % True position of the tag in the center of the cube

    % Create Figure
    fig = figure('Name', 'Anchor Calibration', 'NumberTitle', 'off', 'KeyPressFcn', @(src, event) moveTag(src, event));
    ax = axes('Parent', fig);
    hold on;
    camlight; lighting gouraud; % Enhance visualization with lighting
    
    % Plot True Anchors and Tag
    handles.trueAnchorsPlot = plotAnchors(zeros(size(trueAnchors)), trueAnchors, 'b', 'True Anchors', 2, false); % 2 seconds transition time
    handles.tagPlot = plotTag(trueTagPosition, 'r', 'True Tag');
    
    % Plot transmission range spheres and boundaries
    handles.anchorTransmissionRadius = 20;
    handles.transmissionRangePlot = plotTransmissionRanges(trueAnchors, handles.anchorTransmissionRadius);
    handles.possibleBoundaryPlot = plotPossibleLocalizationBoundary(trueAnchors, handles.anchorTransmissionRadius);
    [handles.usageBoundaryPlot, plotHandles] = plotAnchorUsageBoundary(trueAnchors, handles.anchorTransmissionRadius, ax);
    
    % Ensure legend shows only one entry per type
    legend({'True Anchors', 'True Tag'});
    
    % Set axis limits for a 40x40x40 world
    title('3D Indoor Environment');
    xlabel('X (m)');
    ylabel('Y (m)');
    zlabel('Z (m)');

     % Ensure the aspect ratio and plot box ratio are set to manual
    set(ax, 'DataAspectRatioMode', 'manual');
    set(ax, 'PlotBoxAspectRatioMode', 'manual');
    % Set fixed axis limits
    xlim(ax, [-20 50]); % Set fixed limits for X axis
    ylim(ax, [-20 50]); % Set fixed limits for Y axis
    zlim(ax, [-20 50]); % Set fixed limits for Z axis
    

    % Ensure the aspect ratio is equal
    axis(ax, 'equal');

    % Grid and View
    grid(ax, 'on');
    view(3);
    axis vis3d;

    calibrationAlgorithms =  {'Nonlinear Least Squares', ...
                                                            'Maximum Likelihood Estimation', ...
                                                            'Extended Kalman Filter', ...
                                                            'Linear Least Squares', ...
                                                            'Weighted Least Squares', ...
                                                            'Iterative Refinement', ...
                                                            'Genetic Algorithm', ...
                                                            'Linear Programming', ...
                                                            'Shallow Neural Network'};

    % Dropdown menu for algorithm selection
    uicontrol('Style', 'text', 'String', 'Select Calibration Algorithm:', 'Position', [20 60 200 20]);
    algorithmMenu = uicontrol('Style', 'popupmenu', 'String', calibrationAlgorithms, ...
                          'Position', [20 30 200 30]);

    % Checkbox for transmission radius visibility
    handles.transmissionCheckbox = uicontrol('Style', 'checkbox', 'String', 'Show Transmission Range', ...
                                             'Position', [20 100 150 30], 'Value', 1, ...
                                             'Callback', @(src, event) toggleVisibility(src, event, 'transmissionRange'));

    % Checkbox for impossible localization boundary visibility
    handles.possibleCheckbox = uicontrol('Style', 'checkbox', 'String', 'Show Possible Localization Boundary', ...
                                           'Position', [20 140 250 30], 'Value', 1, ...
                                           'Callback', @(src, event) toggleVisibility(src, event, 'impossibleBoundary'));

    % Checkbox for anchor usage boundary visibility
    handles.usageCheckbox = uicontrol('Style', 'checkbox', 'String', 'Show Anchor Usage Boundary', ...
                                      'Position', [20 180 200 30], 'Value', 1, ...
                                      'Callback', @(src, event) toggleVisibility(src, event, 'usageBoundary'));

    % Create checkboxes for toggling visibility on the right side
    checkboxWidth = 150; % Width of the checkboxes
    checkboxHeight = 20; % Height of each checkbox
    padding = 10; % Padding between checkboxes
    panelWidth = 200; % Width of the panel to hold checkboxes
    
    % Create a panel for checkboxes
    panel = uipanel('Parent', fig, 'Position', [0.8, 0.1, 0.2, 0.3], 'Title', 'Toggle Anchor Usage Boundaries');
    
    % Create checkboxes for toggling visibility
    for k = 1:numel(plotHandles)
        uicontrol('Style', 'checkbox', 'String', sprintf('Show %d Anchors', k), ...
            'Parent', panel, ...
            'Position', [10, panelWidth - k * (checkboxHeight + padding), checkboxWidth, checkboxHeight], ...
            'Value', 1, 'Callback', @(src, ~) toggleVisibility2(src, plotHandles(k)));
    end

    % Initialize handles structure
    handles.estimatedAnchorsPlot = [];
    handles.estimatedAnchors = [];
    handles.algorithmMenu = algorithmMenu;
    handles.trueAnchors = trueAnchors;
    handles.trueTagPosition = trueTagPosition;
    handles.estimatedTagPlot = [];
    handles.estimatedTagPosition = [];
    handles.tagPlot = handles.tagPlot; % Handle for the tag plot
    handles.stepSize = 0.4;
    handles.tagErrorData = [];
    handles.anchorErrorData = cell(1, nAnchors);
    handles.tagErrorAxes = [];
    handles.initGuessRange = 0.5;
    handles.toaStd = 1e-9;
    handles.distancesStd = 0.1;
    handles.tagPosStd = 0.1;
    handles.h = [];

    lb = repmat([0 0 0], nAnchors, 1); % Lower bounds
    ub = repmat([mx mx mx], nAnchors, 1);  % Upper bounds
    sz = size(lb);
    bounds = zeros(2, sz(1), sz(2));
    bounds(1, :, :) = lb;
    bounds(2, :, :) = ub;

    handles.bounds = bounds;
    
    % Store the handles structure
    guidata(fig, handles);

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
        title(handles.anchorErrorAxes(i), ['Anchor ' num2str(i) ' Position Error']);
        handles.anchorErrorData{i} = []; % Initialize empty data for each anchor
    end

    % Create subplots for histograms
    handles.errorHistFigure = figure('Name', 'Error Histograms', 'NumberTitle', 'off');
    
    % Tag Error Histogram Plot
    handles.tagErrorHistAxes = subplot(numAnchors + 1, 1, 1, 'Parent', handles.errorHistFigure);
    xlabel(handles.tagErrorHistAxes, 'Error (m)');
    ylabel(handles.tagErrorHistAxes, 'Frequency');
    title(handles.tagErrorHistAxes, 'Tag Position Error Histogram');
    
    % Anchor Error Histogram Plots
    handles.anchorErrorHistAxes = gobjects(numAnchors, 1);
    
    for i = 1:numAnchors
        handles.anchorErrorHistAxes(i) = subplot(numAnchors + 1, 1, i + 1, 'Parent', handles.errorHistFigure);
        xlabel(handles.anchorErrorHistAxes(i), 'Error (m)');
        ylabel(handles.anchorErrorHistAxes(i), 'Frequency');
        title(handles.anchorErrorHistAxes(i), ['Anchor ' num2str(i) ' Error Histogram']);
    end


    % Store the handles structure
    guidata(fig, handles);

end
