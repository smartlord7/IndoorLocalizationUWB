function tagPos = generateStratifiedTags(xRange, yRange, zRange)
    % Generates a tag position using stratified sampling within the 3D space.
    
    % Define the number of subdivisions for each axis (more subdivisions give more uniform coverage)
    numDivisions = 10;
    
    % Choose a random subdivision index along each axis
    xIdx = randi(numDivisions);
    yIdx = randi(numDivisions);
    zIdx = randi(numDivisions);
    
    % Compute stratified position within the range for each axis
    xPos = xRange(1) + (xIdx - 0.5) * (xRange(2) - xRange(1)) / numDivisions;
    yPos = yRange(1) + (yIdx - 0.5) * (yRange(2) - yRange(1)) / numDivisions;
    zPos = zRange(1) + (zIdx - 0.5) * (zRange(2) - zRange(1)) / numDivisions;
    
    tagPos = [xPos, yPos, zPos];
end
