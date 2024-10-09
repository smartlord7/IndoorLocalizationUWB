function rmse = root_mean_squared_error(matrix1, matrix2)
    % Check if the input matrices have the same size
    if ~isequal(size(matrix1), size(matrix2))
        error('Input matrices must have the same size.');
    end
    
    % Compute the squared differences between the two matrices
    squared_diff = (matrix1 - matrix2) .^ 2;
    
    % Calculate the mean of the squared differences
    rmse = sqrt(mean(squared_diff(:)));
end