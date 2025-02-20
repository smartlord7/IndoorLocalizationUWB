function process_log_data(folder_path, anchor_file, trajectory_file, num_samples, output_file)
    % Reads UWB data, anchor positions, and trajectory, aggregates data across multiple files, 
    % and averages redundant samples for better stability.
    %
    % Inputs:
    % - folder_path: Directory containing log files
    % - anchor_file: Path to the file with anchor coordinates
    % - trajectory_file: Path to the file with predefined trajectory points
    % - num_samples: Number of samples to extract based on closest trajectory points
    % - output_file: Output CSV file to store processed data
    
    % Read anchor positions
    anchors = read_anchors(anchor_file);
    
    % Read predefined trajectory points
    trajectory = read_trajectory(trajectory_file);
    
    % Get list of log files in the directory
    files = dir(fullfile(folder_path, '*.log'));

    % Initialize data storage across all files
    all_data = [];
    sample_num = 0; % Global sample counter

    % Process each file and aggregate
    for file = files'
        file_path = fullfile(file.folder, file.name);
        file_data = readlines(file_path);

        for line = file_data'
            sample_num = sample_num + 1;
            anchor_distances = containers.Map(keys(anchors), num2cell(nan(1, length(anchors))));
            tag_position = NaN(1,3);
            
            % Extract distances from log line
            tokens = regexp(line, '([A-F0-9]+)\[([-0-9\.]+),([-0-9\.]+),([-0-9\.]+)\]=(\d+\.\d+)', 'tokens');
            est_tokens = regexp(line, 'est\[([-0-9\.]+),([-0-9\.]+),([-0-9\.]+)', 'tokens');
            
            for i = 1:length(tokens)
                hex_code = tokens{i}{1};
                if isKey(anchors, hex_code)
                    anchor_distances(hex_code) = str2double(tokens{i}{5});
                end
            end
            
            % Extract estimated tag position
            if ~isempty(est_tokens)
                tag_position = [str2double(est_tokens{1}{1}), ...
                                str2double(est_tokens{1}{2}), ...
                                str2double(est_tokens{1}{3})];
            end
            
            % Handle missing distances using real anchor positions
            anchor_keys = keys(anchor_distances);
            for i = 1:length(anchor_keys)
                if isnan(anchor_distances(anchor_keys{i}))
                    anchor_distances(anchor_keys{i}) = estimate_missing_distance(tag_position, anchors(anchor_keys{i}));
                end
            end
            
            timestamp = sample_num; % Ensures unique timestamps across files

            % Store data for later selection
            data_entry = struct('timestamp', timestamp, 'tag_position', tag_position, ...
                                'anchor_distances', anchor_distances, 'sample_num', sample_num);
            all_data = [all_data, data_entry]; %#ok<AGROW>
        end
    end

    % Select closest samples to predefined trajectory points & apply averaging
    selected_data = select_and_average_samples(all_data, trajectory, num_samples);
    
    % Write aggregated and averaged data to file
    fid = fopen(output_file, 'w');
    fprintf(fid, 'Timestamp,AnchorID,Distance,SampleNumber,EstimatedX,EstimatedY,EstimatedZ\n');
    
    for i = 1:length(selected_data)
        entry = selected_data(i);
        anchor_keys = keys(entry.anchor_distances);
        for j = 1:length(anchor_keys)
            fprintf(fid, '%.3f,%s,%.6f,%d,%.6f,%.6f,%.6f\n', ...
                    entry.timestamp, anchor_keys{j}, entry.anchor_distances(anchor_keys{j}), ...
                    entry.sample_num, entry.tag_position(1), entry.tag_position(2), entry.tag_position(3));
        end
    end
    
    fclose(fid);
end

%% Function to Select and Average Nearby Samples
function averaged_data = select_and_average_samples(all_data, trajectory, num_samples)
    % Selects num_samples closest samples to predefined trajectory points 
    % and averages samples within a distance threshold.

    distance_threshold = 0.05;   % How far a sample can be from the trajectory point
    max_samples_per_point = 10;  % Max samples used for averaging at each trajectory point
    
    averaged_data = [];
    
    for i = 1:size(trajectory, 2)
        traj_point = trajectory(:, i)';  % Get trajectory point as row vector
        nearby_samples = [];
        
        % Find all samples within the distance threshold
        for j = 1:length(all_data)
            entry = all_data(j);
            tag_pos = entry.tag_position;
            dist = norm(tag_pos - traj_point);
            
            if dist < distance_threshold
                nearby_samples = [nearby_samples, entry]; %#ok<AGROW>
            end
        end
        
        % Limit the number of samples to the max threshold
        if length(nearby_samples) > max_samples_per_point
            nearby_samples = nearby_samples(1:max_samples_per_point);
        end
        
        % If we have multiple nearby samples, average them
        if ~isempty(nearby_samples)
            avg_entry = struct('timestamp', mean([nearby_samples.timestamp]), ...
                               'tag_position', mean(reshape([nearby_samples.tag_position], 3, []), 2)', ...
                               'sample_num', mean([nearby_samples.sample_num]));

            % Average anchor distances
            anchor_keys = keys(nearby_samples(1).anchor_distances);
            avg_distances = containers.Map(anchor_keys, num2cell(zeros(1, length(anchor_keys))));
            
            % Properly accumulate anchor distances
            for k = 1:length(anchor_keys)
                key = anchor_keys{k};
                dist_values = zeros(1, length(nearby_samples));
                
                for s = 1:length(nearby_samples)
                    dist_values(s) = nearby_samples(s).anchor_distances(key);
                end
                
                avg_distances(key) = mean(dist_values);
            end
            
            avg_entry.anchor_distances = avg_distances;
            averaged_data = [averaged_data, avg_entry]; %#ok<AGROW>
        end
        
        % Stop if we reach the required number of samples
        if length(averaged_data) >= num_samples
            break;
        end
    end
end



function anchors = read_anchors(file_path)
    % Reads anchor positions from a file and returns a map with anchor IDs as keys.
    file_data = readlines(file_path);
    anchors = containers.Map();
    
    for line = file_data'
        tokens = regexp(line, '([A-F0-9]+)\[([-0-9\.]+),([-0-9\.]+),([-0-9\.]+)\]', 'tokens');
        if ~isempty(tokens)
            hex_code = tokens{1}{1};
            position = [str2double(tokens{1}{2}), str2double(tokens{1}{3}), str2double(tokens{1}{4})];
            anchors(hex_code) = position;
        end
    end
end

function trajectory = read_trajectory(file_path)
    % Reads trajectory points from a file and returns a 3 x N matrix.

    file_data = fileread(file_path);
    tokens = regexp(file_data, '\((-?\d+\.\d+),(-?\d+\.\d+),(-?\d+\.\d+)\)', 'tokens');
    
    % Convert tokens to numeric array
    trajectory_vector = cell2mat(cellfun(@(t) str2double(t), tokens, 'UniformOutput', false));
    
    % Reshape to 3 x N (3 rows for X, Y, Z and N columns for samples)
    trajectory = reshape(trajectory_vector, 3, []);
end




function estimated_distance = estimate_missing_distance(tag_pos, anchor_pos)
    estimated_distance = sqrt(sum((tag_pos - anchor_pos).^2));
end
