function newMatrix = reshapeToSquare(matrix)
    % Get the total number of elements in the input matrix
    [rows, cols] = size(matrix);
    numElements = rows * cols;
    
    % Find the closest integer to the square root of the number of elements
    newRows = floor(sqrt(numElements));
    newCols = ceil(numElements / newRows);
    
    % Pad the matrix with zeros if necessary
    if newRows * newCols > numElements
        % Calculate how many elements are missing
        paddingSize = newRows * newCols - numElements;
        % Pad the matrix with zeros
        matrix = [matrix(:); zeros(paddingSize, 1)];
    end
    
    % Reshape the matrix to the new dimensions
    newMatrix = reshape(matrix, [newRows, newCols]);
end