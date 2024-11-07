function path = generateRandomPath(steps, mx)
    % Initialize the path with random starting positions within the room limits
    path = zeros(steps, 3);
    path(1, :) = [rand * mx(1), rand * mx(2), rand * mx(3)];  % Random starting point within the room

    % Generate random steps for each subsequent point, constrained within the room
    for i = 2:steps
        step = (rand(1, 3) - 0.5) * 2; % Random step between -1 and 1 in each direction
        
        % Add the step to the previous point
        newPosition = path(i-1, :) + step;
        
        % Ensure the position stays within room boundaries [0, mx]
        newPosition = max(min(newPosition, mx), 0);  % Clamp values within [0, mx]
        
        % Store the new position
        path(i, :) = newPosition;
    end
end
