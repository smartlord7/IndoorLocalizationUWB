function trajectory = read_trajectory(file_path)
    % Reads trajectory points from a file and returns a 3 x N matrix.

    file_data = fileread(file_path);
    tokens = regexp(file_data, '\((-?\d+\.\d+),(-?\d+\.\d+),(-?\d+\.\d+)\)', 'tokens');
    
    % Convert tokens to numeric array
    trajectory_vector = cell2mat(cellfun(@(t) str2double(t), tokens, 'UniformOutput', false));
    
    % Reshape to 3 x N (3 rows for X, Y, Z and N columns for samples)
    trajectory = reshape(trajectory_vector, 3, []);
end