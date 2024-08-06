function updateAnchors(~, ~, prevPositions, positions, h)
    persistent currentStep;
    
    if isempty(currentStep) | mod(currentStep, 100) == 0 
        currentStep = 0;
    end
    
    % Calculate the interpolation factor
    factor = currentStep / 100;
    
    % Update positions
    for i = 1:size(positions, 1)
        % Interpolate between previous and current positions
        currentPosition = prevPositions(i, :) + factor * (positions(i, :) - prevPositions(i, :));
        
        % Update the anchor's surface data
        [X, Y, Z] = sphere; % Sphere coordinates
        xData = X + currentPosition(1);
        yData = Y + currentPosition(2);
        zData = Z + currentPosition(3);
        
        % Set the updated data
        set(h(i), 'XData', xData, 'YData', yData, 'ZData', zData);
    end

    % Increment step
    currentStep = currentStep + 1;
end
