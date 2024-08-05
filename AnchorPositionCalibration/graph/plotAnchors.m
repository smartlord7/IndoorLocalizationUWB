function h = plotAnchors(prevPositions, positions, color, displayName, transitionTime)
    % Plot the anchors with a smooth transition effect
    % positions: Array of anchor positions
    % color: Color of the anchors
    % displayName: Display name for the legend
    % transitionTime: Duration of the transition in seconds
    
    [X, Y, Z] = sphere; % Create sphere for anchor representation
    numAnchors = size(positions, 1);
    h = gobjects(numAnchors, 1);

  
    
    % Create anchor handles
    for i = 1:numAnchors
        h(i) = surf(X + positions(i, 1), Y + positions(i, 2), Z + positions(i, 3), ...
                    'FaceColor', color, 'EdgeColor', 'none', 'DisplayName', displayName, ...
                    'HandleVisibility', 'off');
    end
    
    % Initialize animation
    steps = 100; % Number of animation steps
    interval = transitionTime / steps; % Time between steps
    
    % Create a timer to update the position
    t = timer('ExecutionMode', 'fixedRate', 'Period', interval, ...
              'TasksToExecute', steps, 'TimerFcn', @(src, event) updateAnchors(src, event, prevPositions, positions, h));
    
    % Start the animation
    start(t);
  
end