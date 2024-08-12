function updateAnchors(~, ~, t)
    try
        % Access the UserData property
        stepData = get(t, 'UserData'); % Retrieve UserData
        
        % Validate handles
        if any(~isvalid(stepData.h))
            disp('One or more handles are invalid.');
            stop(t);
            delete(t);
            return;
        end
        
        if isempty(stepData.currentStep) || mod(stepData.currentStep, 100) == 0 
            stepData.currentStep = 0;
        end
        
        % Calculate the interpolation factor
        factor = stepData.currentStep / 100;
        
        % Update positions
        for i = 1:size(stepData.positions, 1)
            % Interpolate between previous and current positions
            currentPosition = stepData.prevPositions(i, :) + factor * (stepData.positions(i, :) - stepData.prevPositions(i, :));
            
            % Update the anchor's surface data
            [X, Y, Z] = sphere; % Sphere coordinates
            xData = X + currentPosition(1);
            yData = Y + currentPosition(2);
            zData = Z + currentPosition(3);
            
            % Check if the handle is still valid before setting the data
            if isvalid(stepData.h(i))
                % Set the updated data
                set(stepData.h(i), 'XData', xData, 'YData', yData, 'ZData', zData);
            else
                disp(['Handle for anchor ' num2str(i) ' is invalid.']);
            end
        end
    
        % Increment step
        stepData.currentStep = stepData.currentStep + 1;
        
        % Update the timer's UserData with the new stepData
        set(t, 'UserData', stepData); % Update UserData

        % Stop timer when the animation is complete
        if stepData.currentStep > stepData.totalSteps
            stop(t);
            delete(t);
            disp('Timer completed successfully.');
        end
        
    catch ME
        % Handle errors here
        disp('An error occurred during the animation:');
        disp(getReport(ME));
        
        % Stop and delete the timer to prevent further issues
        stop(t);
        delete(t);
    end
end
