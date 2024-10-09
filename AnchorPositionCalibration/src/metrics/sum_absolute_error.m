function error_sum = sum_absolute_error(matrix1, matrix2)
    % Check if the input matrices have the same size
    if ~isequal(size(matrix1), size(matrix2))
        error('Input matrices must have the same size.');
    end
    
    % Compute the absolute differences between the two matrices
    abs_diff = abs(matrix1 - matrix2);
    
    % Sum all the absolute differences
    error_sum = sum(abs_diff(:));
end