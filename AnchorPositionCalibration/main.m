function main()
    % Parameters
    fs = 1e9; % Sampling frequency
    pulseWidth = 2e-9; % Pulse width in seconds
    pulseAmplitude = 1; % Pulse amplitude
    c = 3e8; % Speed of light in m/s

    % Number of Anchors
    nAnchors = 6;
    
    % Define 3D Indoor Environment with Random Anchor Positions
    trueAnchors = 20 * rand(nAnchors, 3); % Random anchor positions in the cube [0, 10] x [0, 10] x [0, 10]
    trueTagPosition = [5, 5, 5]; % True position of the tag

    % Create Figure
    fig = figure('Name', 'Anchor Calibration', 'NumberTitle', 'off', 'KeyPressFcn', @(src, event) moveTag(src, event));
    hold on;
    plotAnchors(zeros(size(trueAnchors)),  trueAnchors, 'b', 'True Anchors', 2, false); % 2 seconds transition time
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
    algorithmMenu = uicontrol('Style', 'popupmenu', 'String', {'Nonlinear Least Squares', ...
                                                            'Maximum Likelihood Estimation', ...
                                                            'Extended Kalman Filter', ...
                                                            'Linear Least Squares', ...
                                                            'Weighted Least Squares', ...
                                                            'Iterative Refinement', ...
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
    handles.stepSize = 0.4;
    handles.tagErrorData = [];
    handles.anchorErrorData = cell(1, nAnchors);
    handles.tagErrorAxes = [];
    handles.initGuessRange = 0.1;
    handles.toaStd = 1e-9;
    handles.distancesStd = 0.1;
    handles.tagPosStd = 0.1;
    handles.h = [];
    handles.anchorTransmissionRadius = 15;

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
